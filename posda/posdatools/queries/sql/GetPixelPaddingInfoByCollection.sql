-- Name: GetPixelPaddingInfoByCollection
-- Schema: posda_files
-- Columns: ['modality', 'pixel_pad', 'slope', 'intercept', 'manufacturer', 'image_type', 'signed', 'count']
-- Args: ['collection']
-- Tags: ['PixelPadding']
-- Description: Get Pixel Padding Summary Info
-- 

select
  distinct modality, pixel_pad, slope, intercept, manufacturer, 
  image_type, pixel_representation as signed, count(*)
from                                           
  file_series natural join file_equipment natural join ctp_file natural join
  file_slope_intercept natural join slope_intercept natural join file_image natural join image
where                                                 
  modality = 'CT' and project_name = ?
group by 
  modality, pixel_pad, slope, intercept, manufacturer, image_type, signed
