-- Name: GetSpreadsheetInfoForRadcompDisp
-- Schema: posda_files
-- Columns: ['patient_id', 'study_uid', 'series_uid', 'num_files', 'shift']
-- Args: ['collection']
-- Tags: ['adding_ctp', 'for_scripting', 'non_dicom_phi', 'non_dicom_edit']
-- Description: Simple Phi Report with Meta Quotes

select
  distinct patient_id,
  study_instance_uid as study_uid, 
  series_instance_uid as series_uid,
  baseline_date - diagnosis_date + interval '1 day' as shift,
  count(distinct file_id) as num_files
from
  file_patient natural join file_series natural join file_study natural join ctp_file,
  patient_mapping
where
  patient_id = to_patient_id and
  ctp_file.project_name = ?
group by
  patient_id, study_uid, series_uid, shift