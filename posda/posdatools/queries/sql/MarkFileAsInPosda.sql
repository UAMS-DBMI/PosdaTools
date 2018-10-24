-- Name: MarkFileAsInPosda
-- Schema: posda_backlog
-- Columns: []
-- Args: ['posda_file_id', 'request_id']
-- Tags: ['NotInteractive', 'Backlog']
-- Description: Update a request status to indicate file in Posda

update request
set
  file_in_posda = true,
  time_entered = now(),
  posda_file_id = ?
where
  request_id = ?

