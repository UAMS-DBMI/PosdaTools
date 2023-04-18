-- Name: VisibleColSiteWithCtpLikeSite
-- Schema: posda_files
-- Columns: ['collection', 'site', 'num_files']
-- Args: ['pattern']
-- Tags: ['adding_ctp', 'find_patients', 'series_selection', 'ctp_col_site', 'select_for_phi']
-- Description: Get List of visible patients with CTP data

select
  distinct project_name as collection, site_name as site, count(*) as num_files
from ctp_file
where project_name like ?
group by collection, site order by collection