-- Name: CreatePhiNonDicomScanInstance
-- Schema: posda_phi_simple
-- Columns: []
-- Args: ['description_of_scan', 'num_files']
-- Tags: ['NotInteractive', 'non_dicom_phi']
-- Description: Create a dciodvfy_scan_instance row

insert into phi_non_dicom_scan_instance(
  pndsi_description,
  pndsi_start_time,
  pndsi_num_files,
  pndsi_num_files_scanned
) values (
  ?, now(), ?, 0
)