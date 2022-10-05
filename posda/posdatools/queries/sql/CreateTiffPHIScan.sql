-- Name: CreateTiffPHIScan
-- Schema: posda_phi_simple
-- Columns: ['tiff_phi_scan_instance_id']
-- Args: ['description']
-- Tags: ['phi_reports']
-- Description: Create a Tiff PHI Scan instance
--


insert into public.tiff_phi_scan_instance (description, start_time) values (?, now()) returning tiff_phi_scan_instance_id;
