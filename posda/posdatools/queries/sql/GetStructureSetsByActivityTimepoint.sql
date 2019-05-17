-- Name: GetStructureSetsByActivityTimepoint
-- Schema: posda_files
-- Columns: ['file_id', 'path', 'patient_id']
-- Args: ['activity_timepoint_id']
-- Tags: ['Structure Sets', 'sops', 'LinkageChecks']
-- Description: Get List of file_ids for structure sets in an activity timepoint
-- 

select 
  file_id, root_path || '/' || rel_path as path, patient_id
from
  file_structure_set natural join activity_timepoint_file natural join file_location natural join file_storage_root
  natural join file_patient
where
  activity_timepoint_id = ?