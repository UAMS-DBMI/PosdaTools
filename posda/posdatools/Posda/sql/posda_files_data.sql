truncate table import_control;

insert into import_control values (
	'waiting to go inservice', 	-- status
	null, 				-- processor_pid
	10, 				-- idle_seconds
	null, 				-- pending_change_request
	50 				-- files_per_round
);
