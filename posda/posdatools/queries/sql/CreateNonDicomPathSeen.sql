-- Name: CreateNonDicomPathSeen
-- Schema: posda_phi_simple
-- Columns: []
-- Args: ['non_dicom_file_type', 'non_dicom_path']
-- Tags: ['NotInteractive', 'non_dicom_phi']
-- Description: Create a dciodvfy_scan_instance row

insert into non_dicom_path_seen(
  non_dicom_file_type,
  non_dicom_path
) values (
  ?, ?
)