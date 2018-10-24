-- Name: VisualReviewStatusById
-- Schema: posda_files
-- Columns: ['id', 'processing_status', 'review_status', 'dicom_file_type', 'num_equiv', 'num_series']
-- Args: ['id']
-- Tags: ['by_collection', 'find_series', 'compare_collection_site', 'search_series', 'edit_files', 'simple_phi', 'dciodvfy', 'ctp_details', 'select_for_phi', 'visual_review_reports', 'visual_review_new_workflow']
-- Description: Get Series in A Collection, site with dicom_file_type, modality, and sop_count
-- 

select
  distinct visual_review_instance_id as id, processing_status, review_status, dicom_file_type,
  count(distinct image_equivalence_class_id) as num_equiv, count(distinct series_instance_uid) as num_series
from
  image_equivalence_class natural join image_equivalence_class_input_image 
  natural join dicom_file natural join ctp_file
where
  visual_review_instance_id = ? and visibility is null
group by id, processing_status, review_status, dicom_file_type