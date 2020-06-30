-- Name: SeriesWhichFailedToTransferToPublic
-- Schema: posda_files
-- Columns: ['series_instance_uid', 'count']
-- Args: ['subprocess_invocation_id']
-- Tags: ['AllCollections', 'DateRange', 'Kirk', 'Totals', 'count_queries', 'end_of_month']
-- Description: Get the list of files which failed to transfer to nbia from public_copy_status
--

select distinct series_instance_uid, count(*) from file_series
where file_id in (
select file_id from public_copy_status where
subprocess_invocation_id = ? and not success) group by series_instance_uid;