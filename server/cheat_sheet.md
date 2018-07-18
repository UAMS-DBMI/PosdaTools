export PGUSER=postgres
export PGPASSWORD=example
export PGHOST=localhost
export PGPORT=5433


http://tcia-dev-1.ad.uams.edu/k/work?processing_status=ReadyToReview

http://tcia-dev-1.ad.uams.edu/k/work?review_status=Good

http://tcia-dev-1.ad.uams.edu/k/work?visual_review_instance_id=1

http://tcia-dev-1.ad.uams.edu/k/work?visual_review_instance_id=1&review_status=Good

http://tcia-dev-1.ad.uams.edu/k/work?dicom_file_type=CT+Image+Storage&processing_status=ReadyToReview&visual_review_instance_id=1


To Build/Serve Kaleidoscope pytho server
1. 'make' in the posda2/kaleidoscope dir
2. `./manage down` from posda2
3. `./manage up -d` from posda2

---

To Build/Serve Kaleidoscope angular UI:
1. `make` in the angular dir  (posda2/nginx/kaleidoscope)
2. `make` in the nginx dir (to build the image
3. `./manage down` from posda2
4. `./manage up -d` from posda2

---

Shortcut to build/serve Kaleidoscope angular UI:
1. `make` in the angular dir
2. `make` in the nginx dir (to build the image)
3. `./restart_nginx.sh` from posda2 dir

---

To run queries from command line
* `./manage psql posda_files` from posda2 dir 
