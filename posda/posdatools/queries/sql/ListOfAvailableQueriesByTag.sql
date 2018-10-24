-- Name: ListOfAvailableQueriesByTag
-- Schema: posda_queries
-- Columns: ['tag', 'name', 'description']
-- Args: ['tag']
-- Tags: ['AllCollections', 'q_list']
-- Description: Get a list of available queries

select tag, name, description from (
  select
    unnest(tags) as tag,
    name, description
  from queries
) as foo
where tag = ?
order by name