-- Name: GetDciodvfyErrorInvalidValueForVr
-- Schema: posda_phi_simple
-- Columns: ['id']
-- Args: ['error_tag', 'error_index', 'error_value', 'error_reason', 'error_desc']
-- Tags: ['NotInteractive', 'used_in_dciodvfy']
-- Description: Get an dciodvfy_errors row by error_tag where error_type = 'InvalidValueForVr'

select
  dciodvfy_error_id as id
from 
  dciodvfy_error
where
  error_type = 'InvalidValueForVr'
  and error_tag = ? and
  error_index = ? and
  error_value = ? and
  error_reason = ? and
  error_subtype = ?
