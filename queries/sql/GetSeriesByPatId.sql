-- Name: GetSeriesByPatId
-- Schema: posda_files
-- Columns: ['series_instance_uid', 'num_files']
-- Args: ['patient_id']
-- Tags: ['meta', 'test', 'hello', 'query_tabs', 'bills_test']
-- Description: See if ctp_file_row exists

select
  distinct series_instance_uid, count(distinct file_id) as num_files
from
  file_series natural join file_patient natural join ctp_file
where
  patient_id = ? and
  visibility is null
group by series_instance_uid