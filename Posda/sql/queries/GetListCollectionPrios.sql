-- Name: GetListCollectionPrios
-- Schema: posda_backlog
-- Columns: ['collection', 'priority']
-- Args: []
-- Tags: ['NotInteractive', 'Backlog', 'Backlog Monitor', 'backlog_status']
-- Description: Get a list of all collections in backlog with defined counts

select collection, file_count as priority
from collection_count_per_round
order by collection

