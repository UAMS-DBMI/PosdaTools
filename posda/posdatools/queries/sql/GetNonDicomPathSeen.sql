-- Name: GetNonDicomPathSeen
-- Schema: posda_phi_simple
-- Columns: []
-- Args: ['file_type', 'path']
-- Tags: ['NotInteractive', 'non_dicom_phi']
-- Description: Create a dciodvfy_scan_instance row

select
  non_dicom_path_seen_id 
from
  non_dicom_path_seen
where
  non_dicom_file_type = ? and
  non_dicom_path = ?