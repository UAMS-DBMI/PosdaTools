-- Name: PatientIdByNonDicomFileId
-- Schema: posda_files
-- Columns: ['subject']
-- Args: ['file_id']
-- Tags: ['adding_ctp', 'for_scripting', 'non_dicom_phi', 'non_dicom_edit']
-- Description: Simple Phi Report with Meta Quotes

select subject from non_dicom_file where file_id = ?