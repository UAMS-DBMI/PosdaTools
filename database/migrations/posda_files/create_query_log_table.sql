/*
	Issue PT-797 - Query module track stats

	We need a table to track Posda::DB Query usage

*/
create table query_log (
	when_retrieved timestamp,
	query_name text
);

comment on table query_log is 'A table to track Posda::DB Query usage';
