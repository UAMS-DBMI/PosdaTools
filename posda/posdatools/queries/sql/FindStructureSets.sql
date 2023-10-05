-- Name: FindStructureSets
-- Schema: posda_files
-- Columns: ['dicom_file_type', 'project_name', 'patient_id', 'min', 'max', 'count']
-- Args: []
-- Tags: ['Exceptional-Responders_NCI_Oct2018_curation']
-- Description: Find files which have unique_pixel_data_id but no image_id, then find out where the hell they came from

select
  distinct dicom_file_type, project_name,  
  patient_id, min(import_time), max(import_time), count(distinct file_id) 
from
  ctp_file natural join dicom_file natural join
  file_patient natural join file_import natural join 
  import_event 
where file_id in (
  select file_id 
  from (
    select file_id, image_id 
    from ctp_file natural join file_series left join file_image using(file_id)
    where modality = 'CT' and project_name = 'Exceptional-Responders' and file_id in (
      select
         distinct file_id from file_import natural join import_event natural join dicom_file
      where import_time > '2018-09-17'
    )
  ) as foo where image_id is null
) 
group by dicom_file_type, project_name, patient_id
order by patient_id