#!/bin/bash

. ../load-env.sh

postgresql-setup initdb

systemctl enable rh-postgresql13-postgresql
systemctl start rh-postgresql13-postgresql

# add root as a user (may need to add other users)
sudo -u postgres scl enable rh-postgresql13 -- createuser -s root
