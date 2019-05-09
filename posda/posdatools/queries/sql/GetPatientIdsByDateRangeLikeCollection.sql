-- Name: GetPatientIdsByDateRangeLikeCollection
-- Schema: posda_files
-- Columns: ['patient_id', 'import_type']
-- Args: ['collection_like', 'from', 'to']
-- Tags: ['clin_qual']
-- Description: Create An Activity Timepoint
-- 
-- 

select 
  distinct patient_id, import_type
from
  clinical_trial_qualified_patient_id join file_patient using (patient_id) 
  join file_import using(file_id)
  join import_event using(import_event_id)
where 
  collection like ? and import_time > ? and import_time < ? and import_type not like 'script%'