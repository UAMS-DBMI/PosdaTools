-- Name: AllVisibleSubjectsByCollection
-- Schema: posda_files
-- Columns: ['patient_id', 'status', 'project_name', 'site_name', 'num_files']
-- Args: ['collection']
-- Tags: ['FindSubjects', 'PatientStatus']
-- Description: Find All Subjects which have at least one visible file
-- 

select
  distinct patient_id,
  patient_import_status as status,
  project_name, site_name,
  count(*) as num_files
from
  file_patient natural join ctp_file natural join patient_import_status
where
  patient_id in (
    select patient_id 
    from
      file_patient natural join ctp_file 
    where
      project_name = ? and
      visibility is null
  ) and
  visibility is null
group by patient_id, status, project_name, site_name
order by project_name, status, site_name, patient_id;
