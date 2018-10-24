-- Name: files_to_copy_from_public
-- Schema: public
-- Columns: ['site', 'sop_instance_uid', 'dicom_file_uri']
-- Args: ['collection', 'site']
-- Tags: ['meta', 'test', 'hello', 'query_tabs', 'bills_test']
-- Description: Files to copy from Public (to Posda)

select 
  dp_site_name as site, 
  sop_instance_uid, 
  dicom_file_uri 
from general_image, trial_data_provenance
where 
  general_image.trial_dp_pk_id = trial_data_provenance.trial_dp_pk_id and 
  trial_data_provenance.project = ? and
  trial_data_provenance.dp_site_name = ?