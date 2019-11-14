drop table if exists submissions;
drop type if exists access_type;

create type access_type as enum ('public', 'limited');
create table submissions (
	submission_id		serial primary key,
	collection_code 	text references collection_codes(collection_code),
	site_code			text references site_codes(site_code),
    patient_id_prefix   text,
    body_part           text,
    access_type         access_type,
    baseline_date       timestamp,
    date_shift          integer,
    unique (collection_code, site_code)
);
