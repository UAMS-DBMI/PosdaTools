-- Name: ListOfAvailableQueriesForDescEdit
-- Schema: posda_queries
-- Columns: ['name', 'description', 'query', 'tags']
-- Args: []
-- Tags: ['AllCollections', 'q_list']
-- Description: Get a list of available queries

select
  name, description, query,
  array_to_string(tags, ',') as tags
from queries
order by name