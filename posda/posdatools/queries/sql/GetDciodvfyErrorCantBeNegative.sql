-- Name: GetDciodvfyErrorCantBeNegative
-- Schema: posda_phi_simple
-- Columns: ['id']
-- Args: ['error_tag', 'error_value']
-- Tags: ['NotInteractive', 'used_in_dciodvfy']
-- Description: Get an dciodvfy_errors row by error_tag where error_type = 'CantBeNegative'

select
  dciodvfy_error_id as id
from 
  dciodvfy_error
where
  error_type = 'CantBeNegative'
  and error_tag = ?
  and error_value = ?
