-- Name: CreateNonDicomFileScanInstance
-- Schema: posda_phi_simple
-- Columns: []
-- Args: ['phi_non_dicom_scan_instance_id', 'file_type', 'posda_file_id']
-- Tags: ['NotInteractive', 'non_dicom_phi']
-- Description: Create a dciodvfy_scan_instance row

insert into non_dicom_file_scan(
  phi_non_dicom_scan_instance_id,
  file_type,
  file_in_posda,
  posda_file_id
) values (
  ?, ?, true, ?
)