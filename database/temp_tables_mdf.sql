create table temp_mpr_volume(
  temp_mpr_volume_id serial,
  temp_mpr_volume_type text, -- "Axial", "Sagittal", or "Coronal"
                             -- Note: "Axial" implies (1,0,0,0,1,0) iop
                             --       "Coronal" implies (1,0,0,0,0,-1) iop
                             --       "Sagittal" implies (0,1,0,0,0,-1) iop
  temp_mpr_volume_w_c text,  -- Something that will bring out the surface of the body
  temp_mpr_volume_w_w text,  -- soft tissue (50,350) or (-81, 397) seems to work well
  temp_mpr_volume_position_x float not null,
  temp_mpr_volume_position_y float not null,
  temp_mpr_volume_position_z float not null,
  temp_mpr_volume_rows integer not null,
  temp_mpr_volume_cols integer not null,
  temp_mpr_volume_description text,
  temp_mpr_volme_creation_time timestamp,
  temp_mpr_volume_creator text,
  row_spc float not null,
  col_spc float not null
);
create table temp_mpr_slice(
  temp_mpr_volume_id integer not null,
  temp_mpr_slice_offset float not null, -- e.g Z-offset for Axial
                                        -- for Y-offset for Coronal
                                        -- for X-offset for Sagittal
  temp_mpr_gray_file_id integer,  -- one of gray_file_id and jpeg_file_id
  temp_mpr_jpeg_file_id integer   -- must be populated (both may be populated)
                                  -- gray_file_id must be populated if volume
                                  -- is to be subsampled or mpr'ed
                                  -- jpeg_file_id must be populated if volume
                                  -- is to be displayed
);
