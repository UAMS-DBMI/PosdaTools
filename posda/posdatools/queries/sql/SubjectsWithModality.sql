-- Name: SubjectsWithModality
-- Schema: posda_files
-- Columns: ['project_name', 'site_name', 'patient_id', 'num_files']
-- Args: ['modality']
-- Tags: ['FindSubjects']
-- Description: Find All Subjects with given modality in Collection, Site
-- 

select distinct
project_name,
site_name,  
patient_id, count(*) as num_files
from
  ctp_file natural join file_patient natural join file_series
where
  modality = ?
group by project_name, site_name, patient_id
order by patient_id

