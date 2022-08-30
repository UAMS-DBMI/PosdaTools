-- Name: PathologyVRlogs
-- Schema: posda_files
-- Columns: ['pathology_visual_review_instance_id', 'path_file_id', 'good_status', 'reviewing_user', 'review_time']
-- Args: ['activity_creation_id']
-- Tags: ['pathology', 'visual_review']
-- Description: Get all pathvr reviews on an activity
--

select
  pathology_visual_review_instance_id , path_file_id, good_status, reviewing_user, review_time
from pathology_visual_review_files a  natural left join pathology_visual_review_status b
natural join pathology_visual_review_instance c
where activity_creation_id = ?
