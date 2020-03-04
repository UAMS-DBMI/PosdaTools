-- Name: FilesVisibilityByPatientSeries
-- Schema: posda_files
-- Columns: ['file_id', 'visibility']
-- Args: ['patient_id', 'series_instance_uid']
-- Tags: ['duplicates', 'dup_sops', 'hide_dup_sops', 'sops_different_series']
-- Description: Return a count of duplicate SOP Instance UIDs
--

select
  distinct file_id, visibility
from
  file_patient natural join file_series natural left join ctp_file
where
  patient_id = ? and
  series_instance_uid = ?
