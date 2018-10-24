-- Name: KnownBlankImagesInSeries
-- Schema: posda_files
-- Columns: ['pixel_digest', 'num_files']
-- Args: ['series_instance_uid']
-- Tags: ['by_series']
-- Description: List of SOPs, files, and import times in a series
-- 

select distinct pixel_digest, count(*) as num_files from (
  select file_id, digest as pixel_digest
  from
    file_image join image using (image_id) join unique_pixel_data using (unique_pixel_data_id)
  where file_id in (select file_id from file_series natural join ctp_file where series_instance_uid = ?)
)
as foo group by pixel_digest