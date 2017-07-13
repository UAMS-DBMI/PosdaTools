-- Name: GetSeriesWithSignatureIntake
-- Schema: intake
-- Columns: ['series_instance_uid', 'signature']
-- Args: ['collection', 'site']
-- Tags: ['signature']
-- Description: Get a list of Series with Signatures by Collection Intake
-- 

select
  distinct  s.series_instance_uid,
  concat(
    COALESCE(e.manufacturer, ''), 
    '_',
    COALESCE(e.manufacturer_model_name, ''),
     '_',
    COALESCE(e.software_versions, '') 
  ) as signature
from
  general_series s, general_equipment e
where
  s.general_equipment_pk_id = e.general_equipment_pk_id and
  s.general_series_pk_id in (
    select
      distinct i.general_series_pk_id
    from
      general_image i, trial_data_provenance tdp
    where
      i.trial_dp_pk_id = tdp.trial_dp_pk_id and
      tdp.project = ? and tdp.dp_site_name = ?
  )