-- Name: InsertTempMprVolume
-- Schema: posda_files
-- Columns: []
-- Args: ['temp_mpr_volume_type', 'temp_mpr_volume_w_c', 'temp_mpr_volume_w_w', 'temp_mpr_volume_position_x', 'temp_mpr_volume_position_y', 'temp_mpr_volume_position_z', 'temp_mpr_volume_rows', 'temp_mpr_volume_cols', 'temp_mpr_volume_description', 'temp_mpr_volume_creator']
-- Tags: ['TempMprVolume']
-- Description: Create a row in temp_mpr_volume
-- 

insert into temp_mpr_volume(
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
  temp_mpr_volume_creator
) values (
  ?,?,?,
  ?,?,?,
  ?,?,?,
  now(),?
)