#!/bin/bash

echo "This will only work if the database is in docker with default settings"

TEMPF=/tmp/auth.dump

# Dump the entire posda_auth database, and rename public to auth
docker compose exec -T db pg_dump -U postgres -n public --no-tablespaces posda_auth | sed 's/public/auth/g' > $TEMPF

# Import the result into the posda_files database (this will put it under the
# auth schema)
docker compose exec -T db psql -U postgres posda_files < $TEMPF

rm $TEMPF
