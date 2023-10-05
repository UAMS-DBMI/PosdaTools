-- Name: DicomFileTypesNotProcessed
-- Schema: posda_files
-- Columns: ['dicom_file_type', 'count']
-- Args: []
-- Tags: ['dicom_file_type']
-- Description: List of Distinct Dicom File Types which have unprocessed DICOM files
-- 

select 
  distinct dicom_file_type, count(distinct file_id)
from
  dicom_file d natural join ctp_file
where
  not exists (
    select file_id 
    from file_series s
    where s.file_id = d.file_id
  )
group by dicom_file_type