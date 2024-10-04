-- Name: PathologyExportQuery1
-- Schema: posda_files
-- Columns: ['path', 'collectionname', 'studyid', 'clinicaltrialsubjectid', 'imageid']
-- Args: ['activity_id']
-- Tags: ['pathology', 'export']
-- Description: Get mapping and path info for exporting data to pathdb
--

select
	rel_path as path,
	collection_name as collectionname,
	site_name as studyid,
	clinical_trial_subject_id as clinicaltrialsubjectid,
	image_id imageid
from file f
	natural join file_location fl
	natural join pathology_patient_mapping ppm
where f.file_id in (
	select
		file_id
	from activity_timepoint_file atf
	where activity_timepoint_id in
		(select
			max(activity_timepoint_id)
			from activity_timepoint atp
			where activity_id = ?));
