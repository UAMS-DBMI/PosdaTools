/*
	Issue: PT-727
  Table for Worker Nodes
*/

create table work (
    work_id serial primary key,
    node_hostname text,
    subprocess_invocation_id integer references subprocess_invocation(subprocess_invocation_id),
    input_file_id integer references file(file_id),
    status text,
    running boolean not null default false,
    finished boolean not null default false,
    failed boolean not null default false,
	stdout_file_id integer references file(file_id),
    stderr_file_id integer references file(file_id)
);
