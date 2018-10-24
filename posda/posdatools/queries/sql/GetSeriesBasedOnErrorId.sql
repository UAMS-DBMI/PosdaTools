-- Name: GetSeriesBasedOnErrorId
-- Schema: posda_phi_simple
-- Columns: ['series_instance_uid']
-- Args: ['dciodvfy_error_id']
-- Tags: ['tag_usage', 'dciodvfy']
-- Description: find series for a particular dciodvfy_error

select 
  distinct unit_uid as series_instance_uid
from 
  dciodvfy_unit_scan natural join dciodvfy_unit_scan_error
where
  dciodvfy_error_id = ?
order by dciodvfy_error_id