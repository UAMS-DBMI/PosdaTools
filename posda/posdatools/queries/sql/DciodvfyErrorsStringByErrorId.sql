-- Name: DciodvfyErrorsStringByErrorId
-- Schema: posda_phi_simple
-- Columns: ['error_string']
-- Args: ['dciodvfy_error_id']
-- Tags: ['tag_usage', 'dciodvfy']
-- Description: Show all the dciodvfy scans

select                                                    
  dciodvfy_error_id || '|' ||
  error_type || '|' ||                                                                                                                                                                                                                   
  coalesce(error_tag, '[null]') || '|' ||
  coalesce(error_value, '[null]') || '|' ||
  coalesce(error_subtype, '[null]') || '|' ||
  coalesce(error_module, '[null]') || '|' ||
  coalesce(error_reason, '[null]') || '|' ||
  coalesce(error_index, '[null]') || '|' ||
  coalesce(error_text, '[null]') as error_string
from dciodvfy_error 
where  dciodvfy_error_id = ?