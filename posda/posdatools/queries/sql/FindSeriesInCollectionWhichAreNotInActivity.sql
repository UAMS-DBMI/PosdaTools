-- Name: FindSeriesInCollectionWhichAreNotInActivity
-- Schema: posda_files
-- Columns: ['series_instance_uid', 'dicom_file_type', 'modality', 'visibility', 'num_files']
-- Args: ['collection', 'activity_id']
-- Tags: []
-- Description: Find all series which are in specified collection, but not in the timepoint
--

select
  series_instance_uid, dicom_file_type, modality, coalesce(visibility, 'visible') as visibility, 
  count(distinct file_id) as num_files
from
  file_series natural join dicom_file natural join ctp_file
where series_instance_uid in (
    select distinct series_instance_uid from file_series natural join ctp_file
    where project_name = ?
  ) and series_instance_uid not in (
    select distinct series_instance_uid
    from file_series natural join activity_timepoint_file
    where activity_timepoint_id = (
       select max (activity_timepoint_id) as activity_timepoint_id
       from activity_timepoint
       where activity_id = ?
    )
  )
group by series_instance_uid, dicom_file_type, modality, visibility