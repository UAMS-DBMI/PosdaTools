-- Name: ClassicPublicDownloadPath
-- Schema: public
-- Columns: ['file_path']
-- Args: ['sop_instance_uid']
-- Tags: ['public']
-- Description: Get the 'classic download file path' for a file based on sop_instance_uid
-- 

select concat(gs.project,'/',
              gs.patient_id,'/',
              s.study_instance_uid,'/',
              gs.series_instance_uid, '/') as file_path
  from study s,
       general_series gs,
       general_image gi
where gs.study_pk_id = s.study_pk_id
   and gs.general_series_pk_id = gi.general_series_pk_id
   and gi.sop_instance_uid=?