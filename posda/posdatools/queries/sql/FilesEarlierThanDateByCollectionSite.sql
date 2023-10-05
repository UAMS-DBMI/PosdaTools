-- Name: FilesEarlierThanDateByCollectionSite
-- Schema: posda_files
-- Columns: ['file_id', 'old_visibility']
-- Args: ['collection', 'site', 'before']
-- Tags: ['find_series', 'equivalence_classes', 'consistency', 'visual_review_results', 'hide_files']
-- Description: Show Received before date by collection, site

select 
  distinct file_id, visibility as old_visibility
from 
  ctp_file natural join file_import natural join import_event
where
  project_name = ? and site_name = ?
  and import_time < ?
 