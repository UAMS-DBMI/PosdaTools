-- Name: DistinctSopsInSeriesForCompare
-- Schema: posda_files
-- Columns: ['sop_instance_uid', 'dicom_file_type', 'sop_class_uid', 'modality', 'file_id']
-- Args: ['series_instance_uid']
-- Tags: ['compare_series']
-- Description: Get Distinct SOPs in Series with number files
-- Only visible filess
-- 

select distinct sop_instance_uid, dicom_file_type, sop_class_uid, modality, file_id
from file_sop_common natural join dicom_file  natural join file_series
where file_id in (
  select
    distinct file_id
  from
    file_series natural join ctp_file
  where
    series_instance_uid = ?
)
