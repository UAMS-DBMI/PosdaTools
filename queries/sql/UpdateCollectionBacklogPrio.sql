-- Name: UpdateCollectionBacklogPrio
-- Schema: posda_backlog
-- Columns: []
-- Args: ['priority', 'collection']
-- Tags: ['NotInteractive', 'Backlog']
-- Description: Update the priority of a collection in a backlog 

update
  collection_count_per_round
set
  file_count = ?
where
  collection = ?

