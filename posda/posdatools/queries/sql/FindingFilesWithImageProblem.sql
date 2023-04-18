-- Name: FindingFilesWithImageProblem
-- Schema: posda_files
-- Columns: ['file_id', 'path']
-- Args: []
-- Tags: ['Exceptional-Responders_NCI_Oct2018_curation']
-- Description: Find files which have unique_pixel_data_id but no image_id, then find out where the hell they came from

select file_id, root_path || '/' || rel_path as path
from (
  select file_id, image_id 
  from pixel_location left join image using(unique_pixel_data_id)
  where file_id in (
    select
       distinct file_id from file_import natural join import_event natural join dicom_file
    where import_time > '2018-09-17'
  )
) as foo natural join ctp_file natural join file_location natural join file_storage_root
where image_id is null
