-- Name: DistinctSopsInSeriesForComparePublic
-- Schema: public
-- Columns: ['sop_instance_uid', 'sop_class_uid', 'modality', 'count']
-- Args: ['series_instance_uid']
-- Tags: ['compare_series']
-- Description: Get Distinct SOPs in Series with number files
-- Only visible filess
-- 

select 
  sop_instance_uid, sop_class_uid, i.patient_id, modality
from
  general_image i, general_series s
where
  s.series_instance_uid = i.series_instance_uid and s.series_instance_uid = ?