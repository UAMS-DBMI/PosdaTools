-- Name: GetPrivateKb
-- Schema: posda_private_tag
-- Columns: ['sig', 'owned_by', 'grp', 'ele', 'vr', 'vm', 'name']
-- Args: []
-- Tags: ['private_tags']
-- Description: Get the relevant features of a private tag by signature
-- Used in DispositionReport.pl - not for interactive use
--

select
pt_signature as sig, pt_owner as owned_by, pt_group as grp,
pt_element as ele, pt_consensus_vr as vr,
pt_consensus_vm as vm, pt_consensus_name as name
from pt
where not pt_is_specific_to_block