-- Name: GetSopModalityPathDigest
-- Schema: posda_files
-- Columns: ['sop_instance_uid', 'modality', 'path', 'digest']
-- Args: ['file_id']
-- Tags: ['bills_test', 'comparing_posda_to_public']
-- Description: get sop_instance, modality, and path to file by file_id

select 
  sop_instance_uid, modality,
  root_path || '/' || rel_path as path,
  digest
from
  file natural join file_series natural join file_sop_common natural join file_location natural join file_storage_root
where
  file_id = ?