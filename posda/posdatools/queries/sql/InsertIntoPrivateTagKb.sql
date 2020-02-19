-- Name: InsertIntoPrivateTagKb
-- Schema: posda_private_tag
-- Columns: []
-- Args: ['pt_signature', 'pt_short_signature', 'pt_owner', 'pt_group', 'pt_element', 'pt_consensus_vr', 'pt_consensus_vm', 'pt_consensus_name', 'pt_consensus_disposition', 'pt_consensus_description']
-- Tags: ['Phi maint']
-- Description: Insert a row into the pt table in the private_tag_kb schema
--

insert into pt(
  pt_signature,
  pt_short_signature,
  pt_owner,
  pt_group,
  pt_element,
  pt_consensus_vr,
  pt_consensus_vm,
  pt_consensus_name, 
  pt_consensus_disposition,
  pt_consensus_description
) values ( 
  ?, ?, ?, ?, ?,
  ?, ?, ?, ?, ?
)