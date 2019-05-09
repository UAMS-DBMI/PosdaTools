-- Name: ImageFrameOfReferenceBySeriesPublic
-- Schema: public
-- Columns: ['for_uid', 'num_files']
-- Args: ['series_instance_uid']
-- Tags: ['Structure Sets', 'sops', 'LinkageChecks', 'struct_linkages']
-- Description: Get list of plan which reference unknown SOPs
-- 
-- 

select
  distinct frame_of_reference_uid as for_uid,
  count(distinct sop_instance_uid) as num_files
from
  general_image i, general_series s
where
  s.general_series_pk_id = i.general_series_pk_id and s.series_instance_uid = ?
group by frame_of_reference_uid;