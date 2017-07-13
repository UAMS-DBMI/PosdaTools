-- Name: AllSubjectsWithNoStatus
-- Schema: posda_files
-- Columns: ['patient_id', 'project_name', 'site_name', 'num_files']
-- Args: []
-- Tags: ['FindSubjects', 'PatientStatus']
-- Description: All Subjects With No Patient Import Status
-- 

select
  distinct patient_id, project_name, site_name,
  count(*) as num_files
from
  file_patient natural join ctp_file
where
  patient_id in (
    select 
      distinct patient_id
    from
      file_patient p
    where
       not exists (
         select
           patient_id
         from
            patient_import_status s
         where
            p.patient_id = s.patient_id
       )
  ) 
  and visibility is null
group by patient_id, project_name, site_name
order by project_name, site_name, patient_id
