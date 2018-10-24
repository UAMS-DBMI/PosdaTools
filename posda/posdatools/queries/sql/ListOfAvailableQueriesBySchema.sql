-- Name: ListOfAvailableQueriesBySchema
-- Schema: posda_queries
-- Columns: ['name', 'description', 'tags']
-- Args: ['schema']
-- Tags: ['AllCollections', 'schema']
-- Description: Get a list of available queries

select
  name, description,
  array_to_string(tags, ',') as tags
from queries
where schema = ?
order by name