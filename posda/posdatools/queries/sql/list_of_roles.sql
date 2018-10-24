-- Name: list_of_roles
-- Schema: posda_queries
-- Columns: ['role']
-- Args: []
-- Tags: ['roles']
-- Description: Show a complete list of roles
-- 

select
  filter_name as role
from query_tag_filter