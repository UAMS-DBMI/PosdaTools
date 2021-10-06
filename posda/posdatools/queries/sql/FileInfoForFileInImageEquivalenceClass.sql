-- Name: FileInfoForFileInImageEquivalenceClass
-- Schema: posda_files
-- Columns: ['file_id', 'series_instance_uid', 'study_instance_uid', 'sop_instance_uid', 'instance_number', 'modality', 'dicom_file_type', 'for_uid', 'iop', 'ipp', 'pixel_data_digest', 'samples_per_pixel', 'pixel_spacing', 'photometric_interpretation', 'pixel_rows', 'pixel_columns', 'bits_allocated', 'bits_stored', 'high_bit', 'pixel_representation', 'planar_configuration', 'number_of_frames']
-- Args: ['file_id']
-- Tags: ['activity_timepoint', 'series_report']
-- Description: Get Distinct SOPs in Series with number files
-- Only visible filess
-- 

select
  distinct file_id,
  series_instance_uid,
  study_instance_uid,
  sop_instance_uid,
  cast (instance_number as integer) as instance_number,
  modality,
  dicom_file_type,
  for_uid, iop, ipp, 
  pixel_data_digest,
  samples_per_pixel,
  pixel_spacing,
  photometric_interpretation,
  pixel_rows,
  pixel_columns,
  bits_allocated,
  bits_stored,
  high_bit,
  pixel_representation,
  planar_configuration,
  number_of_frames
from
  dicom_file
  natural join file_series
  natural join file_study
  natural join file_sop_common
  join file_image using(file_id)
  join image using(image_id)
  left join file_image_geometry using(file_id) 
  left join image_geometry using(image_geometry_id)
where file_id = ?
order by instance_number