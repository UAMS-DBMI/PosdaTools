-- Name: GetAllQualifiedCTQPByLikeCollectionSiteWithFIleCountAndLoadTimes
-- Schema: posda_files
-- Columns: ['collection', 'site', 'patient_id', 'qualified', 'num_files', 'earliest', 'latest']
-- Args: ['collection_like', 'site']
-- Tags: ['clin_qual']
-- Description: Create An Activity Timepoint
-- 
-- 

select 
  collection, site, patient_id, qualified, count(distinct file_id) as num_files,
  min(import_time) as earliest, max(import_time) as latest
from
  clinical_trial_qualified_patient_id join file_patient using (patient_id) join file_import using(file_id)
  join import_event using(import_event_id)
where collection like ? and site = ?
group by collection, site, patient_id, qualified