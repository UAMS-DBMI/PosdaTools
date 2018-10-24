-- Name: CreateRound
-- Schema: posda_backlog
-- Columns: []
-- Args: []
-- Tags: ['NotInteractive', 'Backlog']
-- Description: Create a row in round table to record files_imported in this round

insert into round(
  round_created
) values (
  now()
)
