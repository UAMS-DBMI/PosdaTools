-- Name: IsFileInActivity
-- Schema: posda_files
-- Columns: ['file_id']
-- Args: ['file_id', 'activity_id']
-- Tags: ['non_dicom_extensions']
-- Description: find out if file is in current activity_timepoint for activity
-- 

select
  file_id from activity_timepoint_file
where
  file_id = ? and
  activity_timepoint_id = (
    select max(activity_timepoint_id) as activity_timepoint_id
    from activity_timepoint where activity_id = ?
  )