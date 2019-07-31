from ..subprocess import lines
from ..util import md5sum
from ..util import printe
from ..config import Config
import requests

# this should currently be the docker address: web
# API_URL = Config.get("api_url")
API_URL = "http://web/papi"

def insert_file(filename, comment="Added by Python Job"):
    return insert_file_via_api(filename, comment)


def insert_file_via_api(filename, comment):
    payload = {
        'digest': md5sum(filename),
    }
    with open(filename, "rb") as infile:
        r = requests.put(f"{API_URL}/v1/import/file", params=payload, data=infile)

    if r.status_code == 200:
        obj = r.json()
        return obj['file_id']
    else:
        raise RuntimeError("Failed to insert file into posda!")

def insert_file_via_perl(filename, comment="Added by Python Job"):
    """Insert a file into posda, and return the new file_id

    Currently implemented via calls to 
    the perl program ImportSingleFileIntoPosdaAndReturnId.pl
    """
    for line in lines(['ImportSingleFileIntoPosdaAndReturnId.pl', filename, comment]):
        if line.startswith("File id:"):
            return int(line[8:])

    # TODO: pass on the error if there was one
    raise RuntimeError("Failed to insert file into posda!")
