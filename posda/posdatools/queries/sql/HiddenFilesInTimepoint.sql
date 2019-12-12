-- Name: HiddenFilesInTimepoint
-- Schema: posda_files
-- Columns: ['file_id']
-- Args: ['activity_timepoint_id']
-- Tags: ['activity_timepoints']
-- Description:  Get hidden files in timepoint
--

select
  distinct file_id
from
  activity_timepoint_file natural left join ctp_file
where
  activity_timepoint_id = ? and visibility is not null