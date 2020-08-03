-- Name: GetListOfUnprocessedStructureSetsInActivity
-- Schema: posda_files
-- Columns: ['file_id', 'path']
-- Args: ['activity_id']
-- Tags: ['NotInteractive', 'used_in_processing_structure_set_linkages']
-- Description: Get the file_storage root for newly created files
--

select
  file_id,
  root_path || '/' || rel_path as path
from
  file_storage_root natural join file_location
where file_id in (
  select distinct file_id
  from dicom_file df natural join ctp_file natural join activity_timepoint_file
  where 
  dicom_file_type = 'RT Structure Set Storage'
  and visibility is null and has_no_roi_linkages is null
  and not exists (
    select file_id from file_roi_image_linkage r where r.file_id = df.file_id
  )
  and activity_timepoint_id = (
    select max(activity_timepoint_id) as activity_timepoint_id
    from activity_timepoint
    where activity_id = ?
  )
) 