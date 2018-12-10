-- Name: GetDatasetStart
-- Schema: posda_files
-- Columns: ['data_set_start']
-- Args: ['file_id']
-- Tags: ['AllCollections', 'universal', 'public_posda_consistency']
-- Description: Get path to file by id

select
  data_set_start
from
  file_meta
where
  file_id = ?