-- Name: GetFileIdPixDigInstNumBySeriesInTp
-- Schema: posda_files
-- Columns: ['file_id', 'pixel_data_digest', 'instance_number', 'modality']
-- Args: ['activity_timepoint_id', 'series_instance_uid']
-- Tags: ['nifti']
-- Description: Get the ImportEventId of an import based on import_comment
-- 

select
  file_id, pixel_data_digest, instance_number, modality
from
  dicom_file natural join activity_timepoint_file natural join file_series natural join file_sop_common,
  file_nifti_defacing fnd
where
  activity_timepoint_id = ? and
  series_instance_uid = ? and
  file_id = fnd.from_nifti_file and
  fnd.three_d_rendered_face is not null