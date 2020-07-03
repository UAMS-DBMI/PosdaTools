-- Name: NonDicomActivityTimepointReport
-- Schema: posda_files
-- Columns: ['file_type', 'num_files']
-- Args: ['activity_id']
-- Tags: ['activity_timepoint_reports']
-- Description:  Make a very verbose report of files in the latest timepoint for an activity
--

select
  distinct file_type, count(distinct file_id) as num_files
from
  file
where file_id in  
  (
    select 
      file_id from activity_timepoint_file atf
    where
     activity_timepoint_id = (
        select 
          max(activity_timepoint_id) as activity_timepoint_id
        from
          activity_timepoint
        where
          activity_id = ?
      ) and
      not exists (select file_id from dicom_file df where df.file_id = atf.file_id)
   )
group by file_type