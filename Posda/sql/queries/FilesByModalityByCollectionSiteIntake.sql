-- Name: FilesByModalityByCollectionSiteIntake
-- Schema: intake
-- Columns: ['patient_id', 'modality', 'series_instance_uid', 'sop_instance_uid', 'dicom_file_uri']
-- Args: ['modality', 'project_name', 'site_name']
-- Tags: ['FindSubjects', 'intake', 'FindFiles']
-- Description: Find All Files with given modality in Collection, Site on Intake
-- 

select
  distinct i.patient_id, modality, s.series_instance_uid, sop_instance_uid, dicom_file_uri
from
  general_image i, trial_data_provenance tdp, general_series s
where
  s.general_series_pk_id = i.general_series_pk_id and 
  i.trial_dp_pk_id = tdp.trial_dp_pk_id and 
  modality = ? and
  tdp.project = ? and 
  tdp.dp_site_name = ?