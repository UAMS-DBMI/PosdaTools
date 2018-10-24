-- Name: tags_by_role
-- Schema: posda_queries
-- Columns: ['role', 'tag']
-- Args: ['role']
-- Tags: ['roles']
-- Description: Show a complete list of associated tags for a role
-- 

select
  filter_name as role, unnest(tags_enabled) as tag
from query_tag_filter where filter_name = ?