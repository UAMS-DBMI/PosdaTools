-- Name: VisualReviewStatusWithCollectionById
-- Schema: posda_files
-- Columns: ['collection', 'site', 'series_instance_uid', 'review_status', 'modality', 'series_description', 'series_date', 'num_equiv_classes', 'num_files']
-- Args: ['visual_review_instance_id', 'review_status']
-- Tags: ['by_collection', 'find_series', 'compare_collection_site', 'search_series', 'edit_files', 'simple_phi', 'dciodvfy', 'ctp_details', 'select_for_phi', 'visual_review_new_workflow']
-- Description: Get Series in A Collection, site with dicom_file_type, modality, and sop_count
-- 

select 
  distinct project_name as collection, site_name as site, 
  series_instance_uid, review_status, modality, series_description,
  series_date, count(distinct image_equivalence_class_id) as num_equiv_classes, 
  count(distinct file_id) as num_files
from
  visual_review_instance natural join image_equivalence_class natural join
  image_equivalence_class_input_image natural join
  file_series natural join ctp_file
where
  visual_review_instance_id = ? and review_status = ? and visibility is null
group by collection, site, series_instance_uid, review_status, modality, series_description, series_date;