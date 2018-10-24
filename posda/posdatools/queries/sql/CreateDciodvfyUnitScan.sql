-- Name: CreateDciodvfyUnitScan
-- Schema: posda_phi_simple
-- Columns: []
-- Args: ['type_of_unit', 'unit_uid', 'unit_id', 'num_file_in_unit']
-- Tags: ['NotInteractive', 'used_in_dciodvfy']
-- Description: Create a dciodvfy_unit_scan row

insert into dciodvfy_unit_scan(
  type_of_unit,
  unit_uid,
  unit_id,
  num_file_in_unit,
  start_time
) values( ?, ?, ?, ?, now())