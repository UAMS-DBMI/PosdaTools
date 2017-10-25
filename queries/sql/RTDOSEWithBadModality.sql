-- Name: RTDOSEWithBadModality
-- Schema: posda_files
-- Columns: ['collection', 'site', 'patient_id', 'series_instance_uid', 'modality', 'dicom_file_type', 'num_files']
-- Args: []
-- Tags: ['by_series', 'consistency', 'for_bill_series_consistency']
-- Description: Check a Series for Consistency
-- 

select distinct
  project_name as collection,
  site_name as site, 
  patient_id,
  series_instance_uid,
  modality,
  dicom_file_type,
  count(distinct file_id) as num_files
from
  file_series natural join ctp_file natural join file_patient
  natural join dicom_file
where 
  dicom_file_type = 'RT Dose Storage' and 
  visibility is null and
  modality != 'RTDOSE'
group by
  collection, site, patient_id, series_instance_uid, modality, dicom_file_type
order by
  collection, site, patient_id
