-- Name: GetDciodvfyErrorAttrSpecWithIndex
-- Schema: posda_phi_simple
-- Columns: ['id']
-- Args: ['error_tag', 'error_subtype', 'error_index']
-- Tags: ['NotInteractive', 'used_in_dciodvfy']
-- Description: Get dciodvfy_errors row where subtype = AttributeSpecificErrorWithIndex

select
  dciodvfy_error_id as id
from 
  dciodvfy_error
where
  error_type = 'AttributeSpecificErrorWithIndex'
  and error_tag = ?
  and error_subtype= ?
  and error_index = ?