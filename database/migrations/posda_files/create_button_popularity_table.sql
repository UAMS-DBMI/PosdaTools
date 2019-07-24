/*
	Issue PT-741 popular button signifier

*/

create table public.button_popularity (
	processname text not null,
	created timestamp not null
);
