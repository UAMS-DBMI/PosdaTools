-- Name: GetDciodvfyWarningId
-- Schema: posda_phi_simple
-- Columns: ['id']
-- Args: []
-- Tags: ['NotInteractive', 'used_in_dciodvfy']
-- Description: Get id of recently created dciodvfy_warnings row

select currval('dciodvfy_warning_dciodvfy_warning_id_seq') as id