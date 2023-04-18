-- Name: CollectionSiteWithDicomFileTypesNotProcessed
-- Schema: posda_files
-- Columns: ['collection', 'site', 'dicom_file_type', 'count']
-- Args: []
-- Tags: ['dicom_file_type']
-- Description: List of Distinct Collection, Site, Dicom File Types which have unprocessed DICOM files
-- 

select 
  distinct project_name as collection, site_name as site, dicom_file_type, count(distinct file_id)
from
  dicom_file d natural join ctp_file
where
  not exists (
    select file_id 
    from file_series s
    where s.file_id = d.file_id
  )
group by project_name, site_name, dicom_file_type