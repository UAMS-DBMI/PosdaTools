-- Name: VisibleImagesWithDetailsAndFileIdByVisualId
-- Schema: posda_files
-- Columns: ['patient_id', 'study_instance_uid', 'series_instance_uid', 'sop_instance_uid', 'modality', 'file_id']
-- Args: ['visual_review_instance_id']
-- Tags: ['by_collection', 'find_series', 'compare_collection_site', 'search_series', 'edit_files', 'simple_phi', 'dciodvfy', 'ctp_details', 'select_for_phi', 'visual_review_new_workflow']
-- Description: Get Series in A Collection, site with dicom_file_type, modality, and sop_count
-- 

select 
  distinct patient_id, study_instance_uid, series_instance_uid, sop_instance_uid, modality, 
  file_id
from 
  file_patient natural join file_study natural join file_series natural join 
  file_sop_common natural join ctp_file
where series_instance_uid in (
  select
    distinct series_instance_uid
  from
    image_equivalence_class natural join file_series natural join
    image_equivalence_class_input_image natural join dicom_file natural join ctp_file
  where
    visual_review_instance_id = ? 
)