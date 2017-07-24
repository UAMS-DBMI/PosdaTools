-- Name: GetNRequestsForCollection
-- Schema: posda_backlog
-- Columns: ['request_id', 'collection', 'received_file_path', 'file_digest', 'time_received', 'size']
-- Args: ['collection', 'num_rows']
-- Tags: ['NotInteractive', 'Backlog']
-- Description: Get N Requests for a Given Collection

select 
  distinct request_id, collection, received_file_path, file_digest, time_received, size
from 
  request natural join submitter
where
  collection = ? and not file_in_posda 
order by time_received 
limit ?
