-- Name: GetDciodvfyErrorAttrSpec
-- Schema: posda_phi_simple
-- Columns: ['id']
-- Args: ['error_tag', 'error_subtype']
-- Tags: ['NotInteractive', 'used_in_dciodvfy']
-- Description: Get dciodvfy_errors row where subtype = AttributeSpecificError

select
  dciodvfy_error_id as id
from 
  dciodvfy_error
where
  error_type = 'AttributeSpecificError'
  and error_tag = ?
  and error_subtype= ?