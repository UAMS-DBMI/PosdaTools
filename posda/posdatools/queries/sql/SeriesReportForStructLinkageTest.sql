-- Name: SeriesReportForStructLinkageTest
-- Schema: posda_files
-- Columns: ['file_id', 'file_name', 'sop_instance_uid', 'sop_class_uid', 'study_instance_uid', 'series_instance_uid', 'for_uid', 'iop', 'ipp']
-- Args: ['series_instance_uid']
-- Tags: ['by_series_instance_uid', 'duplicates', 'posda_files', 'sops', 'series_report']
-- Description: Get Distinct SOPs in Series with number files
-- Only visible filess
-- 

select
  distinct file_id, (
    select root_path 
    from file_storage_root
    where file_storage_root.file_storage_root_id = file_location.file_storage_root_id
  ) || '/' || rel_path as file_name,
  sop_instance_uid, sop_class_uid,
  study_instance_uid, series_instance_uid,
  for_uid, iop, ipp
from
  file_location
  natural join file_series 
  natural join file_study
  natural join file_sop_common
  left join file_image_geometry using(file_id) 
  left join image_geometry using(image_geometry_id)
where file_id in (
  select file_id from file_series natural join ctp_file
  where series_instance_uid = ?
    and visibility is null
)