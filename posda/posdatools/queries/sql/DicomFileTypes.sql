-- Name: DicomFileTypes
-- Schema: posda_files
-- Columns: ['dicom_file_type', 'count']
-- Args: []
-- Tags: ['find_series', 'dicom_file_type']
-- Description: List of Dicom File Types with count of files in Posda
-- 

select 
  distinct dicom_file_type, count(distinct file_id)
from
  dicom_file natural join ctp_file
group by dicom_file_type
order by count desc