-- Name: ListOfDciodvfyErrors
-- Schema: posda_phi_simple
-- Columns: ['error_type', 'error_tag', 'error_value', 'error_subtype', 'error_module', 'error_reason', 'error_index', 'num_scan_units']
-- Args: []
-- Tags: ['tag_usage', 'dciodvfy']
-- Description: All dciodvfy errors in DB

select 
  distinct error_type,
  error_tag, 
  error_value,
  error_subtype,
  error_module, 
  error_reason,
  error_index,
  count(distinct dciodvfy_unit_scan_id)  as num_scan_units 
from 
  dciodvfy_error
  natural join dciodvfy_unit_scan_error
group by 
  error_type,
  error_tag, 
  error_value,
  error_subtype,
  error_module, 
  error_reason,
  error_index
order by
  error_type,
  error_tag, 
  error_value,
  error_subtype,
  error_module, 
  error_reason,
  error_index