-- Name: SeriesReportVisible
-- Schema: posda_files
-- Columns: ['file_id', 'modality', 'inst_num', 'iop', 'ipp', 'sop_instance_uid']
-- Args: ['series_instance_uid']
-- Tags: ['by_series_instance_uid', 'duplicates', 'posda_files', 'sops', 'series_report']
-- Description: Get Distinct SOPs in Series with number files
-- Only visible filess
--

select 
  distinct file_id, sop_instance_uid, modality, cast(instance_number as int) inst_num, iop, ipp
from 
  file_series natural join file_sop_common 
  left join file_image_geometry using(file_id) 
  left join image_geometry using(image_geometry_id)
where file_id in (
  select 
  file_id from file_series natural join ctp_file
  where series_instance_uid = ?
) order by inst_num;