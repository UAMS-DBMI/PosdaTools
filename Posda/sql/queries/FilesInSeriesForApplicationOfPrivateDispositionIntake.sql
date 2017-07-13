-- Name: FilesInSeriesForApplicationOfPrivateDispositionIntake
-- Schema: intake
-- Columns: ['path', 'sop_instance_uid', 'modality']
-- Args: ['series_instance_uid']
-- Tags: ['find_files', 'ApplyDisposition', 'intake']
-- Description: Get path, sop_instance_uid, and modality for all files in a series
-- 

select
  i.dicom_file_uri as path, i.sop_instance_uid, s.modality
from
  general_image i, general_series s
where
  i.general_series_pk_id = s.general_series_pk_id and
  s.series_instance_uid = ?