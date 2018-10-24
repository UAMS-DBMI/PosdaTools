-- Name: TagsInMultipleTagFilters
-- Schema: posda_queries
-- Columns: ['tag', 'num_locations']
-- Args: []
-- Tags: ['meta', 'test', 'hello', 'query_tabs', 'bills_test']
-- Description: Add a filter to a tab

select distinct tag, count(*) as num_locations
from (
  select 
     query_tab_name,
      filter_name,
      unnest(tags_enabled) as tag
  from
    query_tabs join query_tabs_query_tag_filter using(query_tab_name)
    natural join query_tag_filter
) as foo
group by tag
order by num_locations desc