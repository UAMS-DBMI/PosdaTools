-- Name: GetEquipmentInfoById
-- Schema: posda_files
-- Columns: ['file_id', 'manufacturer', 'institution_name', 'institution_addr', 'station_name', 'inst_dept_name', 'manuf_model_name', 'dev_serial_num', 'software_versions', 'spatial_resolution', 'last_calib_date', 'last_calib_time', 'pixel_pad']
-- Args: ['file_id']
-- Tags: ['reimport_queries']
-- Description: Get file path from id

select
  file_id,
  manufacturer,
  institution_name,
  institution_addr,
  station_name,
  inst_dept_name,
  manuf_model_name,
  dev_serial_num,
  software_versions,
  spatial_resolution,
  last_calib_date,
  last_calib_time,
  pixel_pad
from file_equipment
where file_id = ?