-- Name: DatabaseSize
-- Schema: posda_files
-- Columns: ['name', 'owner', 'size']
-- Args: []
-- Tags: ['postgres_status']
-- Description: Show active queries for a database
-- Works for PostgreSQL 9.4.5 (Current Mac)



select d.datname AS name,  pg_catalog.pg_get_userbyid(d.datdba) AS owner,
    CASE WHEN pg_catalog.has_database_privilege(d.datname, 'CONNECT')
        THEN pg_catalog.pg_size_pretty(pg_catalog.pg_database_size(d.datname))
        ELSE 'No Access'
    END AS size
FROM pg_catalog.pg_database d
    ORDER BY
    CASE WHEN pg_catalog.has_database_privilege(d.datname, 'CONNECT')
        THEN pg_catalog.pg_database_size(d.datname)
        ELSE NULL
    END DESC -- nulls first
    LIMIT 20;
