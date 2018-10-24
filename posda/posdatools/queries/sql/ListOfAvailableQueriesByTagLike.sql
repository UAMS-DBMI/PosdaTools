-- Name: ListOfAvailableQueriesByTagLike
-- Schema: posda_queries
-- Columns: ['name', 'description', 'tags']
-- Args: ['tag']
-- Tags: ['AllCollections', 'q_list']
-- Description: Get a list of available queries

select distinct name, description, tags from (
  select
    unnest(tags) as tag,
    name, description,
    array_to_string(tags, ',') as tags
  from queries
) as foo
where tag like ?
order by name