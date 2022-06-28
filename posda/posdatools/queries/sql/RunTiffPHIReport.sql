-- Name: RunTiffPHIReport
-- Schema: posda_phi_simple
-- Columns: ['tag_name', 'value', 'file_id']
-- Args: ['tiff_phi_scan_instance_id']
-- Tags: ['phi_reports']
-- Description: Return PHI Report data
--

select
  tag_name,
  value,
  file_id
from
  tiff_phi_scan_instance
  natural join tiff_tag_value_occurance
  natural join tiff_tag_seen
  natural join tiff_value_seen
  where tiff_phi_scan_instance_id = ?;
