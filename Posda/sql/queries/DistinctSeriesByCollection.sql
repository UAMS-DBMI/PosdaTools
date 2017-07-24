-- Name: DistinctSeriesByCollection
-- Schema: posda_files
-- Columns: ['series_instance_uid', 'dicom_file_type', 'modality', 'count']
-- Args: ['collection']
-- Tags: ['by_collection', 'find_series', 'search_series', 'send_series', 'phi_simple', 'simple_phi']
-- Description: Get Series in A Collection
-- 

select distinct series_instance_uid, dicom_file_type, modality, count(*)
from (
select distinct series_instance_uid, sop_instance_uid, dicom_file_type, modality from (
select
   distinct series_instance_uid, modality, sop_instance_uid,
   file_id, dicom_file_type
 from file_series natural join file_sop_common
   natural join ctp_file natural join dicom_file
where
  project_name = ?
  and visibility is null)
as foo
group by series_instance_uid, sop_instance_uid, dicom_file_type, modality)
as foo
group by series_instance_uid, dicom_file_type, modality
