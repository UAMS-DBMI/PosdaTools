-- Name: CurrentPatientWithoutStatii
-- Schema: posda_files
-- Columns: ['collection', 'site', 'patient_id', 'patient_import_status']
-- Args: []
-- Tags: ['counts', 'count_queries', 'patient_status']
-- Description: Get the current status of all patients

select 
  distinct project_name as collection,
  site_name as site,
  patient_id,
  '<undef>' as patient_import_status
from 
  ctp_file natural join file_patient p
where 
  visibility is null and
  not exists (select * from patient_import_status s where p.patient_id = s.patient_id)