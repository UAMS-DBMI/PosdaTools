#!/bin/bash
set -e

setup() {
	./setup.sh

	psql posda_files <<-END
		insert into file_storage_root
		values
		(1, '/home/posda/cache/submission_root', true, 'default import path'),
		(2, '/home/posda/cache/k-storage', true, 'k-base generated'),
		(3, '/home/posda/cache/created', true, 'created'),
		(4, '/home/posda/cache/submission_root', true, 'imports from browser');
		select setval('file_storage_root_file_storage_root_id_seq', 5);
	END

	mkdir -p /home/posda/cache/submission_root
	mkdir -p /home/posda/cache/k-storage
	mkdir -p /home/posda/cache/created
	echo 2 > /home/posda/cache/POSDA_VERSION
}

# load the env files that Docker would normally load
for f in temp-config/*.env; do
	export $(grep -v ^# $f)
done

# assuming this is run from the install dir!
cd ../posda/posdatools
setup
