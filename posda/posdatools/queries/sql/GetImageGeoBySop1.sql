-- Name: GetImageGeoBySop1
-- Schema: posda_files
-- Columns: ['iop', 'ipp', 'for_uid', 'series_instance_uid']
-- Args: ['sop_instance_uid']
-- Tags: ['LinkageChecks', 'BySopInstance']
-- Description: Get Geometric Information by Sop Instance UID from posda

select
  iop, ipp, for_uid, series_instance_uid
from
  image_geometry natural join file_image_geometry natural join file_series
where
  file_id in 
  (
    select 
      file_id 
    from
      file_sop_common natural join ctp_file
    where
      sop_instance_uid = ?
  )