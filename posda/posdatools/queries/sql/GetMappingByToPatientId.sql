-- Name: GetMappingByToPatientId
-- Schema: posda_files
-- Columns: ['from_patient_id', 'to_patient_id']
-- Args: ['to_patient_id']
-- Tags: ['patient_mapping']
-- Description: Get Mapping By to_patient_id
--

select from_patient_id, to_patient_id
from patient_mapping
where to_patient_id = ?