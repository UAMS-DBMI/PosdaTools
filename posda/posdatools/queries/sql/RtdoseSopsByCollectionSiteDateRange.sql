-- Name: RtdoseSopsByCollectionSiteDateRange
-- Schema: posda_files
-- Columns: ['sop_instance_uid']
-- Args: ['collection', 'site', 'from', 'to']
-- Tags: ['Hierarchy', 'apply_disposition', 'hash_unhashed']
-- Description: Construct list of files in a collection, site in a Patient, Study, Series Hierarchy

select distinct
  sop_instance_uid
from
  file_series natural join ctp_file natural join file_sop_common
  natural join file_import natural join import_event
where 
  project_name = ? and site_name = ?
  and visibility is null and import_time > ? and 
  import_time < ?
  and modality = 'RTDOSE'