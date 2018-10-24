-- Name: NonDicomFileInPosdaByScanPathValue
-- Schema: posda_phi_simple
-- Columns: ['file_id', 'type', 'path', 'q_value', 'num_files']
-- Args: ['scan_id', 'file_type', 'non_dicom_path', 'value']
-- Tags: ['adding_ctp', 'for_scripting', 'non_dicom_phi']
-- Description: Simple Phi Report with Meta Quotes

select 
  distinct posda_file_id as file_id, non_dicom_file_type as type, '<' ||non_dicom_path || '>' as path,
  '<' || value || '>' as q_value
from
  non_dicom_path_value_occurrance natural join
  non_dicom_path_seen natural join
  value_seen natural join
  non_dicom_file_scan natural join
  phi_non_dicom_scan_instance
where 
  phi_non_dicom_scan_instance_id = ? and 
  file_type = ? and 
  non_dicom_path = ? and 
  value = ?
order by type, path, q_value