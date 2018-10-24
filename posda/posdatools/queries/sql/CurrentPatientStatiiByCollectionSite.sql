-- Name: CurrentPatientStatiiByCollectionSite
-- Schema: posda_files
-- Columns: ['collection', 'site', 'patient_id', 'patient_import_status']
-- Args: ['collection', 'site']
-- Tags: ['counts', 'patient_status', 'for_bill_counts']
-- Description: Get the current status of all patients

select 
  distinct project_name as collection,
  site_name as site,
  patient_id,
  patient_import_status
from 
  ctp_file natural join file_patient natural left join patient_import_status
where
  visibility is null and project_name = ? and site_name = ?