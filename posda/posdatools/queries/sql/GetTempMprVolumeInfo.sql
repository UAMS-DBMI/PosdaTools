-- Name: GetTempMprVolumeInfo
-- Schema: posda_files
-- Columns: ['temp_mpr_volume_id', 'temp_mpr_volume_type', 'temp_mpr_volume_w_c', 'temp_mpr_volume_w_w', 'temp_mpr_volume_position_x', 'temp_mpr_volume_position_y', 'temp_mpr_volume_position_z', 'temp_mpr_volume_rows', 'temp_mpr_volume_cols', 'temp_mpr_volume_description', 'temp_mpr_volme_creation_time', 'temp_mpr_volume_creator', 'row_spc', 'col_spc']
-- Args: ['temp_mpr_volume_id']
-- Tags: ['TempMprVolume']
-- Description: Get all the data from a temp_mpr_volume row based on its id
-- 

select
   temp_mpr_volume_id,
   temp_mpr_volume_type,
   temp_mpr_volume_w_c,
   temp_mpr_volume_w_w,
   temp_mpr_volume_position_x,
   temp_mpr_volume_position_y,
   temp_mpr_volume_position_z,
   temp_mpr_volume_rows,
   temp_mpr_volume_cols,
   temp_mpr_volume_description,
   temp_mpr_volme_creation_time,
   temp_mpr_volume_creator,
   row_spc,
   col_spc
from 
  temp_mpr_volume
where
  temp_mpr_volume_id = ?
