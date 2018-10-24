-- Name: GetDciodvfyErrorId
-- Schema: posda_phi_simple
-- Columns: ['id']
-- Args: []
-- Tags: ['NotInteractive', 'used_in_dciodvfy']
-- Description: Create a id of newly created dciodvfy_error row

select currval('dciodvfy_error_dciodvfy_error_id_seq') as id