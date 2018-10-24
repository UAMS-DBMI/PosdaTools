INSERT INTO queries (name, query, args, columns, tags, schema, description) VALUES ('ActiveQueriesOld', 'select
  datname as db_name, procpid as pid,
  usesysid as user_id, usename as user,
  waiting, now() - xact_start as since_xact_start,
  now() - query_start as since_query_start,
  now() - backend_start as since_back_end_start,
  current_query
from
  pg_stat_activity
where
  datname = ?
', '{db_name}', '{db_name,pid,user_id,user,waiting,since_xact_start,since_query_start,since_back_end_start,current_query}', '{postgres_status}', 'posda_files', 'Show active queries for a database
Works for PostgreSQL 8.4.20 (Current Linux)
');
INSERT INTO queries (name, query, args, columns, tags, schema, description) VALUES ('AllHiddenSubjects', 'select
  distinct patient_id, project_name, site_name,
  count(*) as num_files
from
  file_patient natural join ctp_file
where patient_id in (
    select distinct patient_id 
    from file_patient
  except 
    select patient_id 
    from
      file_patient natural join ctp_file 
    where
      visibility is null
) group by patient_id, project_name, site_name
order by project_name, site_name, patient_id;
', '{}', '{patient_id,project_name,site_name,num_files}', '{FindSubjects}', 'posda_files', 'Find All Subjects which have only hidden files
');
INSERT INTO queries (name, query, args, columns, tags, schema, description) VALUES ('AllPixelInfo', 'select
  f.file_id as file_id, root_path || ''/'' || rel_path as file,
  file_offset, size, modality,
  bits_stored, bits_allocated, pixel_representation, number_of_frames,
  samples_per_pixel, pixel_rows, pixel_columns, photometric_interpretation
from
  file_image f natural join image natural join unique_pixel_data
  natural join file_series
  join pixel_location pl using(unique_pixel_data_id), 
  file_location fl natural join file_storage_root
where
  pl.file_id = fl.file_id
  and f.file_id = pl.file_id
  and f.file_id in (
  select distinct file_id
  from ctp_file
  where visibility is null
)
', '{}', '{file_id,file,file_offset,size,bits_stored,bits_allocated,pixel_representation,number_of_frames,samples_per_pixel,pixel_rows,pixel_columns,photometric_interpretation,modality}', '{}', 'posda_files', 'Get pixel descriptors for all files
');
INSERT INTO queries (name, query, args, columns, tags, schema, description) VALUES ('AllPixelInfoByBitDepth', 'select
  f.file_id as file_id, root_path || ''/'' || rel_path as file,
  file_offset, size, modality,
  bits_stored, bits_allocated, pixel_representation, number_of_frames,
  samples_per_pixel, pixel_rows, pixel_columns, photometric_interpretation
from
  file_image f natural join image natural join unique_pixel_data
  natural join file_series
  join pixel_location pl using(unique_pixel_data_id), 
  file_location fl natural join file_storage_root
where
  pl.file_id = fl.file_id
  and f.file_id = pl.file_id
  and f.file_id in (
  select distinct file_id
  from
    ctp_file natural join file_image natural join image
  where visibility is null and bits_allocated = ?
)
', '{bits_allocated}', '{file_id,file,file_offset,size,bits_stored,bits_allocated,pixel_representation,number_of_frames,samples_per_pixel,pixel_rows,pixel_columns,photometric_interpretation,modality}', '{}', 'posda_files', 'Get pixel descriptors for all files
');
INSERT INTO queries (name, query, args, columns, tags, schema, description) VALUES ('AllPixelInfoByModality', 'select
  f.file_id as file_id, root_path || ''/'' || rel_path as file,
  file_offset, size, modality,
  bits_stored, bits_allocated, pixel_representation, number_of_frames,
  samples_per_pixel, pixel_rows, pixel_columns, photometric_interpretation
from
  file_image f natural join image natural join unique_pixel_data
  natural join file_series
  join pixel_location pl using(unique_pixel_data_id), 
  file_location fl natural join file_storage_root
where
  pl.file_id = fl.file_id
  and f.file_id = pl.file_id
  and f.file_id in (
  select distinct file_id
  from
    ctp_file natural join file_series 
  where visibility is null and modality = ?
)
', '{bits_allocated}', '{file_id,file,file_offset,size,bits_stored,bits_allocated,pixel_representation,number_of_frames,samples_per_pixel,pixel_rows,pixel_columns,photometric_interpretation,modality}', '{}', 'posda_files', 'Get pixel descriptors for all files
');
INSERT INTO queries (name, query, args, columns, tags, schema, description) VALUES ('AllPixelInfoByPhotometricInterp', 'select
  f.file_id as file_id, root_path || ''/'' || rel_path as file,
  file_offset, size, modality,
  bits_stored, bits_allocated, pixel_representation, number_of_frames,
  samples_per_pixel, pixel_rows, pixel_columns, photometric_interpretation
from
  file_image f natural join image natural join unique_pixel_data
  natural join file_series
  join pixel_location pl using(unique_pixel_data_id), 
  file_location fl natural join file_storage_root
where
  pl.file_id = fl.file_id
  and f.file_id = pl.file_id
  and f.file_id in (
  select distinct file_id
  from
    ctp_file natural join file_image natural join image
  where visibility is null and photometric_interpretation = ?
)
', '{bits_allocated}', '{file_id,file,file_offset,size,bits_stored,bits_allocated,pixel_representation,number_of_frames,samples_per_pixel,pixel_rows,pixel_columns,photometric_interpretation,modality}', '{}', 'posda_files', 'Get pixel descriptors for all files
');
INSERT INTO queries (name, query, args, columns, tags, schema, description) VALUES ('AllSopsReceivedBetweenDates', 'select
   distinct project_name, site_name, patient_id,
   study_instance_uid, series_instance_uid, count(*) as num_sops,
   min(first_loaded) as first_loaded, max(last_loaded) as last_loaded
from (
  select 
    distinct project_name, site_name, patient_id,
    study_instance_uid, series_instance_uid, sop_instance_uid,
    count(*) as num_files, sum(num_uploads) as num_uploads,
    min(first_loaded) as first_loaded, max(last_loaded) as last_loaded
  from (
    select
      distinct project_name, site_name, patient_id,
        study_instance_uid, series_instance_uid, sop_instance_uid,
        file_id, count(*) as num_uploads, max(import_time) as last_loaded,
         min(import_time) as first_loaded
    from (
      select
        distinct project_name, site_name, patient_id,
        study_instance_uid, series_instance_uid, sop_instance_uid,
        file_id, import_time
      from
        ctp_file natural join file_patient natural join
        file_study natural join file_series natural join
        file_sop_common natural join file_import natural join
        import_event
      where
        visibility is null and sop_instance_uid in (
          select distinct sop_instance_uid
          from 
            file_import natural join import_event natural join file_sop_common
          where import_time > ? and import_time < ?
        )
      ) as foo
    group by
      project_name, site_name, patient_id, study_instance_uid, 
      series_instance_uid, sop_instance_uid, file_id
  )as foo
  group by 
    project_name, site_name, patient_id, study_instance_uid, 
    series_instance_uid, sop_instance_uid
) as foo
group by 
  project_name, site_name, patient_id, study_instance_uid, 
  series_instance_uid
', '{start_time,end_time}', '{project_name,site_name,patient_id,study_instance_uid,series_instance_uid,num_sops,first_loaded,last_loaded}', '{receive_reports}', 'posda_files', 'Series received between dates regardless of duplicates
');
INSERT INTO queries (name, query, args, columns, tags, schema, description) VALUES ('AllSopsReceivedBetweenDatesByCollection', 'select
   distinct project_name, site_name, patient_id,
   study_instance_uid, series_instance_uid, count(*) as num_sops,
   min(first_loaded) as first_loaded, max(last_loaded) as last_loaded
from (
  select 
    distinct project_name, site_name, patient_id,
    study_instance_uid, series_instance_uid, sop_instance_uid,
    count(*) as num_files, sum(num_uploads) as num_uploads,
    min(first_loaded) as first_loaded, max(last_loaded) as last_loaded
  from (
    select
      distinct project_name, site_name, patient_id,
        study_instance_uid, series_instance_uid, sop_instance_uid,
        file_id, count(*) as num_uploads, max(import_time) as last_loaded,
         min(import_time) as first_loaded
    from (
      select
        distinct project_name, site_name, patient_id,
        study_instance_uid, series_instance_uid, sop_instance_uid,
        file_id, import_time
      from
        ctp_file natural join file_patient natural join
        file_study natural join file_series natural join
        file_sop_common natural join file_import natural join
        import_event
      where
        visibility is null and sop_instance_uid in (
          select distinct sop_instance_uid
          from 
            file_import natural join import_event natural join file_sop_common
            natural join ctp_file
          where import_time > ? and import_time < ? and
            project_name = ? and visibility is null
        )
      ) as foo
    group by
      project_name, site_name, patient_id, study_instance_uid, 
      series_instance_uid, sop_instance_uid, file_id
  )as foo
  group by 
    project_name, site_name, patient_id, study_instance_uid, 
    series_instance_uid, sop_instance_uid
) as foo
group by 
  project_name, site_name, patient_id, study_instance_uid, 
  series_instance_uid
', '{start_time,end_time,collection}', '{project_name,site_name,patient_id,study_instance_uid,series_instance_uid,num_sops,first_loaded,last_loaded}', '{receive_reports}', 'posda_files', 'Series received between dates regardless of duplicates
');
INSERT INTO queries (name, query, args, columns, tags, schema, description) VALUES ('DistinctSeriesBySubjectIntake', 'select
  distinct s.series_instance_uid, modality, count(*) as num_images
from
  general_image i, general_series s,
  trial_data_provenance tdp
where
  s.general_series_pk_id = i.general_series_pk_id and
  i.patient_id = ? and i.trial_dp_pk_id = tdp.trial_dp_pk_id and
  tdp.project = ? and
  tdp.dp_site_name = ?
group by series_instance_uid, modality
', '{subject_id,project_name,site_name}', '{series_instance_uid,modality,num_images}', '{by_subject,find_series,intake}', 'intake', 'Get Series in A Collection, Site, Subject
');
INSERT INTO queries (name, query, args, columns, tags, schema, description) VALUES ('AllSubjectsWithNoStatus', 'select
  distinct patient_id, project_name, site_name,
  count(*) as num_files
from
  file_patient natural join ctp_file
where
  patient_id in (
    select 
      distinct patient_id
    from
      file_patient p
    where
       not exists (
         select
           patient_id
         from
            patient_import_status s
         where
            p.patient_id = s.patient_id
       )
  ) 
  and visibility is null
group by patient_id, project_name, site_name
order by project_name, site_name, patient_id
', '{}', '{patient_id,project_name,site_name,num_files}', '{FindSubjects,PatientStatus}', 'posda_files', 'All Subjects With No Patient Import Status
');
INSERT INTO queries (name, query, args, columns, tags, schema, description) VALUES ('AllValuesByElementSig', 'select distinct value, vr, element_signature, equipment_signature, count(*)
from (
select
  distinct series_instance_uid, element_signature, value, vr,
  equipment_signature
from
  scan_event natural join series_scan
  natural join scan_element natural join element_signature
  natural join equipment_signature
  natural join seen_value
where
  scan_event_id = ? and
  element_signature = ?
) as foo
group by value, element_signature, vr, equipment_signature
order by value, element_signature, vr, equipment_signature
', '{scan_id,tag_signature}', '{value,vr,element_signature,equipment_signature,count}', '{tag_usage}', 'posda_phi', 'List of values seen in scan by ElementSignature with VR and count
');
INSERT INTO queries (name, query, args, columns, tags, schema, description) VALUES ('AllVisibleSubjects', 'select
  distinct patient_id,
  patient_import_status as status,
  project_name, site_name,
  count(*) as num_files
from
  file_patient natural join ctp_file natural join patient_import_status
where
  patient_id in (
    select patient_id 
    from
      file_patient natural join ctp_file 
    where
      visibility is null
  ) and
  visibility is null
group by patient_id, status, project_name, site_name
order by project_name, status, site_name, patient_id;
', '{}', '{patient_id,status,project_name,site_name,num_files}', '{FindSubjects,PatientStatus}', 'posda_files', 'Find All Subjects which have at least one visible file
');
INSERT INTO queries (name, query, args, columns, tags, schema, description) VALUES ('AllVisibleSubjectsByCollection', 'select
  distinct patient_id,
  patient_import_status as status,
  project_name, site_name,
  count(*) as num_files
from
  file_patient natural join ctp_file natural join patient_import_status
where
  patient_id in (
    select patient_id 
    from
      file_patient natural join ctp_file 
    where
      project_name = ? and
      visibility is null
  ) and
  visibility is null
group by patient_id, status, project_name, site_name
order by project_name, status, site_name, patient_id;
', '{collection}', '{patient_id,status,project_name,site_name,num_files}', '{FindSubjects,PatientStatus}', 'posda_files', 'Find All Subjects which have at least one visible file
');
INSERT INTO queries (name, query, args, columns, tags, schema, description) VALUES ('AllVrsByElementSig', 'select distinct vr, element_signature, equipment_signature, count(*)
from (
select
  distinct series_instance_uid, element_signature, vr,
  equipment_signature
from
  scan_event natural join series_scan
  natural join scan_element natural join element_signature
  natural join equipment_signature
where
  scan_event_id = ? and
  element_signature = ?
) as foo
group by element_signature, vr, equipment_signature
order by element_signature, vr, equipment_signature
', '{scan_id,tag_signature}', '{vr,element_signature,equipment_signature,count}', '{tag_usage}', 'posda_phi', 'List of values seen in scan by ElementSignature with VR and count
');
INSERT INTO queries (name, query, args, columns, tags, schema, description) VALUES ('AverageSecondsPerFile', 'select avg(seconds_per_file) from (
  select (send_ended - send_started)/number_of_files as seconds_per_file 
  from dicom_send_event where send_ended is not null and number_of_files > 0
  and send_started > ? and send_ended < ?
) as foo
', '{from_date,to_date}', '{avg}', '{send_to_intake}', 'posda_files', 'Average Time to send a file between times
');
INSERT INTO queries (name, query, args, columns, tags, schema, description) VALUES ('ComplexDuplicatePixelData', 'select 
  distinct project_name, site_name, patient_id, series_instance_uid, count(*)
from 
  ctp_file natural join file_patient natural join file_series 
where 
  file_id in (
    select 
      distinct file_id
    from
      file_image natural join image natural join unique_pixel_data
      natural join ctp_file
    where digest in (
      select
        distinct pixel_digest
      from (
        select
          distinct pixel_digest, count(*)
        from (
          select 
            distinct unique_pixel_data_id, pixel_digest, project_name,
            site_name, patient_id, count(*) 
          from (
            select
              distinct unique_pixel_data_id, file_id, project_name,
              site_name, patient_id, 
              unique_pixel_data.digest as pixel_digest 
            from
              image natural join file_image natural join 
              ctp_file natural join file_patient fq
              join unique_pixel_data using(unique_pixel_data_id)
            where visibility is null
          ) as foo 
          group by 
            unique_pixel_data_id, project_name, pixel_digest,
            site_name, patient_id
        ) as foo 
        group by pixel_digest
      ) as foo 
      where count = ?
    )
    and visibility is null
  ) 
group by project_name, site_name, patient_id, series_instance_uid
order by count desc;
', '{count}', '{project_name,site_name,patient_id,series_instance_uid,count}', '{pix_data_dups}', 'posda_files', 'Find series with duplicate pixel count of <n>
');
INSERT INTO queries (name, query, args, columns, tags, schema, description) VALUES ('CountsByCollection', 'select
  distinct
    patient_id, image_type, modality, study_date, study_description,
    series_description, study_instance_uid, series_instance_uid,
    manufacturer, manuf_model_name, software_versions,
    count(distinct sop_instance_uid) as num_sops,
    count(distinct file_id) as num_files
from
  ctp_file join file_patient using(file_id)
  join file_series using(file_id)
  join file_sop_common using(file_id)
  join file_study using(file_id)
  join file_equipment using(file_id)
  left join file_image using(file_id)
  left join image using (image_id)
where
  project_name = ? and visibility is null
group by
  patient_id, image_type, modality, study_date, study_description,
  series_description, study_instance_uid, series_instance_uid,
  manufacturer, manuf_model_name, software_versions
order by
  patient_id, study_instance_uid, series_instance_uid, image_type,
  modality, study_date, study_description,
  series_description,
  manufacturer, manuf_model_name, software_versions
', '{collection}', '{patient_id,image_type,modality,study_date,study_description,series_description,study_instance_uid,series_instance_uid,manufacturer,manuf_model_name,software_versions,num_sops,num_files}', '{counts}', 'posda_files', 'Counts query by Collection
');
INSERT INTO queries (name, query, args, columns, tags, schema, description) VALUES ('GetInsertedSendId', 'select currval(''dicom_send_event_dicom_send_event_id_seq'') as id
', '{}', '{id}', '{NotInteractive,SeriesSendEvent}', 'posda_files', 'Get dicom_send_event_id after creation
For use in scripts.
Not meant for interactive use
');
INSERT INTO queries (name, query, args, columns, tags, schema, description) VALUES ('GetPatientStatus', 'select
  patient_import_status as status
from
  patient_import_status
where
  patient_id = ?
', '{patient_id}', '{status}', '{NotInteractive,PatientStatus,Update}', 'posda_files', NULL);
INSERT INTO queries (name, query, args, columns, tags, schema, description) VALUES ('CountsByCollectionSite', 'select
  distinct
    patient_id, image_type, modality, study_date, study_description,
    series_description, study_instance_uid, series_instance_uid,
    manufacturer, manuf_model_name, software_versions,
    count(distinct sop_instance_uid) as num_sops,
    count(distinct file_id) as num_files
from
  ctp_file join file_patient using(file_id)
  join file_series using(file_id)
  join file_sop_common using(file_id)
  join file_study using(file_id)
  join file_equipment using(file_id)
  left join file_image using(file_id)
  left join image using (image_id)
where
  project_name = ? and site_name = ? and visibility is null
group by
  patient_id, image_type, modality, study_date, study_description,
  series_description, study_instance_uid, series_instance_uid,
  manufacturer, manuf_model_name, software_versions
order by
  patient_id, study_instance_uid, series_instance_uid, image_type,
  modality, study_date, study_description,
  series_description,
  manufacturer, manuf_model_name, software_versions
', '{collection,site}', '{patient_id,image_type,modality,study_date,study_description,series_description,study_instance_uid,series_instance_uid,manufacturer,manuf_model_name,software_versions,num_sops,num_files}', '{counts}', 'posda_files', 'Counts query by Collection, Site
');
INSERT INTO queries (name, query, args, columns, tags, schema, description) VALUES ('CountsByCollectionSiteSubject', 'select
  distinct
    patient_id, image_type, dicom_file_type, modality,
    study_date, study_description,
    series_description, study_instance_uid, series_instance_uid,
    manufacturer, manuf_model_name, software_versions,
    count(distinct sop_instance_uid) as num_sops,
    count(distinct file_id) as num_files
from
  ctp_file join file_patient using(file_id)
  join file_series using(file_id)
  join file_sop_common using(file_id)
  join dicom_file using(file_id)
  join file_study using(file_id)
  join file_equipment using(file_id)
  left join file_image using(file_id)
  left join image using (image_id)
where
  project_name = ? and site_name = ? and patient_id = ?
  and visibility is null
group by
  patient_id, image_type, dicom_file_type, modality,
  study_date, study_description,
  series_description, study_instance_uid, series_instance_uid,
  manufacturer, manuf_model_name, software_versions
order by
  patient_id, study_instance_uid, series_instance_uid, image_type,
  dicom_file_type, modality, study_date, study_description,
  series_description,
  manufacturer, manuf_model_name, software_versions
', '{collection,site,patient_id}', '{patient_id,image_type,dicom_file_type,modality,study_date,study_description,series_description,study_instance_uid,series_instance_uid,manufacturer,manuf_model_name,software_versions,num_sops,num_files}', '{counts}', 'posda_files', 'Counts query by Collection, Site, Subject
');
INSERT INTO queries (name, query, args, columns, tags, schema, description) VALUES ('CreateFileSend', 'insert into dicom_file_send(
  dicom_send_event_id, file_path, status, file_id_sent
) values (
  ?, ?, ?, ?
)
', '{id,path,status,file_id}', NULL, '{NotInteractive,SeriesSendEvent}', 'posda_files', 'Add a file send row
For use in scripts.
Not meant for interactive use
');
INSERT INTO queries (name, query, args, columns, tags, schema, description) VALUES ('DatabaseSize', 'SELECT d.datname AS Name,  pg_catalog.pg_get_userbyid(d.datdba) AS Owner,
    CASE WHEN pg_catalog.has_database_privilege(d.datname, ''CONNECT'')
        THEN pg_catalog.pg_size_pretty(pg_catalog.pg_database_size(d.datname))
        ELSE ''No Access''
    END AS SIZE
FROM pg_catalog.pg_database d
    ORDER BY
    CASE WHEN pg_catalog.has_database_privilege(d.datname, ''CONNECT'')
        THEN pg_catalog.pg_database_size(d.datname)
        ELSE NULL
    END DESC -- nulls first
    LIMIT 20;
', '{}', '{Name,Owner,Size}', '{postgres_status}', 'posda_files', 'Show active queries for a database
Works for PostgreSQL 9.4.5 (Current Mac)
');
INSERT INTO queries (name, query, args, columns, tags, schema, description) VALUES ('DatesOfUploadByCollectionSite', 'select distinct date_trunc as date, count(*) as num_uploads from (
 select 
  date_trunc(''day'', import_time),
  file_id
from file_import natural join import_event
  natural join ctp_file
where project_name = ? and site_name = ? 
) as foo
group by date
order by date
', '{collection,site}', '{date,num_uploads}', '{receive_reports}', 'posda_files', 'Show me the dates with uploads for Collection from Site
');
INSERT INTO queries (name, query, args, columns, tags, schema, description) VALUES ('DatesOfUploadByCollectionSiteVisible', 'select distinct date_trunc as date, count(*) as num_uploads from (
 select 
  date_trunc(''day'', import_time),
  file_id
from file_import natural join import_event natural join file_sop_common
  natural join ctp_file
where project_name = ? and site_name = ? and visibility is null
) as foo
group by date
order by date
', '{collection,site}', '{date,num_uploads}', '{receive_reports}', 'posda_files', 'Show me the dates with uploads for Collection from Site
');
INSERT INTO queries (name, query, args, columns, tags, schema, description) VALUES ('DiskSpaceByCollection', 'select
  distinct project_name as collection, sum(size) as total_bytes
from
  ctp_file natural join file
where
  file_id in (
  select distinct file_id
  from ctp_file
  where project_name = ?
  )
group by project_name
', '{collection}', '{collection,total_bytes}', '{by_collection,posda_files,storage_used}', 'posda_files', 'Get disk space used by collection
');
INSERT INTO queries (name, query, args, columns, tags, schema, description) VALUES ('DiskSpaceByCollectionSummary', 'select
  distinct project_name as collection, sum(size) as total_bytes
from
  ctp_file natural join file
where
  file_id in (
  select distinct file_id
  from ctp_file
  )
group by project_name
order by total_bytes
', '{}', '{collection,total_bytes}', '{by_collection,posda_files,storage_used,summary}', 'posda_files', 'Get disk space used for all collections
');
INSERT INTO queries (name, query, args, columns, tags, schema, description) VALUES ('DistinctSeriesByCollection', 'select distinct series_instance_uid, modality, count(*)
from (
select distinct series_instance_uid, sop_instance_uid, modality from (
select
   distinct series_instance_uid, modality, sop_instance_uid,
   file_id
 from file_series natural join file_sop_common
   natural join ctp_file
where
  project_name = ? 
  and visibility is null)
as foo
group by series_instance_uid, sop_instance_uid, modality)
as foo
group by series_instance_uid, modality
', '{project_name}', '{series_instance_uid,modality,count}', '{by_collection,find_series}', 'posda_files', 'Get Series in A Collection
');
INSERT INTO queries (name, query, args, columns, tags, schema, description) VALUES ('DistinctSeriesBySubject', 'select distinct series_instance_uid, modality, count(*)
from (
select distinct series_instance_uid, sop_instance_uid, modality from (
select
   distinct series_instance_uid, modality, sop_instance_uid,
   file_id
 from file_series natural join file_sop_common
   natural join file_patient natural join ctp_file
where
  patient_id = ? and project_name = ? 
  and site_name = ? and visibility is null)
as foo
group by series_instance_uid, sop_instance_uid, modality)
as foo
group by series_instance_uid, modality
', '{subject_id,project_name,site_name}', '{series_instance_uid,modality,count}', '{by_subject,find_series}', 'posda_files', 'Get Series in A Collection, Site, Subject
');
INSERT INTO queries (name, query, args, columns, tags, schema, description) VALUES ('GetPatientStautus', NULL, NULL, NULL, '{}', NULL, 'Get Current Patient Status
For use in scripts
Not really intended for interactive use
');
INSERT INTO queries (name, query, args, columns, tags, schema, description) VALUES ('DistinctSeriesBySubjectPublic', 'select
  distinct s.series_instance_uid, modality, count(*) as num_images
from
  general_image i, general_series s,
  trial_data_provenance tdp
where
  s.general_series_pk_id = i.general_series_pk_id and
  i.patient_id = ? and i.trial_dp_pk_id = tdp.trial_dp_pk_id and
  tdp.project = ?
group by series_instance_uid, modality
', '{subject_id,project_name}', '{series_instance_uid,modality,num_images}', '{by_subject,find_series,intake}', 'public', 'Get Series in A Collection, Site, Subject
');
INSERT INTO queries (name, query, args, columns, tags, schema, description) VALUES ('DistinctSopsInCollection', 'select distinct sop_instance_uid
from
  file_sop_common
where file_id in (
  select
    distinct file_id
  from
    ctp_file
  where
    project_name = ? and visibility is null
)
order by sop_instance_uid
', '{collection}', '{sop_instance_uid}', '{by_collection,posda_files,sops}', 'posda_files', 'Get Distinct SOPs in Collection with number files
Only visible files
');
INSERT INTO queries (name, query, args, columns, tags, schema, description) VALUES ('DistinctSopsInCollectionByStorageClass', 'select distinct sop_instance_uid, rel_path
from
  file_sop_common natural join file_location natural join file_storage_root
where file_id in (
  select
    distinct file_id
  from
    ctp_file natural join file_location natural join file_storage_root
  where
    project_name = ? and visibility is null and storage_class = ?
) and current
order by sop_instance_uid
', '{collection,storage_class}', '{sop_instance_uid,rel_path}', '{by_collection,posda_files,sops}', 'posda_files', 'Get Distinct SOPs in Collection with number files
Only visible files
');
INSERT INTO queries (name, query, args, columns, tags, schema, description) VALUES ('DistinctSopsInCollectionIntake', 'select
  distinct i.sop_instance_uid
from
  general_image i,
  trial_data_provenance tdp
where
  i.trial_dp_pk_id = tdp.trial_dp_pk_id and
  tdp.project = ?
order by sop_instance_uid
', '{collection}', '{sop_instance_uid}', '{by_collection,intake,sops}', 'intake', 'Get Distinct SOPs in Collection with number files
Only visible files
');
INSERT INTO queries (name, query, args, columns, tags, schema, description) VALUES ('DistinctSopsInCollectionIntakeWithFile', 'select
  distinct i.sop_instance_uid, i.dicom_file_uri
from
  general_image i,
  trial_data_provenance tdp
where
  i.trial_dp_pk_id = tdp.trial_dp_pk_id and
  tdp.project = ?
order by sop_instance_uid
', '{collection}', '{sop_instance_uid,dicom_file_uri}', '{by_collection,files,intake,sops}', 'intake', 'Get Distinct SOPs in Collection with number files
Only visible files
');
INSERT INTO queries (name, query, args, columns, tags, schema, description) VALUES ('DistinctSopsInSeries', 'select distinct sop_instance_uid, count(*)
from file_sop_common
where file_id in (
  select
    distinct file_id
  from
    file_series natural join ctp_file
  where
    series_instance_uid = ? and visibility is null
)
group by sop_instance_uid
order by count desc
', '{series_instance_uid}', '{sop_instance_uid,count}', '{by_series_instance_uid,duplicates,posda_files,sops}', 'posda_files', 'Get Distinct SOPs in Series with number files
Only visible filess
');
INSERT INTO queries (name, query, args, columns, tags, schema, description) VALUES ('DistinctUnhiddenFilesInSeries', 'select
  distinct file_id
from
  file_series natural join file_sop_common natural join ctp_file
where
  series_instance_uid = ? and visibility is null
', '{series_instance_uid}', '{file_id}', '{by_series_instance_uid,file_ids,posda_files}', 'posda_files', 'Get Distinct Unhidden Files in Series
');
INSERT INTO queries (name, query, args, columns, tags, schema, description) VALUES ('DistinctValuesByTagWithFileCount', 'select distinct element_signature, value, count(*) as num_files
from (
select
  distinct series_instance_uid,
  series_scanned_file as file, 
  element_signature, value
from
  scan_event natural join series_scan natural join seen_value
  natural join element_signature natural join 
  scan_element natural left join sequence_index
where
  element_signature = ?
order by series_instance_uid, file, value
) as foo
group by element_signature, value
', '{tag}', '{element_signature,value,num_files}', '{tag_usage}', 'posda_phi', 'Distinct values for a tag with file count
');
INSERT INTO queries (name, query, args, columns, tags, schema, description) VALUES ('DupSopCountsByCSS', 'select
  distinct sop_instance_uid, min, max, count
from (
  select
    distinct sop_instance_uid, min(file_id),
    max(file_id),count(*)
  from (
    select
      distinct sop_instance_uid, file_id
    from
      file_sop_common 
    where sop_instance_uid in (
      select
        distinct sop_instance_uid
      from
        file_sop_common natural join ctp_file
        natural join file_patient
      where
        project_name = ? and site_name = ? 
        and patient_id = ? and visibility is null
    )
  ) as foo natural join ctp_file
  where visibility is null
  group by sop_instance_uid
)as foo where count > 1
', '{collection,site,subject}', '{sop_instance_uid,min,max,count}', '{}', 'posda_files', 'Counts of DuplicateSops By Collection, Site, Subject
');
INSERT INTO queries (name, query, args, columns, tags, schema, description) VALUES ('DupSopsReceivedBetweenDates', 'select
   distinct project_name, site_name, patient_id,
   study_instance_uid, series_instance_uid, count(*) as num_sops,
   sum(num_files) as num_files, sum(num_uploads) as num_uploads,
    min(first_loaded) as first_loaded, max(last_loaded) as last_loaded
from (
  select 
    distinct project_name, site_name, patient_id,
    study_instance_uid, series_instance_uid, sop_instance_uid,
    count(*) as num_files, sum(num_uploads) as num_uploads,
    min(first_loaded) as first_loaded, max(last_loaded) as last_loaded
  from (
    select
      distinct project_name, site_name, patient_id,
        study_instance_uid, series_instance_uid, sop_instance_uid,
        file_id, count(*) as num_uploads, max(import_time) as last_loaded,
         min(import_time) as first_loaded
    from (
      select
        distinct project_name, site_name, patient_id,
        study_instance_uid, series_instance_uid, sop_instance_uid,
        file_id, import_time
      from
        ctp_file natural join file_patient natural join
        file_study natural join file_series natural join
        file_sop_common natural join file_import natural join
        import_event
      where
        visibility is null and sop_instance_uid in (
          select distinct sop_instance_uid
          from 
            file_import natural join import_event natural join file_sop_common
          where import_time > ? and import_time < ?
        )
      ) as foo
    group by
      project_name, site_name, patient_id, study_instance_uid, 
      series_instance_uid, sop_instance_uid, file_id
  )as foo
  group by 
    project_name, site_name, patient_id, study_instance_uid, 
    series_instance_uid, sop_instance_uid
) as foo
where num_uploads > 1
group by 
  project_name, site_name, patient_id, study_instance_uid, 
  series_instance_uid
', '{start_time,end_time}', '{project_name,site_name,patient_id,study_instance_uid,series_instance_uid,num_sops,num_files,num_uploads,first_loaded,last_loaded}', '{receive_reports}', 'posda_files', 'Series received between dates with duplicate sops
');
INSERT INTO queries (name, query, args, columns, tags, schema, description) VALUES ('DupSopsReceivedBetweenDatesByCollection', 'select
   distinct project_name, site_name, patient_id,
   study_instance_uid, series_instance_uid, count(*) as num_sops,
   sum(num_files) as num_files, sum(num_uploads) as num_uploads,
    min(first_loaded) as first_loaded, max(last_loaded) as last_loaded
from (
  select 
    distinct project_name, site_name, patient_id,
    study_instance_uid, series_instance_uid, sop_instance_uid,
    count(*) as num_files, sum(num_uploads) as num_uploads,
    min(first_loaded) as first_loaded, max(last_loaded) as last_loaded
  from (
    select
      distinct project_name, site_name, patient_id,
        study_instance_uid, series_instance_uid, sop_instance_uid,
        file_id, count(*) as num_uploads, max(import_time) as last_loaded,
         min(import_time) as first_loaded
    from (
      select
        distinct project_name, site_name, patient_id,
        study_instance_uid, series_instance_uid, sop_instance_uid,
        file_id, import_time
      from
        ctp_file natural join file_patient natural join
        file_study natural join file_series natural join
        file_sop_common natural join file_import natural join
        import_event
      where
        visibility is null and sop_instance_uid in (
          select distinct sop_instance_uid
          from 
            file_import natural join import_event natural join file_sop_common
             natural join ctp_file
          where import_time > ? and import_time < ?
            and project_name = ? and visibility is null
        )
      ) as foo
    group by
      project_name, site_name, patient_id, study_instance_uid, 
      series_instance_uid, sop_instance_uid, file_id
  )as foo
  group by 
    project_name, site_name, patient_id, study_instance_uid, 
    series_instance_uid, sop_instance_uid
) as foo
where num_uploads > 1
group by 
  project_name, site_name, patient_id, study_instance_uid, 
  series_instance_uid
', '{start_time,end_time,collection}', '{project_name,site_name,patient_id,study_instance_uid,series_instance_uid,num_sops,num_files,num_uploads,first_loaded,last_loaded}', '{receive_reports}', 'posda_files', 'Series received between dates with duplicate sops
');
INSERT INTO queries (name, query, args, columns, tags, schema, description) VALUES ('GetPrivateTagFeaturesBySignature', 'select
  pt_consensus_name as name,
  pt_consensus_vr as vr,
  pt_consensus_disposition as disposition
from pt
where pt_signature = ?
', '{signature}', '{name,vr,disposition}', '{DispositionReport,NotInteractive}', 'posda_private_tag', 'Get the relevant features of a private tag by signature
Used in DispositionReport.pl - not for interactive use
');
INSERT INTO queries (name, query, args, columns, tags, schema, description) VALUES ('DuplicateDownloadsByCollection', 'select distinct patient_id, series_instance_uid, count(*)
from file_series natural join file_patient
where file_id in (
  select file_id from (
    select
      distinct file_id, count(*)
    from file_import
    where file_id in (
      select
        distinct file_id
      from 
        file_patient natural join ctp_file
      where
        project_name = ? 
        and site_name = ? and visibility is null
    )
    group by file_id
  ) as foo
  where count > 1
)
group by patient_id, series_instance_uid
order by patient_id
', '{project_name,site_name}', '{series_instance_uid,count}', '{by_collection,duplicates,find_series}', 'posda_files', 'Number of files for a subject which have been downloaded more than once
');
INSERT INTO queries (name, query, args, columns, tags, schema, description) VALUES ('DuplicateDownloadsBySubject', 'select count(*) from (
  select
    distinct file_id, count(*)
  from file_import
  where file_id in (
    select
      distinct file_id
    from 
      file_patient natural join ctp_file
    where
      patient_id = ? and project_name = ? 
      and site_name = ? and visibility is null
  )
  group by file_id
) as foo
where count > 1
', '{subject_id,project_name,site_name}', '{count}', '{by_subject,duplicates,find_series}', 'posda_files', 'Number of files for a subject which have been downloaded more than once
');
INSERT INTO queries (name, query, args, columns, tags, schema, description) VALUES ('DuplicateFilesBySop', 'select
  distinct
    project_name as collection, site_name as site,
    patient_id, sop_instance_uid, modality, file_id,
    root_path || ''/'' || rel_path as file_path,
    count(*) as num_uploads,
    min(import_time) as first_upload, 
    max(import_time) as last_upload
from
  ctp_file natural join file_patient natural join file_sop_common
  natural join file_series natural join file_location natural join
  file_storage_root natural join file_import natural join
  import_event
where
  sop_instance_uid = ?
group by
  project_name, site_name, patient_id, sop_instance_uid, modality, 
  file_id, file_path
order by
  collection, site, patient_id, sop_instance_uid, modality
', '{sop_instance_uid}', '{collection,site,patient_id,sop_instance_uid,modality,file_id,file_path,num_uploads,first_upload,last_upload}', '{duplicates}', 'posda_files', 'Counts query by Collection, Site
');
INSERT INTO queries (name, query, args, columns, tags, schema, description) VALUES ('DuplicatePixelDataByProject', 'select image_id, file_id
from file_image where image_id in (
  select image_id
  from (
    select distinct image_id, count(*)
    from (
      select distinct image_id, file_id 
      from file_image
      where file_id in (
        select
          distinct file_id 
        from ctp_file
        where project_name = ? and visibility is null
      )
    ) as foo
    group by image_id
  ) as foo
  where count > 1
)
order by image_id;
', '{collection}', '{image_id,file_id}', '{}', 'posda_files', 'Return a list of files with duplicate pixel data
');
INSERT INTO queries (name, query, args, columns, tags, schema, description) VALUES ('DuplicatePixelDataThatMatters', 'select image_id, count from (
  select distinct image_id, count(*)
  from (
    select distinct image_id, file_id
    from (
      select
        file_id, image_id, patient_id, study_instance_uid, 
        series_instance_uid, sop_instance_uid, modality
      from
        file_patient natural join file_series natural join 
        file_study natural join file_sop_common
        natural join file_image
      where file_id in (
        select file_id
        from (
          select image_id, file_id 
          from file_image 
          where image_id in (
            select image_id
            from (
              select distinct image_id, count(*)
              from (
                select distinct image_id, file_id
                from file_image where file_id in (
                  select distinct file_id
                  from ctp_file
                  where project_name = ? and visibility is null
                )
              ) as foo
              group by image_id
            ) as foo 
            where count > 1
          )
        ) as foo
      )
    ) as foo
  ) as foo
  group by image_id
) as foo 
where count > 1;
', '{collection}', '{image_id,count}', '{}', 'posda_files', 'Return a list of files with duplicate pixel data,
restricted to those files which have parsed DICOM data
representations in Database.
');
INSERT INTO queries (name, query, args, columns, tags, schema, description) VALUES ('DuplicateSOPInstanceUIDs', 'select
  sop_instance_uid, min(file_id) as first,
  max(file_id) as last, count(*)
from file_sop_common
where sop_instance_uid in (
  select distinct sop_instance_uid from (
    select distinct sop_instance_uid, count(*) from (
      select distinct file_id, sop_instance_uid 
      from
        ctp_file natural join file_sop_common
        natural join file_patient
      where project_name = ? and site_name = ? and patient_id = ?
    ) as foo natural join ctp_file
    where visibility is null
    group by sop_instance_uid order by count desc
  ) as foo where count > 1
) group by sop_instance_uid;
', '{collection,site,subject}', '{sop_instance_uid,first,last,count}', '{duplicates}', 'posda_files', 'Return a count of duplicate SOP Instance UIDs
');
INSERT INTO queries (name, query, args, columns, tags, schema, description) VALUES ('DuplicateSOPInstanceUIDsByCollectionWithoutHidden1', 'select
  distinct project_name as collection,
  site_name as site, patient_id,
  study_instance_uid, series_instance_uid
from file_sop_common natural join ctp_file natural join file_patient
  natural join file_study natural join file_series
where sop_instance_uid in (
  select distinct sop_instance_uid from (
    select distinct sop_instance_uid, count(*) from (
      select distinct file_id, sop_instance_uid 
      from
        ctp_file natural join file_sop_common
        natural join file_patient
    ) as foo natural join ctp_file
    group by sop_instance_uid order by count desc
  ) as foo where count > 1
) group by project_name, site_name, patient_id, study_instance_uid, 
  series_instance_uid
', '{}', '{collection,site,patient_id,study_instance_uid,series_instance_uid}', '{receive_reports}', 'posda_files', 'Return a count of visible duplicate SOP Instance UIDs
');
INSERT INTO queries (name, query, args, columns, tags, schema, description) VALUES ('DuplicateSOPInstanceUIDsGlobalWithHidden', 'select distinct collection, site, patient_id, count(*)
from (
select 
  distinct collection, site, patient_id, sop_instance_uid, count(*)
  as dups
from (
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
        natural join file_patient
    ) as foo
    group by sop_instance_uid order by count desc
  ) as foo where count > 1
) group by project_name, site_name, patient_id, study_instance_uid, 
  series_instance_uid, sop_instance_uid, file_id
) as foo
group by collection, site, patient_id, sop_instance_uid
) as foo where dups > 1
group by collection, site, patient_id
order by collection, site, patient_id
', '{}', '{collection,site,patient_id,count}', '{receive_reports}', 'posda_files', 'Return a report of duplicate SOP Instance UIDs ignoring visibility
');
INSERT INTO queries (name, query, args, columns, tags, schema, description) VALUES ('DuplicateSOPInstanceUIDsGlobalWithoutHidden', 'select
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
', '{}', '{collection,site,patient_id,study_instance_uid,series_instance_uid,sop_instance_uid,file_id}', '{receive_reports}', 'posda_files', 'Return a report of visible duplicate SOP Instance UIDs
');
INSERT INTO queries (name, query, args, columns, tags, schema, description) VALUES ('DuplicateSopsInSeries', 'select
  sop_instance_uid, import_time, file_id
from 
  file_sop_common
  natural join file_import natural join import_event
where sop_instance_uid in (
select sop_instance_uid from (
select
  distinct sop_instance_uid, count(distinct file_id) 
from
  file_sop_common natural join file_series
where
  series_instance_uid = ?
group by sop_instance_uid
) as foo
where count > 1
)
order by sop_instance_uid, import_time
', '{series_instance_uid}', '{sop_instance_uid,import_time,file_id}', '{by_series}', 'posda_files', 'List of Actual duplicate SOPs (i.e. different files, same SOP)
in a series
');
INSERT INTO queries (name, query, args, columns, tags, schema, description) VALUES ('ElementScanIdByScanValueTag', 'select 
  distinct scan_element_id
from
  scan_element natural join element_signature
  natural join series_scan natural join seen_value
  natural join scan_event
where
  scan_event_id = ? and
  value = ? and
  element_signature = ?
', '{scan_id,value,tag}', '{scan_element_id}', '{tag_usage}', 'posda_phi', 'Find out where specific value, tag combinations occur in a scan
');
INSERT INTO queries (name, query, args, columns, tags, schema, description) VALUES ('ElementsWithMultipleVRs', 'select element_signature, count from (
  select element_signature, count(*)
  from (
    select
      distinct element_signature, vr
    from
      scan_event natural join series_scan
      natural join scan_element natural join element_signature
      natural join equipment_signature
    where
      scan_event_id = ?
  ) as foo
  group by element_signature
) as foo
where count > 1
', '{scan_id}', '{element_signature,count}', '{tag_usage}', 'posda_phi', 'List of Elements with multiple VRs seen
');
INSERT INTO queries (name, query, args, columns, tags, schema, description) VALUES ('EquipmentByPrivateTag', 'select distinct equipment_signature from (
select
  distinct element_signature, equipment_signature
from 
  equipment_signature natural join series_scan
  natural join scan_element natural join element_signature
  natural join scan_event
where scan_event_id = ? and is_private ) as foo
where element_signature = ?
order by equipment_signature;
', '{scan_id,element_signature}', '{equipment_signature}', '{tag_usage}', 'posda_phi', 'Which equipment signatures for which private tags
');
INSERT INTO queries (name, query, args, columns, tags, schema, description) VALUES ('EquipmentByValueSignature', 'select distinct value, vr, element_signature, equipment_signature, count(*)
from (
select
  distinct series_instance_uid, element_signature, value, vr,
  equipment_signature
from
  scan_event natural join series_scan
  natural join scan_element natural join element_signature
  natural join equipment_signature
  natural join seen_value
where
  scan_event_id = ? and
  value = ? and
  element_signature = ?
) as foo
group by value, element_signature, vr, equipment_signature
order by value, element_signature, vr, equipment_signature
', '{scan_id,value,tag_signature}', '{value,vr,element_signature,equipment_signature,count}', '{tag_usage}', 'posda_phi', 'List of equipment, values seen in scan by VR with count
');
INSERT INTO queries (name, query, args, columns, tags, schema, description) VALUES ('FilesAndLoadTimesInSeries', 'select
  distinct sop_instance_uid, file_id, import_time
from
  file_sop_common natural join file_series
  natural join file_import natural join import_event
where
  series_instance_uid = ?
order by 
  sop_instance_uid, import_time, file_id
', '{series_instance_uid}', '{sop_instance_uid,import_time,file_id}', '{by_series}', 'posda_files', 'List of SOPs, files, and import times in a series
');
INSERT INTO queries (name, query, args, columns, tags, schema, description) VALUES ('FilesByScanValueTag', 'select
  distinct series_instance_uid,
  series_scanned_file as file, 
  element_signature, sequence_level,
  item_number
from
  scan_event natural join series_scan natural join seen_value
  natural join element_signature natural join 
  scan_element natural left join sequence_index
where
  scan_event_id = ? and value = ? and element_signature = ?
order by series_instance_uid, file
', '{scan_id,value,tag}', '{series_instance_uid,file,element_signature,sequence_level,item_number}', '{tag_usage}', 'posda_phi', 'Find out where specific value, tag combinations occur in a scan
');
INSERT INTO queries (name, query, args, columns, tags, schema, description) VALUES ('FilesByScanWithValue', 'select
  distinct series_instance_uid,
  series_scanned_file as file, 
  element_signature, value
from
  scan_event natural join series_scan natural join seen_value
  natural join element_signature natural join 
  scan_element natural left join sequence_index
where
  scan_event_id = ? and element_signature = ?
order by series_instance_uid, file, value
', '{scan_id,tag}', '{series_instance_uid,file,element_signature,value}', '{tag_usage}', 'posda_phi', 'Find out where specific value, tag combinations occur in a scan
');
INSERT INTO queries (name, query, args, columns, tags, schema, description) VALUES ('FilesByTagWithValue', 'select
  distinct series_instance_uid,
  series_scanned_file as file, 
  element_signature, value
from
  scan_event natural join series_scan natural join seen_value
  natural join element_signature natural join 
  scan_element natural left join sequence_index
where
  element_signature = ?
order by series_instance_uid, file, value
', '{tag}', '{series_instance_uid,file,element_signature,value}', '{tag_usage}', 'posda_phi', 'Find out where specific value, tag combinations occur in a scan
');
INSERT INTO queries (name, query, args, columns, tags, schema, description) VALUES ('FilesInCollectionSiteForSend', 'select
  distinct file_id, root_path || ''/'' || rel_path as path, 
  xfer_syntax, sop_class_uid,
  data_set_size, data_set_start, sop_instance_uid, digest
from
  file_location natural join file_storage_root
  natural join dicom_file natural join ctp_file
  natural join file_sop_common natural join file_series
  natural join file_meta natural join file
where
  project_name = ? and site_name = ? and visibility is null
', '{collection,site}', '{file_id,path,xfer_syntax,sop_class_uid,data_set_size,data_set_start,sop_instance_uid,digest}', '{by_collection_site,find_files,for_send}', 'posda_files', 'Get everything you need to negotiate a presentation_context
for all files in a Collection Site
');
INSERT INTO queries (name, query, args, columns, tags, schema, description) VALUES ('FilesInSeriesForSend', 'select
  distinct file_id, root_path || ''/'' || rel_path as path, xfer_syntax, sop_class_uid,
  data_set_size, data_set_start, sop_instance_uid, digest
from
  file_location natural join file_storage_root
  natural join dicom_file natural join ctp_file
  natural join file_sop_common natural join file_series
  natural join file_meta natural join file
where
  series_instance_uid = ? and visibility is null
', '{series_instance_uid}', '{file_id,path,xfer_syntax,sop_class_uid,data_set_size,data_set_start,sop_instance_uid,digest}', '{SeriesSendEvent,by_series,find_files,for_send}', 'posda_files', 'Get everything you need to negotiate a presentation_context
for all files in a series
');
INSERT INTO queries (name, query, args, columns, tags, schema, description) VALUES ('FilesWithIndicesByElementScanId', 'select
  distinct series_instance_uid,
  series_scanned_file as file, 
  element_signature, sequence_level,
  item_number
from
  series_scan natural join element_signature natural join 
  scan_element natural left join sequence_index
where
  scan_element_id = ?
', '{scan_element_id}', '{series_instance_uid,file,element_signature,sequence_level,item_number}', '{tag_usage}', 'posda_phi', 'Find out where specific value, tag combinations occur in a scan
');
INSERT INTO queries (name, query, args, columns, tags, schema, description) VALUES ('FindInconsistentSeries', 'select series_instance_uid from (
select distinct series_instance_uid, count(*) from (
  select distinct
    series_instance_uid, modality, series_number, laterality, series_date,
    series_time, performing_phys, protocol_name, series_description,
    operators_name, body_part_examined, patient_position,
    smallest_pixel_value, largest_pixel_value, performed_procedure_step_id,
    performed_procedure_step_start_date, performed_procedure_step_start_time,
    performed_procedure_step_desc, performed_procedure_step_comments,
    count(*)
  from
    file_series natural join ctp_file
  where
    project_name = ? and visibility is null
  group by
    series_instance_uid, modality, series_number, laterality, series_date,
    series_time, performing_phys, protocol_name, series_description,
    operators_name, body_part_examined, patient_position,
    smallest_pixel_value, largest_pixel_value, performed_procedure_step_id,
    performed_procedure_step_start_date, performed_procedure_step_start_time,
    performed_procedure_step_desc, performed_procedure_step_comments
) as foo
group by series_instance_uid
) as foo
where count > 1
', '{collection}', '{series_instance_uid}', '{consistency,find_series}', 'posda_files', 'Find Inconsistent Series
');
INSERT INTO queries (name, query, args, columns, tags, schema, description) VALUES ('FindInconsistentSeriesExtended', 'select series_instance_uid from (
select distinct series_instance_uid, count(*) from (
  select distinct
    series_instance_uid, modality, series_number, laterality, series_date,
    series_time, performing_phys, protocol_name, series_description,
    operators_name, body_part_examined, patient_position,
    smallest_pixel_value, largest_pixel_value, performed_procedure_step_id,
    performed_procedure_step_start_date, performed_procedure_step_start_time,
    performed_procedure_step_desc, performed_procedure_step_comments,
    image_type, count(*)
  from
    file_series natural join ctp_file
    left join file_image using(file_id)
    left join image using(image_id)
  where
    project_name = ? and visibility is null
  group by
    series_instance_uid, image_type,
    modality, series_number, laterality, series_date,
    series_time, performing_phys, protocol_name, series_description,
    operators_name, body_part_examined, patient_position,
    smallest_pixel_value, largest_pixel_value, performed_procedure_step_id,
    performed_procedure_step_start_date, performed_procedure_step_start_time,
    performed_procedure_step_desc, performed_procedure_step_comments
) as foo
group by series_instance_uid
) as foo
where count > 1
', '{collection}', '{series_instance_uid}', '{consistency,find_series}', 'posda_files', 'Find Inconsistent Series Extended to include image type
');
INSERT INTO queries (name, query, args, columns, tags, schema, description) VALUES ('FindInconsistentStudy', 'select distinct study_instance_uid from (
  select distinct study_instance_uid, count(*) from (
    select distinct
      study_instance_uid, study_date, study_time,
      referring_phy_name, study_id, accession_number,
      study_description, phys_of_record, phys_reading,
      admitting_diag
    from
      file_study natural join ctp_file
    where
      project_name = ? and visibility is null
    group by
      study_instance_uid, study_date, study_time,
      referring_phy_name, study_id, accession_number,
      study_description, phys_of_record, phys_reading,
      admitting_diag
  ) as foo
  group by study_instance_uid
) as foo
where count > 1
', '{collection}', '{study_instance_uid}', '{by_study,consistency}', 'posda_files', 'Find Inconsistent Studies
');
INSERT INTO queries (name, query, args, columns, tags, schema, description) VALUES ('FirstFileInSeriesIntake', 'select
  dicom_file_uri as path
from
  general_image
where
  series_instance_uid =  ?
limit 1
', '{series_instance_uid}', '{path}', '{by_series,intake}', 'intake', 'First files in series in Intake
');
INSERT INTO queries (name, query, args, columns, tags, schema, description) VALUES ('FirstFileInSeriesPosda', 'select root_path || ''/'' || rel_path as path
from file_location natural join file_storage_root
where file_id in (
select file_id from 
  (
  select 
    distinct sop_instance_uid, min(file_id) as file_id
  from 
    file_series natural join ctp_file 
    natural join file_sop_common
  where 
    series_instance_uid = ?
    and visibility is null
  group by sop_instance_uid
) as foo)
limit 1
', '{series_instance_uid}', '{path}', '{by_series}', 'posda_files', 'First files in series in Posda
');
INSERT INTO queries (name, query, args, columns, tags, schema, description) VALUES ('FirstFilesInSeries', 'select root_path || ''/'' || rel_path as path
from file_location natural join file_storage_root
where file_id in (
select file_id from 
  (
  select 
    distinct sop_instance_uid, min(file_id) as file_id
  from 
    file_series natural join ctp_file 
    natural join file_sop_common
  where 
    series_instance_uid = ?
    and visibility is null
  group by sop_instance_uid
) as foo);
', '{series_instance_uid}', '{path}', '{by_series}', 'posda_files', 'First files uploaded by series
');
INSERT INTO queries (name, query, args, columns, tags, schema, description) VALUES ('GetInfoForDupFilesByCollection', 'select
  file_id, image_id, patient_id, study_instance_uid, series_instance_uid,
   sop_instance_uid, modality
from
  file_patient natural join file_series natural join file_study
  natural join file_sop_common natural join file_image
where file_id in (
  select file_id
  from (
    select image_id, file_id
    from file_image
    where image_id in (
      select image_id
      from (
        select distinct image_id, count(*)
        from (
          select distinct image_id, file_id
          from file_image
          where file_id in (
            select
              distinct file_id
              from ctp_file
              where project_name = ? and visibility is null
          )
        ) as foo
        group by image_id
      ) as foo 
      where count > 1
    )
  ) as foo
);
', '{collection}', '{file_id,image_id,patient_id,study_instance_uid,series_instance_uid,sop_instance_uid,modality}', '{}', 'posda_files', 'Get information related to duplicate files by collection
');
INSERT INTO queries (name, query, args, columns, tags, schema, description) VALUES ('GetPublicTagDispositionBySignature', 'select
  disposition
from public_tag_disposition
where tag_name = ?
', '{signature}', '{disposition}', '{DispositionReport,NotInteractive}', 'posda_public_tag', 'Get the disposition of a public tag by signature
Used in DispositionReport.pl - not for interactive use
');
INSERT INTO queries (name, query, args, columns, tags, schema, description) VALUES ('GetSeriesSignature', 'select distinct
  dicom_file_type, modality|| '':'' || coalesce(manufacturer, ''<undef>'') || '':'' 
  || coalesce(manuf_model_name, ''<undef>'') ||
  '':'' || coalesce(software_versions, ''<undef>'') as signature,
  count(distinct series_instance_uid) as num_series,
  count(distinct file_id) as num_files
from
  file_series natural join file_equipment natural join ctp_file
  natural join dicom_file
where project_name = ?
group by dicom_file_type, signature
', '{collection}', '{dicom_file_type,signature,num_series,num_files}', '{signature}', 'posda_files', 'Get a list of Series Signatures by Collection
');
INSERT INTO queries (name, query, args, columns, tags, schema, description) VALUES ('GetSeriesWithSignature', 'select distinct
  series_instance_uid, dicom_file_type, 
  modality|| '':'' || coalesce(manufacturer, ''<undef>'') || '':'' 
  || coalesce(manuf_model_name, ''<undef>'') ||
  '':'' || coalesce(software_versions, ''<undef>'') as signature,
  count(distinct series_instance_uid) as num_series,
  count(distinct file_id) as num_files
from
  file_series natural join file_equipment natural join ctp_file
  natural join dicom_file
where project_name = ? and visibility is null
group by series_instance_uid, dicom_file_type, signature
', '{collection}', '{series_instance_uid,dicom_file_type,signature,num_series,num_files}', '{signature}', 'posda_files', 'Get a list of Series with Signatures by Collection
');
INSERT INTO queries (name, query, args, columns, tags, schema, description) VALUES ('GetSlopeIntercept', 'select
  slope, intercept, si_units
from
  file_slope_intercept natural join slope_intercept
where
  file_id = ?
', '{file_id}', '{slope,intercept,si_units}', '{by_file_id,posda_files,slope_intercept}', 'posda_files', 'Get a Slope, Intercept for a particular file 
');
INSERT INTO queries (name, query, args, columns, tags, schema, description) VALUES ('GetValueForTag', 'select
  series_instance_uid, element_signature as tag, value
from
  scan_element natural join series_scan natural join
  seen_value natural join element_signature
where element_signature = ? and scan_event_id = ?
', '{tag,scan_id}', '{series_instance_uid,tag,value}', '{tag_values}', 'posda_phi', 'Find Values for a given tag for all scanned series in a phi scan instance
');
INSERT INTO queries (name, query, args, columns, tags, schema, description) VALUES ('GetWinLev', 'select
  window_width, window_center, win_lev_desc, wl_index
from
  file_win_lev natural join window_level
where
  file_id = ?
order by wl_index desc;
', '{file_id}', '{window_width,window_center,win_lev_desc,wl_index}', '{by_file_id,posda_files,window_level}', 'posda_files', 'Get a Window, Level(s) for a particular file 
');
INSERT INTO queries (name, query, args, columns, tags, schema, description) VALUES ('GlobalUnhiddenSOPDuplicatesSummary', 'select 
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
', '{}', '{collection,site,patient_id,study_instance_uid,series_instance_uid,sop_instance_uid,num_dup_sops,num_uploads,first_upload,last_upload}', '{receive_reports}', 'posda_files', 'Return a report of visible duplicate SOP Instance UIDs
');
INSERT INTO queries (name, query, args, columns, tags, schema, description) VALUES ('HideEarlyFilesCSP', 'update ctp_file set visibility = ''hidden'' where file_id in (
  select min as file_id
  from (
    select
      distinct sop_instance_uid, min, max, count
    from (
      select
        distinct sop_instance_uid, min(file_id),
        max(file_id),count(*)
      from (
        select
          distinct sop_instance_uid, file_id
        from
          file_sop_common 
        where sop_instance_uid in (
          select
            distinct sop_instance_uid
          from
            file_sop_common natural join ctp_file
            natural join file_patient
          where
            project_name = ? and site_name = ? 
            and patient_id = ? and visibility is null
        )
      ) as foo natural join ctp_file
      where visibility is null
      group by sop_instance_uid
    )as foo where count > 1
  ) as foo
);
', '{collection,site,subject}', NULL, '{}', 'posda_files', 'Hide earliest submission of a file:
  Note:    uses sequencing of file_id to determine earliest
           file, not import_time
');
INSERT INTO queries (name, query, args, columns, tags, schema, description) VALUES ('HideSeriesNotLikeWithModality', 'update ctp_file set visibility = ''hidden''
where file_id in (
  select
    file_id
  from
    file_series
  where
    series_instance_uid in (
      select
         distinct series_instance_uid
      from (
        select
         distinct
           file_id, series_instance_uid, series_description
        from
           ctp_file natural join file_series
        where
           modality = ? and project_name = ? and site_name = ?and 
           series_description not like ?
      ) as foo
    )
  )
', '{modality,collection,site,description_not_matching}', NULL, '{Update,posda_files}', 'posda_files', 'Hide series not matching pattern by modality
');
INSERT INTO queries (name, query, args, columns, tags, schema, description) VALUES ('ImageIdByFileId', 'select
  distinct file_id, image_id
from
  file_image
where
  file_id = ?
', '{file_id}', '{file_id,image_id}', '{by_file_id,image_id,posda_files}', 'posda_files', 'Get image_id for file_id 
');
INSERT INTO queries (name, query, args, columns, tags, schema, description) VALUES ('InsertInitialPatientStatus', 'insert into patient_import_status(
  patient_id, patient_import_status
) values (?, ?)
', '{patient_id,status}', NULL, '{Insert,NotInteractive,PatientStatus}', 'posda_files', 'Insert Initial Patient Status
For use in scripts
Not really intended for interactive use
');
INSERT INTO queries (name, query, args, columns, tags, schema, description) VALUES ('StudiesInCollectionSite', 'select
  distinct study_instance_uid
from
  file_study natural join ctp_file
where
  project_name = ? and site_name = ? and visibility is null
', '{project_name,site_name}', '{study_instance_uid}', '{find_studies}', 'posda_files', 'Get Studies in A Collection, Site
');
INSERT INTO queries (name, query, args, columns, tags, schema, description) VALUES ('InsertSendEvent', 'insert into dicom_send_event(
  destination_host, destination_port,
  called_ae, calling_ae,
  send_started, invoking_user,
  reason_for_send, number_of_files,
  is_series_send, series_to_send
)values(
  ?, ?,
  ?, ?,
  now(), ?,
  ?, ?,
  true, ?
)
', '{host,port,called,calling,who,why,num_files,series}', NULL, '{NotInteractive,SeriesSendEvent}', 'posda_files', 'Create a DICOM Series Send Event
For use in scripts.
Not meant for interactive use
');
INSERT INTO queries (name, query, args, columns, tags, schema, description) VALUES ('IntakeFilesInSeries', 'select
  dicom_file_uri as file_path
from
  general_image
where
  series_instance_uid = ?
', '{series_instance_uid}', '{file_path}', '{intake}', 'intake', 'List of all Series By Collection, Site on Intake
');
INSERT INTO queries (name, query, args, columns, tags, schema, description) VALUES ('IntakeImagesByCollectionSite', 'select
  p.patient_id as PID,
  s.modality as Modality,
  i.sop_instance_uid as SopInstance,
  t.study_date as StudyDate,
  t.study_desc as StudyDescription,
  s.series_desc as SeriesDescription,
  s.series_number as SeriesNumber,
  t.study_instance_uid as StudyInstanceUID,
  s.series_instance_uid as SeriesInstanceUID,
  q.manufacturer as Mfr,
  q.manufacturer_model_name as Model,
  q.software_versions
from
  general_image i,
  general_series s,
  study t,
  patient p,
  trial_data_provenance tdp,
  general_equipment q
where
  i.general_series_pk_id = s.general_series_pk_id and
  s.study_pk_id = t.study_pk_id and
  s.general_equipment_pk_id = q.general_equipment_pk_id and
  t.patient_pk_id = p.patient_pk_id and
  p.trial_dp_pk_id = tdp.trial_dp_pk_id and
  tdp.project = ? and
  tdp.dp_site_name = ?
', '{collection,site}', '{PID,Modality,SopInstance,ImageType,StudyDate,StudyDescription,SeriesDescription,SeriesNumber,StudyInstanceUID,SeriesInstanceUID,Mfr,Model,software_versions}', '{intake}', 'intake', 'List of all Files Images By Collection, Site
');
INSERT INTO queries (name, query, args, columns, tags, schema, description) VALUES ('IntakeImagesByCollectionSiteSubj', 'select
  p.patient_id as PID,
  s.modality as Modality,
  i.dicom_file_uri as FilePath,
  i.sop_instance_uid as SopInstance,
  t.study_date as StudyDate,
  t.study_desc as StudyDescription,
  s.series_desc as SeriesDescription,
  s.series_number as SeriesNumber,
  t.study_instance_uid as StudyInstanceUID,
  s.series_instance_uid as SeriesInstanceUID,
  q.manufacturer as Mfr,
  q.manufacturer_model_name as Model,
  q.software_versions
from
  general_image i,
  general_series s,
  study t,
  patient p,
  trial_data_provenance tdp,
  general_equipment q
where
  i.general_series_pk_id = s.general_series_pk_id and
  s.study_pk_id = t.study_pk_id and
  s.general_equipment_pk_id = q.general_equipment_pk_id and
  t.patient_pk_id = p.patient_pk_id and
  p.trial_dp_pk_id = tdp.trial_dp_pk_id and
  tdp.project = ? and
  tdp.dp_site_name = ? and
  p.patient_id = ?
', '{collection,site,patient_id}', '{PID,Modality,SopInstance,FilePath}', '{SymLink,intake}', 'intake', 'List of all Files Images By Collection, Site
');
INSERT INTO queries (name, query, args, columns, tags, schema, description) VALUES ('IntakeSeriesByCollectionSite', 'select
  p.patient_id as PID,
  s.modality as Modality,
  t.study_date as StudyDate,
  t.study_desc as StudyDescription,
  s.series_desc as SeriesDescription,
  s.series_number as SeriesNumber,
  t.study_instance_uid as StudyInstanceUID,
  s.series_instance_uid as SeriesInstanceUID,
  q.manufacturer as Mfr,
  q.manufacturer_model_name as Model,
  q.software_versions
from
  general_series s,
  study t,
  patient p,
  trial_data_provenance tdp,
  general_equipment q
where
  s.study_pk_id = t.study_pk_id and
  s.general_equipment_pk_id = q.general_equipment_pk_id and
  t.patient_pk_id = p.patient_pk_id and
  p.trial_dp_pk_id = tdp.trial_dp_pk_id and
  tdp.project = ? and
  tdp.dp_site_name = ?
', '{collection,site}', '{PID,Modality,StudyDate,StudyDescription,SeriesDescription,SeriesNumber,StudyInstanceUID,SeriesInstanceUID,Mfr,Model,software_versions}', '{intake}', 'intake', 'List of all Series By Collection, Site on Intake
');
INSERT INTO queries (name, query, args, columns, tags, schema, description) VALUES ('IntakeSeriesWithSignatureByCollectionSite', 'select
  p.patient_id as PID,
  s.modality as Modality,
  t.study_date as StudyDate,
  t.study_desc as StudyDescription,
  s.series_desc as SeriesDescription,
  s.series_number as SeriesNumber,
  t.study_instance_uid as StudyInstanceUID,
  s.series_instance_uid as series_instance_uid,
  concat(q.manufacturer, ":", q.manufacturer_model_name, ":",
  q.software_versions) as signature
from
  general_series s,
  study t,
  patient p,
  trial_data_provenance tdp,
  general_equipment q
where
  s.study_pk_id = t.study_pk_id and
  s.general_equipment_pk_id = q.general_equipment_pk_id and
  t.patient_pk_id = p.patient_pk_id and
  p.trial_dp_pk_id = tdp.trial_dp_pk_id and
  tdp.project = ? and
  tdp.dp_site_name = ?
', '{collection,site}', '{series_instance_uid,Modality,signature}', '{intake}', 'intake', 'List of all Series By Collection, Site on Intake
');
INSERT INTO queries (name, query, args, columns, tags, schema, description) VALUES ('LastFilesInSeries', 'select root_path || ''/'' || rel_path as path
from file_location natural join file_storage_root
where file_id in (
select file_id from 
  (
  select 
    distinct sop_instance_uid, max(file_id) as file_id
  from 
    file_series natural join ctp_file 
    natural join file_sop_common
  where 
    series_instance_uid = ?
    and visibility is null
  group by sop_instance_uid
) as foo);
', '{series_instance_uid}', '{path}', '{by_series}', 'posda_files', 'Last files uploaded by series
');
INSERT INTO queries (name, query, args, columns, tags, schema, description) VALUES ('NewSopsReceivedBetweenDates', 'select
   distinct project_name, site_name, patient_id,
   study_instance_uid, series_instance_uid, count(*) as num_sops,
   min(first_loaded) as first_loaded, max(last_loaded) as last_loaded
from (
  select 
    distinct project_name, site_name, patient_id,
    study_instance_uid, series_instance_uid, sop_instance_uid,
    count(*) as num_files, sum(num_uploads) as num_uploads,
    min(first_loaded) as first_loaded, max(last_loaded) as last_loaded
  from (
    select
      distinct project_name, site_name, patient_id,
        study_instance_uid, series_instance_uid, sop_instance_uid,
        file_id, count(*) as num_uploads, max(import_time) as last_loaded,
         min(import_time) as first_loaded
    from (
      select
        distinct project_name, site_name, patient_id,
        study_instance_uid, series_instance_uid, sop_instance_uid,
        file_id, import_time
      from
        ctp_file natural join file_patient natural join
        file_study natural join file_series natural join
        file_sop_common natural join file_import natural join
        import_event
      where
        visibility is null and sop_instance_uid in (
          select distinct sop_instance_uid
          from 
            file_import natural join import_event natural join file_sop_common
          where import_time > ? and import_time < ?
        )
      ) as foo
    group by
      project_name, site_name, patient_id, study_instance_uid, 
      series_instance_uid, sop_instance_uid, file_id
  )as foo
  group by 
    project_name, site_name, patient_id, study_instance_uid, 
    series_instance_uid, sop_instance_uid
) as foo
where num_uploads = 1
group by 
  project_name, site_name, patient_id, study_instance_uid, 
  series_instance_uid
', '{start_time,end_time}', '{project_name,site_name,patient_id,study_instance_uid,series_instance_uid,num_sops,first_loaded,last_loaded}', '{receive_reports}', 'posda_files', 'Series received between dates with sops without duplicates
');
INSERT INTO queries (name, query, args, columns, tags, schema, description) VALUES ('NewSopsReceivedBetweenDatesByCollection', 'select
   distinct project_name, site_name, patient_id,
   study_instance_uid, series_instance_uid, count(*) as num_sops,
   min(first_loaded) as first_loaded, max(last_loaded) as last_loaded
from (
  select 
    distinct project_name, site_name, patient_id,
    study_instance_uid, series_instance_uid, sop_instance_uid,
    count(*) as num_files, sum(num_uploads) as num_uploads,
    min(first_loaded) as first_loaded, max(last_loaded) as last_loaded
  from (
    select
      distinct project_name, site_name, patient_id,
        study_instance_uid, series_instance_uid, sop_instance_uid,
        file_id, count(*) as num_uploads, max(import_time) as last_loaded,
         min(import_time) as first_loaded
    from (
      select
        distinct project_name, site_name, patient_id,
        study_instance_uid, series_instance_uid, sop_instance_uid,
        file_id, import_time
      from
        ctp_file natural join file_patient natural join
        file_study natural join file_series natural join
        file_sop_common natural join file_import natural join
        import_event
      where
        visibility is null and sop_instance_uid in (
          select distinct sop_instance_uid
          from 
            file_import natural join import_event natural join file_sop_common
            natural join ctp_file
          where import_time > ? and import_time < ? and
            project_name = ? and visibility is null
        )
      ) as foo
    group by
      project_name, site_name, patient_id, study_instance_uid, 
      series_instance_uid, sop_instance_uid, file_id
  )as foo
  group by 
    project_name, site_name, patient_id, study_instance_uid, 
    series_instance_uid, sop_instance_uid
) as foo
where num_uploads = 1
group by 
  project_name, site_name, patient_id, study_instance_uid, 
  series_instance_uid
', '{start_time,end_time,collection}', '{project_name,site_name,patient_id,study_instance_uid,series_instance_uid,num_sops,first_loaded,last_loaded}', '{receive_reports}', 'posda_files', 'Series received between dates with sops without duplicates
');
INSERT INTO queries (name, query, args, columns, tags, schema, description) VALUES ('NumEquipSigsForPrivateTagSigs', 'select distinct element_signature, count(*) from (
select
  distinct element_signature, equipment_signature
from 
  equipment_signature natural join series_scan
  natural join scan_element natural join element_signature
  natural join scan_event
where scan_event_id = ? and is_private) as foo
group by element_signature
order by element_signature
', '{scan_id}', '{element_signature,count}', '{tag_usage}', 'posda_phi', 'Number of Equipment signatures in which tags are featured
');
INSERT INTO queries (name, query, args, columns, tags, schema, description) VALUES ('NumEquipSigsForTagSigs', 'select distinct element_signature, count(*) from (
select
  distinct element_signature, equipment_signature
from 
  equipment_signature natural join series_scan
  natural join scan_element natural join element_signature
  natural join scan_event
where scan_event_id = ?) as foo
group by element_signature
order by element_signature
', '{scan_id}', '{element_signature,count}', '{tag_usage}', 'posda_phi', 'Number of Equipment signatures in which tags are featured
');
INSERT INTO queries (name, query, args, columns, tags, schema, description) VALUES ('PatientStatusChangeByCollection', 'select
  patient_id, old_pat_status as from,
  new_pat_status as to, pat_stat_change_who as by,
  pat_stat_change_why as why,
  when_pat_stat_changed as when
from patient_import_status_change
where patient_id in(
  select distinct patient_id
  from file_patient natural join ctp_file
  where project_name = ? and visibility is null
)
order by patient_id, when_pat_stat_changed
', '{collection}', '{patient_id,from,to,by,why,when}', '{PatientStatus}', 'posda_files', 'Get History of Patient Status Changes by Collection
');
INSERT INTO queries (name, query, args, columns, tags, schema, description) VALUES ('PatientStatusChangeByPatient', 'select
  patient_id, old_pat_status as from,
  new_pat_status as to, pat_stat_change_who as by,
  pat_stat_change_why as why,
  when_pat_stat_changed as when
from patient_import_status_change
where patient_id = ?
order by when
', '{patient_id}', '{patient_id,from,to,by,why,when}', '{PatientStatus}', 'posda_files', 'Get History of Patient Status Changes by Patient Id
');
INSERT INTO queries (name, query, args, columns, tags, schema, description) VALUES ('PatientStatusCounts', 'select
  distinct project_name as collection, patient_import_status as status,
  count(distinct patient_id) as num_patients
from
  patient_import_status natural join file_patient natural join ctp_file
where
  visibility is null
group by collection, status
order by collection, status
', '{}', '{collection,status,num_patients}', '{FindSubjects,PatientStatus}', 'posda_files', 'Find All Subjects which have at least one visible file
');
INSERT INTO queries (name, query, args, columns, tags, schema, description) VALUES ('PatientStatusCountsByCollection', 'select
  distinct project_name as collection, patient_import_status as status,
  count(distinct patient_id) as num_patients
from
  patient_import_status natural join file_patient natural join ctp_file
where project_name = ? and visibility is null
group by collection, status
', '{collection}', '{collection,status,num_patients}', '{FindSubjects,PatientStatus}', 'posda_files', 'Find All Subjects which have at least one visible file
');
INSERT INTO queries (name, query, args, columns, tags, schema, description) VALUES ('PhiScanStatus', 'select
  scan_event_id as id,
  scan_started as start_time,
  scan_ended as end_time,
  scan_ended - scan_started as duration,
  scan_status as status,
  scan_description as description,
  num_series_to_scan as to_scan,
  num_series_scanned as scanned
from 
  scan_event
order by id
', '{}', '{id,description,start_time,end_time,duration,status,to_scan,scanned}', '{tag_usage}', 'posda_phi', 'Status of PHI scans
');
INSERT INTO queries (name, query, args, columns, tags, schema, description) VALUES ('PhiScanStatusInProcess', 'select
  scan_event_id as id,
  scan_started as start_time,
  scan_ended as end_time,
  scan_ended - scan_started as duration,
  scan_status as status,
  scan_description as description,
  num_series_to_scan as to_scan,
  num_series_scanned as scanned,
  (((now() - scan_started) / num_series_scanned) * (num_series_to_scan -
  num_series_scanned)) + now() as projected_completion,
  (cast(num_series_scanned as float) / 
    cast(num_series_to_scan as float)) * 100.0 as percentage
from
  scan_event
where
   num_series_to_scan > num_series_scanned
   and num_series_scanned > 0
order by id
', '{}', '{id,description,start_time,end_time,duration,status,to_scan,scanned,percentage,projected_completion}', '{tag_usage}', 'posda_phi', 'Status of PHI scans
');
INSERT INTO queries (name, query, args, columns, tags, schema, description) VALUES ('PixDupsByCollecton', 'select 
  distinct series_instance_uid, count(*)
from 
  ctp_file natural join file_series 
where 
  project_name = ? and visibility is null
  and file_id in (
    select 
      distinct file_id
    from
      file_image natural join image natural join unique_pixel_data
      natural join ctp_file
    where digest in (
      select
        distinct pixel_digest
      from (
        select
          distinct pixel_digest, count(*)
        from (
          select 
            distinct unique_pixel_data_id, pixel_digest, project_name,
            site_name, patient_id, count(*) 
          from (
            select
              distinct unique_pixel_data_id, file_id, project_name,
              site_name, patient_id, 
              unique_pixel_data.digest as pixel_digest 
            from
              image natural join file_image natural join 
              ctp_file natural join file_patient fq
              join unique_pixel_data using(unique_pixel_data_id)
            where visibility is null
          ) as foo 
          group by 
            unique_pixel_data_id, project_name, pixel_digest,
            site_name, patient_id
        ) as foo 
        group by pixel_digest
      ) as foo 
      where count > 1
    )
    and visibility is null
  ) 
group by series_instance_uid
order by count desc;
', '{collection}', '{series_instance_uid,count}', '{pix_data_dups}', 'posda_files', 'Counts of duplicate pixel data in series by Collection
');
INSERT INTO queries (name, query, args, columns, tags, schema, description) VALUES ('PixelDataIdByFileId', 'select
  distinct file_id, image_id, unique_pixel_data_id
from
  file_image natural join image
where
  file_id = ?
', '{file_id}', '{file_id,image_id,unique_pixel_data_id}', '{by_file_id,pixel_data_id,posda_files}', 'posda_files', 'Get unique_pixel_data_id for file_id 
');
INSERT INTO queries (name, query, args, columns, tags, schema, description) VALUES ('PixelDataIdByFileIdWithOtherFileId', 'select
  distinct f.file_id as file_id, image_id, unique_pixel_data_id, 
  l.file_id as other_file_id
from
  file_image f natural join image natural join unique_pixel_data
  join pixel_location l using(unique_pixel_data_id)
where
  f.file_id = ?
', '{file_id}', '{file_id,image_id,unique_pixel_data_id,other_file_id}', '{by_file_id,duplicates,pixel_data_id,posda_files}', 'posda_files', 'Get unique_pixel_data_id for file_id 
');
INSERT INTO queries (name, query, args, columns, tags, schema, description) VALUES ('ValuesWithVrTagAndCount', 'select distinct vr, value, element_signature, num_files from (
  select
    distinct vr, value, element_signature, count(*)  as num_files
  from
    scan_event natural join series_scan natural join seen_value
    natural join element_signature natural join scan_element
  where
    scan_event_id = ?
  group by value, element_signature, vr
) as foo
order by vr, value
', '{scan_id}', '{vr,value,element_signature,num_files}', '{tag_usage}', 'posda_phi', 'List of values seen in scan by VR (with count of elements)
');
INSERT INTO queries (name, query, args, columns, tags, schema, description) VALUES ('PixelInfoByFileId', 'select
  root_path || ''/'' || rel_path as file, file_offset, size, 
  bits_stored, bits_allocated, pixel_representation, number_of_frames,
  samples_per_pixel, pixel_rows, pixel_columns, photometric_interpretation
from
  file_image f natural join image natural join unique_pixel_data
  join pixel_location pl using(unique_pixel_data_id), 
  file_location fl natural join file_storage_root
where
  f.file_id = ? and pl.file_id = fl.file_id
  and f.file_id = pl.file_id
', '{image_id}', '{file,file_offset,size,bits_stored,bits_allocated,pixel_representation,number_of_frames,samples_per_pixel,pixel_rows,pixel_columns,photometric_interpretation}', '{}', 'posda_files', 'Get pixel descriptors for a particular image id
');
INSERT INTO queries (name, query, args, columns, tags, schema, description) VALUES ('PixelInfoByImageId', 'select
  root_path || ''/'' || rel_path as file, file_offset, size, 
  bits_stored, bits_allocated, pixel_representation, number_of_frames,
  samples_per_pixel, pixel_rows, pixel_columns, photometric_interpretation
from
  image natural join unique_pixel_data natural join pixel_location
  natural join file_location natural join file_storage_root
where image_id = ?
', '{image_id}', '{file,file_offset,size,bits_stored,bits_allocated,pixel_representation,number_of_frames,samples_per_pixel,pixel_rows,pixel_columns,photometric_interpretation}', '{}', 'posda_files', 'Get pixel descriptors for a particular image id
');
INSERT INTO queries (name, query, args, columns, tags, schema, description) VALUES ('PixelInfoBySopInstance', 'select
  f.file_id, root_path || ''/'' || rel_path as file, file_offset, size, 
  bits_stored, bits_allocated, pixel_representation, number_of_frames,
  samples_per_pixel, pixel_rows, pixel_columns, photometric_interpretation,
  planar_configuration, modality
from
  file_image f natural join image natural join unique_pixel_data
  join pixel_location pl using(unique_pixel_data_id), 
  file_location fl natural join file_storage_root
  natural join file_series 
where
  pl.file_id = fl.file_id
  and f.file_id = pl.file_id
  and f.file_id in (
    select distinct file_id
    from file_sop_common where sop_instance_uid = ?
  )
', '{sop_instance_uid}', '{file_id,file,file_offset,size,bits_stored,bits_allocated,pixel_representation,number_of_frames,samples_per_pixel,pixel_rows,pixel_columns,photometric_interpretation,planar_configuration,modality}', '{}', 'posda_files', 'Get pixel descriptors for a particular image id
');
INSERT INTO queries (name, query, args, columns, tags, schema, description) VALUES ('PixelTypes', 'select
  distinct photometric_interpretation,
  samples_per_pixel,
  bits_allocated,
  bits_stored,
  high_bit,
  pixel_representation,
  planar_configuration,
  modality,
  count(*)
from
  image natural join file_image natural join file_series
group by
  photometric_interpretation,
  samples_per_pixel,
  bits_allocated,
  bits_stored,
  high_bit,
  pixel_representation,
  planar_configuration,
  modality
order by
  photometric_interpretation,
  samples_per_pixel,
  bits_allocated,
  bits_stored,
  high_bit,
  pixel_representation,
  planar_configuration,
  modality
', '{}', '{photometric_interpretation,samples_per_pixel,bits_allocated,bits_stored,high_bit,pixel_representation,planar_configuration,modality,count}', '{all,find_pixel_types,posda_files}', 'posda_files', 'Get distinct pixel types
');
INSERT INTO queries (name, query, args, columns, tags, schema, description) VALUES ('PixelTypesWithGeo', 'select
  distinct photometric_interpretation,
  samples_per_pixel,
  bits_allocated,
  bits_stored,
  high_bit,
  pixel_representation,
  planar_configuration,
  iop
from
  image natural join image_geometry
order by photometric_interpretation
', '{}', '{photometric_interpretation,samples_per_pixel,bits_allocated,bits_stored,high_bit,pixel_representation,planar_configuration,iop}', '{find_pixel_types,image_geometry,posda_files}', 'posda_files', 'Get distinct pixel types with geometry
');
INSERT INTO queries (name, query, args, columns, tags, schema, description) VALUES ('PixelTypesWithGeoRGB', 'select
  distinct photometric_interpretation,
  samples_per_pixel,
  bits_allocated,
  bits_stored,
  high_bit,
  pixel_representation,
  planar_configuration,
  iop
from
  image natural join image_geometry
where
  photometric_interpretation = ''RGB''
order by photometric_interpretation
', '{}', '{photometric_interpretation,samples_per_pixel,bits_allocated,bits_stored,high_bit,pixel_representation,planar_configuration,iop}', '{find_pixel_types,image_geometry,posda_files,rgb}', 'posda_files', 'Get distinct pixel types with geometry and rgb
');
INSERT INTO queries (name, query, args, columns, tags, schema, description) VALUES ('PixelTypesWithNoGeo', 'select
  distinct photometric_interpretation,
  samples_per_pixel,
  bits_allocated,
  bits_stored,
  high_bit,
  pixel_representation,
  planar_configuration
from
  image i where image_id not in (
    select image_id from image_geometry g where g.image_id = i.image_id
  )
order by photometric_interpretation
', '{}', '{photometric_interpretation,samples_per_pixel,bits_allocated,bits_stored,high_bit,pixel_representation,planar_configuration}', '{find_pixel_types,image_geometry,posda_files}', 'posda_files', 'Get pixel types with no geometry
');
INSERT INTO queries (name, query, args, columns, tags, schema, description) VALUES ('PixelTypesWithSlopeCT', 'select
  distinct photometric_interpretation,
  samples_per_pixel,
  bits_allocated,
  bits_stored,
  high_bit,
  pixel_representation,
  planar_configuration,
  modality,
  slope,
  intercept,
  count(*)
from
  image natural join file_image natural join file_series
  natural join file_slope_intercept natural join slope_intercept
where
  modality = ''CT''
group by
  photometric_interpretation,
  samples_per_pixel,
  bits_allocated,
  bits_stored,
  high_bit,
  pixel_representation,
  planar_configuration,
  modality,
  slope,
  intercept
order by
  photometric_interpretation,
  samples_per_pixel,
  bits_allocated,
  bits_stored,
  high_bit,
  pixel_representation,
  planar_configuration,
  modality,
  slope,
  intercept
', '{}', '{photometric_interpretation,samples_per_pixel,bits_allocated,bits_stored,high_bit,pixel_representation,planar_configuration,modality,slope,intercept,count}', '{}', 'posda_files', 'Get distinct pixel types
');
INSERT INTO queries (name, query, args, columns, tags, schema, description) VALUES ('PosdaImagesByCollectionSite', 'select distinct
  patient_id as "PID",
  modality as "Modality",
  sop_instance_uid as "SopInstance",
  study_date as "StudyDate",
  study_description as "StudyDescription",
  series_description as "SeriesDescription",
  study_instance_uid as "StudyInstanceUID",
  series_instance_uid as "SeriesInstanceUID",
  manufacturer as "Mfr",
  manuf_model_name as "Model",
  software_versions
from
  file_patient natural join file_series natural join
  file_sop_common natural join file_study natural join
  file_equipment natural join ctp_file
where
  file_id in (
  select distinct file_id from ctp_file
  where project_name = ? and site_name = ? and visibility is null)
', '{collection,site}', '{PID,Modality,SopInstance,StudyDate,StudyDescription,SeriesDescription,StudyInstanceUID,SeriesInstanceUID,Mfr,Model,software_versions}', '{posda_files}', 'posda_files', 'List of all Files Images By Collection, Site
');
INSERT INTO queries (name, query, args, columns, tags, schema, description) VALUES ('PosdaTotals', 'select 
    distinct project_name, site_name, count(*) as num_subjects,
    sum(num_studies) as num_studies,
    sum(num_series) as num_series, sum(total_files) as total_files,
    sum(total_sops) as total_sops
from (
  select
    distinct project_name, site_name, patient_id,
    count(*) as num_studies, sum(num_series) as num_series, 
    sum(total_files) as total_files,
    sum(total_sops) as total_sops
  from (
    select
       distinct project_name, site_name, patient_id, 
       study_instance_uid, count(*) as num_series,
       sum(num_sops) as total_sops,
       sum(num_files) as total_files
    from (
      select
        distinct project_name, site_name, patient_id,
        study_instance_uid, series_instance_uid,
        count(distinct file_id) as num_files,
        count(distinct sop_instance_uid) as num_sops
      from (
        select
          distinct project_name, site_name, patient_id,
          study_instance_uid, series_instance_uid, sop_instance_uid,
          file_id
        from
           ctp_file natural join file_study natural join
           file_series natural join file_sop_common
           natural join file_patient
        where
          visibility is null
      ) as foo
      group by
        project_name, site_name, patient_id, 
        study_instance_uid, series_instance_uid
    ) as foo
    group by project_name, site_name, patient_id, study_instance_uid
  ) as foo
  group by project_name, site_name, patient_id
) as foo
group by project_name, site_name
order by project_name, site_name
', '{}', '{project_name,site_name,num_subjects,num_studies,num_series,total_files,total_sops}', '{}', 'posda_files', 'Produce total counts for all collections currently in Posda
');
INSERT INTO queries (name, query, args, columns, tags, schema, description) VALUES ('PosdaTotalsHidden', 'select 
    distinct project_name, site_name, count(*) as num_subjects,
    sum(num_studies) as num_studies,
    sum(num_series) as num_series, sum(total_files) as total_files,
    sum(total_sops) as total_sops
from (
  select
    distinct project_name, site_name, patient_id,
    count(*) as num_studies, sum(num_series) as num_series, 
    sum(total_files) as total_files,
    sum(total_sops) as total_sops
  from (
    select
       distinct project_name, site_name, patient_id, 
       study_instance_uid, count(*) as num_series,
       sum(num_sops) as total_sops,
       sum(num_files) as total_files
    from (
      select
        distinct project_name, site_name, patient_id,
        study_instance_uid, series_instance_uid,
        count(distinct file_id) as num_files,
        count(distinct sop_instance_uid) as num_sops
      from (
        select
          distinct project_name, site_name, patient_id,
          study_instance_uid, series_instance_uid, sop_instance_uid,
          file_id
        from
           ctp_file natural join file_study natural join
           file_series natural join file_sop_common
           natural join file_patient
        where
          visibility = ''hidden''
      ) as foo
      group by
        project_name, site_name, patient_id, 
        study_instance_uid, series_instance_uid
    ) as foo
    group by project_name, site_name, patient_id, study_instance_uid
  ) as foo
  group by project_name, site_name, patient_id
) as foo
group by project_name, site_name
order by project_name, site_name
', '{}', '{project_name,site_name,num_subjects,num_studies,num_series,total_files,total_sops}', '{}', 'posda_files', 'Get totals of files hidden in Posda
');
INSERT INTO queries (name, query, args, columns, tags, schema, description) VALUES ('PosdaTotalsWithDateRange', 'select 
    distinct project_name, site_name, count(*) as num_subjects,
    sum(num_studies) as num_studies,
    sum(num_series) as num_series, sum(total_files) as total_files
from (
  select
    distinct project_name, site_name, patient_id, count(*) as num_studies,
    sum(num_series) as num_series, sum(total_files) as total_files
  from (
    select
       distinct project_name, site_name, patient_id, study_instance_uid, 
       count(*) as num_series, sum(num_files) as total_files
    from (
      select
        distinct project_name, site_name, patient_id, study_instance_uid, 
        series_instance_uid, count(*) as num_files 
      from (
        select
          distinct project_name, site_name, patient_id, study_instance_uid,
          series_instance_uid, sop_instance_uid 
        from
           ctp_file natural join file_study natural join
           file_series natural join file_sop_common natural join file_patient
           natural join file_import natural join import_event
        where
          visibility is null and import_time >= ? and
          import_time < ? 
      ) as foo
      group by
        project_name, site_name, patient_id, 
        study_instance_uid, series_instance_uid
    ) as foo
    group by project_name, site_name, patient_id, study_instance_uid
  ) as foo
  group by project_name, site_name, patient_id
) as foo
group by project_name, site_name
order by project_name, site_name
', '{start_time,end_time}', '{project_name,site_name,num_subjects,num_studies,num_series,total_files}', '{}', 'posda_files', 'Get posda totals by date range
');
INSERT INTO queries (name, query, args, columns, tags, schema, description) VALUES ('PosdaTotalsWithDateRangeWithHidden', 'select 
    distinct project_name, site_name, count(*) as num_subjects,
    sum(num_studies) as num_studies,
    sum(num_series) as num_series, sum(total_files) as total_files
from (
  select
    distinct project_name, site_name, patient_id, count(*) as num_studies,
    sum(num_series) as num_series, sum(total_files) as total_files
  from (
    select
       distinct project_name, site_name, patient_id, study_instance_uid, 
       count(*) as num_series, sum(num_files) as total_files
    from (
      select
        distinct project_name, site_name, patient_id, study_instance_uid, 
        series_instance_uid, count(*) as num_files 
      from (
        select
          distinct project_name, site_name, patient_id, study_instance_uid,
          series_instance_uid, sop_instance_uid 
        from
           ctp_file natural join file_study natural join
           file_series natural join file_sop_common natural join file_patient
           natural join file_import natural join import_event
        where
          import_time >= ? and
          import_time < ? 
      ) as foo
      group by
        project_name, site_name, patient_id, 
        study_instance_uid, series_instance_uid
    ) as foo
    group by project_name, site_name, patient_id, study_instance_uid
  ) as foo
  group by project_name, site_name, patient_id
) as foo
group by project_name, site_name
order by project_name, site_name
', '{start_time,end_time}', '{project_name,site_name,num_subjects,num_studies,num_series,total_files}', '{}', 'posda_files', 'Get posda totals by date range
');
INSERT INTO queries (name, query, args, columns, tags, schema, description) VALUES ('StudyConsistency', 'select distinct
  study_instance_uid, study_date, study_time,
  referring_phy_name, study_id, accession_number,
  study_description, phys_of_record, phys_reading,
  admitting_diag, count(*)
from
  file_study natural join ctp_file
where study_instance_uid = ? and visibility is null
group by
  study_instance_uid, study_date, study_time,
  referring_phy_name, study_id, accession_number,
  study_description, phys_of_record, phys_reading,
  admitting_diag
', '{study_instance_uid}', '{study_instance_uid,count,study_description,study_date,study_time,referring_phy_name,study_id,accession_number,phys_of_record,phys_reading,admitting_diag}', '{by_study,consistency}', 'posda_files', 'Check a Study for Consistency
');
INSERT INTO queries (name, query, args, columns, tags, schema, description) VALUES ('PosdaTotalsWithHidden', 'select 
    distinct project_name, site_name, count(*) as num_subjects,
    sum(num_studies) as num_studies,
    sum(num_series) as num_series, sum(total_files) as total_files
from (
  select
    distinct project_name, site_name, patient_id, count(*) as num_studies,
    sum(num_series) as num_series, sum(total_files) as total_files
  from (
    select
       distinct project_name, site_name, patient_id, study_instance_uid, 
       count(*) as num_series, sum(num_files) as total_files
    from (
      select
        distinct project_name, site_name, patient_id, study_instance_uid, 
        series_instance_uid, count(*) as num_files 
      from (
        select
          distinct project_name, site_name, patient_id, study_instance_uid,
          series_instance_uid, sop_instance_uid 
        from
           ctp_file natural join file_study natural join
           file_series natural join file_sop_common natural join file_patient
       ) as foo
       group by
         project_name, site_name, patient_id, 
         study_instance_uid, series_instance_uid
    ) as foo
    group by project_name, site_name, patient_id, study_instance_uid
  ) as foo
  group by project_name, site_name, patient_id
  order by project_name, site_name, patient_id
) as foo
group by project_name, site_name
order by project_name, site_name
', '{}', '{project_name,site_name,num_subjects,num_studies,num_series,total_files}', '{}', 'posda_files', 'Get total posda files including hidden
');
INSERT INTO queries (name, query, args, columns, tags, schema, description) VALUES ('PrivateTagUsage', 'select
  distinct element_signature, equipment_signature
from 
  equipment_signature natural join series_scan
  natural join scan_element natural join element_signature
  natural join scan_event
where scan_event_id = ? and is_private
order by element_signature;
', '{scan_id}', '{element_signature,equipment_signature}', '{tag_usage}', 'posda_phi', 'Which equipment signatures for which private tags
');
INSERT INTO queries (name, query, args, columns, tags, schema, description) VALUES ('PrivateTagsByEquipment', 'select distinct element_signature from (
select
  distinct element_signature, equipment_signature
from 
  equipment_signature natural join series_scan
  natural join scan_element natural join element_signature
  natural join scan_event
where scan_event_id = ? and is_private ) as foo
where equipment_signature = ?
order by element_signature;
', '{scan_id,equipment_signature}', '{element_signature}', '{tag_usage}', 'posda_phi', 'Which equipment signatures for which private tags
');
INSERT INTO queries (name, query, args, columns, tags, schema, description) VALUES ('RecordPatientStatusChange', 'insert into patient_import_status_change(
  patient_id, when_pat_stat_changed,
  pat_stat_change_who, pat_stat_change_why,
  old_pat_status, new_pat_status
) values (
  ?, now(),
  ?, ?,
  ?, ?
)
', '{patient_id,who,why,old_status,new_status}', NULL, '{NotInteractive,PatientStatus,Update}', 'posda_files', 'Record a change to Patient Import Status
For use in scripts
Not really intended for interactive use
');
INSERT INTO queries (name, query, args, columns, tags, schema, description) VALUES ('SendEventSummary', 'select
  reason_for_send, num_events, files_sent, earliest_send,
  finished, finished - earliest_send as duration
from (
  select
    distinct reason_for_send, count(*) as num_events, sum(number_of_files) as files_sent,
    min(send_started) as earliest_send, max(send_ended) as finished
  from dicom_send_event
  group by reason_for_send
  order by earliest_send
) as foo
', '{}', '{reason_for_send,num_events,files_sent,earliest_send,finished,duration}', '{send_to_intake}', 'posda_files', 'Summary of SendEvents by Reason
');
INSERT INTO queries (name, query, args, columns, tags, schema, description) VALUES ('SendEventsByReason', 'select
  send_started, send_ended - send_started as duration,
  destination_host, destination_port,
  number_of_files as to_send, files_sent,
  invoking_user, reason_for_send
from (
  select
    distinct dicom_send_event_id,
    count(distinct file_path) as files_sent
  from
    dicom_send_event natural join dicom_file_send
  where
    reason_for_send = ?
  group by dicom_send_event_id
) as foo
natural join dicom_send_event
order by send_started
', '{reason}', '{send_started,duration,destination_host,destination_port,to_send,files_sent,invoking_user,reason_for_send}', '{send_to_intake}', 'posda_files', 'List of Send Events By Reason
');
INSERT INTO queries (name, query, args, columns, tags, schema, description) VALUES ('SentToIntakeByDate', 'select
  send_started, send_ended - send_started as duration,
  destination_host, destination_port,
  number_of_files as to_send, files_sent,
  invoking_user, reason_for_send
from (
  select
    distinct dicom_send_event_id,
    count(distinct file_path) as files_sent
  from
    dicom_send_event natural join dicom_file_send
  where
    send_started > ? and send_started < ?
  group by dicom_send_event_id
) as foo
natural join dicom_send_event
order by send_started
', '{from_date,to_date}', '{send_started,duration,destination_host,destination_port,to_send,files_sent,invoking_user,reason_for_send}', '{send_to_intake}', 'posda_files', 'List of Files Sent To Intake By Date
');
INSERT INTO queries (name, query, args, columns, tags, schema, description) VALUES ('SeriesByLikeDescriptionAndCollection', 'select distinct
  series_instance_uid, series_description
from
  file_series natural join ctp_file
where project_name = ? and series_description like ?
', '{collection,pattern}', '{series_instance_uid,series_description}', '{find_series}', 'posda_files', 'Get a list of Series by Collection matching Series Description
');
INSERT INTO queries (name, query, args, columns, tags, schema, description) VALUES ('SeriesCollectionSite', 'select distinct
  series_instance_uid
from
  file_series natural join ctp_file
where project_name = ? and site_name = ? and visibility is null
', '{collection,site}', '{series_instance_uid}', '{find_series}', 'posda_files', 'Get a list of Series by Collection, Site
');
INSERT INTO queries (name, query, args, columns, tags, schema, description) VALUES ('SeriesConsistency', 'select distinct
  series_instance_uid, modality, series_number, laterality, series_date,
  series_time, performing_phys, protocol_name, series_description,
  operators_name, body_part_examined, patient_position,
  smallest_pixel_value, largest_pixel_value, performed_procedure_step_id,
  performed_procedure_step_start_date, performed_procedure_step_start_time,
  performed_procedure_step_desc, performed_procedure_step_comments,
  count(*)
from
  file_series natural join ctp_file
where series_instance_uid = ? and visibility is null
group by
  series_instance_uid, modality, series_number, laterality, series_date,
  series_time, performing_phys, protocol_name, series_description,
  operators_name, body_part_examined, patient_position,
  smallest_pixel_value, largest_pixel_value, performed_procedure_step_id,
  performed_procedure_step_start_date, performed_procedure_step_start_time,
  performed_procedure_step_desc, performed_procedure_step_comments
', '{series_instance_uid}', '{series_instance_uid,count,modality,series_number,laterality,series_date,series_time,performing_phys,protocol_name,series_description,operators_name,body_part_examined,patient_position,smallest_pixel_value,largest_pixel_value,performed_procedure_step_id,performed_procedure_step_start_date,performed_procedure_step_start_time,performed_procedure_step_desc,performed_procedure_step_comments}', '{by_series,consistency}', 'posda_files', 'Check a Series for Consistency
');
INSERT INTO queries (name, query, args, columns, tags, schema, description) VALUES ('SeriesConsistencyExtended', 'select distinct
  series_instance_uid, modality, series_number, laterality, series_date,
  series_time, performing_phys, protocol_name, series_description,
  operators_name, body_part_examined, patient_position,
  smallest_pixel_value, largest_pixel_value, performed_procedure_step_id,
  performed_procedure_step_start_date, performed_procedure_step_start_time,
  performed_procedure_step_desc, performed_procedure_step_comments, image_type,
  count(*)
from
  file_series natural join ctp_file
  left join file_image using(file_id)
  left join image using (image_id)
where series_instance_uid = ? and visibility is null
group by
  series_instance_uid, modality, series_number, laterality,
  series_date, image_type,
  series_time, performing_phys, protocol_name, series_description,
  operators_name, body_part_examined, patient_position,
  smallest_pixel_value, largest_pixel_value, performed_procedure_step_id,
  performed_procedure_step_start_date, performed_procedure_step_start_time,
  performed_procedure_step_desc, performed_procedure_step_comments
', '{series_instance_uid}', '{series_instance_uid,count,modality,series_number,laterality,series_date,image_type,series_time,performing_phys,protocol_name,series_description,operators_name,body_part_examined,patient_position,smallest_pixel_value,largest_pixel_value,performed_procedure_step_id,performed_procedure_step_start_date,performed_procedure_step_start_time,performed_procedure_step_desc,performed_procedure_step_comments}', '{by_series,consistency}', 'posda_files', 'Check a Series for Consistency (including Image Type)
');
INSERT INTO queries (name, query, args, columns, tags, schema, description) VALUES ('SeriesEquipmentByValueSignature', 'select
  distinct series_instance_uid, element_signature, value, vr,
  equipment_signature
from
  scan_event natural join series_scan
  natural join scan_element natural join element_signature
  natural join equipment_signature
  natural join seen_value
where
  scan_event_id = ? and
  value = ? and
  element_signature = ?
order by value, element_signature, vr
', '{scan_id,value,tag_signature}', '{series_instance_uid,value,vr,element_signature,equipment_signature}', '{tag_usage}', 'posda_phi', 'List of series, values, vr seen in scan with equipment signature
');
INSERT INTO queries (name, query, args, columns, tags, schema, description) VALUES ('SeriesLike', 'select
   distinct collection, site, pat_id,
   series_instance_uid, series_description, count(*)
from (
  select
   distinct
     project_name as collection, site_name as site,
     file_id, series_instance_uid, patient_id as pat_id,
     series_description
  from
     ctp_file natural join file_series natural join file_patient
  where
     project_name = ? and site_name = ? and 
     series_description like ?
) as foo
group by collection, site, pat_id, series_instance_uid, series_description
order by collection, site, pat_id
', '{collection,site,description_matching}', '{collection,site,pat_id,series_instance_uid,series_description,count}', '{find_series,pattern,posda_files}', 'posda_files', 'Select series not matching pattern
');
INSERT INTO queries (name, query, args, columns, tags, schema, description) VALUES ('SeriesNickname', 'select
  project_name, site_name, subj_id, series_nickname
from
  series_nickname
where
  series_instance_uid = ?
', '{series_instance_uid}', '{project_name,site_name,subj_id,series_nickname}', '{}', 'posda_nicknames', 'Get a nickname, etc for a particular series uid
');
INSERT INTO queries (name, query, args, columns, tags, schema, description) VALUES ('SeriesNotLikeWithModality', 'select
   distinct series_instance_uid, series_description, count(*)
from (
  select
   distinct
     file_id, series_instance_uid, series_description
  from
     ctp_file natural join file_series
  where
     modality = ? and project_name = ? and site_name = ? and 
     series_description not like ? and visibility is null
) as foo
group by series_instance_uid, series_description
', '{modality,collection,site,description_not_matching}', '{series_instance_uid,series_description,count}', '{find_series,pattern,posda_files}', 'posda_files', 'Select series not matching pattern by modality
');
INSERT INTO queries (name, query, args, columns, tags, schema, description) VALUES ('SeriesSentToIntakeByDate', 'select
  series_to_send as series_instance_uid,
  send_started, send_ended - send_started as duration,
  destination_host, destination_port,
  number_of_files as to_send, files_sent,
  invoking_user, reason_for_send
from (
  select
    distinct dicom_send_event_id,
    count(distinct file_path) as files_sent
  from
    dicom_send_event natural join dicom_file_send
  where
    send_started > ? and send_started < ?
  group by dicom_send_event_id
) as foo
natural join dicom_send_event
order by send_started
', '{from_date,to_date}', '{send_started,duration,series_instance_uid,destination_host,destination_port,to_send,files_sent,invoking_user,reason_for_send}', '{send_to_intake}', 'posda_files', 'List of Series Sent To Intake By Date
');
INSERT INTO queries (name, query, args, columns, tags, schema, description) VALUES ('SeriesWithDuplicatePixelDataThatMatters', 'select distinct series_instance_uid
from file_series natural join file_image
where image_id in (
select image_id from (
  select distinct image_id, count(*)
  from (
    select distinct image_id, file_id
    from (
      select
        file_id, image_id, patient_id, study_instance_uid, 
        series_instance_uid, sop_instance_uid, modality
      from
        file_patient natural join file_series natural join 
        file_study natural join file_sop_common
        natural join file_image
      where file_id in (
        select file_id
        from (
          select image_id, file_id 
          from file_image 
          where image_id in (
            select image_id
            from (
              select distinct image_id, count(*)
              from (
                select distinct image_id, file_id
                from file_image where file_id in (
                  select distinct file_id
                  from ctp_file
                  where project_name = ? and visibility is null
                )
              ) as foo
              group by image_id
            ) as foo 
            where count > 1
          )
        ) as foo
      )
    ) as foo
  ) as foo
  group by image_id
) as foo 
where count > 1
)
', '{collection}', '{series_instance_uid}', '{}', 'posda_files', 'Return a list of files with duplicate pixel data,
restricted to those files which have parsed DICOM data
representations in Database.
');
INSERT INTO queries (name, query, args, columns, tags, schema, description) VALUES ('SeriesWithRGB', 'select
  distinct series_instance_uid
from
  image natural join file_image
  natural join file_series
  natural join ctp_file
where
  photometric_interpretation = ''RGB''
  and visibility is null
', '{}', '{series_instance_uid}', '{find_series,posda_files,rgb}', 'posda_files', 'Get distinct pixel types with geometry and rgb
');
INSERT INTO queries (name, query, args, columns, tags, schema, description) VALUES ('SopNickname', 'select
  project_name, site_name, subj_id, sop_nickname, modality,
  has_modality_conflict
from
  sop_nickname
where
  sop_instance_uid = ?
', '{sop_instance_uid}', '{project_name,site_name,subj_id,sop_nickname,modality,has_modality_conflict}', '{}', 'posda_nicknames', 'Get a nickname, etc for a particular SOP Instance  uid
');
INSERT INTO queries (name, query, args, columns, tags, schema, description) VALUES ('StudyNickname', 'select
  project_name, site_name, subj_id, study_nickname
from
  study_nickname
where
  study_instance_uid = ?
', '{study_instance_uid}', '{project_name,site_name,subj_id,study_nickname}', '{}', 'posda_nicknames', 'Get a nickname, etc for a particular study uid
');
INSERT INTO queries (name, query, args, columns, tags, schema, description) VALUES ('SubjectCountByCollectionSite', 'select
  distinct
    patient_id, count(distinct file_id)
from
  ctp_file natural join file_patient
where
  project_name = ? and site_name = ? and visibility is null
group by
  patient_id 
order by
  patient_id
', '{collection,site}', '{patient_id,count}', '{counts}', 'posda_files', 'Counts query by Collection, Site
');
INSERT INTO queries (name, query, args, columns, tags, schema, description) VALUES ('SubjectsWithDupSops', 'select
  distinct collection, site, subj_id, count(*)
from (
  select
    distinct project_name as collection,
    site_name as site, patient_id as subj_id,
    file_id
  from
    ctp_file natural join file_sop_common
    natural join file_patient
  where
    sop_instance_uid in (
      select distinct sop_instance_uid from (
        select distinct sop_instance_uid, count(*) from (
          select distinct file_id, sop_instance_uid 
          from
            ctp_file natural join file_sop_common
            natural join file_patient
          where
            visibility is null
        ) as foo group by sop_instance_uid order by count desc
      ) as foo 
      where count > 1
    )
    and visibility is null
  ) as foo
group by collection, site, subj_id
', '{}', '{collection,site,subj_id,count}', '{duplicates}', 'posda_files', 'Return a count of duplicate SOP Instance UIDs
');
INSERT INTO queries (name, query, args, columns, tags, schema, description) VALUES ('SubjectsWithDupSopsByCollection', 'select
  distinct collection, site, subj_id, count(*)
from (
  select
    distinct project_name as collection,
    site_name as site, patient_id as subj_id,
    file_id
  from
    ctp_file natural join file_sop_common
    natural join file_patient
  where
    sop_instance_uid in (
      select distinct sop_instance_uid from (
        select distinct sop_instance_uid, count(*) from (
          select distinct file_id, sop_instance_uid 
          from
            ctp_file natural join file_sop_common
            natural join file_patient
          where
            project_name = ? and visibility is null
        ) as foo group by sop_instance_uid order by count desc
      ) as foo 
      where count > 1
    )
    and visibility is null
  ) as foo
group by collection, site, subj_id
', '{collection}', '{collection,site,subj_id,count}', '{}', 'posda_files', 'Return a count of duplicate SOP Instance UIDs
');
INSERT INTO queries (name, query, args, columns, tags, schema, description) VALUES ('SubjectsWithModalityByCollectionSite', 'select
  distinct patient_id, count(*) as num_files
from
  ctp_file natural join file_patient natural join file_series
where
  modality = ? and project_name = ? and site_name = ?
group by patient_id
order by patient_id
', '{modality,project_name,site_name}', '{patient_id,num_files}', '{FindSubjects}', 'posda_files', 'Find All Subjects with given modality in Collection, Site
');
INSERT INTO queries (name, query, args, columns, tags, schema, description) VALUES ('SubjectsWithModalityByCollectionSiteIntake', 'select
  distinct i.patient_id, modality, count(*) as num_files
from
  general_image i, trial_data_provenance tdp, general_series s
where
  s.general_series_pk_id = i.general_series_pk_id and 
  i.trial_dp_pk_id = tdp.trial_dp_pk_id and 
  modality = ? and
  tdp.project = ? and 
  tdp.dp_site_name = ?
group by patient_id, modality
', '{modality,project_name,site_name}', '{patient_id,modality,num_files}', '{FindSubjects,SymLink,intake}', 'intake', 'Find All Subjects with given modality in Collection, Site
');
INSERT INTO queries (name, query, args, columns, tags, schema, description) VALUES ('TagUsage', 'select
  distinct element_signature, equipment_signature
from 
  equipment_signature natural join series_scan
  natural join scan_element natural join element_signature
  natural join scan_event
where scan_event_id = ?
order by element_signature;
', '{scan_id}', '{element_signature,equipment_signature}', '{tag_usage}', 'posda_phi', 'Which equipment signatures for which tags
');
INSERT INTO queries (name, query, args, columns, tags, schema, description) VALUES ('TestThisOne', 'select
  patient_id, patient_import_status,
  count(distinct file_id) as total_files,
  min(import_time) min_time, max(import_time) as max_time,
  count(distinct study_instance_uid) as num_studies,
  count(distinct series_instance_uid) as num_series
from
  ctp_file natural join file natural join
  file_import natural join import_event natural join
  file_study natural join file_series natural join file_patient
  natural join patient_import_status
where
  project_name = ? and site_name = ? and visibility is null
group by patient_id, patient_import_status
', '{project_name,site_name,PatientStatus}', '{patient_id,patient_import_status,total_files,min_time,max_time,num_studies,num_series}', '{}', 'posda_files', '');
INSERT INTO queries (name, query, args, columns, tags, schema, description) VALUES ('TotalDiskSpace', 'select
  sum(size) as total_bytes
from
  file
where
  file_id in (
  select distinct file_id
  from ctp_file
  )
', '{}', '{total_bytes}', '{all,posda_files,storage_used}', 'posda_files', 'Get total disk space used
');
INSERT INTO queries (name, query, args, columns, tags, schema, description) VALUES ('ValuesWithVrTagAndCountLimited', 'select distinct vr, value, element_signature, num_files from (
  select
    distinct vr, value, element_signature, count(*)  as num_files
  from
    scan_event natural join series_scan natural join seen_value
    natural join element_signature natural join scan_element
  where
    scan_event_id = ? and
    vr not in (
      ''AE'', ''AT'', ''DS'', ''FL'', ''FD'', ''IS'', ''OD'', ''OF'', ''OL'', ''OW'',
      ''SL'', ''SQ'', ''SS'', ''TM'', ''UL'', ''US''
    )
  group by value, element_signature, vr
) as foo
order by vr, value
', '{scan_id}', '{vr,value,element_signature,num_files}', '{tag_usage}', 'posda_phi', 'List of values seen in scan by VR (with count of elements)
');
INSERT INTO queries (name, query, args, columns, tags, schema, description) VALUES ('VrsSeen', 'select distinct vr, count(*) from (
  select
    distinct value, element_signature, vr
  from
    scan_event natural join series_scan natural join seen_value
    natural join element_signature natural join scan_element
  where
    scan_event_id = ?
) as foo
group by vr
order by vr
', '{scan_id}', '{vr,count}', '{tag_usage}', 'posda_phi', 'List of VR''s seen in scan (with count)
');
INSERT INTO queries (name, query, args, columns, tags, schema, description) VALUES ('WhereSeriesSits', 'select distinct
  project_name as collection,
  site_name as site,
  patient_id,
  study_instance_uid,
  series_instance_uid,
  count(distinct file_id) as num_files
from
  file_patient natural join
  file_study natural join
  file_series natural join
  ctp_file
where file_id in (
  select
    distinct file_id
  from
    file_series natural join ctp_file
  where
    series_instance_uid = ? and visibility is null
)
group by
  project_name, site_name, patient_id,
  study_instance_uid, series_instance_uid
order by
  project_name, site_name, patient_id,
  study_instance_uid, series_instance_uid
', '{series_instance_uid}', '{collection,site,patient_id,study_instance_uid,series_instance_uid,num_files}', '{by_series_instance_uid,posda_files,sops}', 'posda_files', 'Get Collection, Site, Patient, Study Hierarchy in which series resides
');
INSERT INTO queries (name, query, args, columns, tags, schema, description) VALUES ('TotalsByDateRange', 'select 
    distinct project_name, site_name, count(*) as num_subjects,
    sum(num_studies) as num_studies,
    sum(num_series) as num_series, sum(total_files) as total_files
from (
  select
    distinct project_name, site_name, patient_id, count(*) as num_studies,
    sum(num_series) as num_series, sum(total_files) as total_files
  from (
    select
       distinct project_name, site_name, patient_id, study_instance_uid, 
       count(*) as num_series, sum(num_files) as total_files
    from (
      select
        distinct project_name, site_name, patient_id, study_instance_uid, 
        series_instance_uid, count(*) as num_files 
      from (
        select
          distinct project_name, site_name, patient_id, study_instance_uid,
          series_instance_uid, sop_instance_uid 
        from
           ctp_file natural join file_study natural join
           file_series natural join file_sop_common natural join file_patient
           natural join file_import natural join import_event
        where
          visibility is null and import_time >= ? and
          import_time < ? 
      ) as foo
      group by
        project_name, site_name, patient_id, 
        study_instance_uid, series_instance_uid
    ) as foo
    group by project_name, site_name, patient_id, study_instance_uid
  ) as foo
  group by project_name, site_name, patient_id
) as foo
group by project_name, site_name
order by project_name, site_name
', '{start_time,end_time}', '{project_name,site_name,num_subjects,num_studies,num_series,total_files}', '{AllCollections,DateRange,Kirk,Totals}', 'posda_files', 'Get posda totals by date range
');
INSERT INTO queries (name, query, args, columns, tags, schema, description) VALUES ('TotalsByDateRangeAndCollection', 'select 
    distinct project_name, site_name, count(*) as num_subjects,
    sum(num_studies) as num_studies,
    sum(num_series) as num_series, sum(total_files) as total_files
from (
  select
    distinct project_name, site_name, patient_id, count(*) as num_studies,
    sum(num_series) as num_series, sum(total_files) as total_files
  from (
    select
       distinct project_name, site_name, patient_id, study_instance_uid, 
       count(*) as num_series, sum(num_files) as total_files
    from (
      select
        distinct project_name, site_name, patient_id, study_instance_uid, 
        series_instance_uid, count(*) as num_files 
      from (
        select
          distinct project_name, site_name, patient_id, study_instance_uid,
          series_instance_uid, sop_instance_uid 
        from
           ctp_file natural join file_study natural join
           file_series natural join file_sop_common natural join file_patient
           natural join file_import natural join import_event
        where
          visibility is null and import_time >= ? and
          import_time < ? and project_name = ?
      ) as foo
      group by
        project_name, site_name, patient_id, 
        study_instance_uid, series_instance_uid
    ) as foo
    group by project_name, site_name, patient_id, study_instance_uid
  ) as foo
  group by project_name, site_name, patient_id
) as foo
group by project_name, site_name
order by project_name, site_name
', '{start_time,end_time,project_name}', '{project_name,site_name,num_subjects,num_studies,num_series,total_files}', '{DateRange,Kirk,Totals}', 'posda_files', 'Get posda totals by date range
');
INSERT INTO queries (name, query, args, columns, tags, schema, description) VALUES ('TotalsLike', 'select 
    distinct project_name, site_name, count(*) as num_subjects,
    sum(num_studies) as num_studies,
    sum(num_series) as num_series, sum(total_files) as total_files
from (
  select
    distinct project_name, site_name, patient_id, count(*) as num_studies,
    sum(num_series) as num_series, sum(total_files) as total_files
  from (
    select
       distinct project_name, site_name, patient_id, study_instance_uid, 
       count(*) as num_series, sum(num_files) as total_files
    from (
      select
        distinct project_name, site_name, patient_id, study_instance_uid, 
        series_instance_uid, count(*) as num_files 
      from (
        select
          distinct project_name, site_name, patient_id, study_instance_uid,
          series_instance_uid, sop_instance_uid 
        from
           ctp_file natural join file_study natural join
           file_series natural join file_sop_common natural join file_patient
         where
           project_name like ? and visibility is null
       ) as foo
       group by
         project_name, site_name, patient_id, 
         study_instance_uid, series_instance_uid
    ) as foo
    group by project_name, site_name, patient_id, study_instance_uid
  ) as foo
  group by project_name, site_name, patient_id
  order by project_name, site_name, patient_id
) as foo
group by project_name, site_name
order by project_name, site_name
', '{pattern}', '{project_name,site_name,num_subjects,num_studies,num_series,total_files}', '{}', 'posda_files', 'Get Posda totals for with collection matching pattern
');
INSERT INTO queries (name, query, args, columns, tags, schema, description) VALUES ('UnHideFilesCSP', 'update ctp_file set visibility = null where file_id in (
  select
    distinct file_id
  from
    ctp_file natural join file_patient
  where
    project_name = ? and site_name = ?
    and visibility = ''hidden'' and patient_id = ?
);
', '{collection,site,subject}', NULL, '{}', 'posda_files', 'UnHide all files hidden by Collection, Site, Subject
');
INSERT INTO queries (name, query, args, columns, tags, schema, description) VALUES ('UpdateCountsDb', 'insert into totals_by_collection_site(
  count_report_id,
  collection_name, site_name,
  num_subjects, num_studies, num_series, num_sops
) values (
  currval(''count_report_count_report_id_seq''),
  ?, ?,
  ?, ?, ?, ?
)
', '{project_name,site_name,num_subjects,num_studies,num_series,num_files}', NULL, '{insert,posda_counts}', 'posda_counts', '');
INSERT INTO queries (name, query, args, columns, tags, schema, description) VALUES ('UpdatePatientImportStatus', 'update patient_import_status set 
  patient_import_status = ?
where patient_id = ?
', '{patient_id,status}', NULL, '{NotInteractive,PatientStatus,Update}', 'posda_files', 'Update Patient Status
For use in scripts
Not really intended for interactive use
');
INSERT INTO queries (name, query, args, columns, tags, schema, description) VALUES ('UpdateSendEvent', 'update dicom_send_event
  set send_ended = now()
where dicom_send_event_id = ?
', '{id}', NULL, '{NotInteractive,SeriesSendEvent}', 'posda_files', 'Update dicom_send_event_id after creation and completion of send
For use in scripts.
Not meant for interactive use
');
INSERT INTO queries (name, query, args, columns, tags, schema, description) VALUES ('ValuesByVr', 'select distinct value, count(*) from (
  select
    distinct value, element_signature, vr
  from
    scan_event natural join series_scan natural join seen_value
    natural join element_signature natural join scan_element
  where
    scan_event_id = ? and vr = ?
) as foo
group by value
order by value
', '{scan_id,vr}', '{value,count}', '{tag_usage}', 'posda_phi', 'List of values seen in scan by VR (with count of elements)
');
INSERT INTO queries (name, query, args, columns, tags, schema, description) VALUES ('ValuesByVrWithTagAndCount', 'select distinct value, element_signature, num_files from (
  select
    distinct value, element_signature, vr, count(*)  as num_files
  from
    scan_event natural join series_scan natural join seen_value
    natural join element_signature natural join scan_element
  where
    scan_event_id = ? and vr = ?
  group by value, element_signature, vr
) as foo
order by value
', '{scan_id,vr}', '{value,element_signature,num_files}', '{tag_usage}', 'posda_phi', 'List of values seen in scan by VR (with count of elements)
');
INSERT INTO queries (name, query, args, columns, tags, schema, description) VALUES ('PixelInfoBySeries', 'select
  f.file_id as file_id, 
  root_path || ''/'' || rel_path as file,
  file_offset, 
  size, 
  bits_stored, 
  bits_allocated, 
  pixel_representation, 
  number_of_frames,
  samples_per_pixel, 
  pixel_rows, 
  pixel_columns, 
  photometric_interpretation,
  planar_configuration,
  modality
from
  file_image f natural join image natural join unique_pixel_data
  natural join file_series
  join pixel_location pl using(unique_pixel_data_id), 
  file_location fl natural join file_storage_root
where
  pl.file_id = fl.file_id
  and f.file_id = pl.file_id
  and f.file_id in (
  select distinct file_id
  from file_series natural join ctp_file
  where series_instance_uid = ? and visibility is null
)', '{series_instance_uid}', '{file_id,file,file_offset,size,bits_stored,bits_allocated,pixel_representation,number_of_frames,samples_per_pixel,pixel_rows,pixel_columns,photometric_interpretation,planar_configuration,modality}', '{}', 'posda_files', 'Get pixel descriptors for all files in a series
');
