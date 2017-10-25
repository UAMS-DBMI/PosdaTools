-- Name: GetFileIdVisibilityBySeriesInstanceUid
-- Schema: posda_files
-- Columns: ['file_id', 'visibility']
-- Args: ['series_instance_uid']
-- Tags: ['ImageEdit', 'edit_files']
-- Description: Get File id and visibility for all files in a series

select distinct file_id, visibility
from file_series natural left join ctp_file
where series_instance_uid = ?