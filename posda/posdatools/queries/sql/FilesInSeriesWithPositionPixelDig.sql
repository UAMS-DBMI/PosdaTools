-- Name: FilesInSeriesWithPositionPixelDig
-- Schema: posda_files
-- Columns: ['file_id', 'image_id', 'unique_pixel_data_id', 'ipp', 'instance_number']
-- Args: ['series_instance_uid']
-- Tags: ['SeriesSendEvent', 'by_series', 'find_files', 'for_send']
-- Description: Get file info from series for comparison of dup_series

select
  distinct file_id, image_id, unique_pixel_data_id, ipp, instance_number
from
  file_series natural join file_image natural join ctp_file natural join file_sop_common
  natural join image natural join image_geometry
where
  series_instance_uid = ?
