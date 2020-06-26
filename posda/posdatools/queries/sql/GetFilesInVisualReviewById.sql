-- Name: GetFilesInVisualReviewById
-- Schema: posda_files
-- Columns: ['file_id']
-- Args: ['visual_review_instance_id']
-- Tags: ['visual_review']
-- Description: Get all files in a visual_review_instance
--

select 
  file_id
from
  image_equivalence_class_input_image
where
  image_equivalence_class_id in (
    select image_equivalence_class_id 
    from image_equivalence_class where visual_review_instance_id = ?
)