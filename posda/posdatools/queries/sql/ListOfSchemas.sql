-- Name: ListOfSchemas
-- Schema: posda_queries
-- Columns: ['schema']
-- Args: []
-- Tags: ['AllCollections', 'schema']
-- Description: Get a list of available queries

select
 distinct schema
from queries
order by schema