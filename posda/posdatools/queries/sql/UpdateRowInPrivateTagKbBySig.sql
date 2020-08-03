-- Name: UpdateRowInPrivateTagKbBySig
-- Schema: posda_private_tag
-- Columns: []
-- Args: ['pt_owner', 'pt_group', 'pt_element', 'pt_consensus_vr', 'pt_consensus_vm', 'pt_consensus_name', 'pt_signature']
-- Tags: ['Phi maint']
-- Description: Update a row into the pt table in the private_tag_kb schema by pt_signature
--

update  pt set
  pt_owner = ?,
  pt_group = ?,
  pt_element = ?,
  pt_consensus_vr = ?,
  pt_consensus_vm = ?,
  pt_consensus_name = ?
where
  pt_signature = ?