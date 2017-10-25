-- Name: CreateNewQueryTab
-- Schema: posda_queries
-- Columns: []
-- Args: ['query_tab_name', 'query_tab_description', 'sort_order']
-- Tags: ['meta', 'test', 'hello', 'query_tabs']
-- Description: Create a new query tab

insert into query_tabs (
  query_tab_name,
  query_tab_description, 
  defines_dropdown,
  sort_order,
  defines_search_engine)
values(
  ?, ?, true, ?, false
)