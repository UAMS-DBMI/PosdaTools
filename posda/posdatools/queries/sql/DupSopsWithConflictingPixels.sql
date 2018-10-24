-- Name: DupSopsWithConflictingPixels
-- Schema: posda_files
-- Columns: ['sop_instance_uid', 'count']
-- Args: []
-- Tags: ['pix_data_dups']
-- Description: Find list of series with SOP with duplicate pixel data

select distinct sop_instance_uid, count
  from (
    select
      distinct sop_instance_uid, count(*)
    from (
      select
        sop_instance_uid, unique_pixel_data.digest as pixel_digest
      from
        file_sop_common natural join file natural join file_image join
        image using (image_id) join unique_pixel_data using (unique_pixel_data_id)
    )as foo group by sop_instance_uid
  ) as foo where count > 1