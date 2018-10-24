-- Name: DistinctSopsInCollectionSitePublicWithFile
-- Schema: public
-- Columns: ['sop_instance_uid', 'dicom_file_uri']
-- Args: ['collection', 'site']
-- Tags: ['by_collection', 'files', 'intake', 'sops', 'compare_collection_site']
-- Description: Get Distinct SOPs in Collection with number files
-- 

select
  distinct i.sop_instance_uid, i.dicom_file_uri
from
  general_image i,
  trial_data_provenance tdp
where
  i.trial_dp_pk_id = tdp.trial_dp_pk_id and
  tdp.project = ? and tdp.dp_site_name = ?
order by sop_instance_uid
