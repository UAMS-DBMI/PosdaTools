-- Name: NiftiVRlogs
-- Schema: posda_files
-- Columns: ['nifti_visual_review_instance_id', 'nifti_file_id', 'good_status', 'reviewing_user', 'review_time']
-- Args: ['activity_id']
-- Tags: ['nifti', 'visual_review']
-- Description: Get all nifti visual reviews for an activity
--

select
  nifti_visual_review_instance_id, nifti_file_id, good_status, reviewing_user, review_time
from nifti_visual_review_files a  
natural left join nifti_visual_review_status b
natural join nifti_visual_review_instance c
where activity_id = ?
