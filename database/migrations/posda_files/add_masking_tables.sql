/*

Add Masking tables

This pertains to TADMIN-1215

*/
create type masking_status_type as enum (
	'created',
	'ready-to-process',
	'in-process',
	'process-complete',
	'accepted',
	'rejected',
	'errored'
);
create table masking (
	image_equivalence_class_id integer primary key references image_equivalence_class(image_equivalence_class_id),
	masking_parameters jsonb,
	masking_status masking_status_type not null default 'created',
	import_event_id integer references import_event(import_event_id),
	masking_exit_code integer
);
create table masking_history (
	image_equivalence_class_id integer references masking(image_equivalence_class_id),
	new_status masking_status_type,
	when_changed timestamp with time zone not null,
	who_changed integer not null references auth.users(user_id)
);
create index masking_history_idx on masking_history(image_equivalence_class_id);

create table masking_exit_code (
	masking_exit_code integer primary key,
	exit_code_name text,
	exit_code_description text
);
-- These values must match those defined in Masker for it's exit codes
insert into masking_exit_code values 
(0, 'SUCCESS', 'Masking was successful'),
(2, 'ARG_ERROR', null),
(3, 'UNSUPPORTED_FILETYPE', null),
(5, 'FEW_SLICES', null),
(6, 'BINARY_MASK', null),
(7, 'DUP_SOPS', null)
;
