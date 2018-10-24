-- Name: DciodvfyErrorIdsBySeriesAndScanInstance
-- Schema: posda_phi_simple
-- Columns: ['dciodvfy_error_id']
-- Args: ['dciodvfy_scan_instance_id', 'series_instance_uid']
-- Tags: ['tag_usage', 'dciodvfy']
-- Description: Show all the dciodvfy scans

select                                                    
  dciodvfy_error_id
from dciodvfy_error 
where  dciodvfy_error_id in (
  select distinct dciodvfy_error_id
  from (
    select
      distinct unit_uid, dciodvfy_error_id
    from
      dciodvfy_unit_scan
      natural join dciodvfy_unit_scan_error
    where
      dciodvfy_scan_instance_id = ? and unit_uid =?
  )
 as foo
)