-- Name: SeriesWithDupSopsInTimepoint
-- Schema: posda_files
-- Columns: ['patient_id', 'study_instance_uid', 'series_instance_uid', 'collection', 'site', 'visibility', 'modality', 'type', 'num_files', 'num_sops']
-- Args: ['activity_timepoint_id']
-- Tags: ['compare_series']
-- Description: Get Distinct SOPs in Series with number files
-- Only visible filess
-- 

select 
  patient_id, study_instance_uid, series_instance_uid,
 collection, site, modality,
  type, num_files, num_sops
from (
select 
  patient_id, study_instance_uid, series_instance_uid, 
  project_name as collection, site_name as site, visibility, modality,
  dicom_file_type as type, count(distinct file_id) as num_files,
  count(distinct sop_instance_uid) as num_sops
from
  file_patient natural join file_study natural join file_series natural join file_sop_common
  natural join dicom_file
  natural left join ctp_file
where file_id in (
  select file_id from activity_timepoint natural join activity_timepoint_file where activity_timepoint_id = ?)
group by patient_id, study_instance_uid, series_instance_uid, collection,
  site, visibility, modality, dicom_file_type
order by series_instance_uid
)as foo
where num_sops != num_files