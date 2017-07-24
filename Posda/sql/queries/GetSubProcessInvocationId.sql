-- Name: GetSubProcessInvocationId
-- Schema: posda_queries
-- Columns: ['id']
-- Args: []
-- Tags: ['NotInteractive', 'used_in_background_processing']
-- Description: Get the id of the subprocess_invocation row just created

select currval('subprocess_invocation_subprocess_invocation_id_seq') as id