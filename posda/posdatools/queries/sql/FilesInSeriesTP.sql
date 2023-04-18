-- Name: FilesInSeriesTP
-- Schema: posda_files
-- Columns: ['file']
-- Args: ['series_instance_uid', 'activity_timepoint_id']
-- Tags: ['by_series', 'find_files', 'used_in_simple_phi']
-- Description:  Get files in a series from posda database that are in the lastest timepoint
--

select
distinct root_path || ''/'' || rel_path as file
from
file_location natural join file_storage_root
natural left join ctp_file
natural join file_series
natural join activity_timepoint_file
where
series_instance_uid = ?
and activity_timepoint_id = ?
