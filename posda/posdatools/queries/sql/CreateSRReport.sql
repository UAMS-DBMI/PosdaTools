-- Name: CreateSRReport
-- Schema: posda_phi_simple
-- Columns: ['element','q_value', 'path_sig_pattern']
-- Args: ['sr_phi_scan_instance_id']
-- Tags: ['Structured Report']
-- Description: Create a PHI report for an SR
--

select
  distinct '<' || tag || '>' as element,
 '<' || value || '>' as q_value,
 path_sig_pattern
from sr_path_value_occurance natural join sr_path_seen natural join value_seen
where
  sr_phi_scan_instance_id = ?
group by tag, value, path_sig_pattern
order by element, q_value;
