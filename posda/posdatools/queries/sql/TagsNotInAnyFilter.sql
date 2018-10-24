-- Name: TagsNotInAnyFilter
-- Schema: posda_queries
-- Columns: ['tag']
-- Args: []
-- Tags: ['meta', 'test', 'hello', 'query_tabs', 'bills_test']
-- Description: Add a filter to a tab

select
  distinct tag
from(
  select unnest(tags) as tag
  from queries
) as tag_q
where tag not in (select tag
from (
  select 
     query_tab_name,
      filter_name,
      unnest(tags_enabled) as tag
  from
    query_tabs join query_tabs_query_tag_filter using(query_tab_name)
    natural join query_tag_filter
) as foo
) 