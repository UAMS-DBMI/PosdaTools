-- Name: SRGetPathSeen
-- Schema: posda_phi_simple
-- Columns: ['sr_path_seen_id']
-- Args: ['path_sig_pattern']
-- Tags: ['Structured Report']
-- Description: Check to see if the given path haas been seen before
--

select
  sr_path_seen_id
from
  sr_path_seen
where
  path_sig_pattern = ?;
