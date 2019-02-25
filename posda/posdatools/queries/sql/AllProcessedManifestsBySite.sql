-- Name: AllProcessedManifestsBySite
-- Schema: posda_files
-- Columns: ['file_id', 'cm_collection', 'cm_site', 'total_files']
-- Args: ['site']
-- Tags: ['activity_timepoint_support', 'manifests']
-- Description: Create An Activity Timepoint
-- 
-- 

select
  distinct file_id, cm_collection, cm_site,  sum(cm_num_files) as total_files
from
  ctp_manifest_row
where
  cm_site = ?
group by file_id, cm_collection, cm_site