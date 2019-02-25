-- Name: ColumnsInTable
-- Schema: posda_queries
-- Columns: ['column_name']
-- Args: ['table_name']
-- Tags: ['AllCollections', 'postgres_stats', 'table_size']
-- Description: Get a list of collections and sites
-- 

select attname as column_name
FROM pg_attribute,pg_class 
WHERE attrelid=pg_class.oid 
AND relname= ?
AND attstattarget <>0; 
