-- Name: NonDicomPhiReportCsvMetaQuotesLimit
-- Schema: posda_phi_simple
-- Columns: ['type', 'path', 'q_value', 'num_files']
-- Args: ['scan_id', 'limit']
-- Tags: ['adding_ctp', 'for_scripting', 'non_dicom_phi', 'non_dicom_edit']
-- Description: Simple Phi Report with Meta Quotes

select 
  distinct non_dicom_file_type as type, '<' ||non_dicom_path || '>' as path,
  '<' || value || '>' as q_value, count(distinct posda_file_id) as num_files
from 
  non_dicom_path_value_occurrance natural join
  non_dicom_path_seen natural join
  value_seen natural join
  non_dicom_file_scan natural join
  phi_non_dicom_scan_instance
where 
  phi_non_dicom_scan_instance_id = ? and file_type = 'csv'
group by type, path, q_value
order by type, path, q_value
limit ?