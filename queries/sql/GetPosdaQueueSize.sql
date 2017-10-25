-- Name: GetPosdaQueueSize
-- Schema: posda_files
-- Columns: ['num_files']
-- Args: []
-- Tags: ['NotInteractive', 'Backlog', 'Backlog Monitor', 'backlog_status']
-- Description: Get size of queue  in Posda

select
 count(*) as num_files
from
  file NATURAL JOIN file_location NATURAL JOIN file_storage_root
where
  is_dicom_file is null and
  ready_to_process and
  processing_priority is not null

