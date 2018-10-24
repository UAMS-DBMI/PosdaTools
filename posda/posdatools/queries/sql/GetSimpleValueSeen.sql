-- Name: GetSimpleValueSeen
-- Schema: posda_phi_simple
-- Columns: ['id']
-- Args: ['value']
-- Tags: ['used_in_simple_phi', 'NotInteractive', 'non_dicom_phi']
-- Description: Get value seen if exists

select
  value_seen_id as id
from 
  value_seen
where
  value = ?