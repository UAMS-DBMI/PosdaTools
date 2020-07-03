-- Name: SopStatusReportForVisualReviewInstance
-- Schema: posda_files
-- Columns: ['patient_id', 'series_instance_uid', 'sop_instance_uid', 'modality', 'file_id', 'processing_status', 'review_status']
-- Args: ['visual_review_instance_id']
-- Tags: ['visual_review']
-- Description: Get all files in a visual_review_instance with file_info and review_info
--

select 
    patient_id, series_instance_uid, sop_instance_uid, modality, file_id, 
    processing_status, review_status
from
    image_equivalence_class_input_image natural join
    image_equivalence_class natural join visual_review_instance natural join
    file_patient natural join file_series natural join file_sop_common
where
  image_equivalence_class_id in (
    select image_equivalence_class_id 
    from image_equivalence_class
    where visual_review_instance_id = ?
  )