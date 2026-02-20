-- Name: GetLatestPMUploadID
-- Schema: posda_files
-- Columns: ['active', 'patient_mapping_id', 'upload_id','from_patient_id', 'to_patient_id', 'to_patient_name', 'collection_name', 'site_name']
-- Args: ['to_patient_id']
-- Tags: ['patient_mapping']
-- Description: Find the last upload id from patient mapping

select
  max(upload_id)
from
  patient_mapping
