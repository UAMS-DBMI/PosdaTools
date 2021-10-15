-- Name: GetNiftiConversionNotesBySeries
-- Schema: posda_files
-- Columns: ['note']
-- Args: ['series_instance_uid']
-- Tags: ['Nifti']
-- Description: Get Nifti Conversion Notes by Series Instance UID
-- 

select
  note
from nifti_conversion_notes
where
  nifti_file_from_series_id = (
    select nifti_file_from_series_id
    from nifti_file_from_series
    where series_instance_uid = ?
  )