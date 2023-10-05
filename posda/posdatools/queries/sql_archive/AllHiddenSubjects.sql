-- Name: AllHiddenSubjects
-- Schema: posda_files
-- Columns: ['patient_id', 'project_name', 'site_name', 'num_files']
-- Args: []
-- Tags: ['FindSubjects']
-- Description: Find All Subjects which have only hidden files
-- 

select
  distinct patient_id, project_name, site_name,
  count(*) as num_files
from
  file_patient natural join ctp_file
where patient_id in (
    select distinct patient_id 
    from file_patient
  except 
    select patient_id 
    from
      file_patient natural join ctp_file 
    where
      visibility is null
) group by patient_id, project_name, site_name
order by project_name, site_name, patient_id;
