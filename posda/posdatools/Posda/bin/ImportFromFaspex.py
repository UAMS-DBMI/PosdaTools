#!/usr/bin/env python3
"""
A script to automate importing of data from Faspex packages
"""

# from posda.database import Database
# from posda.queries import Query
from posda.background.process import BackgroundProcess
from posda.util import md5sum
from posda.config import Config
from pathlib import Path
import requests
import argparse
import subprocess
import json
import datetime
import os
import sys
import time

URL = f'{Config.get("internal_api_url")}/v1/import/'

rclone_cmd = [
    "rclone",
    "--config",
    "/nas/ross/rclone.conf",
]


def printe(*args):
    """Print, but to STDERR"""
    print(*args, file=sys.stderr)


def sizeof_fmt(num, suffix="B"):
    for unit in ("", "Ki", "Mi", "Gi", "Ti", "Pi", "Ei", "Zi"):
        if abs(num) < 1024.0:
            return f"{num:3.1f}{unit}{suffix}"
        num /= 1024.0
    return f"{num:.1f}Yi{suffix}"


def create_import_event(import_comment):
    r = requests.put(URL + "event", params={"source": import_comment})

    resp = r.json()
    return resp["import_event_id"]


def close_import_event(import_event_id):
    r = requests.post(URL + f"event/{import_event_id}/close")
    resp = r.json()


def add_file(filename, import_event_id, digest):
    """add one file using file_in_place endpoint"""

    r = requests.post(
        URL + "file_in_place",
        params={
            "import_event_id": import_event_id,
            "localpath": filename,
            "digest": digest,
        },
    )

    try:
        resp = r.json()
        return r.status_code, resp
    except:
        return r.status_code, r.content


def parse_args():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("background_id", help="the background_subprocess_id")
    parser.add_argument(
        "activity_id", help="the activity to create the new timepoint in"
    )
    parser.add_argument("package_dir", help="the name of the Faspex package directory")
    parser.add_argument("notify", help="user to notify when complete")

    return parser.parse_args()


def get_size(path):
    res = subprocess.check_output(
        [
            *rclone_cmd,
            "size",
            "--json",
            path,
        ]
    )

    obj = json.loads(res)
    return obj


def copy_files(source_path, dest_path) -> datetime.timedelta:
    # copy doesn't have any way to report progress in machine-readable way
    # so we just measure how long it takes
    copy_start_time = datetime.datetime.now()

    subprocess.check_call(
        [
            *rclone_cmd,
            "copy",
            source_path,
            dest_path,
        ]
    )

    copy_end_time = datetime.datetime.now()

    # return a timedelta of how long it took
    return copy_end_time - copy_start_time


def gen_files(path):
    for path, dnames, fnames in os.walk(path):
        for file in fnames:
            yield os.path.join(path, file)


def main(args):
    storage_base_dir = Path("posda:posda-pathology/posda")
    backup_base_dir = Path("faspex:pathology/posda")
    faspex_base_dir = Path("faspex:packages")

    background = BackgroundProcess(args.background_id, args.notify, args.activity_id)
    background.daemonize()

    source_path = faspex_base_dir / args.package_dir
    dest_path = storage_base_dir / args.activity_id
    backup_path = backup_base_dir / args.activity_id

    print(f"{source_path=}")
    print(f"{dest_path=}")
    print(f"{backup_path=}")
    print(f"{args.package_dir=}")

    size = get_size(source_path)
    human_size = sizeof_fmt(size["bytes"])
    file_count = size["count"]

    copy_time_best_case = size["bytes"] // (100 * 1024 * 1024)  # 100MiB speed estimate
    hr_estimate = datetime.timedelta(seconds=copy_time_best_case)

    background.set_activity_status(
        f"Copying {human_size} in {file_count} files, est {hr_estimate}"
    )

    copy_time = copy_files(source_path, dest_path)
    print(f"time taken: {copy_time}")

    ## Copy to the "backup bucket" here, verify we want to do this (pathology bucket)
    backup_copy_time = copy_files(source_path, backup_path)
    print(f"time taken: {backup_copy_time}")

    # background.set_activity_status("Waiting 1 minute for files to settle")
    # time.sleep(60)

    ## Scan the NFS directory for list of files to import
    nfs_dest_path = str(dest_path).replace("posda:", "/nas/ross/")
    files_to_import = list(gen_files(nfs_dest_path))

    found_count = len(files_to_import)
    if found_count == file_count:
        print(f"Found {found_count} files, looks good.")
    else:
        print(
            f"Found {found_count} files, which doesn't match the earlier count. Something may be wrong"
        )

    ## Perform the import
    perform_import(args, background, files_to_import)

    background.finish("Complete")


def perform_import(args, background, files_to_import):
    import_event_id = create_import_event(f"In-place import of {args.package_dir}")
    print(f"Beginning import, {import_event_id=}")

    total_to_import = len(files_to_import)
    for i, filename in enumerate(files_to_import):
        background.set_activity_status(f"Importing {i+1} of {total_to_import}")
        # digest = b3sum(filename)
        digest = md5sum(filename)
        retries = 5
        while True:
            # Attempt to insert the file (this could fail)
            code, result = add_file(filename, import_event_id, digest)

            # Exit loop if it worked
            if code == 200:
                break

            printe(code, result, filename)
            retries -= 1

            if retries <= 0:
                print(f"Giving up on {filename}")
                break

            time.sleep(10)  # wait 10 seconds before trying again


if __name__ == "__main__":
    args = parse_args()
    main(args)
