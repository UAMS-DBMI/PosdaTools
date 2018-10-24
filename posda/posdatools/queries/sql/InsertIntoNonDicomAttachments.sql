-- Name: InsertIntoNonDicomAttachments
-- Schema: posda_files
-- Columns: []
-- Args: ['non_dicom_file_id', 'dicom_file_id', 'patient_id', 'manifest_uid', 'study_instance_uid', 'series_instance_uid', 'manifest_date', 'version']
-- Tags: ['radcomp']
-- Description: Add a filter to a tab

insert into non_dicom_attachments(
  non_dicom_file_id,
  dicom_file_id,
  patient_id,
  manifest_uid,
  study_instance_uid,
  series_instance_uid,
  manifest_date,
  version
)values(
  ?, ?, ?, ?, ?, ?, ?, ?
)
