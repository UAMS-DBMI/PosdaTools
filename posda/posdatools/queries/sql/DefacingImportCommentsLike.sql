-- Name: DefacingImportCommentsLike
-- Schema: posda_files
-- Columns: ['import_event_comment']
-- Args: ['import_event_comment_like']
-- Tags: ['nifti']
-- Description: Find matching import_event_comments in defaced_dicom_series
-- 

select
  import_event_comment
from
  defaced_dicom_series
where
  import_event_comment like ?