-- Name: DeleteTpFilesFromFileMr
-- Schema: posda_files
-- Columns: []
-- Args: ['activity_timepoint_id']
-- Tags: ['file_mr']
-- Description:  Delete files in activity_timepoint from file_mr
--

delete from file_mr
where file_id in (
  select file_id from activity_timepoint_file
  where activity_timepoint_id = ?
)