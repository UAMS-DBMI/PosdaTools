-- Name: VisualReviewStatusDetailsOld
-- Schema: posda_files
-- Columns: ['image_equivalence_class_id', 'series_instance_uid', 'processing_status', 'review_status']
-- Args: ['visual_review_instance_id', 'processing_status', 'review_status', 'dicom_file_type']
-- Tags: ['by_collection', 'find_series', 'compare_collection_site', 'search_series', 'edit_files', 'simple_phi', 'dciodvfy', 'ctp_details', 'select_for_phi', 'visual_review_new_workflow']
-- Description: Get Series in A Collection, site with dicom_file_type, modality, and sop_count
-- 

select 
  distinct image_equivalence_class_id, series_instance_uid, processing_status, review_status
from 
  image_equivalence_class natural join image_equivalence_class_input_image natural join dicom_file
where 
  visual_review_instance_id = ? and processing_status = ? and 
  (review_status= ?  or review_status is null)  and dicom_file_type = ?