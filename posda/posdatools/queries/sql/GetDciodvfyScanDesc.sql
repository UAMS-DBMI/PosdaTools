-- Name: GetDciodvfyScanDesc
-- Schema: posda_phi_simple
-- Columns: ['type_of_unit', 'description_of_scan', 'number_units', 'scanned_so_far', 'start_time', 'end_time']
-- Args: ['scan_id']
-- Tags: ['tag_usage', 'dciodvfy']
-- Description: Get info about a dciodvfy scan

select 
  type_of_unit,
  description_of_scan,
  number_units,
  scanned_so_far,
  start_time,
  end_time
from 
  dciodvfy_scan_instance
where dciodvfy_scan_instance_id = ?
