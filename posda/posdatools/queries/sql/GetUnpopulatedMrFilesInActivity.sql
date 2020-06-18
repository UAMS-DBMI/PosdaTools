-- Name: GetUnpopulatedMrFilesInActivity
-- Schema: posda_files
-- Columns: ['file_id', 'path']
-- Args: ['activity_id']
-- Tags: ['mr_images']
-- Description: Counts query by Collection, Site
--

select
  distinct file_id, root_path || '/' || rel_path as path
from 
  file_storage_root natural join file_location
where
  file_id in (
    select file_id from dicom_file d natural left join ctp_file
    where visibility is null and dicom_file_type = 'MR Image Storage'
    and not exists (
      select file_id from file_mr m where m.file_id = d.file_id
    )
    and exists (select file_id from activity_timepoint_file atp where
       atp.file_id = d.file_id and
       activity_timepoint_id = (
         select
           max(activity_timepoint_id) as activity_timepoint_id
         from activity_timepoint 
          where activity_id = ?
       )
    )
  )