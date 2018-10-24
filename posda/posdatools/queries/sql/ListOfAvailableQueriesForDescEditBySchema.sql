-- Name: ListOfAvailableQueriesForDescEditBySchema
-- Schema: posda_queries
-- Columns: ['name', 'description', 'query', 'tags']
-- Args: ['schema']
-- Tags: ['AllCollections', 'schema']
-- Description: Get a list of available queries

select
  name, description, query,
  array_to_string(tags, ',') as tags
from queries
where schema = ?
order by name