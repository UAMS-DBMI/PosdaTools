-- Name: PhiNonDicomScanStatus
-- Schema: posda_phi_simple
-- Columns: ['id', 'description', 'start_time', 'num_files_to_scan', 'num_files_scanned', 'end_time']
-- Args: []
-- Tags: ['tag_usage', 'non_dicom_phi_status']
-- Description: Status of PHI scans
-- 

select 
   phi_non_dicom_scan_instance_id as id,
   pndsi_description as description,
   pndsi_start_time as start_time,
   pndsi_num_files as num_files_to_scan,
   pndsi_num_files_scanned as num_files_scanned,
   pndsi_end_time as end_time
from
  phi_non_dicom_scan_instance
order by start_time
