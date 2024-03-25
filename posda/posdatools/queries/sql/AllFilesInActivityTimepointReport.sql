-- Name: AllFilesInActivityTimepointReport
-- Schema: posda_files
-- Columns: ['activity_id', 'activity_timepoint_id', 'file_id', 'file_type', 'patient_id', 'study_instance_uid', 'study_description', 'study_date', 'study_time', 'series_instance_uid', 'series_number', 'series_date', 'series_time', 'series_description', 'protocol_name', 'modality', 'laterality', 'patient_position', 'body_part_examined', 'sop_instance_uid', 'sop_class_uid', 'instance_number', 'specific_character_set']
-- Args: ['activity_timepoint_id']
-- Tags: ['activity_timepoint_reports']
-- Description: Report on all files (not just DICOM) in activity timepoint
--

select a.activity_id, 
       atf.activity_timepoint_id, 
       f.file_id, 	 
       f.file_type,
       fp.patient_id, 
       fst.study_instance_uid, 
       fst.study_description, 
       fst.study_date, 
       fst.study_time,
       fse.series_instance_uid, 
       fse.series_number, 
       fse.series_date, 
       fse.series_time,
       fse.series_description, 
       fse.protocol_name, 
       fse.modality, 
       fse.laterality,
       fse.patient_position, 
       fse.body_part_examined, 
       fsc.sop_instance_uid, 
       fsc.sop_class_uid, 
       fsc.instance_number,       
       fsc.specific_character_set
  from activity_timepoint_file atf
  left join activity_timepoint atp
    on atp.activity_timepoint_id = atf.activity_timepoint_id 
  left join activity a
    on a.activity_id = atp.activity_id 
  left join file f
    on f.file_id = atf.file_id 
  left join file_patient fp
    on fp.file_id = atf.file_id 
  left join file_study fst
    on fst.file_id = atf.file_id 
  left join file_series fse
    on fse.file_id = atf.file_id 
  left join file_sop_common fsc
    on fsc.file_id = atf.file_id
 where atf.activity_timepoint_id = ?
 order by patient_id, study_instance_uid, series_instance_uid, sop_instance_uid  

