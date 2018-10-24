-- Name: ListOfAvailableQueriesByNameLike
-- Schema: posda_queries
-- Columns: ['schema', 'name', 'description', 'tags']
-- Args: ['name_like']
-- Tags: ['AllCollections', 'q_list']
-- Description: Get a list of available queries

select schema, name, description, tags from (
  select
    schema, name, description,
    array_to_string(tags, ',') as tags
  from queries
) as foo
where name like ?
order by name