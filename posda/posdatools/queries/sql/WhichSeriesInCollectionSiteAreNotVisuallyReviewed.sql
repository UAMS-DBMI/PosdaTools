-- Name: WhichSeriesInCollectionSiteAreNotVisuallyReviewed
-- Schema: posda_files
-- Columns: ['collection', 'site', 'patient_id', 'series_instance_uid', 'dicom_file_type', 'modality', 'review_status', 'num_files']
-- Args: ['collection', 'site']
-- Tags: ['find_series', 'equivalence_classes', 'consistency', 'visual_review_results', 'hide_events']
-- Description: Get visual review status report by series for Collection, Site

select 
  distinct project_name as collection,
  site_name as site,
  patient_id,
   series_instance_uid,
  dicom_file_type,
  modality,
  'Not submitted for review' as review_status,
  count(distinct file_id) as num_files
from 
  dicom_file natural join 
  file_series ser natural join
  file_patient natural join  
  ctp_file
where
  project_name = ? and
  site_name = ?
  and visibility is null
  and not exists (
    select * from image_equivalence_class iec
    where iec.series_instance_uid = ser.series_instance_uid
  )
group by
  collection, site, patient_id,
  series_instance_uid,
  dicom_file_type,
  modality,
  review_status
order by
  series_instance_uid