-- Name: VisibilityChangesByCollectionSite
-- Schema: posda_files
-- Columns: ['collection', 'site', 'user_name', 'prior_visibility', 'new_visibility', 'time', 'reason_for', 'num_files']
-- Args: ['collection', 'site']
-- Tags: ['find_series', 'equivalence_classes', 'consistency', 'visual_review_results', 'hide_files']
-- Description: Get visual review status report by series for Collection, Site

select
  distinct project_name as collection, 
  site_name as site,
  user_name, prior_visibility, new_visibility,
  date_trunc('hour',time_of_change) as time, 
  reason_for, count(*) as num_files
from
  file_visibility_change natural join
  ctp_file natural join 
  file_patient natural join 
  file_series
where
  project_name = ? and site_name = ?
group by 
  collection, site, user_name, prior_visibility, new_visibility,
  time, reason_for
order by time, collection, site