-- Name: TableSizePosdaFiles
-- Schema: posda_files
-- Columns: ['oid', 'table_schema', 'table_name', 'row_estimate', 'total_bytes', 'index_bytes', 'total', 'toast_bytes', 'index', 'toast', 'table']
-- Args: []
-- Tags: ['AllCollections', 'postgres_stats', 'table_size']
-- Description: Get a list of collections and sites
-- 

select *, pg_size_pretty(total_bytes) AS total
    , pg_size_pretty(index_bytes) AS INDEX
    , pg_size_pretty(toast_bytes) AS toast
    , pg_size_pretty(table_bytes) AS TABLE
  FROM (
  SELECT *, total_bytes-index_bytes-COALESCE(toast_bytes,0) AS table_bytes FROM (
      SELECT c.oid,nspname AS table_schema, relname AS TABLE_NAME
              , c.reltuples AS row_estimate
              , pg_total_relation_size(c.oid) AS total_bytes
              , pg_indexes_size(c.oid) AS index_bytes
              , pg_total_relation_size(reltoastrelid) AS toast_bytes
          FROM pg_class c
          LEFT JOIN pg_namespace n ON n.oid = c.relnamespace
          WHERE relkind = 'r'
  ) a
) a where
  table_schema = 'public' or table_schema = 'dbif_config' or table_schema = 'dicom_conv'
order by total_bytes desc