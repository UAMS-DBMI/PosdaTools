-- Name: GetDciodvfyWarningAttrSpecWithValue
-- Schema: posda_phi_simple
-- Columns: ['id']
-- Args: ['warning_tag', 'warning_desc', 'warning_value']
-- Tags: ['NotInteractive', 'used_in_dciodvfy']
-- Description: Get dciodvfy_warning row where subtype = AttributeSpecificWarningWithValue

select
  dciodvfy_warning_id as id
from 
  dciodvfy_warning
where
  warning_type = 'AttributeSpecificWarningWithValue'
  and warning_tag = ?
  and warning_desc = ?
  and warning_value = ?


  