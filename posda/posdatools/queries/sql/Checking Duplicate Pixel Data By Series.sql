-- Name: Checking Duplicate Pixel Data By Series
-- Schema: posda_files
-- Columns: ['collection', 'site', 'patient_id', 'dicom_file_type', 'pixel_data_digest', 'sop_instance_uid']
-- Args: ['series_instance_uid']
-- Tags: ['CPTAC Bolus September 2018']
-- Description: Get the list of files by sop, excluding base series

select 
  distinct project_name as collection, site_name as site, patient_id,
  dicom_file_type, pixel_data_digest, sop_instance_uid
from
  file_series natural join file_patient natural join ctp_file natural join
  file_sop_common natural join dicom_file
where pixel_data_digest in (
  select
    distinct pixel_data_digest
  from
    file_series natural join ctp_file natural join dicom_file
  where 
    series_instance_uid = ?
  )
order by pixel_data_digest