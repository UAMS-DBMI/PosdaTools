-- Name: NiftiFilePathsFromActivity
-- Schema: posda_files
-- Columns: ['file_id','root_path','rel_path']
-- Args: ['activity_id']
-- Tags: []
-- Description: View filepaths for the nifti files in the latest Actitivy TP for the specified activity id
--
--

select
  file_id,
  root_path,
  rel_path
from
  activity_timepoint_file
  natural join  file
  natural join file_nifti
  natural join file_location
  natural join file_storage_root
where
  activity_timepoint_id =  (select max(activity_timepoint_id) as activity_timepoint_id from activity_timepoint where activity_id = ? )
