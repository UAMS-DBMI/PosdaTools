-- Name: SeriesNickname
-- Schema: posda_nicknames
-- Columns: ['project_name', 'site_name', 'subj_id', 'series_nickname']
-- Args: ['series_instance_uid']
-- Tags: []
-- Description: Get a nickname, etc for a particular series uid
-- 

select
  project_name, site_name, subj_id, series_nickname
from
  series_nickname
where
  series_instance_uid = ?
