-- Name: UpdateCountsDb
-- Schema: posda_counts
-- Columns: None
-- Args: ['project_name', 'site_name', 'num_subjects', 'num_studies', 'num_series', 'num_files']
-- Tags: ['intake', 'posda_counts']
-- Description: 

insert into totals_by_collection_site(
  count_report_id,
  collection_name, site_name,
  num_subjects, num_studies, num_series, num_sops
) values (
  currval('count_report_count_report_id_seq'),
  ?, ?,
  ?, ?, ?, ?
)
returning count_report_id
