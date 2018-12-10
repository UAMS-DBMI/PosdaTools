-- Name: GetElemenSeenIdBySigVr
-- Schema: posda_phi_simple
-- Columns: ['element_seen_id']
-- Args: ['element_sig_pattern', 'vr']
-- Tags: ['NotInteractive', 'ElementDisposition', 'phi_maint']
-- Description: Get List of Private Elements By Disposition

select element_seen_id
from element_seen
where element_sig_pattern = ? and vr = ?