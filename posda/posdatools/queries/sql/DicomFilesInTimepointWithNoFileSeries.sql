-- Name: DicomFilesInTimepointWithNoFileSeries
-- Schema: posda_files
-- Columns: ['file_id']
-- Args: ['activity_timepoint_id']
-- Tags: ['queries']
-- Description: Counts query by Collection, Site
-- 

select
  file_id
from
  file f natural join dicom_file
where file_id in (
  select file_id from activity_timepoint_file where activity_timepoint_id = ? 
  )
  and not exists (
    select file_id from file_series s where s.file_id = f.file_id
  )