-- Name: GetNbiaTransferParams
-- Schema: posda_files
-- Columns: ['collection', 'site', 'site_id', 'sop_instance_uid', 'tpa_url']
-- Args: ['activity_id', 'file_id']
-- Tags: ['export_event']
-- Description:  get the export_event_id of a newly created export_event
--

select
  distinct project_name as collection,
  site_name as site, 
  site_code || collection_code as site_id,
  sop_instance_uid,
  a.third_party_analysis_url as tpa_url
from
  file_sop_common sc natural left join ctp_file ctp join site_codes using (site_name),
  collection_codes cc, activity a
where
  ctp.project_name = cc.collection_name and a.activity_id = ?
  and sc.file_id = ?
  