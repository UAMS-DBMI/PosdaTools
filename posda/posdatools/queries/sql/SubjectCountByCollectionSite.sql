-- Name: SubjectCountByCollectionSite
-- Schema: posda_files
-- Columns: ['patient_id', 'count']
-- Args: ['collection', 'site']
-- Tags: ['counts']
-- Description: Counts query by Collection, Site
-- 

select
  distinct
    patient_id, count(distinct file_id)
from
  ctp_file natural join file_patient
where
  project_name = ? and site_name = ?
group by
  patient_id 
order by
  patient_id
