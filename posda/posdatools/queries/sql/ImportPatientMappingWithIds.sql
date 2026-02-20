-- Name: FindPMbyPatient
-- Schema: posda_files
-- Columns: ['active', 'patient_mapping_id', 'upload_id','from_patient_id', 'to_patient_id', 'to_patient_name', 'collection_name', 'site_name']
-- Args: ['to_patient_id']
-- Tags: ['patient_mapping']
-- Description: Find all Patient Mappings for a patient

select
  active, patient_mapping_id, upload_id, to_patient_id, to_patient_name, collection_name, site_name
from
  patient_mapping
where
  to_patient_id = ?
