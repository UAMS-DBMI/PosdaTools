-- Name: InsertRoundCounts
-- Schema: posda_backlog
-- Columns: []
-- Args: ['round_id', 'collection', 'num_requests', 'priority']
-- Tags: ['NotInteractive', 'Backlog']
-- Description: Insert a row into round_counts

insert into round_counts(
  round_id, collection,
  num_requests, priority
) values (
  ?, ?,
  ?, ?
)
