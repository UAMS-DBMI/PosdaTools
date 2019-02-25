-- Name: AllProcessedManifestsByCollectionLikeWithPatientAndQualAndDate
-- Schema: posda_files
-- Columns: ['file_id', 'date', 'cm_collection', 'collection', 'cm_site', 'site', 'cm_patient_id', 'qualified', 'total_files']
-- Args: ['collection_like']
-- Tags: ['activity_timepoint_support', 'manifests']
-- Description: Create An Activity Timepoint
-- 
-- 

select
  distinct file_id, import_time as date, cm_collection, collection, cm_site, site, cm_patient_id, qualified,
  sum(cm_num_files) as total_files
from
  ctp_manifest_row m natural join file_import natural join import_event, clinical_trial_qualified_patient_id c
where
  cm_collection like ? and m.cm_patient_id = c.patient_id
group by file_id, date, cm_collection, collection, cm_site, site, cm_patient_id, qualified
order by date