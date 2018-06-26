#!/usr/bin/env bash
echo "Executing psql inside the database docker container..."

docker exec -it posda2_db_1 psql -U postgres $@
