SQL=../posda/posdatools/Posda/sql
# SRCFILES := $(shell find ${SQL} -type f)
SCHEMA_FILES := \
		${SQL}/dicom_dd.sql \
		${SQL}/dicom_roots.sql \
		${SQL}/posda_appstats.sql \
		${SQL}/posda_auth.sql \
		${SQL}/posda_auth_setup.sql \
		${SQL}/posda_backlog.sql \
		${SQL}/posda_counts.sql \
		${SQL}/posda_files.sql \
		${SQL}/posda_dbif_config.sql \
		${SQL}/posda_nicknames.sql \
		${SQL}/posda_phi.sql \
		${SQL}/posda_phi_simple.sql \
		${SQL}/posda_queries.sql \
		${SQL}/posda_simple_phi.sql \
		${SQL}/private_tag_kb.sql \
		${SQL}/public_tag_disposition.sql
DATA_FILES := \
		${SQL}/dicom_dd_data.sql \
		${SQL}/private_tag_kb_data.sql \
		${SQL}/posda_phi_simple_data.sql \
		${SQL}/posda_files_data.sql \
		${SQL}/posda_dbif_config_data.sql

# ${SQL}/posda_backlog_data.sql

all: all.sql

clean:
	rm -f *.sql

all.sql: schema.sql data.sql queries.sql
	cat $+ > all.sql

schema.sql: $(SCHEMA_FILES)
	cat $+ > schema.sql

data.sql: $(DATA_FILES)
	cat $+ > data.sql

queries.sql:
	echo "\\connect posda_files" > queries.sql
	echo "set search_path to public, dbif_config;" >> queries.sql
	echo "truncate table queries;" >> queries.sql
	../posda/posdatools/queries/compile.py ../posda/posdatools/queries/sql >> queries.sql
