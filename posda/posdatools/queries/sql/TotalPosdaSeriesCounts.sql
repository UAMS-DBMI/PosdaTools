-- Name: TotalPosdaSeriesCounts
-- Schema: posda_files
-- Columns: ['collection', 'site', 'num_series', 'num_files']
-- Args: []
-- Tags: ['meta', 'test', 'hello', 'query_tabs', 'bills_test']
-- Description: Files for a specific patient which were first received after a specific time

select
  distinct project_name as collection, site_name as site,  count(distinct series_instance_uid) as num_series,
  count(distinct file_id) as num_files
from 
  ctp_file natural join file_series 
where
  visibility is null group by collection, site           
order by collection, site