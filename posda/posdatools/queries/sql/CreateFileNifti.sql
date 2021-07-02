-- Name: CreateFileNifti
-- Schema: posda_files
-- Columns: []
-- Args: ['file_id', 'magic', 'is_zipped', 'descrip', 'aux_file', 'bitpix', 'datatype', 'num_dim', 'dim1', 'dim2', 'dim3', 'dim4', 'dim5', 'dim6', 'dim7', 'pixdim_0', 'pixdim_1', 'pixdim_2', 'pixdim_3', 'pixdim_4', 'pixdim_5', 'pixdim_6', 'pixdim_7', 'intent_code', 'intent_name', 'intent_p1', 'intent_p2', 'intent_p3', 'cal_max', 'cal_min', 'scl_slope', 'scl_inter', 'slice_start', 'slice_end', 'slice_code', 'sform_code', 's_row_x_0', 's_row_x_1', 's_row_x_2', 's_row_x_3', 's_row_y_0', 's_row_y_1', 's_row_y_2', 's_row_y_3', 's_row_z_0', 's_row_z_1', 's_row_z_2', 's_row_z_3', 'xyzt_units', 'qform_code', 'quatern_b', 'quatern_c', 'quatern_d', 'q_offset_x', 'q_offset_y', 'q_offset_z', 'vox_offset']
-- Tags: ['nifti']
-- Description: Create row in file_nifti table
-- 

insert into file_nifti(
  file_id, magic, is_zipped, descrip, aux_file,
  bitpix , datatype, num_dim, dim1, dim2,
  dim3, dim4, dim5, dim6, dim7,
  pixdim_0, pixdim_1, pixdim_2, pixdim_3, pixdim_4,
  pixdim_5, pixdim_6, pixdim_7, intent_code, intent_name,
  intent_p1, intent_p2, intent_p3, cal_max, cal_min,
  scl_slope, scl_inter, slice_start, slice_end, slice_code,
  sform_code, s_row_x_0, s_row_x_1, s_row_x_2, s_row_x_3,
  s_row_y_0, s_row_y_1, s_row_y_2, s_row_y_3,  s_row_z_0, 
  s_row_z_1, s_row_z_2, s_row_z_3, xyzt_units, qform_code,
  quatern_b, quatern_c, quatern_d, q_offset_x, q_offset_y,
  q_offset_z, vox_offset
) values (
  ?, ?, ?, ?, ?,
  ?, ?, ?, ?, ?,
  ?, ?, ?, ?, ?,
  ?, ?, ?, ?, ?,
  ?, ?, ?, ?, ?,
  ?, ?, ?, ?, ?,
  ?, ?, ?, ?, ?,
  ?, ?, ?, ?, ?,
  ?, ?, ?, ?, ?,
  ?, ?, ?, ?, ?,
  ?, ?, ?, ?, ?,
  ?, ?
)