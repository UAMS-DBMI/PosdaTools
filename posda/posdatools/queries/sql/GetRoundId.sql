-- Name: GetRoundId
-- Schema: posda_backlog
-- Columns: ['file_id']
-- Args: []
-- Tags: ['NotInteractive', 'Backlog']
-- Description: Get posda file id of created round row

select  currval('round_round_id_seq') as id
