select distinct
    root_path || '/' || rel_path as file, 
    file_offset, 
    size, 
    bits_stored, 
    bits_allocated, 
    pixel_representation, 
    pixel_columns, 
    pixel_rows, 
    photometric_interpretation,

    slope,
    intercept,

    window_width,
    window_center,
    pixel_pad,

	project_name,
	site_name,
	sop_instance_uid,
	series_instance_uid

from
    file_image
    natural join image 
    natural join unique_pixel_data 
    natural join pixel_location
    natural join file_location 
    natural join file_storage_root
    natural join file_equipment
	natural join file_sop_common
	natural join file_series
	natural join ctp_file

    natural left join file_slope_intercept
    natural left join slope_intercept

    natural left join file_win_lev
    natural left join window_level

where file_image.file_id = 3367285
