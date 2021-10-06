-- Name: SeriesReportTimepointWithFileType
-- Schema: posda_files
-- Columns: ['file_id', 'modality', 'dicom_file_type', 'inst_num', 'iop', 'ipp', 'sop_instance_uid']
-- Args: ['series_instance_uid', 'activity_timepoint_id']
-- Tags: ['by_series_instance_uid', 'duplicates', 'posda_files', 'sops', 'series_report']
-- Description: Get Distinct SOPs in Series with number files
-- Only files in specified timepoint (visible or not)
-- 

select 
  distinct file_id, sop_instance_uid, modality, dicom_file_type, cast(instance_number as int) inst_num, iop, ipp
from 
  file_series natural join file_sop_common natural join dicom_file
  left join file_image_geometry using(file_id) 
  left join image_geometry using(image_geometry_id)
where file_id in (
  select 
  file_id from file_series natural join activity_timepoint_file
  where series_instance_uid = ? and activity_timepoint_id = ?
) order by inst_num;