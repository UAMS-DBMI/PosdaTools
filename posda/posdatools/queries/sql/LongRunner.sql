-- Name: LongRunner
-- Schema: posda_files
-- Columns: ['file_id', 'file_type', 'digest', 'pixel_data_digest', 'dicom_file_type', 'patient_id', 'modality', 'path', 'import_type', 'import_comment']
-- Args: []
-- Tags: ['AllCollections', 'DateRange', 'Kirk', 'Totals', 'count_queries', 'end_of_month']
-- Description: Long running query
--

select
  file_id, file_type, digest, pixel_data_digest, dicom_file_type, patient_id, modality,
  root_path || '/' || l.rel_path as path, import_type,  import_comment
from
  file natural left join dicom_file  natural left join file_patient 
  natural left join file_series natural join file_location l natural join file_storage_root
  join file_import using(file_id) join import_event using (import_event_id)