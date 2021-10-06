-- Name: VisibleNonDicomFilesByCollection
-- Schema: posda_files
-- Columns: ['file_id']
-- Args: ['collection']
-- Tags: ['ad_hoc queries']
-- Description: Visible DICOM files by collection
-- 

select
  distinct file_id
from
  non_dicom_file
where
  collection = ? and visibility is null
