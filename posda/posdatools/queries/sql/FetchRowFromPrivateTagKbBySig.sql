-- Name: FetchRowFromPrivateTagKbBySig
-- Schema: posda_private_tag
-- Columns: ['pt_owner', 'pt_group', 'pt_element', 'pt_consensus_vr', 'pt_consensus_vm', 'pt_consensus_name']
-- Args: ['pt_signature']
-- Tags: ['Phi maint']
-- Description: Get an existing row in the pt table by signature
--

select  
 pt_owner, pt_group, pt_element, pt_consensus_vr, pt_consensus_vm, pt_consensus_name
from pt
where pt_signature = ?