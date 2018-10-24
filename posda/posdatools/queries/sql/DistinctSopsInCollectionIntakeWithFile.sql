-- Name: DistinctSopsInCollectionIntakeWithFile
-- Schema: intake
-- Columns: ['sop_instance_uid', 'dicom_file_uri']
-- Args: ['collection']
-- Tags: ['by_collection', 'files', 'intake', 'sops']
-- Description: Get Distinct SOPs in Collection with number files
-- Only visible files
-- 

select
  distinct i.sop_instance_uid, i.dicom_file_uri
from
  general_image i,
  trial_data_provenance tdp
where
  i.trial_dp_pk_id = tdp.trial_dp_pk_id and
  tdp.project = ?
order by sop_instance_uid
