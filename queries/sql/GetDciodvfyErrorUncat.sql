-- Name: GetDciodvfyErrorUncat
-- Schema: posda_phi_simple
-- Columns: ['id']
-- Args: ['error_text']
-- Tags: ['NotInteractive', 'used_in_dciodvfy']
-- Description: Get an dciodvfy_errors row by error_text (if present)

select
  dciodvfy_error_id as id
from 
  dciodvfy_error
where
  error_type = 'Uncategorized'
  and error_text = ?