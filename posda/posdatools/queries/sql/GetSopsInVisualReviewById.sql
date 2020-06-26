-- Name: GetSopsInVisualReviewById
-- Schema: posda_files
-- Columns: ['sop_instance_uid']
-- Args: ['visual_review_instance_id']
-- Tags: ['visual_review']
-- Description: Get all files in a visual_review_instance
--

select sop_instance_uid from file_sop_common
where file_id in (select 
  file_id
from
  image_equivalence_class_input_image
where
  image_equivalence_class_id in (
    select image_equivalence_class_id 
    from image_equivalence_class where visual_review_instance_id = ?
)
)