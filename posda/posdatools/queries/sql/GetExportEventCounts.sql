-- Name: GetExportEventCounts
-- Schema: posda_files
-- Columns: ['transfer_status', 'count']
-- Args: ['export_event_id']
-- Tags: ['export_event']
-- Description:  Get the counts of all files in an export_event by transfer_status
--

select
	coalesce(transfer_status::text, 'waiting') as transfer_status,
	count(file_id) as count
from file_export
where export_event_id = ?
group by 1
