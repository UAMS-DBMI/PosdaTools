-- Name: ShowQueryTabHierarchyWithQueries
-- Schema: posda_queries
-- Columns: ['query_tab_name', 'filter_name', 'tag', 'query_name']
-- Args: []
-- Tags: ['meta', 'test', 'hello', 'query_tabs', 'bills_test']
-- Description: Add a filter to a tab

select 
  distinct query_tab_name, filter_name, tag, query_name
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
order by 
  query_tab_name, filter_name, tag, query_name