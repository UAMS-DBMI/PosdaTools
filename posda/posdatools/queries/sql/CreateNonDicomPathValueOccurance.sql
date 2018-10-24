-- Name: CreateNonDicomPathValueOccurance
-- Schema: posda_phi_simple
-- Columns: []
-- Args: ['non_dicom_path_seen_id', 'value_seen_id', 'non_dicom_file_scan_id']
-- Tags: ['NotInteractive', 'non_dicom_phi']
-- Description: Create a dciodvfy_scan_instance row

insert into non_dicom_path_value_occurrance(
  non_dicom_path_seen_id,
  value_seen_id,
  non_dicom_file_scan_id
) values (
  ?, ?, ?
)