-- Name: AllProcessedManifests
-- Schema: posda_files
-- Columns: ['file_id', 'cm_collection', 'cm_site', 'cm_patient_id', 'total_files']
-- Args: []
-- Tags: ['activity_timepoint_support', 'manifests']
-- Description: Create An Activity Timepoint
-- 
-- 

select
  distinct file_id, cm_collection, cm_site, cm_patient_id, sum(cm_num_files) as total_files
from
  ctp_manifest_row
group by file_id, cm_collection, cm_site, cm_patient_id