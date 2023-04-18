-- Name: AreVisibleFilesMarkedAsBadOrUnreviewedInSeries
-- Schema: posda_files
-- Columns: ['collection', 'site', 'patient_id', 'series_instance_uid', 'dicom_file_type', 'modality', 'review_status', 'processing_status', 'visibility', 'file_id']
-- Args: ['series_instance_uid']
-- Tags: ['find_series', 'equivalence_classes', 'consistency', 'visual_review_results', 'hide_events']
-- Description: Get visual review status report by series for Collection, Site

select 
  collection,
  site,
  patient_id,
  series_instance_uid,
  dicom_file_type,
  modality,
  review_status,
  processing_status,
  count(distinct file_id) as num_files
from (
  select 
    distinct project_name as collection,
    site_name as site,
    patient_id,
    series_instance_uid,
    dicom_file_type,
    modality,
    review_status,
    processing_status,
    visibility,
    file_id
  from 
    dicom_file natural join 
    file_series natural join 
    file_patient natural join
    ctp_file natural join 
  (
    select file_id, review_status, processing_status
    from
      image_equivalence_class_input_image natural join
      image_equivalence_class join
      ctp_file using(file_id)
    where
      series_instance_uid = ?
  ) as foo
) as foo
where
  review_status != 'Good' and
  review_status != 'PassThrough'
group by
  collection,
  site,
  patient_id,
  series_instance_uid,
  dicom_file_type,
  modality,
  review_status,
  processing_status
