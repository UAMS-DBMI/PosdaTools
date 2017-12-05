-- Name: ToExamineRecentFiles
-- Schema: posda_files
-- Columns: ['file_id', 'collection', 'site', 'patient_id', 'series_instance_uid', 'dicom_file_type', 'modality']
-- Args: ['patient_id', 'import_time_1', 'import_time_2']
-- Tags: ['meta', 'test', 'hello', 'query_tabs', 'bills_test']
-- Description: Files for a specific patient which were first received after a specific time

select 
  file_id, project_name as collection, site_name as site,
  patient_id, series_instance_uid, dicom_file_type, modality
from
  ctp_file natural join file_patient natural join dicom_file natural join file_series where file_id in 
  (
     select file_id from 
     (  
        select 
           distinct file_id, min(import_time) as import_time 
        from 
          file_import natural join import_event 
        where file_id in 
        (
          select 
            distinct file_id 
          from 
             ctp_file natural join file_import natural join import_event
             natural join file_patient 
           where patient_id =? and import_time > ?
         ) group by file_id
      ) as foo
      where import_time > ?
  )