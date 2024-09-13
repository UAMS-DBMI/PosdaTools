-- Name: CreateNiftiPHIScan
-- Schema: posda_phi_simple
-- Columns: ['nifti_phi_scan_instance_id']
-- Args: ['description']
-- Tags: ['phi_reports']
-- Description: Create a Nifti PHI Scan instance
--


insert into public.nifti_phi_scan_instance (description, start_time) values (?, now()) returning nifti_phi_scan_instance_id;
