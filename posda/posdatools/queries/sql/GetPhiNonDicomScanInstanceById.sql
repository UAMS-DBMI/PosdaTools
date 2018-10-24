-- Name: GetPhiNonDicomScanInstanceById
-- Schema: posda_phi_simple
-- Columns: ['phi_non_dicom_scan_instance_id', 'description', 'start_time', 'num_files', 'num_files_scanned', 'end_time']
-- Args: ['phi_non_dicom_scan_instance_id']
-- Tags: ['NotInteractive', 'non_dicom_phi']
-- Description: Create a dciodvfy_scan_instance row

select
  phi_non_dicom_scan_instance_id,
  pndsi_description as description,
  pndsi_start_time as start_time,
  pndsi_num_files as num_files,
  pndsi_num_files_scanned as num_files_scanned,
  pndsi_end_time as end_time
from
  phi_non_dicom_scan_instance
where
  phi_non_dicom_scan_instance_id = ?