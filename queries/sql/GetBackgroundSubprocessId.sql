-- Name: GetBackgroundSubprocessId
-- Schema: posda_queries
-- Columns: ['id']
-- Args: []
-- Tags: ['NotInteractive', 'used_in_background_processing']
-- Description: Get the id of the background_subprocess row just created

select currval('background_subprocess_background_subprocess_id_seq') as id