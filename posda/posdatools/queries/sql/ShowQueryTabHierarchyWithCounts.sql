-- Name: ShowQueryTabHierarchyWithCounts
-- Schema: posda_queries
-- Columns: ['query_tab_name', 'filter_name', 'tag', 'num_queries']
-- Args: []
-- Tags: ['meta', 'test', 'hello', 'query_tabs', 'bills_test']
-- Description: Add a filter to a tab

select 
  query_tab_name, filter_name, tag, count(distinct query_name) as num_queries
from(
  select 
     query_tab_name,
      filter_name,
      unnest(tags_enabled) as tag
  from
    query_tabs join query_tabs_query_tag_filter using(query_tab_name)
    natural join query_tag_filter
) as foo
natural join(
  select
     name as query_name,
     unnest(tags) as tag
from queries
) as fie
group by query_tab_name, filter_name, tag
order by 
  query_tab_name, filter_name, tag