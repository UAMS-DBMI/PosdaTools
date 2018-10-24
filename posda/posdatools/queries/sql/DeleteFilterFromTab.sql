-- Name: DeleteFilterFromTab
-- Schema: posda_queries
-- Columns: []
-- Args: ['query_tab_name', 'filter_name']
-- Tags: ['meta', 'test', 'hello', 'query_tabs']
-- Description: Remove a filter from a tab

delere from query_tabs_query_tag_filter
where query_tab_name = ? and filter_name = ?