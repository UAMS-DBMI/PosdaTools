-- Name: QueryByName
-- Schema: posda_queries
-- Columns: ['name', 'description', 'query', 'tags']
-- Args: ['name']
-- Tags: ['AllCollections', 'queries']
-- Description: Get a list of available queries

select
  name, description, query,
  array_to_string(tags, ',') as tags
from queries
where name = ?
