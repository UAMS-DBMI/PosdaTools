-- Name: FilesWithNoCtpByPatientId
-- Schema: posda_files
-- Columns: ['file_id']
-- Args: ['patient_id']
-- Tags: ['adding_ctp']
-- Description: Get Series in A Collection
-- 

select
  distinct file_id
from
  file_patient p
where
  not exists(
  select file_id from ctp_file c
  where c.file_id = p.file_id
)
and patient_id = ?
