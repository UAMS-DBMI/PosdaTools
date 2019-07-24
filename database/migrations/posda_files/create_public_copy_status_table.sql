/*
	Issue: PT-731
*/
create table public_copy_status (
	subprocess_invocation_id integer references subprocess_invocation(subprocess_invocation_id),
	file_id integer references file(file_id),
	success boolean,
	error_message text
);

comment on table public_copy_status is 'Store the status of attempts to copy files to public';

alter table public_copy_status add primary key (subprocess_invocation_id, file_id);
-- create index nbia_send_status_idx on nbia_send_status(background_subprocess_id);
