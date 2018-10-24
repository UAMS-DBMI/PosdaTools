-- Name: NumFilesInSeries
-- Schema: posda_files
-- Columns: ['num_files']
-- Args: ['series_instance_uid']
-- Tags: ['bills_test']
-- Description: Get number of files in series

select count(distinct file_id) as num_files from file_series natural join ctp_file where 
series_instance_uid = ? and visibility is null