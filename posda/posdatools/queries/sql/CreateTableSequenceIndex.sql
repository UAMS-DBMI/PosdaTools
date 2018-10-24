-- Name: CreateTableSequenceIndex
-- Schema: posda_phi
-- Columns: []
-- Args: ['scan_element_id', 'sequence_level', 'item_number']
-- Tags: ['UsedInPhiSeriesScan', 'NotInteractive']
-- Description: Create Table Sequence Id

insert into sequence_index(
  scan_element_id, sequence_level, item_number
) values (?, ?, ?)
