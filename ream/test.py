#!/usr/bin/env python3

import redis
import json



db = redis.StrictRedis(host="redis", db=0)

print("adding a test entry to the 'submission_required' list...")

db.lpush('submission_required', json.dumps([
    1, # subprocess_invocation_id
    1, # file_id
    'QTest1',     # collection
    'Quasar98',     # site
    99,         # site ID
    1,          # batch
    "/nas/public/posda/storage/7a/5d/2f/7a5d2fbcd6d9f0865e7b3e66009a3ef9"
]))


# ldct_lahey_test_file = "/nas/public/test-storage/private_dispositions/2ffc969c-8eb3-11e9-827e-21ed064a52bb/LDCT-01-001/1.3.6.1.4.1.14519.5.2.1.3983.1600.175911262200889415475108687483/1.3.6.1.4.1.14519.5.2.1.3983.1600.128692777087971278951654848485/CT_1.3.6.1.4.1.14519.5.2.1.3983.1600.102712461580935109084712780585.dcm"
# db.lpush('submission_required', json.dumps([
#     'QTest1',     # collection
#     'Quasar99',     # site
#     99,         # site ID
#     0,          # batch
#     ldct_lahey_test_file
# ]))
