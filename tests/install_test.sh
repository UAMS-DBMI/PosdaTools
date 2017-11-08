#!/usr/bin/env bash

# Execute some high-level tests to see if the install worked
failed=0

# units
systemctl is-active posda                 || failed=1
systemctl is-active posda-backlog         || failed=1
systemctl is-active posda-file-process    || failed=1

# databases
psql -l | grep -q dicom_dd                || failed=1
psql -l | grep -q dicom_roots             || failed=1
psql -l | grep -q posda_appstats          || failed=1
psql -l | grep -q posda_auth              || failed=1
psql -l | grep -q posda_backlog           || failed=1
psql -l | grep -q posda_counts            || failed=1
psql -l | grep -q posda_files             || failed=1
psql -l | grep -q posda_nicknames         || failed=1
psql -l | grep -q posda_phi               || failed=1
psql -l | grep -q posda_phi_simple        || failed=1
psql -l | grep -q posda_queries           || failed=1
psql -l | grep -q private_tag_kb          || failed=1
psql -l | grep -q public_tag_disposition  || failed=1

# a test of a failing test
psql -l | grep -q public_tag_disposition2  || failed=1


exit $failed
