-- Name: ChangeEquivalenceClassStatus
-- Schema: posda_files
-- Columns: []
-- Args: ['review_status', 'processing_status', 'image_equivalence_class_id']
-- Tags: ['by_collection', 'find_series', 'compare_collection_site', 'search_series', 'edit_files', 'simple_phi', 'dciodvfy', 'ctp_details', 'select_for_phi', 'visual_review_new_workflow']
-- Description: Get Series in A Collection, site with dicom_file_type, modality, and sop_count
-- 

update image_equivalence_class set
  review_status = ?,
  processing_status = ?
where
  image_equivalence_class_id = ?