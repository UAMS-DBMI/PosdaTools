-- Name: VisualReviewStatusDetails
-- Schema: posda_files
-- Columns: ['image_equivalence_class_id', 'series_instance_uid', 'processing_status', 'review_status', 'visibility', 'num_files']
-- Args: ['visual_review_instance_id', 'dicom_file_type', 'processing_status', 'review_status']
-- Tags: ['by_collection', 'find_series', 'compare_collection_site', 'search_series', 'edit_files', 'simple_phi', 'dciodvfy', 'ctp_details', 'select_for_phi', 'visual_review_new_workflow']
-- Description: Get Series in A Collection, site with dicom_file_type, modality, and sop_count
-- 

select distinct image_equivalence_class_id, series_instance_uid, processing_status, review_status, visibility, count(distinct file_id) as num_files
from image_equivalence_class natural join image_equivalence_class_input_image natural join dicom_file natural join ctp_file
where visual_review_instance_id = ? and dicom_file_type = ? and
  processing_status = ? and (review_status is null or review_status = ?) 
group by image_equivalence_class_id, series_instance_uid, processing_status, review_status, visibility;
