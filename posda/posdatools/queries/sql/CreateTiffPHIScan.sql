-- Name: CreateTiffPHIScan
-- Schema: posda_phi_simple
-- Columns: ['tiff_phi_scan_instance_id']
-- Args: ['description']
-- Tags: ['phi_reports']
-- Description: Create a Tiff PHI Scan instance
--
<<<<<<< HEAD

insert into public.tiff_phi_scan_instance (description, start_time) values (?, now()) returning tiff_phi_scan_instance_id;
=======
insert into pathology_patient_mapping values (?,?,?,?,?) on conflict (file_id) do update set patient_id = Excluded.patient_id, original_name = Excluded.original_file_name, collection_name = Excluded.collection_name, site_name = Excluded.site_name;
>>>>>>> f1bf1dac (in progress Path Pat Mapping)
