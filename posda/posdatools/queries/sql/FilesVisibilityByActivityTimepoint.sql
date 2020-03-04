-- Name: FilesVisibilityByActivityTimepoint
-- Schema: posda_files
-- Columns: ['file_id', 'visibility']
-- Args: ['activity_timepoint_id']
-- Tags: ['duplicates', 'dup_sops', 'hide_dup_sops', 'sops_different_series']
-- Description: Return a count of duplicate SOP Instance UIDs
--

select
  distinct file_id, visibility
from
 activity_timepoint_file natural left join ctp_file
where
  activity_timepoint_id = ?