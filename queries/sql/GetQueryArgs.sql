-- Name: GetQueryArgs
-- Schema: posda_queries
-- Columns: ['args']
-- Args: ['name']
-- Tags: ['bills_test', 'posda_db_populate']
-- Description: Add a filter to a tab

select args from queries where name = ?