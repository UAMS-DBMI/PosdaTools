truncate table import_control;

insert into import_control values (
	'waiting to go inservice', 	-- status
	null, 				-- processor_pid
	10, 				-- idle_seconds
	null, 				-- pending_change_request
	50 				-- files_per_round
);

alter database posda_files set search_path = public, dbif_config, dicom_conv;

refresh materialized view file_imports_over_time;
refresh materialized view files_without_type;
