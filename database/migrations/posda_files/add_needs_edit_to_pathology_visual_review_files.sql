/*
	Add new field to support PT-1013
*/
alter table pathology_visual_review_files
add column needs_edit bool default null;
