-- Name: GetDciodvfyErrorBadVm
-- Schema: posda_phi_simple
-- Columns: ['id']
-- Args: ['error_tag', 'error_value', 'error_index', 'error_module']
-- Tags: ['NotInteractive', 'used_in_dciodvfy']
-- Description: Get an dciodvfy_errors row by error_text (if present)

select
  dciodvfy_error_id as id
from 
  dciodvfy_error
where
  error_type = 'BadValueMultiplicity'
  and error_tag = ?
  and error_value = ?
  and error_index = ?
  and error_module = ?
