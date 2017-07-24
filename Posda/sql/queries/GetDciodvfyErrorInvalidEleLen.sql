-- Name: GetDciodvfyErrorInvalidEleLen
-- Schema: posda_phi_simple
-- Columns: ['id']
-- Args: ['error_tag', 'error_value', 'error_subtype', 'error_reason', 'error_index']
-- Tags: ['NotInteractive', 'used_in_dciodvfy']
-- Description: Get an dciodvfy_errors row by error_tag where error_type = 'InvalidElementLength'

select
  dciodvfy_error_id as id
from 
  dciodvfy_error
where
  error_type = 'InvalidElementLength'
  and error_tag = ?
  and error_value = ?
  and error_subtype = ?
  and error_reason = ?
  and error_index = ?
