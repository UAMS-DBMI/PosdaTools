-- Name: ListSrPublic
-- Schema: public
-- Columns: ['collection', 'site', 'patient_id', 'dicom_file_uri']
-- Args: ['collection_like']
-- Tags: ['meta', 'test', 'hello', 'query_tabs', 'bills_test', 'view_structured_reports']
-- Description: Add a filter to a tab

select 
  tdp.project as collection, dp_site_name as site, i.patient_id, dicom_file_uri 
from
  general_image i, general_series s, trial_data_provenance tdp
where
  tdp.trial_dp_pk_id = i.trial_dp_pk_id and s.modality = 'SR' and s.general_series_pk_id = i.general_series_pk_id
  and tdp.project like ?