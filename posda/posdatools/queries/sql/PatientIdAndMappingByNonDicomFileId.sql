-- Name: PatientIdAndMappingByNonDicomFileId
-- Schema: posda_files
-- Columns: ['from_patient_id', 'to_patient_id', 'to_patient_name', 'collection_name', 'site_name', 'batch_number', 'diagnosis_date', 'baseline_date', 'date_shift', 'uid_root', 'computed_shift']
-- Args: ['file_id']
-- Tags: ['adding_ctp', 'for_scripting', 'non_dicom_phi', 'non_dicom_edit']
-- Description: Simple Phi Report with Meta Quotes

select
  from_patient_id, to_patient_id, to_patient_name, collection_name, site_name,
  batch_number, diagnosis_date, baseline_date, date_shift, uid_root,
  baseline_date - diagnosis_date + interval '1 day' as computed_shift
from 
  patient_mapping pm, non_dicom_file ndf
where
  pm.from_patient_id = ndf.subject and
  file_id = ?