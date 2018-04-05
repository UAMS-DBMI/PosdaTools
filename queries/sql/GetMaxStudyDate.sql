-- Name: GetMaxStudyDate
-- Schema: posda_files
-- Columns: ['study_date']
-- Args: ['patient_id']
-- Tags: ['adding_ctp', 'for_scripting', 'non_dicom_phi', 'non_dicom_edit']
-- Description: Simple Phi Report with Meta Quotes

select
   max(study_date) as study_date
from 
  file_patient natural join ctp_file natural join file_study
where
  patient_id = ?