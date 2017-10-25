-- Name: FirstFileForSopPosda
-- Schema: posda_files
-- Columns: ['path', 'modality']
-- Args: ['sop_instance_uid']
-- Tags: ['by_series', 'UsedInPhiSeriesScan']
-- Description: First files in series in Posda
-- 

select
  root_path || '/' || rel_path as path,
  modality
from 
  file_location natural join file_storage_root
  natural join file_sop_common
  natural join file_series
  natural join ctp_file
where
  sop_instance_uid = ? and visibility is null
limit 1