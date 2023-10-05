-- Name: DistinctSeriesByDicomFileType
-- Schema: posda_files
-- Columns: ['series_instance_uid', 'dicom_file_type', 'count']
-- Args: ['dicom_file_type']
-- Tags: ['find_series', 'dicom_file_type']
-- Description: List of Distinct Series By Dicom File Type
-- 

select 
  distinct series_instance_uid, dicom_file_type, count(distinct file_id)
from
  file_series natural join dicom_file natural join ctp_file
where
  dicom_file_type = ?
group by series_instance_uid, dicom_file_type