#!/usr/bin/env python3.6

from posda.config import Database
from posda.queries import Query

db = Database("nonexistant")

# with Query("DistinctSeriesByCollectionSite").run(
#         'Radiomics', 
#         'MAASTRO') as r:
#     for row in r:
#         print(row)
#         break

# TODO: add a way to toggle off the NamedTupleCursor, for more speed?
# with Query("DistinctSeriesByCollectionSite").run(
#         site_name='MAASTRO',
#         project_name='Radiomics') as r:
#     for row in r:
#         print(row)
#         print(row.series_instance_uid)
#         break

for row in Query("DistinctSeriesByCollectionSite").run(
        site_name='MAASTRO',
        project_name='Radiomics'):
    print(row)
    break


# hide some files
hide_file = Query("HideFile")

for row in Query("FilesInCollectionSiteForSend").run(
        collection='Radiomics',
        site='MAASTRO'):

    count = hide_file.execute(row.file_id)
    print(f"{row.file_id}: {count} row(s) updated")


# unhide all files
with Database("posda_files").cursor() as cur:
    cur.execute("update ctp_file "
                "set visibility = null "
                "where visibility = 'hidden'")

