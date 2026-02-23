-- Name: GetLatestPMUploadID
-- Schema: posda_files
-- Columns: ['latest']
-- Args: []
-- Tags: ['patient_mapping']
-- Description: Find the last upload id from patient mapping

select
  max(upload_id) as latest
from
  patient_mapping
