-- Name: DciodvfyErrorIdByValue
-- Schema: posda_phi_simple
-- Columns: ['dciodvfy_error_id']
-- Args: ['error_value']
-- Tags: ['tag_usage', 'dciodvfy']
-- Description: find dciodvfy_error_id by contents of error_value

select 
  distinct dciodvfy_error_id
from 
  dciodvfy_error
where
  error_value = ?