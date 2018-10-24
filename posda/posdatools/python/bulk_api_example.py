import getpass

import posda.uuid
import posda.bulk

session = posda.uuid.get_guid()

root = '/cache/posda/Data/HierarchicalExtractions/data'
collection = 'Pancreas-CT'
site = 'NIH-CC-LDRR'
user = getpass.getuser()
port = 1337

bulk = posda.bulk.BulkOperations(root, collection, site,
                                 session, user, port)

def sub(coll, site, subj, f_list, info):
    num_edits = info.get('CurrentRev', None)

    if num_edits is None:
        return None
    else:
        return "{}//{}//{} has {} revisions".format(
                coll, site, subj, num_edits)

for line in bulk.map_unlocked(sub, "description"):
    print(line)

