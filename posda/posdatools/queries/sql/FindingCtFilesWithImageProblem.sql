-- Name: FindingCtFilesWithImageProblem
-- Schema: posda_files
-- Columns: ['file_id', 'path']
-- Args: []
-- Tags: ['Exceptional-Responders_NCI_Oct2018_curation']
-- Description: Find files which have unique_pixel_data_id but no image_id, then find out where the hell they came from

select distinct file_id, root_path || '/' || rel_path as path
from (
  select file_id, image_id 
  from file natural left join file_image
  where file_id in (
    select
       distinct file_id from file_import natural join import_event
       natural join ctp_file natural join file_series
    where import_time > '2018-09-17' and visibility is null and
      project_name = 'Exceptional-Responders' and modality = 'CT'
  )
) as foo natural join file_location natural join file_storage_root
where image_id is null
