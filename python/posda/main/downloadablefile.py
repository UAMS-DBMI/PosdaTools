import uuid
from ..config import Database

URL = 'http://tcia-posda-rh-1.ad.uams.edu/papi'

def make(file_id, mime_type, valid_until=None):
    hash = str(uuid.uuid4())
    with Database('posda_files') as conn:
        cur = conn.cursor()
        cur.execute("""
            insert into downloadable_file 
            (file_id, mime_type, valid_until, security_hash)
            values (%s, %s, %s, %s)
            returning downloadable_file_id
        """, [file_id, mime_type, valid_until, hash])

        for row in cur:
            return f"{URL}/file/{row[0]}/{hash}"

def make_csv(file_id, valid_until=None):
    return make(file_id, 'text/csv', valid_until)
