-- Name: SeriesNotScheduledForVisualReviewByCollectionSiteSummary
-- Schema: posda_files
-- Columns: ['series_instance_uid', 'dicom_file_type', 'modality', 'num_files']
-- Args: ['project_name', 'site_name']
-- Tags: ['find_series', 'equivalence_classes', 'consistency', 'visual_review_results', 'hide_files']
-- Description: Get Series which have no image_equivalence class by collection, site

select 
  distinct
  series_instance_uid,
  dicom_file_type,
  modality,
  count(distinct file_id) as num_files
from 
  dicom_file natural join 
  file_series natural join 
  ctp_file
where
  file_id in (
    select file_id from file_series
    where series_instance_uid in
    (
       select distinct series_instance_uid
       from file_series fs natural join ctp_file
       where
         project_name = ? and
         site_name = ? and visibility is null
         and not exists (
           select series_instance_uid
           from image_equivalence_class ie
           where ie.series_instance_uid = fs.series_instance_uid
         )
    )
  )
group by
  series_instance_uid,
  dicom_file_type,
  modality