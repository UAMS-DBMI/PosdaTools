import time

import requests

from ..config import Config
from ..subprocess import lines
from ..util import md5sum, printe

API_URL = Config.get("internal-api-url")


def insert_file(filename, comment="Added by Python Job"):
    return insert_file_via_api(filename, comment)


def insert_file_via_api_inplace(filename, comment="Added by Python Job"):
    payload = {
        "localpath": filename,
    }
    r = requests.post(f"{API_URL}/v1/import/file_in_place", params=payload)

    if r.status_code == 200:
        obj = r.json()
        return obj["file_id"]
    else:
        raise RuntimeError(f"Failed to insert file into posda! {r.content.decode()}")


def insert_file_via_api(filename, comment, max_attempts=5, base_delay=1.0):
    payload = {
        "digest": md5sum(filename),
        "localpath": filename,
    }

    last_error = None
    for attempt in range(max_attempts):
        if attempt > 0:
            delay = base_delay * (2 ** (attempt - 1))  # 1s, 2s, 4s, 8s, ...
            printe(
                f"insert_file_via_api: attempt {attempt + 1}/{max_attempts} after {delay:.0f}s delay (last error: {last_error})"
            )
            time.sleep(delay)

        try:
            with open(filename, "rb") as infile:
                r = requests.put(
                    f"{API_URL}/v1/import/file", params=payload, data=infile
                )

            if r.status_code == 200:
                obj = r.json()
                return obj["file_id"]
            else:
                last_error = (
                    f"HTTP {r.status_code}: {r.content.decode(errors='replace')}"
                )

        except requests.exceptions.RequestException as e:
            last_error = str(e)

    raise RuntimeError(
        f"Failed to insert file into posda after {max_attempts} attempts! Last error: {last_error}"
    )


def insert_file_via_perl(filename, comment="Added by Python Job"):
    """Insert a file into posda, and return the new file_id

    Currently implemented via calls to
    the perl program ImportSingleFileIntoPosdaAndReturnId.pl
    """
    for line in lines(["ImportSingleFileIntoPosdaAndReturnId.pl", filename, comment]):
        if line.startswith("File id:"):
            return int(line[8:])

    # TODO: pass on the error if there was one
    raise RuntimeError("Failed to insert file into posda!")
