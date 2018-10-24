-- Name: ListOfAvailableQueries
-- Schema: posda_queries
-- Columns: ['schema', 'name', 'description', 'tags']
-- Args: []
-- Tags: ['AllCollections', 'q_list']
-- Description: Get a list of available queries

select
  schema, name, description,
  array_to_string(tags, ',') as tags
from queries
order by name