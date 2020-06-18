-- Name: GetExportRequest
-- Schema: posda_files
-- Columns: ['request_status']
-- Args: ['export_event_id']
-- Tags: ['export_event']
-- Description:  Check if a request is pending and return request_status if so
--

select
  request_status
from
  export_event
where
 export_event_id = ? and request_pending
