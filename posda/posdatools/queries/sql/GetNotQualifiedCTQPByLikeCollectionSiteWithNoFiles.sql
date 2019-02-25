-- Name: GetNotQualifiedCTQPByLikeCollectionSiteWithNoFiles
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
  clinical_trial_qualified_patient_id p
where collection like ? and site = ? and not qualified and
  not exists (select file_id from file_patient f where f.patient_id = p.patient_id)
group by collection, site, patient_id, qualified