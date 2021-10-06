-- Name: ClassicPublicDownloadPathBySeriesWithSopEtc
-- Schema: public
-- Columns: ['series_instance_uid', 'sop_instance_uid', 'instance_number', 'acquisition_number', 'dir_path']
-- Args: ['series_instance_uid']
-- Tags: ['public']
-- Description: Get the 'classic download file path' for a file based on sop_instance_uid
-- 

select 
  gs.series_instance_uid, 
  gi.sop_instance_uid,
  gi.instance_number,
  gi.acquisition_number,
  concat(gs.project,'/',
              gs.patient_id,'/',
              s.study_instance_uid,'/',
              gs.series_instance_uid, '/') as dir_path
  from study s,
       general_series gs,
       general_image gi
where gs.study_pk_id = s.study_pk_id
   and gs.general_series_pk_id = gi.general_series_pk_id
   and gi.series_instance_uid=?