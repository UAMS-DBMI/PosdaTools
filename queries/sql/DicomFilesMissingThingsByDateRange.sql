-- Name: DicomFilesMissingThingsByDateRange
-- Schema: posda_files
-- Columns: ['file_id', 'collection', 'site', 'file_patient_missing', 'file_sop_common_missing', 'file_series_missing', 'file_equipment_missing']
-- Args: ['from', 'to']
-- Tags: []
-- Description: List DICOM files which are missing one of:
-- 
-- * file_patient
-- * file_sop_common
-- * file_series
-- * file_equipment
-- 
-- Note that these could be missing due to a failure to fully 
-- parse the DICOM file. If that is the case, the CTP information
-- may also have failed (or been missing). Collection and Site
-- are included in this query but may be missing!

select
	dicom_file.file_id,
	project_name as collection,
	site_name as site,
	case when file_sop_common.file_id is null
		then 'X'
		else ''
	end as file_sop_common_missing,
	case when file_patient.file_id is null
		then 'X'
		else ''
	end as file_patient_missing,
	case when file_study.file_id is null
		then 'X'
		else ''
	end as file_study_missing,
	case when file_series.file_id is null
		then 'X'
		else ''
	end as file_series_missing,
	case when file_equipment.file_id is null
		then 'X'
		else ''
	end as file_equipment_missing


from dicom_file
natural join import_event
natural join file_import
natural left join ctp_file
left join file_patient
	on dicom_file.file_id = file_patient.file_id
left join file_sop_common
	on dicom_file.file_id = file_sop_common.file_id
left join file_series
	on dicom_file.file_id = file_series.file_id
left join file_equipment
	on dicom_file.file_id = file_equipment.file_id
left join file_study
	on dicom_file.file_id = file_study.file_id

where 
	import_time >= ?
	and import_time < ?
	and (
		file_patient.file_id is null
		or file_sop_common.file_id is null
		or file_series.file_id is null
		or file_equipment.file_id is null
	)
