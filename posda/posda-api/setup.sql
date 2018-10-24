create table downloadable_file (
	downloadable_file_id	serial primary key,
	file_id integer not null,
	security_hash text not null,
	creation_date timestamp not null default now(),
	valid_until date,
	mime_type text,
	foreign key (file_id) references file (file_id)
);
