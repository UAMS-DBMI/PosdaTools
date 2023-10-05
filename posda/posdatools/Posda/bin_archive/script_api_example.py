#!/usr/bin/python3 -u

from posda.database import Database
from posda.queries import Query
from posda.background.process import BackgroundProcess
from posda.main.file import insert_file

db = Database("nonexistant")


def print_distinct_series_by_collsite(collection, site):
    for row in Query("DistinctSeriesByCollectionSite").run(
            site_name=site,
            project_name=collection):
        print(row)
        break
    else:
        print(f"No collection/site {collection}//{site}")


def hide_some_files(collection, site):
    # hide some files
    hide_file = Query("HideFile")

    for row in Query("FilesInCollectionSiteForSend").run(
            collection=collection,
            site=site):

        count = hide_file.execute(row.file_id)
        print(f"{row.file_id}: {count} row(s) updated")


def unhide_all():
    with Database("posda_files").cursor() as cur:
        cur.execute("update ctp_file "
                    "set visibility = null "
                    "where visibility = 'hidden'")

        print(cur.rowcount, "files unhidden")


background = BackgroundProcess("", 'admin', 1)
background.print_to_email("test email write")
background.daemonize()

r = background.create_report('test report')
r.write("test?")

background.set_activity_status('test!')

# print_distinct_series_by_collsite("LDCT", "Lahey")
# hide_some_files("LDCT", "Lahey")
# unhide_all()

background.finish("final status is this")
