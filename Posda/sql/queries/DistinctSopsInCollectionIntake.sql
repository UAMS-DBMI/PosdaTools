-- Name: DistinctSopsInCollectionIntake
-- Schema: intake
-- Columns: ['sop_instance_uid']
-- Args: ['collection']
-- Tags: ['by_collection', 'intake', 'sops']
-- Description: Get Distinct SOPs in Collection with number files
-- Only visible files
-- 

select
  distinct i.sop_instance_uid
from
  general_image i,
  trial_data_provenance tdp
where
  i.trial_dp_pk_id = tdp.trial_dp_pk_id and
  tdp.project = ?
order by sop_instance_uid
