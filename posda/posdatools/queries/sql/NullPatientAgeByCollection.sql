-- Name: NullPatientAgeByCollection
-- Schema: posda_files
-- Columns: ['file_id', 'path']
-- Args: ['collection']
-- Tags: ['meta', 'test', 'hello', 'query_tabs', 'bills_test']
-- Description: Add a filter to a tab

select
  file_id, root_path || '/' || rel_path as path
from
  file_storage_root natural join file_location natural join ctp_file natural join file_patient
where
  project_name = ? and patient_age is null