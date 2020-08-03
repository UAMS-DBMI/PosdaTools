-- Name: BackupPrivateTagKnowledgeBase
-- Schema: posda_private_tag
-- Columns: ['pt_signature', 'pt_owner', 'pt_group', 'pt_element', 'pt_consensus_vr', 'pt_consensus_vm', 'pt_consensus_name', 'pt_consensus_description', 'pt_consensus_disposition']
-- Args: []
-- Tags: ['DispositionReport', 'NotInteractive']
-- Description: Get the relevant features of a private tag by signature
-- Used in DispositionReport.pl - not for interactive use
--

select
  pt_signature, pt_owner, pt_group, pt_element, pt_consensus_vr, pt_consensus_vm, pt_consensus_name,
  pt_consensus_description, pt_consensus_disposition
from pt
where not pt_is_specific_to_block;
