-- Name: GetSeriesListByDciodvyScanInstance
-- Schema: posda_phi_simple
-- Columns: ['series_instance_uid']
-- Args: ['dciodvfy_scan_instance_id', 'repeat_scan_instance_id']
-- Tags: ['tag_usage', 'dciodvfy']
-- Description: Show all the dciodvfy scans

select distinct(unit_uid) as series_instance_uid from dciodvfy_unit_scan natural join dciodvfy_unit_scan_warning  where dciodvfy_scan_instance_id = ? union 
select distinct(unit_uid) as series_instance_uid from dciodvfy_unit_scan natural join dciodvfy_unit_scan_error  where dciodvfy_scan_instance_id = ?
