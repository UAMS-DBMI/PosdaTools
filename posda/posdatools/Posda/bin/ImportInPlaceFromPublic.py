#!/usr/bin/env python3
"""
Import-in-place from Public

This program will import all files in a Collection (and Site)
from Public into Posda.
"""
import sys

import pydicom
import requests

from posda.database import Database
from posda.config import Config
from posda.background.process import BackgroundProcess

import argparse

URL = Config.get("internal_api_url") + "/v1/import/"
OLD_PATH = "/usr/local/apps/ncia/CTP-server/CTP/storage"
NEW_PATH = "/nas/public/storage"


def parse_visibility(s):
    if s == "":
        return None

    try:
        parts = s.split(",")
        int_parts = [int(i) for i in parts]

        return [str(i) for i in int_parts]
    except ValueError as ve:
        print("Error converting visibility parameter:", ve)
        return None


def printe(*args):
    """Print, but to STDERR"""
    print(*args, file=sys.stderr)


def create_import_event(import_comment):
    r = requests.put(URL + "event", params={"source": import_comment})

    resp = r.json()
    return resp["import_event_id"]


def close_import_event(import_event_id):
    r = requests.post(URL + f"event/{import_event_id}/close")
    resp = r.json()


def add_file(filename, digest, import_event_id):
    """add one file using file_in_place endpoint"""

    r = requests.post(
        URL + "file_in_place",
        params={
            "import_event_id": import_event_id,
            "localpath": filename,
            # It was discovered that trusting the digest in NBIA was
            # not wise. Not sending it here will cause the server
            # to generate it from the actual file on disk
            # "digest": digest,
        },
    )

    try:
        resp = r.json()
        return r.status_code, resp
    except:
        return r.status_code, r.content


def get_xfer_syntax(filename):
    try:
        ds = pydicom.dcmread(filename)
        return ds.file_meta.TransferSyntaxUID
    except:
        return None


def import_one_file(import_event_id, filename, digest):
    """import one file using the file_in_place endpoint"""

    # There was a time when files stored in NBIA used
    # a special mount location, which has since changed
    if OLD_PATH in filename:
        filename = filename.replace(OLD_PATH, NEW_PATH)

    code, result = add_file(filename, digest, import_event_id)
    if code != 200:
        printe(code, result, filename)
        return False

    # if result['created']:
    #     ccode = "C"
    # else:
    #     ccode = " "

    # print(f"{ccode}|{result['file_id']}")

    return True


def execute_count_query(cur, collection_name, vis, site_name):
    # Forgive me for the crimes I have committed here
    if vis is None:
        cur.execute(
            """\
            select count(*)
            from general_series gs
            join general_image gi 
                on gi.general_series_pk_id = gs.general_series_pk_id
            where gs.project = %(project)s
            and (%(site)s = "" or gs.site = %(site)s)
        """,
            {
                "project": collection_name,
                "site": site_name
            },
        )

    else:
        cur.execute(
            f"""\
            select count(*)
            from general_series gs
            join general_image gi 
                on gi.general_series_pk_id = gs.general_series_pk_id
            where gs.project = %(project)s
            and (%(site)s = "" or gs.site = %(site)s)
            and gs.visibility in ({','.join(vis)})
        """,
            {
                "project": collection_name,
                "site": site_name
            },
        )


def execute_select_query(cur, collection_name, vis, site_name):
    if vis is None:
        cur.execute(
            """\
            select gi.dicom_file_uri, gi.md5_digest
            from general_series gs
            join general_image gi 
                on gi.general_series_pk_id = gs.general_series_pk_id
            where gs.project = %(project)s
            and (%(site)s = "" or gs.site = %(site)s)
        """,
            {
                "project": collection_name,
                "site": site_name
            },
        )
    else:
        cur.execute(
            f"""\
            select gi.dicom_file_uri, gi.md5_digest
            from general_series gs
            join general_image gi 
                on gi.general_series_pk_id = gs.general_series_pk_id
            where gs.project = %(project)s
            and (%(site)s = "" or gs.site = %(site)s)
            and gs.visibility in ({','.join(vis)})
        """,
            {
                "project": collection_name,
                "site": site_name
            },
        )


def main(background_id, activity_id, notify, collection_name, visibility, site_name):
    background = BackgroundProcess(background_id, notify, activity_id)
    background.daemonize()

    print(f"Beginning import of collection {collection_name} from Public.")
    import_comment = f"Importing {collection_name} from public (in-place)"
    import_event_id = create_import_event(import_comment)
    print(f"Import event id: {import_event_id}")

    with Database("public") as conn:
        cur = conn.cursor()

        vis_list = parse_visibility(visibility)

        execute_count_query(cur, collection_name, vis_list, site_name)

        for (count,) in cur:
            total_files_to_import = count

        print(f"Found {total_files_to_import} files to import.")


        execute_select_query(cur, collection_name, vis_list, site_name)

        # collect all of the filenames into memory
        # NOTE: This is done because, for larger collections
        # some MySQL timeout is exceeded if we step over them
        background.set_activity_status(
            "Selecting filenames from database, this might take a long time.."
        )
        all_records = cur.fetchall()
        error_count = 0
        for i, (uri, digest) in enumerate(all_records):
            if i % 1000 == 0:
                background.set_activity_status(
                    f"Imported {i} of {total_files_to_import}"
                )
            if not import_one_file(import_event_id, uri, digest):
                error_count += 1

    close_import_event(import_event_id)

    if error_count > 0:
        print(f"Unfortunately there were {error_count} errors! See STDERR")
    background.finish(
        f"Complete - imported {total_files_to_import - error_count} files"
    )


def parse_args():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument(
        "background_id", help="background_subprocess_id, should be supplied by Posda"
    )
    parser.add_argument("activity_id", help="the activity you want to convert")
    parser.add_argument("notify", help="the person to notify when complete")
    parser.add_argument("collection_name", help="the collection to import")
    parser.add_argument(
        "visibility",
        help="""comma-seperated list of visibilities to include; leave blank
                for all. Possible values are: 
                0: Not Yet Reviewed,
                1: Visible,
                2: Not Visible,
                3: To Be Deleted,
                4: Delete,
                5: 1st Review,
                6: 2nd Review,
                7: 3rd Review,
                8: 4th Review,
                9: 5th Review,
                10: 6th Review,
                11: 7th Review,
                12: Downloadable
        """,
    )
    parser.add_argument(
        "site_name",
        help="the site to include; leave blank for all",
    )

    return parser.parse_args()


if __name__ == "__main__":
    args = parse_args()

    printe("Running with args: ", args)
    main(
        args.background_id,
        args.activity_id,
        args.notify,
        args.collection_name,
        args.visibility,
        args.site_name,
    )
