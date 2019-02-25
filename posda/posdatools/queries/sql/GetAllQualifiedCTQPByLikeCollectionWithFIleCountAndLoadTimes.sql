-- Name: GetAllQualifiedCTQPByLikeCollectionWithFIleCountAndLoadTimes
-- Schema: posda_files
-- Columns: ['collection', 'site', 'patient_id', 'qualified', 'num_files', 'earliest_day', 'latest_day']
-- Args: ['collection_like']
-- Tags: ['clin_qual']
-- Description: Create An Activity Timepoint
-- 
-- 

select 
  collection, site, patient_id, qualified, count(distinct file_id) as num_files,
  min(date_trunc('day',import_time)) as earliest_day, max(date_trunc('day', import_time)) as latest_day
from
  clinical_trial_qualified_patient_id join file_patient using (patient_id) join file_import using(file_id)
  join import_event using(import_event_id)
where collection like ?
group by collection, site, patient_id, qualified