-- Name: GetDciodvfyErrorUnrecogEnum
-- Schema: posda_phi_simple
-- Columns: ['id']
-- Args: ['error_value', 'error_tag', 'error_index']
-- Tags: ['NotInteractive', 'used_in_dciodvfy']
-- Description: Get an dciodvfy_errors row by error_text (if present)

select
  dciodvfy_error_id as id
from 
  dciodvfy_error
where
  error_type = 'UnrecognizedEnumeratedValue'
  and error_value = ?
  and error_tag = ?
  and error_index = ?