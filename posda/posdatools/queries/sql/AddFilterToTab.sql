-- Name: AddFilterToTab
-- Schema: posda_queries
-- Columns: []
-- Args: ['query_tab_name', 'filter_name', 'sort_order']
-- Tags: ['meta', 'test', 'hello', 'query_tabs', 'bills_test']
-- Description: Add a filter to a tab

insert into query_tabs_query_tag_filter(query_tab_name, filter_name, sort_order)
values(?, ?, ?)