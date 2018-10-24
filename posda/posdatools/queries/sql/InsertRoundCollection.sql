-- Name: InsertRoundCollection
-- Schema: posda_backlog
-- Columns: []
-- Args: ['round_id', 'collection', 'num_entered', 'num_failed', 'num_dups']
-- Tags: ['NotInteractive', 'Backlog']
-- Description: Insert a row into round_collection

insert into round_collection(
  round_id, collection,
  num_entered, num_failed,
  num_dups
) values (
  ?, ?,
  ?, ?,
  ?
)
