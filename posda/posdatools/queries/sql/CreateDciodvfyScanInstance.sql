-- Name: CreateDciodvfyScanInstance
-- Schema: posda_phi_simple
-- Columns: []
-- Args: ['type_of_unit', 'description_of_scan', 'number_units']
-- Tags: ['NotInteractive', 'used_in_dciodvfy']
-- Description: Create a dciodvfy_scan_instance row

insert into dciodvfy_scan_instance(
  type_of_unit,
  description_of_scan,
  number_units,
  scanned_so_far,
  start_time
) values (
  ?, ?, ?, 0, now()
)