-- Name: CreateCtpFileRow
-- Schema: posda_files
-- Columns: []
-- Args: ['file_id', 'project_name', 'site_name', 'site_id', 'file_visibility', 'batch', 'study_year']
-- Tags: ['meta', 'test', 'hello', 'query_tabs', 'bills_test']
-- Description: create ctp_file row

insert into ctp_file(
  file_id, project_name, site_name, site_id, file_visibility, batch, study_year
) values (
  ?, ?, ?, ?, ?, ?, ?
)