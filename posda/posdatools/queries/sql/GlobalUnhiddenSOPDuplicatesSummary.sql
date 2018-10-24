-- Name: GlobalUnhiddenSOPDuplicatesSummary
-- Schema: posda_files
-- Columns: ['collection', 'site', 'patient_id', 'study_instance_uid', 'series_instance_uid', 'sop_instance_uid', 'num_dup_sops', 'num_uploads', 'first_upload', 'last_upload']
-- Args: []
-- Tags: ['receive_reports']
-- Description: Return a report of visible duplicate SOP Instance UIDs
-- 

select 
  distinct project_name as collection, site_name as site, patient_id,
  study_instance_uid, series_instance_uid,
  sop_instance_uid, min(import_time) as first_upload, max(import_time) as
  last_upload, count(distinct file_id) as num_dup_sops,
  count(*) as num_uploads from (
select
  distinct project_name as collection,
  site_name as site, patient_id,
  study_instance_uid, series_instance_uid, sop_instance_uid, file_id
from file_sop_common natural join ctp_file natural join file_patient
  natural join file_study natural join file_series
where visibility is null and sop_instance_uid in (
  select distinct sop_instance_uid from (
    select distinct sop_instance_uid, count(*) from (
      select distinct file_id, sop_instance_uid 
      from
        ctp_file natural join file_sop_common
        natural join file_study natural join file_series
        natural join file_patient
      where visibility is null
    ) as foo
    group by sop_instance_uid order by count desc
  ) as foo where count > 1
) group by project_name, site_name, patient_id, study_instance_uid, 
  series_instance_uid, sop_instance_uid, file_id
) as foo
natural join file_sop_common natural join file_series natural join file_study
natural join ctp_file natural join file_patient natural join file_import
natural join import_event
group by project_name, site_name, patient_id,
  study_instance_uid, series_instance_uid,
  sop_instance_uid
order by project_name, site_name, patient_id
