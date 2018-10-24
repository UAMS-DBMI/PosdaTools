create table queries (
	name	text primary key,
	query	text,
	args	text[],
	columns	text[],
	tags	text[],
	schema	text,
	description text
);
