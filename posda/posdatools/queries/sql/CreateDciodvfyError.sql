-- Name: CreateDciodvfyError
-- Schema: posda_phi_simple
-- Columns: []
-- Args: ['error_type', 'error_tag', 'error_subtype', 'error_module', 'error_reason', 'error_index', 'error_value', 'error_text']
-- Tags: ['NotInteractive', 'used_in_dciodvfy']
-- Description: Create a dciodvfy_errors row by error_text 

insert into dciodvfy_error(
  error_type, error_tag, error_subtype, error_module,
  error_reason, error_index, error_value, error_text
) values (
  ?, ?, ?, ?,
  ?, ?, ?, ?
)