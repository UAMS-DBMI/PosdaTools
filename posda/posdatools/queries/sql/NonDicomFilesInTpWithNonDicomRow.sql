-- Name: NonDicomFilesInTpWithNonDicomRow
-- Schema: posda_files
-- Columns: ['file_id', 'digest', 'file_type', 'non_dicom_file_type', 'non_dicom_subtype', 'subject', 'collection', 'site', 'date_last_categorized', 'path']
-- Args: ['activity_id']
-- Tags: ['non_dicom_extensions']
-- Description: All nonDICOM files bysubject in timepoint
-- 

select
  distinct nd.file_id, f.digest, f.file_type, 
  nd.file_type as non_dicom_file_type,
  nd.file_sub_type as non_dicom_subtype,
  nd.subject as subject,
  nd.collection,
  nd.site,
  nd.date_last_categorized,
  root_path || '/' || rel_path as path
from
  file f join non_dicom_file nd using (file_id)
  natural join activity_timepoint_file
  join file_location using(file_id)
  natural join file_storage_root
where
  activity_timepoint_id = (
    select max(activity_timepoint_id) as activity_timepoint_id
    from activity_timepoint
    where activity_id = ?
  )
