-- Name: ShowQueryTabHierarchyByTabWithQueries
-- Schema: posda_queries
-- Columns: ['query_tab_name', 'filter_name', 'tag', 'query_name']
-- Args: ['query_tab_name']
-- Tags: ['meta', 'test', 'hello', 'query_tabs', 'bills_test']
-- Description: Add a filter to a tab

select
  query_tab_name, filter_name, tag, query_name
from (
  select 
     query_tab_name,
      filter_name,
      unnest(tags_enabled) as tag
  from
    query_tabs join query_tabs_query_tag_filter using(query_tab_name)
    natural join query_tag_filter
  where query_tab_name = ?
) as foo
natural join(
  select name as query_name, unnest(tags) as tag
from queries
) as fie
order by filter_name, tag, query_name