-- Name: GetTempMprSliceInfo
-- Schema: posda_files
-- Columns: ['temp_mpr_slice_offset', 'temp_mpr_gray_file_id', 'temp_mpr_jpeg_file_id']
-- Args: ['temp_mpr_volume_id']
-- Tags: ['TempMprVolume']
-- Description: Get all the slices for a temp_mpr_volume based on its id
-- 

select
   temp_mpr_slice_offset,
   temp_mpr_gray_file_id,
   temp_mpr_jpeg_file_id
from 
  temp_mpr_slice
where
  temp_mpr_volume_id = ?
order by temp_mpr_slice_offset desc
