-- Name: InsertCollectionCountPerRound
-- Schema: posda_backlog
-- Columns: []
-- Args: ['collection', 'num_files']
-- Tags: ['NotInteractive', 'Backlog']
-- Description: Insert a row into collection count per round

insert into collection_count_per_round(
  collection, file_count
) values (
  ?, ?
)
