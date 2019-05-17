\connect posda_files

insert into public.import_control values (
	'waiting to go inservice', 	-- status
	null, 				-- processor_pid
	10, 				-- idle_seconds
	null, 				-- pending_change_request
	50 				-- files_per_round
);

alter database posda_files set search_path = public, dbif_config, dicom_conv;

refresh materialized view public.file_imports_over_time;
refresh materialized view public.files_without_type;
