-- Name: CreateSRReport
-- Schema: posda_phi_simple
-- Columns: ['element','val_length','q_value', 'path_sig_pattern']
-- Args: ['sr_phi_scan_instance_id']
-- Tags: ['Structured Report']
-- Description: Create a PHI report for an SR
--

select
  distinct '<' || tag || '>' as element,
 length(value) as val_length,
 '<' || value || '>' as q_value,
 path_sig_pattern as description
from sr_path_value_occurance natural join sr_path_seen natural join value_seen
where
  sr_phi_scan_instance_id = ?
group by tag, value, path_sig_pattern
order by element, q_value;
