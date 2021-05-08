/*
	Add a JSONB column (metrics) to the work table, for tracking
	runtime statistics. This relates to PT-1011

*/
alter table work add column metrics jsonb;
