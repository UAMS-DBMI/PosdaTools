-- Name: GetBasicImageGeometry
-- Schema: posda_files
-- Columns: ['iop', 'ipp']
-- Args: ['series_instance_uid']
-- Tags: ['NotInteractive', 'used_in_import_edited_files', 'used_in_check_circular_view']
-- Description: Get file_id, and current visibility by digest
-- For use in scripts
-- Not really intended for interactive use
-- 

select
  iop, ipp
from
  file_series
  join file_image using (file_id)
  join image_geometry using (image_id)
where 
  series_instance_uid = ?