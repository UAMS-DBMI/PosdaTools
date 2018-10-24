-- Name: SubjectsWithModalityByCollectionSiteIntake
-- Schema: intake
-- Columns: ['patient_id', 'modality', 'num_files']
-- Args: ['modality', 'project_name', 'site_name']
-- Tags: ['FindSubjects', 'SymLink', 'intake']
-- Description: Find All Subjects with given modality in Collection, Site
-- 

select
  distinct i.patient_id, modality, count(*) as num_files
from
  general_image i, trial_data_provenance tdp, general_series s
where
  s.general_series_pk_id = i.general_series_pk_id and 
  i.trial_dp_pk_id = tdp.trial_dp_pk_id and 
  modality = ? and
  tdp.project = ? and 
  tdp.dp_site_name = ?
group by patient_id, modality
