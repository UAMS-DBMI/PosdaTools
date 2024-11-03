#!/bin/bash
set -e

if [ -z "$CONFIG_DIR" ]; then
        echo "Missing install configuration, load CONFIG first!";
        exit 1;
fi

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

cd $INSTALL_DIR
# load the env files that Docker would normally load
for f in configs/*.env; do
	export $(grep -v ^# $f)
done

cd $POSDA_DIR
setup
