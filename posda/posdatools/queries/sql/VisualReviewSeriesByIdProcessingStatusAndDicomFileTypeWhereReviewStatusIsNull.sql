-- Name: VisualReviewSeriesByIdProcessingStatusAndDicomFileTypeWhereReviewStatusIsNull
-- Schema: posda_files
-- Columns: ['image_equivalence_class_id', 'series_instance_uid']
-- Args: ['visual_review_instance_id', 'processing_status', 'dicom_file_type']
-- Tags: ['by_collection', 'find_series', 'compare_collection_site', 'search_series', 'edit_files', 'simple_phi', 'dciodvfy', 'ctp_details', 'select_for_phi', 'visual_review_new_workflow']
-- Description: Get Series in A Collection, site with dicom_file_type, modality, and sop_count
-- 

select 
  distinct image_equivalence_class_id, series_instance_uid
from
  visual_review_instance natural join image_equivalence_class natural join
  image_equivalence_class_input_image natural join dicom_file natural join 
  file_series natural join ctp_file
where
  visual_review_instance_id = ? and review_status is null and processing_status = ? and dicom_file_type = ?
