-- Name: GetFilesWithSeriesButNoStudy
-- Schema: posda_files
-- Columns: ['file_id']
-- Args: ['collection']
-- Tags: ['posda_db_populate', 'dicom_file_type']
-- Description: Add a filter to a tab

select 
  distinct file_id
from
  file_series se natural join ctp_file
where
  not exists (
    select file_id from file_study st where st.file_id = se.file_id
  ) and
  visibility is null
  and project_name = ?