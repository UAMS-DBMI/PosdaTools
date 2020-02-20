-- Name: VeryBadDicomFilesInTimepoint
-- Schema: posda_files
-- Columns: ['file_id', 'path']
-- Args: ['activity_timepoint_id']
-- Tags: ['weird_stuff']
-- Description: Get really bad DICOM files in timepoint
--

select
  file_id, 
  root_path || '/' || rel_path as path
from
  file_storage_root natural join file_location fl
where
  file_id in (
    select 
      file_id from file natural join activity_timepoint_file
    where
      activity_timepoint_id = ? and
      file_type = 'parsed dicom file'
      and not exists (
        select file_id from file_sop_common sc where sc.file_id = fl.file_id
      )
  )