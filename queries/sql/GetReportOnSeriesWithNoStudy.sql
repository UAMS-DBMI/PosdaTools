-- Name: GetReportOnSeriesWithNoStudy
-- Schema: posda_files
-- Columns: ['collection', 'site', 'patient_id', 'series_instance_uid', 'visibility', 'num_files']
-- Args: []
-- Tags: ['bills_test', 'posda_db_populate']
-- Description: Add a filter to a tab

select 
  distinct project_name as collection,
  site_name as site, patient_id, series_instance_uid, visibility, count(*) as num_files
from ctp_file natural join file natural join file_patient natural join file_series  where digest in (
select digest from file where file_id in (
select file_id from file_series where not exists(select file_id from file_study where file_series.file_id = file_study.file_id))) group by project_name, site_name, patient_id, series_instance_uid,visibility;