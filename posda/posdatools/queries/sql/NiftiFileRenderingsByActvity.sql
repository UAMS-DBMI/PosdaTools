-- Name: NiftiFileRenderingsByActvity
-- Schema: posda_files
-- Columns: ['nifti_file_id', 'jpeg_image_type', 'reviewer', 'review_status', 'review_time']
-- Args: ['activity_id']
-- Tags: ['Nifti']
-- Description: Get information about nifti projections for latest timepoint in current activity
-- 

select
  distinct nj.nifti_file_id, f.file_type as jpeg_image_type,
  reviewer, review_status, review_time
from
  nifti_jpeg_projection nj natural left join nifti_projection_review pr,
  file f
where
  f.file_id = nj.jpeg_file_id and
  nifti_file_id in(
    select file_id from activity_timepoint_file
    where activity_timepoint_id = (
       select max(activity_timepoint_id) as activity_timepoint_id
       from activity_timepoint where activity_id = ?
    )
)