-- Name: AllProcessedManifestsByCollectionLikeWithDate
-- Schema: posda_files
-- Columns: ['file_id', 'date', 'cm_collection', 'cm_site', 'total_files']
-- Args: ['collection_like']
-- Tags: ['activity_timepoint_support', 'manifests']
-- Description: Create An Activity Timepoint
-- 
-- 

select
  distinct file_id, import_time as date, cm_collection, cm_site,  sum(cm_num_files) as total_files
from
  ctp_manifest_row natural join file_import natural join import_event
where
  cm_collection like ?
group by file_id, date, cm_collection, cm_site