-- Name: GetQualifiedCTQPByLikeCollectionSiteWithFIleCount
-- Schema: posda_files
-- Columns: ['collection', 'site', 'patient_id', 'qualified', 'num_files']
-- Args: ['collection_like', 'site']
-- Tags: ['clin_qual']
-- Description: Create An Activity Timepoint
-- 
-- 

select 
  collection, site, patient_id, qualified, count(distinct file_id) as num_files
from
  clinical_trial_qualified_patient_id join file_patient using (patient_id)
where collection like ? and site = ? and qualified
group by collection, site, patient_id, qualified