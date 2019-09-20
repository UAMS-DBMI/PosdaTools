-- Name: GetPosdaQueueSize
-- Schema: posda_files
-- Columns: ['num_files']
-- Args: []
-- Tags: ['NotInteractive', 'Backlog', 'Backlog Monitor', 'backlog_status']
-- Description: Get size of queue  in Posda
-- Removed by Quasar on 2018-11-25. Results are not identical but it is more than 500 times faster
-- NATURAL JOIN file_location NATURAL JOIN file_storage_root
--

select
 count(*) as num_files
from
  file 
where
  is_dicom_file is null and
  ready_to_process and
  processing_priority is not null

