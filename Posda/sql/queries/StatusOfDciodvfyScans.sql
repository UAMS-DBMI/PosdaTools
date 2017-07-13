-- Name: StatusOfDciodvfyScans
-- Schema: posda_phi_simple
-- Columns: ['id', 'type_of_unit', 'description_of_scan', 'number_units', 'scanned_so_far', 'start_time', 'end_time']
-- Args: []
-- Tags: ['tag_usage', 'dciodvfy']
-- Description: Show all the dciodvfy scans

select 
  dciodvfy_scan_instance_id as id,
  type_of_unit,
  description_of_scan,
  number_units,
  scanned_so_far,
  start_time,
  end_time
from 
  dciodvfy_scan_instance
  