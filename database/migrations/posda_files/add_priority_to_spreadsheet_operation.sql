/*
	This edit belongs to workernodes, 
  Adds the priority number to spreadsheet operations
*/
alter table spreadsheet_operation add column worker_priority int default 0;
