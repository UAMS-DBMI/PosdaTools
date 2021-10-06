-- Name: DescriptivePublicDownloadPathWithSeriesSopEtc
-- Schema: public
-- Columns: ['series_instance_uid', 'sop_instance_uid', 'instance_number', 'acquisition_number', 'dir_path']
-- Args: ['series_instance_uid']
-- Tags: ['public']
-- Description: Get the 'descriptive download file path' for a file based on sop_instance_uid
-- 

select 
  gs.series_instance_uid, 
  gi.sop_instance_uid,
  gi.instance_number,
  gi.acquisition_number,
   replace(
       concat(gs.project,'/',
              gs.patient_id,'/',
           IF(s.study_date IS NULL or s.study_date  = '', '', concat(date_format(s.study_date, '%m-%d-%Y'), '-')),
           IF(s.study_id IS NULL or s.study_id  = '', '', concat(s.study_id, '-')),
           IF(s.study_desc IS NULL or s.study_desc  = '', '', concat(s.study_desc, '-')),
           right(gs.study_instance_uid, 5), '/',
           IF(gs.series_number IS NULL or gs.series_number  = '', '', concat(gs.series_number, '-')),
           IF(gs.series_desc IS NULL or gs.series_desc  = '', '', concat(gs.series_desc, '-')),
           right(gs.series_instance_uid, 5), '/'),'_','') as dir_path
  from study s,
       general_series gs,
       general_image gi
where gs.study_pk_id = s.study_pk_id
   and gs.general_series_pk_id = gi.general_series_pk_id
   and gi.series_instance_uid=?