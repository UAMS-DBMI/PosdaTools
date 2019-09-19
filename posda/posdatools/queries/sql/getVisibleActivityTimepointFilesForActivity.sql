-- Name: getVisibleActivityTimepointFilesForActivity
-- Schema: posda_files
-- Columns: ['collection', 'site', 'patient_id', 'study_instance_uid', 'series_instance_uid', 'sop_instance_uid', 'dicom_file_type', 'modality', 'file_id']
-- Args: ['activity_id']
-- Tags: ['NotInteractive']
-- Description: Fetches Activity Timepoint data for creating a new timepoint from an old one as an update.
-- For use in scripts.
-- Not really intended for interactive use.

select
coalesce(project_name, 'UNKNOWN') as collection,
coalesce(site_name, 'UNKNOWN') as site,
patient_id,
study_instance_uid,
series_instance_uid,
sop_instance_uid,
dicom_file_type,
modality,
file_id
from
file_patient
natural left join ctp_file
natural join file_study
natural join file_series
natural join file_sop_common
natural join dicom_file
where
file_id in (select distinct
file_id
from
activity_timepoint
natural join activity_timepoint_file
where
activity_id = ?)
and visibility is null
order by series_instance_uid