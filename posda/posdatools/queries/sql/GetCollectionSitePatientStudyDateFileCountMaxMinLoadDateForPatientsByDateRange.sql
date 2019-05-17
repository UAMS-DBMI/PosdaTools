-- Name: GetCollectionSitePatientStudyDateFileCountMaxMinLoadDateForPatientsByDateRange
-- Schema: posda_files
-- Columns: ['collection', 'site', 'patient_id', 'qualified', 'study_date', 'num_files', 'num_sops', 'earliest_day', 'latest_day']
-- Args: ['collection_like', 'from', 'to', 'to_again']
-- Tags: ['clin_qual']
-- Description: Create An Activity Timepoint
-- 
-- 

select * from (select 
  collection, site, patient_id, qualified, study_date,
  count(distinct file_id) as num_files, count (distinct sop_instance_uid) as num_sops,
  min(date_trunc('day',import_time)) as earliest_day, max(date_trunc('day', import_time)) as latest_day
from
  clinical_trial_qualified_patient_id join file_patient using (patient_id) 
  join file_study using(file_id) join file_import using(file_id)
  join file_sop_common using(file_id)
  join import_event using(import_event_id)
where patient_id in (
  select 
    distinct patient_id
  from
    clinical_trial_qualified_patient_id join file_patient using (patient_id) 
    join file_import using(file_id)
    join import_event using(import_event_id)
  where 
    collection like ? and import_time > ? and import_time < ? and import_type not like 'script%'
)
group by collection, site, patient_id, qualified, study_date) as foo
where earliest_day < ?