-- Name: CountOfFilesRemainingToBeHiddenByScanInstanceWithSeries
-- Schema: posda_files
-- Columns: ['series_instance_uid', 'num_files']
-- Args: ['visual_review_instance_id']
-- Tags: ['by_collection', 'find_series', 'compare_collection_site', 'search_series', 'edit_files', 'simple_phi', 'dciodvfy', 'ctp_details', 'select_for_phi', 'visual_review_status']
-- Description: Get Series in A Collection, site with dicom_file_type, modality, and sop_count
--

select
  distinct series_instance_uid, count(distinct file_id) as num_files
from
  file_sop_common natural join file_series natural join ctp_file
where
  sop_instance_uid in (
    select
      sop_instance_uid
    from
      file_sop_common
      where file_id in (
          select
            distinct file_id
          from
             image_equivalence_class natural join
             image_equivalence_class_input_image
           where
             visual_review_instance_id = ? and
             review_status = 'Bad'
        )
     )
group by series_instance_uid