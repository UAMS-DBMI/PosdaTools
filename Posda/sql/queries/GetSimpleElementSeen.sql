-- Name: GetSimpleElementSeen
-- Schema: posda_phi_simple
-- Columns: ['id']
-- Args: ['element_sig_pattern', 'vr']
-- Tags: ['used_in_simple_phi', 'NotInteractive']
-- Description: Get an element_seen row by element, vr (if present)

select
  element_seen_id as id
from 
  element_seen
where
  element_sig_pattern = ? and
  vr = ?