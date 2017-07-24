-- Name: SubjectsWithModalityByCollectionSite
-- Schema: posda_files
-- Columns: ['patient_id', 'num_files']
-- Args: ['modality', 'project_name', 'site_name']
-- Tags: ['FindSubjects']
-- Description: Find All Subjects with given modality in Collection, Site
-- 

select
  distinct patient_id, count(*) as num_files
from
  ctp_file natural join file_patient natural join file_series
where
  modality = ? and project_name = ? and site_name = ?
group by patient_id
order by patient_id
