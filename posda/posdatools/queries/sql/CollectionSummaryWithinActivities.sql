-- Name: CollectionSummaryWithinActivities
-- Schema: posda_files
-- Columns: ['patient_id', 'num_studies', 'num_series']
-- Args: ['activities', 'collection_name']
-- Tags: []
-- Description: Summary of Collection within multiple activities
--

select * from (
/*
	This query takes a list of activity_ids and a collection name,
	and generates a report of the number of studies and series contained
	within.

	The activity_ids are comma deliminited, no spaces.

	422,426
	NSCLC-RADIOMICS-RIDER1
*/
with input as ( 
select
	unnest(string_to_array(?, ',')) as activity_id
), input_as_int as (
	/* must be cast to an int for the join later to work */
	select activity_id::int as activity_id
	from input
), activity_timepoints as (
	select *
	from activity_timepoint
	natural join input_as_int
), activity_ids as (
	/* Get only the max timepoint id for each activity */
	select 
		activity_id,
		max(activity_timepoint_id)
	from activity_timepoints
	group by 1
), activity_files as (
	select
		file_id
	from
		activity_timepoint_file
		natural join activity_timepoint
		natural join activity_ids
)

select
        patient_id,
        count(distinct study_instance_uid) num_studies,
        count(distinct series_instance_uid) num_series
from activity_files
natural join ctp_file
natural join file_patient
natural join file_study
natural join file_series
where project_name = ?

group by 1
) foo

;
