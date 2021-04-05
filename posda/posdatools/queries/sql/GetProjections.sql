-- Name: GetProjections
-- Schema: posda_files
-- Columns: ['image_equivalence_class_id', 'series_instance_uid', 'equivalence_class_number', 'processing_status', 'review_status', 'file_id']
-- Args: ['visual_review_instance_id']
-- Tags: ['Kaleidoscope']
-- Description: Get image_equivalence_class information for a visual review_instance
-- 

select
  image_equivalence_class_id, series_instance_uid, 
  equivalence_class_number, processing_status, review_status,
  file_id                                                                                                                                                                                  from 
  image_equivalence_class natural left join image_equivalence_class_out_image
where
  visual_review_instance_id = ?