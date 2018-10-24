-- Name: RecentUploadsTest1
-- Schema: posda_files
-- Columns: ['project_name', 'site_name', 'dicom_file_type', 'count', 'minutes_ago', 'time']
-- Args: []
-- Tags: ['files']
-- Description: Show files received by Posda in the past day.

select
        project_name,
        site_name,
        dicom_file_type,
        count(*),
        (extract(epoch from now() - max(import_time)) / 60)::int as minutes_ago,
        to_char(max(import_time), 'HH24:MI') as time

    from (
        select 
          project_name,
          site_name,
          dicom_file_type,
          sop_instance_uid,
          import_time

        from 
          file_import
          natural join import_event
          natural join ctp_file
          natural join dicom_file
          natural join file_sop_common
          natural join file_patient

        where import_time > now() - interval '1' day
          and visibility is null
    ) as foo
    group by
        project_name,
        site_name,
        dicom_file_type
    order by minutes_ago asc;