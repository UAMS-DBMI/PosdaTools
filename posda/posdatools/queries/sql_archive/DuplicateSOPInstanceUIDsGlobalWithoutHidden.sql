-- Name: DuplicateSOPInstanceUIDsGlobalWithoutHidden
-- Schema: posda_files
-- Columns: ['collection', 'site', 'patient_id', 'study_instance_uid', 'series_instance_uid', 'sop_instance_uid', 'file_id']
-- Args: []
-- Tags: ['receive_reports']
-- Description: Return a report of visible duplicate SOP Instance UIDs
-- 

select
  distinct project_name as collection,
  site_name as site, patient_id,
  study_instance_uid, series_instance_uid, sop_instance_uid, file_id
from file_sop_common natural join ctp_file natural join file_patient
  natural join file_study natural join file_series
where sop_instance_uid in (
  select distinct sop_instance_uid from (
    select distinct sop_instance_uid, count(*) from (
      select distinct file_id, sop_instance_uid 
      from
        ctp_file natural join file_sop_common
        natural join file_study natural join file_series
        natural join file_patient
    ) as foo
    group by sop_instance_uid order by count desc
  ) as foo where count > 1
) group by project_name, site_name, patient_id, study_instance_uid, 
  series_instance_uid, sop_instance_uid, file_id
