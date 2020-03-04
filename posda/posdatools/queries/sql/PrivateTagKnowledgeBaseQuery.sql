-- Name: PrivateTagKnowledgeBaseQuery
-- Schema: posda_private_tag
-- Columns: ['pt_id', 'pt_signature', 'pt_short_signature', 'pt_owner', 'pt_group', 'pr_element', 'pt_is_specific_to_block', 'pt_specific_block', 'pt_consensus_vr', 'pt_consensus_vm', 'pt_consensus_name', 'pt_consensus_disposition', 'pt_consensus_description']
-- Args: ['pt_signature']
-- Tags: ['DispositionReport', 'NotInteractive']
-- Description: Get the relevant features of a private tag by signature
-- Used in DispositionReport.pl - not for interactive use
--

select
 pt_id,
 pt_signature,
 pt_short_signature,
 pt_owner,
 pt_group,
 pt_element,
 pt_is_specific_to_block,
 pt_specific_block,
 pt_consensus_vr,
 pt_consensus_vm,
 pt_consensus_name,
 pt_consensus_disposition,
 pt_consensus_description
from pt
where pt_signature = ?
