-- Name: get_file_to_fix_ctp
-- Schema: posda_files
-- Columns: ['file_id', 'file_path']
-- Args: ['from', 'limit']
-- Tags: ['meta', 'test', 'hello', 'query_tabs', 'bills_test']
-- Description: Add a filter to a tab

select
  file_id, root_path || '/' || file_location.rel_path as file_path 
from
  file_patient  natural join
  file_import natural join
  import_event join file_location using(file_id) join file_storage_root using (file_storage_root_id)
where 
  import_time > ? and not exists
  (select file_id from ctp_file where ctp_file.file_id = file_patient.file_id)
limit ?