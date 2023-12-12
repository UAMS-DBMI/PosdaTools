/*
	Add new gamma Index to the VR preview images
*/
alter table pathology_visual_review_preview_files
add column gammaindex int default null;
