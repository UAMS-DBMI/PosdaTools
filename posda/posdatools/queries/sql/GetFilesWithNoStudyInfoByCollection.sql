-- Name: GetFilesWithNoStudyInfoByCollection
-- Schema: posda_files
-- Columns: ['file_id', 'path']
-- Args: ['collection']
-- Tags: ['reimport_queries', 'dicom_file_type']
-- Description: Get file path from id

select
  file_id,
  root_path || '/' || rel_path as path
from
  file_storage_root natural join file_location
where file_id in (
select 
  distinct file_id
from 
 ctp_file c
where
  project_name = ? and 
  visibility is null and 
  not exists (
    select
      file_id 
    from
      file_study s 
    where
      s.file_id = c.file_id
  )
)