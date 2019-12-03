-- Name: ImportedFileNamesFromTimepoint
-- Schema: posda_files
-- Columns: ['digest', 'file_name']
-- Args: ['activity_timepoint_id']
-- Tags: ['digest', 'file_name']
-- Description: Get list of digest and imported file_name from an activity timepoint
-- 

select
  distinct  digest, file_name
from
  file natural join file_import
where
  file_id in (
    select file_id 
    from activity_timepoint_file 
    where activity_timepoint_id = ?
)