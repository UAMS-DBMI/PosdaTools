/*
	This edit belongs to PT-931, 
	Create a Warning message for outdated queries called from Operation Popups
*/
alter table spreadsheet_operation add column outdated bool default false;
