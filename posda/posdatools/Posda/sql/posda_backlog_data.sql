truncate table control_status;

insert into control_status values (
	'waiting to go inservice', 	-- status
	null, 				-- processor_pid
	'10 seconds', 			-- idle_poll_interval
	null, 				-- last_service
	null, 				-- pending_change_request
	null, 				-- source_pending_change_request
	null, 				-- request_time
	500, 				-- num_files_per_round
	500 				-- target_queue_size
);
