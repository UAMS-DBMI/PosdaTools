-- Name: GetListCollectionsWithNoDefinedCounts
-- Schema: posda_backlog
-- Columns: ['collection']
-- Args: []
-- Tags: ['NotInteractive', 'Backlog', 'Backlog Monitor']
-- Description: Get a list of all collections in backlog with no defined counts

select distinct collection
from submitter s
where collection not in (
  select collection from collection_count_per_round c
  where s.collection = c.collection
)
