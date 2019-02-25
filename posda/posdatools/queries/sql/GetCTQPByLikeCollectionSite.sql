-- Name: GetCTQPByLikeCollectionSite
-- Schema: posda_files
-- Columns: ['collection', 'site', 'patient_id', 'qualified']
-- Args: ['collection_like', 'site']
-- Tags: ['clin_qual']
-- Description: Create An Activity Timepoint
-- 
-- 

select 
  collection, site, patient_id, qualified
from
  clinical_trial_qualified_patient_id
where collection like ? and site = ?