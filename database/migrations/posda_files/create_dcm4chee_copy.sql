create table dcm4chee_copy (
	subprocess_invocation_id integer references subprocess_invocation(subprocess_invocation_id) not null,
	file_id integer references file(file_id) not null,
	rel_path text not null,
	processed bool not null default false,
	failed bool,
	error text,
	primary key (subprocess_invocation_id, file_id)
);
create index dcm4chee_copy_processed on dcm4chee_copy(processed);
