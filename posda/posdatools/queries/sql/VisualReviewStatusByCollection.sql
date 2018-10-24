-- Name: VisualReviewStatusByCollection
-- Schema: posda_files
-- Columns: ['series_instance_uid', 'review_status', 'visibility', 'modality', 'series_description', 'series_date', 'num_equiv_classes', 'num_files']
-- Args: ['collection', 'review_status']
-- Tags: ['by_collection', 'find_series', 'compare_collection_site', 'search_series', 'edit_files', 'simple_phi', 'dciodvfy', 'ctp_details', 'select_for_phi', 'visual_review_new_workflow']
-- Description: Get Series in A Collection, site with dicom_file_type, modality, and sop_count
-- 

select 
  distinct series_instance_uid, visibility, review_status, modality, series_description,
  series_date, count(distinct image_equivalence_class_id) as num_equiv_classes, 
  count(distinct file_id) as num_files
from
  image_equivalence_class natural join
  image_equivalence_class_input_image natural join
  file_series natural join ctp_file
where
  project_name = ? and visibility is null and review_status = ?
group by series_instance_uid, visibility, review_status, modality, series_description, series_date;