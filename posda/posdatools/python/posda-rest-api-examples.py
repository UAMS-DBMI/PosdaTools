#!/usr/bin/env python3

import datetime
from posda.main import downloadablefile  # TODO: maybe this should be in posda.api ?

# Simplest form, just supply a file_id (named argument not required)
url = downloadablefile.make_csv(file_id=1)
print(url)


# Or you can speciy an expiration date
url = downloadablefile.make_csv(file_id=2, valid_until=datetime.datetime(2018, 1, 1))
print(url)


# If it's not a CSV, you can also specify a mime-type
url = downloadablefile.make(3, 'application/dicom', datetime.datetime(2018, 1, 1))
print(url)
