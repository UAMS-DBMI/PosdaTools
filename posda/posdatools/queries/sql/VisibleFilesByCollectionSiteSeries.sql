-- Name: VisibleFilesByCollectionSiteSeries
-- Schema: posda_files
-- Columns: ['collection', 'site', 'file_id', 'visibility']
-- Args: ['collection', 'site', 'series_instance_uid']
-- Tags: ['duplicates', 'dup_sops', 'hide_dup_sops', 'sops_different_series']
-- Description: Return a count of duplicate SOP Instance UIDs
-- 

select
  distinct project_name as collection,
  site_name as site,
  file_id, visibility
from
  file_series natural left join ctp_file
where
  project_name = ? and
  site_name = ? and
  series_instance_uid = ? and
  visibility is null
order by collection, site
