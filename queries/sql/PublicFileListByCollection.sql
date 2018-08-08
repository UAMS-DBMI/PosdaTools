-- Name: PublicFileListByCollection
-- Schema: public
-- Columns: ['collection', 'patient_id', 'series_instance_uid', 'dicom_file_uri']
-- Args: ['collection']
-- Tags: ['by_collection', 'find_series', 'search_series', 'send_series', 'phi_simple', 'simple_phi']
-- Description: Get Series in A Collection
-- 

select 
  distinct tdp.project as collection, s.patient_id, s.series_instance_uid, dicom_file_uri
from
  trial_data_provenance tdp, general_image i, general_series s
where
  s.general_series_pk_id = i.general_series_pk_id and i.trial_dp_pk_id = tdp.trial_dp_pk_id
  and tdp.project = ?