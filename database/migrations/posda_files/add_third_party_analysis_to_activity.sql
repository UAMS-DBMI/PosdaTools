/*
	Issue: PT-789 Create a new table to track TPA URLs
	Sub-task of PT-788 Add Third Party Analysis support

	Third Paraty Analysis URLs need to be tracked at the Activity
	level, so add it to the activity table.
*/

alter table activity add column third_party_analysis_url text;
