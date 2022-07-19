-- Name: InsertTempMprSlice
-- Schema: posda_files
-- Columns: []
-- Args: ['temp_mpr_volume_id', 'temp_mpr_slice_offset', 'temp_mpr_gray_file_id', 'temp_mpr_jpeg_file_id']
-- Tags: ['TempMprVolume']
-- Description: Create a row in temp_mpr_slice
-- 

insert into temp_mpr_slice(
  temp_mpr_volume_id,
  temp_mpr_slice_offset,
  temp_mpr_gray_file_id,
  temp_mpr_jpeg_file_id
) values (
  ?,?,?,
  ?
)
