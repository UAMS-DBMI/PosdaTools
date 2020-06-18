-- Name: AllFilesInActivityTimepointReport
-- Schema: posda_files
-- Columns: ['file_type', 'dicom_file_type', 'num_files']
-- Args: ['activity_id']
-- Tags: ['activity_timepoint_reports']
-- Description: Report on all files (not just DICOM) in activity timepoint
--

select 
  distinct file_type, dicom_file_type, count(*) as num_files
from
  file natural join
  activity_timepoint_file
  natural left join dicom_file
where
  activity_timepoint_id = (
    select max(activity_timepoint_id) as activity_timepoint_id
  from
    activity_timepoint
  where
    activity_id = ?
)
group by
  file_type, dicom_file_type
order by 
  file_type