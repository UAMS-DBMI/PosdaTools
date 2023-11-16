/*
	Add new gamma Index to the VR preview images
*/
alter table pathology_visual_review_files
add column gammaIndex int default null;
