-- Name: FileStorageTotalBytes
-- Schema: posda_files
-- Columns: ['total_bytes']
-- Args: []
-- Tags: ['AllCollections', 'postgres_stats', 'database_size']
-- Description: Get a list of collections and sites
-- 

select
  sum(size) as total_bytes
from file
