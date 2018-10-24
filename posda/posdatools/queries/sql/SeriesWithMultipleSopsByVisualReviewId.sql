-- Name: SeriesWithMultipleSopsByVisualReviewId
-- Schema: posda_files
-- Columns: ['series_instance_uid', 'dicom_file_type', 'modality', 'visibility', 'num_files']
-- Args: ['visual_review_instance_id']
-- Tags: ['by_collection', 'find_series', 'compare_collection_site', 'search_series', 'edit_files', 'simple_phi', 'dciodvfy', 'ctp_details', 'select_for_phi', 'visual_review_new_workflow']
-- Description: Get Series in A Collection, site with dicom_file_type, modality, and sop_count
-- 

select 
  distinct series_instance_uid, dicom_file_type, modality, visibility, count(distinct file_id) as num_files
from file_series natural join dicom_file natural join ctp_file
where series_instance_uid in (
  select series_instance_uid from (
    select
      distinct series_instance_uid, count(distinct dicom_file_type) as num_types, 
      count(distinct modality) as num_modalities 
    from (
      select 
        distinct series_instance_uid, dicom_file_type, modality
      from 
        file_series natural join dicom_file natural join image_equivalence_class
      where visual_review_instance_id = ?
     ) as foo
    group by series_instance_uid
  ) as foo 
  where num_types > 1 or num_modalities > 1
) group by series_instance_uid, dicom_file_type, modality, visibility order by series_instance_uid