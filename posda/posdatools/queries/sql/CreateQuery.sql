-- Name: CreateQuery
-- Schema: posda_queries
-- Columns: []
-- Args: ['name', 'query', 'args', 'columns', 'tags', 'schema', 'description']
-- Tags: ['queries']
-- Description: Create a new query


insert into queries(
  name, query, args, columns, tags, schema, description
) values (
  ?, ?, ?, ?, ?, ?, ?
)