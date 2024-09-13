-- Name: RunNiftiPHIReport
-- Schema: posda_phi_simple
-- Columns: ['tag_name', 'value', 'file_id']
-- Args: ['nifti_phi_scan_instance_id']
-- Tags: ['phi_reports']
-- Description: Return PHI Report data
--

select
  tag_name,
  value,
  file_id
from
  nifti_phi_scan_instance
  natural join nifti_tag_value_occurrence
  natural join nifti_tag_seen
  natural join nifti_value_seen
  where nifti_phi_scan_instance_id = ?
  order by file_id, tag_name;
