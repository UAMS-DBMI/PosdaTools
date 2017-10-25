-- Name: CreateSimpleElementSeen
-- Schema: posda_phi_simple
-- Columns: []
-- Args: ['element_sig_pattern', 'vr']
-- Tags: ['NotInteractive', 'used_in_simple_phi_maint', 'used_in_phi_maint']
-- Description: Create a new Simple PHI scan

insert into 
   element_seen(element_sig_pattern, vr)
   values(?, ?)
