-- Name: ExportDaemonRequest
-- Schema: posda_files
<<<<<<< HEAD
-- Columns: []
-- Args: ['request_status', 'export_event_id']
-- Tags: ['export_event']
-- Description: submit a request to Export Daemon
=======
-- Columns: ['file_id']
-- Args: []
-- Tags: ['AllCollections', 'DateRange', 'Kirk', 'Totals', 'count_queries', 'end_of_month']
-- Description: Get posda totals by date range
-- 
-- **WARNING:**  This query can run for a **LONG** time if you give it a large date range.
-- It is intended for short date ranges (i.e. "What came in last night?" or "What came in last month?")
-- (Ignore this line, it is a test!)
>>>>>>> Initial working copy of ExportTimepoint operation
--

update export_event set
  request_status = ?,
  request_pending = true
<<<<<<< HEAD
where export_event_id = ?
=======
where export_event_id
>>>>>>> Initial working copy of ExportTimepoint operation
