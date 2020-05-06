-- Name: SeriesListByStudyInstanceUidWithAdmittingDiag
-- Schema: posda_files
-- Columns: ['collection', 'site', 'patient_id', 'study_instance_uid', 'study_date', 'study_description', 'series_instance_uid', 'series_date', 'series_description', 'admitting_diag', 'modality', 'dicom_file_type', 'num_files']
-- Args: ['study_instance_uid']
-- Tags: ['find_series', 'for_tracy']
-- Description: Get List of Series by Study Instance UID
--

select
  distinct project_name as collection,
  site_name as site,
  patient_id,
  study_instance_uid,
  study_date,
  study_description,
  series_instance_uid,
  series_date,
  series_description,
  admitting_diag,
  modality, 
  dicom_file_type, 
  count(distinct file_id) as num_files
from 
  file_patient natural join
  file_series natural join
  file_study natural join
  dicom_file natural join
  ctp_file
where 
  study_instance_uid = ?
  and visibility is null
group by 
  collection,
  site,
  patient_id,
  study_instance_uid,
  study_date,
  study_description,
  series_instance_uid,
  series_date,
  series_description,
  admitting_diag,
  modality,
  dicom_file_type;