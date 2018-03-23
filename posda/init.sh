#!/usr/bin/env bash

# check if this is a first-run; if so, setup Posda
if [ ! -e "/home/posda/cache/POSDA_VERSION" ]; then
    echo "Looks like this is the first run.. setting up Posda.."
	cd /home/posda/posdatools
	./setup.sh

	psql posda_files <<END
		insert into file_storage_root
		values 
		(1, '/home/posda/cache/submission_root', true, 'default import path'),
		(2, '/home/posda/cache/k-storage', true, 'k-base generated'),
		(3, '/home/posda/cache/created', true, 'created');
END
	# Wasn't wanting to stick from the Dockerfile, do it here instead
	mkdir -p /home/posda/cache/submission_root
	mkdir -p /home/posda/cache/k-storage
	mkdir -p /home/posda/cache/created
	echo 2 > /home/posda/cache/POSDA_VERSION
fi

supervisord -n
