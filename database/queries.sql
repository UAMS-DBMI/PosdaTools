set search_path to public, dbif_config;
truncate table queries;

            insert into queries
            values ('SubprocessesByUserWhichGeneratedEmail', 'select 
  distinct subprocess_invocation_id, when_script_started, when_background_entered,
  when_script_ended, user_to_notify, button_name, operation_name, command_line,
  user_inbox_content_id, activity_id, brief_description as activity_description
from
  subprocess_invocation natural left join background_subprocess natural left join 
  background_subprocess_report natural left join user_inbox_content natural left join
  activity_inbox_content left join activity using (activity_id)
where
  invoking_user = ? and background_subprocess_report.name = ''Email''
order by subprocess_invocation_id desc;', ARRAY['invoking_user'], 
                    ARRAY['subprocess_invocation_id', 'when_script_started', 'when_background_entered', 'when_script_ended', 'user_to_notify', 'button_name', 'operation_name', 'user_inbox_content_id', 'activity_id', 'activity_description', 'command_line'], ARRAY['AllCollections', 'queries', 'activity_support'], 'posda_queries', 'Get a list of available queries')
        ;

            insert into queries
            values ('PatientReportByPatientOnly', 'select
  distinct project_name as collection,
  site_name as site,
  site_id,
  patient_id, study_instance_uid, study_description,
  series_instance_uid, series_description,
  count(distinct file_id) as num_files,
  min(import_time) as earliest_upload,
  max(import_time) as latest_upload,
  count(distinct import_event_id) as num_uploads
from
  file_patient natural join file_study natural join
  file_series natural join ctp_file natural join
  file_import natural join import_event
where
  patient_id = ?
  and visibility is null
group by 
  collection, site, site_id,
  patient_id, study_instance_uid, study_description,
  series_instance_uid, series_description
order by
  study_instance_uid, series_instance_uid, num_files', ARRAY['patient_id'], 
                    ARRAY['collection', 'site', 'patient_id', 'site_id', 'study_instance_uid', 'study_description', 'series_instance_uid', 'series_description', 'num_files', 'earliest_upload', 'latest_upload', 'num_uploads'], ARRAY['meta', 'test', 'hello', 'bills_test'], 'posda_files', 'Add a filter to a tab')
        ;

            insert into queries
            values ('GetListStructureSets', 'select 
  distinct project_name, site_name, patient_id, sop_instance_uid
from
  file_sop_common natural join ctp_file natural join dicom_file natural join file_patient
where
  dicom_file_type = ''RT Structure Set Storage'' and visibility is null
order by project_name, site_name, patient_id', '{}', 
                    ARRAY['project_name', 'patient_id', 'site_name', 'sop_instance_uid'], ARRAY['Structure Sets', 'sops', 'LinkageChecks'], 'posda_files', 'Get Structure Set List

')
        ;

            insert into queries
            values ('FinalizeSimpleScanInstance', 'update phi_scan_instance set
  end_time = now()
where
  phi_scan_instance_id = ?', ARRAY['id'], 
                    '{}', ARRAY['used_in_simple_phi', 'NotInteractive'], 'posda_phi_simple', 'Finalize PHI Scan')
        ;

            insert into queries
            values ('CreateDciodvfyUnitScan', 'insert into dciodvfy_unit_scan(
  type_of_unit,
  unit_uid,
  unit_id,
  num_file_in_unit,
  start_time
) values( ?, ?, ?, ?, now())', ARRAY['type_of_unit', 'unit_uid', 'unit_id', 'num_file_in_unit'], 
                    '{}', ARRAY['NotInteractive', 'used_in_dciodvfy'], 'posda_phi_simple', 'Create a dciodvfy_unit_scan row')
        ;

            insert into queries
            values ('SeriesVisualReviewResultsByCollectionSiteStatusNotGood', 'select 
  distinct series_instance_uid,
  dicom_file_type,
  modality,
  review_status,
  count(distinct file_id) as num_files
from 
  dicom_file natural join 
  file_series natural join 
  ctp_file join 
  image_equivalence_class using(series_instance_uid)
where
  project_name = ? and
  site_name = ? and review_status != ''Good''
group by
  series_instance_uid,
  dicom_file_type,
  modality,
  review_status
order by
  series_instance_uid', ARRAY['project_name', 'site_name'], 
                    ARRAY['series_instance_uid', 'dicom_file_type', 'modality', 'review_status', 'num_files'], ARRAY['find_series', 'equivalence_classes', 'consistency', 'visual_review_results', 'hide_files'], 'posda_files', 'Get visual review status report by series for Collection, Site')
        ;

            insert into queries
            values ('BackgroundProcessStatsWithInvokerLikeProgram', 'select
  distinct command_executed, invoking_user as invoker, 
  max(when_script_ended - when_script_started) as longest,
  min(when_script_ended - when_script_started) as shortest,
  avg(when_script_ended - when_script_started) as avg, count(*) as times_invoked,
  min(when_script_started) as first, max(when_script_started) as last
from
  background_subprocess natural join subprocess_invocation
where
  when_script_ended is not null and command_executed like ?
group by command_executed, invoker', ARRAY['command_executed_like'], 
                    ARRAY['command_executed', 'invoker', 'longest', 'shortest', 'avg', 'times_invoked', 'first', 'last'], ARRAY['invoking_user'], 'posda_files', 'Get a list of collections and sites
')
        ;

            insert into queries
            values ('InsertFileImportLong', 'insert into file_import(
  import_event_id, file_id,  rel_path, rel_dir, file_name
) values (
  ?, ?, ?, ?, ?
)
', ARRAY['import_event_id', 'file_id', 'rel_path', 'rel_dir', 'file_name'], 
                    '{}', ARRAY['NotInteractive', 'Backlog', 'used_in_file_import_into_posda'], 'posda_files', 'Create an import_event')
        ;

            insert into queries
            values ('GetCountSsVolumeByPatientId', 'select
  distinct sop_instance_uid, count(distinct sop_instance_link) as num_links 
from (
  select 
    sop_instance_uid, for_uid, study_instance_uid, series_instance_uid,
    sop_class as sop_class_uid, sop_instance as sop_instance_link
  from
    ss_for natural join ss_volume natural join
    file_structure_set join file_sop_common using (file_id)
  where structure_set_id in (
    select 
      structure_set_id 
    from
      file_structure_set fs, file_sop_common sc
    where
      sc.file_id = fs.file_id and sop_instance_uid in (
         select distinct sop_instance_uid 
         from file_sop_common natural join file_patient
         where patient_id = ?
     )
  )
) as foo 
group by sop_instance_uid', ARRAY['patient_id'], 
                    ARRAY['sop_instance_uid', 'num_links'], ARRAY['Structure Sets', 'sops', 'LinkageChecks'], 'posda_files', 'Get Structure Set Volume

')
        ;

            insert into queries
            values ('LookingForMissingHeadNeckPetCT', 'select distinct series_instance_uid, visibility, count(distinct file_id) as num_files, count(distinct import_event_id) as num_uploads, count(distinct sop_instance_uid) as num_sops
, max(import_time) as last_load, min(import_time) as earliest_load from file_series join ctp_file using(file_id) join file_sop_common using(file_id) join file_import using (file_id) join import_event using(import_event_id)
where project_name = ''Head-Neck-PET-CT'' and import_time > ''2018-04-01'' group by series_instance_uid, visibility;', '{}', 
                    ARRAY['series_instance_uid', 'visibility', 'num_files', 'num_uploads', 'num_sops', 'last_load', 'earliest_load'], ARRAY['meta', 'test', 'hello', 'bills_test', 'bills_ad_hoc_scripts', 'for_tracy'], 'posda_files', 'Add a filter to a tab')
        ;

            insert into queries
            values ('ShowPopUps', 'select * from popup_buttons
 ', '{}', 
                    ARRAY['popup_button_id', 'name', 'object_class', 'btn_col', 'is_full_table', 'btn_name'], ARRAY['AllCollections', 'universal'], 'posda_queries', 'Get a list of configured pop-up buttons')
        ;

            insert into queries
            values ('GetDciodvfyWarningUnrecognizedDT', 'select
  dciodvfy_warning_id as id
from 
  dciodvfy_warning
where
  warning_type = ''UnrecognizedDefinedTerm''
  and warning_tag = ?
  and warning_value = ?
  and warning_index = ?
', ARRAY['warning_tag', 'warning_value', 'warning_index'], 
                    ARRAY['id'], ARRAY['NotInteractive', 'used_in_dciodvfy'], 'posda_phi_simple', 'Get dciodvfy_warning row where subtype = UnrecognizedDefinedTerm')
        ;

            insert into queries
            values ('DistinctSeriesByCollectionSiteSubject', 'select distinct patient_id, series_instance_uid, dicom_file_type, modality, count(*)
from (
select distinct patient_id, series_instance_uid, sop_instance_uid, dicom_file_type, modality from (
select
   distinct patient_id, series_instance_uid, modality, sop_instance_uid,
   file_id, dicom_file_type
 from file_series natural join file_sop_common
   natural join file_patient
   natural join ctp_file natural join dicom_file
where
  project_name = ? and site_name = ? and patient_id = ?
  and visibility is null)
as foo
group by patient_id, series_instance_uid, sop_instance_uid, dicom_file_type, modality)
as foo
group by patient_id, series_instance_uid, dicom_file_type, modality
', ARRAY['project_name', 'site_name', 'patient_id'], 
                    ARRAY['patient_id', 'series_instance_uid', 'dicom_file_type', 'modality', 'count'], ARRAY['by_collection', 'find_series', 'compare_collection_site', 'search_series', 'edit_files'], 'posda_files', 'Get Series in A Collection, site with dicom_file_type, modality, and sop_count
')
        ;

            insert into queries
            values ('PixelInfoBySopInstance', 'select
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
', ARRAY['sop_instance_uid'], 
                    ARRAY['file_id', 'file', 'file_offset', 'size', 'bits_stored', 'bits_allocated', 'pixel_representation', 'number_of_frames', 'samples_per_pixel', 'pixel_rows', 'pixel_columns', 'photometric_interpretation', 'planar_configuration', 'modality'], '{}', 'posda_files', 'Get pixel descriptors for a particular image id
')
        ;

            insert into queries
            values ('GetIdOfNewCopyFromPublicRow', 'select currval(''copy_from_public_copy_from_public_id_seq'') as id', '{}', 
                    ARRAY['id'], ARRAY['bills_test', 'copy_from_public'], 'posda_files', 'Add a filter to a tab')
        ;

            insert into queries
            values ('ListClosedActivitiesWithItems', 'select
  distinct activity_id,
  brief_description,
  when_created,
  who_created,
  when_closed,
  count(distinct user_inbox_content_id) as num_items
from
  activity natural join activity_inbox_content
where when_closed is not null
group by activity_id, brief_description, when_created, who_created, when_closed
order by activity_id', '{}', 
                    ARRAY['activity_id', 'brief_description', 'when_created', 'who_created', 'when_closed', 'num_items'], ARRAY['AllCollections', 'queries', 'activities'], 'posda_queries', 'Get a list of available queries')
        ;

            insert into queries
            values ('GetPlans', 'select
  distinct project_name as collection,
  site_name as site,
  patient_id,
  series_instance_uid,
  file_id
from
  file_series natural join
  file_patient natural join ctp_file
where
  project_name = ? and
  visibility is null and
  file_id in (
select file_id from plan p natural join file_plan)', ARRAY['collection'], 
                    ARRAY['collection', 'site', 'patient_id', 'series_instance_uid', 'file_id'], ARRAY['Structure Sets', 'sops', 'LinkageChecks', 'plan_linkages'], 'posda_files', 'Get list of plan which reference unknown SOPs

')
        ;

            insert into queries
            values ('AddInsertedToFileCopyFromPublic', 'update file_copy_from_public set
  inserted_file_id = ?
where copy_from_public_id = ? and sop_instance_uid = ?', ARRAY['inserted_file_id', 'copy_from_public_id', 'sop_instance_uid'], 
                    '{}', ARRAY['bills_test', 'copy_from_public'], 'posda_files', 'Add a filter to a tab')
        ;

            insert into queries
            values ('VisualReviewStatusByIdWithVisibility', 'select
  distinct processing_status, review_status, dicom_file_type,  visibility,
  count(distinct image_equivalence_class_id) as num_equiv, count(distinct series_instance_uid) as num_series                                                               from
  image_equivalence_class natural join image_equivalence_class_input_image 
  natural join dicom_file natural join ctp_file
where
  visual_review_instance_id = ?
group by processing_status, review_status, dicom_file_type, visibility', ARRAY['id'], 
                    ARRAY['processing_status', 'review_status', 'dicom_file_type', 'visibility', 'num_equiv', 'num_series'], ARRAY['by_collection', 'find_series', 'compare_collection_site', 'search_series', 'edit_files', 'simple_phi', 'dciodvfy', 'ctp_details', 'select_for_phi', 'visual_review_reports', 'visual_review_new_workflow'], 'posda_files', 'Get Series in A Collection, site with dicom_file_type, modality, and sop_count
')
        ;

            insert into queries
            values ('AllPixelInfo', 'select
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
', '{}', 
                    ARRAY['file_id', 'file', 'file_offset', 'size', 'bits_stored', 'bits_allocated', 'pixel_representation', 'number_of_frames', 'samples_per_pixel', 'pixel_rows', 'pixel_columns', 'photometric_interpretation', 'modality'], '{}', 'posda_files', 'Get pixel descriptors for all files
')
        ;

            insert into queries
            values ('GetInfoForDupFilesByCollection', 'select
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
', ARRAY['collection'], 
                    ARRAY['file_id', 'image_id', 'patient_id', 'study_instance_uid', 'series_instance_uid', 'sop_instance_uid', 'modality'], '{}', 'posda_files', 'Get information related to duplicate files by collection
')
        ;

            insert into queries
            values ('VisibilityChangeEventsByCollection', 'select 
  distinct project_name as collection,
  site_name as site,
  patient_id,
  series_instance_uid,
  date_trunc(''day'', time_of_change) as when_done,
  user_name, prior_visibility, new_visibility, reason_for, count(distinct file_id) as num_files
from
   ctp_file natural join file_patient natural join file_series natural join file_visibility_change 
where project_name = ?
group by
 collection, site, patient_id, series_instance_uid, when_done, user_name, prior_visibility, new_visibility, reason_for
order by when_done desc', ARRAY['collection'], 
                    ARRAY['collection', 'site', 'patient_id', 'series_instance_uid', 'when_done', 'user_name', 'prior_visibility', 'new_visibility', 'reason_for', 'num_files'], ARRAY['meta', 'test', 'hello', 'bills_test', 'hide_events'], 'posda_files', 'Add a filter to a tab')
        ;

            insert into queries
            values ('GetNonDicomPathSeenId', 'select
  currval(''non_dicom_file_scan_non_dicom_file_scan_id_seq'') as id', '{}', 
                    ARRAY['id'], ARRAY['used_in_simple_phi', 'NotInteractive', 'non_dicom_phi'], 'posda_phi_simple', 'Get value seen if exists')
        ;

            insert into queries
            values ('InsertIntoPosdaPublicCompare', 'insert into posda_public_compare(
  compare_public_to_posda_instance_id,
  sop_instance_uid,
  posda_file_id,
  posda_file_path,
  public_file_path,
  short_report_file_id,
  long_report_file_id
) values ( ?, ?, ?, ?, ?, ?, ?)', ARRAY['compare_public_to_posda_instance_id', 'sop_instance_uid', 'posda_file_id', 'posda_file_path', 'public_file_path', 'short_report_file_id', 'long_report_file_id'], 
                    '{}', ARRAY['NotInteractive', 'Backlog', 'Transaction', 'public_posda_counts'], 'posda_files', 'Lock the file table in posda_files')
        ;

            insert into queries
            values ('SummaryOfSingleFileImportEventsByDateRange', 'select 
  distinct import_type, import_comment, min(import_time) as earliest, max(import_time) as latest,
  count(distinct import_event_id) as num_imports
from (
  select * 
  from (
    select
      distinct import_event_id, import_time, import_type, import_comment, count(distinct file_id)
    from
      import_event natural join file_import 
    where
      import_time > ?
      and import_time < ?
     group by import_event_id, import_time, import_type, import_comment
     order by import_time desc
  ) as foo where count = 1
) as foo 
group by import_type, import_comment;', ARRAY['from', 'to'], 
                    ARRAY['import_type', 'import_comment', 'earliest', 'latest', 'num_imports'], ARRAY['downloads_by_date', 'import_events'], 'posda_files', 'Counts query by Collection, Site
')
        ;

            insert into queries
            values ('AddPhiElement', 'insert into element_signature (
  element_signature,
  vr,
  is_private,
  private_disposition,
  name_chain
) values (
  ?, ?, ?, ?, ?
)
', ARRAY['element_signature', 'vr', 'is_private', 'private_disposition', 'name_chain'], 
                    '{}', ARRAY['NotInteractive', 'used_in_reconcile_tag_names'], 'posda_phi', 'Add an element_signature row to posda_phi')
        ;

            insert into queries
            values ('GetQualifiedCTQPByLikeCollectionSiteWithFIleCount', 'select 
  collection, site, patient_id, qualified, count(distinct file_id) as num_files
from
  clinical_trial_qualified_patient_id join file_patient using (patient_id)
where collection like ? and site = ? and qualified
group by collection, site, patient_id, qualified', ARRAY['collection_like', 'site'], 
                    ARRAY['collection', 'site', 'patient_id', 'qualified', 'num_files'], ARRAY['clin_qual'], 'posda_files', 'Create An Activity Timepoint

')
        ;

            insert into queries
            values ('SeriesWithDuplicatePixelDataTest', 'select 
  distinct project_name as collection,
  site_name as site,
  patient_id,
  series_instance_uid,
  count(distinct file_id) as num_files
from 
  file_series natural join file_image
  natural join file_patient
  natural join ctp_file
where 
  visibility is null 
  and image_id in (
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
              select distinct image_id, count(distinct file_id)
              from file_image natural join ctp_file
              where project_name = ? and visibility is null
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
) group by collection, site, patient_id, series_instance_uid
', ARRAY['collection'], 
                    ARRAY['collection', 'site', 'series_instance_uid', 'patient_id', 'num_files'], ARRAY['pixel_duplicates'], 'posda_files', 'Return a list of files with duplicate pixel data,
restricted to those files which have parsed DICOM data
representations in Database.
')
        ;

            insert into queries
            values ('PixelTypesWithRowsColumns', 'select
  distinct photometric_interpretation,
  samples_per_pixel,
  bits_allocated,
  bits_stored,
  high_bit,
  pixel_rows,
  pixel_columns,
  number_of_frames,
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
  pixel_rows,
  pixel_columns,
  number_of_frames,
  pixel_representation,
  planar_configuration,
  modality
order by
  count desc', '{}', 
                    ARRAY['photometric_interpretation', 'samples_per_pixel', 'bits_allocated', 'bits_stored', 'high_bit', 'pixel_rows', 'pixel_columns', 'number_of_frames', 'pixel_representation', 'planar_configuration', 'modality', 'count'], ARRAY['all', 'find_pixel_types', 'posda_files'], 'posda_files', 'Get distinct pixel types
')
        ;

            insert into queries
            values ('LookingForMissingHeadNeckPetCT2', 'select 
  distinct series_instance_uid, modality, 
  count(distinct file_id) as num_files, min(import_time) as first_load, max(import_time) as last_load
from
  file_series
  join file_import using(file_id)
  join import_event using(import_event_id)
where file_id in (      
  select
     distinct file_id
  from
    file_series join ctp_file using(file_id)
    join file_sop_common using(file_id) 
    join file_import using (file_id)
    join import_event using(import_event_id)
  where 
    project_name = ''Head-Neck-PET-CT'' and import_time > ''2018-04-01''
  )
group by series_instance_uid, modality', '{}', 
                    ARRAY['study_instance_uid', 'series_instance_uid', 'modality', 'num_files', 'first_load', 'last_load'], ARRAY['meta', 'test', 'hello', 'bills_test', 'bills_ad_hoc_scripts', 'for_tracy'], 'posda_files', 'Add a filter to a tab')
        ;

            insert into queries
            values ('CountsByPatientId', 'select
  distinct
    patient_id, image_type, dicom_file_type, modality,
    study_date, series_date,
    study_description,
    series_description, study_instance_uid, series_instance_uid,
    manufacturer, manuf_model_name, software_versions,
    count(distinct sop_instance_uid) as num_sops,
    count(distinct file_id) as num_files,
    min(import_time) as earliest,
    max(import_time) as latest
from
  ctp_file join file_patient using(file_id)
  join dicom_file using(file_id)
  join file_series using(file_id)
  join file_sop_common using(file_id)
  join file_study using(file_id)
  join file_equipment using(file_id)
  join file_import using(file_id)
  join import_event using(import_event_id)
  left join file_image using(file_id)
  left join image using (image_id)
where
  patient_id = ? and visibility is null
group by
  patient_id, image_type, dicom_file_type, modality, study_date, 
  series_date, study_description,
  series_description, study_instance_uid, series_instance_uid,
  manufacturer, manuf_model_name, software_versions
order by
  patient_id, study_instance_uid, series_instance_uid, image_type,
  modality, study_date, series_date, study_description,
  series_description,
  manufacturer, manuf_model_name, software_versions
', ARRAY['patient_id'], 
                    ARRAY['patient_id', 'image_type', 'dicom_file_type', 'modality', 'study_date', 'series_date', 'study_description', 'series_description', 'study_instance_uid', 'series_instance_uid', 'manufacturer', 'manuf_model_name', 'software_versions', 'num_sops', 'num_files', 'earliest', 'latest'], ARRAY['counts', 'count_queries'], 'posda_files', 'Counts query by Collection, Site
')
        ;

            insert into queries
            values ('DualFileNameReportByImportEvent', 'select
  file_id, patient_id,
  study_instance_uid, study_date, study_description, series_instance_uid,
  modality, series_date, series_description, dicom_file_type, file_name,
  root_path || ''/'' || l.rel_path as path 
from
  file_import natural join file_patient natural join file_series natural join
  file_study natural join dicom_file join file_location l using(file_id) natural join
  file_storage_root
where
  import_event_id = ?
order by file_name', ARRAY['import_event_id'], 
                    ARRAY['file_id', 'patient_id', 'study_instance_uid', 'study_date', 'study_description', 'series_instance_uid', 'modality', 'series_date', 'series_description', 'dicom_file_type', 'file_name', 'path'], ARRAY['import_events'], 'posda_files', 'List of values seen in scan by ElementSignature with VR and count
')
        ;

            insert into queries
            values ('GetSeenValue', 'select * from seen_value where value = ?
', ARRAY['value'], 
                    ARRAY['seen_value_id', 'value'], ARRAY['UsedInPhiSeriesScan', 'NotInteractive'], 'posda_phi', 'Get Seen Value Id')
        ;

            insert into queries
            values ('GetPosdaPhiSimpleElementSigInfo', 'select
  element_sig_pattern,
  vr,
  is_private,
  private_disposition,
  tag_name
from element_seen

', '{}', 
                    ARRAY['element_sig_pattern', 'vr', 'is_private', 'private_disposition', 'name_chain'], ARRAY['NotInteractive', 'used_in_reconcile_tag_names'], 'posda_phi_simple', 'Get the relevant features of an element_signature in posda_phi_simple schema')
        ;

            insert into queries
            values ('FileWithInfoBySopInPosda', 'select 
  file_for.for_uid as frame_of_ref,
  iop, 
  ipp,
  pixel_spacing,
  pixel_rows,
  pixel_columns
from
  file_sop_common natural join ctp_file
  natural join file_for natural join file_image
  join image_geometry using (image_id)
  join image using (image_id)
where
  sop_instance_uid = ?
  and visibility is null', ARRAY['sop_instance_uid'], 
                    ARRAY['frame_of_ref', 'iop', 'ipp', 'pixel_spacing', 'pixel_rows', 'pixel_columns'], ARRAY['LinkageChecks', 'used_in_struct_linkage_check'], 'posda_files', 'Get list of Roi with info by file_id

')
        ;

            insert into queries
            values ('PatientStudySeriesHierarchyByCollectionSiteExt', 'select distinct
  patient_id,
  study_instance_uid,
  series_instance_uid,
  dicom_file_type,
  modality,
  count (distinct file_id) as num_files
from
  file_study natural join
  ctp_file natural join
  dicom_file natural join
  file_series natural join
  file_patient
where 
  file_id in (
    select distinct file_id
    from ctp_file
    where project_name = ? and site_name = ? and
    visibility is null
  )
group by patient_id, study_instance_uid, series_instance_uid,
  dicom_file_type, modality
order by patient_id, study_instance_uid, series_instance_uid', ARRAY['collection', 'site'], 
                    ARRAY['patient_id', 'study_instance_uid', 'series_instance_uid', 'dicom_file_type', 'modality', 'num_files'], ARRAY['Hierarchy', 'phi_simple', 'simple_phi'], 'posda_files', 'Construct list of files in a collection, site in a Patient, Study, Series Hierarchy')
        ;

            insert into queries
            values ('CreateElementSignature', 'insert into element_signature(element_signature, vr, is_private) values(?, ?, ?)
', ARRAY['element_signature', 'vr', 'is_private'], 
                    '{}', ARRAY['UsedInPhiSeriesScan', 'NotInteractive'], 'posda_phi', 'Create New Element Signature Id')
        ;

            insert into queries
            values ('AverageSecondsPerFile', 'select avg(seconds_per_file) from (
  select (send_ended - send_started)/number_of_files as seconds_per_file 
  from dicom_send_event where send_ended is not null and number_of_files > 0
  and send_started > ? and send_ended < ?
) as foo
', ARRAY['from_date', 'to_date'], 
                    ARRAY['avg'], ARRAY['send_to_intake'], 'posda_files', 'Average Time to send a file between times
')
        ;

            insert into queries
            values ('LookUpTagEle', 'select
  tag, name, keyword, vr, vm, is_retired, comments
from 
  dicom_element
where
  tag = ?', ARRAY['tag'], 
                    ARRAY['tag', 'name', 'keyword', 'vr', 'vm', 'is_retired', 'comments'], ARRAY['NotInteractive', 'used_in_dciodvfy'], 'dicom_dd', 'Get tag from name or keyword')
        ;

            insert into queries
            values ('RoundSummary1Recent', 'select
  distinct round_id,
  round_start, 
  round_end - round_start as duration, 
  round_end, 
  sum(num_entered + num_dups),
  ((round_end - round_start) / sum(num_entered + num_dups)) as sec_per_file
from
  round natural join round_collection
where
  round_end is not null and (now() - round_end) < ''24:00''
group by 
  round_id, round_start, duration, round_end 
order by round_id', '{}', 
                    ARRAY['round_id', 'round_start', 'duration', 'round_end', 'sum', 'sec_per_file'], ARRAY['NotInteractive', 'Backlog', 'Backlog Monitor', 'backlog_status'], 'posda_backlog', 'Summary of rounds')
        ;

            insert into queries
            values ('DistinctPatientStudySeriesByCollection', 'select distinct
  patient_id, 
  study_instance_uid,
  series_instance_uid, 
  dicom_file_type,
  modality, 
  count(distinct file_id) as num_files
from
  ctp_file
  natural join dicom_file
  natural join file_study
  natural join file_series
  natural join file_patient
where
  project_name = ? and
  visibility is null
group by
  patient_id, 
  study_instance_uid,
  series_instance_uid,
  dicom_file_type,
  modality
  ', ARRAY['collection'], 
                    ARRAY['patient_id', 'study_instance_uid', 'series_instance_uid', 'dicom_file_type', 'modality', 'num_files'], ARRAY['by_collection', 'find_series', 'search_series', 'send_series'], 'posda_files', 'Get Series in A Collection
')
        ;

            insert into queries
            values ('DupSopsByImportEventByPatLike', 'select
  distinct sop_instance_uid, count(distinct file_id) as num_files
from (
  select distinct sop_instance_uid, file_id 
  from file_sop_common 
  where file_id in (
    select
      distinct file_id from file_import where import_event_id in (select import_event_id from (
        select
          distinct import_event_id, import_time,  import_type, count(distinct file_id) as num_files
        from
          import_event natural join file_import natural join file_patient
        where
          import_type = ''multi file import'' and
          patient_id like ?
         group by import_event_id, import_time, import_type
       ) as foo
    )
  )
)as foo
group by sop_instance_uid
', ARRAY['patient_id_like'], 
                    ARRAY['sop_instance_uid', 'num_files'], ARRAY['adding_ctp', 'find_patients', 'no_ctp_patients', 'import_event'], 'posda_files', 'Get Series in A Collection
')
        ;

            insert into queries
            values ('GetDupsFromSimilarDupContourCounts', 'select distinct roi_id, count(*) from file_roi_image_linkage where
contour_digest in (select contour_digest from (select
  distinct contour_digest, count(*) from
(select
  distinct
  project_name as collection,
  site_name as site,
  patient_id,
  series_instance_uid,
  sop_class_uid,
  file_id,
  contour_digest
from
   ctp_file
   natural join file_patient
   natural join file_series
   natural join file_sop_common
  natural join file_roi_image_linkage
where file_id in (
  select distinct file_id from (
    select 
      distinct file_id, count(*) as num_dup_contours
    from
      file_roi_image_linkage 
    where 
      contour_digest in (
      select contour_digest
     from (
        select 
          distinct contour_digest, count(*)
        from
          file_roi_image_linkage group by contour_digest
     ) as foo
      where count > 1
    ) group by file_id order by num_dup_contours desc
  ) as foo
  where num_dup_contours = ?
)
) as foo
group by contour_digest)
as foo where count > 1)
group by roi_id order by count desc
', ARRAY['num_dup_contours'], 
                    ARRAY['roi_id', 'count'], ARRAY['Structure Sets', 'sops', 'LinkageChecks', 'dup_contours'], 'posda_files', 'Get list of plan which reference unknown SOPs

')
        ;

            insert into queries
            values ('UnHideFile', 'update
  ctp_file
set
  visibility = null
where
  file_id = ?
', ARRAY['file_id'], 
                    '{}', ARRAY['ImageEdit', 'NotInteractive'], 'posda_files', 'Hide a file
')
        ;

            insert into queries
            values ('GetCTQPByCollectionSite', 'select 
  collection, site, patient_id, qualified
from
  clinical_trial_qualified_patient_id
where collection = ? and site = ?', ARRAY['collection', 'site'], 
                    ARRAY['collection', 'site', 'patient_id', 'qualified'], ARRAY['clin_qual'], 'posda_files', 'Create An Activity Timepoint

')
        ;

            insert into queries
            values ('TotalDiskSpace', 'select
  sum(size) as total_bytes
from
  file
where
  file_id in (
  select distinct file_id
  from ctp_file
  )
', '{}', 
                    ARRAY['total_bytes'], ARRAY['all', 'posda_files', 'storage_used'], 'posda_files', 'Get total disk space used
')
        ;

            insert into queries
            values ('DistinctSeriesByCollection', 'select distinct series_instance_uid, patient_id, dicom_file_type, modality, count(*)
from (
select distinct series_instance_uid, patient_id, sop_instance_uid, dicom_file_type, modality from (
select
   distinct series_instance_uid, patient_id, modality, sop_instance_uid,
   file_id, dicom_file_type
 from file_series natural join file_sop_common
   natural join ctp_file natural join dicom_file natural join file_patient
where
  project_name = ?
  and visibility is null)
as foo
group by series_instance_uid, patient_id, sop_instance_uid, dicom_file_type, modality)
as foo
group by series_instance_uid, patient_id, dicom_file_type, modality
', ARRAY['collection'], 
                    ARRAY['series_instance_uid', 'patient_id', 'dicom_file_type', 'modality', 'count'], ARRAY['by_collection', 'find_series', 'search_series', 'send_series', 'phi_simple', 'simple_phi', 'dciodvfy'], 'posda_files', 'Get Series in A Collection
')
        ;

            insert into queries
            values ('LastFilesInSeries', 'select root_path || ''/'' || rel_path as path
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
', ARRAY['series_instance_uid'], 
                    ARRAY['path'], ARRAY['by_series'], 'posda_files', 'Last files uploaded by series
')
        ;

            insert into queries
            values ('FileSizeByCollection', 'select project_name as collection,sum(size) as total_disc_used from file natural join ctp_file group by project_name order by total_disc_used desc', '{}', 
                    ARRAY['collection', 'total_disc_used'], ARRAY['AllCollections', 'queries'], 'posda_files', 'Get a list of available queries')
        ;

            insert into queries
            values ('HideFile', 'update
  ctp_file
set
  visibility = ''hidden''
where
  file_id = ?
', ARRAY['file_id'], 
                    '{}', ARRAY['ImageEdit', 'NotInteractive'], 'posda_files', 'Hide a file
')
        ;

            insert into queries
            values ('DupSopCountsByCSS', 'select
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
', ARRAY['collection', 'site', 'subject'], 
                    ARRAY['sop_instance_uid', 'min', 'max', 'count'], '{}', 'posda_files', 'Counts of DuplicateSops By Collection, Site, Subject
')
        ;

            insert into queries
            values ('StorageRootIdByClass', 'select file_storage_root_id as id from file_storage_root where
storage_class = ?', ARRAY['storage_class'], 
                    ARRAY['id'], ARRAY['used_in_file_import_into_posda', 'used_in_file_migration'], 'posda_files', 'Get file storage root by storage class

Used in file migration; should return a single row. If not, error in database configuration.')
        ;

            insert into queries
            values ('CountsByCollectionSiteExt', 'select
  distinct
    patient_id, image_type, dicom_file_type, modality, study_date, study_description,
    series_description, study_instance_uid, series_instance_uid,
    manufacturer, manuf_model_name, software_versions,
    count(distinct sop_instance_uid) as num_sops,
    count(distinct file_id) as num_files
from
  ctp_file join file_patient using(file_id)
  join dicom_file using(file_id)
  join file_series using(file_id)
  join file_sop_common using(file_id)
  join file_study using(file_id)
  join file_equipment using(file_id)
  left join file_image using(file_id)
  left join image using (image_id)
where
  project_name = ? and site_name = ? and visibility is null
group by
  patient_id, image_type, dicom_file_type, modality, study_date, study_description,
  series_description, study_instance_uid, series_instance_uid,
  manufacturer, manuf_model_name, software_versions
order by
  patient_id, study_instance_uid, series_instance_uid, image_type, dicom_file_type,
  modality, study_date, study_description,
  series_description,
  manufacturer, manuf_model_name, software_versions
', ARRAY['collection', 'site'], 
                    ARRAY['patient_id', 'image_type', 'dicom_file_type', 'modality', 'study_date', 'study_description', 'series_description', 'study_instance_uid', 'series_instance_uid', 'manufacturer', 'manuf_model_name', 'software_versions', 'num_sops', 'num_files'], ARRAY['counts'], 'posda_files', 'Counts query by Collection, Site
')
        ;

            insert into queries
            values ('BackgroundersByDateRange', 'select
  distinct operation_name, count(distinct subprocess_invocation_id) as num_invocations
from
  background_subprocess natural join subprocess_invocation
where
  when_script_ended is not null and operation_name is not null and
  when_script_started > ? and when_script_ended < ? and
  when_script_ended is not null
group by operation_name
order by num_invocations desc', ARRAY['from', 'to'], 
                    ARRAY['operation_name', 'num_invocations'], ARRAY['invoking_user'], 'posda_files', 'Get a list of collections and sites
')
        ;

            insert into queries
            values ('SimplePhiReportAllPrivateOnlyMetaQuote', 'select 
  distinct ''<'' || element_sig_pattern || ''>''  as element, length(value) as val_length,
  vr, 
  ''<'' || value || ''>'' as q_value, tag_name as description, private_disposition as disp, count(*) as num_series
from element_value_occurance natural join element_seen natural join value_seen
where 
  phi_scan_instance_id = ? and is_private
group by element_sig_pattern, vr, value, val_length, description, disp
order by vr, element, val_length', ARRAY['scan_id'], 
                    ARRAY['element', 'vr', 'disp', 'q_value', 'description', 'num_series'], ARRAY['adding_ctp', 'for_scripting', 'phi_reports'], 'posda_phi_simple', 'Simple Phi Report with Meta Quotes')
        ;

            insert into queries
            values ('GoInServicePosdaImport', 'update import_control
set status = ''service process running'',
  processor_pid = ?', ARRAY['pid'], 
                    '{}', ARRAY['NotInteractive', 'PosdaImport'], 'posda_files', 'Claim control of posda_import')
        ;

            insert into queries
            values ('GetBackgroundSubprocessId', 'select currval(''background_subprocess_background_subprocess_id_seq'') as id', '{}', 
                    ARRAY['id'], ARRAY['NotInteractive', 'used_in_background_processing'], 'posda_queries', 'Get the id of the background_subprocess row just created')
        ;

            insert into queries
            values ('UpdatePatientImportStatus', 'update patient_import_status set 
  patient_import_status = ?
where patient_id = ?
', ARRAY['patient_id', 'status'], 
                    NULL, ARRAY['NotInteractive', 'PatientStatus', 'Update'], 'posda_files', 'Update Patient Status
For use in scripts
Not really intended for interactive use
')
        ;

            insert into queries
            values ('CountRowsInDicomFileWithPopulatedPixelInfo', 'select 
 count(*) from dicom_file where has_pixel_data is not null', '{}', 
                    ARRAY['count'], ARRAY['adding_pixels_to_dicom_file'], 'posda_files', 'count rows in dicom_file with unpopulated pixel info')
        ;

            insert into queries
            values ('GetFilesToEditBySopForLGCP', 'select
  file_id, root_path || ''/'' || rel_path as path
from 
  file_sop_common natural join file_series natural join
  file_location natural join file_storage_root natural join ctp_file
where 
  sop_instance_uid = ? and series_instance_uid != ?
  and visibility is null
', ARRAY['sop_instance_uid', 'series_instance_uid'], 
                    ARRAY['file_id', 'path'], ARRAY['Curation of Lung-Fused-CT-Pathology'], 'posda_files', 'Get the list of files by sop, excluding base series')
        ;

            insert into queries
            values ('StatusOfDciodvfyScans', 'select 
  dciodvfy_scan_instance_id as id,
  type_of_unit,
  description_of_scan,
  number_units,
  scanned_so_far,
  start_time,
  end_time
from 
  dciodvfy_scan_instance
order by id
  ', '{}', 
                    ARRAY['id', 'type_of_unit', 'description_of_scan', 'number_units', 'scanned_so_far', 'start_time', 'end_time'], ARRAY['tag_usage', 'dciodvfy'], 'posda_phi_simple', 'Show all the dciodvfy scans')
        ;

            insert into queries
            values ('GetLinkedSopsByStructureSetFileId', 'select
  distinct sop_instance
from contour_image natural join  file_structure_set natural join roi natural join roi_contour
where file_id = ?', ARRAY['file_id'], 
                    ARRAY['sop_instance'], ARRAY['Structure Sets', 'sops', 'LinkageChecks'], 'posda_files', 'Get List of SOP''s linked in SS

')
        ;

            insert into queries
            values ('PosdaTotals', 'select 
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
', '{}', 
                    ARRAY['project_name', 'site_name', 'num_subjects', 'num_studies', 'num_series', 'total_files', 'total_sops'], '{}', 'posda_files', 'Produce total counts for all collections currently in Posda
')
        ;

            insert into queries
            values ('GetPixelDescriptorByDigestNew', 'select
  samples_per_pixel, 
  number_of_frames, 
  pixel_rows,
  pixel_columns,
  bits_stored,
  bits_allocated,
  high_bit, 
  pixel_data_offset, 
  pixel_data_length,
  root_path || ''/'' || rel_path as path
from
  image natural join file_image
  natural join dicom_file natural join file_location
  natural join file_storage_root where pixel_data_digest = ?
limit 1', ARRAY['pixel_data_digest'], 
                    ARRAY['samples_per_pixel', 'number_of_frames', 'pixel_rows', 'pixel_columns', 'bits_stored', 'bits_allocated', 'high_bit', 'pixel_data_offset', 'pixel_data_length', 'path'], ARRAY['meta', 'test', 'hello'], 'posda_files', 'Find Duplicated Pixel Digest')
        ;

            insert into queries
            values ('GetPtInfoBySeries', 'select 
  distinct 
  pti_radiopharmaceutical as radiopharmaceutical, 
  pti_radionuclide_total_dose as total_dose,
  pti_radionuclide_half_life as half_life,
  pti_radionuclide_positron_fraction as positron_fraction, 
  pti_fov_shape as fov_shape,
  pti_fov_dimensions as fov_dim,
  pti_collimator_type as coll_type,
  pti_reconstruction_diameter as recon_diam
from file_pt_image natural join file_patient natural join file_series natural join ctp_file 
where series_instance_uid = ? and visibility is null', ARRAY['series_instance_uid'], 
                    ARRAY['radiopharmaceutical', 'total_dose', 'half_life', 'positron_fraction', 'fov_shape', 'fov_dim', 'coll_type', 'recon_diam'], ARRAY['populate_posda_files', 'bills_test'], 'posda_files', 'Gets count of all files which are PET''s which haven''t been imported into file_pt_image yet.

')
        ;

            insert into queries
            values ('ListOfQueriesPerformedByUserByDate', 'select
  query_invoked_by_dbif_id as id,
  query_name,
  query_end_time - query_start_time as duration,
  invoking_user as invoked_by,
  query_start_time as at, 
  number_of_rows
from
  query_invoked_by_dbif
where
  invoking_user = ? and
  query_start_time > ? and query_end_time < ?
order by query_start_time', ARRAY['user', 'from', 'to'], 
                    ARRAY['id', 'query_name', 'duration', 'invoked_by', 'at', 'number_of_rows'], ARRAY['AllCollections', 'q_stats_by_date'], 'posda_queries', 'Get a list of collections and sites
')
        ;

            insert into queries
            values ('GetDciodvfyWarningMissingDicomDir', 'select
  dciodvfy_warning_id as id
from 
  dciodvfy_warning
where
  warning_type = ''MissingForDicomDir''
  and warning_tag = ?
 ', ARRAY['warning_tag'], 
                    ARRAY['id'], ARRAY['NotInteractive', 'used_in_dciodvfy'], 'posda_phi_simple', 'Get an dciodvfy_warnings row by warning_text (if present)')
        ;

            insert into queries
            values ('Checking Duplicate Series', 'select 
  distinct project_name as collection, site_name as site, patient_id,
  dicom_file_type, pixel_data_digest, sop_instance_uid
from
  file_series natural join file_patient natural join ctp_file natural join
  file_sop_common natural join dicom_file
where
  visibility is null and series_instance_uid = ?
order by sop_instance_uid', ARRAY['series_instance_uid'], 
                    ARRAY['collection', 'site', 'patient_id', 'dicom_file_type', 'pixel_data_digest', 'sop_instance_uid'], ARRAY['CPTAC Bolus September 2018'], 'posda_files', 'Get the list of files by sop, excluding base series')
        ;

            insert into queries
            values ('ColSiteDetails', 'select
  distinct project_name as collection,
  site_name as site,
  patient_id,
  patient_name,
  study_instance_uid,
  study_date,
  series_instance_uid,
  modality,
  count (distinct file_id) as num_files
from
  file_patient natural left join
  file_study natural left join
  file_series natural left join
  ctp_file
where
  project_name = ? and site_name = ? and visibility is null
group by
  project_name, site_name, 
  patient_id, patient_name, study_instance_uid, study_date,
  series_instance_uid, modality
order by 
  project_name, site_name, patient_id, study_date,
  modality
', ARRAY['collection', 'site'], 
                    ARRAY['collection', 'site', 'visibility', 'patient_id', 'patient_name', 'study_instance_uid', 'study_date', 'series_instance_uid', 'modality', 'num_files'], ARRAY['adding_ctp', 'find_patients', 'ctp_details'], 'posda_files', 'Get Series in A Collection
')
        ;

            insert into queries
            values ('GetDciodvfyErrorUnrecogEnum', 'select
  dciodvfy_error_id as id
from 
  dciodvfy_error
where
  error_type = ''UnrecognizedEnumeratedValue''
  and error_value = ?
  and error_tag = ?
  and error_index = ?', ARRAY['error_value', 'error_tag', 'error_index'], 
                    ARRAY['id'], ARRAY['NotInteractive', 'used_in_dciodvfy'], 'posda_phi_simple', 'Get an dciodvfy_errors row by error_text (if present)')
        ;

            insert into queries
            values ('RecordPatientStatusChange', 'insert into patient_import_status_change(
  patient_id, when_pat_stat_changed,
  pat_stat_change_who, pat_stat_change_why,
  old_pat_status, new_pat_status
) values (
  ?, now(),
  ?, ?,
  ?, ?
)
', ARRAY['patient_id', 'who', 'why', 'old_status', 'new_status'], 
                    NULL, ARRAY['NotInteractive', 'PatientStatus', 'Update'], 'posda_files', 'Record a change to Patient Import Status
For use in scripts
Not really intended for interactive use
')
        ;

            insert into queries
            values ('GetScanElementId', 'select currval(''scan_element_scan_element_id_seq'') as id', '{}', 
                    ARRAY['id'], ARRAY['NotInteractive', 'UsedInPhiSeriesScan'], 'posda_phi', 'Get current value of ScanElementId Sequence
')
        ;

            insert into queries
            values ('FromFileWithVisibilityBySopFromDicomEditCompare', 'select 
  sop_instance_uid,
  file_id as from_file_id,
  visibility as from_file_visibility
from
  ctp_file natural join file natural join file_sop_common,
  dicom_edit_compare
where
  from_file_digest = file.digest and
  subprocess_invocation_id = ?
order by sop_instance_uid', ARRAY['subprocess_invocation_id'], 
                    ARRAY['sop_instance_uid', 'from_file_id', 'from_file_visibility'], ARRAY['meta', 'test', 'hello', 'bills_test', 'hide_events'], 'posda_files', 'Add a filter to a tab')
        ;

            insert into queries
            values ('GetSsVolumeForStudySeriesCount', 'select 
  distinct for_uid, study_instance_uid, series_instance_uid,
  sop_class as sop_class_uid, count(distinct sop_instance) as num_sops
  from ss_for natural join ss_volume where structure_set_id in (
    select 
      structure_set_id 
    from
      file_structure_set fs, file_sop_common sc
    where
      sc.file_id = fs.file_id and sop_instance_uid = ?
)
group by for_uid, study_instance_uid, series_instance_uid, sop_class
', ARRAY['sop_instance_uid'], 
                    ARRAY['for_uid', 'study_instance_uid', 'series_instance_uid', 'sop_class_uid', 'num_sops'], ARRAY['Structure Sets', 'sops', 'LinkageChecks'], 'posda_files', 'Get Structure Set Volume

')
        ;

            insert into queries
            values ('EquipmentByPrivateTag', 'select distinct equipment_signature from (
select
  distinct element_signature, equipment_signature
from 
  equipment_signature natural join series_scan
  natural join scan_element natural join element_signature
  natural join scan_event
where scan_event_id = ? and is_private ) as foo
where element_signature = ?
order by equipment_signature;
', ARRAY['scan_id', 'element_signature'], 
                    ARRAY['equipment_signature'], ARRAY['tag_usage'], 'posda_phi', 'Which equipment signatures for which private tags
')
        ;

            insert into queries
            values ('Series In Posda By PatientId', 'select 
  distinct series_instance_uid
from
  file_series natural join file_patient natural join ctp_file
where 
  visibility is null and patient_id = ?

', ARRAY['patient_id'], 
                    ARRAY['series_instance_uid'], ARRAY['Reconcile Public and Posda for CPTAC'], 'posda_files', 'Get the list of files by sop, excluding base series')
        ;

            insert into queries
            values ('GetSeriesByVisualReviewIdAndStatus', 'select 
  distinct series_instance_uid
from
  image_equivalence_class
where
  visual_review_instance_id = ? and review_status = ?', ARRAY['visual_review_instance_id', 'review_status'], 
                    ARRAY['series_instance_uid'], ARRAY['signature', 'phi_review', 'visual_review', 'visual_review_new_workflow'], 'posda_files', 'Get a list of Series By Visual Review Id and Status
')
        ;

            insert into queries
            values ('ByDistinguishedDigest', 'select
  distinct project_name as collection,
  site_name as site,
  patient_id as subject,
  series_instance_uid, 
  count(distinct sop_instance_uid) as num_sops
from 
  ctp_file natural join
  file_patient natural join
  file_sop_common natural join
  file_series
where file_id in (
  select 
    file_id
  from
    file_image
    join image using(image_id)
    join unique_pixel_data using(unique_pixel_data_id)
  where digest = ?
  ) and visibility is null 
group by 
  collection,
  site,
  series_instance_uid,
  subject
order by
  collection,
  site,
  subject', ARRAY['pixel_digest'], 
                    ARRAY['collection', 'site', 'subject', 'series_instance_uid', 'num_sops'], ARRAY['duplicates', 'distinguished_digest'], 'posda_files', 'Return a count of duplicate SOP Instance UIDs
')
        ;

            insert into queries
            values ('FilesInSeriesWithPath', 'select
  distinct root_path || ''/'' || rel_path as file
from
  file_location natural join file_storage_root
  natural join ctp_file
  natural join file_series
where
  series_instance_uid = ? and visibility is null
', ARRAY['series_instance_uid'], 
                    ARRAY['file'], ARRAY['by_series', 'find_files', 'used_in_simple_phi'], 'posda_files', 'Get files in a series from posda database
')
        ;

            insert into queries
            values ('GetBackgroundButtons', 'select
    background_button_id,
    operation_name,
    object_class,
    button_text
from background_buttons

', '{}', 
                    ARRAY['background_button_id', 'operation_name', 'object_class', 'button_text'], ARRAY['NotInteractive', 'used_in_process_popup'], 'posda_queries', 'N
o
n
e')
        ;

            insert into queries
            values ('DicomFilesMissingThingsByDateRange', 'select
	dicom_file.file_id,
	project_name as collection,
	site_name as site,
	case when file_sop_common.file_id is null
		then ''X''
		else ''''
	end as file_sop_common_missing,
	case when file_patient.file_id is null
		then ''X''
		else ''''
	end as file_patient_missing,
	case when file_study.file_id is null
		then ''X''
		else ''''
	end as file_study_missing,
	case when file_series.file_id is null
		then ''X''
		else ''''
	end as file_series_missing,
	case when file_equipment.file_id is null
		then ''X''
		else ''''
	end as file_equipment_missing


from dicom_file
natural join import_event
natural join file_import
natural left join ctp_file
left join file_patient
	on dicom_file.file_id = file_patient.file_id
left join file_sop_common
	on dicom_file.file_id = file_sop_common.file_id
left join file_series
	on dicom_file.file_id = file_series.file_id
left join file_equipment
	on dicom_file.file_id = file_equipment.file_id
left join file_study
	on dicom_file.file_id = file_study.file_id

where 
	import_time >= ?
	and import_time < ?
	and (
		file_patient.file_id is null
		or file_sop_common.file_id is null
		or file_series.file_id is null
		or file_equipment.file_id is null
	)
', ARRAY['from', 'to'], 
                    ARRAY['file_id', 'collection', 'site', 'file_sop_common_missing', 'file_patient_missing', 'file_study_missing', 'file_series_missing', 'file_equipment_missing'], '{}', 'posda_files', 'List DICOM files which are missing one of:

* file_patient
* file_sop_common
* file_series
* file_equipment

Note that these could be missing due to a failure to fully 
parse the DICOM file. If that is the case, the CTP information
may also have failed (or been missing). Collection and Site
are included in this query but may be missing!')
        ;

            insert into queries
            values ('ListOfValuesByElementInScan', 'select element_signature, value                  
from element_signature natural join scan_element natural join seen_value natural join series_scan natural join scan_event where element_signature = ? and scan_event_id = ?;', ARRAY['element_signature', 'scan_id'], 
                    ARRAY['element_signature', 'value'], ARRAY['ElementDisposition'], 'posda_phi', 'Get List of Values for Private Element based on element_signature_id')
        ;

            insert into queries
            values ('UpdateStatusVisualReviewInstance', 'update visual_review_instance set
  visual_review_num_series_done = ?,
  visual_review_num_equiv_class = ?
where
  visual_review_instance_id = ?', ARRAY['visual_review_num_series_done', 'visual_review_num_equiv_class', 'visual_review_instance_id'], 
                    '{}', ARRAY['find_series', 'equivalence_classes', 'consistency', 'visual_review'], 'posda_files', 'Get Id of Visual Review Instance')
        ;

            insert into queries
            values ('VisualReviewStatusWithCollectionByIdWithVisibility', 'select 
  distinct project_name as collection, site_name as site, 
  series_instance_uid, visibility, review_status, modality, series_description,
  series_date, count(distinct image_equivalence_class_id) as num_equiv_classes, 
  count(distinct file_id) as num_files
from
  visual_review_instance natural join image_equivalence_class natural join
  image_equivalence_class_input_image natural join
  file_series natural join ctp_file
where
  visual_review_instance_id = ? and review_status = ?
group by collection, site, series_instance_uid, visibility, review_status, modality, series_description, series_date;', ARRAY['visual_review_instance_id', 'review_status'], 
                    ARRAY['collection', 'site', 'series_instance_uid', 'review_status', 'visibility', 'modality', 'series_description', 'series_date', 'num_equiv_classes', 'num_files'], ARRAY['by_collection', 'find_series', 'compare_collection_site', 'search_series', 'edit_files', 'simple_phi', 'dciodvfy', 'ctp_details', 'select_for_phi', 'visual_review_new_workflow'], 'posda_files', 'Get Series in A Collection, site with dicom_file_type, modality, and sop_count
')
        ;

            insert into queries
            values ('GetContourData', 'select
  contour_data
from
  roi_contour
where roi_contour_id = ?', ARRAY['roi_contour_id'], 
                    ARRAY['contour_data'], ARRAY['Structure Sets', 'sops', 'LinkageChecks'], 'posda_files', 'Get Contour Data by roi_contour_id
')
        ;

            insert into queries
            values ('GetMaxFileId', 'select
  max(file_id) as file_id
from
  file
', '{}', 
                    ARRAY['file_id'], ARRAY['used_in_file_import_into_posda', 'used_in_file_migration'], 'posda_files', 'Get count of files relative to storage root')
        ;

            insert into queries
            values ('DistinctSopsInSeriesForCompare', 'select distinct sop_instance_uid, dicom_file_type, sop_class_uid, modality, file_id
from file_sop_common natural join dicom_file  natural join file_series
where file_id in (
  select
    distinct file_id
  from
    file_series natural join ctp_file
  where
    series_instance_uid = ? and visibility is null
)
', ARRAY['series_instance_uid'], 
                    ARRAY['sop_instance_uid', 'dicom_file_type', 'sop_class_uid', 'modality', 'file_id'], ARRAY['compare_series'], 'posda_files', 'Get Distinct SOPs in Series with number files
Only visible filess
')
        ;

            insert into queries
            values ('GetPatientMappingExperimental', 'select
  from_patient_id,
  to_patient_id,
  to_patient_name,
  collection_name,
  site_name,
  batch_number,
  date_shift,
  ''<'' || diagnosis_date || ''>'' as diagnosis_date,
  ''<'' || baseline_date || ''>'' as baseline_date,
  ''<'' || date_trunc(''year'', diagnosis_date) || ''>'' as year_of_diagnosis,
  baseline_date - diagnosis_date as computed_shift
from
  patient_mapping
  ', '{}', 
                    ARRAY['from_patient_id', 'to_patient_id', 'to_patient_name', 'collection_name', 'site_name', 'batch_number', 'date_shift', 'diagnosis_date', 'baseline_date', 'year_of_diagnosis', 'computed_shift'], ARRAY['adding_ctp', 'for_scripting', 'patient_mapping'], 'posda_files', 'Retrieve entries from patient_mapping table')
        ;

            insert into queries
            values ('SsWithClosedContoursWithNoLinkage', 'select 
  distinct project_name as collection,
  site_name as site, patient_id, series_instance_uid, file_id
from ctp_file natural join file_patient natural join file_series 
where project_name = ? and visibility is null
  and file_id in (
  select distinct file_id from file_structure_set where structure_set_id in (
    select distinct structure_set_id from roi where roi_id in (
      select distinct roi_id from roi_contour where roi_contour_id in (
        select distinct roi_id from roi r where exists (
          select * from roi_contour c where r.roi_id = c.roi_id and geometric_type = ''CLOSED_PLANAR'') 
          and roi_id in (     
            select distinct roi_id from roi r where not exists (
              select * from file_roi_image_linkage l where l.roi_id = r.roi_id
            )
         )
       )
     )
   )
)', ARRAY['collection'], 
                    ARRAY['collection', 'site', 'patient_id', 'file_id', 'series_instance_uid'], ARRAY['Structure Sets', 'sops', 'LinkageChecks', 'struct_linkages'], 'posda_files', 'Get list of plan which reference unknown SOPs

')
        ;

            insert into queries
            values ('NonDicomFileInPosdaByScanPathValue', 'select 
  distinct posda_file_id as file_id, non_dicom_file_type as type, ''<'' ||non_dicom_path || ''>'' as path,
  ''<'' || value || ''>'' as q_value
from
  non_dicom_path_value_occurrance natural join
  non_dicom_path_seen natural join
  value_seen natural join
  non_dicom_file_scan natural join
  phi_non_dicom_scan_instance
where 
  phi_non_dicom_scan_instance_id = ? and 
  file_type = ? and 
  non_dicom_path = ? and 
  value = ?
order by type, path, q_value', ARRAY['scan_id', 'file_type', 'non_dicom_path', 'value'], 
                    ARRAY['file_id', 'type', 'path', 'q_value', 'num_files'], ARRAY['adding_ctp', 'for_scripting', 'non_dicom_phi'], 'posda_phi_simple', 'Simple Phi Report with Meta Quotes')
        ;

            insert into queries
            values ('DuplicateSopsInSeriesExperimental', 'select 
  sop_instance_uid, first_f as early_file, last_f as late_file
from (
  select 
    distinct sop_instance_uid, min(file_id) as first_f, max(file_id) as last_f
  from
     file_series natural join file_sop_common natural join ctp_file
  where
     series_instance_uid = ? and visibility is null
  group by sop_instance_uid
) as foo
where first_f < last_f', ARRAY['series_instance_uid'], 
                    ARRAY['sop_instance_uid', 'early_file', 'late_file'], ARRAY['by_series', 'dup_sops', 'ACRIN-FMISO-Brain Duplicate Elimination'], 'posda_files', 'List of Actual duplicate SOPs (i.e. different files, same SOP)
in a series
')
        ;

            insert into queries
            values ('DeleteFilterFromTab', 'delere from query_tabs_query_tag_filter
where query_tab_name = ? and filter_name = ?', ARRAY['query_tab_name', 'filter_name'], 
                    '{}', ARRAY['meta', 'test', 'hello', 'query_tabs'], 'posda_queries', 'Remove a filter from a tab')
        ;

            insert into queries
            values ('GetSeriesWithImageByCollectionSiteDateRange', 'select distinct
  project_name as collection, site_name as site,
  patient_id, modality, series_instance_uid, 
  count(distinct sop_instance_uid) as num_sops,
  count(distinct file_id) as num_files
from
  file_series natural join file_sop_common
  natural join file_patient
  natural join file_image natural join ctp_file
  natural join file_import natural join import_event
where project_name = ? and site_name = ? and visibility is null
  and import_time > ? and import_time < ?
group by
  collection, site, patient_id, modality, series_instance_uid
', ARRAY['collection', 'site', 'from', 'to'], 
                    ARRAY['collection', 'site', 'patient_id', 'modality', 'series_instance_uid', 'num_sops', 'num_files'], ARRAY['signature', 'phi_review', 'visual_review'], 'posda_files', 'Get a list of Series with images by CollectionSite
')
        ;

            insert into queries
            values ('GetAllFilesAndDigests', 'select 
  received_file_path, file_digest
from 
  request

', '{}', 
                    ARRAY['received_file_path', 'digest'], ARRAY['NotInteractive', 'Backlog'], 'posda_backlog', 'Get all files with digests in backlog')
        ;

            insert into queries
            values ('GetSeriesWithImageByCollectionSite', 'select distinct
  project_name as collection, site_name as site,
  patient_id, modality, series_instance_uid, 
  count(distinct sop_instance_uid) as num_sops,
  count(distinct file_id) as num_files
from
  file_series natural join file_sop_common
  natural join file_patient
  natural join file_image natural join ctp_file
  natural join file_import natural join import_event
where project_name = ? and site_name = ? and visibility is null
group by
  collection, site, patient_id, modality, series_instance_uid
', ARRAY['collection', 'site'], 
                    ARRAY['collection', 'site', 'patient_id', 'modality', 'series_instance_uid', 'num_sops', 'num_files'], ARRAY['signature', 'phi_review', 'visual_review'], 'posda_files', 'Get a list of Series with images by CollectionSite
')
        ;

            insert into queries
            values ('DispositionsVersusChanges', 'select 
  element_sig_pattern, tag_name, element_seen_id, private_disposition, when_changed, new_disposition
from element_seen natural join element_disposition_changed 
order by element_sig_pattern, when_changed', '{}', 
                    ARRAY['element_sig_pattern', 'tag_name', 'element_seen_id', 'private_disposition', 'when_changed', 'new_disposition'], ARRAY['tag_usage', 'used_in_phi_maint', 'phi_maint'], 'posda_phi_simple', 'Private tags with no disposition with values in phi_simple')
        ;

            insert into queries
            values ('PatientsWithNoCtpLike', 'select
  distinct patient_id,
  count(distinct series_instance_uid) as num_series,
  count(distinct file_id) as num_files,
  min(import_time) as first_import,
  max(import_time) as last_import
from
  file_patient sc natural join file_series
  natural join file_import natural join import_event
where
  not exists (select file_id from ctp_file c where sc.file_id = c.file_id) and patient_id like ?
group by patient_id;', ARRAY['patient_match'], 
                    ARRAY['patient_id', 'num_series', 'num_files'], ARRAY['adding_ctp', 'find_patients', 'no_ctp_patients'], 'posda_files', 'Get Series in A Collection
')
        ;

            insert into queries
            values ('FilesIdsInSeriesWithVisibility', 'select
  file_id, visibility
from
  ctp_file
  natural join file_series
where
  series_instance_uid = ?
', ARRAY['series_instance_uid'], 
                    ARRAY['file_id', 'visibility'], ARRAY['by_series', 'find_files', 'used_in_simple_phi'], 'posda_files', 'Get files in a series from posda database
')
        ;

            insert into queries
            values ('DoseLinkageToPlanByCollectionSite', 'select
  sop_instance_uid as referencing_dose,
  rt_dose_referenced_plan_uid as referenced_plan
from
  rt_dose natural join file_dose natural join file_sop_common natural join ctp_file
where
  project_name = ? and site_name = ? and visibility is null', ARRAY['collection', 'site'], 
                    ARRAY['referencing_dose', 'referenced_plan'], ARRAY['Structure Sets', 'sops', 'LinkageChecks', 'plan_linkages', 'dose_linkages'], 'posda_files', 'Get list of plan which reference unknown SOPs

')
        ;

            insert into queries
            values ('CountsByCollectionLikeDateRangePlus', 'select
  distinct
    patient_id, image_type, dicom_file_type, modality,
    study_date, series_date,
    study_description,
    series_description, study_instance_uid, series_instance_uid,
    manufacturer, manuf_model_name, software_versions,
    count(distinct sop_instance_uid) as num_sops,
    count(distinct file_id) as num_files,
    min(import_time) as earliest,
    max(import_time) as latest
from
  ctp_file join file_patient using(file_id)
  join dicom_file using(file_id)
  join file_series using(file_id)
  join file_sop_common using(file_id)
  join file_study using(file_id)
  join file_equipment using(file_id)
  join file_import using(file_id)
  join import_event using(import_event_id)
  left join file_image using(file_id)
  left join image using (image_id)
where
  file_id in (
    select file_id 
    from file_import natural join import_event
    where import_time > ? and import_time < ?
  ) and project_name like ? and visibility is null
group by
  patient_id, image_type, dicom_file_type, modality, study_date, 
  series_date, study_description,
  series_description, study_instance_uid, series_instance_uid,
  manufacturer, manuf_model_name, software_versions
order by
  patient_id, study_instance_uid, series_instance_uid, image_type,
  modality, study_date, series_date, study_description,
  series_description,
  manufacturer, manuf_model_name, software_versions
', ARRAY['from', 'to', 'collection_like'], 
                    ARRAY['patient_id', 'image_type', 'dicom_file_type', 'modality', 'study_date', 'series_date', 'study_description', 'series_description', 'study_instance_uid', 'series_instance_uid', 'manufacturer', 'manuf_model_name', 'software_versions', 'num_sops', 'num_files', 'earliest', 'latest'], ARRAY['counts', 'count_queries'], 'posda_files', 'Counts query by Collection, Site
')
        ;

            insert into queries
            values ('DistinctVrByScan', 'select 
  distinct vr, count(*) as num_series
from element_value_occurance natural join element_seen natural join value_seen
where 
  phi_scan_instance_id = ? 
group by vr', ARRAY['scan_id'], 
                    ARRAY['vr', 'num_series'], ARRAY['tag_usage', 'simple_phi'], 'posda_phi_simple', 'Status of PHI scans
')
        ;

            insert into queries
            values ('SubjectsWithDupSops', 'select
  distinct collection, site, patient_id, count(*)
from (
  select
    distinct project_name as collection,
    site_name as site, patient_id,
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
group by collection, site, patient_id
', '{}', 
                    ARRAY['collection', 'site', 'patient_id', 'count'], ARRAY['duplicates', 'dup_sops'], 'posda_files', 'Return a count of duplicate SOP Instance UIDs
')
        ;

            insert into queries
            values ('UpdateDicomEditCompareDispositionStatus', 'update dicom_edit_compare_disposition set
  current_disposition = ?,
  last_updated = now()
where
  subprocess_invocation_id = ?
', ARRAY['current_disposition', 'subprocess_invocation_id'], 
                    '{}', ARRAY['adding_ctp', 'for_scripting'], 'posda_files', 'Update status of an entry in dicom_edit_compare_disposition

From script only.  Don''t run from user interface (needs valid subprocess_invocation_id)')
        ;

            insert into queries
            values ('GetVisualReviewInstanceId', 'select currval(''visual_review_instance_visual_review_instance_id_seq'') as id', '{}', 
                    ARRAY['id'], ARRAY['find_series', 'equivalence_classes', 'consistency', 'visual_review'], 'posda_files', 'Get Id of Visual Review Instance')
        ;

            insert into queries
            values ('GetSeriesByPatId', 'select
  distinct series_instance_uid, count(distinct file_id) as num_files
from
  file_series natural join file_patient natural join ctp_file
where
  patient_id = ? and
  visibility is null
group by series_instance_uid', ARRAY['patient_id'], 
                    ARRAY['series_instance_uid', 'num_files'], ARRAY['meta', 'test', 'hello', 'query_tabs', 'bills_test'], 'posda_files', 'See if ctp_file_row exists')
        ;

            insert into queries
            values ('FileStorageTotalBytes', 'select
  sum(size) as total_bytes
from file
', '{}', 
                    ARRAY['total_bytes'], ARRAY['AllCollections', 'postgres_stats', 'database_size'], 'posda_files', 'Get a list of collections and sites
')
        ;

            insert into queries
            values ('ShowAllHideEventsByCollectionSite', 'select
  file_id,
  user_name,
  time_of_change,
  prior_visibility,
  new_visibility,
  reason_for
from
   file_visibility_change 
where file_id in (
  select file_id 
  from ctp_file 
  where project_name = ? and site_name = ? 
)', ARRAY['collection', 'site'], 
                    ARRAY['file_id', 'user_name', 'time_of_change', 'prior_visibility', 'new_visibility', 'reason_for'], ARRAY['old_hidden'], 'posda_files', 'Show All Hide Events by Collection, Site')
        ;

            insert into queries
            values ('CreateActivity', 'insert into activity(brief_description, when_created, who_created) values (
?, now(), ?);', ARRAY['description', 'user'], 
                    '{}', ARRAY['AllCollections', 'queries', 'activity_support'], 'posda_queries', 'Get a list of available queries')
        ;

            insert into queries
            values ('GetSsReferencingKnownImages', 'select
  project_name as collection,
  site_name as site,
  patient_id, file_id
from
  ctp_file natural join file_patient
where file_id in (
  select
    distinct ss_file_id as file_id 
  from (
    select
      sop_instance_uid, ss_file_id 
    from (
      select 
        distinct
           linked_sop_instance_uid as sop_instance_uid,
           file_id as ss_file_id
      from
        file_roi_image_linkage
    ) foo left join file_sop_common using(sop_instance_uid)
    join ctp_file using(file_id)
  where
    visibility is null
  ) as foo
)
order by collection, site, patient_id, file_id
', '{}', 
                    ARRAY['collection', 'site', 'patient_id', 'file_id'], ARRAY['Structure Sets', 'sops', 'LinkageChecks', 'struct_linkages'], 'posda_files', 'Get list of plan which reference unknown SOPs

')
        ;

            insert into queries
            values ('SeriesInHierarchyBySeriesWithFileTypeModality', 'select distinct
  project_name as collection,
  site_name as site,
  patient_id,
  study_instance_uid,
  series_instance_uid,
  dicom_file_type,
  modality,
  count(distinct file_id) as num_files
from
  file_patient natural join
  file_study natural join
  file_series natural join
  dicom_file natural join 
  ctp_file
where file_id in (
  select
    distinct file_id
  from
    file_series natural join ctp_file
  where
    series_instance_uid = ? and visibility is null
)
group by collection, site, patient_id, 
  study_instance_uid, series_instance_uid,
  dicom_file_type, modality
order by
  project_name, site_name, patient_id,
  study_instance_uid, series_instance_uid
', ARRAY['series_instance_uid'], 
                    ARRAY['collection', 'site', 'patient_id', 'study_instance_uid', 'series_instance_uid', 'dicom_file_type', 'modality', 'num_files'], ARRAY['by_series_instance_uid', 'posda_files', 'sops'], 'posda_files', 'Get Collection, Site, Patient, Study Hierarchy in which series resides
')
        ;

            insert into queries
            values ('FindUnpopulatedPetsWithCount', 'select
  file_id, root_path || ''/'' || rel_path as file_path
from file_location natural join file_storage_root
where file_id in
(
  select distinct file_id from dicom_file df
  where dicom_file_type = ''Positron Emission Tomography Image Storage''
  and not exists (select file_id from file_pt_image pti where pti.file_id = df.file_id)
)
limit ?', ARRAY['n'], 
                    ARRAY['file_id', 'file_path'], ARRAY['populate_posda_files', 'bills_test'], 'posda_files', 'Get''s all files which are PET''s which haven''t been imported into file_pt_image yet.<br>

Ok to run this interactively, but use small n')
        ;

            insert into queries
            values ('SubjectLoadDaysByCollection', 'select
  distinct collection, site, subj, date_trunc(?, time_received) as time,
  count(*) as number_of_files,
  max(time_entered - time_received) as max_delay,
  min(time_entered - time_received) as min_delay
from request natural join submitter
where time_received > ? and time_received < ?
  and collection = ?
group by collection, site, subj, time order by time desc, collection, site, subj', ARRAY['interval_type', 'from', 'to', 'collection'], 
                    ARRAY['collection', 'site', 'subj', 'time', 'number_of_files', 'max_delay', 'min_delay'], ARRAY['find_series', 'for_tracy', 'backlog_round_history'], 'posda_backlog', 'Get List of Series by Subject Name')
        ;

            insert into queries
            values ('InsertIntoPatientMappingBaselineBatch', 'insert into patient_mapping(
  from_patient_id,
  to_patient_id,
  to_patient_name,
  collection_name,
  site_name,
  batch_number,
  diagnosis_date,
  baseline_date) values (
  ?, ?, ?, ?, ?, ?, ?, ?)', ARRAY['from_patient_id', 'to_patient_id', 'to_patient_name', 'collection_name', 'site_name', 'batch_number', 'date_shift'], 
                    '{}', ARRAY['adding_ctp', 'mapping_tables', 'insert_pat_mapping'], 'posda_files', 'Make an entry into the patient_mapping table with batch, diagnosis_date, and baseline_date')
        ;

            insert into queries
            values ('CreateNonDicomPathSeen', 'insert into non_dicom_path_seen(
  non_dicom_file_type,
  non_dicom_path
) values (
  ?, ?
)', ARRAY['non_dicom_file_type', 'non_dicom_path'], 
                    '{}', ARRAY['NotInteractive', 'non_dicom_phi'], 'posda_phi_simple', 'Create a dciodvfy_scan_instance row')
        ;

            insert into queries
            values ('DuplicateSopsInSeriesDistinct', 'select
  distinct sop_instance_uid,
  count(distinct file_id) as num_files,
  min(import_time) as earliest,
  max(import_time) as latest
from 
  file_sop_common
  natural join file_import natural join import_event
where sop_instance_uid in (
select sop_instance_uid from (
select
  distinct sop_instance_uid, count(distinct file_id) 
from
  file_sop_common natural join file_series natural join ctp_file
where
  series_instance_uid = ? and visibility is null
group by sop_instance_uid
) as foo
where count > 1
)
group by sop_instance_uid
order by sop_instance_uid', ARRAY['series_instance_uid'], 
                    ARRAY['sop_instance_uid', 'num_files', 'earliest', 'latest'], ARRAY['by_series', 'dup_sops'], 'posda_files', 'List of Actual duplicate SOPs (i.e. different files, same SOP)
in a series
')
        ;

            insert into queries
            values ('FindInconsistentSeriesWithSubjectAndStudy', 'select distinct patient_id, study_instance_uid, series_instance_uid
from file_patient natural join file_study natural join file_series
where series_instance_uid in (
select series_instance_uid from (
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
)', ARRAY['collection'], 
                    ARRAY['patient_id', 'study_instance_uid', 'series_instance_uid'], ARRAY['consistency', 'find_series', 'for_bill_series_consistency'], 'posda_files', 'Find Inconsistent Series
')
        ;

            insert into queries
            values ('SubjectCountsDateRangeSummaryByCollectionSite', 'select 
  distinct patient_id,
  min(import_time) as from,
  max(import_time) as to,
  count(distinct file_id) as num_files,
  count(distinct sop_instance_uid) as num_sops
from 
  ctp_file natural join 
  file_sop_common natural join
  file_patient natural join 
  file_import natural join 
  import_event
where
  project_name = ? and site_name = ? and visibility is null
group by patient_id
order by patient_id', ARRAY['collection', 'site'], 
                    ARRAY['patient_id', 'from', 'to', 'num_files', 'num_sops'], ARRAY['counts', 'for_bill_counts'], 'posda_files', 'Counts query by Collection, Site
')
        ;

            insert into queries
            values ('CreateTableSequenceIndex', 'insert into sequence_index(
  scan_element_id, sequence_level, item_number
) values (?, ?, ?)
', ARRAY['scan_element_id', 'sequence_level', 'item_number'], 
                    '{}', ARRAY['UsedInPhiSeriesScan', 'NotInteractive'], 'posda_phi', 'Create Table Sequence Id')
        ;

            insert into queries
            values ('GetRoiIdFromFileIdRoiNum', 'select
  roi_id
from
  roi natural join structure_set natural join file_structure_set
where 
  file_id =? and roi_num = ?', ARRAY['file_id', 'roi_num'], 
                    ARRAY['roi_id'], ARRAY['NotInteractive', 'used_in_processing_structure_set_linkages'], 'posda_files', 'Get the file_storage root for newly created files')
        ;

            insert into queries
            values ('PixelTypesWithGeo', 'select
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
', '{}', 
                    ARRAY['photometric_interpretation', 'samples_per_pixel', 'bits_allocated', 'bits_stored', 'high_bit', 'pixel_representation', 'planar_configuration', 'iop'], ARRAY['find_pixel_types', 'image_geometry', 'posda_files'], 'posda_files', 'Get distinct pixel types with geometry
')
        ;

            insert into queries
            values ('UpdateCollectionBacklogPrio', 'update
  collection_count_per_round
set
  file_count = ?
where
  collection = ?

', ARRAY['priority', 'collection'], 
                    '{}', ARRAY['NotInteractive', 'Backlog'], 'posda_backlog', 'Update the priority of a collection in a backlog ')
        ;

            insert into queries
            values ('InboxEmailToUsername', 'select user_name
from user_inbox
where user_email_addr = ?

', ARRAY['user_email_addr'], 
                    ARRAY['user_name'], ARRAY['NotInteractive', 'used_in_background_processing'], 'posda_queries', 'Convert an email address to a username')
        ;

            insert into queries
            values ('GetPublicSopsForCompareCollectionLike', 'select
  i.patient_id,
  i.study_instance_uid,
  s.series_instance_uid,
  sop_instance_uid,
  sop_class_uid,
  s.modality,
  i.dicom_file_uri
from
  general_image i,
  trial_data_provenance tdp,
  general_series s
where  
  i.trial_dp_pk_id = tdp.trial_dp_pk_id 
  and tdp.project like ?
  and i.general_series_pk_id = s.general_series_pk_id', ARRAY['collection'], 
                    ARRAY['patient_id', 'study_instance_uid', 'series_instance_uid', 'sop_instance_uid', 'sop_class_uid', 'modality', 'dicom_file_uri'], ARRAY['public_posda_counts'], 'public', 'Generate a long list of all unhidden SOPs for a collection in public<br>
<em>This can generate a long list</em>')
        ;

            insert into queries
            values ('FinishActivityTaskStatus', 'update activity_task_status set
  status_text = ?,
  expected_remaining_time = null,
  end_time = now(),
  last_updated = now()
where
  activity_id = ? and
  subprocess_invocation_id = ?', ARRAY['status_text', 'activity_id', 'subprocess_invocation_id'], 
                    '{}', ARRAY['NotInteractive', 'Update'], 'posda_files', 'Update status_text and end_timee in activity_task_status
For use in scripts
Not really intended for interactive use
')
        ;

            insert into queries
            values ('AreVisibleFilesMarkedAsBadOrUnreviewedInSeriesNew', 'select 
  collection,
  site,
  patient_id,
  series_instance_uid,
  dicom_file_type,
  modality,
  review_status,
  processing_status,
  count(distinct file_id) as num_files
from (
  select 
    distinct project_name as collection,
    site_name as site,
    patient_id,
    series_instance_uid,
    dicom_file_type,
    modality,
    review_status,
    processing_status,
    visibility,
    file_id
  from 
    dicom_file natural join 
    file_series natural join 
    file_patient natural join
    ctp_file natural join 
  (
    select file_id, review_status, processing_status
    from
      image_equivalence_class_input_image natural join
      image_equivalence_class join
      ctp_file using(file_id)
    where
      series_instance_uid = ?
  ) as foo
) as foo
where
  visibility is null and 
  review_status != ''Good'' and
  review_status != ''PassThrough''
group by
  collection,
  site,
  patient_id,
  series_instance_uid,
  dicom_file_type,
  modality,
  review_status,
  processing_status
', ARRAY['series_instance_uid'], 
                    ARRAY['collection', 'site', 'patient_id', 'series_instance_uid', 'dicom_file_type', 'modality', 'review_status', 'processing_status', 'visibility', 'file_id'], ARRAY['find_series', 'equivalence_classes', 'consistency', 'visual_review_results', 'hide_events'], 'posda_files', 'Get visual review status report by series for Collection, Site')
        ;

            insert into queries
            values ('DistinctVisibleFileReportByPatient', 'select distinct
  project_name as collection, site_name as site, patient_id, study_instance_uid,
  series_instance_uid, sop_instance_uid, dicom_file_type, modality, file_id
from
  file_patient natural join file_study natural join file_series natural join file_sop_common
  natural join dicom_file natural join ctp_file
where
  patient_id = ? and visibility is null
order by series_instance_uid', ARRAY['patient_id'], 
                    ARRAY['collection', 'site', 'patient_id', 'study_instance_uid', 'series_instance_uid', 'sop_instance_uid', 'dicom_file_type', 'modality', 'file_id'], ARRAY['by_collection', 'find_series', 'compare_collection_site', 'search_series', 'edit_files', 'simple_phi', 'dciodvfy', 'ctp_details', 'select_for_phi', 'visual_review_selection', 'activity_timepoints'], 'posda_files', 'Get Series in A Collection, site with dicom_file_type, modality, and sop_count
')
        ;

            insert into queries
            values ('GetFilePath', 'select
  root_path || ''/'' || rel_path as path
from
  file_location natural join file_storage_root
where
  file_id = ?', ARRAY['file_id'], 
                    ARRAY['path'], ARRAY['AllCollections', 'universal', 'public_posda_consistency'], 'posda_files', 'Get path to file by id')
        ;

            insert into queries
            values ('SeriesWithDupSops', 'select
  distinct collection, site, subj_id, study_instance_uid, series_instance_uid, count(*)
from (
  select
    distinct project_name as collection,
    site_name as site, patient_id as subj_id,
    study_instance_uid, series_instance_uid,
    file_id
  from
    ctp_file natural join file_sop_common
    natural join file_patient natural join file_study natural join file_series
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
group by collection, site, subj_id, study_instance_uid, series_instance_uid
', '{}', 
                    ARRAY['collection', 'site', 'subj_id', 'count', 'study_instance_uid', 'series_instance_uid'], ARRAY['duplicates'], 'posda_files', 'Return a count of duplicate SOP Instance UIDs
')
        ;

            insert into queries
            values ('IncrementSimpleSeriesScanned', 'update phi_scan_instance set
  num_series_scanned = num_series_scanned + 1
where
  phi_scan_instance_id = ?', ARRAY['id'], 
                    '{}', ARRAY['used_in_simple_phi', 'NotInteractive'], 'posda_phi_simple', 'Increment series scanned')
        ;

            insert into queries
            values ('FindingImportEvent', 'select
  import_event_id, import_time, count(distinct file_id) as num_files
from import_event natural join file_import
where import_event_id in (
  select distinct import_event_id from import_event natural join file_import
  where file_id in (
    select file_id from file_patient where patient_id = ?
  )
) group by import_event_id, import_time order by import_time desc limit 100', ARRAY['patient_id'], 
                    ARRAY['import_event_id', 'import_time', 'num_files'], ARRAY['ACRIN-NSCLC-FDG-PET Curation'], 'posda_files', 'Get the list of files by sop, excluding base series')
        ;

            insert into queries
            values ('SummaryOfToFilesForPatient', 'select
  distinct project_name as collection,
  site_name as site,
  patient_id,
  study_date,
  study_instance_uid,
  series_instance_uid,
  dicom_file_type,
  modality,
  visibility,
  count(distinct sop_instance_uid) as num_sops,
  count(distinct file_id) as num_files
from
  ctp_file natural join
  file_patient natural join
  file_sop_common natural join
  file_study natural join
  file_series natural join
  dicom_file
where file_id in (
  select
    file_id 
  from
    file_patient natural left join ctp_file
  where
    patient_id  = ? and visibility is null
  )
group by collection, site, patient_id, study_date, study_instance_uid, 
  series_instance_uid, dicom_file_type, modality, visibility
order by collection, site, patient_id, study_date, study_instance_uid, modality', ARRAY['patient_id'], 
                    ARRAY['collection', 'site', 'patient_id', 'study_date', 'study_instance_uid', 'series_instance_uid', 'dicom_file_type', 'modality', 'visibility', 'num_sops', 'num_files'], ARRAY['adding_ctp', 'for_scripting', 'patient_queries'], 'posda_files', 'Get a list of to files from the dicom_edit_compare table for a particular edit instance, with file_id and visibility

NB: Normally there should be no file_id (i.e. file has not been imported)')
        ;

            insert into queries
            values ('GetSeriesByVisualReviewIdWithNullStatus', 'select 
  distinct series_instance_uid
from
  image_equivalence_class
where
  visual_review_instance_id = ? and review_status is null', ARRAY['visual_review_instance_id'], 
                    ARRAY['series_instance_uid'], ARRAY['signature', 'phi_review', 'visual_review', 'visual_review_new_workflow'], 'posda_files', 'Get a list of Series By Visual Review Id and Status
')
        ;

            insert into queries
            values ('ListOfCollectionsAndSites', 'select
    project_name,
	site_name,
	count(*) 
from 
	ctp_file 
where
  visibility is null

group by project_name, site_name
order by project_name, site_name', '{}', 
                    ARRAY['project_name', 'site_name', 'count'], ARRAY['AllCollections', 'universal'], 'posda_files', 'Get a list of collections and sites

optimized by Quasar on 2018-08-08')
        ;

            insert into queries
            values ('FilesByModalityByCollectionSiteIntake', 'select
  distinct i.patient_id, modality, s.series_instance_uid, sop_instance_uid, dicom_file_uri
from
  general_image i, trial_data_provenance tdp, general_series s
where
  s.general_series_pk_id = i.general_series_pk_id and 
  i.trial_dp_pk_id = tdp.trial_dp_pk_id and 
  modality = ? and
  tdp.project = ? and 
  tdp.dp_site_name = ?', ARRAY['modality', 'project_name', 'site_name'], 
                    ARRAY['patient_id', 'modality', 'series_instance_uid', 'sop_instance_uid', 'dicom_file_uri'], ARRAY['FindSubjects', 'intake', 'FindFiles'], 'intake', 'Find All Files with given modality in Collection, Site on Intake
')
        ;

            insert into queries
            values ('MultifileImportsExceptEdits', 'select
  distinct import_type, import_comment, import_time,
  count(distinct import_event_id) as num_imports, sum(num_files) as total_files
from (
  select * from (
    select
      distinct import_event_id, import_time, import_type, import_comment, count(distinct file_id) as num_files 
    from
      import_event natural join file_import
    where import_time > ? and import_time < ?
    group by import_event_id, import_time, import_type, import_comment order by import_time desc
  ) as foo
  where num_files > 1 and import_comment not like ''%dicom_edit_compare%''
) as foo
group by import_type, import_time, import_comment', ARRAY['from', 'to'], 
                    ARRAY['import_type', 'import_comment', 'num_imports', 'import_time', 'total_files'], ARRAY['downloads_by_date', 'import_events'], 'posda_files', 'Counts query by Collection, Site
')
        ;

            insert into queries
            values ('SetDciodvfyScanInstanceNumScanned', 'update dciodvfy_scan_instance set
  scanned_so_far = ?
where
  dciodvfy_scan_instance_id = ?', ARRAY['scanned_so_far', 'dciodvfy_scan_instance_id'], 
                    '{}', ARRAY['NotInteractive', 'used_in_dciodvfy'], 'posda_phi_simple', 'Create a dciodvfy_scan_instance row')
        ;

            insert into queries
            values ('PublicSeriesByCollectionVisibilityMetadata', 'select
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
  q.software_versions,
   count(distinct  i.sop_instance_uid) as Images
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
  s.visibility = ?
group by PID, StudyDate, Modality
', ARRAY['collection', 'visibility'], 
                    ARRAY['PID', 'Modality', 'StudyDate', 'StudyDescription', 'SeriesDescription', 'SeriesNumber', 'StudyInstanceUID', 'SeriesInstanceUID', 'Mfr', 'Model', 'software_versions', 'Images'], ARRAY['public'], 'public', 'List of all Series By Collection, Site on Public with metadata
')
        ;

            insert into queries
            values ('PatientIdMappingByFromPatientId', 'select
  from_patient_id, to_patient_id, to_patient_name, collection_name, site_name,
  batch_number, diagnosis_date, baseline_date, date_shift, uid_root
from 
  patient_mapping
where
  from_patient_id = ?', ARRAY['from_patient_id'], 
                    ARRAY['from_patient_id', 'to_patient_id', 'to_patient_name', 'collection_name', 'site_name', 'batch_number', 'diagnosis_date', 'baseline_date', 'date_shift', 'uid_root'], ARRAY['adding_ctp', 'for_scripting', 'non_dicom_phi', 'non_dicom_edit'], 'posda_files', 'Simple Phi Report with Meta Quotes')
        ;

            insert into queries
            values ('TagLocations', 'select
  query_tab_name,
  filter_name, 
  tag
from (
  select 
     query_tab_name,
      filter_name,
      unnest(tags_enabled) as tag
  from
    query_tabs join query_tabs_query_tag_filter using(query_tab_name)
    natural join query_tag_filter
) as foo
where tag = ?', ARRAY['tag'], 
                    ARRAY['query_tab_name', 'filter_name', 'tag'], ARRAY['meta', 'test', 'hello', 'query_tabs', 'bills_test'], 'posda_queries', 'Add a filter to a tab')
        ;

            insert into queries
            values ('FindingImageProblem', 'select
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
    from pixel_location left join image using(unique_pixel_data_id)
    where file_id in (
      select
         distinct file_id from file_import natural join import_event natural join dicom_file
      where import_time > ''2018-09-17''
    )
  ) as foo where image_id is null
) 
and visibility is null
group by dicom_file_type, project_name, patient_id
order by patient_id', '{}', 
                    ARRAY['dicom_file_type', 'project_name', 'patient_id', 'min', 'max', 'count'], ARRAY['Exceptional-Responders_NCI_Oct2018_curation'], 'posda_files', 'Find files which have unique_pixel_data_id but no image_id, then find out where the hell they came from')
        ;

            insert into queries
            values ('ListOfPrivateElementsFromDD', 'select
  pt_signature as tag,
  pt_consensus_vr as vr,
  pt_consensus_vm as vm,
  pt_consensus_name as name
from
  pt', '{}', 
                    ARRAY['tag', 'vr', 'vm', 'name'], ARRAY['ElementDisposition'], 'posda_private_tag', 'Get List of Private Tags from DD')
        ;

            insert into queries
            values ('GetFilePathWithCollSitePatientStudySeries', 'select
  root_path || ''/'' || rel_path as path,
  project_name as collection,
  site_name as site,
  patient_id,
  study_instance_uid,
  series_instance_uid
from
  file_location natural join file_storage_root natural join
  ctp_file natural join file_patient natural join file_study natural join file_series
where
  file_id = ?', ARRAY['file_id'], 
                    ARRAY['path', 'collection', 'site', 'patient_id', 'study_instance_uid', 'series_instance_uid'], ARRAY['AllCollections', 'universal', 'public_posda_consistency'], 'posda_files', 'Get path to file by id')
        ;

            insert into queries
            values ('GetHiddenFilesBySeriesAndVisualReviewId', 'select
  file_id
from ctp_file
where visibility is not null and file_id in (
  select
    file_id
  from
    image_equivalence_class natural join image_equivalence_class_input_image
  where
    visual_review_instance_id = ? and series_instance_uid = ?
)', ARRAY['visual_review_instance_id', 'series_instance_uid'], 
                    ARRAY['file_id'], ARRAY['signature', 'phi_review', 'visual_review_new_workflow'], 'posda_files', 'Get a list of files which are hidden by series id and visual review id')
        ;

            insert into queries
            values ('GetNotQualifiedCTQPByLikeCollectionSiteWithNoFiles', 'select 
  collection, site, patient_id, qualified
from
  clinical_trial_qualified_patient_id p
where collection like ? and site = ? and not qualified and
  not exists (select file_id from file_patient f where f.patient_id = p.patient_id)
group by collection, site, patient_id, qualified', ARRAY['collection_like', 'site'], 
                    ARRAY['collection', 'site', 'patient_id', 'qualified'], ARRAY['clin_qual'], 'posda_files', 'Create An Activity Timepoint

')
        ;

            insert into queries
            values ('UpdateUserBoundVariable', 'update user_variable_binding set
  bound_value = ?
where
  binding_user = ?
  and bound_variable_name = ?
 ', ARRAY['value', 'user', 'variable_name'], 
                    ARRAY['user', 'variable', 'binding'], ARRAY['AllCollections', 'queries', 'activity_support', 'variabler_binding'], 'posda_queries', 'Get list of variables with bindings for a user')
        ;

            insert into queries
            values ('ListSrPosdaHidden', 'select 
  distinct project_name as collection, site_name as site,
  patient_id, study_instance_uid, series_instance_uid,
  file_id, root_path || ''/'' || rel_path as file_path
from
  dicom_file natural join file_patient natural join file_series
  natural join file_study natural join ctp_file
  join file_location using (file_id) natural join file_storage_root
where
  visibility is not null and dicom_file_type like ''%SR%'' and
  project_name like ?', ARRAY['collection_like'], 
                    ARRAY['collection', 'site', 'patient_id', 'study_instance_uid', 'series_instance_uid', 'file_id', 'file_path'], ARRAY['meta', 'test', 'hello', 'query_tabs', 'bills_test', 'view_structured_reports'], 'posda_files', 'Add a filter to a tab')
        ;

            insert into queries
            values ('GetDciodvfyWarningNonStd', 'select
  dciodvfy_warning_id as id
from 
  dciodvfy_warning
where
  warning_type = ''NonStandardAttribute''
  and warning_tag = ?
  and warning_desc = ?
  and warning_iod = ?

 ', ARRAY['warning_tag', 'warning_desc', 'warning_iod'], 
                    ARRAY['id'], ARRAY['NotInteractive', 'used_in_dciodvfy'], 'posda_phi_simple', 'Get an dciodvfy_warnings row by warning_text (if present)')
        ;

            insert into queries
            values ('GetAllQualifiedCTQPByLikeCollectionWithFIleCountAndLoadTimes', 'select 
  collection, site, patient_id, qualified, count(distinct file_id) as num_files,
  min(date_trunc(''day'',import_time)) as earliest_day, max(date_trunc(''day'', import_time)) as latest_day
from
  clinical_trial_qualified_patient_id join file_patient using (patient_id) join file_import using(file_id)
  join import_event using(import_event_id)
where collection like ?
group by collection, site, patient_id, qualified', ARRAY['collection_like'], 
                    ARRAY['collection', 'site', 'patient_id', 'qualified', 'num_files', 'earliest_day', 'latest_day'], ARRAY['clin_qual'], 'posda_files', 'Create An Activity Timepoint

')
        ;

            insert into queries
            values ('PatientStudySopCountByCollectionSite', 'select 
  distinct patient_id, study_instance_uid, 
  count(distinct sop_instance_uid) as num_sops
from 
  ctp_file natural join 
  file_sop_common natural join
  file_patient natural join 
  file_study
where
  project_name = ? and site_name = ? and visibility is null
group by patient_id, study_instance_uid
order by patient_id', ARRAY['collection', 'site'], 
                    ARRAY['patient_id', 'study_instance_uid', 'num_sops'], ARRAY['counts', 'for_bill_counts'], 'posda_files', 'For every patient in collection site, get a list of studies with a count of distinct SOPs in each study')
        ;

            insert into queries
            values ('HowManyRowsInCopyFromPublic', 'select
  count(*) as num_copies_total
from file_copy_from_public c
where
  c.copy_from_public_id = ? ', ARRAY['copy_from_public_id'], 
                    ARRAY['num_copies_total'], ARRAY['bills_test', 'copy_from_public'], 'posda_files', 'Add a filter to a tab')
        ;

            insert into queries
            values ('ImageFrameOfReferenceBySeriesPosda', 'select 
  distinct for_uid, count(*) as num_files
from
  file_series natural join file_sop_common natural join file_for natural join ctp_file
where 
  series_instance_uid = ? and visibility is null
group by for_uid', ARRAY['series_instance_uid'], 
                    ARRAY['for_uid', 'num_files'], ARRAY['Structure Sets', 'sops', 'LinkageChecks', 'struct_linkages'], 'posda_files', 'Get list of plan which reference unknown SOPs

')
        ;

            insert into queries
            values ('PatientDetailsWithBlankCtp', 'select
  distinct project_name as collection,
  site_name as site,
  visibility,
  patient_id,
  patient_name,
  study_instance_uid,
  study_date,
  series_instance_uid,
  modality,
  count (distinct file_id) as num_files
from
  file_patient natural join
  file_study natural join
  file_series natural join
  ctp_file
where
  project_name = ''UNKNOWN'' and visibility is null
group by
  project_name, site_name, visibility, 
  patient_id, patient_name, study_instance_uid, study_date,
  series_instance_uid, modality
order by 
  project_name, site_name, patient_id, study_date,
  modality
', '{}', 
                    ARRAY['collection', 'site', 'visibility', 'patient_id', 'patient_name', 'study_instance_uid', 'study_date', 'series_instance_uid', 'modality', 'num_files'], ARRAY['adding_ctp', 'find_patients', 'no_ctp_patients'], 'posda_files', 'Get Series in A Collection
')
        ;

            insert into queries
            values ('DistinctPatientStudySeriesByCollectionSite', 'select distinct
  patient_id, 
  study_instance_uid,
  series_instance_uid, 
  dicom_file_type,
  modality, 
  count(distinct file_id) as num_files
from
  ctp_file
  natural join dicom_file
  natural join file_study
  natural join file_series
  natural join file_patient
where
  project_name = ? and
  site_name = ? and
  visibility is null
group by
  patient_id, 
  study_instance_uid,
  series_instance_uid,
  dicom_file_type,
  modality
  ', ARRAY['collection', 'site'], 
                    ARRAY['patient_id', 'study_instance_uid', 'series_instance_uid', 'dicom_file_type', 'modality', 'num_files'], ARRAY['by_collection', 'find_series', 'search_series', 'send_series'], 'posda_files', 'Get Series in A Collection
')
        ;

            insert into queries
            values ('FilesByCollectionSitePatientWithVisibility', 'select
  distinct
  file_id,
  project_name as collection,
  site_name as site,
  patient_id,
  series_instance_uid,
  sop_instance_uid,
  file_id,
  visibility
from
  ctp_file
  join file_patient using(file_id)
  join file_series using(file_id)
  join file_sop_common using(file_id)
where 
  project_name = ?
  and site_name = ?
  and patient_id = ?', ARRAY['collection', 'site', 'patient_id'], 
                    ARRAY['collection', 'site', 'patient_id', 'series_instance_uid', 'sop_instance_uid', 'file_id', 'visibility'], ARRAY['hide_events'], 'posda_files', 'Get List of files for Collection, Site with visibility')
        ;

            insert into queries
            values ('ShowAllHideEventsByCollectionSiteAlt', 'select
 distinct
  user_name,
  date_trunc(''hour'',time_of_change) as hour_of_change,
  prior_visibility,
  new_visibility,
  reason_for,
  count(distinct file_id) as num_files
from
   file_visibility_change 
where file_id in (
  select file_id 
  from ctp_file 
  where project_name = ? and site_name = ?
  and visibility = ''hidden'' 
)
group by user_name, hour_of_change, prior_visibility, new_visibility, reason_for', ARRAY['collection', 'site'], 
                    ARRAY['user_name', 'hour_of_change', 'prior_visibility', 'new_visibility', 'reason_for', 'num_files'], ARRAY['old_hidden'], 'posda_files', 'Show All Hide Events by Collection, Site')
        ;

            insert into queries
            values ('PrivateTagsWhichArentMarked', 'select 
  distinct 
  element_seen_id as id, 
  element_sig_pattern,
  vr,
  tag_name,
  private_disposition as disp
from
  element_seen
where
  is_private is null and 
  element_sig_pattern like ''%"%''
', '{}', 
                    ARRAY['id', 'element_sig_pattern', 'vr', 'tag_name', 'disp'], ARRAY['tag_usage', 'simple_phi', 'simple_phi_maint', 'phi_maint'], 'posda_phi_simple', 'Private tags with no disposition with values in phi_simple')
        ;

            insert into queries
            values ('GetCurrentAdverseFileEvent', 'select currval(''adverse_file_event_adverse_file_event_id_seq'') as id', '{}', 
                    ARRAY['id'], ARRAY['NotInteractive', 'used_in_import_edited_files'], 'posda_files', 'Get current dicom_edit_event_id
For use in scripts
Not really intended for interactive use
')
        ;

            insert into queries
            values ('RelinquishControlPosdaImport', 'update import_control
set status = ''idle'',
  processor_pid =  null,
  pending_change_request = null', '{}', 
                    '{}', ARRAY['NotInteractive', 'PosdaImport'], 'posda_files', 'relese control of posda_import')
        ;

            insert into queries
            values ('TagsSeenSimple', 'select
  element_sig_pattern, vr, is_private, private_disposition, tag_name
from
  element_seen order by element_sig_pattern', '{}', 
                    ARRAY['element_sig_pattern', 'vr', 'is_private', 'private_disposition', 'tag_name'], ARRAY['by_collection', 'find_series', 'compare_collection_site', 'search_series', 'edit_files', 'phi_maint'], 'posda_phi_simple', 'Get all the data from tags_seen in posda_phi_simple database
')
        ;

            insert into queries
            values ('GetDicomObjectTypeBySeries', 'select 
  distinct 
  dicom_file_type as dicom_object_type
from dicom_file natural join file_series natural join ctp_file 
where series_instance_uid = ? and visibility is null
', ARRAY['series_instance_uid'], 
                    ARRAY['dicom_object_type'], ARRAY['populate_posda_files', 'bills_test'], 'posda_files', 'Gets count of all files which are PET''s which haven''t been imported into file_pt_image yet.

')
        ;

            insert into queries
            values ('GetContourImageLinksByFileId', 'select
  distinct roi_id,
  linked_sop_instance_uid as sop_instance_uid,
  linked_sop_class_uid as sop_class_uid,
  contour_type,
  count(distinct contour_digest) as num_contours,
  sum(num_points) as num_points
from
 file_roi_image_linkage
where file_id = ?
group by roi_id, linked_sop_instance_uid, linked_sop_class_uid, contour_type', ARRAY['file_id'], 
                    ARRAY['roi_id', 'sop_instance_uid', 'sop_class_uid', 'contour_type', 'num_contours', 'num_points'], ARRAY['LinkageChecks', 'used_in_struct_linkage_check'], 'posda_files', 'Get list of Roi with info by file_id

')
        ;

            insert into queries
            values ('PixelTypes', 'select
  distinct photometric_interpretation,
  samples_per_pixel,
  bits_allocated,
  bits_stored,
  high_bit,
  coalesce(number_of_frames,1) > 1 as is_multi_frame,
  pixel_representation,
  planar_configuration,
  modality,
  dicom_file_type,
  count(distinct file_id)
from
  image natural join file_image natural join file_series
  natural join dicom_file
group by
  photometric_interpretation,
  samples_per_pixel,
  bits_allocated,
  bits_stored,
  high_bit,
  is_multi_frame,
  pixel_representation,
  planar_configuration,
  modality,
  dicom_file_type
order by
  count desc', '{}', 
                    ARRAY['photometric_interpretation', 'samples_per_pixel', 'bits_allocated', 'bits_stored', 'high_bit', 'is_multi_frame', 'pixel_representation', 'planar_configuration', 'modality', 'dicom_file_type', 'count'], ARRAY['all', 'find_pixel_types', 'posda_files'], 'posda_files', 'Get distinct pixel types
')
        ;

            insert into queries
            values ('GetDciodvfyErrorInvalidEleLen', 'select
  dciodvfy_error_id as id
from 
  dciodvfy_error
where
  error_type = ''InvalidElementLength''
  and error_tag = ?
  and error_value = ?
  and error_subtype = ?
  and error_reason = ?
  and error_index = ?
', ARRAY['error_tag', 'error_value', 'error_subtype', 'error_reason', 'error_index'], 
                    ARRAY['id'], ARRAY['NotInteractive', 'used_in_dciodvfy'], 'posda_phi_simple', 'Get an dciodvfy_errors row by error_tag where error_type = ''InvalidElementLength''')
        ;

            insert into queries
            values ('DistinctSeriesByPatientId', 'select distinct 
  project_name as collection, site_name as site, patient_id, study_instance_uid,
  series_instance_uid, dicom_file_type, modality, count(distinct file_id)
from
  file_study natural join file_series natural join
  file_patient natural join
  dicom_file natural join ctp_file
where
  patient_id = ? and visibility is null
group by 
  collection, site, patient_id, study_instance_uid,
  series_instance_uid, dicom_file_type, modality
', ARRAY['patient_id'], 
                    ARRAY['collection', 'site', 'patient_id', 'study_instance_uid', 'series_instance_uid', 'modality', 'dicom_file_type', 'count'], ARRAY['dciodvfy', 'select_for_phi', 'visual_review_selection', 'activity_timepoint_support'], 'posda_files', 'Get Series in A Collection, site with dicom_file_type, modality, and sop_count
')
        ;

            insert into queries
            values ('FilesInSeriesWithVisibility', 'select
  distinct root_path || ''/'' || rel_path as file
from
  file_location natural join file_storage_root
  natural join ctp_file
  natural join file_series
where
  series_instance_uid = ? and visibility is null
', ARRAY['series_instance_uid'], 
                    ARRAY['file'], ARRAY['by_series', 'find_files', 'used_in_simple_phi'], 'posda_files', 'Get files in a series from posda database
')
        ;

            insert into queries
            values ('GetSeriesBasedOnErrorId', 'select 
  distinct unit_uid as series_instance_uid
from 
  dciodvfy_unit_scan natural join dciodvfy_unit_scan_error
where
  dciodvfy_error_id = ?
order by dciodvfy_error_id', ARRAY['dciodvfy_error_id'], 
                    ARRAY['series_instance_uid'], ARRAY['tag_usage', 'dciodvfy'], 'posda_phi_simple', 'find series for a particular dciodvfy_error')
        ;

            insert into queries
            values ('GetFilePathPublic', 'select
 dicom_file_uri as path
from
  general_image
where
  sop_instance_uid = ?', ARRAY['sop_instance_uid'], 
                    ARRAY['path'], ARRAY['AllCollections', 'universal', 'public_posda_consistency'], 'public', 'Get path to file by id')
        ;

            insert into queries
            values ('DistinctUnhiddenFilesInSeries', 'select
  distinct file_id
from
  file_series natural join file_sop_common natural join ctp_file
where
  series_instance_uid = ? and visibility is null
', ARRAY['series_instance_uid'], 
                    ARRAY['file_id'], ARRAY['by_series_instance_uid', 'file_ids', 'posda_files'], 'posda_files', 'Get Distinct Unhidden Files in Series
')
        ;

            insert into queries
            values ('FindInconsistentStudy', 'select distinct study_instance_uid from (
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
', ARRAY['collection'], 
                    ARRAY['study_instance_uid'], ARRAY['by_study', 'consistency', 'for_bill_study_consistency'], 'posda_files', 'Find Inconsistent Studies
')
        ;

            insert into queries
            values ('BackgroundersByDateRangeWithInvoker', 'select
  distinct operation_name, invoking_user, count(distinct subprocess_invocation_id) as num_invocations
from
  background_subprocess natural join subprocess_invocation
where
  when_script_ended is not null and operation_name is not null and
  when_script_started > ? and when_script_ended < ? and
  when_script_ended is not null
group by operation_name, invoking_user
order by num_invocations desc', ARRAY['from', 'to'], 
                    ARRAY['operation_name', 'invoking_user', 'num_invocations'], ARRAY['invoking_user'], 'posda_files', 'Get a list of collections and sites
')
        ;

            insert into queries
            values ('GetSsByFileId', 'select
  distinct project_name as collection,
  site_name as site,
  patient_id, file_id
from
  ctp_file natural join file_patient natural join file_structure_set
where file_id = ? and visibility is null', ARRAY['file_id'], 
                    ARRAY['collection', 'site', 'patient_id', 'file_id'], ARRAY['Structure Sets', 'sops', 'LinkageChecks', 'struct_linkages'], 'posda_files', 'Get list of plan which reference unknown SOPs

')
        ;

            insert into queries
            values ('ShowImportsBySopInstance', 'select 
  file_id, import_time, import_comment 
from 
  import_event natural join file_import 
where file_id in (
  select file_id from file_sop_common where sop_instance_uid = ?
)
order by import_time', ARRAY['sop_instance_uid'], 
                    ARRAY['file_id', 'import_time', 'import_type', 'import_comment'], ARRAY['old_hidden'], 'posda_files', 'Show All Hide Events by Collection, Site')
        ;

            insert into queries
            values ('VisibilityChangeEventsByCollectionByHourNoSeriesOrPatient', 'select 
  distinct project_name as collection,
  site_name as site,
  date_trunc(''hour'', time_of_change) as when_done,
  user_name, prior_visibility, new_visibility, reason_for, 
  count (distinct patient_id) as num_patients,
  count (distinct series_instance_uid) as num_series,
  count(distinct file_id) as num_files,
  count (distinct series_instance_uid) as num_series
from
   ctp_file natural join file_patient natural join file_series natural join file_visibility_change 
where project_name = ?
group by
 collection, site, when_done, user_name, prior_visibility, new_visibility, reason_for
order by when_done desc', ARRAY['collection'], 
                    ARRAY['collection', 'site', 'when_done', 'user_name', 'prior_visibility', 'new_visibility', 'reason_for', 'num_patients', 'num_series', 'num_files'], ARRAY['meta', 'test', 'hello', 'bills_test', 'hide_events', 'show_hidden'], 'posda_files', 'Add a filter to a tab')
        ;

            insert into queries
            values ('DistinctSeriesByCollectionPublicTest', 'select
  distinct s.series_instance_uid, modality, count(*) as num_images
from
  general_image i, general_series s,
  trial_data_provenance tdp
where
  s.general_series_pk_id = i.general_series_pk_id and
  i.trial_dp_pk_id = tdp.trial_dp_pk_id and
  tdp.project = ?
group by series_instance_uid, modality', ARRAY['project_name'], 
                    ARRAY['series_instance_uid', 'modality', 'num_images'], ARRAY['by_collection', 'find_series', 'intake', 'compare_collection_site', 'simple_phi'], 'public', 'Get Series in A Collection, Site
')
        ;

            insert into queries
            values ('FindDuplicatedPixelDigests', 'select
  distinct pixel_digest, num_files
from (
  select
    distinct digest as pixel_digest, count(distinct file_id) as num_files
  from
    file_image
    join image using(image_id)
    join unique_pixel_data using (unique_pixel_data_id)
  group by digest
) as foo
where num_files > 3
order by num_files desc

', '{}', 
                    ARRAY['pixel_digest', 'num_files'], ARRAY['meta', 'test', 'hello'], 'posda_files', 'Find Duplicated Pixel Digest')
        ;

            insert into queries
            values ('BackgroundProcessStatsWithInvokerNullComand', 'select
  distinct operation_name, command_executed, invoking_user as invoker, 
  max(when_script_ended - when_script_started) as longest,
  min(when_script_ended - when_script_started) as shortest,
  avg(when_script_ended - when_script_started) as avg, count(*) as times_invoked,
  min(when_script_started) as first, max(when_script_started) as last
from
  background_subprocess natural join subprocess_invocation
where
  when_script_ended is not null and operation_name is null
group by operation_name, command_executed, invoker', '{}', 
                    ARRAY['operation_name', 'command_executed', 'invoker', 'longest', 'shortest', 'avg', 'times_invoked', 'first', 'last'], ARRAY['invoking_user'], 'posda_files', 'Get a list of collections and sites
')
        ;

            insert into queries
            values ('FilesInStudy', 'select
  distinct root_path || ''/'' || rel_path as path, 
  sop_instance_uid, modality
from
  file_location natural join file_storage_root 
  natural join ctp_file natural join file_series
  natural join file_sop_common
where
  series_instance_uid = ? and visibility is null
', ARRAY['series_instance_uid'], 
                    ARRAY['path', 'sop_instance_uid', 'modality'], ARRAY['find_files', 'ApplyDisposition'], 'posda_files', 'Get path, sop_instance_uid, and modality for all files in a series
')
        ;

            insert into queries
            values ('FilesByPatientForApplicationOfPrivateDisposition', 'select
  distinct root_path || ''/'' || rel_path as path, 
  sop_instance_uid, modality
from
  file_location natural join file_storage_root 
  natural join ctp_file natural join file_series
  natural join file_patient
  natural join file_sop_common
where
 patient_id = ? and visibility is null
', ARRAY['patient_id'], 
                    ARRAY['path', 'sop_instance_uid', 'modality'], ARRAY['find_files', 'ApplyDisposition', 'edit_files'], 'posda_files', 'Get path, sop_instance_uid, and modality for all files in a series
')
        ;

            insert into queries
            values ('GetSubProcessInvocationId', 'select currval(''subprocess_invocation_subprocess_invocation_id_seq'') as id', '{}', 
                    ARRAY['id'], ARRAY['NotInteractive', 'used_in_background_processing'], 'posda_queries', 'Get the id of the subprocess_invocation row just created')
        ;

            insert into queries
            values ('UpdPosdaPhiSimplePrivDisp', 'update
  element_seen
set
  private_disposition = ?
where
  element_sig_pattern = ? and
  vr = ?

', ARRAY['private_disposition', 'element_signature', 'vr'], 
                    '{}', ARRAY['NotInteractive', 'used_in_reconcile_tag_names'], 'posda_phi_simple', 'Update name_chain in element_seen')
        ;

            insert into queries
            values ('GetImageGeoBySop', 'select 
  distinct sop_instance_uid, iop as image_orientation_patient,
  ipp as image_position_patient,
  pixel_spacing,
  pixel_rows as i_rows,
  pixel_columns as i_columns
from
  file_sop_common join
  ctp_file using(file_id) join
  file_patient using (file_id) join
  file_image using (file_id) join 
  file_series using (file_id) join
  file_study using (file_id) join
  image using (image_id) join
  file_image_geometry using (file_id) join
  image_geometry using (image_geometry_id) 
where 
  sop_instance_uid = ? and visibility is null
', ARRAY['sop_instance_uid'], 
                    ARRAY['sop_instance_uid', 'image_orientation_patient', 'image_position_patient', 'pixel_spacing', 'i_rows', 'i_columns'], ARRAY['LinkageChecks', 'BySopInstance'], 'posda_files', 'Get Geometric Information by Sop Instance UID from posda')
        ;

            insert into queries
            values ('GetPatientStatus', 'select
  patient_import_status as status
from
  patient_import_status
where
  patient_id = ?
', ARRAY['patient_id'], 
                    ARRAY['status'], ARRAY['NotInteractive', 'PatientStatus', 'Update'], 'posda_files', 'Get Patient Status')
        ;

            insert into queries
            values ('GetVisualReviewStatusBothCountsById', 'select 
  distinct review_status, processing_status, count(distinct series_instance_uid) as num_series
from
  image_equivalence_class
where
  visual_review_instance_id = ?
group by review_status, processing_status', ARRAY['visual_review_instance_id'], 
                    ARRAY['review_status', 'processing_status', 'num_series'], ARRAY['signature', 'phi_review', 'visual_review', 'visual_review_new_workflow'], 'posda_files', 'Get a list of Series By Visual Review Id and Status
')
        ;

            insert into queries
            values ('ValueSeenByElementSeen', 'select value from value_seen where value_seen_id in (
  select  value_seen_id
  from element_value_occurance
where
    element_seen_id in (
      select element_seen_id
      from
        element_seen
      where
        element_sig_pattern = ?
    )
)', ARRAY['element_sig_pattern'], 
                    ARRAY['value'], ARRAY['tag_usage', 'simple_phi_maint', 'phi_maint'], 'posda_phi_simple', 'Private tags with no disposition with values in phi_simple')
        ;

            insert into queries
            values ('ValuesByVr', 'select distinct value, count(*) from (
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
', ARRAY['scan_id', 'vr'], 
                    ARRAY['value', 'count'], ARRAY['tag_usage'], 'posda_phi', 'List of values seen in scan by VR (with count of elements)
')
        ;

            insert into queries
            values ('GetSiteCodes', 'select
  site_name, site_code
from
  site_codes
  ', '{}', 
                    ARRAY['site_name', 'site_code'], ARRAY['adding_ctp', 'for_scripting'], 'posda_files', 'Retrieve entries from patient_mapping table')
        ;

            insert into queries
            values ('ListOpenActivitiesWithItemCount', 'select
  distinct activity_id,
  brief_description,
  when_created,
  who_created,
  count(distinct user_inbox_content_id) as num_items
from
  activity natural left join activity_inbox_content
where when_closed is null
group by activity_id, brief_description, when_created, who_created
order by activity_id desc', '{}', 
                    ARRAY['activity_id', 'brief_description', 'when_created', 'who_created', 'num_items'], ARRAY['AllCollections', 'queries', 'activity_support'], 'posda_queries', 'Get a list of available queries')
        ;

            insert into queries
            values ('PatientDetailsWithNoCtp', 'select
  distinct 
  patient_id,
  patient_name,
  study_instance_uid,
  study_date,
  series_instance_uid,
  modality,
  count (distinct file_id) as num_files
from
  file_patient natural left join
  file_study natural left join
  file_series f
where
  patient_id = ?
  and not exists (select file_id from ctp_file c where c.file_id = f.file_id)
group by
  patient_id, patient_name, study_instance_uid, study_date,
  series_instance_uid, modality
order by 
  patient_id, study_date,
  modality
', ARRAY['patient_id'], 
                    ARRAY['patient_id', 'patient_name', 'study_instance_uid', 'study_date', 'series_instance_uid', 'modality', 'num_files'], ARRAY['adding_ctp', 'find_patients', 'no_ctp_details'], 'posda_files', 'Get Series in A Collection
')
        ;

            insert into queries
            values ('InsertPublicDisposition', 'insert into public_disposition(
  element_signature_id, sop_class_uid, name, disposition
) values (
  ?, ?, ?, ?
)

', ARRAY['element_signature_id', 'sop_class_uid', 'name', 'disposition'], 
                    '{}', ARRAY['NotInteractive', 'Update', 'ElementDisposition'], 'posda_phi', 'Insert a public disposition')
        ;

            insert into queries
            values ('GetPhiNonDicomScanInstanceById', 'select
  phi_non_dicom_scan_instance_id,
  pndsi_description as description,
  pndsi_start_time as start_time,
  pndsi_num_files as num_files,
  pndsi_num_files_scanned as num_files_scanned,
  pndsi_end_time as end_time
from
  phi_non_dicom_scan_instance
where
  phi_non_dicom_scan_instance_id = ?', ARRAY['phi_non_dicom_scan_instance_id'], 
                    ARRAY['phi_non_dicom_scan_instance_id', 'description', 'start_time', 'num_files', 'num_files_scanned', 'end_time'], ARRAY['NotInteractive', 'non_dicom_phi'], 'posda_phi_simple', 'Create a dciodvfy_scan_instance row')
        ;

            insert into queries
            values ('RecordElementDispositionChangeSimple', 'insert into element_disposition_changed(
  element_seen_id,
  when_changed,
  who_changed,
  why_changed,
  new_disposition
) values (
  ?, now(), ?, ?, ?)', ARRAY['id', 'who', 'why', 'disp'], 
                    '{}', ARRAY['tag_usage', 'simple_phi', 'used_in_phi_maint'], 'posda_phi_simple', 'Private tags with no disposition with values in phi_simple')
        ;

            insert into queries
            values ('StudyConsistency', 'select distinct
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
', ARRAY['study_instance_uid'], 
                    ARRAY['study_instance_uid', 'count', 'study_description', 'study_date', 'study_time', 'referring_phy_name', 'study_id', 'accession_number', 'phys_of_record', 'phys_reading', 'admitting_diag'], ARRAY['by_study', 'consistency', 'study_consistency'], 'posda_files', 'Check a Study for Consistency
')
        ;

            insert into queries
            values ('UpdateCopyInformation', 'update copy_from_public set 
  status_of_copy = ?,
  pid_of_running_process = ?
where copy_from_public_id = ?', ARRAY['status_of_copy', 'pid_of_running_process', 'copy_from_public_id'], 
                    '{}', ARRAY['bills_test', 'copy_from_public'], 'posda_files', 'Add a filter to a tab')
        ;

            insert into queries
            values ('PatientStatusCounts', 'select
  distinct project_name as collection, patient_import_status as status,
  count(distinct patient_id) as num_patients
from
  patient_import_status natural join file_patient natural join ctp_file
where
  visibility is null
group by collection, status
order by collection, status
', '{}', 
                    ARRAY['collection', 'status', 'num_patients'], ARRAY['FindSubjects', 'PatientStatus'], 'posda_files', 'Find All Subjects which have at least one visible file
')
        ;

            insert into queries
            values ('DuplicatePixelDataByProject', 'select image_id, file_id
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
', ARRAY['collection'], 
                    ARRAY['image_id', 'file_id'], ARRAY['pixel_duplicates'], 'posda_files', 'Return a list of files with duplicate pixel data
')
        ;

            insert into queries
            values ('DistinctSeriesByCollectionLikePatient', 'select distinct patient_id, series_instance_uid, modality, count(*)
from (
select distinct patient_id, series_instance_uid, sop_instance_uid, modality from (
select
   distinct patient_id, series_instance_uid, modality, sop_instance_uid,
   file_id
 from file_series natural join file_sop_common natural join file_patient
   natural join ctp_file
where
  project_name = ? and patient_id like ?
  and visibility is null)
as foo
group by patient_id, series_instance_uid, sop_instance_uid, modality)
as foo
group by patient_id, series_instance_uid, modality
', ARRAY['project_name', 'patient_id_like'], 
                    ARRAY['patient_id', 'series_instance_uid', 'modality', 'count'], ARRAY['by_collection', 'find_series'], 'posda_files', 'Get Series in A Collection
')
        ;

            insert into queries
            values ('RoiWithForAndFileIdByCollectionSite', 'select
  distinct for_uid, roi_num, roi_name, file_id
from
  roi natural join file_structure_set natural join ctp_file
where 
  project_name = ? and site_name = ? and visibility is null
order by file_id, for_uid', ARRAY['collection', 'site'], 
                    ARRAY['for_uid', 'roi_num', 'roi_name', 'file_id'], ARRAY['Structure Sets', 'sops', 'LinkageChecks', 'struct_linkages'], 'posda_files', 'Get list of plan which reference unknown SOPs

')
        ;

            insert into queries
            values ('SeriesVisualReviewResultsByCollectionSite', 'select 
  distinct series_instance_uid,
  dicom_file_type,
  modality,
  review_status,
  processing_status,
  count(distinct file_id) as num_files
from 
  dicom_file natural join 
  file_series natural join 
  ctp_file join 
  image_equivalence_class using(series_instance_uid)
where
  project_name = ? and
  site_name = ?
group by
  series_instance_uid,
  dicom_file_type,
  modality,
  review_status,
  processing_status
order by
  series_instance_uid', ARRAY['project_name', 'site_name'], 
                    ARRAY['series_instance_uid', 'dicom_file_type', 'modality', 'review_status', 'processing_status', 'num_files'], ARRAY['find_series', 'equivalence_classes', 'consistency', 'visual_review_results', 'hide_files'], 'posda_files', 'Get visual review status report by series for Collection, Site')
        ;

            insert into queries
            values ('GetFilesWithNoStudyInfoByCollection', 'select
  file_id,
  root_path || ''/'' || rel_path as path
from
  file_storage_root natural join file_location
where file_id in (
select 
  distinct file_id
from 
 ctp_file c
where
  project_name = ? and 
  visibility is null and 
  not exists (
    select
      file_id 
    from
      file_study s 
    where
      s.file_id = c.file_id
  )
)', ARRAY['collection'], 
                    ARRAY['file_id', 'path'], ARRAY['reimport_queries', 'dicom_file_type'], 'posda_files', 'Get file path from id')
        ;

            insert into queries
            values ('GetDupContourCountsExtended', 'select
  project_name as collection,
  site_name as site,
  patient_id,
  file_id,
  num_dup_contours
from (
  select 
    distinct file_id, count(*) as num_dup_contours
  from
    file_roi_image_linkage 
  where 
    contour_digest in (
    select contour_digest
    from (
      select 
        distinct contour_digest, count(*)
      from
        file_roi_image_linkage group by contour_digest
    ) as foo
    where count > 1
  ) group by file_id 
) foo join ctp_file using (file_id) join file_patient using(file_id)
order by num_dup_contours desc', '{}', 
                    ARRAY['collection', 'site', 'patient_id', 'file_id', 'num_dup_contours'], ARRAY['Structure Sets', 'sops', 'LinkageChecks', 'dup_contours'], 'posda_files', 'Get list of plan which reference unknown SOPs

')
        ;

            insert into queries
            values ('FindInconsistentSeriesIgnoringTimeCollectionLike', 'select series_instance_uid from (
select distinct series_instance_uid, count(*) from (
  select distinct
    series_instance_uid, modality, series_number, laterality, series_date,
    performing_phys, protocol_name, series_description,
    operators_name, body_part_examined, patient_position,
    smallest_pixel_value, largest_pixel_value, performed_procedure_step_id,
    performed_procedure_step_start_date, performed_procedure_step_start_time,
    performed_procedure_step_desc, performed_procedure_step_comments,
    count(*)
  from
    file_series natural join ctp_file
  where
    project_name like ? and visibility is null
  group by
    series_instance_uid, modality, series_number, laterality, series_date,
    performing_phys, protocol_name, series_description,
    operators_name, body_part_examined, patient_position,
    smallest_pixel_value, largest_pixel_value, performed_procedure_step_id,
    performed_procedure_step_start_date, performed_procedure_step_start_time,
    performed_procedure_step_desc, performed_procedure_step_comments
) as foo
group by series_instance_uid
) as foo
where count > 1
', ARRAY['collection_like'], 
                    ARRAY['series_instance_uid'], ARRAY['consistency', 'find_series', 'series_consistency'], 'posda_files', 'Find Inconsistent Series by Collection Site
')
        ;

            insert into queries
            values ('SummaryOfToFiles', 'select
  distinct project_name as collection,
  site_name as site,
  patient_id,
  study_date,
  study_instance_uid,
  series_instance_uid,
  dicom_file_type,
  modality,
  visibility,
  count(distinct sop_instance_uid) as num_sops,
  count(distinct file_id) as num_files
from
  ctp_file natural join
  file_patient natural join
  file_sop_common natural join
  file_study natural join
  file_series natural join
  dicom_file
where file_id in (
  select
    file_id 
  from
    file f, dicom_edit_compare dec 
  where
    f.digest = dec.to_file_digest and dec.subprocess_invocation_id = ?
  )
group by collection, site, patient_id, study_date, study_instance_uid, 
  series_instance_uid, dicom_file_type, modality, visibility
order by collection, site, patient_id, study_date, study_instance_uid, modality', ARRAY['subprocess_invocation_id'], 
                    ARRAY['collection', 'site', 'patient_id', 'study_date', 'study_instance_uid', 'series_instance_uid', 'dicom_file_type', 'modality', 'visibility', 'num_sops', 'num_files'], ARRAY['adding_ctp', 'for_scripting', 'patient_queries'], 'posda_files', 'Get a list of to files from the dicom_edit_compare table for a particular edit instance, with file_id and visibility

NB: Normally there should be no file_id (i.e. file has not been imported)')
        ;

            insert into queries
            values ('PosdaTotalsHidden', 'select 
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
', '{}', 
                    ARRAY['project_name', 'site_name', 'num_subjects', 'num_studies', 'num_series', 'total_files', 'total_sops'], '{}', 'posda_files', 'Get totals of files hidden in Posda
')
        ;

            insert into queries
            values ('VisualReviewStatusByCollection', 'select 
  distinct series_instance_uid, visibility, review_status, modality, series_description,
  series_date, count(distinct image_equivalence_class_id) as num_equiv_classes, 
  count(distinct file_id) as num_files
from
  image_equivalence_class natural join
  image_equivalence_class_input_image natural join
  file_series natural join ctp_file
where
  project_name = ? and visibility is null and review_status = ?
group by series_instance_uid, visibility, review_status, modality, series_description, series_date;', ARRAY['collection', 'review_status'], 
                    ARRAY['series_instance_uid', 'review_status', 'visibility', 'modality', 'series_description', 'series_date', 'num_equiv_classes', 'num_files'], ARRAY['by_collection', 'find_series', 'compare_collection_site', 'search_series', 'edit_files', 'simple_phi', 'dciodvfy', 'ctp_details', 'select_for_phi', 'visual_review_new_workflow'], 'posda_files', 'Get Series in A Collection, site with dicom_file_type, modality, and sop_count
')
        ;

            insert into queries
            values ('SopInstanceFilePathCountAndLoadTimesBySeries', 'select
  distinct sop_instance_uid, file_id,
  root_path || ''/'' || file_location.rel_path as path,
  min(import_time) as first_loaded,
  count(distinct import_time) as times_loaded,
  max(import_time) as last_loaded
from
  file_location
  natural join file_storage_root
  join file_import using(file_id)
  join import_event using (import_event_id)
  natural join file_sop_common
  natural join file_series
where series_instance_uid = ?
group by sop_instance_uid, file_id, path
order by sop_instance_uid, first_loaded', ARRAY['series_instance_uid'], 
                    ARRAY['sop_instance_uid', 'file_id', 'path', 'first_loaded', 'times_loaded', 'last_loaded'], ARRAY['SeriesSendEvent', 'by_series', 'find_files', 'for_send', 'for_comparing_dups', 'dup_sops'], 'posda_files', 'Get file path from id')
        ;

            insert into queries
            values ('GetPosdaQueueSize', 'select
 count(*) as num_files
from
  file 
where
  is_dicom_file is null and
  ready_to_process and
  processing_priority is not null

', '{}', 
                    ARRAY['num_files'], ARRAY['NotInteractive', 'Backlog', 'Backlog Monitor', 'backlog_status'], 'posda_files', 'Get size of queue  in Posda
Removed by Quasar on 2018-11-25. Results are not identical but it is more than 500 times faster
NATURAL JOIN file_location NATURAL JOIN file_storage_root')
        ;

            insert into queries
            values ('PosdaPublicDifferenceReportByEditId', 'select
  distinct short_report_file_id, long_report_file_id, count(distinct sop_instance_uid) as num_files
from public_to_posda_file_comparison
where compare_public_to_posda_instance_id =?
group by short_report_file_id, long_report_file_id order by short_report_file_id', ARRAY['compare_public_to_posda_instance_id'], 
                    ARRAY['short_report_file_id', 'long_report_file_id', 'num_files'], ARRAY['used_in_file_import_into_posda', 'used_in_file_migration'], 'posda_files', 'Get count of files relative to storage root')
        ;

            insert into queries
            values ('LookUpTag', 'select
  tag, name, keyword, vr, vm, is_retired, comments
from 
  dicom_element
where
  name = ? or
  keyword = ?', ARRAY['name', 'keyword'], 
                    ARRAY['tag', 'name', 'keyword', 'vr', 'vm', 'is_retired', 'comments'], ARRAY['NotInteractive', 'used_in_dciodvfy'], 'dicom_dd', 'Get tag from name or keyword')
        ;

            insert into queries
            values ('SeriesListByStudyInstanceUid', 'select
  distinct project_name as collection,
  site_name as site,
  patient_id,
  study_instance_uid,
  study_date,
  study_description,
  series_instance_uid,
  series_date,
  series_description,
  modality, 
  dicom_file_type, 
  count(distinct file_id) as num_files
from 
  file_patient natural join
  file_series natural join
  file_study natural join
  dicom_file natural join
  ctp_file
where 
  study_instance_uid = ?
  and visibility is null
group by 
  collection,
  site,
  patient_id,
  study_instance_uid,
  study_date,
  study_description,
  series_instance_uid,
  series_date,
  series_description,
  modality,
  dicom_file_type;', ARRAY['study_instance_uid'], 
                    ARRAY['collection', 'site', 'patient_id', 'study_instance_uid', 'study_date', 'study_description', 'series_instance_uid', 'series_date', 'series_description', 'modality', 'dicom_file_type', 'num_files'], ARRAY['find_series', 'for_tracy'], 'posda_files', 'Get List of Series by Study Instance UID')
        ;

            insert into queries
            values ('NumEquipSigsForTagSigs', 'select distinct element_signature, count(*) from (
select
  distinct element_signature, equipment_signature
from 
  equipment_signature natural join series_scan
  natural join scan_element natural join element_signature
  natural join scan_event
where scan_event_id = ?) as foo
group by element_signature
order by element_signature
', ARRAY['scan_id'], 
                    ARRAY['element_signature', 'count'], ARRAY['tag_usage'], 'posda_phi', 'Number of Equipment signatures in which tags are featured
')
        ;

            insert into queries
            values ('FilesWithIndicesByElementScanId', 'select
  distinct series_instance_uid,
  series_scanned_file as file, 
  element_signature, sequence_level,
  item_number
from
  series_scan natural join element_signature natural join 
  scan_element natural left join sequence_index
where
  scan_element_id = ?
', ARRAY['scan_element_id'], 
                    ARRAY['series_instance_uid', 'file', 'element_signature', 'sequence_level', 'item_number'], ARRAY['tag_usage'], 'posda_phi', 'Find out where specific value, tag combinations occur in a scan
')
        ;

            insert into queries
            values ('ShowFilesHiddenByUserDateRange', 'select 
  distinct project_name as collection,
  site_name as site,
  patient_id,
  study_instance_uid,
  series_instance_uid,
  reason_for as reason,
  prior_visibility as before,
  new_visibility as after,
  min(time_of_change) as earliest,
  max(time_of_change) as latest,
  count(distinct file_id) as num_files
from 
  file_visibility_change natural join
  file_patient natural join
  file_study natural join
  file_series natural join 
  ctp_file
where
  user_name = ? and
  time_of_change > ? and time_of_change < ?
group by
   collection, site, 
   patient_id, study_instance_uid,
   series_instance_uid, reason, before, after
order by
  patient_id, study_instance_uid, series_instance_uid', ARRAY['user', 'from', 'to'], 
                    ARRAY['collection', 'site', 'patient_id', 'study_instance_uid', 'series_instance_uid', 'reason', 'before', 'after', 'num_files', 'earliest', 'latest'], ARRAY['find_series', 'equivalence_classes', 'consistency', 'visual_review_results', 'old_hidden'], 'posda_files', 'Show Files Hidden By User Date Range')
        ;

            insert into queries
            values ('GlobalUnhiddenSOPDuplicatesSummary', 'select 
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
', '{}', 
                    ARRAY['collection', 'site', 'patient_id', 'study_instance_uid', 'series_instance_uid', 'sop_instance_uid', 'num_dup_sops', 'num_uploads', 'first_upload', 'last_upload'], ARRAY['receive_reports'], 'posda_files', 'Return a report of visible duplicate SOP Instance UIDs
')
        ;

            insert into queries
            values ('RoiInfoByFileId', 'select
  distinct roi_id, for_uid,
  max_x, max_y, max_z,
  min_x, min_y, min_z,
  roi_name, roi_description , roi_interpreted_type
from
  roi natural join file_structure_set
where file_id = ?', ARRAY['file_id'], 
                    ARRAY['roi_id', 'for_uid', 'max_x', 'max_y', 'max_z', 'min_x', 'min_y', 'min_z', 'roi_name', 'roi_description', 'roi_interpreted_type'], ARRAY['LinkageChecks', 'used_in_struct_linkage_check'], 'posda_files', 'Get list of Roi with info by file_id

')
        ;

            insert into queries
            values ('FirstFileInSeriesPublic', 'select
  dicom_file_uri as path
from
  general_image
where
  series_instance_uid =  ?
limit 1
', ARRAY['series_instance_uid'], 
                    ARRAY['path'], ARRAY['by_series', 'UsedInPhiSeriesScan', 'public'], 'public', 'First files in series in Public
')
        ;

            insert into queries
            values ('GetRoiCounts', 'select 
   distinct sop_instance_uid, count(distinct roi_id)
from 
  roi natural join structure_set natural join file_structure_set 
  join file_sop_common using(file_id)
group by sop_instance_uid
order by count desc
', '{}', 
                    ARRAY['sop_instance_uid', 'count'], ARRAY['Structure Sets', 'sops', 'LinkageChecks'], 'posda_files', 'Get List of ROI''s in a structure Set

')
        ;

            insert into queries
            values ('GetZipUploadEventsByDateRangeNonDicomOnly', 'select distinct import_event_id, import_time, count (distinct file_id) as num_files from (
  select import_event_id, file_id, import_time, rel_path, file_type
  from file_import natural join import_event join file using(file_id)
  where import_time > ? and import_time < ? and import_comment = ''zip''
  and (rel_path like ''%.docx'' or rel_path like ''%.xls'' or rel_path like ''%.xlsx'' or rel_path like ''%.csv'')
) as foo
group by import_event_id, import_time', ARRAY['from', 'to'], 
                    ARRAY['import_event_id', 'num_files'], ARRAY['radcomp'], 'posda_files', 'Add a filter to a tab')
        ;

            insert into queries
            values ('ChangeFileStorageRootIdByFileIdAndOldStorageRootId', 'update
  file_location
set file_storage_root_id = ?
where file_storage_root_id = ?
and file_id = ?', ARRAY['new_file_storage_root_id', 'old_file_storage_root_id', 'file_id'], 
                    '{}', ARRAY['used_in_file_import_into_posda', 'used_in_file_migration'], 'posda_files', 'Get root_path for a file_storage_root
')
        ;

            insert into queries
            values ('DoesDoseReferenceGoodPlan', 'select
  sop_instance_uid
from
  file_sop_common fsc, rt_dose d natural join file_dose f
where
  f.file_id = ? and d.rt_dose_referenced_plan_uid = fsc.sop_instance_uid', ARRAY['file_id'], 
                    ARRAY['sop_instance_uid'], ARRAY['LinkageChecks', 'used_in_dose_linkage_check'], 'posda_files', 'Determine whether an RTDOSE references a known plan

')
        ;

            insert into queries
            values ('DciodvfyErrorIdsBySeriesAndScanInstance', 'select                                                    
  dciodvfy_error_id
from dciodvfy_error 
where  dciodvfy_error_id in (
  select distinct dciodvfy_error_id
  from (
    select
      distinct unit_uid, dciodvfy_error_id
    from
      dciodvfy_unit_scan
      natural join dciodvfy_unit_scan_error
    where
      dciodvfy_scan_instance_id = ? and unit_uid =?
  )
 as foo
)', ARRAY['dciodvfy_scan_instance_id', 'series_instance_uid'], 
                    ARRAY['dciodvfy_error_id'], ARRAY['tag_usage', 'dciodvfy'], 'posda_phi_simple', 'Show all the dciodvfy scans')
        ;

            insert into queries
            values ('PrivateTagUsage', 'select
  distinct element_signature, equipment_signature
from 
  equipment_signature natural join series_scan
  natural join scan_element natural join element_signature
  natural join scan_event
where scan_event_id = ? and is_private
order by element_signature;
', ARRAY['scan_id'], 
                    ARRAY['element_signature', 'equipment_signature'], ARRAY['tag_usage'], 'posda_phi', 'Which equipment signatures for which private tags
')
        ;

            insert into queries
            values ('GetDosesAndPlanReferences', 'select
  sop_instance_uid as dose_referencing,
  rt_dose_referenced_plan_uid as plan_referenced
from
  rt_dose natural join file_dose join file_sop_common using (file_id)', '{}', 
                    ARRAY['dose_referencing', 'plan_referenced'], ARRAY['Structure Sets', 'sops', 'LinkageChecks'], 'posda_files', 'Get list of dose and plan sops where dose references plan
')
        ;

            insert into queries
            values ('CountsByCollectionSiteDateRangePlus', 'select
  distinct
    patient_id, image_type, dicom_file_type, modality,
    study_date, series_date,
    study_description,
    series_description, study_instance_uid, series_instance_uid,
    manufacturer, manuf_model_name, software_versions,
    count(distinct sop_instance_uid) as num_sops,
    count(distinct file_id) as num_files,
    min(import_time) as earliest,
    max(import_time) as latest
from
  ctp_file join file_patient using(file_id)
  join dicom_file using(file_id)
  join file_series using(file_id)
  join file_sop_common using(file_id)
  join file_study using(file_id)
  join file_equipment using(file_id)
  join file_import using(file_id)
  join import_event using(import_event_id)
  left join file_image using(file_id)
  left join image using (image_id)
where
  file_id in (
    select file_id 
    from file_import natural join import_event
    where import_time > ? and import_time < ?
  ) and project_name = ? and site_name = ? and visibility is null
group by
  patient_id, image_type, dicom_file_type, modality, study_date, 
  series_date, study_description,
  series_description, study_instance_uid, series_instance_uid,
  manufacturer, manuf_model_name, software_versions
order by
  patient_id, study_instance_uid, series_instance_uid, image_type,
  modality, study_date, series_date, study_description,
  series_description,
  manufacturer, manuf_model_name, software_versions
', ARRAY['from', 'to', 'collection', 'site'], 
                    ARRAY['patient_id', 'image_type', 'dicom_file_type', 'modality', 'study_date', 'series_date', 'study_description', 'series_description', 'study_instance_uid', 'series_instance_uid', 'manufacturer', 'manuf_model_name', 'software_versions', 'num_sops', 'num_files', 'earliest', 'latest'], ARRAY['counts', 'count_queries'], 'posda_files', 'Counts query by Collection, Site
')
        ;

            insert into queries
            values ('DupSopsByCollectionDateRange', 'select
  distinct collection, site, subj_id, 
  sop_instance_uid,
  count(distinct file_id) as num_files
from (
  select
    distinct project_name as collection,
    site_name as site, patient_id as subj_id,
    study_instance_uid, series_instance_uid,
    sop_instance_uid,
    file_id
  from
    ctp_file natural join file_sop_common
    natural join file_patient natural join file_study natural join file_series
  where
    sop_instance_uid in (
      select distinct sop_instance_uid 
      from (
        select distinct sop_instance_uid, count(distinct file_id)
        from file_sop_common natural join ctp_file
        where visibility is null and sop_instance_uid in (
          select distinct sop_instance_uid
          from file_sop_common natural join ctp_file
            join file_import using(file_id) 
            join import_event using(import_event_id)
          where project_name = ?  and
             visibility is null and import_time > ?
              and import_time < ?
        ) group by sop_instance_uid
      ) as foo 
      where count > 1
    )
    and visibility is null
  ) as foo
group by collection, site, subj_id, sop_instance_uid

', ARRAY['collection', 'from', 'to'], 
                    ARRAY['collection', 'site', 'subj_id', 'sop_instance_uid', 'num_files'], ARRAY['duplicates', 'dup_sops', 'hide_dup_sops', 'check_dups'], 'posda_files', 'Return a count of duplicate SOP Instance UIDs
')
        ;

            insert into queries
            values ('GetPosdaFileIdByDigest', 'select
 file_id
from
  file
where
  digest = ?

', ARRAY['digest'], 
                    ARRAY['file_id'], ARRAY['NotInteractive', 'Backlog', 'used_in_file_import_into_posda'], 'posda_files', 'Get posda file id of file by file_digest')
        ;

            insert into queries
            values ('DistinctSeriesByCollectionSitePublic', 'select
  distinct s.series_instance_uid, modality, count(*) as num_images
from
  general_image i, general_series s,
  trial_data_provenance tdp
where
  s.general_series_pk_id = i.general_series_pk_id and
  i.trial_dp_pk_id = tdp.trial_dp_pk_id and
  tdp.project = ? and tdp.dp_site_name = ?
group by series_instance_uid, modality', ARRAY['project_name', 'site_name'], 
                    ARRAY['series_instance_uid', 'modality', 'num_images'], ARRAY['by_collection', 'find_series', 'intake', 'compare_collection_site', 'simple_phi'], 'public', 'Get Series in A Collection, Site
')
        ;

            insert into queries
            values ('GetLoadWeeks', 'select 
  distinct load_week from (
  select 
    distinct file_id, date_trunc(''week'', min(import_time)) as load_week
  from 
    file_import natural join import_event
  where
    import_time >= ? and import_time < ?
  group by file_id
) as foo 
order by load_week;', ARRAY['from', 'to'], 
                    ARRAY['load_week'], ARRAY['downloads_by_date'], 'posda_files', 'Counts query by Collection, Site
')
        ;

            insert into queries
            values ('InsertEditImportEvent', 'insert into import_event(
  import_type, import_comment, import_time
) values (
  ?, ?, now()
)', ARRAY['import_type', 'import_comment'], 
                    '{}', ARRAY['NotInteractive', 'Backlog', 'Transaction', 'used_in_file_import_into_posda'], 'posda_files', 'Insert an Import Event for an Edited File')
        ;

            insert into queries
            values ('VisibilityChangeEventsByCollectionByHour', 'select 
  distinct project_name as collection,
  site_name as site,
  patient_id,
  series_instance_uid,
  date_trunc(''hour'', time_of_change) as when_done,
  user_name, prior_visibility, new_visibility, reason_for, count(distinct file_id) as num_files
from
   ctp_file natural join file_patient natural join file_series natural join file_visibility_change 
where project_name = ?
group by
 collection, site, patient_id, series_instance_uid, when_done, user_name, prior_visibility, new_visibility, reason_for
order by when_done desc', ARRAY['collection'], 
                    ARRAY['collection', 'site', 'patient_id', 'series_instance_uid', 'when_done', 'user_name', 'prior_visibility', 'new_visibility', 'reason_for', 'num_files'], ARRAY['meta', 'test', 'hello', 'bills_test', 'hide_events', 'show_hidden'], 'posda_files', 'Add a filter to a tab')
        ;

            insert into queries
            values ('RoundCountsByCollection2', 'select
  round_id, collection,
  round_created,
  round_start,  
  round_end,
  wait_count,
  process_count,
  num_entered,
  num_failed,
  num_dups,
  num_requests,
  priority
from
  round natural join round_counts natural join round_collection
where collection = ?
order by round_id, collection', ARRAY['collection'], 
                    ARRAY['round_id', 'collection', 'num_dups', 'round_created', 'round_start', 'round_end', 'wait_count', 'process_count', 'num_entered', 'num_failed', 'num_dups', 'num_requests', 'priority'], ARRAY['NotInteractive', 'Backlog', 'Backlog Monitor', 'backlog_analysis_reporting_tools'], 'posda_backlog', 'Summary of rounds')
        ;

            insert into queries
            values ('ListOfRepeatingPrivateElementsFromDD', 'select
  ptrg_signature_masked as tag,
  ptrg_base_grp as base_grp,
  ptrg_grp_mask as id_mask,
  ptrg_grp_ext_mask as ext_mask,
  ptrg_grp_ext_shift as ext_shift,
  ptrg_consensus_vr as vr,
  ptrg_consensus_vm as vm,
  ptrg_consensus_name as name 
from ptrg', '{}', 
                    ARRAY['tag', 'base_grp', 'id_mask', 'ext_mask', 'ext_shift', 'vr', 'vm', 'name'], ARRAY['ElementDisposition'], 'posda_private_tag', 'Get List of Repeating Private Tags from DD')
        ;

            insert into queries
            values ('FinalizeComparePublicToPosdaInstance', 'update compare_public_to_posda_instance set
  status_of_compare = ''Comparisons In Progress'',
  when_compare_completed = now(),
  last_updated = now()
where
  compare_public_to_posda_instance_id = ?
', ARRAY['compare_public_to_posda_instance_id'], 
                    '{}', ARRAY['adding_ctp', 'for_scripting'], 'posda_files', 'Update an entry in dicom_edit_compare_disposition

From script only.  Don''t run from user interface (needs valid subprocess_invocation_id)')
        ;

            insert into queries
            values ('GetSsReferencingUnknownImagesByCollection', 'select
  distinct project_name as collection,
  site_name as site,
  patient_id, series_instance_uid, file_id
from
  ctp_file natural join file_patient natural join file_series
where file_id in (
select
  distinct ss_file_id as file_id from 
(select
  sop_instance_uid, ss_file_id 
from (
  select 
    distinct linked_sop_instance_uid as sop_instance_uid, file_id as ss_file_id
  from
    file_roi_image_linkage
  ) foo left join file_sop_common using(sop_instance_uid)
  where
  file_id is null
) as foo
)
and project_name = ? and visibility is null
order by collection, site, patient_id, file_id
', ARRAY['collection'], 
                    ARRAY['collection', 'site', 'patient_id', 'series_instance_uid', 'file_id'], ARRAY['Structure Sets', 'sops', 'LinkageChecks', 'struct_linkages'], 'posda_files', 'Get list of plan which reference unknown SOPs

')
        ;

            insert into queries
            values ('GetDciodvfyErrorUncat', 'select
  dciodvfy_error_id as id
from 
  dciodvfy_error
where
  error_type = ''Uncategorized''
  and error_text = ?', ARRAY['error_text'], 
                    ARRAY['id'], ARRAY['NotInteractive', 'used_in_dciodvfy'], 'posda_phi_simple', 'Get an dciodvfy_errors row by error_text (if present)')
        ;

            insert into queries
            values ('GetDciodvfyErrorInvalidValueForVr', 'select
  dciodvfy_error_id as id
from 
  dciodvfy_error
where
  error_type = ''InvalidValueForVr''
  and error_tag = ? and
  error_index = ? and
  error_value = ? and
  error_reason = ? and
  error_subtype = ?
', ARRAY['error_tag', 'error_index', 'error_value', 'error_reason', 'error_desc'], 
                    ARRAY['id'], ARRAY['NotInteractive', 'used_in_dciodvfy'], 'posda_phi_simple', 'Get an dciodvfy_errors row by error_tag where error_type = ''InvalidValueForVr''')
        ;

            insert into queries
            values ('HideEvents', 'select
  distinct date_trunc(''day'', time_of_change) as when_done, 
  reason_for,
  user_name, 
  count(*) as num_files
from
  file_visibility_change
group by when_done, reason_for, user_name
order by when_done desc', '{}', 
                    ARRAY['when_done', 'reason_for', 'user_name', 'num_files'], ARRAY['meta', 'test', 'hello', 'bills_test', 'hide_events'], 'posda_files', 'Add a filter to a tab')
        ;

            insert into queries
            values ('SimplePhiReportAllMetaQuotes', 'select 
  distinct ''<'' || element_sig_pattern || ''>'' as element, vr, 
  ''<'' || value || ''>'' as q_value, tag_name as description, count(*) as num_series
from element_value_occurance natural join element_seen natural join value_seen
where 
  phi_scan_instance_id = ?
group by element_sig_pattern, vr, value, description
order by vr, element, q_value
', ARRAY['scan_id'], 
                    ARRAY['element', 'vr', 'q_value', 'description', 'num_series'], ARRAY['adding_ctp', 'for_scripting', 'phi_reports'], 'posda_phi_simple', 'Simple Phi Report with Meta Quotes')
        ;

            insert into queries
            values ('CreateBackgroundReport', 'insert into background_subprocess_report(
  background_subprocess_id,
  file_id,
  name
) values (
  ?, ?, ?
)
returning background_subprocess_report_id
', ARRAY['background_subprocess_id', 'file_id', 'name'], 
                    NULL, ARRAY['NotInteractive', 'used_in_background_processing'], 'posda_queries', 'Create a new entry in background_subprocess_report table')
        ;

            insert into queries
            values ('PublicCollectionCounts', 'select
        tdp.project as Collection,''|'',
        group_concat(distinct s.modality) as Modalities,''|'',
        count(distinct p.patient_id) as Pts,''|'',
        count(distinct t.study_instance_uid) as Studies,''|'',
        count(distinct s.series_instance_uid) as Series,''|'',
        count(distinct i.sop_instance_uid) as Images, ''|'',
        format(sum(i.dicom_size)/1000000000,1) as GBytes
 
     from
        general_image i,
        general_series s,
        study t,
        patient p,
        trial_data_provenance tdp
 
     where
        i.general_series_pk_id = s.general_series_pk_id and
        s.study_pk_id = t.study_pk_id and
        t.patient_pk_id = p.patient_pk_id and
        p.trial_dp_pk_id = tdp.trial_dp_pk_id and
        tdp.project =? and
        s.visibility = ?
 
     group by tdp.project', ARRAY['collection', 'visibility'], 
                    ARRAY['Collection', 'Modalities', 'Pts', 'Studies', 'Series', 'Images', 'GBytes'], ARRAY['AllCollections', 'DateRange', 'Kirk', 'Totals', 'count_queries', 'end_of_month'], 'public', 'Get public totals for collection

Used to fill in "Detailed description" on public Wiki page

')
        ;

            insert into queries
            values ('PatientIdMappingByToPatientId', 'select
  from_patient_id, to_patient_id, to_patient_name, collection_name, site_name,
  batch_number, diagnosis_date, baseline_date, date_shift, uid_root,
  baseline_date - diagnosis_date + interval ''1 day'' as computed_shift,
  site_code
from 
  patient_mapping
where
  to_patient_id = ?', ARRAY['to_patient_id'], 
                    ARRAY['from_patient_id', 'to_patient_id', 'to_patient_name', 'collection_name', 'site_name', 'batch_number', 'diagnosis_date', 'baseline_date', 'date_shift', 'uid_root', 'computed_shift', 'site_code'], ARRAY['adding_ctp', 'for_scripting', 'non_dicom_phi', 'non_dicom_edit'], 'posda_files', 'Simple Phi Report with Meta Quotes')
        ;

            insert into queries
            values ('ListActivities', 'select
  activity_id,
  brief_description,
  when_created,
  who_created,
  when_closed
from
  activity
order by activity_id desc', '{}', 
                    ARRAY['activity_id', 'brief_description', 'when_created', 'who_created', 'when_closed'], ARRAY['AllCollections', 'queries', 'activity_support'], 'posda_queries', 'Get a list of available queries')
        ;

            insert into queries
            values ('CreateNonDicomFileChangeRow', 'insert into non_dicom_file_change(
  file_id, file_type, file_sub_type, collection, site, subject, visibility, when_categorized,
  when_recategorized, who_recategorized, why_recategorized)
values(
  ?, ?, ?, ?, ?, ?, ?, ?,
  now(), ?, ?
)
', ARRAY['file_id', 'file_type', 'file_sub_type', 'collection', 'site', 'subject', 'visibility', 'date_last_categorized', 'who', 'why'], 
                    '{}', ARRAY['radcomp'], 'posda_files', 'Add a filter to a tab')
        ;

            insert into queries
            values ('SimplePhiReportPrivateOnlyByScanVrScreenDeletedPT', 'select 
  distinct element_sig_pattern as element, vr, value, 
  tag_name as description, count(*) as num_series
from element_value_occurance natural join element_seen natural join value_seen
where 
  phi_scan_instance_id = ? and vr = ? and
  is_private and
  private_disposition in (''k'', ''oi'', ''h'', ''o'')
group by element_sig_pattern, vr, value, tag_name', ARRAY['scan_id', 'vr'], 
                    ARRAY['element', 'vr', 'value', 'description', 'num_series'], ARRAY['tag_usage', 'simple_phi'], 'posda_phi_simple', 'Status of PHI scans
')
        ;

            insert into queries
            values ('FindingFilesWithImageProblem', 'select file_id, root_path || ''/'' || rel_path as path
from (
  select file_id, image_id 
  from pixel_location left join image using(unique_pixel_data_id)
  where file_id in (
    select
       distinct file_id from file_import natural join import_event natural join dicom_file
    where import_time > ''2018-09-17''
  )
) as foo natural join ctp_file natural join file_location natural join file_storage_root
where image_id is null and visibility is null
', '{}', 
                    ARRAY['file_id', 'path'], ARRAY['Exceptional-Responders_NCI_Oct2018_curation'], 'posda_files', 'Find files which have unique_pixel_data_id but no image_id, then find out where the hell they came from')
        ;

            insert into queries
            values ('GetDciodvfyUnitScanErrorId', 'select currval(''dciodvfy_unit_scan_error_dciodvfy_unit_scan_error_id_seq'') as id', '{}', 
                    ARRAY['id'], ARRAY['NotInteractive', 'used_in_dciodvfy'], 'posda_phi_simple', 'Create a dciodvfy_scan_instance row')
        ;

            insert into queries
            values ('FilesIdsVisibleInSeries', 'select
  distinct file_id
from
  file_series natural join file_sop_common natural join ctp_file
where
  series_instance_uid = ? and visibility is null
', ARRAY['series_instance_uid'], 
                    ARRAY['file_id'], ARRAY['by_series_instance_uid', 'file_ids', 'posda_files'], 'posda_files', 'Get Distinct Unhidden Files in Series
')
        ;

            insert into queries
            values ('RequestShutdown', 'update control_status
  set pending_change_request = ''shutdown'',
  source_pending_change_request = ''DbIf'',
  request_time = now()', '{}', 
                    '{}', ARRAY['NotInteractive', 'Backlog', 'Backlog Monitor'], 'posda_backlog', 'request a shutdown of Backlog processing')
        ;

            insert into queries
            values ('GetPixelPaddingInfo', 'select
  distinct modality, pixel_pad, slope, intercept, manufacturer, 
  image_type, pixel_representation as signed, count(*)
from                                           
  file_series natural join file_equipment natural join 
  file_slope_intercept natural join slope_intercept natural join file_image natural join image
where                                                 
  modality = ''CT''
group by 
  modality, pixel_pad, slope, intercept, manufacturer, image_type, signed
', '{}', 
                    ARRAY['modality', 'pixel_pad', 'slope', 'intercept', 'manufacturer', 'image_type', 'signed', 'count'], ARRAY['PixelPadding'], 'posda_files', 'Get Pixel Padding Summary Info
')
        ;

            insert into queries
            values ('ListHiddenFilesByCollectionPatient', 'select
  project_name as collection,
  site_name as site,
  patient_id,
  series_instance_uid,
  file_id,
  visibility as old_visibility
from
  ctp_file natural join
  file_patient natural join
  file_series
where
  visibility is not null and
  project_name = ? and
  patient_id = ?', ARRAY['collection', 'patient_id'], 
                    ARRAY['collection', 'site', 'patient_id', 'series_instance_uid', 'file_id', 'old_visibility'], ARRAY['find_series', 'equivalence_classes', 'consistency', 'visual_review_results', 'old_visibility'], 'posda_files', 'Show Received before date by collection, site')
        ;

            insert into queries
            values ('DistinctSeriesByCollectionPublic', 'select
  distinct s.series_instance_uid, modality, count(*) as num_images
from
  general_image i, general_series s,
  trial_data_provenance tdp
where
  s.general_series_pk_id = i.general_series_pk_id and
  i.trial_dp_pk_id = tdp.trial_dp_pk_id and
  tdp.project = ?
group by series_instance_uid, modality', ARRAY['project_name'], 
                    ARRAY['series_instance_uid', 'modality', 'num_images'], ARRAY['by_collection', 'find_series', 'public'], 'public', 'Get Series in A Collection
')
        ;

            insert into queries
            values ('DciodvfyErrorsStringBySeriesAndScanInstance', 'select                                                    
  dciodvfy_error_id || ''|'' ||
  error_type || ''|'' ||                                                                                                                                                                                                                   
  error_tag || ''|'' ||
  coalesce(error_value, ''[null]'') || ''|'' ||
  coalesce(error_subtype, ''[null]'') || ''|'' ||
  coalesce(error_module, ''[null]'') || ''|'' ||
  coalesce(error_reason, ''[null]'') || ''|'' ||
  coalesce(error_index, ''[null]'') || ''|'' ||
  coalesce(error_text, ''[null]'') as error_string
from dciodvfy_error 
where  dciodvfy_error_id in (
  select distinct dciodvfy_error_id
  from (
    select
      distinct unit_uid, dciodvfy_error_id
    from
      dciodvfy_unit_scan
      natural join dciodvfy_unit_scan_error
    where
      dciodvfy_scan_instance_id = ? and unit_uid =?
  )
 as foo
)', ARRAY['dciodvfy_scan_instance_id', 'series_instance_uid'], 
                    ARRAY['error_string'], ARRAY['tag_usage', 'dciodvfy'], 'posda_phi_simple', 'Show all the dciodvfy scans')
        ;

            insert into queries
            values ('DistinctSeriesByImportEventByPatLike', 'select
  distinct series_instance_uid, count(distinct file_id) as num_files
from (
  select distinct series_instance_uid, file_id 
  from file_series 
  where file_id in (
    select
      distinct file_id from file_import where import_event_id in (select import_event_id from (
        select
          distinct import_event_id, import_time,  import_type, count(distinct file_id) as num_files
        from
          import_event natural join file_import natural join file_patient
        where
          import_type = ''multi file import'' and
          patient_id like ?
         group by import_event_id, import_time, import_type
       ) as foo
    )
  )
)as foo
group by series_instance_uid
', ARRAY['patient_id_like'], 
                    ARRAY['series_instance_uid', 'num_files'], ARRAY['adding_ctp', 'find_patients', 'no_ctp_patients', 'import_event'], 'posda_files', 'Get Series in A Collection
')
        ;

            insert into queries
            values ('GetSeriesWithSignature', 'select distinct
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
', ARRAY['collection'], 
                    ARRAY['series_instance_uid', 'dicom_file_type', 'signature', 'num_series', 'num_files'], ARRAY['signature'], 'posda_files', 'Get a list of Series with Signatures by Collection
')
        ;

            insert into queries
            values ('SeriesByNotLikeDescriptionAndCollectionSite', 'select distinct
  series_instance_uid, series_description
from
  file_series natural join ctp_file
where 
  project_name = ? and site_name = ? and 
  visibility is null and
  series_description not like ?
', ARRAY['collection', 'site', 'pattern'], 
                    ARRAY['series_instance_uid', 'series_description'], ARRAY['find_series'], 'posda_files', 'Get a list of Series by Collection, Site not matching Series Description
')
        ;

            insert into queries
            values ('HideEventInfo', 'select 
  distinct project_name as collection,
  site_name as site,
  patient_id,
  series_instance_uid,
  count(distinct file_id) as num_files
from 
  ctp_file natural join
  file_series natural join 
  file_patient
where file_id in (
select
  distinct file_id
from
  file_visibility_change
where
  date_trunc(''day'', time_of_change) = ? and
  reason_for = ? and
  user_name = ?
)
group by
  collection, site, patient_id, series_instance_uid
order by
  collection, site, patient_id, series_instance_uid', ARRAY['day_of_change', 'reason_for', 'user_name'], 
                    ARRAY['collection', 'site', 'patient_id', 'series_instance_uid', 'num_files'], ARRAY['meta', 'test', 'hello', 'bills_test', 'hide_events'], 'posda_files', 'Add a filter to a tab')
        ;

            insert into queries
            values ('SeriesInHierarchyBySeriesExtended', 'select distinct
  project_name as collection,
  site_name as site,
  patient_id,
  study_instance_uid,
  study_date,
  study_description,
  series_instance_uid,
  series_description,
  series_date,
  modality,
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
  collection, site, patient_id, study_instance_uid, study_date,
  study_description, series_instance_uid, series_description,
  series_date, modality
order by
  project_name, site_name, patient_id,
  study_instance_uid, series_instance_uid
', ARRAY['series_instance_uid'], 
                    ARRAY['collection', 'site', 'patient_id', 'study_instance_uid', 'study_date', 'study_description', 'series_instance_uid', 'series_description', 'series_date', 'modality', 'num_files'], ARRAY['by_series_instance_uid', 'posda_files', 'sops'], 'posda_files', 'Get Collection, Site, Patient, Study Hierarchy in which series resides
')
        ;

            insert into queries
            values ('DupSopsByCollection', 'select distinct sop_instance_uid, min(latest) as earliest, max(latest) as latest
from (
  select
    distinct sop_instance_uid, file_id, max(import_time) latest
  from file_location join file_import using(file_id) join import_event using (import_event_id)  
    join file_sop_common using(file_id) join ctp_file using (file_id)
  where sop_instance_uid in (
    select distinct sop_instance_uid from (
      select distinct sop_instance_uid, count(distinct file_id)
      from file_sop_common natural join ctp_file
      where project_name = ? and visibility is null group by sop_instance_uid
      ) as foo
    where count > 1
    ) and visibility is null
  group by sop_instance_uid, file_id
) as foo
group by sop_instance_uid', ARRAY['collection'], 
                    ARRAY['sop_instance_uid', 'earliest', 'latest'], ARRAY['meta', 'test', 'hello', 'bills_test', 'check_dups'], 'posda_files', 'List of duplicate sops with file_ids and latest load date')
        ;

            insert into queries
            values ('GetSimpleSeriesScanId', 'select currval(''series_scan_instance_series_scan_instance_id_seq'') as id', '{}', 
                    ARRAY['id'], ARRAY['used_in_simple_phi', 'NotInteractive'], 'posda_phi_simple', 'Get id of newly created series_scan_instance')
        ;

            insert into queries
            values ('AddPhiSimpleElement', 'insert into element_seen (
  element_sig_pattern,
  vr,
  is_private,
  private_disposition,
  tag_name
) values (
  ?, ?, ?, ?, ?
)
', ARRAY['element_signature', 'vr', 'is_private', 'private_disposition', 'name_chain'], 
                    '{}', ARRAY['NotInteractive', 'used_in_reconcile_tag_names'], 'posda_phi_simple', 'Add an element_seen row to posda_phi_simple')
        ;

            insert into queries
            values ('CreateFileSend', 'insert into dicom_file_send(
  dicom_send_event_id, file_path, status, file_id_sent
) values (
  ?, ?, ?, ?
)
', ARRAY['id', 'path', 'status', 'file_id'], 
                    NULL, ARRAY['NotInteractive', 'SeriesSendEvent'], 'posda_files', 'Add a file send row
For use in scripts.
Not meant for interactive use
')
        ;

            insert into queries
            values ('GetEditStatus', 'select
  subprocess_invocation_id as id,
  start_creation_time, end_creation_time - start_creation_time as duration,
  number_edits_scheduled as to_edit,
  number_compares_with_diffs as changed,
  number_compares_without_diffs as not_changed,
  current_disposition as disposition,
  dest_dir
from
  dicom_edit_compare_disposition
order by start_creation_time desc', '{}', 
                    ARRAY['id', 'start_creation_time', 'duration', 'to_edit', 'changed', 'not_changed', 'disposition', 'dest_dir'], ARRAY['adding_ctp', 'find_patients', 'series_selection', 'check_edits', 'testing_edit_objects', 'edit_status'], 'posda_files', 'Get List of visible patients with CTP data')
        ;

            insert into queries
            values ('CreateBackgroundInputLine', 'insert into background_input_line(
  background_subprocess_id,
  line_number,
  line
) values (
  ?, ?, ?
)', ARRAY['background_subprocess_id', 'param_index', 'param_value'], 
                    '{}', ARRAY['NotInteractive', 'used_in_background_processing'], 'posda_queries', 'Create row in background_input_line table

Used by background subprocess')
        ;

            insert into queries
            values ('PhiNonDicomScanStatusInProgress', 'select 
   phi_non_dicom_scan_instance_id as id,
   pndsi_description as description,
   pndsi_start_time as start_time,
   pndsi_num_files as num_files_to_scan,
   pndsi_num_files_scanned as num_files_scanned,
   now() - pndsi_start_time as time_running
from
  phi_non_dicom_scan_instance
where pndsi_end_time is null
order by start_time', '{}', 
                    ARRAY['id', 'description', 'start_time', 'num_files_to_scan', 'num_files_scanned', 'time_running'], ARRAY['tag_usage', 'non_dicom_phi_status'], 'posda_phi_simple', 'Status of PHI scans
')
        ;

            insert into queries
            values ('SeriesWithExactlyNEquivalenceClasses', 'select series_instance_uid, count from (
select distinct series_instance_uid, count(*) from image_equivalence_class group by series_instance_uid) as foo where count = ?', ARRAY['count'], 
                    ARRAY['series_instance_uid', 'count'], ARRAY['find_series', 'equivalence_classes', 'consistency'], 'posda_files', 'Find Series with exactly n equivalence classes')
        ;

            insert into queries
            values ('GetPosdaFilesImportControl', 'select
  status,
  processor_pid,
  idle_seconds,
  pending_change_request,
  files_per_round
from
  import_control', '{}', 
                    ARRAY['status', 'processor_pid', 'idle_seconds', 'pending_change_request', 'files_per_round'], ARRAY['NotInteractive', 'PosdaImport'], 'posda_files', 'Get import control status from posda_files database')
        ;

            insert into queries
            values ('AllValuesByElementSig', 'select distinct value, vr, element_signature, equipment_signature, count(*)
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
', ARRAY['scan_id', 'tag_signature'], 
                    ARRAY['value', 'vr', 'element_signature', 'equipment_signature', 'count'], ARRAY['tag_usage'], 'posda_phi', 'List of values seen in scan by ElementSignature with VR and count
')
        ;

            insert into queries
            values ('GetDicomEditCompareDisposition', 'select
  number_edits_scheduled,
  number_compares_with_diffs,
  number_compares_without_diffs,
  current_disposition,
  dest_dir
from
  dicom_edit_compare_disposition
where
  subprocess_invocation_id = ?
  ', ARRAY['subprocess_invocation_id'], 
                    ARRAY['number_edits_scheduled', 'number_compares_with_diffs', 'number_compares_without_diffs', 'current_disposition', 'dest_dir'], ARRAY['adding_ctp', 'for_scripting'], 'posda_files', 'Retrieve entries from patient_mapping table')
        ;

            insert into queries
            values ('SeriesCollectionSite', 'select distinct
  series_instance_uid
from
  file_series natural join ctp_file
where project_name = ? and site_name = ? and visibility is null
', ARRAY['collection', 'site'], 
                    ARRAY['series_instance_uid'], ARRAY['find_series'], 'posda_files', 'Get a list of Series by Collection, Site
')
        ;

            insert into queries
            values ('GetStartOfWeek', 'select 
  date_trunc(''week'', to_timestamp(?, ''yyyy-mm-dd'')) as start_week
 ', ARRAY['from'], 
                    ARRAY['start_week'], ARRAY['downloads_by_date'], 'posda_files', 'Counts query by Collection, Site
')
        ;

            insert into queries
            values ('VisibilityChangeEventsByCollectionForHiddenFiles', 'select
  distinct project_name as collection, 
  site_name as site, patient_id,
  user_name, 
  date_trunc(''hour'',time_of_change) as time, 
  reason_for, count(*)
from
  file_visibility_change natural join
  ctp_file natural join 
  file_patient natural join 
  file_series
where
  project_name = ? and
  visibility is not null
group by collection, site, patient_id, user_name, time, reason_for
order by time, collection, site, patient_id', ARRAY['collection'], 
                    ARRAY['collection', 'site', 'patient_id', 'user_name', 'time', 'reason_for', 'count'], ARRAY['find_series', 'equivalence_classes', 'consistency', 'visual_review_results', 'hide_files', 'old_hidden'], 'posda_files', 'Show Received before date by collection, site')
        ;

            insert into queries
            values ('CreateSubprocessInvocationButton', 'insert into subprocess_invocation (
  from_spreadsheet,
  from_button,
  query_invoked_by_dbif_id,
  button_name,
  command_line,
  invoking_user,
  when_invoked,
  operation_name
) values (
  false, true, ?, ?, ?, ?, now(), ?
)
returning subprocess_invocation_id
', ARRAY['query_invoked_by_dbif_id', 'btn_name', 'command_line', 'invoking_user', 'operation_name'], 
                    '{}', ARRAY['NotInteractive', 'used_in_background_processing'], 'posda_queries', 'Create a row in subprocess_invocation table

Used when invoking a spreadsheet operation from a button')
        ;

            insert into queries
            values ('InsertIntoSeriesScan', 'insert into series_scan(
  scan_event_id, equipment_signature_id, series_instance_uid,
  series_scan_status, series_scanned_file
) values (
  ?, ?, ?, ''In Process'', ?)', ARRAY['scan_id', 'equipment_signature_id', 'series_instance_uid', 'series_scanned_file'], 
                    '{}', ARRAY['UsedInPhiSeriesScan', 'NotInteractive'], 'posda_phi', 'List of values seen in scan by VR (with count of elements)
')
        ;

            insert into queries
            values ('TestThisOne', 'select
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
', ARRAY['project_name', 'site_name', 'PatientStatus'], 
                    ARRAY['patient_id', 'patient_import_status', 'total_files', 'min_time', 'max_time', 'num_studies', 'num_series'], '{}', 'posda_files', '')
        ;

            insert into queries
            values ('ListOfPrivateElementsWithNullDispositions', 'select
  distinct element_signature, vr , private_disposition as disposition,
  element_signature_id, name_chain
from
  element_signature natural join scan_element natural join series_scan
where
  is_private and private_disposition is null
order by element_signature
', '{}', 
                    ARRAY['element_signature', 'vr', 'disposition', 'element_signature_id', 'name_chain'], ARRAY['NotInteractive', 'Update', 'ElementDisposition'], 'posda_phi', 'Get Disposition of element by sig and VR')
        ;

            insert into queries
            values ('ImportEventsByMatchingNameAndType', 'select
  import_event_id, import_type,
  import_comment, import_time, import_close_time - import_time as duration, 
  count(distinct file_id) as num_images
from 
  import_event natural join file_import
where
  import_comment like ? and import_type like ?
group by import_event_id, import_type, import_comment, import_time, import_close_time', ARRAY['import_comment_like', 'import_type_like'], 
                    ARRAY['import_event_id', 'import_type', 'import_comment', 'import_time', 'duration', 'num_images'], ARRAY['import_events'], 'posda_files', 'Get Import Events by matching comment')
        ;

            insert into queries
            values ('GetSeriesForPhiInfo', 'select 
  series_instance_uid
from 
  series_scan_instance 
where series_scan_instance_id in (
  select series_scan_instance_id 
  from element_value_occurance 
  where element_seen_id in (
    select 
      element_seen_id 
    from element_seen 
    where element_sig_pattern = ? and vr = ?
  )
  and value_seen_id in (
    select value_seen_id 
    from value_seen
    where value = ?
  )
  and phi_scan_instance_id = ?
)', ARRAY['element', 'vr', 'value', 'scan_id'], 
                    ARRAY['series_instance_uid'], ARRAY['used_in_simple_phi', 'NotInteractive'], 'posda_phi_simple', 'Get an element_seen row by element, vr (if present)')
        ;

            insert into queries
            values ('GetElementSignature', 'select * from element_signature
  where element_signature = ? and vr = ?
', ARRAY['element_signature', 'vr'], 
                    ARRAY['element_signature_id', 'element_signature', 'is_private', 'vr'], ARRAY['UsedInPhiSeriesScan', 'NotInteractive', 'ElementDisposition'], 'posda_phi', 'Get Element Signature By Signature (pattern) and VR')
        ;

            insert into queries
            values ('ActiveQueriesRunning', 'select 
  datname, pid,
  now() - query_start as time_query_running, 
  query
from pg_stat_activity
where
  state = ''active''
order by datname, state
', '{}', 
                    ARRAY['datname', 'pid', 'time_query_running', 'query'], ARRAY['AllCollections', 'postgres_stats', 'postgres_query_stats'], 'posda_backlog', 'Get a list of collections and sites
')
        ;

            insert into queries
            values ('AllVrsByElementSig', 'select distinct vr, element_signature, equipment_signature, count(*)
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
', ARRAY['scan_id', 'tag_signature'], 
                    ARRAY['vr', 'element_signature', 'equipment_signature', 'count'], ARRAY['tag_usage'], 'posda_phi', 'List of values seen in scan by ElementSignature with VR and count
')
        ;

            insert into queries
            values ('GetListStructureSetsByCollectionSite', 'select 
  distinct project_name, site_name, patient_id, sop_instance_uid
from
  file_sop_common natural join ctp_file natural join dicom_file natural join file_patient
where
  dicom_file_type = ''RT Structure Set Storage'' and visibility is null
  and project_name = ? and site_name = ?
order by project_name, site_name, patient_id', ARRAY['collection', 'site'], 
                    ARRAY['project_name', 'patient_id', 'site_name', 'sop_instance_uid'], ARRAY['Structure Sets', 'sops', 'LinkageChecks'], 'posda_files', 'Get Structure Set List

')
        ;

            insert into queries
            values ('GetPosdaDupSopCounts', 'select sop_instance_uid, num_files from (
select distinct sop_instance_uid, count(distinct file_id) as num_files from (
select
  distinct patient_id,
  study_instance_uid, 
  series_instance_uid, 
  sop_instance_uid,
  sop_class_uid,
  modality,
  dicom_file_type,
  root_path || ''/'' || rel_path as file_path,
  file_id
from
  ctp_file
  natural join dicom_file
  natural join file_patient
  natural join file_study
  natural join file_series
  natural join file_sop_common
  natural join file_location
  natural join file_storage_root
where
  project_name = ? 
  and visibility is null
) as foo group by sop_instance_uid
) as foo where num_files > 1', ARRAY['collection'], 
                    ARRAY['sop_instance_uid', 'num_files'], ARRAY['public_posda_counts'], 'posda_files', 'Generate a long list of all unhidden SOPs for a collection in posda<br>
<em>This can generate a long list</em>')
        ;

            insert into queries
            values ('DuplicateSopsInSeriesFast', 'select * from (
  select
    distinct sop_instance_uid, count(*) as num_sops
  from file_sop_common where file_id in (
    select distinct file_id
    from file_series natural join ctp_file 
    where series_instance_uid = ? and visibility is null
  ) group by sop_instance_uid
) as foo where num_sops > 1
', ARRAY['series_instance_uid'], 
                    ARRAY['sop_instance_uid', 'num_sops'], ARRAY['by_series', 'dup_sops', 'ACRIN-FMISO-Brain Duplicate Elimination'], 'posda_files', 'List of Actual duplicate SOPs (i.e. different files, same SOP)
in a series
')
        ;

            insert into queries
            values ('SeriesReportForStructLinkageTest', 'select
  file_id, (
    select root_path 
    from file_storage_root
    where file_storage_root.file_storage_root_id = file_location.file_storage_root_id
  ) || ''/'' || rel_path as file_name,
  sop_instance_uid, sop_class_uid,
  study_instance_uid, series_instance_uid,
  for_uid, iop, ipp
from
  file_location
  natural join file_series 
  natural join file_study
  natural join file_sop_common
  left join file_image_geometry using(file_id) 
  left join image_geometry using(image_geometry_id)
where file_id in (
  select file_id from file_series natural join ctp_file
  where series_instance_uid = ?
    and visibility is null
)', ARRAY['series_instance_uid'], 
                    ARRAY['file_id', 'file_name', 'sop_instance_uid', 'sop_class_uid', 'study_instance_uid', 'series_instance_uid', 'for_uid', 'iop', 'ipp'], ARRAY['by_series_instance_uid', 'duplicates', 'posda_files', 'sops', 'series_report'], 'posda_files', 'Get Distinct SOPs in Series with number files
Only visible filess
')
        ;

            insert into queries
            values ('DuplicateSopsInSeries', 'select
  sop_instance_uid, import_time, file_id
from 
  file_sop_common
  natural join file_import natural join import_event
where sop_instance_uid in (
select sop_instance_uid from (
select
  distinct sop_instance_uid, count(distinct file_id) 
from
  file_sop_common natural join file_series natural join ctp_file
where
  series_instance_uid = ? and visibility is null
group by sop_instance_uid
) as foo
where count > 1
)
order by sop_instance_uid, import_time
', ARRAY['series_instance_uid'], 
                    ARRAY['sop_instance_uid', 'import_time', 'file_id'], ARRAY['by_series', 'dup_sops', 'ACRIN-FMISO-Brain Duplicate Elimination'], 'posda_files', 'List of Actual duplicate SOPs (i.e. different files, same SOP)
in a series
')
        ;

            insert into queries
            values ('ListOfAvailableQueriesForDescEditBySchema', 'select
  name, description, query,
  array_to_string(tags, '','') as tags
from queries
where schema = ?
order by name', ARRAY['schema'], 
                    ARRAY['name', 'description', 'query', 'tags'], ARRAY['AllCollections', 'schema'], 'posda_queries', 'Get a list of available queries')
        ;

            insert into queries
            values ('EquivalenceClassStatusSummary', 'select 
  distinct patient_id, study_instance_uid, series_instance_uid,
  processing_status, count(*) 
from 
  image_equivalence_class natural join image_equivalence_class_input_image 
  natural join file_study natural join file_series natural join file_patient
group by 
  patient_id, study_instance_uid, series_instance_uid, processing_status
order by 
  patient_id, study_instance_uid, series_instance_uid, processing_status', '{}', 
                    ARRAY['patient_id', 'study_instance_uid', 'series_instance_uid', 'processing_status', 'count'], ARRAY['find_series', 'equivalence_classes', 'consistency', 'visual_review'], 'posda_files', 'Find Series with more than n equivalence class')
        ;

            insert into queries
            values ('ElementScanIdByScanValueTag', 'select 
  distinct scan_element_id
from
  scan_element natural join element_signature
  natural join series_scan natural join seen_value
  natural join scan_event
where
  scan_event_id = ? and
  value = ? and
  element_signature = ?
', ARRAY['scan_id', 'value', 'tag'], 
                    ARRAY['scan_element_id'], ARRAY['tag_usage'], 'posda_phi', 'Find out where specific value, tag combinations occur in a scan
')
        ;

            insert into queries
            values ('FinalizeDciodvfyScanInstance', 'update dciodvfy_scan_instance set
  end_time = now()
where
  dciodvfy_scan_instance_id = ?', ARRAY['dciodvfy_scan_instance_id'], 
                    '{}', ARRAY['NotInteractive', 'used_in_dciodvfy'], 'posda_phi_simple', 'Create a dciodvfy_scan_instance row')
        ;

            insert into queries
            values ('GetEditList', 'select * from dicom_edit_event', '{}', 
                    ARRAY['dicom_edit_event_id', 'from_dicom_file', 'to_dicom_file', 'edit_desc_file', 'when_done', 'performing_user'], ARRAY['ImageEdit'], 'posda_files', 'Get list of dicom_edit_event')
        ;

            insert into queries
            values ('GetUnkQualifiedCTQPByLikeCollectionSiteWithNoFiles', 'select 
  collection, site, patient_id, qualified
from
  clinical_trial_qualified_patient_id p
where collection like ? and site = ? and qualified is null and
  not exists (select file_id from file_patient f where f.patient_id = p.patient_id)
group by collection, site, patient_id, qualified', ARRAY['collection_like', 'site'], 
                    ARRAY['collection', 'site', 'patient_id', 'qualified'], ARRAY['clin_qual'], 'posda_files', 'Create An Activity Timepoint

')
        ;

            insert into queries
            values ('RoundSummary1DateRange', 'select
  distinct round_id,
  round_start, 
  round_end - round_start as duration, 
  round_end, 
  sum(num_entered + num_dups),
  ((round_end - round_start) / sum(num_entered + num_dups)) as sec_per_file
from
  round natural join round_collection
where
  round_end is not null and round_start > ? and round_end < ?
group by 
  round_id, round_start, duration, round_end 
order by round_id', ARRAY['from', 'to'], 
                    ARRAY['round_id', 'round_start', 'duration', 'round_end', 'sum', 'sec_per_file'], ARRAY['NotInteractive', 'Backlog', 'Backlog Monitor', 'backlog_analysis_reporting_tools'], 'posda_backlog', 'Summary of rounds')
        ;

            insert into queries
            values ('WhatHasComeInRecently', 'select
  distinct collection, site, date_trunc(?, time_received) as time,
  count(*) as number_of_files,
  max(time_entered - time_received) as max_delay,
  min(time_entered - time_received) as min_delay
from request natural join submitter
where time_received > ? and time_received < ?
group by collection, site, time order by time desc, collection, site', ARRAY['interval', 'from', 'to'], 
                    ARRAY['collection', 'site', 'time', 'number_of_files', 'max_delay', 'min_delay'], ARRAY['NotInteractive', 'Backlog', 'Backlog Monitor', 'backlog_round_history', 'for_bill_counts'], 'posda_backlog', 'A query to tell you what has been recently received:<ul>
  <li>interval = ''year'' | ''month'' | ''week'' | ''day'' | ''hour'' | ''minute'' | ''sec''</li>
  <li>from = start date/time (midnight if time not included)</li>
  <li>to = end date/time (midnight if time not included)</li>
</ul>')
        ;

            insert into queries
            values ('FileNamesBySeriesAndImportId', 'select file_id, file_name
from file_import natural join import_event natural join file_series
where import_event_id = ? and series_instance_uid = ?', ARRAY['import_event_id', 'series_instance_uid'], 
                    ARRAY['file_id', 'file_name'], ARRAY['downloads_by_date', 'import_events', 'QIN-GBM-DSC-MRI-DRO/Barrow'], 'posda_files', 'Counts query by Collection, Site
')
        ;

            insert into queries
            values ('FilesByScanValueTag', 'select
  distinct series_instance_uid,
  series_scanned_file as file, 
  element_signature, value, sequence_level,
  item_number
from
  scan_event natural join series_scan natural join seen_value
  natural join element_signature natural join 
  scan_element natural left join sequence_index
where
  scan_event_id = ? and value = ? and element_signature = ?
order by series_instance_uid, file
', ARRAY['scan_id', 'value', 'tag'], 
                    ARRAY['series_instance_uid', 'file', 'element_signature', 'value', 'sequence_level', 'item_number'], ARRAY['tag_usage', 'phi_review'], 'posda_phi', 'Find out where specific value, tag combinations occur in a scan
')
        ;

            insert into queries
            values ('InboxContentAllByUser', 'select
 user_name, user_inbox_content_id as id, operation_name,
  current_status,
  activity_id, brief_description,
  when_script_started as when, 
  file_id, subprocess_invocation_id as sub_id,
  command_line,
  file_id_in_posda as spreadsheet_file_id
from 
  user_inbox natural join
  user_inbox_content natural join background_subprocess_report
  natural join background_subprocess natural left join subprocess_invocation
  natural left join spreadsheet_uploaded
  natural left join activity_inbox_content natural left join
  activity
where user_name = ?
order by user_inbox_content_id desc', ARRAY['user_name'], 
                    ARRAY['user_name', 'id', 'operation_name', 'current_status', 'activity_id', 'brief_description', 'when', 'file_id', 'command_line', 'spreadsheet_file_id'], ARRAY['AllCollections', 'queries', 'activity_support'], 'posda_queries', 'Get a list of available queries')
        ;

            insert into queries
            values ('NewSopsReceivedBetweenDatesByCollection', 'select
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
', ARRAY['start_time', 'end_time', 'collection'], 
                    ARRAY['project_name', 'site_name', 'patient_id', 'study_instance_uid', 'series_instance_uid', 'num_sops', 'first_loaded', 'last_loaded'], ARRAY['receive_reports'], 'posda_files', 'Series received between dates with sops without duplicates
')
        ;

            insert into queries
            values ('PatientStudySeriesHierarchyByCollectionNotMatchingSeriesDesc', 'select distinct
  patient_id,
  study_instance_uid,
  series_instance_uid
from
  file_study natural join ctp_file natural join file_series natural join file_patient
where 
  file_id in (
    select distinct file_id
    from ctp_file natural join file_series
    where project_name = ? and visibility is null and series_description not like ?
  )
order by patient_id, study_instance_uid, series_instance_uid', ARRAY['collection', 'exclude_series_descriptions_matching'], 
                    ARRAY['patient_id', 'study_instance_uid', 'series_instance_uid'], ARRAY['Hierarchy'], 'posda_files', 'Construct list of series in a collection in a Patient, Study, Series Hierarchy excluding matching SeriesDescriptons')
        ;

            insert into queries
            values ('SummaryOfMultipleFileImportEventsWithEarliestLatestEtc', 'select 
  distinct import_type,
  min(import_time) as earliest,
  max(import_time) as latest,
  count(distinct import_event_id) as num_imports,
  sum(num_files) as total_files
from (
  select
    distinct import_event_id,
    import_time, import_type,
    import_comment,
    count(distinct file_id) as num_files
  from
    import_event natural join file_import
  group by import_event_id, import_time, import_type, import_comment
) as foo
where num_files > 1 group by import_type', '{}', 
                    ARRAY['import_type', 'earliest', 'latest', 'num_imports', 'total_files'], ARRAY['downloads_by_date', 'import_events'], 'posda_files', 'Counts query by Collection, Site
')
        ;

            insert into queries
            values ('DuplicateSopsInSeriesNew', 'select
  sop_instance_uid, date_trunc(''day'',import_time) as import_day, file_id
from 
  file_sop_common
  natural join file_import natural join import_event
where sop_instance_uid in (
select sop_instance_uid from (
select
  distinct sop_instance_uid, count(distinct file_id) 
from
  file_sop_common natural join file_series natural join ctp_file
where
  series_instance_uid = ? and visibility is null
group by sop_instance_uid
) as foo
where count > 1
)
order by sop_instance_uid, import_day, file_id
', ARRAY['series_instance_uid'], 
                    ARRAY['sop_instance_uid', 'import_day', 'file_id'], ARRAY['by_series', 'dup_sops', 'ACRIN-FMISO-Brain Duplicate Elimination'], 'posda_files', 'List of Actual duplicate SOPs (i.e. different files, same SOP)
in a series
')
        ;

            insert into queries
            values ('UpdateElementDisposition', 'update element_signature set 
  private_disposition = ?,
  name_chain = ?
where
  element_signature = ? and
  vr = ?
', ARRAY['private_disposition', 'name_chain', 'element_signature', 'vr'], 
                    '{}', ARRAY['NotInteractive', 'Update', 'ElementDisposition'], 'posda_phi', 'Update Element Disposition
For use in scripts
Not really intended for interactive use
')
        ;

            insert into queries
            values ('InsertDistinguishedDigest', 'insert into distinguished_pixel_digests(
  pixel_digest,
  type_of_pixel_data,
  sample_per_pixel,
  number_of_frames,
  pixel_rows,
  pixel_columns,
  bits_stored,
  bits_allocated,
  high_bit,
  pixel_mask,
  num_distinct_pixel_values) values (
  ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?
);', ARRAY['pixel_digest', 'type_of_pixel_data', 'sample_per_pixel', 'number_of_frames', 'pixel_rows', 'pixel_columns', 'bits_stored', 'bits_allocated', 'high_bit', 'pixel_mask', 'num_distinct_pixel_values'], 
                    '{}', ARRAY['duplicates', 'distinguished_digest'], 'posda_files', 'insert distinguished pixel digest')
        ;

            insert into queries
            values ('GetDoses', 'select
  distinct project_name as collection,
  site_name as site,
  patient_id,
  series_instance_uid,
  file_id
from
  file_series natural join
  file_patient natural join ctp_file
where
  project_name = ? and
  visibility is null and
  file_id in (
select distinct file_id from rt_dose d natural join file_dose)', ARRAY['collection'], 
                    ARRAY['collection', 'site', 'patient_id', 'series_instance_uid', 'file_id'], ARRAY['Structure Sets', 'sops', 'LinkageChecks', 'dose_linkages'], 'posda_files', 'Get list of plan which reference unknown SOPs

')
        ;

            insert into queries
            values ('GetUnreadInboxItems', 'select
  user_inbox_content_id,
  background_subprocess_report_id,
  current_status,
  date_entered
from user_inbox_content 
natural join user_inbox 
where date_dismissed is null
  and user_name = ?
', ARRAY['user_name'], 
                    ARRAY['user_inbox_content_id', 'background_subprocess_report_id', 'current_status', 'date_entered'], '{}', 'posda_queries', 'Get a list of unread messages from the user''s inbox.')
        ;

            insert into queries
            values ('StopTransaction', 'commit', '{}', 
                    '{}', ARRAY['NotInteractive', 'used_in_dciodvfy'], 'posda_phi_simple', 'Create a dciodvfy_scan_instance row')
        ;

            insert into queries
            values ('FindInconsistentStudyIgnoringStudyTimeByCollectionSite', 'select distinct study_instance_uid from (
  select distinct study_instance_uid, count(*) from (
    select distinct
      study_instance_uid, study_date,
      referring_phy_name, study_id, accession_number,
      study_description, phys_of_record, phys_reading,
      admitting_diag
    from
      file_study natural join ctp_file
    where
      project_name = ? and site_name = ? and visibility is null
    group by
      study_instance_uid, study_date,
      referring_phy_name, study_id, accession_number,
      study_description, phys_of_record, phys_reading,
      admitting_diag
  ) as foo
  group by study_instance_uid
) as foo
where count > 1
', ARRAY['collection', 'site'], 
                    ARRAY['study_instance_uid'], ARRAY['by_study', 'consistency', 'study_consistency'], 'posda_files', 'Find Inconsistent Studies
')
        ;

            insert into queries
            values ('AddHocQuery1', 'select 
  distinct project_name as collection, site_name as site, patient_id,
  study_instance_uid, series_instance_uid, dicom_file_type, modality,
  count(distinct file_id) as num_files, count(distinct sop_instance_uid) as num_sops,
  min(import_time) as earliest, max(import_time) as latest
from
  ctp_file natural join file_patient natural join dicom_file natural join file_series natural join
  file_sop_common natural join
  file_study join file_import using(file_id) join import_event using (import_event_id)
where file_id in(
  select distinct file_id from file_patient where patient_id = ''ER-1125''
) and visibility is null 
group by collection, site, patient_id, study_instance_uid, series_instance_uid, dicom_file_type, modality', '{}', 
                    ARRAY['collection', 'site', 'patient_id', 'study_instance_uid', 'series_instance_uid', 'dicom_file_type', 'modality', 'num_files', 'num_sops', 'earliest', 'latest'], ARRAY['meta', 'test', 'hello', 'bills_test'], 'posda_files', 'Add a filter to a tab')
        ;

            insert into queries
            values ('PosdaTotalsWithHidden', 'select 
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
', '{}', 
                    ARRAY['project_name', 'site_name', 'num_subjects', 'num_studies', 'num_series', 'total_files'], '{}', 'posda_files', 'Get total posda files including hidden
')
        ;

            insert into queries
            values ('GetSeriesWithImageByCollection', 'select distinct
  project_name as collection, site_name as site,
  patient_id, modality, series_instance_uid, 
  count(distinct sop_instance_uid) as num_sops,
  count(distinct file_id) as num_files
from
  file_series natural join file_sop_common
  natural join file_patient
  natural join file_image natural join ctp_file
  natural join file_import natural join import_event
where project_name = ? and visibility is null
group by
  collection, site, patient_id, modality, series_instance_uid
', ARRAY['collection'], 
                    ARRAY['collection', 'site', 'patient_id', 'modality', 'series_instance_uid', 'num_sops', 'num_files'], ARRAY['signature', 'phi_review', 'visual_review'], 'posda_files', 'Get a list of Series with images by CollectionSite
')
        ;

            insert into queries
            values ('AllManifests', 'select
  distinct file_id, import_time, size, root_path || ''/'' || l.rel_path as path, i.file_name as alt_path
from
  file_location l join file_storage_root using(file_storage_root_id) 
  join file_import i using (file_id) natural join file join import_event using(import_event_id)
where
  file_type like ''%ASCII%'' and
  l.rel_path like ''%/Manifests/%''
order by import_time', '{}', 
                    ARRAY['file_id', 'import_time', 'size', 'path', 'alt_path'], ARRAY['activity_timepoint_support', 'manifests'], 'posda_files', 'Create An Activity Timepoint

')
        ;

            insert into queries
            values ('ListOfAvailableQueriesBySchema', 'select
  name, description,
  array_to_string(tags, '','') as tags
from queries
where schema = ?
order by name', ARRAY['schema'], 
                    ARRAY['name', 'description', 'tags'], ARRAY['AllCollections', 'schema'], 'posda_queries', 'Get a list of available queries')
        ;

            insert into queries
            values ('GetGeometricInfoPublic', 'select
  sop_instance_uid, image_orientation_patient, image_position_patient,
  pixel_spacing, i_rows, i_columns
from
  general_image
where
  sop_instance_uid = ?
', ARRAY['sop_instance_uid'], 
                    ARRAY['sop_instance_uid', 'image_orientation_patient', 'image_position_patient', 'pixel_spacing', 'i_rows', 'i_columns'], ARRAY['LinkageChecks', 'BySopInstance'], 'public', 'Get Geometric Information by Sop Instance UID from public')
        ;

            insert into queries
            values ('PatientReportDateRange', 'select
  distinct project_name as collection,
  site_name as site,
  patient_id, study_instance_uid, study_description,
  series_instance_uid, series_description,
  count(distinct file_id) as num_files,
  min(import_time) as earliest_upload,
  max(import_time) as latest_upload,
  count(distinct import_event_id) as num_uploads
from
  file_patient natural join file_study natural join
  file_series natural join ctp_file natural join
  file_import natural join import_event
where
  project_name = ? and
  site_name = ? and
  patient_id = ? and
  import_time > ? and
  import_time < ? and
  visibility is null
group by 
  collection, site,
  patient_id, study_instance_uid, study_description,
  series_instance_uid, series_description
order by
  study_instance_uid, series_instance_uid, num_files', ARRAY['collection', 'site', 'patient_id', 'start_time', 'end_time'], 
                    ARRAY['collection', 'site', 'patient_id', 'study_instance_uid', 'study_description', 'series_instance_uid', 'series_description', 'num_files', 'earliest_upload', 'latest_upload', 'num_uploads'], ARRAY['meta', 'test', 'hello', 'bills_test'], 'posda_files', 'Add a filter to a tab')
        ;

            insert into queries
            values ('InsertIntoSiteCodes', 'insert into site_codes(site_name, site_code)
values (?, ?)', ARRAY['site_name', 'site_code'], 
                    '{}', ARRAY['adding_ctp', 'mapping_tables', 'for_scripting'], 'posda_files', 'Make an entry into the site_codes table')
        ;

            insert into queries
            values ('DupSopsReceivedBetweenDates', 'select
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
', ARRAY['start_time', 'end_time'], 
                    ARRAY['project_name', 'site_name', 'patient_id', 'study_instance_uid', 'series_instance_uid', 'num_sops', 'num_files', 'num_uploads', 'first_loaded', 'last_loaded'], ARRAY['receive_reports'], 'posda_files', 'Series received between dates with duplicate sops
')
        ;

            insert into queries
            values ('UpdateDicomEditCompareDisposition', 'update dicom_edit_compare_disposition set
  number_edits_scheduled = ?,
  number_compares_with_diffs = ?,
  number_compares_without_diffs = ?,
  current_disposition = ''Comparisons In Progress'',
  last_updated = now()
where
  subprocess_invocation_id = ?
', ARRAY['number_edits_scheduled', 'number_compares_with_diffs', 'number_compares_without_diffs', 'subprocess_invocation_id'], 
                    '{}', ARRAY['adding_ctp', 'for_scripting'], 'posda_files', 'Update an entry in dicom_edit_compare_disposition

From script only.  Don''t run from user interface (needs valid subprocess_invocation_id)')
        ;

            insert into queries
            values ('InsertFileStudy', 'insert into file_study(
  file_id, study_instance_uid, study_date,
  study_time, referring_phy_name, study_id,
  accession_number, study_description, phys_of_record,
  phys_reading, admitting_diag
) values (
  ?, ?, ?,
  ?, ?, ?,
  ?, ?, ?,
  ?, ?
)', ARRAY['file_id', 'study_instance_uid', 'study_date', 'study_time', 'referring_phy_name', 'study_id', 'accession_number', 'study_description', 'phys_of_record', 'phys_reading', 'admitting_diag'], 
                    '{}', ARRAY['bills_test', 'posda_db_populate'], 'posda_queries', 'Add a filter to a tab')
        ;

            insert into queries
            values ('DismissActivityTaskStatus', 'update activity_task_status set
  dismissed_time = now(),
  dismissed_by = ?
where
  activity_id = ? and
  subprocess_invocation_id = ?', ARRAY['dismissed_by', 'activity_id', 'subprocess_invocation_id'], 
                    '{}', ARRAY['NotInteractive', 'Update'], 'posda_files', 'Update status_text and expected_completion_time in activity_task_status
For use in scripts
Not really intended for interactive use
')
        ;

            insert into queries
            values ('GetSimpleElementSeenIndex', 'select currval(''element_seen_element_seen_id_seq'') as id', '{}', 
                    ARRAY['id'], ARRAY['used_in_simple_phi', 'NotInteractive'], 'posda_phi_simple', 'Get index of newly created element_seen')
        ;

            insert into queries
            values ('SimplePhiReportAllPublicOnly', 'select 
  distinct ''<'' || element_sig_pattern || ''>''  as element, length(value) as val_length,
  vr, value, tag_name as description, count(*) as num_series
from element_value_occurance natural join element_seen natural join value_seen
where 
  phi_scan_instance_id = ? and not is_private
group by element_sig_pattern, vr, value, val_length, description
order by vr, element, val_length', ARRAY['scan_id'], 
                    ARRAY['element', 'vr', 'value', 'description', 'num_series'], ARRAY['tag_usage', 'simple_phi'], 'posda_phi_simple', 'Status of PHI scans
')
        ;

            insert into queries
            values ('GetPublicFeaturesBySignature', 'select
  name, vr
from dicom_element
where tag = ?', ARRAY['element_signature'], 
                    ARRAY['name', 'vr'], ARRAY['UsedInPhiSeriesScan', 'NotInteractive', 'ElementDisposition'], 'dicom_dd', 'Get Element Signature By Signature (pattern) and VR')
        ;

            insert into queries
            values ('GetVisualReviewStatusCountsById', 'select 
  distinct review_status, count(distinct series_instance_uid) as num_series
from
  image_equivalence_class
where
  visual_review_instance_id = ?
group by review_status', ARRAY['visual_review_instance_id'], 
                    ARRAY['review_status', 'num_series'], ARRAY['signature', 'phi_review', 'visual_review', 'visual_review_new_workflow'], 'posda_files', 'Get a list of Series By Visual Review Id and Status
')
        ;

            insert into queries
            values ('GetCountFilesToImportFromEdit', 'select
  count(*) as num_files
from
  dicom_edit_compare
where 
  from_file_digest in 
  (
    select from_file_digest from 
    (
      select distinct from_file_digest 
      from dicom_edit_compare dec, file f natural join ctp_file
      where dec.from_file_digest = f.digest and visibility is null and subprocess_invocation_id = ?
      intersect
      select from_file_digest from dicom_edit_compare dec
      where not exists
      (
        select file_id from file f where dec.to_file_digest = f.digest
       ) 
       and subprocess_invocation_id = ?
    ) as foo
  )
  and subprocess_invocation_id = ?
', ARRAY['command_file_id', 'command_file_id_1', 'command_file_id_2'], 
                    ARRAY['num_files'], ARRAY['used_in_file_import_into_posda', 'used_in_file_migration'], 'posda_files', 'Get count of files relative to storage root')
        ;

            insert into queries
            values ('AllVisibleSubjectsByCollection', 'select
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
', ARRAY['collection'], 
                    ARRAY['patient_id', 'status', 'project_name', 'site_name', 'num_files'], ARRAY['FindSubjects', 'PatientStatus'], 'posda_files', 'Find All Subjects which have at least one visible file
')
        ;

            insert into queries
            values ('DistinctFileReportByCollectionSite', 'select distinct
  project_name as collection, site_name as site, patient_id, study_instance_uid,
  series_instance_uid, sop_instance_uid, dicom_file_type, modality, file_id, visibility
from
  file_patient natural join file_study natural join file_series natural join file_sop_common
  natural join dicom_file natural join ctp_file
where
  project_name = ? and site_name = ?
order by series_instance_uid', ARRAY['project_name', 'site_name'], 
                    ARRAY['collection', 'site', 'patient_id', 'study_instance_uid', 'series_instance_uid', 'sop_instance_uid', 'dicom_file_type', 'modality', 'file_id', 'visibility'], ARRAY['by_collection', 'find_series', 'compare_collection_site', 'search_series', 'edit_files', 'simple_phi', 'dciodvfy', 'ctp_details', 'select_for_phi', 'visual_review_selection'], 'posda_files', 'Get Series in A Collection, site with dicom_file_type, modality, and sop_count
')
        ;

            insert into queries
            values ('FindInconsistentStudyIgnoringStudyTimeIncludingPatientId', 'select distinct study_instance_uid from (
  select distinct study_instance_uid, count(*) from (
    select distinct
      patient_id, study_instance_uid, study_date,
      referring_phy_name, study_id, accession_number,
      study_description, phys_of_record, phys_reading,
      admitting_diag
    from
      file_study natural join file_patient natural join ctp_file
    where
      project_name = ? and visibility is null
    group by
      patient_id, study_instance_uid, study_date,
      referring_phy_name, study_id, accession_number,
      study_description, phys_of_record, phys_reading,
      admitting_diag
  ) as foo
  group by study_instance_uid
) as foo
where count > 1
', ARRAY['collection'], 
                    ARRAY['study_instance_uid'], ARRAY['by_study', 'consistency', 'study_consistency'], 'posda_files', 'Find Inconsistent Studies
')
        ;

            insert into queries
            values ('GetPosdaSopsForCompareCollectionLike', 'select
  distinct patient_id,
  study_instance_uid, 
  series_instance_uid, 
  sop_instance_uid,
  sop_class_uid,
  modality,
  dicom_file_type,
  root_path || ''/'' || rel_path as file_path,
  file_id
from
  ctp_file
  natural join dicom_file
  natural join file_patient
  natural join file_study
  natural join file_series
  natural join file_sop_common
  natural join file_location
  natural join file_storage_root
where
  project_name like ? 
  and visibility is null', ARRAY['collection'], 
                    ARRAY['patient_id', 'study_instance_uid', 'series_instance_uid', 'sop_instance_uid', 'sop_class_uid', 'modality', 'dicom_file_type', 'file_path', 'file_id'], ARRAY['public_posda_counts'], 'posda_files', 'Generate a long list of all unhidden SOPs for a collection in posda<br>
<em>This can generate a long list</em>')
        ;

            insert into queries
            values ('PatientStatusChange', 'select
  patient_id, old_pat_status as from,
  new_pat_status as to, pat_stat_change_who as by,
  pat_stat_change_why as why,
  when_pat_stat_changed as when
from patient_import_status_change
where patient_id in(
  select distinct patient_id
  from file_patient natural join ctp_file
  where visibility is null
)
order by patient_id, when_pat_stat_changed
', '{}', 
                    ARRAY['patient_id', 'from', 'to', 'by', 'why', 'when'], ARRAY['PatientStatus'], 'posda_files', 'Get History of Patient Status Changes by Collection
')
        ;

            insert into queries
            values ('SeriesListBySubjectNameByDateRange', 'select
  distinct project_name as collection,
  site_name as site,
  patient_id,
  study_instance_uid,
  study_date,
  study_description,
  series_instance_uid,
  series_date,
  series_description,
  modality, 
  dicom_file_type, 
  count(distinct file_id) as num_files
from 
  file_patient natural join
  file_series natural join
  file_study natural join
  dicom_file natural join
  ctp_file join file_import using(file_id)
  join import_event using(import_event_id)
where 
  patient_id = ?
  and visibility is null
  and import_time > ? 
  and import_time < ?
group by 
  collection,
  site,
  patient_id,
  study_instance_uid,
  study_date,
  study_description,
  series_instance_uid,
  series_date,
  series_description,
  modality,
  dicom_file_type;', ARRAY['patient_id', 'from', 'to'], 
                    ARRAY['collection', 'site', 'patient_id', 'study_instance_uid', 'study_date', 'study_description', 'series_instance_uid', 'series_date', 'series_description', 'modality', 'dicom_file_type', 'num_files'], ARRAY['find_series', 'for_tracy', 'backlog_round_history'], 'posda_files', 'Get List of Series by Subject Name')
        ;

            insert into queries
            values ('CtpFilesSummary', 'select
 distinct project_name as collection,
 trial_name,
 site_name as site,
 site_id,
 visibility,
 count(distinct file_id) as num_files
from ctp_file
group by 
  collection,
  trial_name,
  site,
  site_id,
  visibility
order by
  collection, trial_name, site, site_id, visibility', '{}', 
                    ARRAY['collection', 'trial_name', 'site', 'site_id', 'visibility', 'num_files'], ARRAY['adding_ctp'], 'posda_files', 'Get Series in A Collection
')
        ;

            insert into queries
            values ('GetContoursFromRoiId', 'select
  roi_contour_id, contour_num, geometric_type, 
  number_of_points, sop_class as linked_image_sop_class,
  sop_instance as linked_image_sop_instance, 
  frame_number as linked_image_frame_number
from
  roi_contour natural left join contour_image
where roi_id = ?', ARRAY['roi_id'], 
                    ARRAY['roi_contour_id', 'contour_num', 'geometric_type', 'number_of_points', 'linked_image_sop_class', 'linked_image_sop_instance', 'linked_image_frame_number'], ARRAY['Structure Sets', 'sops', 'LinkageChecks'], 'posda_files', 'Get List of ROI''s in a structure Set

')
        ;

            insert into queries
            values ('PatientStatusChangeByPatient', 'select
  patient_id, old_pat_status as from,
  new_pat_status as to, pat_stat_change_who as by,
  pat_stat_change_why as why,
  when_pat_stat_changed as when
from patient_import_status_change
where patient_id = ?
order by when
', ARRAY['patient_id'], 
                    ARRAY['patient_id', 'from', 'to', 'by', 'why', 'when'], ARRAY['PatientStatus'], 'posda_files', 'Get History of Patient Status Changes by Patient Id
')
        ;

            insert into queries
            values ('ImageIdByFileId', 'select
  distinct file_id, image_id
from
  file_image
where
  file_id = ?
', ARRAY['file_id'], 
                    ARRAY['file_id', 'image_id'], ARRAY['by_file_id', 'image_id', 'posda_files'], 'posda_files', 'Get image_id for file_id 
')
        ;

            insert into queries
            values ('DuplicatePixelDataThatMatters', 'select image_id, count from (
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
', ARRAY['collection'], 
                    ARRAY['image_id', 'count'], ARRAY['pixel_duplicates'], 'posda_files', 'Return a list of files with duplicate pixel data,
restricted to those files which have parsed DICOM data
representations in Database.
')
        ;

            insert into queries
            values ('TableSizePosdaFiles', 'select *, pg_size_pretty(total_bytes) AS total
    , pg_size_pretty(index_bytes) AS INDEX
    , pg_size_pretty(toast_bytes) AS toast
    , pg_size_pretty(table_bytes) AS TABLE
  FROM (
  SELECT *, total_bytes-index_bytes-COALESCE(toast_bytes,0) AS table_bytes FROM (
      SELECT c.oid,nspname AS table_schema, relname AS TABLE_NAME
              , c.reltuples AS row_estimate
              , pg_total_relation_size(c.oid) AS total_bytes
              , pg_indexes_size(c.oid) AS index_bytes
              , pg_total_relation_size(reltoastrelid) AS toast_bytes
          FROM pg_class c
          LEFT JOIN pg_namespace n ON n.oid = c.relnamespace
          WHERE relkind = ''r''
  ) a
) a where
  table_schema = ''public'' or table_schema = ''dbif_config'' or table_schema = ''dicom_conv''
order by total_bytes desc', '{}', 
                    ARRAY['oid', 'table_schema', 'table_name', 'row_estimate', 'total_bytes', 'index_bytes', 'total', 'toast_bytes', 'index', 'toast', 'table'], ARRAY['AllCollections', 'postgres_stats', 'table_size'], 'posda_files', 'Get a list of collections and sites
')
        ;

            insert into queries
            values ('LockDicomEditCompareDisposition', 'lock dicom_edit_compare_disposition
', '{}', 
                    '{}', ARRAY['adding_ctp', 'for_scripting'], 'posda_files', 'Lock table dicom_edit_compare_disposition

From script only.  Don''t run from user interface.')
        ;

            insert into queries
            values ('TagsSeenSimplePrivate', 'select
  element_sig_pattern, vr, private_disposition, tag_name
from
  element_seen
where
  is_private
order by element_sig_pattern', '{}', 
                    ARRAY['element_sig_pattern', 'vr', 'private_disposition', 'tag_name'], ARRAY['by_collection', 'find_series', 'compare_collection_site', 'search_series', 'edit_files', 'phi_maint'], 'posda_phi_simple', 'Get all the data from tags_seen in posda_phi_simple database
')
        ;

            insert into queries
            values ('DistinctFilesByTagAndValue', 'select
  distinct series_instance_uid,
  series_scanned_file as file, 
  element_signature
from
  scan_event natural join series_scan natural join seen_value
  natural join element_signature natural join 
  scan_element natural left join sequence_index
where
  element_signature = ? and value = ?
order by series_instance_uid, file
', ARRAY['tag', 'value'], 
                    ARRAY['series_instance_uid', 'file', 'element_signature'], ARRAY['tag_usage'], 'posda_phi', 'Find out where specific value, tag combinations occur in a scan
')
        ;

            insert into queries
            values ('GetSeriesWithOutImageByCollectionSite', 'select distinct
  project_name as collection, site_name as site,
  patient_id, modality, series_instance_uid, 
  count(distinct sop_instance_uid) as num_sops,
  count(distinct file_id) as num_files
from
  file_series
  natural join file_sop_common
  natural join file_patient
  natural join ctp_file ctp
  natural join file_import natural join import_event
where project_name = ? and site_name = ? and visibility is null
  and not exists (select image_id from file_image fi where ctp.file_id = fi.file_id)
group by
  collection, site, patient_id, modality, series_instance_uid
', ARRAY['collection', 'site'], 
                    ARRAY['collection', 'site', 'patient_id', 'modality', 'series_instance_uid', 'num_sops', 'num_files'], ARRAY['signature', 'phi_review', 'visual_review'], 'posda_files', 'Get a list of Series with images by CollectionSite
')
        ;

            insert into queries
            values ('GetSsVolumeReferencingKnownImages', 'select 
  project_name as collection, 
  site_name as site, patient_id, 
  file_id 
from 
  ctp_file natural join file_patient 
where file_id in (
   select
    distinct file_id from ss_volume v 
    join ss_for using(ss_for_id) 
    join file_structure_set using (structure_set_id) 
  where 
     exists (
       select file_id 
       from file_sop_common s 
       where s.sop_instance_uid = v.sop_instance
  )
)
order by collection, site, patient_id', '{}', 
                    ARRAY['collection', 'site', 'patient_id', 'file_id'], ARRAY['Structure Sets', 'sops', 'LinkageChecks', 'struct_linkages'], 'posda_files', 'Get list of plan which reference unknown SOPs

')
        ;

            insert into queries
            values ('FilesWithNoCtpByPatientId', 'select
  distinct file_id
from
  file_patient p
where
  not exists(
  select file_id from ctp_file c
  where c.file_id = p.file_id
)
and patient_id = ?
', ARRAY['patient_id'], 
                    ARRAY['file_id'], ARRAY['adding_ctp'], 'posda_files', 'Get Series in A Collection
')
        ;

            insert into queries
            values ('WhereSopSitsIntake', 'select distinct
  tdp.project as collection,
  tdp.dp_site_name as site,
  p.patient_id,
  i.study_instance_uid,
  i.series_instance_uid
from
  general_image i,
  patient p,
  trial_data_provenance tdp
where
  sop_instance_uid = ?
  and i.patient_pk_id = p.patient_pk_id
  and i.trial_dp_pk_id = tdp.trial_dp_pk_id
', ARRAY['sop_instance_uid'], 
                    ARRAY['collection', 'site', 'patient_id', 'study_instance_uid', 'series_instance_uid'], ARRAY['posda_files', 'sops', 'BySopInstance'], 'intake', 'Get Collection, Patient, Study Hierarchy in which SOP resides
')
        ;

            insert into queries
            values ('DistinctSeriesBySubjectIntake', 'select
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
', ARRAY['subject_id', 'project_name', 'site_name'], 
                    ARRAY['series_instance_uid', 'modality', 'num_images'], ARRAY['by_subject', 'find_series', 'intake'], 'intake', 'Get Series in A Collection, Site, Subject
')
        ;

            insert into queries
            values ('SopsDupsInDifferentSeriesByCollectionSite', 'select
  distinct collection, site, subj_id, study_instance_uid, series_instance_uid, sop_instance_uid,
  file_id, file_path
from (
  select
    distinct project_name as collection,
    site_name as site, patient_id as subj_id,
    study_instance_uid, series_instance_uid,
    sop_instance_uid,
    file_id, root_path ||''/'' || rel_path as file_path
  from
    ctp_file natural join file_sop_common
    natural join file_patient natural join file_study natural join file_series
    join file_location using(file_id) join file_storage_root using(file_storage_root_id)
  where
    sop_instance_uid in (
      select distinct sop_instance_uid from (
        select distinct sop_instance_uid, count(distinct file_id) from (
          select distinct file_id, sop_instance_uid 
          from
            ctp_file natural join file_sop_common
            natural join file_patient
          where
            visibility is null and project_name = ? and site_name = ?
        ) as foo group by sop_instance_uid order by count desc
      ) as foo 
      where count > 1
    )
    and visibility is null
  ) as foo
order by sop_instance_uid

', ARRAY['collection', 'site'], 
                    ARRAY['collection', 'site', 'subj_id', 'study_instance_uid', 'series_instance_uid', 'sop_instance_uid', 'file_id', 'file_path'], ARRAY['duplicates', 'dup_sops', 'hide_dup_sops', 'sops_different_series'], 'posda_files', 'Return a count of duplicate SOP Instance UIDs
')
        ;

            insert into queries
            values ('ImportIntoFileStudy', 'insert into file_study
  (file_id, study_instance_uid, study_date,
   study_time, referring_phy_name, study_id,
   accession_number, study_description, phys_of_record,
   phys_reading, admitting_diag)
values
  (?, ?, ?,
   ?, ?, ?,
   ?, ?, ?,
   ?, ?)
', ARRAY['file_id', 'study_instance_uid', 'study_date', 'study_time', 'referring_phy_name', 'study_id', 'accession_number', 'study_description', 'phys_of_record', 'phys_reading', 'admitting_diag'], 
                    '{}', ARRAY['reimport_queries'], 'posda_files', 'Get file path from id')
        ;

            insert into queries
            values ('GetUnreadInboxCount', 'select count(*) as count
from user_inbox_content 
natural join user_inbox 
where date_dismissed is null
  and user_name = ?
', ARRAY['user_name'], 
                    ARRAY['count'], '{}', 'posda_queries', 'Get a count of unread messages from the user''s inbox.')
        ;

            insert into queries
            values ('InboxContentAll', 'select
 user_name, user_inbox_content_id as id, operation_name,
  current_status,
  activity_id, brief_description,
  when_script_started as when, 
  file_id, subprocess_invocation_id as sub_id,
  command_line,
  file_id_in_posda as spreadsheet_file_id
from 
  user_inbox natural join
  user_inbox_content natural join background_subprocess_report
  natural join background_subprocess natural left join subprocess_invocation
  natural left join spreadsheet_uploaded
  natural left join activity_inbox_content natural left join
  activity 
order by user_inbox_content_id desc', '{}', 
                    ARRAY['user_name', 'id', 'operation_name', 'current_status', 'activity_id', 'brief_description', 'when', 'file_id', 'command_line', 'spreadsheet_file_id'], ARRAY['AllCollections', 'queries', 'activity_support'], 'posda_queries', 'Get a list of available queries')
        ;

            insert into queries
            values ('StorageRootIdById', 'select root_path from file_storage_root where
file_storage_root_id = ?', ARRAY['file_storage_root_id'], 
                    ARRAY['root_path'], ARRAY['used_in_file_import_into_posda', 'used_in_file_migration'], 'posda_files', 'Get root_path for a file_storage_root
')
        ;

            insert into queries
            values ('UpdateFileIsPresent', 'update file_location set file_is_present = true where file_is_present is null', '{}', 
                    '{}', ARRAY['adding_pixels_to_dicom_file'], 'posda_files', 'Default file_is_present to true')
        ;

            insert into queries
            values ('DciodvfyErrorsStringByErrorId', 'select                                                    
  dciodvfy_error_id || ''|'' ||
  error_type || ''|'' ||                                                                                                                                                                                                                   
  coalesce(error_tag, ''[null]'') || ''|'' ||
  coalesce(error_value, ''[null]'') || ''|'' ||
  coalesce(error_subtype, ''[null]'') || ''|'' ||
  coalesce(error_module, ''[null]'') || ''|'' ||
  coalesce(error_reason, ''[null]'') || ''|'' ||
  coalesce(error_index, ''[null]'') || ''|'' ||
  coalesce(error_text, ''[null]'') as error_string
from dciodvfy_error 
where  dciodvfy_error_id = ?', ARRAY['dciodvfy_error_id'], 
                    ARRAY['error_string'], ARRAY['tag_usage', 'dciodvfy'], 'posda_phi_simple', 'Show all the dciodvfy scans')
        ;

            insert into queries
            values ('GetVisibleFilesByEquivalenceClass', 'select
  file_id, visibility
from ctp_file
where visibility is null and file_id in (
  select
    file_id
  from
    image_equivalence_class natural join image_equivalence_class_input_image
  where
    image_equivalence_class_id = ?
)', ARRAY['image_equivalence_class_id'], 
                    ARRAY['file_id', 'visibility'], ARRAY['signature', 'phi_review', 'visual_review', 'visual_review_new_workflow'], 'posda_files', 'Get a list of files which are hidden by series id and visual review id')
        ;

            insert into queries
            values ('DupSopsOnlyAfterDate', 'select distinct sop_instance_uid from (
  select
    distinct sop_instance_uid, file_id, max(import_time) latest
  from file_location join file_import using(file_id) join import_event using (import_event_id)  
    join file_sop_common using(file_id) join ctp_file using (file_id)
  where sop_instance_uid in (
    select distinct sop_instance_uid from (
      select distinct sop_instance_uid, count(distinct file_id)
      from file_sop_common natural join ctp_file
      where project_name = ? and visibility is null group by sop_instance_uid
      ) as foo
    where count > 1
    ) and visibility is null
  group by sop_instance_uid, file_id
) as foo where latest >= ?
except
select distinct sop_instance_uid from (
select
    distinct sop_instance_uid, file_id, max(import_time) latest
  from file_location join file_import using(file_id) join import_event using (import_event_id)  
    join file_sop_common using(file_id) join ctp_file using (file_id)
  where sop_instance_uid in (
    select distinct sop_instance_uid from (
      select distinct sop_instance_uid, count(distinct file_id)
      from file_sop_common natural join ctp_file
      where project_name = ? and visibility is null group by sop_instance_uid
      ) as foo
    where count > 1
    ) and visibility is null
  group by sop_instance_uid, file_id
) as foo where latest < ?', ARRAY['collection', 'break_date', 'collection_1', 'break_date_1'], 
                    ARRAY['sop_instance_uid'], ARRAY['meta', 'test', 'hello', 'bills_test'], 'posda_files', 'List of duplicate sops with file_ids and latest load date only after cut date')
        ;

            insert into queries
            values ('StudyConsistencyWithPatientId', 'select distinct
  patient_id, study_instance_uid, study_date, study_time,
  referring_phy_name, study_id, accession_number,
  study_description, phys_of_record, phys_reading,
  admitting_diag, count(distinct file_id)
from
  file_study natural join file_patient natural join ctp_file
where study_instance_uid = ? and visibility is null
group by
  patient_id, study_instance_uid, study_date, study_time,
  referring_phy_name, study_id, accession_number,
  study_description, phys_of_record, phys_reading,
  admitting_diag
', ARRAY['study_instance_uid'], 
                    ARRAY['patient_id', 'study_instance_uid', 'count', 'study_description', 'study_date', 'study_time', 'referring_phy_name', 'study_id', 'accession_number', 'phys_of_record', 'phys_reading', 'admitting_diag'], ARRAY['by_study', 'consistency', 'study_consistency'], 'posda_files', 'Check a Study for Consistency
')
        ;

            insert into queries
            values ('background_subprocesses_by_date_op_name', 'select 
  background_subprocess_id as bkgrnd_id, subprocess_invocation_id as invoc_id,
  operation_name, command_line, invoking_user, when_script_started
from
  background_subprocess natural left join subprocess_invocation where invoking_user = ?
  and when_script_ended is not null
  and when_script_started > ? and when_script_started < ? and operation_name = ?
order by when_script_started desc', ARRAY['invoking_user', 'from', 'to', 'operation_name'], 
                    ARRAY['bkgrnd_id', 'invoc_id', 'operation_name', 'command_line', 'invoking_user', 'when_script_started'], ARRAY['meta', 'test', 'hello', 'query_tabs', 'bills_test'], 'posda_queries', 'Add a filter to a tab')
        ;

            insert into queries
            values ('SimplePhiReportByScanVr', 'select 
  distinct element_sig_pattern as element, vr, value, 
  tag_name as description, count(*) as num_series
from element_value_occurance natural join element_seen natural join value_seen
where 
  phi_scan_instance_id = ? and vr = ?
group by element_sig_pattern, vr, value, tag_name', ARRAY['scan_id', 'vr'], 
                    ARRAY['element', 'vr', 'value', 'description', 'num_series'], ARRAY['tag_usage', 'simple_phi'], 'posda_phi_simple', 'Status of PHI scans
')
        ;

            insert into queries
            values ('GetSsReferencingUnknownImages', 'select
  project_name as collection,
  site_name as site,
  patient_id, file_id
from
  ctp_file natural join file_patient
where file_id in (
select
  distinct ss_file_id as file_id from 
(select
  sop_instance_uid, ss_file_id 
from (
  select 
    distinct linked_sop_instance_uid as sop_instance_uid, file_id as ss_file_id
  from
    file_roi_image_linkage
  ) foo left join file_sop_common using(sop_instance_uid)
  where
  file_id is null
) as foo
)
order by collection, site, patient_id, file_id
', '{}', 
                    ARRAY['collection', 'site', 'patient_id', 'file_id'], ARRAY['Structure Sets', 'sops', 'LinkageChecks', 'struct_linkages'], 'posda_files', 'Get list of plan which reference unknown SOPs

')
        ;

            insert into queries
            values ('GetPosdaSimplePhiPrivateElements', 'select
  element_sig_pattern,
  vr,
  is_private,
  private_disposition,
  tag_name
from element_seen

', '{}', 
                    ARRAY['element_sig_pattern', 'vr', 'is_private', 'private_disposition', 'name_chain'], ARRAY['NotInteractive', 'used_in_reconcile_tag_names'], 'posda_phi_simple', 'Get the relevant features of an element_signature in posda_phi_simple schema')
        ;

            insert into queries
            values ('AbortRound', 'update round
  set round_aborted = now()
where
  round_id = ?
', ARRAY['round_id'], 
                    '{}', ARRAY['NotInteractive', 'Backlog'], 'posda_backlog', 'Close row in round (set end time)')
        ;

            insert into queries
            values ('TableSizePosdaPhiSimple', 'select *, pg_size_pretty(total_bytes) AS total
    , pg_size_pretty(index_bytes) AS INDEX
    , pg_size_pretty(toast_bytes) AS toast
    , pg_size_pretty(table_bytes) AS TABLE
  FROM (
  SELECT *, total_bytes-index_bytes-COALESCE(toast_bytes,0) AS table_bytes FROM (
      SELECT c.oid,nspname AS table_schema, relname AS TABLE_NAME
              , c.reltuples AS row_estimate
              , pg_total_relation_size(c.oid) AS total_bytes
              , pg_indexes_size(c.oid) AS index_bytes
              , pg_total_relation_size(reltoastrelid) AS toast_bytes
          FROM pg_class c
          LEFT JOIN pg_namespace n ON n.oid = c.relnamespace
          WHERE relkind = ''r''
  ) a
) a where table_schema = ''public'' order by total_bytes desc', '{}', 
                    ARRAY['table_schema', 'table_name', 'row_estimate', 'total_bytes', 'index_bytes', 'total', 'toast_bytes', 'index', 'toast', 'table'], ARRAY['AllCollections', 'postgres_stats', 'table_size'], 'posda_phi_simple', 'Get a list of collections and sites
')
        ;

            insert into queries
            values ('GetFileIdAndVisibilityByDigest', 'select
  f.file_id as id,
  c.file_id as ctp_file_id,
  c.visibility as visibility
from
  file f left join ctp_file c
  using(file_id)
where
  f.file_id in (
  select file_id
  from
     file
  where
     digest = ?
)', ARRAY['digest'], 
                    ARRAY['id', 'ctp_file_id', 'visibility'], ARRAY['NotInteractive', 'used_in_import_edited_files'], 'posda_files', 'Get file_id, and current visibility by digest
For use in scripts
Not really intended for interactive use
')
        ;

            insert into queries
            values ('PatientByImportEventIdHiddenFiles', 'select
  distinct patient_id, count(distinct file_id) as num_files
from file_patient
where file_id in (
  select distinct file_id
  from file_import natural join import_event natural left join ctp_file
  where import_event_id = ? and visibility = ''hidden''
) group by patient_id order by patient_id', ARRAY['import_event_id'], 
                    ARRAY['patient_id', 'num_files'], ARRAY['ACRIN-NSCLC-FDG-PET Curation'], 'posda_files', 'Get the list of files by sop, excluding base series')
        ;

            insert into queries
            values ('SelectPtInfoSummaryByCollection', 'select 
  distinct 
  project_name as collection,
  site_name as site,
  patient_id,
  series_instance_uid,
  pti_radiopharmaceutical as radiopharmaceutical, 
  pti_radionuclide_total_dose as total_dose,
  pti_radionuclide_half_life as half_life,
  pti_radionuclide_positron_fraction as positron_fraction, 
  pti_fov_shape as fov_shape,
  pti_fov_dimensions as fov_dim,
  pti_collimator_type as coll_type,
  pti_reconstruction_diameter as recon_diam, 
  count(*) as num_files
from file_pt_image natural join file_patient natural join file_series natural join ctp_file 
where project_name = ? and visibility is null
group by
  collection,
  site,
  patient_id,
  series_instance_uid,
  radiopharmaceutical,
  total_dose,
  half_life,
  positron_fraction,
  fov_shape,
  fov_dim,
  coll_type,
  recon_diam
order by patient_id', ARRAY['collection'], 
                    ARRAY['collection', 'site', 'patient_id', 'series_instance_uid', 'radiopharmaceutical', 'total_dose', 'half_life', 'positron_fraction', 'fov_shape', 'fov_dim', 'coll_type', 'recon_diam', 'num_files'], ARRAY['populate_posda_files', 'bills_test'], 'posda_files', 'Gets count of all files which are PET''s which haven''t been imported into file_pt_image yet.

')
        ;

            insert into queries
            values ('PatientsWithNoCtp', 'select
  distinct patient_id,
  count(distinct series_instance_uid) as num_series,
  count(distinct file_id) as num_files,
  min(import_time) as first_import,
  max(import_time) as last_import
from
  file_patient sc natural join file_series
  natural join file_import natural join import_event
where
  not exists (select file_id from ctp_file c where sc.file_id = c.file_id)
group by patient_id;', '{}', 
                    ARRAY['patient_id', 'num_series', 'num_files'], ARRAY['adding_ctp', 'find_patients', 'no_ctp_patients'], 'posda_files', 'Get Series in A Collection
')
        ;

            insert into queries
            values ('files_to_copy_from_public', 'select 
  dp_site_name as site, 
  sop_instance_uid, 
  dicom_file_uri 
from general_image, trial_data_provenance
where 
  general_image.trial_dp_pk_id = trial_data_provenance.trial_dp_pk_id and 
  trial_data_provenance.project = ? and
  trial_data_provenance.dp_site_name = ?', ARRAY['collection', 'site'], 
                    ARRAY['site', 'sop_instance_uid', 'dicom_file_uri'], ARRAY['meta', 'test', 'hello', 'query_tabs', 'bills_test'], 'public', 'Files to copy from Public (to Posda)')
        ;

            insert into queries
            values ('FilesInSeriesWithPositionPixelDig', 'select
  distinct file_id, image_id, unique_pixel_data_id, ipp, instance_number
from
  file_series natural join file_image natural join ctp_file natural join file_sop_common
  natural join image natural join image_geometry
where
  series_instance_uid = ? and visibility is null
', ARRAY['series_instance_uid'], 
                    ARRAY['file_id', 'image_id', 'unique_pixel_data_id', 'ipp', 'instance_number'], ARRAY['SeriesSendEvent', 'by_series', 'find_files', 'for_send'], 'posda_files', 'Get file info from series for comparison of dup_series')
        ;

            insert into queries
            values ('UpdateCopyFromPublic', 'update copy_from_public
  set when_file_rows_populated = now(),
  num_file_rows_populated = ?,
  status_of_copy = ?
where
  copy_from_public_id = ?', ARRAY['num_file_rows_populated', 'status_of_copy', 'copy_id'], 
                    '{}', ARRAY['bills_test', 'copy_from_public'], 'posda_files', 'Add a filter to a tab')
        ;

            insert into queries
            values ('LongestRunningNQueriesByDate', 'select * from (
select query_invoked_by_dbif_id as id, query_name, query_end_time - query_start_time as duration,
invoking_user, query_start_time, number_of_rows
from query_invoked_by_dbif
where query_end_time is not null and
query_start_time > ? and query_end_time < ?
order by duration desc) as foo
limit ?', ARRAY['from', 'to', 'n'], 
                    ARRAY['id', 'query_name', 'duration', 'invoking_user', 'query_start_time', 'number_of_rows'], ARRAY['AllCollections', 'q_stats_by_date'], 'posda_queries', 'Get a list of collections and sites
')
        ;

            insert into queries
            values ('TagUsage', 'select
  distinct element_signature, equipment_signature
from 
  equipment_signature natural join series_scan
  natural join scan_element natural join element_signature
  natural join scan_event
where scan_event_id = ?
order by element_signature;
', ARRAY['scan_id'], 
                    ARRAY['element_signature', 'equipment_signature'], ARRAY['tag_usage'], 'posda_phi', 'Which equipment signatures for which tags
')
        ;

            insert into queries
            values ('GetSeriesInfoById', 'select
  file_id,
  modality,
  series_instance_uid,
  series_number,
  laterality,
  series_date,
  series_time,
  performing_phys,
  protocol_name,
  series_description,
  operators_name,
  body_part_examined,
  patient_position,
  smallest_pixel_value,
  largest_pixel_value,
  performed_procedure_step_id,
  performed_procedure_step_start_date,
  performed_procedure_step_start_time,
  performed_procedure_step_desc, 
  performed_procedure_step_comments,
  date_fixed
from file_series
where file_id = ?', ARRAY['file_id'], 
                    ARRAY['file_id', 'modality', 'series_instance_uid', 'series_number', 'laterality', 'series_date', 'series_time', 'performing_phys', 'protocol_name', 'series_description', 'operators_name', 'body_part_examined', 'patient_position', 'smallest_pixel_value', 'largest_pixel_value', 'performed_procedure_step_id', 'performed_procedure_step_start_date', 'performed_procedure_step_start_time', 'performed_procedure_step_desc', 'performed_procedure_step_comments', 'performed_procedure_step_comments', 'date_fixed'], ARRAY['reimport_queries'], 'posda_files', 'Get file path from id')
        ;

            insert into queries
            values ('GetBacklogControl', 'select
  status, processor_pid,
  idle_poll_interval,
  last_service, pending_change_request,
  source_pending_change_request,
  request_time, num_files_per_round,
  target_queue_size,
  (now() - request_time) as time_pending
from control_status
', '{}', 
                    ARRAY['status', 'processor_pid', 'idle_poll_interval', 'last_service', 'pending_change_request', 'source_pending_change_request', 'request_time', 'num_files_per_round', 'target_queue_size', 'time_pending'], ARRAY['NotInteractive', 'Backlog', 'Backlog Monitor'], 'posda_backlog', 'Get control status from backlog database')
        ;

            insert into queries
            values ('GetUnkQualifiedCTQPByLikeCollectionSiteWithFIleCountAndLoadTimes', 'select 
  collection, site, patient_id, qualified, count(distinct file_id) as num_files,
  min(import_time) as earliest, max(import_time) as latest
from
  clinical_trial_qualified_patient_id join file_patient using (patient_id) join file_import using(file_id)
  join import_event using(import_event_id)
where collection like ? and site = ? and qualified is null
group by collection, site, patient_id, qualified', ARRAY['collection_like', 'site'], 
                    ARRAY['collection', 'site', 'patient_id', 'qualified', 'num_files', 'earliest', 'latest'], ARRAY['clin_qual'], 'posda_files', 'Create An Activity Timepoint

')
        ;

            insert into queries
            values ('LinkAFEtoEditEvent', 'insert into dicom_edit_event_adverse_file_event(
  dicom_edit_event_id, adverse_file_event_id
) values (?, ?)
', ARRAY['dicom_edit_event_id', 'adverse_file_event_id'], 
                    '{}', ARRAY['Insert', 'NotInteractive', 'used_in_import_edited_files'], 'posda_files', 'Insert row linking adverse_file_edit_event to dicom_edit_event
For use in scripts
Not really intended for interactive use
')
        ;

            insert into queries
            values ('GetDciodvfyWarningWrongExpVr', 'select
  dciodvfy_warning_id as id
from 
  dciodvfy_warning
where
  warning_type = ''WrongExplicitVr''
  and warning_tag = ?
  and warning_desc = ?
  and warning_comment = ?
  and warning_value = ?
  and warning_reason = ?
 ', ARRAY['warning_tag', 'warning_desc', 'warning_comment', 'warning_value', 'warning_reason'], 
                    ARRAY['id'], ARRAY['NotInteractive', 'used_in_dciodvfy'], 'posda_phi_simple', 'Get an dciodvfy_warnings row by warning_text (if present)')
        ;

            insert into queries
            values ('CreateSimpleElementSeen', 'insert into 
   element_seen(element_sig_pattern, vr)
   values(?, ?)
', ARRAY['element_sig_pattern', 'vr'], 
                    '{}', ARRAY['NotInteractive', 'used_in_simple_phi_maint', 'used_in_phi_maint'], 'posda_phi_simple', 'Create a new Simple PHI scan')
        ;

            insert into queries
            values ('GetGeometricInfoIntake', 'select
  sop_instance_uid, image_orientation_patient, image_position_patient,
  pixel_spacing, i_rows, i_columns
from
  general_image
where
  sop_instance_uid = ?
', ARRAY['sop_instance_uid'], 
                    ARRAY['sop_instance_uid', 'image_orientation_patient', 'image_position_patient', 'pixel_spacing', 'i_rows', 'i_columns'], ARRAY['LinkageChecks', 'BySopInstance'], 'intake', 'Get Geometric Information by Sop Instance UID from intake')
        ;

            insert into queries
            values ('GetSeriesVisibilityCountsBySeriesAndVisualReviewId', 'select
  distinct series_instance_uid, coalesce(visibility, ''<undef>''), modality,
  count(distinct file_id) as num_files
from file_series natural join ctp_file
where file_id in (
  select
    file_id
  from
    image_equivalence_class natural join image_equivalence_class_input_image
  where
    visual_review_instance_id = ? and series_instance_uid = ?
)
group by series_instance_uid, visibility, modality', ARRAY['visual_review_instance_id', 'series_instance_uid'], 
                    ARRAY['series_instance_uid', 'visibility', 'modality', 'num_files'], ARRAY['signature', 'phi_review', 'visual_review', 'visual_review_new_workflow'], 'posda_files', 'Get a list of files which are hidden by series id and visual review id')
        ;

            insert into queries
            values ('CreateNonDicomEditCompareDisposition', 'insert into non_dicom_edit_compare_disposition(
  subprocess_invocation_id, start_creation_time, current_disposition, process_pid, dest_dir
)values (
  ?, now(), ''Starting Up'', ?, ?
)', ARRAY['subprocess_invocation_id', 'process_pid', 'dest_dir'], 
                    '{}', ARRAY['adding_ctp', 'for_scripting', 'non_dicom_edit'], 'posda_files', 'Create an entry in dicom_edit_compare_disposition

From script only.  Don''t run from user interface (needs valid subprocess_invocation_id)')
        ;

            insert into queries
            values ('EndTransactionPosda', 'commit
', '{}', 
                    '{}', ARRAY['NotInteractive', 'Backlog', 'Transaction', 'used_in_file_import_into_posda'], 'posda_files', 'End a transaction in Posda files')
        ;

            insert into queries
            values ('background_subprocesses', 'select 
  background_subprocess_id as id, 
  operation_name, command_executed, invoking_user, when_script_started
from
  background_subprocess natural left join subprocess_invocation where invoking_user = ?
 and when_script_ended is not null
order by when_script_started desc', ARRAY['invoking_user'], 
                    ARRAY['id', 'operation_name', 'command_executed', 'invoking_user', 'when_script_started'], ARRAY['meta', 'test', 'hello', 'query_tabs', 'bills_test'], 'posda_queries', 'Add a filter to a tab')
        ;

            insert into queries
            values ('PublicFileListByCollection', 'select 
  distinct tdp.project as collection, s.patient_id, s.series_instance_uid, dicom_file_uri
from
  trial_data_provenance tdp, general_image i, general_series s
where
  s.general_series_pk_id = i.general_series_pk_id and i.trial_dp_pk_id = tdp.trial_dp_pk_id
  and tdp.project = ?', ARRAY['collection'], 
                    ARRAY['collection', 'patient_id', 'series_instance_uid', 'dicom_file_uri'], ARRAY['by_collection', 'find_series', 'search_series', 'send_series', 'phi_simple', 'simple_phi'], 'public', 'Get Series in A Collection
')
        ;

            insert into queries
            values ('CountsByCollectionLikeSite', 'select
  distinct
    project_name as collection, site_name as site,
    patient_id, image_type, dicom_file_type, modality,
    study_date, series_date,
    study_description,
    series_description, study_instance_uid, series_instance_uid,
    manufacturer, manuf_model_name, software_versions,
    count(distinct sop_instance_uid) as num_sops,
    count(distinct file_id) as num_files,
    min(import_time) as earliest,
    max(import_time) as latest
from
  ctp_file join file_patient using(file_id)
  join dicom_file using(file_id)
  join file_series using(file_id)
  join file_sop_common using(file_id)
  join file_study using(file_id)
  join file_equipment using(file_id)
  join file_import using(file_id)
  join import_event using(import_event_id)
  left join file_image using(file_id)
  left join image using (image_id)
where
  file_id in (
    select file_id 
    from file_import natural join import_event
  ) and project_name like ?  and site_name = ? 
group by
  collection, site, patient_id, image_type, dicom_file_type, modality, study_date, 
  series_date, study_description,
  series_description, study_instance_uid, series_instance_uid,
  manufacturer, manuf_model_name, software_versions
order by
  collection, site, patient_id, study_instance_uid, series_instance_uid, image_type,
  modality, study_date, series_date, study_description,
  series_description,
  manufacturer, manuf_model_name, software_versions
', ARRAY['collection_like', 'site'], 
                    ARRAY['collection', 'site', 'patient_id', 'image_type', 'dicom_file_type', 'modality', 'study_date', 'series_date', 'study_description', 'series_description', 'study_instance_uid', 'series_instance_uid', 'manufacturer', 'manuf_model_name', 'software_versions', 'num_sops', 'num_files', 'earliest', 'latest'], ARRAY['counts', 'count_queries'], 'posda_files', 'Counts query by Collection like pattern
')
        ;

            insert into queries
            values ('FilesInHierarchyBySeries', 'select distinct
  project_name as collection,
  site_name as site,
  patient_id,
  study_instance_uid,
  series_instance_uid,
  sop_instance_uid,
  file_id
from
  file_patient natural join
  file_study natural join
  file_series natural join
  file_sop_common natural join
  ctp_file
where file_id in (
  select
    distinct file_id
  from
    file_series natural join ctp_file
  where
    series_instance_uid = ? and visibility is null
)
order by
  project_name, site_name, patient_id,
  study_instance_uid, series_instance_uid
', ARRAY['series_instance_uid'], 
                    ARRAY['collection', 'site', 'patient_id', 'study_instance_uid', 'series_instance_uid', 'sop_instance_uid', 'file_id'], ARRAY['by_series_instance_uid', 'posda_files', 'sops'], 'posda_files', 'Get Collection, Site, Patient, Study Hierarchy in which series resides
')
        ;

            insert into queries
            values ('GetRoiCountsBySeriesInstanceUid', 'select 
   distinct sop_instance_uid, count(distinct roi_id)
from 
  roi natural join structure_set natural join file_structure_set 
  join file_sop_common using(file_id)
where sop_instance_uid in (
  select distinct sop_instance_uid from file_sop_common natural join file_series
  where series_instance_uid = ?
)
group by sop_instance_uid
order by count desc
', ARRAY['series_instance_uid'], 
                    ARRAY['sop_instance_uid', 'count'], ARRAY['Structure Sets', 'sops', 'LinkageChecks'], 'posda_files', 'Get List of ROI''s in a structure Set

')
        ;

            insert into queries
            values ('GetBackgroundButtonsByTag', 'select
    background_button_id,
    operation_name,
    object_class,
    button_text
from background_buttons
where tags && ?

', ARRAY['tags'], 
                    ARRAY['background_button_id', 'operation_name', 'object_class', 'button_text'], ARRAY['NotInteractive', 'used_in_process_popup'], 'posda_queries', '')
        ;

            insert into queries
            values ('DistinctSeriesByCollectionLikeSeriesDescription', 'select 
  distinct collection, 
  site, patient_id, series_instance_uid, 
  series_description,
  dicom_file_type, modality, 
  count(distinct sop_instance_uid) as num_sops,
  count(distinct file_id) as num_files
  from (
    select
     distinct project_name as collection,
     site_name as site,
     patient_id, 
     series_instance_uid, 
     series_description,
     dicom_file_type, 
     modality, sop_instance_uid,
     file_id
    from 
     file_series
     natural join dicom_file
     natural join file_sop_common 
     natural join file_patient
     natural join ctp_file
  where
    project_name = ? 
    and site_name = ? 
    and series_description like ?
    and visibility is null
) as foo
group by collection, site, patient_id, 
  series_instance_uid, series_description, dicom_file_type, modality
', ARRAY['collection', 'site', 'description'], 
                    ARRAY['collection', 'site', 'patient_id', 'series_instance_uid', 'series_description', 'dicom_file_type', 'modality', 'num_sops', 'num_files'], ARRAY['by_collection', 'find_series'], 'posda_files', 'Get Series in A Collection
')
        ;

            insert into queries
            values ('CountsByCollectionSite', 'select
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
', ARRAY['collection', 'site'], 
                    ARRAY['patient_id', 'image_type', 'modality', 'study_date', 'study_description', 'series_description', 'study_instance_uid', 'series_instance_uid', 'manufacturer', 'manuf_model_name', 'software_versions', 'num_sops', 'num_files'], ARRAY['counts'], 'posda_files', 'Counts query by Collection, Site
')
        ;

            insert into queries
            values ('CreateComparePublicToPosdaInstance', 'insert into compare_public_to_posda_instance(
  when_compare_started, status_of_compare, number_of_sops
)values (
  now(), ''Starting Up'', ?
)', ARRAY['num_sops'], 
                    '{}', ARRAY['adding_ctp', 'for_scripting'], 'posda_files', 'Create an entry in dicom_edit_compare_disposition

From script only.  Don''t run from user interface (needs valid subprocess_invocation_id)')
        ;

            insert into queries
            values ('GetFilesToImportFromEdit', 'select
  subprocess_invocation_id,
  from_file_digest,
  to_file_digest,
  to_file_path
from
  dicom_edit_compare
where 
  from_file_digest in 
  (
    select from_file_digest from 
    (
      select distinct from_file_digest 
      from dicom_edit_compare dec, file f natural join ctp_file
      where dec.from_file_digest = f.digest and visibility is null and subprocess_invocation_id = ?
      intersect
      select from_file_digest from dicom_edit_compare dec
      where not exists
      (
        select file_id from file f where dec.to_file_digest = f.digest
       ) 
       and subprocess_invocation_id = ?
    ) as foo
  )
  and subprocess_invocation_id = ?
limit ?', ARRAY['subprocess_invocation_id', 'subprocess_invocation_id_1', 'subprocess_invocation_id_2', 'limit'], 
                    ARRAY['subprocess_invocation_id', 'from_file_digest', 'to_file_digest', 'to_file_path'], ARRAY['used_in_file_import_into_posda', 'used_in_file_migration'], 'posda_files', 'Get count of files relative to storage root')
        ;

            insert into queries
            values ('TableSizePosdaBacklog', 'select *, pg_size_pretty(total_bytes) AS total
    , pg_size_pretty(index_bytes) AS INDEX
    , pg_size_pretty(toast_bytes) AS toast
    , pg_size_pretty(table_bytes) AS TABLE
  FROM (
  SELECT *, total_bytes-index_bytes-COALESCE(toast_bytes,0) AS table_bytes FROM (
      SELECT c.oid,nspname AS table_schema, relname AS TABLE_NAME
              , c.reltuples AS row_estimate
              , pg_total_relation_size(c.oid) AS total_bytes
              , pg_indexes_size(c.oid) AS index_bytes
              , pg_total_relation_size(reltoastrelid) AS toast_bytes
          FROM pg_class c
          LEFT JOIN pg_namespace n ON n.oid = c.relnamespace
          WHERE relkind = ''r''
  ) a
) a where table_schema = ''public'' order by total_bytes desc', '{}', 
                    ARRAY['table_schema', 'table_name', 'row_estimate', 'total_bytes', 'index_bytes', 'total', 'toast_bytes', 'index', 'toast', 'table'], ARRAY['AllCollections', 'postgres_stats', 'table_size'], 'posda_backlog', 'Get a list of collections and sites
')
        ;

            insert into queries
            values ('DicomFileTypes', 'select 
  distinct dicom_file_type, count(distinct file_id)
from
  dicom_file natural join ctp_file
where
  visibility is null  
group by dicom_file_type
order by count desc', '{}', 
                    ARRAY['dicom_file_type', 'count'], ARRAY['find_series', 'dicom_file_type'], 'posda_files', 'List of Dicom File Types with count of files in Posda
')
        ;

            insert into queries
            values ('OneFileFromSop', 'select
  distinct root_path || ''/'' || rel_path as file
from
  file_location natural join file_storage_root
  natural join ctp_file
  natural join file_sop_common
where
  sop_instance_uid = ? and visibility is null
limit 1
', ARRAY['sop_instance_uid'], 
                    ARRAY['file'], ARRAY['by_series', 'find_files', 'used_in_simple_phi'], 'posda_files', 'Get files in a series from posda database
')
        ;

            insert into queries
            values ('ListSrPosda', 'select 
  distinct project_name as collection, site_name as site,
  patient_id, study_instance_uid, series_instance_uid,
  file_id, root_path || ''/'' || rel_path as file_path
from
  dicom_file natural join file_patient natural join file_series
  natural join file_study natural join ctp_file
  join file_location using (file_id) natural join file_storage_root
where
  visibility is null and dicom_file_type like ''%SR%'' and
  project_name like ?', ARRAY['collection_like'], 
                    ARRAY['collection', 'site', 'patient_id', 'study_instance_uid', 'series_instance_ui', 'file_id', 'file_path'], ARRAY['meta', 'test', 'hello', 'query_tabs', 'bills_test', 'view_structured_reports'], 'posda_files', 'Add a filter to a tab')
        ;

            insert into queries
            values ('TagsSeenPrivate', 'select
  element_signature, vr, is_private, private_disposition, name_chain
from
  element_signature
where is_private
order by element_signature, vr', '{}', 
                    ARRAY['element_signature', 'vr', 'is_private', 'private_disposition', 'name_chain'], ARRAY['by_collection', 'find_series', 'compare_collection_site', 'search_series', 'edit_files', 'phi_maint'], 'posda_phi', 'Get all the data from tags_seen in posda_phi database
')
        ;

            insert into queries
            values ('UpdateNonDicomEditCompareDispositionStatus', 'update non_dicom_edit_compare_disposition set
  current_disposition = ?,
  last_updated = now()
where
  subprocess_invocation_id = ?
', ARRAY['current_disposition', 'subprocess_invocation_id'], 
                    '{}', ARRAY['adding_ctp', 'for_scripting', 'non_dicom_import'], 'posda_files', 'Update status of an entry in dicom_edit_compare_disposition

From script only.  Don''t run from user interface (needs valid subprocess_invocation_id)')
        ;

            insert into queries
            values ('NewSopsReceivedBetweenDates', 'select
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
', ARRAY['start_time', 'end_time'], 
                    ARRAY['project_name', 'site_name', 'patient_id', 'study_instance_uid', 'series_instance_uid', 'num_sops', 'first_loaded', 'last_loaded'], ARRAY['receive_reports'], 'posda_files', 'Series received between dates with sops without duplicates
')
        ;

            insert into queries
            values ('InsertManifestRow', 'insert into ctp_manifest_row(
 file_id,
 cm_index,
 cm_collection,
 cm_site,
 cm_patient_id,
 cm_study_date,
 cm_series_instance_uid,
 cm_study_description,
 cm_series_description,
 cm_modality,
 cm_num_files ) values(
 ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?
)', ARRAY['file_id', 'cm_index', 'cm_collection', 'cm_site', 'cm_patient_id', 'cm_study_date', 'cm_series_instance_uid', 'cm_study_description', 'cm_series_description', 'cm_modality', ''], 
                    '{}', ARRAY['activity_timepoint_support', 'manifests'], 'posda_files', 'Create An Activity Timepoint

')
        ;

            insert into queries
            values ('InboxContentByActivityIdWithCompletion', 'select
 user_name, user_inbox_content_id as id, operation_name,
  when_script_started as when, when_script_ended as ended,
  when_script_ended - when_script_started as duration,
  file_id, subprocess_invocation_id as sub_id,
  command_line,
  file_id_in_posda as spreadsheet_file_id
from 
  activity_inbox_content natural join user_inbox natural join
  user_inbox_content natural join background_subprocess_report
  natural join background_subprocess natural join subprocess_invocation
  natural left join spreadsheet_uploaded
where activity_id = ?
order by when_script_started desc', ARRAY['activity_id'], 
                    ARRAY['user_name', 'id', 'operation_name', 'when', 'ended', 'duration', 'file_id', 'sub_id', 'command_line', 'spreadsheet_file_id'], ARRAY['AllCollections', 'queries', 'activity_support'], 'posda_queries', 'Get a list of available queries')
        ;

            insert into queries
            values ('UpdateActivityTaskStatus', 'update activity_task_status set
  status_text = ?,
  last_updated = now(),
  dismissed_time = null,
  dismissed_by = null
where
  activity_id = ? and
  subprocess_invocation_id = ?', ARRAY['status_text', 'activity_id', 'subprocess_invocation_id'], 
                    '{}', ARRAY['NotInteractive', 'Update'], 'posda_files', 'Update status_text and expected_completion_time in activity_task_status
For use in scripts
Not really intended for interactive use
')
        ;

            insert into queries
            values ('GetFileIdVisibilityByImageEquivalenceClass', 'select 
  distinct file_id, visibility
from
  image_equivalence_class natural join image_equivalence_class_input_image natural join ctp_file
where image_equivalence_class_id = ?', ARRAY['image_equivalence_class_id'], 
                    ARRAY['file_id', 'visibility'], ARRAY['ImageEdit', 'edit_files'], 'posda_files', 'Get File id and visibility for all files in a series')
        ;

            insert into queries
            values ('FilesInSeries', 'select
  distinct root_path || ''/'' || rel_path as file
from
  file_location natural join file_storage_root
  natural join ctp_file
  natural join file_series
where
  series_instance_uid = ? and visibility is null
', ARRAY['series_instance_uid'], 
                    ARRAY['file'], ARRAY['by_series', 'find_files', 'used_in_simple_phi'], 'posda_files', 'Get files in a series from posda database
')
        ;

            insert into queries
            values ('HideSeriesNotLikeWithModality', 'update ctp_file set visibility = ''hidden''
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
', ARRAY['modality', 'collection', 'site', 'description_not_matching'], 
                    NULL, ARRAY['Update', 'posda_files'], 'posda_files', 'Hide series not matching pattern by modality
')
        ;

            insert into queries
            values ('CreatePhiNonDicomScanInstance', 'insert into phi_non_dicom_scan_instance(
  pndsi_description,
  pndsi_start_time,
  pndsi_num_files,
  pndsi_num_files_scanned
) values (
  ?, now(), ?, 0
)', ARRAY['description_of_scan', 'num_files'], 
                    '{}', ARRAY['NotInteractive', 'non_dicom_phi'], 'posda_phi_simple', 'Create a dciodvfy_scan_instance row')
        ;

            insert into queries
            values ('PixelDataDuplicateCounts', 'select
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
      image join file_image using(image_id)
      join ctp_file using(file_id)
      join file_patient fq using(file_id)
      join unique_pixel_data using(unique_pixel_data_id)
    where visibility is null
  ) as foo 
  group by 
    unique_pixel_data_id, project_name, pixel_digest,
    site_name, patient_id
) as foo 
group by pixel_digest', '{}', 
                    ARRAY['pixel_digest', 'count'], ARRAY['pix_data_dups', 'pixel_duplicates'], 'posda_files', 'Find digest with counts of files
')
        ;

            insert into queries
            values ('PrivateTagsToBeDeleted', 'select distinct element_sig_pattern as tag from element_seen where is_private and private_disposition = ''d'' order by element_sig_pattern;

', '{}', 
                    ARRAY['tag'], ARRAY['AllCollections', 'queries', 'phi_maint'], 'posda_phi_simple', 'Private tags to be deleted')
        ;

            insert into queries
            values ('ListAllActivities', 'select
  activity_id,
  brief_description,
  when_created,
  who_created,
  when_closed
from
  activity 
order by activity_id', '{}', 
                    ARRAY['activity_id', 'brief_description', 'when_created', 'who_created', 'when_closed'], ARRAY['AllCollections', 'queries', 'activities'], 'posda_queries', 'Get a list of available queries')
        ;

            insert into queries
            values ('PhiNonDicomScanStatusComplete', 'select 
   phi_non_dicom_scan_instance_id as id,
   pndsi_description as description,
   pndsi_start_time as start_time,
   pndsi_num_files as num_files_to_scan,
   pndsi_num_files_scanned as num_files_scanned,
   pndsi_end_time - pndsi_start_time as duration
from
  phi_non_dicom_scan_instance
where pndsi_end_time is not null
order by start_time', '{}', 
                    ARRAY['id', 'description', 'start_time', 'num_files_to_scan', 'num_files_scanned', 'duration'], ARRAY['tag_usage', 'non_dicom_phi_status'], 'posda_phi_simple', 'Status of PHI scans
')
        ;

            insert into queries
            values ('DistinctStudySeriesByCollection', 'select distinct study_instance_uid as study_uid, series_instance_uid as series_uid, patient_id, dicom_file_type, modality, count(*)
from (
select distinct study_instance_uid, series_instance_uid, patient_id, sop_instance_uid, dicom_file_type, modality from (
select
   distinct study_instance_uid, series_instance_uid, patient_id, modality, sop_instance_uid,
   file_id, dicom_file_type
 from file_series natural join file_sop_common
   natural join ctp_file natural join dicom_file natural join file_patient natural join file_study
where
  project_name = ?
  and visibility is null)
as foo
group by study_instance_uid, series_instance_uid, patient_id, sop_instance_uid, dicom_file_type, modality)
as foo
group by study_uid, series_uid, patient_id, dicom_file_type, modality
', ARRAY['collection'], 
                    ARRAY['study_uid', 'series_uid', 'patient_id', 'dicom_file_type', 'modality', 'count'], ARRAY['by_collection', 'find_series', 'search_series', 'send_series', 'phi_simple', 'simple_phi'], 'posda_files', 'Get Series in A Collection
')
        ;

            insert into queries
            values ('GetAllQualifiedCTQPByLikeCollectionSiteWithFIleCountAndLoadTimes', 'select 
  collection, site, patient_id, qualified, count(distinct file_id) as num_files,
  min(import_time) as earliest, max(import_time) as latest
from
  clinical_trial_qualified_patient_id join file_patient using (patient_id) join file_import using(file_id)
  join import_event using(import_event_id)
where collection like ? and site = ?
group by collection, site, patient_id, qualified', ARRAY['collection_like', 'site'], 
                    ARRAY['collection', 'site', 'patient_id', 'qualified', 'num_files', 'earliest', 'latest'], ARRAY['clin_qual'], 'posda_files', 'Create An Activity Timepoint

')
        ;

            insert into queries
            values ('PatientStudySeriesForFile', 'select
  patient_id, study_instance_uid, series_instance_uid, root_path || ''/'' || rel_path as path
from
  file_patient natural join file_series natural join
  file_study natural join file_location natural join file_storage_root
where file_id = ?', ARRAY['file_id'], 
                    ARRAY['patient_id', 'study_instance_uid', 'series_instance_uid', 'path'], ARRAY['activity_timepoint_support'], 'posda_files', 'Create An Activity Timepoint

')
        ;

            insert into queries
            values ('GetNfilesToCopyOnly', 'select
  sop_instance_uid,
  copy_file_path 
from file_copy_from_public
where copy_from_public_id =  ? and inserted_file_id is null 
limit ?', ARRAY['copy_from_public_id', 'count'], 
                    ARRAY['sop_instance_uid', 'copy_file_path'], ARRAY['bills_test', 'copy_from_public'], 'posda_files', 'Add a filter to a tab')
        ;

            insert into queries
            values ('CurrentPatientStatiiByCollectionSite', 'select 
  distinct project_name as collection,
  site_name as site,
  patient_id,
  patient_import_status
from 
  ctp_file natural join file_patient natural left join patient_import_status
where
  visibility is null and project_name = ? and site_name = ?', ARRAY['collection', 'site'], 
                    ARRAY['collection', 'site', 'patient_id', 'patient_import_status'], ARRAY['counts', 'patient_status', 'for_bill_counts'], 'posda_files', 'Get the current status of all patients')
        ;

            insert into queries
            values ('DistinctFilesByScanTag', 'select
  distinct series_instance_uid,
  series_scanned_file as file, 
  element_signature
from
  scan_event natural join series_scan natural join seen_value
  natural join element_signature natural join 
  scan_element natural left join sequence_index
where
  scan_event_id = ? and element_signature = ?
order by series_instance_uid, file
', ARRAY['scan_id', 'tag'], 
                    ARRAY['series_instance_uid', 'file', 'element_signature', 'value', 'sequence_level', 'item_number'], ARRAY['tag_usage', 'phi_review'], 'posda_phi', 'Find out where specific value, tag combinations occur in a scan
')
        ;

            insert into queries
            values ('RecentUploadsTest1', 'select
        project_name,
        site_name,
        dicom_file_type,
        count(*),
        (extract(epoch from now() - max(import_time)) / 60)::int as minutes_ago,
        to_char(max(import_time), ''HH24:MI'') as time

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

        where import_time > now() - interval ''1'' day
          and visibility is null
    ) as foo
    group by
        project_name,
        site_name,
        dicom_file_type
    order by minutes_ago asc;', '{}', 
                    ARRAY['project_name', 'site_name', 'dicom_file_type', 'count', 'minutes_ago', 'time'], ARRAY['files'], 'posda_files', 'Show files received by Posda in the past day.')
        ;

            insert into queries
            values ('SeriesWithDistinguishedDigests', 'select
  distinct project_name as collection,
  site_name as site,
  patient_id,
  series_instance_uid,
  count(distinct sop_instance_uid) as num_sops
from
  ctp_file natural join
  file_patient natural
  join file_series natural
  join file_sop_common
where file_id in(
  select file_id 
  from
    file_image
    join image using (image_id)
    join unique_pixel_data using (unique_pixel_data_id)
  where digest in (
    select distinct pixel_digest as digest 
    from distinguished_pixel_digests
  )
) group by collection, site, patient_id, series_instance_uid', '{}', 
                    ARRAY['collection', 'site', 'patient_id', 'series_instance_uid', 'num_sops'], ARRAY['duplicates', 'distinguished_digest'], 'posda_files', 'show series with distinguished digests and counts')
        ;

            insert into queries
            values ('ListOfSchemas', 'select
 distinct schema
from queries
order by schema', '{}', 
                    ARRAY['schema'], ARRAY['AllCollections', 'schema'], 'posda_queries', 'Get a list of available queries')
        ;

            insert into queries
            values ('SimplePhiReportByScanVrPublicOnly', 'select 
  distinct element_sig_pattern as element, vr, value, 
  tag_name as description, count(*) as num_series
from element_value_occurance natural join element_seen natural join value_seen
where 
  phi_scan_instance_id = ? and vr = ?
  and not is_private
group by element_sig_pattern, vr, value, tag_name', ARRAY['scan_id', 'vr'], 
                    ARRAY['element', 'vr', 'value', 'description', 'num_series'], ARRAY['tag_usage', 'simple_phi'], 'posda_phi_simple', 'Status of PHI scans
')
        ;

            insert into queries
            values ('GetPrivateTagFeaturesBySignature', 'select
  pt_consensus_name as name,
  pt_consensus_vr as vr,
  pt_consensus_disposition as disposition
from pt
where pt_signature = ?
', ARRAY['signature'], 
                    ARRAY['name', 'vr', 'disposition'], ARRAY['DispositionReport', 'NotInteractive'], 'posda_private_tag', 'Get the relevant features of a private tag by signature
Used in DispositionReport.pl - not for interactive use
')
        ;

            insert into queries
            values ('LookingForMissingHeadNeckPetCT1', 'select 
  distinct patient_id, study_instance_uid, series_instance_uid, modality, 
  count(distinct file_id) as num_files, min(import_time) as first_load, max(import_time) as last_load
from
  file_patient natural join file_study 
  natural join file_series
  join file_import using(file_id)
  join import_event using(import_event_id)
where file_id in (      
  select
     distinct file_id
  from
    file_series join ctp_file using(file_id)
    join file_sop_common using(file_id) 
    join file_import using (file_id)
    join import_event using(import_event_id)
  where 
    project_name = ''Head-Neck-PET-CT'' and import_time > ''2018-04-01''
  )
group by patient_id, study_instance_uid, series_instance_uid, modality', '{}', 
                    ARRAY['patient_id', 'study_instance_uid', 'series_instance_uid', 'modality', 'num_files', 'first_load', 'last_load'], ARRAY['meta', 'test', 'hello', 'bills_test', 'bills_ad_hoc_scripts', 'for_tracy'], 'posda_files', 'Add a filter to a tab')
        ;

            insert into queries
            values ('FindingStructureSetsForTest', 'select
  distinct project_name as collection, patient_id, series_description, sop_instance_uid, file_id,
  dicom_file_type
from
  ctp_file natural join dicom_file natural join file_study natural join file_series
  natural join file_patient natural join file_sop_common
where 
  dicom_file_type = ''RT Structure Set Storage'' and visibility is null and project_name = ''Soft-tissue-Sarcoma''', '{}', 
                    ARRAY['collection', 'patient_id', 'file_id', 'dicom_file_type', 'series_description'], ARRAY['Test Case based on Soft-tissue-Sarcoma'], 'posda_files', 'Find All of the Structure Sets In Soft-tissue-Sarcoma')
        ;

            insert into queries
            values ('GetComparePublicToPosdaInstanceId', 'select currval(''compare_public_to_posda_insta_compare_public_to_posda_insta_seq'') as id', '{}', 
                    ARRAY['id'], ARRAY['radcomp'], 'posda_files', 'Add a filter to a tab')
        ;

            insert into queries
            values ('GetBacklogQueueSizeWithCollection', 'select
 distinct collection, count(*) as num_files
from
  request natural join submitter
where
  file_in_posda is false
group by collection

', '{}', 
                    ARRAY['collection', 'num_files'], ARRAY['NotInteractive', 'Backlog', 'Backlog Monitor', 'backlog_status'], 'posda_backlog', 'Get size of queue  in PosdaBacklog')
        ;

            insert into queries
            values ('SeriesListBySubjectName', 'select
  distinct project_name as collection,
  site_name as site,
  patient_id,
  study_instance_uid,
  study_date,
  study_description,
  series_instance_uid,
  series_date,
  series_description,
  modality, 
  dicom_file_type, 
  count(distinct file_id) as num_files
from 
  file_patient natural join
  file_series natural join
  file_study natural join
  dicom_file natural join
  ctp_file
where 
  patient_id = ?
  and visibility is null
group by 
  collection,
  site,
  patient_id,
  study_instance_uid,
  study_date,
  study_description,
  series_instance_uid,
  series_date,
  series_description,
  modality,
  dicom_file_type;', ARRAY['patient_id'], 
                    ARRAY['collection', 'site', 'patient_id', 'study_instance_uid', 'study_date', 'study_description', 'series_instance_uid', 'series_date', 'series_description', 'modality', 'dicom_file_type', 'num_files'], ARRAY['find_series', 'for_tracy'], 'posda_files', 'Get List of Series by Subject Name')
        ;

            insert into queries
            values ('PhiSimpleScanStatus', 'select
  phi_scan_instance_id as id,
  start_time,
  end_time,
  end_time - start_time as duration,
  description,
  num_series as to_scan,
  num_series_scanned as scanned
from 
  phi_scan_instance
order by id desc
', '{}', 
                    ARRAY['id', 'start_time', 'end_time', 'duration', 'description', 'to_scan', 'scanned', 'phi_status'], ARRAY['tag_usage', 'simple_phi', 'scan_status'], 'posda_phi_simple', 'Status of PHI scans
')
        ;

            insert into queries
            values ('HideEarlyFilesCSP', 'update ctp_file set visibility = ''hidden'' where file_id in (
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
', ARRAY['collection', 'site', 'subject'], 
                    NULL, '{}', 'posda_files', 'Hide earliest submission of a file:
  Note:    uses sequencing of file_id to determine earliest
           file, not import_time
')
        ;

            insert into queries
            values ('ActivityTimepointForOpenActivitiesByDescLike', 'select
  activity_id, a.when_created as activity_created,
  brief_description as activity_description, activity_timepoint_id,
  t.when_created as timepoint_created, 
  comment, creating_user
from
  activity a join activity_timepoint t using(activity_id)
where
  a.when_closed is null and
  brief_description like ?', ARRAY['description_like'], 
                    ARRAY['activity_id', 'activity_created', 'activity_description', 'activity_timepoint_id', 'timepoint_created', 'comment', 'creating_user'], ARRAY['by_collection', 'find_series', 'compare_collection_site', 'search_series', 'edit_files', 'simple_phi', 'dciodvfy', 'ctp_details', 'select_for_phi', 'visual_review_selection', 'activity_timepoints'], 'posda_queries', 'Get Series in A Collection, site with dicom_file_type, modality, and sop_count
')
        ;

            insert into queries
            values ('DistinctSeriesByDicomFileType', 'select 
  distinct series_instance_uid, dicom_file_type, count(distinct file_id)
from
  file_series natural join dicom_file natural join ctp_file
where
  dicom_file_type = ? and
  visibility is null  
group by series_instance_uid, dicom_file_type', ARRAY['dicom_file_type'], 
                    ARRAY['series_instance_uid', 'dicom_file_type', 'count'], ARRAY['find_series', 'dicom_file_type'], 'posda_files', 'List of Distinct Series By Dicom File Type
')
        ;

            insert into queries
            values ('ShowQueryTabHierarchyWithCounts', 'select 
  query_tab_name, filter_name, tag, count(distinct query_name) as num_queries
from(
  select 
     query_tab_name,
      filter_name,
      unnest(tags_enabled) as tag
  from
    query_tabs join query_tabs_query_tag_filter using(query_tab_name)
    natural join query_tag_filter
) as foo
natural join(
  select
     name as query_name,
     unnest(tags) as tag
from queries
) as fie
group by query_tab_name, filter_name, tag
order by 
  query_tab_name, filter_name, tag', '{}', 
                    ARRAY['query_tab_name', 'filter_name', 'tag', 'num_queries'], ARRAY['meta', 'test', 'hello', 'query_tabs', 'bills_test'], 'posda_queries', 'Add a filter to a tab')
        ;

            insert into queries
            values ('SimpleSeriesCountsByCollectioin', 'select
  distinct project_name as collection,
  site_name as site,
  patient_id,
  series_instance_uid,
  dicom_file_type,
  modality,
  count(distinct file_id)as num_files,
  sum(size) as num_bytes
from
  ctp_file natural join
  file natural join
  dicom_file natural join
  file_patient natural join
  file_series
where
  visibility is null and
  project_name = ?
group by
  collection,
  site,
  patient_id,
  series_instance_uid,
  dicom_file_type,
  modality', ARRAY['collection'], 
                    ARRAY['collection', 'site', 'patient_id', 'series_instance_uid', 'dicom_file_type', 'modality', 'num_files', 'num_bytes'], ARRAY['counts', 'count_queries'], 'posda_files', 'Counts query by Collection like pattern
')
        ;

            insert into queries
            values ('WhereFilesInTimePointSit', 'select distinct
  project_name as collection,
  site_name as site,
  patient_id,
  study_instance_uid,
  series_instance_uid,
  sop_instance_uid
from
  file_patient natural join
  file_study natural join
  file_series natural join
  file_sop_common natural left join
  ctp_file
where file_id in(
  select file_id from activity_timepoint_file
  where activity_timepoint_id = ?
)', ARRAY['activity_timepoint_id'], 
                    ARRAY['collection', 'site', 'patient_id', 'study_instance_uid', 'series_instance_uid', 'sop_instance_uid'], ARRAY['posda_files', 'sops', 'BySopInstance', 'by_file'], 'posda_files', 'Get Collection, Site, Patient, Study Hierarchy in which SOP resides
')
        ;

            insert into queries
            values ('DistinctSopsInCollectionByStorageClass', 'select distinct sop_instance_uid, rel_path
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
', ARRAY['collection', 'storage_class'], 
                    ARRAY['sop_instance_uid', 'rel_path'], ARRAY['by_collection', 'posda_files', 'sops'], 'posda_files', 'Get Distinct SOPs in Collection with number files
Only visible files
')
        ;

            insert into queries
            values ('DistinctVisibleSopsAndFilesInSeriesWithPatAndStudy', 'select distinct
  patient_id, study_instance_uid, series_instance_uid,
  sop_instance_uid, file_id
from
  file_patient natural join file_study natural join file_series natural join file_sop_common
where file_id in 
  (select
    distinct file_id
  from
    file_series natural join file_sop_common natural join ctp_file
  where
    series_instance_uid = ? and visibility is null)
', ARRAY['series_instance_uid'], 
                    ARRAY['patient_id', 'study_instance_uid', 'series_instance_uid', 'sop_instance_uid', 'file_id'], ARRAY['by_series_instance_uid', 'file_ids', 'posda_files'], 'posda_files', 'Get Distinct Unhidden Files in Series
')
        ;

            insert into queries
            values ('GetXlsxToConvert', 'select 
  file_id, file_type, file_sub_type, collection, site, subject, visibility, date_last_categorized
from
  non_dicom_file
where
 collection = ? and file_type = ''xlsx'' and visibility is null', ARRAY['collection'], 
                    ARRAY['file_id', 'file_type', 'file_sub_type', 'collection', 'site', 'subject', 'visibility', 'date_last_categorized'], ARRAY['radcomp'], 'posda_files', 'Add a filter to a tab')
        ;

            insert into queries
            values ('StudiesInCollectionSite', 'select
  distinct study_instance_uid
from
  file_study natural join ctp_file
where
  project_name = ? and site_name = ? and visibility is null
', ARRAY['project_name', 'site_name'], 
                    ARRAY['study_instance_uid'], ARRAY['find_studies'], 'posda_files', 'Get Studies in A Collection, Site
')
        ;

            insert into queries
            values ('GetToday', 'select 
  date_trunc(''day'',now()) as today
 ', '{}', 
                    ARRAY['today'], ARRAY['downloads_by_date'], 'posda_files', 'Counts query by Collection, Site
')
        ;

            insert into queries
            values ('GetBacklogQueueSize', 'select
 count(*) as num_files
from
  request
where
  file_in_posda is false 

', '{}', 
                    ARRAY['num_files'], ARRAY['NotInteractive', 'Backlog', 'Backlog Monitor', 'backlog_status'], 'posda_backlog', 'Get size of queue  in PosdaBacklog')
        ;

            insert into queries
            values ('GetDoseReferencingNoPlan', 'select
  project_name as collection,
  site_name as site,
  patient_id,
  series_instance_uid,
  file_id
from
  file_series natural join
  file_patient natural join ctp_file
where
  project_name = ? and
  visibility is null and
  file_id in (
select file_id from rt_dose natural join file_dose  where
rt_dose_referenced_plan_uid is null)', ARRAY['collection'], 
                    ARRAY['collection', 'site', 'patient_id', 'sop_instance_uid', 'series_instance_uid', 'file_id'], ARRAY['Structure Sets', 'sops', 'LinkageChecks', 'dose_linkages'], 'posda_files', 'Get list of plan which reference unknown SOPs

')
        ;

            insert into queries
            values ('ContourTypesByRoi', 'select
  distinct geometric_type,
  count(distinct roi_contour_id) as num_contours,
  sum(number_of_points) as total_points
from
 roi_contour
where roi_id = ?
group by geometric_type', ARRAY['roi_id'], 
                    ARRAY['geometric_type', 'num_contours', 'total_points'], ARRAY['LinkageChecks', 'used_in_struct_linkage_check'], 'posda_files', 'Get list of Roi with info by file_id

')
        ;

            insert into queries
            values ('AllPatientDetailsWithNoCtp', 'select
  distinct 
  patient_id,
  patient_name,
  study_instance_uid,
  study_date,
  series_instance_uid,
  modality,
  count (distinct file_id) as num_files
from
  file_patient natural left join
  file_study natural left join
  file_series f
where
 not exists (select file_id from ctp_file c where c.file_id = f.file_id)
group by
  patient_id, patient_name, study_instance_uid, study_date,
  series_instance_uid, modality
order by 
  patient_id, study_date,
  modality
', '{}', 
                    ARRAY['patient_id', 'patient_name', 'study_instance_uid', 'study_date', 'series_instance_uid', 'modality', 'num_files'], ARRAY['adding_ctp', 'find_patients', 'no_ctp_details'], 'posda_files', 'Get Series in A Collection
')
        ;

            insert into queries
            values ('FilesInCollectionSiteForSend', 'select
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
', ARRAY['collection', 'site'], 
                    ARRAY['file_id', 'path', 'xfer_syntax', 'sop_class_uid', 'data_set_size', 'data_set_start', 'sop_instance_uid', 'digest'], ARRAY['by_collection_site', 'find_files', 'for_send'], 'posda_files', 'Get everything you need to negotiate a presentation_context
for all files in a Collection Site
')
        ;

            insert into queries
            values ('AddPidToSubprocessInvocation', 'update subprocess_invocation set
  process_pid = ?
where
  subprocess_invocation_id = ?
', ARRAY['pid', 'subprocess_invocation_id'], 
                    '{}', ARRAY['NotInteractive', 'used_in_background_processing'], 'posda_queries', 'Add a pid to a subprocess_invocation row

used in DbIf after subprocess invoked')
        ;

            insert into queries
            values ('GetListCollectionPrios', 'select collection, file_count as priority
from collection_count_per_round
order by collection

', '{}', 
                    ARRAY['collection', 'priority'], ARRAY['NotInteractive', 'Backlog', 'Backlog Monitor', 'backlog_status'], 'posda_backlog', 'Get a list of all collections defined in backlog with priorities.')
        ;

            insert into queries
            values ('StudiesWithMultiplePatientIds', 'select
  distinct study_instance_uid,
  patient_id
from
  file_study natural join file_patient natural join ctp_file                                                      
where study_instance_uid in (                                                                                                                                                        
  select distinct study_instance_uid from (                                                                                                                                                                                    
     select * from (
        select distinct study_instance_uid, count(*) from (
          select distinct study_instance_uid, patient_id
          from file_study natural join file_patient natural join ctp_file
          where project_name = ? and visibility is null
        ) as foo group by study_instance_uid
      ) as foo where count > 1
   ) as foo
) and
visibility is null', ARRAY['collection'], 
                    ARRAY['study_instance_uid', 'patient_id'], ARRAY['by_study', 'consistency', 'study_consistency'], 'posda_files', 'Find Inconsistent Studies
')
        ;

            insert into queries
            values ('GetDciodvfyErrorMayNotBePres', 'select
  dciodvfy_error_id as id
from 
  dciodvfy_error
where
  error_type = ''MayNotBePresent''
  and error_tag = ?
  and error_reason = ?', ARRAY['error_tag', 'error_reason'], 
                    ARRAY['id'], ARRAY['NotInteractive', 'used_in_dciodvfy'], 'posda_phi_simple', 'Get an dciodvfy_errors row by error_text (if present)')
        ;

            insert into queries
            values ('GetFilesNotImportedInDicomFileCompare', 'select
  count(*)
from
  dicom_edit_compare
where 
  from_file_digest in 
  (
    select from_file_digest from 
    (
      select from_file_digest from dicom_edit_compare dec
      where not exists
      (
        select file_id from file f where dec.to_file_digest = f.digest
       ) 
       and edit_command_file_id = ?
      except
      select distinct from_file_digest 
      from dicom_edit_compare dec, file f natural join ctp_file
      where dec.from_file_digest = f.digest and visibility is null and edit_command_file_id = ?

    ) as foo
  )
  and edit_command_file_id = ?
', ARRAY['command_file_id', 'command_file_id_1', 'command_file_id_2'], 
                    ARRAY['count'], ARRAY['used_in_file_import_into_posda', 'used_in_file_migration'], 'posda_files', 'Get Files hidden but replacement not imported')
        ;

            insert into queries
            values ('CountsByCollectionSiteExcludingSeriesByDescription', 'select
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
  project_name = ? and site_name = ? and visibility is null and
  series_description not like ?
group by
  patient_id, image_type, modality, study_date, study_description,
  series_description, study_instance_uid, series_instance_uid,
  manufacturer, manuf_model_name, software_versions
order by
  patient_id, study_instance_uid, series_instance_uid, image_type,
  modality, study_date, study_description,
  series_description,
  manufacturer, manuf_model_name, software_versions
', ARRAY['collection', 'site', 'series_description_exclusion_pattern'], 
                    ARRAY['patient_id', 'image_type', 'modality', 'study_date', 'study_description', 'series_description', 'study_instance_uid', 'series_instance_uid', 'manufacturer', 'manuf_model_name', 'software_versions', 'num_sops', 'num_files'], ARRAY['counts'], 'posda_files', 'Counts query by Collection, Site
')
        ;

            insert into queries
            values ('background_emails', 'select 
  background_subprocess_report_id as id, 
  button_name, operation_name, invoking_user, when_invoked, file_id, name
from background_subprocess_report natural join background_subprocess natural join subprocess_invocation where invoking_user = ? and name = ''Email''
order by when_invoked desc', ARRAY['invoking_user'], 
                    ARRAY['id', 'button_name', 'operation_name', 'invoking_user', 'when_invoked', 'file_id', 'name'], ARRAY['meta', 'test', 'hello', 'query_tabs', 'bills_test', 'subprocess'], 'posda_queries', 'Add a filter to a tab')
        ;

            insert into queries
            values ('GetLoadPathByImportEventIdAndFileId', 'select file_name from file_import where file_id = ? and import_event_id = ?', ARRAY['file_id', 'import_event_id'], 
                    ARRAY['file_name'], ARRAY['import_events', 'QIN-GBM-DSC-MRI-DRO/Barrow'], 'posda_files', 'Counts query by Collection, Site
')
        ;

            insert into queries
            values ('DistinctSeriesByCollectionSiteModality', 'select distinct series_instance_uid, dicom_file_type, modality, count(*)
from (
select distinct series_instance_uid, sop_instance_uid, dicom_file_type, modality from (
select
   distinct series_instance_uid, modality, sop_instance_uid,
   file_id, dicom_file_type
 from file_series natural join file_sop_common
   natural join ctp_file natural join dicom_file
where
  project_name = ? and site_name = ? and modality = ?
  and visibility is null)
as foo
group by series_instance_uid, sop_instance_uid, dicom_file_type, modality)
as foo
group by series_instance_uid, dicom_file_type, modality
', ARRAY['project_name', 'site_name', 'modality'], 
                    ARRAY['series_instance_uid', 'dicom_file_type', 'modality', 'count'], ARRAY['by_collection', 'find_series', 'compare_collection_site', 'search_series', 'edit_files', 'simple_phi'], 'posda_files', 'Get Series in A Collection, site with dicom_file_type, modality, and sop_count
')
        ;

            insert into queries
            values ('ListOfUncategorizedDciodvfyWarnings', 'select distinct warning_text, count(*)  as num_occurances from dciodvfy_warning
where
  warning_type = ''Uncategorized''
group by 
warning_text', '{}', 
                    ARRAY['warning_text', 'num_occurances'], ARRAY['tag_usage', 'dciodvfy'], 'posda_phi_simple', 'All dciodvfy uncategorized warnings in DB')
        ;

            insert into queries
            values ('InsertActivityTimepointFile', 'insert into activity_timepoint_file(
  activity_timepoint_id, file_id
) values (
  ?, ?
)', ARRAY['actiity_id', 'file_id'], 
                    '{}', ARRAY['activity_timepoint_support'], 'posda_queries', 'Create An Activity Timepoint

')
        ;

            insert into queries
            values ('FilesIdsInSeriesWithVisibilityAndCollection', 'select
  file_id, project_name as collection, visibility
from
  ctp_file
  natural join file_series
where
  series_instance_uid = ?
', ARRAY['series_instance_uid'], 
                    ARRAY['file_id', 'collection', 'visibility'], ARRAY['by_series', 'find_files', 'used_in_simple_phi'], 'posda_files', 'Get files in a series from posda database
')
        ;

            insert into queries
            values ('SeriesVisualReviewResultsByCollectionSiteStatusVisible', 'select 
  distinct series_instance_uid,
  dicom_file_type,
  modality,
  review_status,
  count(distinct file_id) as num_files
from 
  dicom_file natural join 
  file_series natural join 
  ctp_file join 
  image_equivalence_class using(series_instance_uid)
where
  project_name = ? and
  site_name = ? and review_status = ?
  and visibility is null
group by
  series_instance_uid,
  dicom_file_type,
  modality,
  review_status
order by
  series_instance_uid', ARRAY['project_name', 'site_name', 'status'], 
                    ARRAY['series_instance_uid', 'dicom_file_type', 'modality', 'review_status', 'num_files'], ARRAY['find_series', 'equivalence_classes', 'consistency', 'visual_review_results', 'hide_files'], 'posda_files', 'Get visual review status report by series for Collection, Site')
        ;

            insert into queries
            values ('GetBackgroundReportFilename', 'select root_path || ''/'' || rel_path as filename
from file
natural join file_location
natural join file_storage_root
where file_id = ?
', ARRAY['file_id'], 
                    ARRAY['filename'], '{}', 'posda_files', 'Get the filename of a background report, by file_id')
        ;

            insert into queries
            values ('CountsCollectionDateRangeBySubject', 'select
  distinct
    patient_id,
    count(distinct sop_instance_uid) as num_sops,
    count(distinct file_id) as num_files,
    min(import_time) as earliest,
    max(import_time) as latest
from
  ctp_file join file_patient using(file_id)
  join dicom_file using(file_id)
  join file_series using(file_id)
  join file_sop_common using(file_id)
  join file_study using(file_id)
  join file_equipment using(file_id)
  join file_import using(file_id)
  join import_event using(import_event_id)
  left join file_image using(file_id)
  left join image using (image_id)
where
  file_id in (
    select file_id 
    from file_import natural join import_event
    where import_time > ? and import_time < ?
  ) and project_name = ? and visibility is null
group by
  patient_id
order by
  patient_id
', ARRAY['from', 'to', 'collection'], 
                    ARRAY['patient_id', 'num_sops', 'num_files', 'earliest', 'latest'], ARRAY['counts', 'count_queries'], 'posda_files', 'Counts query by Collection, Site
')
        ;

            insert into queries
            values ('AllPixelInfoByBitDepth', 'select
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
', ARRAY['bits_allocated'], 
                    ARRAY['file_id', 'file', 'file_offset', 'size', 'bits_stored', 'bits_allocated', 'pixel_representation', 'number_of_frames', 'samples_per_pixel', 'pixel_rows', 'pixel_columns', 'photometric_interpretation', 'modality'], '{}', 'posda_files', 'Get pixel descriptors for all files
')
        ;

            insert into queries
            values ('SubjectsWithModalityByCollectionSite', 'select
  distinct patient_id, count(*) as num_files
from
  ctp_file natural join file_patient natural join file_series
where
  modality = ? and project_name = ? and site_name = ?
group by patient_id
order by patient_id
', ARRAY['modality', 'project_name', 'site_name'], 
                    ARRAY['patient_id', 'num_files'], ARRAY['FindSubjects'], 'posda_files', 'Find All Subjects with given modality in Collection, Site
')
        ;

            insert into queries
            values ('InsertIntoFileRoiImageLinkage', 'insert into file_roi_image_linkage(
  file_id,
  roi_id,
  linked_sop_instance_uid,
  linked_sop_class_uid,
  contour_file_offset,
  contour_length,
  contour_digest,
  num_points,
  contour_type
) values (
  ?, ?, ?, ?, ?, ?, ?, ?, ?
)', ARRAY['file_id', 'roi_id', 'linked_sop_instance_uid', 'linked_sop_class_uid', 'contour_file_offset', 'contour_length', 'contour_digest', 'num_points', 'contour_type'], 
                    '{}', ARRAY['NotInteractive', 'used_in_processing_structure_set_linkages'], 'posda_files', 'Get the file_storage root for newly created files')
        ;

            insert into queries
            values ('SopsDupsInDifferentSeriesByLikeCollection', 'select
  distinct collection, site, subj_id, study_instance_uid, series_instance_uid, sop_instance_uid,
  file_id, file_path
from (
  select
    distinct project_name as collection,
    site_name as site, patient_id as subj_id,
    study_instance_uid, series_instance_uid,
    sop_instance_uid,
    file_id, root_path ||''/'' || rel_path as file_path
  from
    ctp_file natural join file_sop_common
    natural join file_patient natural join file_study natural join file_series
    join file_location using(file_id) join file_storage_root using(file_storage_root_id)
  where
    sop_instance_uid in (
      select distinct sop_instance_uid from (
        select distinct sop_instance_uid, count(distinct file_id) from (
          select distinct file_id, sop_instance_uid 
          from
            ctp_file natural join file_sop_common
            natural join file_patient
          where
            visibility is null and project_name like ?
        ) as foo group by sop_instance_uid order by count desc
      ) as foo 
      where count > 1
    )
    and visibility is null
  ) as foo
order by sop_instance_uid

', ARRAY['collection'], 
                    ARRAY['collection', 'site', 'subj_id', 'study_instance_uid', 'series_instance_uid', 'sop_instance_uid', 'file_id', 'file_path'], ARRAY['duplicates', 'dup_sops', 'hide_dup_sops', 'sops_different_series'], 'posda_files', 'Return a count of duplicate SOP Instance UIDs
')
        ;

            insert into queries
            values ('GetDicomFilesByImportName', 'select
  distinct file_id                                                                                                                                                                                                                                                                                                                                                                                                                                from
  import_event natural join file_import natural join dicom_file
where
  import_type = ''posda-api import'' and import_comment = ?', ARRAY['import_name'], 
                    ARRAY['file_id'], ARRAY['posda_files', 'sops', 'BySopInstance', 'by_file'], 'posda_files', 'Get Collection, Site, Patient, Study Hierarchy in which SOP resides
')
        ;

            insert into queries
            values ('RoundInfoById', 'select
  round_id, collection,
  round_created,
  round_start,  
  round_end,
  round_aborted,
  wait_count,
  process_count,
  num_entered,
  num_failed,
  num_dups,
  num_requests,
  priority
from
  round natural join round_counts natural join round_collection
where round_id = ?
order by round_id, collection', ARRAY['round_id'], 
                    ARRAY['round_id', 'collection', 'round_created', 'round_start', 'round_end', 'round_aborted', 'wait_count', 'process_count', 'num_entered', 'num_failed', 'num_dups', 'num_requests', 'priority'], ARRAY['NotInteractive', 'Backlog', 'Backlog Monitor'], 'posda_backlog', 'Summary of round by id')
        ;

            insert into queries
            values ('CreateVisualReviewInstance', 'insert into visual_review_instance(
  visual_review_reason,
  visual_review_scheduler,
  visual_review_num_series,
  when_visual_review_scheduled
) values (
  ?, ?, ?, now()
)', ARRAY['visual_review_reason', 'visual_review_scheduler', 'visual_review_num_series'], 
                    '{}', ARRAY['find_series', 'equivalence_classes', 'consistency', 'visual_review'], 'posda_files', 'Create a visual review instance')
        ;

            insert into queries
            values ('SeriesNotLikeWithModality', 'select
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
', ARRAY['modality', 'collection', 'site', 'description_not_matching'], 
                    ARRAY['series_instance_uid', 'series_description', 'count'], ARRAY['find_series', 'pattern', 'posda_files'], 'posda_files', 'Select series not matching pattern by modality
')
        ;

            insert into queries
            values ('SeriesListByCollectionSiteModalityVisualReviewStatus', 'select 
  distinct
  series_instance_uid,
  dicom_file_type,
  modality,
  review_status,
  count(distinct file_id) as num_files
from 
  dicom_file natural join 
  file_series natural join 
  ctp_file join 
  image_equivalence_class using(series_instance_uid)
where
  project_name = ? and
  site_name = ? and
  review_status = ?
  and modality = ?
group by
  series_instance_uid,
  dicom_file_type,
  modality,
  review_status
', ARRAY['project_name', 'site_name', 'review_status', 'modality'], 
                    ARRAY['dicom_file_type', 'modality', 'review_status', 'num_series', 'num_files', 'series_instance_uid'], ARRAY['find_series', 'equivalence_classes', 'consistency', 'visual_review_results', 'hide_files'], 'posda_files', 'Get visual review status report by series for Collection, Site')
        ;

            insert into queries
            values ('GetNonDicomEditCompareToFiles', 'select 
  path,
  file_id,
  collection,
  visibility
from 
  (
    select to_file_path as path, to_file_digest as digest
    from non_dicom_edit_compare
    where subprocess_invocation_id = ?
  ) as foo natural left join
  file natural left join non_dicom_file', ARRAY['subprocess_invocation_id'], 
                    ARRAY['path', 'file_id', 'collection', 'visibility'], ARRAY['adding_ctp', 'for_scripting', 'non_dicom_import'], 'posda_files', 'Get a list of to files from the dicom_edit_compare table for a particular edit instance, with file_id and visibility

NB: Before import:
       There should be no file_id (i.e. file has not been imported)  And there should be no collection.
       (i.e. normally file_id, collection, and visibility are all null).')
        ;

            insert into queries
            values ('CloseDicomFileEditEvent', 'update dicom_edit_event
  set time_completed = now(),
  report_file = ?,
  notification_sent = ?
where
  dicom_edit_event_id = ?', ARRAY['report_file_id', 'notify', 'dicom_edit_event_id'], 
                    '{}', ARRAY['Insert', 'NotInteractive', 'used_in_import_edited_files'], 'posda_files', 'Increment edits done in dicom_edit_event table
For use in scripts
Not really intended for interactive use
')
        ;

            insert into queries
            values ('SeriesVisualReviewResultsByCollectionSiteSummary', 'select 
  distinct
  dicom_file_type,
  modality,
  review_status,
  count(distinct series_instance_uid) as num_series,
  count(distinct file_id) as num_files
from 
  dicom_file natural join 
  file_series natural join 
  ctp_file join 
  image_equivalence_class using(series_instance_uid)
where
  project_name = ? and
  site_name = ? and visibility is null
group by
  dicom_file_type,
  modality,
  review_status
', ARRAY['project_name', 'site_name'], 
                    ARRAY['dicom_file_type', 'modality', 'review_status', 'num_series', 'num_files'], ARRAY['find_series', 'equivalence_classes', 'consistency', 'visual_review_results', 'hide_files'], 'posda_files', 'Get visual review status report by series for Collection, Site')
        ;

            insert into queries
            values ('SeriesByLikeDescriptionAndCollection', 'select distinct
  series_instance_uid, series_description
from
  file_series natural join ctp_file
where project_name = ? and series_description like ?
', ARRAY['collection', 'pattern'], 
                    ARRAY['series_instance_uid', 'series_description'], ARRAY['find_series'], 'posda_files', 'Get a list of Series by Collection matching Series Description
')
        ;

            insert into queries
            values ('LatestActivityTimepointsForActivity', 'select
  activity_id, a.when_created as activity_created,
  brief_description as activity_description, activity_timepoint_id,
  t.when_created as timepoint_created, 
  comment, creating_user
from
  activity a join activity_timepoint t using(activity_id)
where
  a.when_closed is null and
  activity_id = ?
order by activity_timepoint_id desc limit 1', ARRAY['activity_id'], 
                    ARRAY['activity_id', 'activity_created', 'activity_description', 'activity_timepoint_id', 'timepoint_created', 'comment', 'creating_user'], ARRAY['activity_timepoint_support'], 'posda_queries', 'Get Series in A Collection, site with dicom_file_type, modality, and sop_count
')
        ;

            insert into queries
            values ('FilesByModalityByCollectionSiteDateRange', 'select
  distinct patient_id, modality, series_instance_uid, sop_instance_uid, 
  root_path || ''/'' || file_location.rel_path as path,
  min(import_time) as earliest,
  max(import_time) as latest
from
  file_patient natural join file_series natural join file_sop_common natural join ctp_file
  natural join file_location natural join file_storage_root
  join file_import using(file_id) join import_event using(import_event_id)
where
  modality = ? and
  project_name = ? and 
  site_name = ? and
  import_time > ? and import_time < ? and
  visibility is null
group by patient_id, modality, series_instance_uid, sop_instance_uid, path', ARRAY['modality', 'collection', 'site', 'from', 'to'], 
                    ARRAY['patient_id', 'modality', 'series_instance_uid', 'sop_instance_uid', 'path', 'earliest', 'latest'], ARRAY['FindSubjects', 'intake', 'FindFiles'], 'posda_files', 'Find All Files with given modality in Collection, Site')
        ;

            insert into queries
            values ('SubjectCountByCollectionSite', 'select
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
', ARRAY['collection', 'site'], 
                    ARRAY['patient_id', 'count'], ARRAY['counts'], 'posda_files', 'Counts query by Collection, Site
')
        ;

            insert into queries
            values ('IntakeFilesInSeries', 'select
  dicom_file_uri as file_path
from
  general_image
where
  series_instance_uid = ?
', ARRAY['series_instance_uid'], 
                    ARRAY['file_path'], ARRAY['intake', 'used_in_simple_phi'], 'intake', 'List of all Series By Collection, Site on Intake
')
        ;

            insert into queries
            values ('ReviewEditsBySiteCollectionLike', 'select
  distinct project_name,
  site_name,
  series_instance_uid, 
  new_visibility, 
  reason_for,
  min(time_of_change) as earliest,
  max(time_of_change) as latest,
  count(*) as num_files
from
  file_visibility_change natural join
  ctp_file natural join
  file_series
where 
  site_name = ? and project_name like ?
group by 
  project_name, site_name, series_instance_uid, new_visibility, reason_for', ARRAY['site', 'CollectionLike'], 
                    ARRAY['project_name', 'site_name', 'series_instance_uid', 'new_visibility', 'reason_for', 'earliest', 'latest', 'num_files'], ARRAY['Hierarchy', 'review_visibility_changes'], 'posda_files', 'Show all file visibility changes by series for site')
        ;

            insert into queries
            values ('GetSubprocessLines', 'select
  line
from subprocess_lines
where
  subprocess_invocation_id = ?
order by line_number
', ARRAY['subprocess_invocation_id'], 
                    ARRAY['line'], ARRAY['AllCollections', 'queries', 'activity_support'], 'posda_queries', 'Get a list of available queries')
        ;

            insert into queries
            values ('OneFileInSeries', 'select
  distinct root_path || ''/'' || rel_path as file
from
  file_location natural join file_storage_root
  natural join ctp_file
  natural join file_series
where
  series_instance_uid = ? and visibility is null
limit 1
', ARRAY['series_instance_uid'], 
                    ARRAY['file'], ARRAY['by_series', 'find_files', 'used_in_simple_phi'], 'posda_files', 'Get files in a series from posda database
')
        ;

            insert into queries
            values ('DistinctStudySeriesByCollectionSite', 'select distinct study_instance_uid as study_uid, series_instance_uid as series_uid, patient_id, dicom_file_type, modality, count(*)
from (
select distinct study_instance_uid, series_instance_uid, patient_id, sop_instance_uid, dicom_file_type, modality from (
select
   distinct study_instance_uid, series_instance_uid, patient_id, modality, sop_instance_uid,
   file_id, dicom_file_type
 from file_series natural join file_sop_common
   natural join ctp_file natural join dicom_file natural join file_patient natural join file_study
where
  project_name = ? and site_name = ?
  and visibility is null)
as foo
group by study_instance_uid, series_instance_uid, patient_id, sop_instance_uid, dicom_file_type, modality)
as foo
group by study_uid, series_uid, patient_id, dicom_file_type, modality
', ARRAY['collection', 'site'], 
                    ARRAY['study_uid', 'series_uid', 'patient_id', 'dicom_file_type', 'modality', 'count'], ARRAY['by_collection', 'find_series', 'search_series', 'send_series', 'phi_simple', 'simple_phi'], 'posda_files', 'Get Series in A Collection
')
        ;

            insert into queries
            values ('CollectionSiteWithDicomFileTypesNotProcessed', 'select 
  distinct project_name as collection, site_name as site, dicom_file_type, count(distinct file_id)
from
  dicom_file d natural join ctp_file
where
  visibility is null  and
  not exists (
    select file_id 
    from file_series s
    where s.file_id = d.file_id
  )
group by project_name, site_name, dicom_file_type', '{}', 
                    ARRAY['collection', 'site', 'dicom_file_type', 'count'], ARRAY['dicom_file_type'], 'posda_files', 'List of Distinct Collection, Site, Dicom File Types which have unprocessed DICOM files
')
        ;

            insert into queries
            values ('PublicFilesInSeries', 'select
  dicom_file_uri as file_path
from
  general_image
where
  series_instance_uid = ?
', ARRAY['series_instance_uid'], 
                    ARRAY['file_path'], ARRAY['public', 'used_in_simple_phi'], 'public', 'List of all Series By Collection, Site on Intake
')
        ;

            insert into queries
            values ('GetNonDicomEditCompareDisposition', 'select
  num_edits_scheduled,
  num_compares_with_diffs,
  num_compares_without_diffs,
  current_disposition,
  dest_dir
from
  non_dicom_edit_compare_disposition
where
  subprocess_invocation_id = ?
  ', ARRAY['subprocess_invocation_id'], 
                    ARRAY['num_edits_scheduled', 'num_compares_with_diffs', 'num_compares_without_diffs', 'current_disposition', 'dest_dir'], ARRAY['adding_ctp', 'for_scripting', 'non_dicom_import'], 'posda_files', 'Retrieve entries from patient_mapping table')
        ;

            insert into queries
            values ('MarkDicomFileAsNotHavingPixelData', 'update dicom_file set has_pixel_data = false where file_id = ?', ARRAY['file_id'], 
                    '{}', ARRAY['adding_pixels_to_dicom_file'], 'posda_files', 'see name')
        ;

            insert into queries
            values ('SimplePublicPhiReportSelectedVR', 'select 
  distinct element_sig_pattern as element, vr, value, tag_name, count(*) as num_series
from element_value_occurance natural join element_seen natural join value_seen
where 
  phi_scan_instance_id = ? and
  not is_private and
  vr in (''SH'', ''OB'', ''PN'', ''DA'', ''ST'', ''AS'', ''DT'', ''LO'', ''UI'', ''CS'', ''AE'', ''LT'', ''ST'', ''UC'', ''UN'', ''UR'', ''UT'')
group by element_sig_pattern, vr, value, tag_name
order by vr, element_sig_pattern, value', ARRAY['scan_id'], 
                    ARRAY['element', 'vr', 'value', 'tag_name', 'num_series'], ARRAY['tag_usage', 'simple_phi'], 'posda_phi_simple', 'Status of PHI scans
')
        ;

            insert into queries
            values ('TotalsByDateRange', 'select distinct
	project_name,
	site_name,

	count(distinct patient_id) as num_subjects,
	count(distinct study_instance_uid) as num_studies,
	count(distinct series_instance_uid) as num_series,
	count(distinct sop_instance_uid) as total_files
from
	import_event
	natural join file_import
	natural join ctp_file
	natural join file_study
	natural join file_series
	natural join file_sop_common
	natural join file_patient

where
	visibility is null
	and import_time between ? and ? 

group by
	project_name,
	site_name
', ARRAY['from', 'to'], 
                    ARRAY['project_name', 'site_name', 'num_subjects', 'num_studies', 'num_series', 'total_files'], ARRAY['AllCollections', 'DateRange', 'Kirk', 'Totals', 'count_queries', 'end_of_month'], 'posda_files', 'Get posda totals by date range

**WARNING:**  This query can run for a **LONG** time if you give it a large date range.
It is intended for short date ranges (i.e. "What came in last night?" or "What came in last month?")
')
        ;

            insert into queries
            values ('ApiImportEvents', 'select
  import_event_id, import_comment, import_time,
  import_close_time - import_time as duration, 
  count(distinct file_id) as num_images,
  (import_close_time - import_time) / count(distinct file_id) as per_sec
from 
  import_event natural join file_import
where
  import_comment like ? and import_type = ''posda-api import''
group by import_event_id, import_comment, import_time, import_close_time', ARRAY['import_comment_like'], 
                    ARRAY['import_event_id', 'import_comment', 'import_time', 'duration', 'num_images', 'per_sec'], ARRAY['import_events'], 'posda_files', 'Get Import Events by matching comment')
        ;

            insert into queries
            values ('ListOfPrivateElementsWithNullDispositionsByScanId', 'select
  distinct element_signature, vr , private_disposition as disposition,
  element_signature_id, name_chain
from
  element_signature natural join scan_element natural join series_scan
where
  is_private and scan_event_id = ? and private_disposition is null
order by element_signature
', ARRAY['scan_id'], 
                    ARRAY['element_signature', 'vr', 'disposition', 'element_signature_id', 'name_chain'], ARRAY['NotInteractive', 'Update', 'ElementDisposition'], 'posda_phi', 'Get Disposition of element by sig and VR')
        ;

            insert into queries
            values ('PrivateTagCountValueList', 'select 
  distinct element_signature, vr, value, private_disposition as disposition, count(*) as num_files
from
  element_signature natural join scan_element natural join seen_value
where
  is_private
group by element_signature, vr, value, private_disposition
order by element_signature, vr, value', '{}', 
                    ARRAY['vr', 'value', 'element_signature', 'num_files', 'disposition'], ARRAY['postgres_status', 'PrivateTagKb', 'NotInteractive'], 'posda_phi', 'Get List of Private Tags with All Values
')
        ;

            insert into queries
            values ('dicom_files_with_no_ctp_file', 'select distinct patient_id, dicom_file_type, modality, count(distinct file_id) as num_files
from dicom_file d natural join file_patient natural join file_series
where not exists (select file_id from ctp_file c where c.file_id = d.file_id) 
group by patient_id, dicom_file_type, modality', '{}', 
                    ARRAY['patient_id', 'dicom_file_type', 'modality', 'num_files'], ARRAY['meta', 'test', 'hello', 'query_tabs', 'bills_test'], 'posda_files', 'Add a filter to a tab')
        ;

            insert into queries
            values ('GetNonDicomFileById', 'select 
  file_id, file_type, file_sub_type, collection, site, subject, visibility, date_last_categorized
from
  non_dicom_file
where
  file_id = ?', ARRAY['file_id'], 
                    ARRAY['file_id', 'file_type', 'file_sub_type', 'collection', 'site', 'subject', 'visibility', 'date_last_categorized'], ARRAY['radcomp'], 'posda_files', 'Add a filter to a tab')
        ;

            insert into queries
            values ('FinalizeVisualReviewScheduling', 'update visual_review_instance set
  when_visual_review_sched_complete = now()
where
  visual_review_instance_id = ?', ARRAY['visual_review_instance_id'], 
                    '{}', ARRAY['find_series', 'equivalence_classes', 'consistency', 'visual_review'], 'posda_files', 'Get Id of Visual Review Instance')
        ;

            insert into queries
            values ('GetNLocationsAndDigestsByFileStorageRootId', 'select
  file_id, digest, rel_path
from file_location natural join file
where
  file_storage_root_id = ?
limit ?', ARRAY['file_storage_root_id', 'n'], 
                    ARRAY['file_id', 'digest', 'rel_path'], ARRAY['used_in_file_import_into_posda', 'used_in_file_migration'], 'posda_files', 'Get root_path for a file_storage_root
')
        ;

            insert into queries
            values ('CreateDciodvfyScanInstance', 'insert into dciodvfy_scan_instance(
  type_of_unit,
  description_of_scan,
  number_units,
  scanned_so_far,
  start_time
) values (
  ?, ?, ?, 0, now()
)', ARRAY['type_of_unit', 'description_of_scan', 'number_units'], 
                    '{}', ARRAY['NotInteractive', 'used_in_dciodvfy'], 'posda_phi_simple', 'Create a dciodvfy_scan_instance row')
        ;

            insert into queries
            values ('GetPopupDefinition', 'select
  command_line, input_line_format,
  operation_name, operation_type,
  tags
from 
  spreadsheet_operation
where
  operation_name = ?
', ARRAY['operation_name'], 
                    NULL, ARRAY['NotInteractive', 'used_in_process_popup'], 'posda_queries', 'N
o
n
e')
        ;

            insert into queries
            values ('SeriesFileCount', 'select
  count(distinct file_id) as num_files
from
  file_series natural join
  ctp_file
where 
    series_instance_uid = ? and visibility is null
', ARRAY['series_instance_uid'], 
                    ARRAY['num_files'], ARRAY['by_series_instance_uid', 'posda_files', 'sops'], 'posda_files', 'Get Collection, Site, Patient, Study Hierarchy in which series resides
')
        ;

            insert into queries
            values ('RoiInfoByFileIdWithCounts', 'select
  distinct roi_id, for_uid, linked_sop_instance_uid,
  max_x, max_y, max_z,
  min_x, min_y, min_z,
  roi_name, roi_description , roi_interpreted_type,
  count(*) as num_contours
from
  roi natural join file_roi_image_linkage 
where file_id = ?
group by 
  roi_id, for_uid, linked_sop_instance_uid,
  max_x, max_y, max_z,
  min_x, min_y, min_z,
  roi_name,
  roi_description, roi_interpreted_type', ARRAY['file_id'], 
                    ARRAY['roi_id', 'for_uid', 'linked_sop_instance_uid', 'max_x', 'max_y', 'max_z', 'min_x', 'min_y', 'min_z', 'roi_name', 'roi_description', 'roi_interpreted_type', 'num_contours'], ARRAY['LinkageChecks', 'used_in_struct_linkage_check'], 'posda_files', 'Get list of Roi with info by file_id

')
        ;

            insert into queries
            values ('PatientStudySeriesFileHierarchyByCollectionSiteExt', 'select distinct
  patient_id,
  study_instance_uid,
  series_instance_uid,
  dicom_file_type,
  modality,
  count(*)
from
  file_study natural join
  dicom_file natural join
  ctp_file natural join
  file_series natural join 
  file_patient natural join
  file_sop_common
where 
  file_id in (
    select distinct file_id
    from ctp_file
    where project_name = ? and site_name = ? and visibility is null
  )
group by
  patient_id,
  study_instance_uid,
  series_instance_uid,
  dicom_file_type,
  modality
order by patient_id, study_instance_uid, series_instance_uid', ARRAY['collection', 'site'], 
                    ARRAY['patient_id', 'study_instance_uid', 'series_instance_uid', 'dicom_file_type', 'modality', 'count'], ARRAY['Hierarchy'], 'posda_files', 'Construct list of files in a collection, site in a Patient, Study, Series, with Modality of file')
        ;

            insert into queries
            values ('FindFilesInStudyWithDescriptionByStudyUID', 'select distinct
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
', ARRAY['study_instance_uid'], 
                    ARRAY['study_instance_uid', 'count', 'study_description', 'study_date', 'study_time', 'referring_phy_name', 'study_id', 'accession_number', 'phys_of_record', 'phys_reading', 'admitting_diag'], ARRAY['by_study', 'consistency'], 'posda_files', 'Find SopInstanceUID and Description for All Files In Study
')
        ;

            insert into queries
            values ('VisibleImagesWithDetailsAndFileIdByVisualId', 'select 
  distinct patient_id, study_instance_uid, series_instance_uid, sop_instance_uid, modality, 
  file_id
from 
  file_patient natural join file_study natural join file_series natural join 
  file_sop_common natural join ctp_file
where series_instance_uid in (
  select
    distinct series_instance_uid
  from
    image_equivalence_class natural join file_series natural join
    image_equivalence_class_input_image natural join dicom_file natural join ctp_file
  where
    visual_review_instance_id = ? 
)
and visibility is null', ARRAY['visual_review_instance_id'], 
                    ARRAY['patient_id', 'study_instance_uid', 'series_instance_uid', 'sop_instance_uid', 'modality', 'file_id'], ARRAY['by_collection', 'find_series', 'compare_collection_site', 'search_series', 'edit_files', 'simple_phi', 'dciodvfy', 'ctp_details', 'select_for_phi', 'visual_review_new_workflow'], 'posda_files', 'Get Series in A Collection, site with dicom_file_type, modality, and sop_count
')
        ;

            insert into queries
            values ('GetSsVolume', 'select 
  for_uid, study_instance_uid, series_instance_uid,
  sop_class as sop_class_uid, sop_instance as sop_instance_uid
  from ss_for natural join ss_volume where structure_set_id in (
    select 
      structure_set_id 
    from
      file_structure_set fs, file_sop_common sc
    where
      sc.file_id = fs.file_id and sop_instance_uid = ?
)
', ARRAY['sop_instance_uid'], 
                    ARRAY['for_uid', 'study_instance_uid', 'series_instance_uid', 'sop_class_uid', 'sop_instance_uid'], ARRAY['Structure Sets', 'sops', 'LinkageChecks'], 'posda_files', 'Get Structure Set Volume

')
        ;

            insert into queries
            values ('VisualReviewStatusDetailsOld', 'select 
  distinct image_equivalence_class_id, series_instance_uid, processing_status, review_status
from 
  image_equivalence_class natural join image_equivalence_class_input_image natural join dicom_file
where 
  visual_review_instance_id = ? and processing_status = ? and 
  (review_status= ?  or review_status is null)  and dicom_file_type = ?', ARRAY['visual_review_instance_id', 'processing_status', 'review_status', 'dicom_file_type'], 
                    ARRAY['image_equivalence_class_id', 'series_instance_uid', 'processing_status', 'review_status'], ARRAY['by_collection', 'find_series', 'compare_collection_site', 'search_series', 'edit_files', 'simple_phi', 'dciodvfy', 'ctp_details', 'select_for_phi', 'visual_review_new_workflow'], 'posda_files', 'Get Series in A Collection, site with dicom_file_type, modality, and sop_count
')
        ;

            insert into queries
            values ('SimplePhiReportAllRelevantPrivateOnlyWithMetaQuotes', 'select 
  distinct ''<'' || element_sig_pattern || ''>''  as element,
  vr, ''<'' || value || ''>'' as q_value, tag_name as description, private_disposition as disp, count(*) as num_series
from element_value_occurance natural join element_seen natural join value_seen
where 
  phi_scan_instance_id = ? and is_private and private_disposition not in (''d'', ''na'', ''o'', ''h'')
group by element_sig_pattern, vr, value, description, disp
order by vr, element', ARRAY['scan_id'], 
                    ARRAY['element', 'vr', 'q_value', 'description', 'disp', 'num_series'], ARRAY['adding_ctp', 'for_scripting', 'phi_reports'], 'posda_phi_simple', 'Simple Phi Report with Meta Quotes')
        ;

            insert into queries
            values ('GetCtpFileRow', 'select file_id from ctp_file where file_id = ?', ARRAY['file_id'], 
                    ARRAY['file_id'], ARRAY['meta', 'test', 'hello', 'query_tabs', 'bills_test'], 'posda_files', 'See if ctp_file_row exists')
        ;

            insert into queries
            values ('TagsSeenPrivateWithCount', 'select
  distinct element_signature, 
  vr, 
  private_disposition, 
  name_chain, 
  count(distinct value) as num_values
from
  element_signature natural left join
  scan_element natural left join
  seen_value
where is_private
group by element_signature, vr, private_disposition, name_chain
order by element_signature, vr', '{}', 
                    ARRAY['element_signature', 'vr', 'private_disposition', 'name_chain', 'num_values'], ARRAY['by_collection', 'find_series', 'compare_collection_site', 'search_series', 'edit_files', 'phi_maint'], 'posda_phi', 'Get all the data from tags_seen in posda_phi database
')
        ;

            insert into queries
            values ('GetSpreadsheetInfoForRadcompDisp', 'select
  distinct patient_id,
  study_instance_uid as study_uid, 
  series_instance_uid as series_uid,
  baseline_date - diagnosis_date + interval ''1 day'' as shift,
  count(distinct file_id) as num_files
from
  file_patient natural join file_series natural join file_study natural join ctp_file,
  patient_mapping
where
  patient_id = to_patient_id and
  ctp_file.project_name = ? and ctp_file.visibility is null
group by
  patient_id, study_uid, series_uid, shift', ARRAY['collection'], 
                    ARRAY['patient_id', 'study_uid', 'series_uid', 'num_files', 'shift'], ARRAY['adding_ctp', 'for_scripting', 'non_dicom_phi', 'non_dicom_edit'], 'posda_files', 'Simple Phi Report with Meta Quotes')
        ;

            insert into queries
            values ('UpdateEquivalenceClassReviewStatus', 'update image_equivalence_class
set review_status = ?
where image_equivalence_class_id = ?
', ARRAY['processing_status', 'image_equivalence_class_id'], 
                    '{}', ARRAY['consistency', 'find_series', 'equivalence_classes', 'NotInteractive'], 'posda_files', 'For building series equivalence classes')
        ;

            insert into queries
            values ('GetElementDispositionVR', 'select
  element_signature_id, element_signature, vr, private_disposition as disposition, name_chain
from
  element_signature
where
  element_signature = ? and vr = ?
', ARRAY['element_signature', 'vr'], 
                    ARRAY['element_signature_id', 'element_signature', 'vr', 'disposition', 'name_chain'], ARRAY['NotInteractive', 'Update', 'ElementDisposition'], 'posda_phi', 'Get Disposition of element by sig and VR')
        ;

            insert into queries
            values ('GetPixelDescriptorByDigest', 'select
  samples_per_pixel, 
  number_of_frames, 
  pixel_rows,
  pixel_columns,
  bits_stored,
  bits_allocated,
  high_bit, 
  file_offset,
  root_path || ''/'' || rel_path as path
from
  image
  natural join unique_pixel_data
  natural join pixel_location
  join file_location using (file_id)
  join file_storage_root using (file_storage_root_id)
where digest = ?
limit 1', ARRAY['pixel_digest'], 
                    ARRAY['samples_per_pixel', 'number_of_frames', 'pixel_rows', 'pixel_columns', 'bits_stored', 'bits_allocated', 'high_bit', 'file_offset', 'path'], ARRAY['meta', 'test', 'hello'], 'posda_files', 'Find Duplicated Pixel Digest')
        ;

            insert into queries
            values ('GetFileSizeAndPathById', 'select
  root_path || ''/'' || rel_path as path,
  size
from
  file_storage_root natural join file_location natural join file 
where file_id = ?', ARRAY['file_id'], 
                    ARRAY['path', 'size'], ARRAY['radcomp'], 'posda_files', 'Add a filter to a tab')
        ;

            insert into queries
            values ('RoundSummary1', 'select
  distinct round_id,
  round_start, 
  round_end - round_start as duration, 
  round_end, 
  sum(num_entered + num_dups),
  ((round_end - round_start) / sum(num_entered + num_dups)) as sec_per_file
from
  round natural join round_collection
where
  round_end is not null 
group by 
  round_id, round_start, duration, round_end 
order by round_id', '{}', 
                    ARRAY['round_id', 'round_start', 'duration', 'round_end', 'sum', 'sec_per_file'], ARRAY['NotInteractive', 'Backlog', 'Backlog Monitor', 'backlog_analysis_reporting_tools'], 'posda_backlog', 'Summary of rounds')
        ;

            insert into queries
            values ('GetNonDicomConversionInfoById', 'select
  root_path || ''/'' || rel_path as path,
  non_dicom_file.file_type,
  file_sub_type,
  collection, site, subject, visibility, size,
  date_last_categorized
from
  file_storage_root natural join file_location natural join non_dicom_file join file using(file_id)
where file_id = ?', ARRAY['file_id'], 
                    ARRAY['path', 'file_type', 'file_sub_type', 'collection', 'site', 'subject', 'visibility', 'size', 'date_last_categorized'], ARRAY['radcomp'], 'posda_files', 'Add a filter to a tab')
        ;

            insert into queries
            values ('TagsNotInAnyFilter', 'select
  distinct tag
from(
  select unnest(tags) as tag
  from queries
) as tag_q
where tag not in (select tag
from (
  select 
     query_tab_name,
      filter_name,
      unnest(tags_enabled) as tag
  from
    query_tabs join query_tabs_query_tag_filter using(query_tab_name)
    natural join query_tag_filter
) as foo
) ', '{}', 
                    ARRAY['tag'], ARRAY['meta', 'test', 'hello', 'query_tabs', 'bills_test'], 'posda_queries', 'Add a filter to a tab')
        ;

            insert into queries
            values ('BackgroundProcessStatsWithInvokerLikeComand', 'select
  distinct operation_name, command_executed, invoking_user as invoker, 
  max(when_script_ended - when_script_started) as longest,
  min(when_script_ended - when_script_started) as shortest,
  avg(when_script_ended - when_script_started) as avg, count(*) as times_invoked,
  min(when_script_started) as first, max(when_script_started) as last
from
  background_subprocess natural join subprocess_invocation
where
  when_script_ended is not null and operation_name like ?
group by operation_name, command_executed, invoker', ARRAY['operation_name_like'], 
                    ARRAY['operation_name', 'command_executed', 'invoker', 'longest', 'shortest', 'avg', 'times_invoked', 'first', 'last'], ARRAY['invoking_user'], 'posda_files', 'Get a list of collections and sites
')
        ;

            insert into queries
            values ('GetEditStatusByDisposition', 'select
  subprocess_invocation_id as id,
  start_creation_time, end_creation_time - start_creation_time as duration,
  number_edits_scheduled as to_edit,
  number_compares_with_diffs as changed,
  number_compares_without_diffs as not_changed,
  current_disposition as disposition,
  dest_dir
from
  dicom_edit_compare_disposition
where 
  current_disposition like ?
order by start_creation_time desc', ARRAY['disposition'], 
                    ARRAY['id', 'start_creation_time', 'duration', 'to_edit', 'changed', 'not_changed', 'disposition', 'dest_dir'], ARRAY['adding_ctp', 'find_patients', 'series_selection', 'check_edits', 'testing_edit_objects', 'edit_status'], 'posda_files', 'Get List of visible patients with CTP data')
        ;

            insert into queries
            values ('AllSubjectsWithNoStatus', 'select
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
', '{}', 
                    ARRAY['patient_id', 'project_name', 'site_name', 'num_files'], ARRAY['FindSubjects', 'PatientStatus'], 'posda_files', 'All Subjects With No Patient Import Status
')
        ;

            insert into queries
            values ('GetSpreadsheetInfoForRadcompDispWithModality', 'select
  distinct patient_id,
  study_instance_uid as study_uid, 
  series_instance_uid as series_uid,
  modality,
  baseline_date - diagnosis_date + interval ''1 day'' as shift,
  count(distinct file_id) as num_files
from
  file_patient natural join file_series natural join file_study natural join ctp_file,
  patient_mapping
where
  patient_id = to_patient_id and
  ctp_file.project_name = ? and ctp_file.visibility is null
group by
  patient_id, study_uid, series_uid, modality, shift', ARRAY['collection'], 
                    ARRAY['patient_id', 'study_uid', 'series_uid', 'modality', 'num_files', 'shift'], ARRAY['adding_ctp', 'for_scripting', 'non_dicom_phi', 'non_dicom_edit'], 'posda_files', 'Simple Phi Report with Meta Quotes')
        ;

            insert into queries
            values ('RecordReportInsertion', 'insert into report_inserted(
  report_file_in_posda, report_rows_generated, background_subprocess_id
)values(
  ?, ?, ?
)', ARRAY['posda_id_of_report_file', 'rows_in_report', 'background_subprocess_id'], 
                    '{}', ARRAY['NotInteractive', 'used_in_background_processing'], 'posda_queries', 'Record the upload of a report file by a background subprocess

used in a background subprocess when a report file is uploaded')
        ;

            insert into queries
            values ('GetOpenActivities', 'select
  activity_id, brief_description, when_created, who_created, when_closed
from activity
where when_closed is null

', '{}', 
                    ARRAY['activity_id', 'brief_description', 'when_created', 'who_created', 'when_closed'], ARRAY['AllCollections', 'queries', 'activity_support'], 'posda_queries', 'Get a list of available queries')
        ;

            insert into queries
            values ('SummaryOfImportsFromEditByDateRange', 'select
  distinct import_type, min(import_time) as earliest,
  max(import_time) as latest, count(distinct import_event_id) as num_imports,
  sum(num_files) as total_files
from (
  select * from (
    select distinct import_event_id, import_time, import_type, import_comment, count(distinct file_id) as num_files
    from import_event natural join file_import
    where import_time > ? and import_time < ?
    group by import_event_id, import_time, import_type, import_comment
    order by import_time desc
  ) as foo
  where num_files > 1 and import_comment like ''%dicom_edit_compare%''
) as foo 
group by import_type;', ARRAY['from', 'to'], 
                    ARRAY['import_type', 'earliest', 'latest', 'num_imports', 'total_files'], ARRAY['downloads_by_date', 'import_events'], 'posda_files', 'Counts query by Collection, Site
')
        ;

            insert into queries
            values ('NullPatientAgeByCollection', 'select
  file_id, root_path || ''/'' || rel_path as path
from
  file_storage_root natural join file_location natural join ctp_file natural join file_patient
where
  project_name = ? and visibility is null and patient_age is null', ARRAY['collection'], 
                    ARRAY['file_id', 'path'], ARRAY['meta', 'test', 'hello', 'query_tabs', 'bills_test'], 'posda_files', 'Add a filter to a tab')
        ;

            insert into queries
            values ('GetValuesByEleVr', 'select
  distinct value
from
  element_signature
  join scan_element using(element_signature_id)
  join seen_value using (seen_value_id)
where
  element_signature = ? and vr = ?
', ARRAY['element_signature', 'vr'], 
                    ARRAY['value'], ARRAY['NotInteractive', 'Update', 'ElementDisposition'], 'posda_phi', 'Get All  values in posda_phi by element, vr')
        ;

            insert into queries
            values ('ElementsWithMultipleVRs', 'select element_signature, count from (
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
', ARRAY['scan_id'], 
                    ARRAY['element_signature', 'count'], ARRAY['tag_usage'], 'posda_phi', 'List of Elements with multiple VRs seen
')
        ;

            insert into queries
            values ('SeriesWithRGB', 'select
  distinct series_instance_uid
from
  image natural join file_image
  natural join file_series
  natural join ctp_file
where
  photometric_interpretation = ''RGB''
  and visibility is null
', '{}', 
                    ARRAY['series_instance_uid'], ARRAY['find_series', 'posda_files', 'rgb'], 'posda_files', 'Get distinct pixel types with geometry and rgb
')
        ;

            insert into queries
            values ('ActivityStuffMoreBySubprocessInvocationId', 'select
  distinct subprocess_invocation_id, background_subprocess_id, user_inbox_content_id,
  background_subprocess_report_id, file_id,
  background_subprocess_report.name as report_type,
  activity_id, when_script_started,
  when_background_entered, when_script_ended, 
  invoking_user, user_to_notify, button_name,
  operation_name, command_line
from
  subprocess_invocation natural left join background_subprocess natural left join background_subprocess_report
  natural left join user_inbox_content natural left join activity_inbox_content
where subprocess_invocation_id = ?', ARRAY['subprocess_invocation_id'], 
                    ARRAY['subprocess_invocation_id', 'background_subprocess_id', 'user_inbox_content_id', 'background_subprocess_report_id', 'file_id', 'report_type', 'activity_id', 'when_script_started', 'when_background_entered', 'when_script_ended', 'invoking_user', 'user_to_notify', 'button_name', 'operation_name', 'command_line'], ARRAY['activity_timepoint_support'], 'posda_queries', 'Create An Activity Timepoint

')
        ;

            insert into queries
            values ('UpdateEquivalenceClassProcessingStatus', 'update image_equivalence_class
set processing_status = ?
where image_equivalence_class_id = ?
', ARRAY['processing_status', 'image_equivalence_class_id'], 
                    '{}', ARRAY['consistency', 'find_series', 'equivalence_classes', 'NotInteractive'], 'posda_files', 'For building series equivalence classes')
        ;

            insert into queries
            values ('TotalsByDateRangeAndCollection', 'select 
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
', ARRAY['start_time', 'end_time', 'project_name'], 
                    ARRAY['project_name', 'site_name', 'num_subjects', 'num_studies', 'num_series', 'total_files'], ARRAY['DateRange', 'Kirk', 'Totals', 'end_of_month'], 'posda_files', 'Get posda totals by date range
')
        ;

            insert into queries
            values ('FilePathByFileId', 'select
  root_path || ''/'' || rel_path as path
from
  file_location natural join file_storage_root
where
  file_id = ?', ARRAY['file_id'], 
                    ARRAY['path'], ARRAY['SeriesSendEvent', 'by_series', 'find_files', 'for_send', 'for_comparing_dups', 'used_in_file_import_into_posda', 'reimport_queries'], 'posda_files', 'Get file path from id')
        ;

            insert into queries
            values ('FilesSeriesSopsVisibilityInTimepoint', 'select 
  file_id, patient_id, study_instance_uid, series_instance_uid, sop_instance_uid, 
  project_name as collection, site_name as site, visibility, modality,
  dicom_file_type as type
from
  file_patient natural join file_study natural join file_series natural join file_sop_common
  natural join dicom_file
  natural join ctp_file
where file_id in (
  select file_id from activity_timepoint natural join activity_timepoint_file where activity_timepoint_id = ?)', ARRAY['activity_timepoint_id'], 
                    ARRAY['file_id', 'patient_id', 'study_instance_uid', 'series_instance_uid', 'sop_instance_uid', 'collection', 'site', 'visibility', 'modality', 'type'], ARRAY['compare_series'], 'posda_files', 'Get Distinct SOPs in Series with number files
Only visible filess
')
        ;

            insert into queries
            values ('PossiblyRunningSubprocesses', 'select
  subprocess_invocation_id, command_line, invoking_user,
  when_invoked, now() - when_invoked as duration
from
  subprocess_invocation natural left join background_subprocess
where
  when_background_entered is null and subprocess_invocation_id != 0 and
  scrash is null and process_pid is null
order by subprocess_invocation_id', '{}', 
                    ARRAY['subprocess_invocation_id', 'command_line', 'invoking_user', 'when_invoked', 'duration'], ARRAY['meta', 'test', 'hello', 'query_tabs', 'bills_test', 'subprocess'], 'posda_queries', 'Add a filter to a tab')
        ;

            insert into queries
            values ('FinalizeNonDicomEditCompareDisposition', 'update non_dicom_edit_compare_disposition set
  end_creation_time = now(),
  last_updated = now(),
  current_disposition = ''Comparisons Complete''
where
  subprocess_invocation_id = ?
', ARRAY['subprocess_invocation_id'], 
                    '{}', ARRAY['adding_ctp', 'for_scripting', 'non_dicom_edit'], 'posda_files', 'Update an entry in dicom_edit_compare_disposition to indicate its done.

From script only.  Don''t run from user interface (needs valid subprocess_invocation_id)')
        ;

            insert into queries
            values ('SubjectCountsDateRangeSummaryByCollectionSiteDateRange', 'select 
  distinct patient_id,
  min(import_time) as from,
  max(import_time) as to,
  count(distinct file_id) as num_files,
  count(distinct sop_instance_uid) as num_sops
from 
  ctp_file natural join file_patient natural join file_import natural join import_event
  natural join file_sop_common
where
  project_name = ? and site_name = ? and import_time > ? and
  import_time < ?
group by patient_id
order by patient_id', ARRAY['collection', 'site', 'from', 'to'], 
                    ARRAY['patient_id', 'from', 'to', 'num_files', 'num_sops'], ARRAY['counts', 'for_bill_counts'], 'posda_files', 'Counts query by Collection, Site
')
        ;

            insert into queries
            values ('AAA_import_test_query1', 'select ''2492183'' as file_id
union
select ''4372774'' as file_id
', '{}', 
                    ARRAY['file_id'], ARRAY['AllCollections', 'DateRange', 'Kirk', 'Totals', 'count_queries', 'end_of_month'], 'posda_files', 'Get posda totals by date range

**WARNING:**  This query can run for a **LONG** time if you give it a large date range.
It is intended for short date ranges (i.e. "What came in last night?" or "What came in last month?")
(Ignore this line, it is a test!)
')
        ;

            insert into queries
            values ('TableSizePosdaQueries', 'select *, pg_size_pretty(total_bytes) AS total
    , pg_size_pretty(index_bytes) AS INDEX
    , pg_size_pretty(toast_bytes) AS toast
    , pg_size_pretty(table_bytes) AS TABLE
  FROM (
  SELECT *, total_bytes-index_bytes-COALESCE(toast_bytes,0) AS table_bytes FROM (
      SELECT c.oid,nspname AS table_schema, relname AS TABLE_NAME
              , c.reltuples AS row_estimate
              , pg_total_relation_size(c.oid) AS total_bytes
              , pg_indexes_size(c.oid) AS index_bytes
              , pg_total_relation_size(reltoastrelid) AS toast_bytes
          FROM pg_class c
          LEFT JOIN pg_namespace n ON n.oid = c.relnamespace
          WHERE relkind = ''r''
  ) a
) a where table_schema = ''public'' order by total_bytes desc', '{}', 
                    ARRAY['table_schema', 'table_name', 'row_estimate', 'total_bytes', 'index_bytes', 'total', 'toast_bytes', 'index', 'toast', 'table'], ARRAY['AllCollections', 'postgres_stats', 'table_size'], 'posda_queries', 'Get a list of collections and sites
')
        ;

            insert into queries
            values ('AllPatientDetailsWithNoCtpLike', 'select
  distinct 
  patient_id,
  patient_name,
  study_instance_uid,
  study_date,
  series_instance_uid,
  modality,
  count (distinct file_id) as num_files
from
  file_patient natural left join
  file_study natural left join
  file_series f
where
 not exists (select file_id from ctp_file c where c.file_id = f.file_id)
 and patient_id like ?
group by
  patient_id, patient_name, study_instance_uid, study_date,
  series_instance_uid, modality
order by 
  patient_id, study_date,
  modality
', ARRAY['patient_id_like'], 
                    ARRAY['patient_id', 'patient_name', 'study_instance_uid', 'study_date', 'series_instance_uid', 'modality', 'num_files'], ARRAY['adding_ctp', 'find_patients', 'no_ctp_details'], 'posda_files', 'Get Series in A Collection
')
        ;

            insert into queries
            values ('GetGeometricInfo', 'select 
  distinct sop_instance_uid, iop as image_orientation_patient,
  ipp as image_position_patient,
  pixel_spacing,
  pixel_rows as i_rows,
  pixel_columns as i_columns
from
  file_sop_common join 
  file_patient using (file_id) join
  file_image using (file_id) join 
  file_series using (file_id) join
  file_study using (file_id) join
  image using (image_id) join
  file_image_geometry using (file_id) join
  image_geometry using (image_geometry_id) 
where 
  sop_instance_uid = ?
', ARRAY['sop_instance_uid'], 
                    ARRAY['sop_instance_uid', 'image_orientation_patient', 'image_position_patient', 'pixel_spacing', 'i_rows', 'i_columns'], ARRAY['LinkageChecks', 'BySopInstance'], 'posda_files', 'Get Geometric Information by Sop Instance UID from posda')
        ;

            insert into queries
            values ('PatientStudySeriesHierarchyByCollectionSite', 'select distinct
  patient_id,
  study_instance_uid,
  series_instance_uid
from
  file_study natural join ctp_file natural join file_series natural join file_patient
where 
  file_id in (
    select distinct file_id
    from ctp_file
    where project_name = ? and site_name = ? and
    visibility is null
  )
order by patient_id, study_instance_uid, series_instance_uid', ARRAY['collection', 'site'], 
                    ARRAY['patient_id', 'study_instance_uid', 'series_instance_uid'], ARRAY['Hierarchy', 'apply_disposition'], 'posda_files', 'Construct list of files in a collection, site in a Patient, Study, Series Hierarchy')
        ;

            insert into queries
            values ('GetListOfUnprocessedStructureSets', 'select
  file_id,
  root_path || ''/'' || rel_path as path
from
  file_storage_root natural join file_location
where file_id in (
  select distinct file_id
  from dicom_file df natural join ctp_file
  where 
  dicom_file_type = ''RT Structure Set Storage''
  and visibility is null and has_no_roi_linkages is null
  and not exists (
    select file_id from file_roi_image_linkage r where r.file_id = df.file_id
  )
) ', '{}', 
                    ARRAY['file_id', 'path'], ARRAY['NotInteractive', 'used_in_processing_structure_set_linkages'], 'posda_files', 'Get the file_storage root for newly created files')
        ;

            insert into queries
            values ('GetModuleToTableArgs', 'select *
from 
  dicom_tag_parm_column_table natural left join tag_preparation
where posda_table_name = ?', ARRAY['table_name'], 
                    ARRAY['tag_cannonical_name', 'tag', 'posda_table_name', 'column_name', 'preparation_description'], ARRAY['bills_test', 'posda_db_populate'], 'posda_queries', 'Add a filter to a tab')
        ;

            insert into queries
            values ('DuplicateCtpFile', 'select
  distinct project_name as collection,
  site_name as site,
  dicom_file_type,
  count(distinct file_id) as num_files,
  min(import_time) as first,
  max(import_time) as last,
  count(*) as num_imports,
  max(import_time) - min(import_time) as duration
from
   ctp_file natural join dicom_file natural join file_import natural join import_event
where file_id in (
  select file_id from (
    select distinct file_id, count(*) from dicom_file group by file_id 
  ) as foo where count > 1
) group by collection, site, dicom_file_type order by collection, site;', '{}', 
                    ARRAY['collection', 'site', 'dicom_file_type', 'num_files', 'first', 'last', 'num_imports', 'duration'], ARRAY['AllCollections', 'queries'], 'posda_files', 'Get a list of available queries')
        ;

            insert into queries
            values ('DistinctSeriesByCollectionIntake', 'select
  distinct s.series_instance_uid, modality, count(*) as num_images
from
  general_image i, general_series s,
  trial_data_provenance tdp
where
  s.general_series_pk_id = i.general_series_pk_id and
  i.trial_dp_pk_id = tdp.trial_dp_pk_id and
  tdp.project = ?
group by series_instance_uid, modality', ARRAY['project_name'], 
                    ARRAY['series_instance_uid', 'modality', 'num_images'], ARRAY['by_collection', 'find_series', 'intake'], 'intake', 'Get Series in A Collection
')
        ;

            insert into queries
            values ('DistinctVisibleFileReportByPatientCollectionSite', 'select distinct
  project_name as collection, site_name as site, patient_id, study_instance_uid,
  series_instance_uid, sop_instance_uid, dicom_file_type, modality, file_id
from
  file_patient natural join file_study natural join file_series natural join file_sop_common
  natural join dicom_file natural join ctp_file
where
  project_name = ? and site_name = ? and patient_id = ? and visibility is null
order by series_instance_uid', ARRAY['project_name', 'site_name', 'patient_id'], 
                    ARRAY['collection', 'site', 'patient_id', 'study_instance_uid', 'series_instance_uid', 'sop_instance_uid', 'dicom_file_type', 'modality', 'file_id'], ARRAY['by_collection', 'find_series', 'compare_collection_site', 'search_series', 'edit_files', 'simple_phi', 'dciodvfy', 'ctp_details', 'select_for_phi', 'visual_review_selection', 'activity_timepoints'], 'posda_files', 'Get Series in A Collection, site with dicom_file_type, modality, and sop_count
')
        ;

            insert into queries
            values ('MarkEquivalenceClassForRetry', 'update image_equivalence_class set
  processing_status = ''ReadyToProcess'',
  review_status = null
where image_equivalence_class_id = ?', ARRAY['image_equivalence_class_id'], 
                    '{}', ARRAY['by_collection', 'find_series', 'compare_collection_site', 'search_series', 'edit_files', 'simple_phi', 'dciodvfy', 'ctp_details', 'select_for_phi', 'visual_review_new_workflow'], 'posda_files', 'Get Series in A Collection, site with dicom_file_type, modality, and sop_count
')
        ;

            insert into queries
            values ('RecordFileConversion', 'insert into non_dicom_conversion(from_file_id, to_file_id, conversion_event_id)
values(?, ?, ?)', ARRAY['from_file_id', 'to_file_id', 'conversion_event_id'], 
                    '{}', ARRAY['radcomp'], 'posda_files', 'Add a filter to a tab')
        ;

            insert into queries
            values ('GetHiddenToFiles', 'select 
  f.file_id as file_id,
  c.visibility as visibility 
from
  dicom_edit_compare dec,
  file f,
  ctp_file c
where
  dec.to_file_digest = f.digest and
  f.file_id = c.file_id and 
  c.visibility is not null and
  dec.subprocess_invocation_id = ?', ARRAY['subprocess_invocation_id'], 
                    ARRAY['file_id', 'visibility'], ARRAY['Insert', 'NotInteractive', 'used_in_import_edited_files'], 'posda_files', 'Insert edit_event
For use in scripts
Not really intended for interactive use
')
        ;

            insert into queries
            values ('BackgroundProcessStats', 'select
  distinct command_executed, max(when_script_ended - when_script_started) as longest,
  min(when_script_ended - when_script_started) as shortest,
  avg(when_script_ended - when_script_started) as avg, count(*) as times_invoked,
  count(distinct invoking_user) as num_invokers,
  min(when_script_started) as first, max(when_script_started) as last
from
  background_subprocess natural join subprocess_invocation
where
  when_script_ended is not null
group by command_executed
order by last desc, times_invoked desc', '{}', 
                    ARRAY['command_executed', 'longest', 'shortest', 'avg', 'times_invoked', 'num_invokers', 'first', 'last'], ARRAY['invoking_user'], 'posda_files', 'Get a list of collections and sites
')
        ;

            insert into queries
            values ('ComplexDuplicatePixelDataNew', 'select distinct project_name as collection,
site_name as site,
patient_id as patient,
series_instance_uid, count(distinct file_id) as num_files
from
ctp_file natural join file_patient
natural join file_series where file_id in (
select file_id from 
file_image join image using(image_id) 
join unique_pixel_data using (unique_pixel_data_id)
where digest in (
select distinct pixel_digest as digest from (
select
  distinct pixel_digest, count(*) as num_pix_dups
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
      image join file_image using(image_id)
      join ctp_file using(file_id)
      join file_patient fq using(file_id)
      join unique_pixel_data using(unique_pixel_data_id)
    where visibility is null
  ) as foo 
  group by 
    unique_pixel_data_id, project_name, pixel_digest,
    site_name, patient_id
) as foo 
group by pixel_digest) as foo
where num_pix_dups = ?))
group by collection, site, patient, series_instance_uid
order by num_files desc', ARRAY['num_pix_dups'], 
                    ARRAY['collection', 'site', 'patient', 'series_instance_uid', 'num_files'], ARRAY['pix_data_dups', 'pixel_duplicates'], 'posda_files', 'Find series with duplicate pixel count of <n>
')
        ;

            insert into queries
            values ('GetFileIdByFileId', 'select
  file_id
from
  file
where
  file_id = ?
', ARRAY['file_id'], 
                    ARRAY['file_id'], ARRAY['by_file_id', 'posda_files', 'slope_intercept'], 'posda_files', 'Get a Slope, Intercept for a particular file 
')
        ;

            insert into queries
            values ('GetModuleToPosdaTable', 'select * from dicom_module_to_posda_table', '{}', 
                    ARRAY['dicom_module_name', 'create_row_query', 'table_name'], ARRAY['bills_test', 'posda_db_populate'], 'posda_queries', 'Add a filter to a tab')
        ;

            insert into queries
            values ('FilesInSeriesForSend', 'select
  distinct file_id, root_path || ''/'' || rel_path as path, xfer_syntax, sop_class_uid,
  data_set_size, data_set_start, sop_instance_uid, digest
from
  file_location natural join file_storage_root
  natural join dicom_file natural join ctp_file
  natural join file_sop_common natural join file_series
  natural join file_meta natural join file
where
  series_instance_uid = ? and visibility is null
', ARRAY['series_instance_uid'], 
                    ARRAY['file_id', 'path', 'xfer_syntax', 'sop_class_uid', 'data_set_size', 'data_set_start', 'sop_instance_uid', 'digest'], ARRAY['SeriesSendEvent', 'by_series', 'find_files', 'for_send'], 'posda_files', 'Get everything you need to negotiate a presentation_context
for all files in a series
')
        ;

            insert into queries
            values ('ClosedPlanarContoursWithoutLinksByFile', 'select
  distinct roi_id,
  roi_name
from
  file_structure_set natural join
  structure_set natural join
  roi natural join 
  roi_contour r
where
  file_id =? and 
  geometric_type = ''CLOSED_PLANAR'' and 
  not exists (
    select roi_contour_id from contour_image ci where ci.roi_contour_id = r.roi_contour_id
  )', ARRAY['file_id'], 
                    ARRAY['roi_id', 'roi_name'], ARRAY['LinkageChecks', 'used_in_struct_linkage_check'], 'posda_files', 'Get list of Roi with info by file_id

')
        ;

            insert into queries
            values ('FinalizeDciodvfyUnitScan', 'update dciodvfy_unit_scan set
  num_errors_in_unit = ?,
  num_warnings_in_unit = ?,
  end_time = now()
where
  dciodvfy_unit_scan_id = ?
 ', ARRAY['num_errors_in_unit', 'num_warnings_in_unit', 'unit_scan_id'], 
                    '{}', ARRAY['NotInteractive', 'used_in_dciodvfy'], 'posda_phi_simple', 'Create a dciodvfy_unit_scan row')
        ;

            insert into queries
            values ('ListOpenActivitiesWithItems', 'select
  distinct activity_id,
  brief_description,
  when_created,
  who_created,
  count(distinct user_inbox_content_id) as num_items
from
  activity natural join activity_inbox_content
where when_closed is null
group by activity_id, brief_description, when_created, who_created
order by activity_id desc', '{}', 
                    ARRAY['activity_id', 'brief_description', 'when_created', 'who_created', 'num_items'], ARRAY['AllCollections', 'queries', 'activities'], 'posda_queries', 'Get a list of available queries')
        ;

            insert into queries
            values ('UnlinkEmailFromActivity', 'delete from activity_inbox_content
where activity_id = ? and user_inbox_content_id = ?', ARRAY['activity_id', 'user_inbox_content_id'], 
                    '{}', ARRAY['activity_timepoint_support'], 'posda_queries', 'Create An Activity Timepoint

')
        ;

            insert into queries
            values ('SeriesVisualReviewResultsByCollectionSiteVisible', 'select 
  distinct series_instance_uid,
  dicom_file_type,
  modality,
  review_status,
  processing_status,
  count(distinct file_id) as num_files
from 
  dicom_file natural join 
  file_series natural join 
  ctp_file join 
  image_equivalence_class using(series_instance_uid)
where
  project_name = ? and
  site_name = ? and visibility is null
group by
  series_instance_uid,
  dicom_file_type,
  modality,
  review_status,
  processing_status
order by
  series_instance_uid', ARRAY['project_name', 'site_name'], 
                    ARRAY['series_instance_uid', 'dicom_file_type', 'modality', 'review_status', 'processing_status', 'num_files'], ARRAY['find_series', 'equivalence_classes', 'consistency', 'visual_review_results', 'hide_files'], 'posda_files', 'Get visual review status report by series for Collection, Site')
        ;

            insert into queries
            values ('AllQueryTabs', 'select 
   distinct  query_tab_name
from
  query_tabs', '{}', 
                    ARRAY['query_tab_name'], ARRAY['meta', 'test', 'hello', 'query_tabs', 'bills_test'], 'posda_queries', 'Add a filter to a tab')
        ;

            insert into queries
            values ('PatientStudySeriesFileHierarchyByCollection', 'select distinct
  patient_id,
  study_instance_uid,
  series_instance_uid,
  sop_instance_uid,
  root_path || ''/'' || rel_path as path
from
  file_study natural join ctp_file natural join file_series natural join file_patient
  natural join file_sop_common natural join file_location
  natural join file_storage_root
where 
  file_id in (
    select distinct file_id
    from ctp_file
    where project_name = ? and visibility is null
  )
order by patient_id, study_instance_uid, series_instance_uid', ARRAY['collection'], 
                    ARRAY['patient_id', 'study_instance_uid', 'series_instance_uid', 'path'], ARRAY['Hierarchy'], 'posda_files', 'Construct list of files in a collection in a Patient, Study, Series Hierarchy')
        ;

            insert into queries
            values ('GetSopModalityPathDigest', 'select 
  sop_instance_uid, modality,
  root_path || ''/'' || rel_path as path,
  digest
from
  file natural join file_series natural join file_sop_common natural join file_location natural join file_storage_root
where
  file_id = ?', ARRAY['file_id'], 
                    ARRAY['sop_instance_uid', 'modality', 'path', 'digest'], ARRAY['bills_test', 'comparing_posda_to_public'], 'posda_files', 'get sop_instance, modality, and path to file by file_id')
        ;

            insert into queries
            values ('GetSopOfSsReferenceByPlan', 'select
  distinct ss_referenced_from_plan as sop_instance_uid
from
  plan natural join file_plan
where
  file_id = ?', ARRAY['file_id'], 
                    ARRAY['sop_instance_uid'], ARRAY['LinkageChecks', 'used_in_plan_linkage_check'], 'posda_files', 'Get Plan Reference Info for RTDOSE by file_id
')
        ;

            insert into queries
            values ('AddTagToQuery', 'update queries
set tags = array_append(tags, ?)
where name = ?', ARRAY['tag', 'name'], 
                    '{}', ARRAY['query_tags', 'meta', 'test', 'hello'], 'posda_queries', 'Add a tag to a query')
        ;

            insert into queries
            values ('GetConversionId', 'select currval(''conversion_event_conversion_event_id_seq'') as id', '{}', 
                    ARRAY['id'], ARRAY['radcomp'], 'posda_files', 'Add a filter to a tab')
        ;

            insert into queries
            values ('PixelInfoByImageId', 'select
  root_path || ''/'' || rel_path as file, file_offset, size, 
  bits_stored, bits_allocated, pixel_representation, number_of_frames,
  samples_per_pixel, pixel_rows, pixel_columns, photometric_interpretation
from
  image natural join unique_pixel_data natural join pixel_location
  natural join file_location natural join file_storage_root
where image_id = ?
', ARRAY['image_id'], 
                    ARRAY['file', 'file_offset', 'size', 'bits_stored', 'bits_allocated', 'pixel_representation', 'number_of_frames', 'samples_per_pixel', 'pixel_rows', 'pixel_columns', 'photometric_interpretation'], '{}', 'posda_files', 'Get pixel descriptors for a particular image id
')
        ;

            insert into queries
            values ('CountsByCollectionDateRange', 'select
  distinct
    patient_id, image_type, modality, study_date, study_description,
    series_description, study_instance_uid, series_instance_uid,
    manufacturer, manuf_model_name, software_versions,
    count(distinct sop_instance_uid) as num_sops,
    count(distinct file_id) as num_files,
    min(import_time) as earliest,
    max(import_time) as latest
from
  ctp_file join file_patient using(file_id)
  join file_series using(file_id)
  join file_sop_common using(file_id)
  join file_study using(file_id)
  join file_equipment using(file_id)
  join file_import using(file_id)
  join import_event using(import_event_id)
  left join file_image using(file_id)
  left join image using (image_id)
where
  project_name = ? and visibility is null
  and import_time > ? and import_time < ?
group by
  patient_id, image_type, modality, study_date, study_description,
  series_description, study_instance_uid, series_instance_uid,
  manufacturer, manuf_model_name, software_versions
order by
  patient_id, study_instance_uid, series_instance_uid, image_type,
  modality, study_date, study_description,
  series_description,
  manufacturer, manuf_model_name, software_versions
', ARRAY['collection', 'from', 'to'], 
                    ARRAY['patient_id', 'image_type', 'modality', 'study_date', 'study_description', 'series_description', 'study_instance_uid', 'series_instance_uid', 'manufacturer', 'manuf_model_name', 'software_versions', 'num_sops', 'num_files', 'earliest', 'latest'], ARRAY['counts', 'for_bill_counts'], 'posda_files', 'Counts query by Collection, Site
')
        ;

            insert into queries
            values ('StudyNickname', 'select
  project_name, site_name, subj_id, study_nickname
from
  study_nickname
where
  study_instance_uid = ?
', ARRAY['study_instance_uid'], 
                    ARRAY['project_name', 'site_name', 'subj_id', 'study_nickname'], '{}', 'posda_nicknames', 'Get a nickname, etc for a particular study uid
')
        ;

            insert into queries
            values ('GetPublicTagDispositionBySignature', 'select
  disposition
from public_tag_disposition
where tag_name = ?
', ARRAY['signature'], 
                    ARRAY['disposition'], ARRAY['DispositionReport', 'NotInteractive'], 'posda_public_tag', 'Get the disposition of a public tag by signature
Used in DispositionReport.pl - not for interactive use
')
        ;

            insert into queries
            values ('DistinctPatientStudySeriesByCollectionDateRange', 'select distinct
  patient_id, 
  study_instance_uid,
  series_instance_uid, 
  dicom_file_type,
  modality, 
  count(distinct file_id) as num_files
from
  ctp_file
  natural join dicom_file
  natural join file_study
  natural join file_series
  natural join file_patient
  natural join file_import
  natural join import_event
where
  project_name = ? and
  visibility is null and
  import_time > ?
  and import_time < ?
group by
  patient_id, 
  study_instance_uid,
  series_instance_uid,
  dicom_file_type,
  modality
  ', ARRAY['collection', 'from', 'to'], 
                    ARRAY['patient_id', 'study_instance_uid', 'series_instance_uid', 'dicom_file_type', 'modality', 'num_files'], ARRAY['by_collection', 'find_series', 'search_series', 'send_series'], 'posda_files', 'Get Series in A Collection
')
        ;

            insert into queries
            values ('InsertIntoNonDicomAttachments', 'insert into non_dicom_attachments(
  non_dicom_file_id,
  dicom_file_id,
  patient_id,
  manifest_uid,
  study_instance_uid,
  series_instance_uid,
  manifest_date,
  version
)values(
  ?, ?, ?, ?, ?, ?, ?, ?
)
', ARRAY['non_dicom_file_id', 'dicom_file_id', 'patient_id', 'manifest_uid', 'study_instance_uid', 'series_instance_uid', 'manifest_date', 'version'], 
                    '{}', ARRAY['radcomp'], 'posda_files', 'Add a filter to a tab')
        ;

            insert into queries
            values ('GetDciodvfyWarningUnrecog', 'select
  dciodvfy_warning_id as id
from 
  dciodvfy_warning
where
  warning_type = ''UnrecognizedTag''
  and warning_tag = ?
  and warning_comment = ?
 ', ARRAY['warning_tag', 'warning_comment'], 
                    ARRAY['id'], ARRAY['NotInteractive', 'used_in_dciodvfy'], 'posda_phi_simple', 'Get an dciodvfy_warnings row by warning_text (if present)')
        ;

            insert into queries
            values ('GetDicomEditCompareToFiles', 'select 
  path,
  file_id,
  project_name,
  visibility
from 
  (
    select to_file_path as path, to_file_digest as digest
    from dicom_edit_compare
    where subprocess_invocation_id = ?
  ) as foo natural left join
  file natural left join ctp_file', ARRAY['subprocess_invocation_id'], 
                    ARRAY['path', 'file_id', 'project_name', 'visibility'], ARRAY['adding_ctp', 'for_scripting'], 'posda_files', 'Get a list of to files from the dicom_edit_compare table for a particular edit instance, with file_id and visibility

NB: Normally there should be no file_id (i.e. file has not been imported)')
        ;

            insert into queries
            values ('GetPlansReferencingBadSS', 'select
  distinct project_name as collection,
  site_name as site,
  patient_id,
  series_instance_uid,
  file_id
from
  file_series natural join
  file_patient natural join ctp_file
where
  project_name = ? and
  visibility is null and
  file_id in (
select file_id from plan p natural join file_plan  where
not exists (select sop_instance_uid from file_sop_common fsc where p.ss_referenced_from_plan 
= fsc.sop_instance_uid))', ARRAY['collection'], 
                    ARRAY['collection', 'site', 'patient_id', 'series_instance_uid', 'file_id'], ARRAY['Structure Sets', 'sops', 'LinkageChecks', 'plan_linkages'], 'posda_files', 'Get list of plan which reference unknown SOPs

')
        ;

            insert into queries
            values ('GetPhiNonDicomScanId', 'select
  currval(''phi_non_dicom_scan_instance_phi_non_dicom_scan_instance_id_seq'') as id', '{}', 
                    ARRAY['id'], ARRAY['used_in_simple_phi', 'NotInteractive', 'non_dicom_phi'], 'posda_phi_simple', 'Get value seen if exists')
        ;

            insert into queries
            values ('VisualReviewStatusWithCollectionById', 'select 
  distinct project_name as collection, site_name as site, 
  series_instance_uid, review_status, modality, series_description,
  series_date, count(distinct image_equivalence_class_id) as num_equiv_classes, 
  count(distinct file_id) as num_files
from
  visual_review_instance natural join image_equivalence_class natural join
  image_equivalence_class_input_image natural join
  file_series natural join ctp_file
where
  visual_review_instance_id = ? and review_status = ? and visibility is null
group by collection, site, series_instance_uid, review_status, modality, series_description, series_date;', ARRAY['visual_review_instance_id', 'review_status'], 
                    ARRAY['collection', 'site', 'series_instance_uid', 'review_status', 'modality', 'series_description', 'series_date', 'num_equiv_classes', 'num_files'], ARRAY['by_collection', 'find_series', 'compare_collection_site', 'search_series', 'edit_files', 'simple_phi', 'dciodvfy', 'ctp_details', 'select_for_phi', 'visual_review_new_workflow'], 'posda_files', 'Get Series in A Collection, site with dicom_file_type, modality, and sop_count
')
        ;

            insert into queries
            values ('VisibilityChangeEventsByCollectionWithoutFurtherBreakdown', 'select 
  distinct project_name as collection,
  site_name as site,
  patient_id,
  date_trunc(''day'', time_of_change) as when_done,
  user_name, prior_visibility, new_visibility, reason_for, count(distinct file_id) as num_files
from
   ctp_file natural join file_patient natural join file_series natural join file_visibility_change 
where project_name = ?
group by
 collection, site, patient_id, when_done, user_name, prior_visibility, new_visibility, reason_for
order by when_done desc', ARRAY['collection'], 
                    ARRAY['collection', 'site', 'patient_id', 'when_done', 'user_name', 'prior_visibility', 'new_visibility', 'reason_for', 'num_files'], ARRAY['meta', 'test', 'hello', 'bills_test', 'hide_events'], 'posda_files', 'Add a filter to a tab')
        ;

            insert into queries
            values ('GetDatasetStart', 'select
  data_set_start
from
  file_meta
where
  file_id = ?', ARRAY['file_id'], 
                    ARRAY['data_set_start'], ARRAY['AllCollections', 'universal', 'public_posda_consistency'], 'posda_files', 'Get path to file by id')
        ;

            insert into queries
            values ('SeriesWithMultiplePatientIds', 'select
  distinct series_instance_uid,
  patient_id
from
  file_series natural join file_patient natural join ctp_file                                                      
where series_instance_uid in (                                                                                                                                                        
  select distinct series_instance_uid from (                                                                                                                                                                                    
     select * from (
        select distinct series_instance_uid, count(*) from (
          select distinct series_instance_uid, patient_id
          from file_series natural join file_patient natural join ctp_file
          where project_name = ? and visibility is null
        ) as foo group by series_instance_uid
      ) as foo where count > 1
   ) as foo
) and
visibility is null', ARRAY['collection'], 
                    ARRAY['series_instance_uid', 'patient_id'], ARRAY['by_study', 'consistency', 'series_consistency'], 'posda_files', 'Find Inconsistent Studies
')
        ;

            insert into queries
            values ('PhiScanStatusInProcess', 'select
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
', '{}', 
                    ARRAY['id', 'description', 'start_time', 'end_time', 'duration', 'status', 'to_scan', 'scanned', 'percentage', 'projected_completion'], ARRAY['tag_usage', 'obsolete'], 'posda_phi', 'Status of PHI scans
')
        ;

            insert into queries
            values ('GetDoseReferencingGoodPlan', 'select
  distinct project_name as collection,
  site_name as site,
  patient_id,
  series_instance_uid,
  file_id
from
  file_series natural join
  file_patient natural join ctp_file
where
  project_name = ? and
  visibility is null and
  file_id in (
select file_id from rt_dose d  natural join file_dose  where
exists (select sop_instance_uid from file_sop_common fsc where d.rt_dose_referenced_plan_uid
= fsc.sop_instance_uid))', ARRAY['collection'], 
                    ARRAY['collection', 'site', 'patient_id', 'series_instance_uid', 'file_id'], ARRAY['LinkageChecks', 'dose_linkages'], 'posda_files', 'Get list of plan which reference known SOPs

')
        ;

            insert into queries
            values ('GetSopsInSeriesforLGCP', 'select
  sop_instance_uid, file_id, for_uid
from 
  file_series natural join file_for natural join ctp_file
  natural join file_sop_common
where series_instance_uid = ? and visibility is null
', ARRAY['series_instance_uid'], 
                    ARRAY['sop_instance_uid', 'file_id', 'for_uid'], ARRAY['Curation of Lung-Fused-CT-Pathology'], 'posda_files', 'Get SOP instance uid, file_id, and path for each file in series')
        ;

            insert into queries
            values ('CreateRound', 'insert into round(
  round_created
) values (
  now()
)
', '{}', 
                    '{}', ARRAY['NotInteractive', 'Backlog'], 'posda_backlog', 'Create a row in round table to record files_imported in this round')
        ;

            insert into queries
            values ('GetVisibilityByFileId', 'select
  file_id, visibility
from
   ctp_file
where
   file_id = ?
', ARRAY['file_id'], 
                    ARRAY['file_id', 'visibility'], ARRAY['ImageEdit', 'NotInteractive'], 'posda_files', 'Get Visibility for a file by file_id
')
        ;

            insert into queries
            values ('ImportsLikeType', 'select
  distinct import_type, import_comment, import_time,
  sum(num_files) as total_files
from (
  select * from (
    select
      distinct import_event_id, import_time, import_type, import_comment, count(distinct file_id) as num_files 
    from
      import_event natural join file_import
    where import_time > ? and import_time < ?
    group by import_event_id, import_time, import_type, import_comment order by import_time desc
  ) as foo
  where num_files > 1 and import_type like ?
) as foo
group by import_type, import_time, import_comment', ARRAY['from', 'to', 'type_like'], 
                    ARRAY['import_type', 'import_comment', 'import_time', 'total_files'], ARRAY['downloads_by_date', 'import_events'], 'posda_files', 'Counts query by Collection, Site
')
        ;

            insert into queries
            values ('GetSsReferencingKnownImagesByCollection', 'select
  distinct project_name as collection,
  site_name as site,
  patient_id,
  series_instance_uid,
  file_id
from
  ctp_file natural join file_patient natural join file_series
where file_id in (
  select
    distinct ss_file_id as file_id 
  from (
    select
      sop_instance_uid, ss_file_id 
    from (
      select 
        distinct
           linked_sop_instance_uid as sop_instance_uid,
           file_id as ss_file_id
      from
        file_roi_image_linkage
    ) foo left join file_sop_common using(sop_instance_uid)
    join ctp_file using(file_id)
  where
    visibility is null
  ) as foo
)
and project_name = ? and visibility is null
order by collection, site, patient_id, file_id
', ARRAY['collection'], 
                    ARRAY['collection', 'site', 'patient_id', 'series_instance_uid', 'file_id'], ARRAY['Structure Sets', 'sops', 'LinkageChecks', 'struct_linkages'], 'posda_files', 'Get list of RTSTRUCT which reference known SOPs by Collection

')
        ;

            insert into queries
            values ('SeriesForPhi', 'select 
  series_instance_uid 
from 
  series_scan_instance
where series_scan_instance_id in (
  select series_scan_instance_id from (
    select * from element_value_occurance 
    where
      phi_scan_instance_id = ? and
      element_seen_id in (
        select element_seen_id from element_seen
        where element_sig_pattern = ?
      ) and 
      value_seen_id in (
        select value_seen_id from value_seen
        where value = ?
      )
  ) as foo
)', ARRAY['scan_id', 'element_sig_pattern', 'value'], 
                    ARRAY['series_instance_uid'], ARRAY['tag_usage', 'simple_phi'], 'posda_phi_simple', 'Status of PHI scans
')
        ;

            insert into queries
            values ('background_subprocesses_by_date', 'select 
  background_subprocess_id as bkgrnd_id, subprocess_invocation_id as invoc_id,
  operation_name, command_line, invoking_user, when_script_started
from
  background_subprocess natural left join subprocess_invocation where invoking_user = ?
  and when_script_ended is not null
  and when_script_started > ? and when_script_started < ?
order by when_script_started desc', ARRAY['invoking_user', 'from', 'to'], 
                    ARRAY['bkgrnd_id', 'invoc_id', 'operation_name', 'command_line', 'invoking_user', 'when_script_started'], ARRAY['meta', 'test', 'hello', 'query_tabs', 'bills_test'], 'posda_queries', 'Add a filter to a tab')
        ;

            insert into queries
            values ('CurrentPatientStatii', 'select 
  distinct project_name as collection,
  site_name as site,
  patient_id,
  patient_import_status
from 
  ctp_file natural join file_patient natural left join patient_import_status
where 
  visibility is null', '{}', 
                    ARRAY['collection', 'site', 'patient_id', 'patient_import_status'], ARRAY['counts', 'patient_status', 'for_bill_counts'], 'posda_files', 'Get the current status of all patients')
        ;

            insert into queries
            values ('AllPixelInfoByPhotometricInterp', 'select
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
', ARRAY['bits_allocated'], 
                    ARRAY['file_id', 'file', 'file_offset', 'size', 'bits_stored', 'bits_allocated', 'pixel_representation', 'number_of_frames', 'samples_per_pixel', 'pixel_rows', 'pixel_columns', 'photometric_interpretation', 'modality'], '{}', 'posda_files', 'Get pixel descriptors for all files
')
        ;

            insert into queries
            values ('GetPatientMapping', 'select
  from_patient_id,
  to_patient_id,
  to_patient_name,
  collection_name,
  site_name,
  batch_number,
  diagnosis_date,
  baseline_date,
  date_shift,
  baseline_date - diagnosis_date + interval ''1 day'' as computed_shift
from
  patient_mapping
  ', '{}', 
                    ARRAY['from_patient_id', 'to_patient_id', 'to_patient_name', 'collection_name', 'site_name', 'batch_number', 'diagnosis_date', 'baseline_date', 'date_shift', 'computed_shift'], ARRAY['adding_ctp', 'for_scripting', 'patient_mapping'], 'posda_files', 'Retrieve entries from patient_mapping table')
        ;

            insert into queries
            values ('SeriesNickname', 'select
  project_name, site_name, subj_id, series_nickname
from
  series_nickname
where
  series_instance_uid = ?
', ARRAY['series_instance_uid'], 
                    ARRAY['project_name', 'site_name', 'subj_id', 'series_nickname'], '{}', 'posda_nicknames', 'Get a nickname, etc for a particular series uid
')
        ;

            insert into queries
            values ('GetFileVisibilityByDigest', 'select distinct file_id,  visibility from file natural join ctp_file where digest = ?', ARRAY['digest'], 
                    ARRAY['file_id', 'visibility'], ARRAY['used_in_file_import_into_posda', 'used_in_file_migration'], 'posda_files', 'Get current visibility by file_id
')
        ;

            insert into queries
            values ('ActivityStuffMoreByUser', 'select
  distinct subprocess_invocation_id, background_subprocess_id, user_inbox_content_id,
  background_subprocess_report_id, file_id,
  background_subprocess_report.name as report_type,
  activity_id, when_script_started,
  when_background_entered, when_script_ended, 
  invoking_user, user_to_notify, button_name,
  operation_name, command_line
from
  subprocess_invocation natural left join background_subprocess natural left join background_subprocess_report
  natural left join user_inbox_content natural left join activity_inbox_content
where invoking_user = ?
order by subprocess_invocation_id desc
', ARRAY['user'], 
                    ARRAY['subprocess_invocation_id', 'background_subprocess_id', 'user_inbox_content_id', 'background_subprocess_report_id', 'file_id', 'report_type', 'activity_id', 'when_script_started', 'when_background_entered', 'when_script_ended', 'invoking_user', 'user_to_notify', 'button_name', 'operation_name', 'command_line'], ARRAY['activity_timepoint_support'], 'posda_queries', 'Create An Activity Timepoint

')
        ;

            insert into queries
            values ('ListOfUncategorizedDciodvfyErrors', 'select distinct error_text, count(*)  as num_occurances from dciodvfy_error
where
  error_type = ''Uncategorized''
group by 
error_text', '{}', 
                    ARRAY['error_text', 'num_occurances'], ARRAY['tag_usage', 'dciodvfy'], 'posda_phi_simple', 'All dciodvfy uncategorized warnings in DB')
        ;

            insert into queries
            values ('PatientIdAndMappingByNonDicomFileId', 'select
  from_patient_id, to_patient_id, to_patient_name, collection_name, site_name,
  batch_number, diagnosis_date, baseline_date, date_shift, uid_root,
  baseline_date - diagnosis_date + interval ''1 day'' as computed_shift
from 
  patient_mapping pm, non_dicom_file ndf
where
  pm.from_patient_id = ndf.subject and
  file_id = ?', ARRAY['file_id'], 
                    ARRAY['from_patient_id', 'to_patient_id', 'to_patient_name', 'collection_name', 'site_name', 'batch_number', 'diagnosis_date', 'baseline_date', 'date_shift', 'uid_root', 'computed_shift'], ARRAY['adding_ctp', 'for_scripting', 'non_dicom_phi', 'non_dicom_edit'], 'posda_files', 'Simple Phi Report with Meta Quotes')
        ;

            insert into queries
            values ('SeriesWithDuplicatePixelDataThatMatters', 'select 
  distinct project_name as collection,
  site_name as site,
  patient_id,
  series_instance_uid,
  count(distinct file_id) as num_files
from 
  file_series natural join file_image
  natural join file_patient
  natural join ctp_file
where 
  visibility is null 
  and image_id in (
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
) group by collection, site, patient_id, series_instance_uid
', ARRAY['collection'], 
                    ARRAY['collection', 'site', 'series_instance_uid', 'patient_id', 'num_files'], ARRAY['pixel_duplicates'], 'posda_files', 'Return a list of files with duplicate pixel data,
restricted to those files which have parsed DICOM data
representations in Database.
')
        ;

            insert into queries
            values ('AllPatientDetailsWithNoCtpByImportEvent', 'select
  distinct 
  patient_id,
  patient_name,
  study_instance_uid,
  study_date,
  series_instance_uid,
  modality,
  count (distinct file_id) as num_files
from
  file_patient natural left join
  file_study natural left join
  file_series f
where
 not exists (select file_id from ctp_file c where c.file_id = f.file_id)
 and file_id in (select file_id from file_import where import_event_id = ?)
group by
  patient_id, patient_name, study_instance_uid, study_date,
  series_instance_uid, modality
order by 
  patient_id, study_date,
  modality
', ARRAY['import_event_id'], 
                    ARRAY['patient_id', 'patient_name', 'study_instance_uid', 'study_date', 'series_instance_uid', 'modality', 'num_files'], ARRAY['adding_ctp', 'find_patients', 'no_ctp_details'], 'posda_files', 'List patient details without CTP, selected by import event
')
        ;

            insert into queries
            values ('FindingImageProblemCT', 'select
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
    where modality = ''CT'' and project_name = ''Exceptional-Responders'' and file_id in (
      select
         distinct file_id from file_import natural join import_event natural join dicom_file
      where import_time > ''2018-09-17''
    )
  ) as foo where image_id is null
) 
and visibility is null
group by dicom_file_type, project_name, patient_id
order by patient_id', '{}', 
                    ARRAY['dicom_file_type', 'project_name', 'patient_id', 'min', 'max', 'count'], ARRAY['Exceptional-Responders_NCI_Oct2018_curation'], 'posda_files', 'Find files which have unique_pixel_data_id but no image_id, then find out where the hell they came from')
        ;

            insert into queries
            values ('DistinctSopsInCollectionIntake', 'select
  distinct i.sop_instance_uid
from
  general_image i,
  trial_data_provenance tdp
where
  i.trial_dp_pk_id = tdp.trial_dp_pk_id and
  tdp.project = ?
order by sop_instance_uid
', ARRAY['collection'], 
                    ARRAY['sop_instance_uid'], ARRAY['by_collection', 'intake', 'sops'], 'intake', 'Get Distinct SOPs in Collection with number files
Only visible files
')
        ;

            insert into queries
            values ('StudiesInPublicHnsccWithMostCtAndRt', 'select
 patient_id, study_instance_uid, num_images as num_cts
from (
  select 
    distinct i.patient_id, t.study_instance_uid,
    s.series_instance_uid, 
    t.study_desc, series_desc, count(*) as num_images
  from 
    general_image i, trial_data_provenance tdp, general_series s, study t
  where
    i.study_pk_id = t.study_pk_id and i.trial_dp_pk_id = tdp.trial_dp_pk_id and 
    i.general_series_pk_id = s.general_series_pk_id and tdp.project = ''HNSCC'' and
    modality = ''CT'' and t.study_desc = ''RT SIMULATION'' 
  group by series_instance_uid
) as foo order by num_images desc', '{}', 
                    ARRAY['patient_id', 'study_instance_uid', 'num_cts'], ARRAY['meta', 'test', 'hello', 'query_tabs', 'bills_test'], 'public', 'Name says it all')
        ;

            insert into queries
            values ('PatientIdByNonDicomFileId', 'select subject from non_dicom_file where file_id = ?', ARRAY['file_id'], 
                    ARRAY['subject'], ARRAY['adding_ctp', 'for_scripting', 'non_dicom_phi', 'non_dicom_edit'], 'posda_files', 'Simple Phi Report with Meta Quotes')
        ;

            insert into queries
            values ('QueryByName', 'select
  name, description, query,
  array_to_string(tags, '','') as tags
from queries
where name = ?
', ARRAY['name'], 
                    ARRAY['name', 'description', 'query', 'tags'], ARRAY['AllCollections', 'queries'], 'posda_queries', 'Get a list of available queries')
        ;

            insert into queries
            values ('SeriesConsistencyExtended', 'select distinct
  series_instance_uid, modality, series_number, laterality, series_date, dicom_file_type,
  series_time, performing_phys, protocol_name, series_description,
  operators_name, body_part_examined, patient_position,
  smallest_pixel_value, largest_pixel_value, performed_procedure_step_id,
  performed_procedure_step_start_date, performed_procedure_step_start_time,
  performed_procedure_step_desc, performed_procedure_step_comments, image_type,
  iop, pixel_rows, pixel_columns,
  count(*)
from
  file_series natural join ctp_file natural join dicom_file
  left join file_image using(file_id)
  left join image using (image_id)
  left join image_geometry using (image_id)
where series_instance_uid = ? and visibility is null
group by
  series_instance_uid, dicom_file_type, modality, series_number, laterality,
  series_date, image_type, iop, pixel_rows, pixel_columns,
  series_time, performing_phys, protocol_name, series_description,
  operators_name, body_part_examined, patient_position,
  smallest_pixel_value, largest_pixel_value, performed_procedure_step_id,
  performed_procedure_step_start_date, performed_procedure_step_start_time,
  performed_procedure_step_desc, performed_procedure_step_comments
', ARRAY['series_instance_uid'], 
                    ARRAY['series_instance_uid', 'count', 'dicom_file_type', 'modality', 'laterality', 'series_number', 'series_date', 'image_type', 'series_time', 'performing_phys', 'protocol_name', 'series_description', 'operators_name', 'body_part_examined', 'patient_position', 'smallest_pixel_value', 'largest_pixel_value', 'performed_procedure_step_id', 'performed_procedure_step_start_date', 'performed_procedure_step_start_time', 'performed_procedure_step_desc', 'performed_procedure_step_comments', 'iop', 'pixel_rows', 'pixel_columns'], ARRAY['by_series', 'consistency'], 'posda_files', 'Check a Series for Consistency (including Image Type)
')
        ;

            insert into queries
            values ('ApiImportEventsForPatient', 'select
  import_event_id, import_comment, import_time,
  import_close_time - import_time as duration, patient_id,
  count(distinct file_id) as num_images
from 
  import_event natural join file_import natural join file_patient
where
  import_comment like ? and import_type = ''posda-api import'' and patient_id like ?
group by import_event_id, import_comment, import_time, import_close_time, patient_id', ARRAY['import_comment_like', 'patient_id_like'], 
                    ARRAY['import_event_id', 'import_comment', 'import_time', 'duration', 'patient_id', 'num_images'], ARRAY['import_events'], 'posda_files', 'Get Import Events by matching comment')
        ;

            insert into queries
            values ('ImportEvents', 'select
  distinct import_event_id, import_time,  count(distinct file_id) as num_files
from
  import_event natural join file_import
where
  import_type = ''single file import'' and 
  import_time > ? and import_time < ?
group by import_event_id, import_time', ARRAY['from', 'to'], 
                    ARRAY['import_event_id', 'import_time', 'num_files'], ARRAY['adding_ctp', 'find_patients', 'no_ctp_patients', 'import_event'], 'posda_files', 'Get Series in A Collection
')
        ;

            insert into queries
            values ('GetFilePathPublicBySopInst', 'select
  dicom_file_uri
from
  general_image
where
  sop_instance_uid = ?
', ARRAY['sop_instance_uid'], 
                    ARRAY['dicom_file_uri'], ARRAY['posda_files', 'sops', 'BySopInstance'], 'public', 'Get Collection, Site, Patient, Study Hierarchy in which SOP resides
')
        ;

            insert into queries
            values ('SeriesReport', 'select 
  file_id, sop_instance_uid, modality, cast(instance_number as int) inst_num, iop, ipp
from 
  file_series natural join file_sop_common 
  left join file_image_geometry using(file_id) 
  left join image_geometry using(image_geometry_id)
where file_id in (
  select 
  file_id from file_series natural join ctp_file
  where series_instance_uid = ?
    and visibility is null
) order by inst_num;', ARRAY['series_instance_uid'], 
                    ARRAY['file_id', 'modality', 'inst_num', 'iop', 'ipp', 'sop_instance_uid'], ARRAY['by_series_instance_uid', 'duplicates', 'posda_files', 'sops', 'series_report'], 'posda_files', 'Get Distinct SOPs in Series with number files
Only visible filess
')
        ;

            insert into queries
            values ('SeriesForFile', 'select series_instance_uid from file_series where file_id = ?', ARRAY['file_id'], 
                    ARRAY['series_instance_uid'], ARRAY['activity_timepoint_support'], 'posda_files', 'Create An Activity Timepoint

')
        ;

            insert into queries
            values ('ListOfQueriesPerformedAllWithLatestAndCountAndUser', 'select
  distinct invoking_user, query_name,
  max(query_start_time) as last_invocation, 
  count(query_invoked_by_dbif_id) as num_invocations,
  sum(query_end_time - query_start_time) as total_query_time,
  avg(query_end_time - query_start_time) as avg_query_time
from 
  query_invoked_by_dbif
group by invoking_user, query_name
order by last_invocation  desc', '{}', 
                    ARRAY['invoking_user', 'query_name', 'last_invocation', 'num_invocations', 'total_query_time', 'avg_query_time'], ARRAY['AllCollections', 'q_stats'], 'posda_queries', 'Get a list of collections and sites
')
        ;

            insert into queries
            values ('FinalizeDicomEditCompareDisposition', 'update dicom_edit_compare_disposition set
  end_creation_time = now(),
  current_disposition = ''Comparisons Complete''
where
  subprocess_invocation_id = ?
', ARRAY['subprocess_invocation_id'], 
                    '{}', ARRAY['adding_ctp', 'for_scripting'], 'posda_files', 'Update an entry in dicom_edit_compare_disposition to indicate its done.

From script only.  Don''t run from user interface (needs valid subprocess_invocation_id)')
        ;

            insert into queries
            values ('SeriesVisualReviewResultsByCollectionSiteStatusNotGoodExtended', 'select
  distinct patient_id,
  study_instance_uid,
  series_instance_uid,
  dicom_file_type,
  series_modality as modality,
  review_status,
  num_files
from (
select 
  distinct series_instance_uid,
  dicom_file_type,
  modality as series_modality,
  review_status,
  count(distinct file_id) as num_files
from 
  dicom_file natural join 
  file_series natural join 
  ctp_file join 
  image_equivalence_class using(series_instance_uid)
where
  project_name = ? and
  site_name = ? and review_status != ''Good''
  and visibility is null
group by
  series_instance_uid,
  dicom_file_type,
  modality,
  review_status
) as foo
  join file_series using (series_instance_uid)
  join file_study using (file_id) 
  join file_patient using(file_id)
  join ctp_file using(file_id)
where
  visibility is null
order by patient_id, study_instance_uid, series_instance_uid
', ARRAY['project_name', 'site_name'], 
                    ARRAY['patient_id', 'study_instance_uid', 'series_instance_uid', 'dicom_file_type', 'modality', 'review_status', 'num_files'], ARRAY['find_series', 'equivalence_classes', 'consistency', 'visual_review_results', 'hide_files'], 'posda_files', 'Get visual review status report by series for Collection, Site')
        ;

            insert into queries
            values ('PatientStatusCountsByCollection', 'select
  distinct project_name as collection, patient_import_status as status,
  count(distinct patient_id) as num_patients
from
  patient_import_status natural join file_patient natural join ctp_file
where project_name = ? and visibility is null
group by collection, status
', ARRAY['collection'], 
                    ARRAY['collection', 'status', 'num_patients'], ARRAY['FindSubjects', 'PatientStatus'], 'posda_files', 'Find All Subjects which have at least one visible file
')
        ;

            insert into queries
            values ('InsertFileFrameOfRef', 'insert into file_for(file_id, for_uid, position_ref_indicator) values(?, ?, ?)', ARRAY['file_id', 'for_uid', 'position_ref_indicator'], 
                    '{}', ARRAY['Structure Sets', 'sops', 'LinkageChecks', 'plan_linkages'], 'posda_files', 'Get list of plan which reference unknown SOPs

')
        ;

            insert into queries
            values ('UpdateElementDispositionOnly', 'update element_signature set 
  private_disposition = ?
where
  element_signature = ? and
  vr = ?
', ARRAY['private_disposition', 'element_signature', 'vr'], 
                    '{}', ARRAY['NotInteractive', 'Update', 'ElementDisposition'], 'posda_phi', 'Update Element Disposition
For use in scripts
Not really intended for interactive use
')
        ;

            insert into queries
            values ('GetDoseReferencingBadPlan', 'select
  distinct project_name as collection,
  site_name as site,
  patient_id,
  series_instance_uid,
  file_id
from
  file_series natural join
  file_patient natural join ctp_file
where
  project_name = ? and
  visibility is null and
  file_id in (
select file_id from rt_dose d natural join file_dose  where
not exists (select sop_instance_uid from file_sop_common fsc where d.rt_dose_referenced_plan_uid
= fsc.sop_instance_uid))', ARRAY['collection'], 
                    ARRAY['collection', 'site', 'patient_id', 'series_instance_uid', 'file_id'], ARRAY['LinkageChecks', 'dose_linkages'], 'posda_files', 'Get list of RTDOSE which reference unknown SOPs

')
        ;

            insert into queries
            values ('IntakeCountsOld', 'select
        p.patient_id as PID,
        i.image_type as ImageType,
        s.modality as Modality,
        count(i.sop_instance_uid) as Images,
        t.study_date as StudyDate,
        t.study_desc as StudyDescription,
        s.series_desc as SeriesDescription,
        s.series_number as SeriesNumber,
        t.study_instance_uid as StudyInstanceUID,
        s.series_instance_uid as SeriesInstanceUID,
        q.manufacturer as Mfr,
        q.manufacturer_model_name as Model,
        q.software_versions,
        c.reconstruction_diameter as ReconstructionDiameter,
        c.kvp as KVP,
        i.slice_thickness as SliceThickness
     from
        general_image i,
        general_series s,
        study t,
        patient p,
        trial_data_provenance tdp,
        general_equipment q,
        ct_image c
     where
        i.general_series_pk_id = s.general_series_pk_id and
        s.study_pk_id = t.study_pk_id and
        s.general_equipment_pk_id = q.general_equipment_pk_id and
        t.patient_pk_id = p.patient_pk_id and
        p.trial_dp_pk_id = tdp.trial_dp_pk_id and
        tdp.project = ? and
        tdp.dp_site_name = ? and
        c.image_pk_id = i.image_pk_id
    group by p.patient_id, i.image_type, s.series_instance_uid, t.study_instance_uid
', ARRAY['collection', 'site'], 
                    ARRAY['PID', 'Modality', 'Images', 'StudyDate', 'StudyDescription', 'SeriesDescription', 'SeriesNumber', 'StudyInstanceUID', 'SeriesInstanceUID', 'Mfr', 'Model', 'software_versions', 'ImageType', 'ReconstructionDiameter', 'KVP', 'SliceThickness'], ARRAY['intake'], 'intake', 'List of all Files Images By Collection, Site
')
        ;

            insert into queries
            values ('GetCurrentPosdaFileId', 'select  currval(''file_file_id_seq'') as id
', '{}', 
                    ARRAY['file_id'], ARRAY['NotInteractive', 'Backlog', 'used_in_file_import_into_posda'], 'posda_files', 'Get posda file id of created file row')
        ;

            insert into queries
            values ('InsertSendEvent', 'insert into dicom_send_event(
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
', ARRAY['host', 'port', 'called', 'calling', 'who', 'why', 'num_files', 'series'], 
                    NULL, ARRAY['NotInteractive', 'SeriesSendEvent'], 'posda_files', 'Create a DICOM Series Send Event
For use in scripts.
Not meant for interactive use
')
        ;

            insert into queries
            values ('ClearPublicDispositions', 'delete from public_disposition where
  sop_class_uid = ? and name = ?

', ARRAY['sop_class_uid', 'name'], 
                    '{}', ARRAY['NotInteractive', 'Update', 'ElementDisposition'], 'posda_phi', 'Clear all public dispositions for a give sop_class and name')
        ;

            insert into queries
            values ('SubjectsWithDupSopsByCollection', 'select
  distinct collection, site, subj_id, 
  count(distinct file_id) as num_files,
  count(distinct sop_instance_uid) as num_sops,
  min(import_time) as earliest,
  max(import_time) as latest
from (
  select
    distinct project_name as collection,
    site_name as site, patient_id as subj_id,
    file_id, sop_instance_uid, import_time
  from
    ctp_file natural join file_sop_common
    natural join file_patient natural join file_import
    natural join import_event
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
', ARRAY['collection'], 
                    ARRAY['collection', 'site', 'subj_id', 'num_sops', 'num_files', 'earliest', 'latest'], ARRAY['dup_sops'], 'posda_files', 'Return a count of duplicate SOP Instance UIDs
')
        ;

            insert into queries
            values ('WhichSeriesInCollectionSiteAreNotVisuallyReviewed', 'select 
  distinct project_name as collection,
  site_name as site,
  patient_id,
   series_instance_uid,
  dicom_file_type,
  modality,
  ''Not submitted for review'' as review_status,
  count(distinct file_id) as num_files
from 
  dicom_file natural join 
  file_series ser natural join
  file_patient natural join  
  ctp_file
where
  project_name = ? and
  site_name = ?
  and visibility is null
  and not exists (
    select * from image_equivalence_class iec
    where iec.series_instance_uid = ser.series_instance_uid
  )
group by
  collection, site, patient_id,
  series_instance_uid,
  dicom_file_type,
  modality,
  review_status
order by
  series_instance_uid', ARRAY['collection', 'site'], 
                    ARRAY['collection', 'site', 'patient_id', 'series_instance_uid', 'dicom_file_type', 'modality', 'review_status', 'num_files'], ARRAY['find_series', 'equivalence_classes', 'consistency', 'visual_review_results', 'hide_events'], 'posda_files', 'Get visual review status report by series for Collection, Site')
        ;

            insert into queries
            values ('GetScanEventById', 'select * from scan_event where scan_event_id = ?
', ARRAY['scan_id'], 
                    ARRAY['scan_event_id', 'scan_started', 'scan_ended', 'scan_status', 'scan_description', 'num_series_to_scan', 'num_series_scanned'], ARRAY['UsedInPhiSeriesScan', 'NotInteractive'], 'posda_phi', 'List of values seen in scan by VR (with count of elements)
')
        ;

            insert into queries
            values ('GetNonDicomFileTypeSubTypeCollectionSiteSubjectById', 'select 
  file_type,
  file_sub_type,
  collection,
  site,
  subject
from 
  non_dicom_file
where file_id = ?', ARRAY['file_id'], 
                    ARRAY['file_type', 'file_sub_type', 'collection', 'site', 'subject'], ARRAY['adding_ctp', 'for_scripting', 'non_dicom_import'], 'posda_files', 'Get stuff from non_dicom_file by id
')
        ;

            insert into queries
            values ('VisibilityChangeEventsBySeries', 'select 
  distinct project_name as collection,
  site_name as site,
  patient_id,
  date_trunc(''hour'', time_of_change) as when_done,
  user_name, prior_visibility, new_visibility, reason_for, count(distinct file_id) as num_files,
  count (distinct series_instance_uid) as num_series
from
   ctp_file natural join file_patient natural join file_series natural join file_visibility_change 
where series_instance_uid = ?
group by
 collection, site, patient_id, when_done, user_name, prior_visibility, new_visibility, reason_for
order by when_done desc', ARRAY['series_instance_uid'], 
                    ARRAY['collection', 'site', 'patient_id', 'when_done', 'user_name', 'prior_visibility', 'new_visibility', 'reason_for', 'num_files', 'num_series'], ARRAY['meta', 'test', 'hello', 'bills_test', 'hide_events', 'show_hidden'], 'posda_files', 'Add a filter to a tab')
        ;

            insert into queries
            values ('CountsByCollection', 'select
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
', ARRAY['collection'], 
                    ARRAY['patient_id', 'image_type', 'modality', 'study_date', 'study_description', 'series_description', 'study_instance_uid', 'series_instance_uid', 'manufacturer', 'manuf_model_name', 'software_versions', 'num_sops', 'num_files'], ARRAY['counts'], 'posda_files', 'Counts query by Collection
')
        ;

            insert into queries
            values ('VisibleSeriesVisualReviewResultsByCollectionSiteStatus', 'select 
  distinct series_instance_uid,
  dicom_file_type,
  modality,
  review_status,
  count(distinct file_id) as num_files
from 
  dicom_file natural join 
  file_series natural join 
  ctp_file join 
  image_equivalence_class using(series_instance_uid)
where
  project_name = ? and
  site_name = ? and review_status = ?
  and visibility is null
group by
  series_instance_uid,
  dicom_file_type,
  modality,
  review_status
order by
  series_instance_uid', ARRAY['project_name', 'site_name', 'status'], 
                    ARRAY['series_instance_uid', 'dicom_file_type', 'modality', 'review_status', 'num_files'], ARRAY['find_series', 'equivalence_classes', 'consistency', 'visual_review_results', 'hide_files'], 'posda_files', 'Get visual review status report by series for Collection, Site')
        ;

            insert into queries
            values ('RoundSummaryWithCollectionDateRange', 'select
  distinct round_id, collection,
  round_start, 
  round_end - round_start as duration, 
  round_end
from
  round natural join round_collection
where
  round_end is not null and round_start > ? and round_end < ?
group by 
  round_id, collection, round_start, duration, round_end 
order by round_id', ARRAY['from', 'to'], 
                    ARRAY['round_id', 'collection', 'round_start', 'duration', 'round_end'], ARRAY['NotInteractive', 'Backlog', 'Backlog Monitor', 'backlog_analysis_reporting_tools'], 'posda_backlog', 'Summary of rounds')
        ;

            insert into queries
            values ('ListOfCollectionsBySite', 'select 
    distinct project_name as collection, site_name, count(*) 
from 
   ctp_file natural join file_study natural join
   file_series
where
  visibility is null and site_name = ?
group by project_name, site_name
order by project_name, site_name
', ARRAY['site'], 
                    ARRAY['collection', 'site_name', 'count'], ARRAY['AllCollections', 'universal'], 'posda_files', 'Get a list of collections and sites
')
        ;

            insert into queries
            values ('ActivityTimepointsForActivityWithFileCount', 'select
  distinct activity_id, a.when_created as activity_created,
  brief_description as activity_description, activity_timepoint_id,
  t.when_created as timepoint_created, 
  comment, creating_user, count(distinct file_id) as file_count
from
  activity a join activity_timepoint t using(activity_id)
  left join activity_timepoint_file using (activity_timepoint_id)
where
  activity_id = ?
group by activity_id, a.when_created, brief_description,
  activity_timepoint_id, t.when_created, comment, creating_user
order by t.when_created desc', ARRAY['activity_id'], 
                    ARRAY['activity_id', 'activity_created', 'activity_description', 'activity_timepoint_id', 'timepoint_created', 'comment', 'creating_user', 'file_count'], ARRAY['by_collection', 'find_series', 'compare_collection_site', 'search_series', 'edit_files', 'simple_phi', 'dciodvfy', 'ctp_details', 'select_for_phi', 'visual_review_selection', 'activity_timepoints'], 'posda_queries', 'Get Series in A Collection, site with dicom_file_type, modality, and sop_count
')
        ;

            insert into queries
            values ('GetStructureSetVolumeByFileId', 'select
  distinct sop_instance
from
  ss_volume natural join ss_for natural join file_structure_set
where file_id = ?', ARRAY['file_id'], 
                    ARRAY['sop_instance'], ARRAY['Structure Sets', 'sops', 'LinkageChecks'], 'posda_files', 'Get List of SOP''s linked in SS

')
        ;

            insert into queries
            values ('VisualReviewSeriesByIdReviewStatusProcessingStatusAndDicomFileType', 'select 
  distinct image_equivalence_class_id, series_instance_uid
from
  visual_review_instance natural join image_equivalence_class natural join
  image_equivalence_class_input_image natural join dicom_file natural join 
  file_series natural join ctp_file
where
  visual_review_instance_id = ? and review_status = ? and processing_status = ? and dicom_file_type = ?
', ARRAY['visual_review_instance_id', 'review_status', 'processing_status', 'dicom_file_type'], 
                    ARRAY['image_equivalence_class_id', 'series_instance_uid'], ARRAY['by_collection', 'find_series', 'compare_collection_site', 'search_series', 'edit_files', 'simple_phi', 'dciodvfy', 'ctp_details', 'select_for_phi', 'visual_review_new_workflow'], 'posda_files', 'Get Series in A Collection, site with dicom_file_type, modality, and sop_count
')
        ;

            insert into queries
            values ('FileReportByImportEvent', 'select
  distinct project_name as collection, site_name as site, patient_id,
  study_instance_uid, study_date, study_description, series_instance_uid,
  modality, series_date, dicom_file_type, count(distinct file_id) as num_files
from
  file_import natural join file_patient natural join file_series natural join
  file_study natural join dicom_file natural left join ctp_file
where
  import_event_id = ?
group by
  collection, site, patient_id, study_instance_uid, study_date,
  study_description, series_instance_uid, modality, series_date, dicom_file_type;', ARRAY['import_event_id'], 
                    ARRAY['collection', 'site', 'patient_id', 'study_instance_uid', 'study_date', 'study_description', 'series_instance_uid', 'modality', 'series_date', 'dicom_file_type', 'num_files'], ARRAY['import_events', 'QIN-GBM-DSC-MRI-DRO/Barrow'], 'posda_files', 'Counts query by Collection, Site
')
        ;

            insert into queries
            values ('DispositonsSimple', 'select 
  distinct 
  element_seen_id as id, 
  element_sig_pattern,
  vr,
  tag_name,
  private_disposition as disposition
from
  element_seen
where
  is_private
order by element_sig_pattern
', '{}', 
                    ARRAY['id', 'element_sig_pattern', 'vr', 'tag_name', 'disposition'], ARRAY['tag_usage', 'simple_phi_maint', 'phi_maint'], 'posda_phi_simple', 'Private tags with no disposition with values in phi_simple')
        ;

            insert into queries
            values ('DistinctSeriesByCollectionModality', 'select distinct series_instance_uid, patient_id, dicom_file_type, modality, count(distinct file_id) as num_files
 from file_series natural join file_sop_common
   natural join ctp_file natural join dicom_file natural join file_patient
where
  project_name = ? and modality = ?
  and visibility is null
group by series_instance_uid, patient_id, dicom_file_type, modality', ARRAY['collection', 'modality'], 
                    ARRAY['series_instance_uid', 'patient_id', 'dicom_file_type', 'modality', 'num_files'], ARRAY['by_collection', 'find_series', 'search_series', 'send_series', 'phi_simple', 'simple_phi', 'dciodvfy', 'edit_files'], 'posda_files', 'Get Series in A Collection
')
        ;

            insert into queries
            values ('GetMaxProcessedFileId', 'select
  max(file_id) as file_id
from
  file
where
  is_dicom_file is not null
', '{}', 
                    ARRAY['file_id'], ARRAY['used_in_file_import_into_posda', 'used_in_file_migration'], 'posda_files', 'Get count of files relative to storage root')
        ;

            insert into queries
            values ('UpdateSeriesFinished', 'update scan_event 
set scan_status = ''finished'',
  scan_ended = now()
where scan_event_id = ?', ARRAY['scan_event_id'], 
                    '{}', ARRAY['UsedInPhiSeriesScan', 'NotInteractive'], 'posda_phi', 'Update status to finished in scan event
')
        ;

            insert into queries
            values ('IsThisSeriesNotVisuallyReviewed', 'select 
  distinct series_instance_uid,
  dicom_file_type,
  modality,
  ''Not submitted for review'' as review_status,
  count(distinct file_id) as num_files
from 
  dicom_file natural join 
  file_series ser natural join 
  ctp_file
where
  series_instance_uid = ?
  and visibility is null
  and not exists (
    select * from image_equivalence_class iec
    where iec.series_instance_uid = ser.series_instance_uid
  )
group by
  series_instance_uid,
  dicom_file_type,
  modality,
  review_status
order by
  series_instance_uid', ARRAY['series_instance_uid'], 
                    ARRAY['series_instance_uid', 'dicom_file_type', 'modality', 'review_status', 'num_files'], ARRAY['find_series', 'equivalence_classes', 'consistency', 'visual_review_results', 'hide_events'], 'posda_files', 'Get visual review status report by series for Collection, Site')
        ;

            insert into queries
            values ('FilesInSeriesForApplicationOfPrivateDispositionIntake', 'select
  i.dicom_file_uri as path, i.sop_instance_uid, s.modality
from
  general_image i, general_series s
where
  i.general_series_pk_id = s.general_series_pk_id and
  s.series_instance_uid = ?', ARRAY['series_instance_uid'], 
                    ARRAY['path', 'sop_instance_uid', 'modality'], ARRAY['find_files', 'ApplyDisposition', 'intake'], 'intake', 'Get path, sop_instance_uid, and modality for all files in a series
')
        ;

            insert into queries
            values ('FilesInSeriesForApplyingPrivateDisposition', 'select
  distinct file_id, root_path || ''/'' || rel_path as path, sop_instance_uid, 
  modality
from
  file_location natural join file_storage_root
  natural join ctp_file
  natural join file_sop_common natural join file_series
where
  series_instance_uid = ? and visibility is null
', ARRAY['series_instance_uid'], 
                    ARRAY['path', 'sop_instance_uid', 'modality'], ARRAY['SeriesSendEvent', 'by_series', 'find_files', 'ApplyDisposition'], 'posda_files', 'Get Sop Instance UID, file_path, modality for all files in a series')
        ;

            insert into queries
            values ('LongestRunningNQueries', 'select * from (
select query_invoked_by_dbif_id as id, query_name, query_end_time - query_start_time as duration,
invoking_user, query_start_time, number_of_rows
from query_invoked_by_dbif
where query_end_time is not null
order by duration desc) as foo
limit ?', ARRAY['n'], 
                    ARRAY['id', 'query_name', 'duration', 'invoking_user', 'query_start_time', 'number_of_rows'], ARRAY['AllCollections', 'q_stats'], 'posda_queries', 'Get a list of collections and sites
')
        ;

            insert into queries
            values ('GetElementByPrivateDisposition', 'select
  element_signature, private_disposition as disposition
from
  element_signature
where
  is_private and private_disposition = ?
', ARRAY['private_disposition'], 
                    ARRAY['element_signature', 'disposition'], ARRAY['NotInteractive', 'ElementDisposition'], 'posda_phi', 'Get List of Private Elements By Disposition')
        ;

            insert into queries
            values ('ToFilesFilesImportedByEditId', 'select
  count(distinct file_id) as files_imported
from (
    select distinct file_id from file f, dicom_edit_compare dec
     where f.digest = dec.to_file_digest and 
        subprocess_invocation_id = ?
  ) as foo
', ARRAY['subprocess_invocation_id'], 
                    ARRAY['files_imported'], ARRAY['adding_ctp', 'find_patients', 'series_selection', 'check_edits', 'edit_status'], 'posda_files', 'Get List of visible patients with CTP data')
        ;

            insert into queries
            values ('GetCTQP', 'select 
  collection, site, patient_id, qualified
from
  clinical_trial_qualified_patient_id', '{}', 
                    ARRAY['collection', 'site', 'patient_id', 'qualified'], ARRAY['clin_qual'], 'posda_files', 'Create An Activity Timepoint

')
        ;

            insert into queries
            values ('IntakePatientsByCollectionSite', 'select
  distinct p.patient_id as PID, count(distinct i.image_pk_id) as num_images
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
group by PID
', ARRAY['collection', 'site'], 
                    ARRAY['PID', 'num_images'], ARRAY['intake'], 'intake', 'List of all Files Images By Collection, Site
')
        ;

            insert into queries
            values ('GetStudyInfoById', 'select
  file_id,
  study_instance_uid,
  study_date,
  study_time,
  referring_phy_name,
  study_id,
  accession_number,
  study_description,
  phys_of_record,
  phys_reading,
  admitting_diag
from file_study
where file_id = ?', ARRAY['file_id'], 
                    ARRAY['file_id', 'study_instance_uid', 'study_date', 'study_time', 'referring_phy_name', 'study_id', 'accession_number', 'study_description', 'phys_of_record', 'phys_reading', 'phys_reading', 'admitting_diag'], ARRAY['reimport_queries'], 'posda_files', 'Get file path from id')
        ;

            insert into queries
            values ('DciodvfyErrorIdByValue', 'select 
  distinct dciodvfy_error_id
from 
  dciodvfy_error
where
  error_value = ?', ARRAY['error_value'], 
                    ARRAY['dciodvfy_error_id'], ARRAY['tag_usage', 'dciodvfy'], 'posda_phi_simple', 'find dciodvfy_error_id by contents of error_value')
        ;

            insert into queries
            values ('GetActivityTimepointId', 'select currval(''activity_timepoint_activity_timepoint_id_seq'') as id', '{}', 
                    ARRAY['id'], ARRAY['by_collection', 'activity_timepoint_support'], 'posda_queries', 'Create An Activity Timepoint

')
        ;

            insert into queries
            values ('ReOpenActivity', 'update activity set
  when_closed = null
where
  activity_id = ?', ARRAY['activity_id'], 
                    '{}', ARRAY['activity_timepoint_support', 'activity_support'], 'posda_queries', 'Close an activity

')
        ;

            insert into queries
            values ('GetWinLev', 'select
  window_width, window_center, win_lev_desc, wl_index
from
  file_win_lev natural join window_level
where
  file_id = ?
order by wl_index desc;
', ARRAY['file_id'], 
                    ARRAY['window_width', 'window_center', 'win_lev_desc', 'wl_index'], ARRAY['by_file_id', 'posda_files', 'window_level'], 'posda_files', 'Get a Window, Level(s) for a particular file 
')
        ;

            insert into queries
            values ('GetNfilesToCopy', 'select
  c.sop_instance_uid,
  c.replace_file_id,
  c.copy_file_path
from file_copy_from_public c, ctp_file p
where
  c.copy_from_public_id = ? and
  (p.file_id = c.replace_file_id and p.visibility is null) and 
  (inserted_file_id is null)
limit ?', ARRAY['copy_from_public_id', 'count'], 
                    ARRAY['sop_instance_uid', 'replace_file_id', 'copy_file_path'], ARRAY['bills_test', 'copy_from_public'], 'posda_files', 'Add a filter to a tab')
        ;

            insert into queries
            values ('ShowQueryTabHierarchyByTabWithQueries', 'select
  query_tab_name, filter_name, tag, query_name
from (
  select 
     query_tab_name,
      filter_name,
      unnest(tags_enabled) as tag
  from
    query_tabs join query_tabs_query_tag_filter using(query_tab_name)
    natural join query_tag_filter
  where query_tab_name = ?
) as foo
natural join(
  select name as query_name, unnest(tags) as tag
from queries
) as fie
order by filter_name, tag, query_name', ARRAY['query_tab_name'], 
                    ARRAY['query_tab_name', 'filter_name', 'tag', 'query_name'], ARRAY['meta', 'test', 'hello', 'query_tabs', 'bills_test'], 'posda_queries', 'Add a filter to a tab')
        ;

            insert into queries
            values ('GetNonSquareImageIds', 'select file_id from image natural join file_image  where pixel_rows != pixel_columns
offset ? limit ?', ARRAY['offset', 'limit'], 
                    ARRAY['file_id'], ARRAY['ImageEdit'], 'posda_files', 'Get list of dicom_edit_event')
        ;

            insert into queries
            values ('GetVisualReviewInstanceInfo', 'select 
  visual_review_reason
from
  visual_review_instance
where
  visual_review_instance_id = ?', ARRAY['visual_review_instance_id'], 
                    ARRAY['visual_review_reason'], ARRAY['signature', 'phi_review', 'visual_review', 'visual_review_new_workflow'], 'posda_files', 'Get a list of Series By Visual Review Id and Status
')
        ;

            insert into queries
            values ('VisibilityChangesByCollectionSite', 'select
  distinct project_name as collection, 
  site_name as site,
  user_name, prior_visibility, new_visibility,
  date_trunc(''hour'',time_of_change) as time, 
  reason_for, count(*) as num_files
from
  file_visibility_change natural join
  ctp_file natural join 
  file_patient natural join 
  file_series
where
  project_name = ? and site_name = ?
group by 
  collection, site, user_name, prior_visibility, new_visibility,
  time, reason_for
order by time, collection, site', ARRAY['collection', 'site'], 
                    ARRAY['collection', 'site', 'user_name', 'prior_visibility', 'new_visibility', 'time', 'reason_for', 'num_files'], ARRAY['find_series', 'equivalence_classes', 'consistency', 'visual_review_results', 'hide_files'], 'posda_files', 'Get visual review status report by series for Collection, Site')
        ;

            insert into queries
            values ('FindInconsistentStudyIgnoringStudyTime', 'select distinct study_instance_uid from (
  select distinct study_instance_uid, count(*) from (
    select distinct
      study_instance_uid, study_date,
      referring_phy_name, study_id, accession_number,
      study_description, phys_of_record, phys_reading,
      admitting_diag
    from
      file_study natural join ctp_file
    where
      project_name = ? and visibility is null
    group by
      study_instance_uid, study_date,
      referring_phy_name, study_id, accession_number,
      study_description, phys_of_record, phys_reading,
      admitting_diag
  ) as foo
  group by study_instance_uid
) as foo
where count > 1
', ARRAY['collection'], 
                    ARRAY['study_instance_uid'], ARRAY['by_study', 'consistency', 'study_consistency'], 'posda_files', 'Find Inconsistent Studies
')
        ;

            insert into queries
            values ('InsertIntoPatientMappingBaselineNoBatch', 'insert into patient_mapping(
  from_patient_id,
  to_patient_id,
  to_patient_name,
  collection_name,
  site_name,
  diagnosis_date,
  baseline_date) values (
  ?, ?, ?, ?, ?, ?, ?)', ARRAY['from_patient_id', 'to_patient_id', 'to_patient_name', 'collection_name', 'site_name', 'diagnosis_date', 'baseline_date'], 
                    '{}', ARRAY['adding_ctp', 'mapping_tables', 'insert_pat_mapping'], 'posda_files', 'Make an entry into the patient_mapping table with no batch and diagnosis_date, and baseline_date')
        ;

            insert into queries
            values ('CreateNonDicomFileById', 'insert into non_dicom_file(
  file_id, file_type, file_sub_type, collection, site, subject, date_last_categorized
)values(
  ?, ?, ?, ?, ?, ?, now()
)
', ARRAY['file_id', 'file_type', 'file_sub_type', 'collection', 'site', 'subject'], 
                    '{}', ARRAY['radcomp'], 'posda_files', 'Add a filter to a tab')
        ;

            insert into queries
            values ('GetSeriesFileCountsByPatientId', 'select
  series_instance_uid, modality, dicom_file_type, count(distinct sop_instance_uid) as num_sops
from
  file_series natural join file_patient natural join 
  dicom_file natural join file_sop_common
where
  patient_id = ?
group by series_instance_uid, modality, dicom_file_type
', ARRAY['patient_id'], 
                    ARRAY['series_instance_uid', 'modality', 'dicom_file_type', 'num_sops'], ARRAY['Structure Sets', 'sops', 'LinkageChecks'], 'posda_files', 'Get Counts in file_series by patient_id

')
        ;

            insert into queries
            values ('DoesDoseReferenceNoPlan', 'select
  file_id
from
  rt_dose  natural join file_dose
where
  rt_dose_referenced_plan_uid is null
  and file_id = ?', ARRAY['file_id'], 
                    ARRAY['file_id'], ARRAY['Structure Sets', 'sops', 'LinkageChecks', 'used_in_dose_linkage_check'], 'posda_files', 'Return a row if file references no plan

')
        ;

            insert into queries
            values ('CreateSeenValue', 'insert into seen_value(value)values(?)', ARRAY['value'], 
                    '{}', ARRAY['UsedInPhiSeriesScan', 'NotInteractive'], 'posda_phi', 'Create New Seen Value')
        ;

            insert into queries
            values ('AreVisibleFilesMarkedAsBadOrUnreviewedInSeriesExperiment', 'select 
  distinct project_name as collection,
  site_name as site,
  patient_id,
  series_instance_uid,
  dicom_file_type,
  modality,
  review_status,
  processing_status,
  visibility,
  file_id
from 
  dicom_file natural join 
  file_series natural join 
  file_patient natural join
  ctp_file natural join 
(
  select file_id, review_status, processing_status
  from
    image_equivalence_class_input_image natural join
    image_equivalence_class join
    ctp_file using(file_id)
  where
    series_instance_uid = ?
) as foo

', ARRAY['series_instance_uid'], 
                    ARRAY['collection', 'site', 'patient_id', 'series_instance_uid', 'dicom_file_type', 'modality', 'review_status', 'processing_status', 'visibility', 'file_id'], ARRAY['find_series', 'equivalence_classes', 'consistency', 'visual_review_results', 'hide_events'], 'posda_files', 'Get visual review status report by series for Collection, Site')
        ;

            insert into queries
            values ('RoundStatsWithCollectionForDateRange', 'select
  distinct collection, date_trunc(?, time_received) as time,
  count(*) as number_of_files,
  max(time_entered - time_received) as max_delay,
  min(time_entered - time_received) as min_delay
from request natural join submitter
where time_received > ? and time_received < ?
group by collection, time order by time desc, collection', ARRAY['interval', 'from', 'to'], 
                    ARRAY['collection', 'time', 'number_of_files', 'max_delay', 'min_delay'], ARRAY['NotInteractive', 'Backlog', 'Backlog Monitor', 'for_bill'], 'posda_backlog', 'Summary of rounds')
        ;

            insert into queries
            values ('ListOfQueriesPerformedByUserWithLatestAndCount', 'select
  distinct query_name, query,
  max(query_start_time) as last_invocation, 
  count(query_invoked_by_dbif_id) as num_invocations,
  sum(query_end_time - query_start_time) as total_query_time,
  avg(query_end_time - query_start_time) as avg_query_time
from 
  query_invoked_by_dbif i, queries q
where invoking_user = ? and i.query_name = q.name
group by query_name, query
order by last_invocation  desc', ARRAY['user'], 
                    ARRAY['query_name', 'query', 'last_invocation', 'num_invocations', 'total_query_time', 'avg_query_time'], ARRAY['AllCollections', 'q_stats'], 'posda_queries', 'Get a list of collections and sites
')
        ;

            insert into queries
            values ('AllManifestsBySite', 'select
  distinct file_id, import_time, size, root_path || ''/'' || l.rel_path as path, i.file_name as alt_path
from
  file_location l join file_storage_root using(file_storage_root_id) 
  join file_import i using (file_id) natural join file join import_event using(import_event_id)
where
  file_id in (
    select distinct file_id from ctp_manifest_row where cm_site = ?
  )', ARRAY['site'], 
                    ARRAY['file_id', 'import_time', 'size', 'path', 'alt_path'], ARRAY['activity_timepoint_support', 'manifests'], 'posda_files', 'Create An Activity Timepoint

')
        ;

            insert into queries
            values ('InsertAdverseFileEvent', 'insert into adverse_file_event(
  file_id, event_description, when_occured
) values (?, ?, now())
', ARRAY['file_id', 'event_description'], 
                    '{}', ARRAY['Insert', 'NotInteractive', 'used_in_import_edited_files'], 'posda_files', 'Insert adverse_file_event row
For use in scripts
Not really intended for interactive use
')
        ;

            insert into queries
            values ('GetPosdaSopCountByPatientId', 'select
  distinct patient_id,
  count(distinct sop_instance_uid) as num_sops
from
  ctp_file
  natural join dicom_file
  natural join file_patient
  natural join file_study
  natural join file_series
  natural join file_sop_common
  natural join file_location
  natural join file_storage_root
where
  patient_id = ? 
  and visibility is null
group by patient_id', ARRAY['patient_id'], 
                    ARRAY['patient_id', 'num_sops'], ARRAY['public_posda_counts'], 'posda_files', 'Generate a long list of all unhidden SOPs for a collection in posda<br>
<em>This can generate a long list</em>')
        ;

            insert into queries
            values ('GetNonDicomFileIdTypeAndPathByCollectionSite', 'select
  file_id, non_dicom_file.file_type as file_type, file_sub_type,
  root_path || ''/'' || rel_path as path
from
  file_storage_root natural join file_location natural join non_dicom_file
where
  collection = ? and site = ?
  and visibility is null', ARRAY['collection', 'site'], 
                    ARRAY['file_id', 'file_type', 'file_sub_type', 'path'], ARRAY['NotInteractive', 'non_dicom_phi'], 'posda_files', 'Create a dciodvfy_scan_instance row')
        ;

            insert into queries
            values ('DupSopsWithConflictingPixels', 'select distinct sop_instance_uid, count
  from (
    select
      distinct sop_instance_uid, count(*)
    from (
      select
        sop_instance_uid, unique_pixel_data.digest as pixel_digest
      from
        file_sop_common natural join file natural join file_image join
        image using (image_id) join unique_pixel_data using (unique_pixel_data_id)
    )as foo group by sop_instance_uid
  ) as foo where count > 1', '{}', 
                    ARRAY['sop_instance_uid', 'count'], ARRAY['pix_data_dups'], 'posda_files', 'Find list of series with SOP with duplicate pixel data')
        ;

            insert into queries
            values ('WhereFileSitsExt', 'select distinct
  project_name as collection,
  site_name as site,
  visibility,
  patient_id,
  study_instance_uid,
  series_instance_uid,
  sop_instance_uid,
  sop_class_uid,
  modality,
  dicom_file_type,
  root_path || ''/'' || file_location.rel_path as path,
  date_trunc(''day'',  min(import_time)) as earliest_import_day,
  date_trunc(''day'', max(import_time)) as latest_import_day
from
  dicom_file natural join
  file_patient natural join
  file_study natural join
  file_series natural join
  file_sop_common natural join
  file_import natural join
  import_event 
  natural left join ctp_file
  join file_location using(file_id)
  natural join file_storage_root
where file_id = ?
group by 
  project_name, site_name, visibility,
  patient_id, study_instance_uid, series_instance_uid,
  sop_instance_uid, sop_class_uid, modality, dicom_file_type, path', ARRAY['file_id'], 
                    ARRAY['collection', 'site', 'visibility', 'patient_id', 'study_instance_uid', 'series_instance_uid', 'sop_instance_uid', 'sop_class_uid', 'modality', 'dicom_file_type', 'path', 'earliest_import_day', 'latest_import_day'], ARRAY['posda_files', 'sops', 'BySopInstance', 'by_file'], 'posda_files', 'Get Collection, Site, Patient, Study Hierarchy in which SOP resides
')
        ;

            insert into queries
            values ('SeriesEquipmentByValueSignature', 'select
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
', ARRAY['scan_id', 'value', 'tag_signature'], 
                    ARRAY['series_instance_uid', 'value', 'vr', 'element_signature', 'equipment_signature'], ARRAY['tag_usage'], 'posda_phi', 'List of series, values, vr seen in scan with equipment signature
')
        ;

            insert into queries
            values ('RowsInDicomFileWithNoPixelInfoRecent', 'select 
  file_id, root_path || ''/'' || rel_path as path
from dicom_file natural join file_location natural join file_storage_root
where has_pixel_data is null 
order by file_id desc limit ?', ARRAY['num_rows'], 
                    ARRAY['file_id', 'path'], ARRAY['adding_pixels_to_dicom_file'], 'posda_files', 'List of files (id, path) which are dicom_files with undefined pixel info')
        ;

            insert into queries
            values ('VisibleFilesByCollectionSitePatient', 'select
  distinct project_name as collection,
  site_name as site,
  patient_id, file_id, visibility
from
  ctp_file natural join file_patient
where
  project_name = ? and
  site_name = ? and
  patient_id = ? and
  visibility is null
order by collection, site, patient_id

', ARRAY['collection', 'site', 'patient_id'], 
                    ARRAY['collection', 'site', 'patient_id', 'file_id', 'visibility'], ARRAY['duplicates', 'dup_sops', 'hide_dup_sops', 'sops_different_series'], 'posda_files', 'Return a count of duplicate SOP Instance UIDs
')
        ;

            insert into queries
            values ('CountRowsInDicomFileWithUnpopulatedPixelInfo', 'select 
 count(*) from dicom_file where has_pixel_data is null', '{}', 
                    ARRAY['count'], ARRAY['adding_pixels_to_dicom_file'], 'posda_files', 'count rows in dicom_file with unpopulated pixel info')
        ;

            insert into queries
            values ('RoundCountsByCollection2DateRange', 'select
  round_id, collection,
  round_created,
  round_start,  
  round_end - round_start as duration,
  wait_count,
  process_count,
  num_entered,
  num_failed,
  num_dups,
  num_requests,
  priority
from
  round natural join round_counts natural join round_collection
where collection = ? and round_start > ? and round_end < ?
order by round_id, collection', ARRAY['collection', 'from', 'to'], 
                    ARRAY['round_id', 'collection', 'num_dups', 'round_created', 'round_start', 'duration', 'wait_count', 'process_count', 'num_entered', 'num_failed', 'num_dups', 'num_requests', 'priority'], ARRAY['NotInteractive', 'Backlog', 'Backlog Monitor', 'backlog_analysis_reporting_tools'], 'posda_backlog', 'Summary of rounds')
        ;

            insert into queries
            values ('CtWithBadModality', 'select distinct
  project_name as collection,
  site_name as site, 
  patient_id,
  series_instance_uid,
  modality,
  dicom_file_type,
  count(distinct file_id) as num_files
from
  file_series natural join ctp_file natural join file_patient
  natural join dicom_file
where 
  dicom_file_type = ''CT Image Storage'' and 
  visibility is null and
  modality != ''CT''
group by
  collection, site, patient_id, series_instance_uid, modality, dicom_file_type
order by
  collection, site, patient_id
', '{}', 
                    ARRAY['collection', 'site', 'patient_id', 'series_instance_uid', 'modality', 'dicom_file_type', 'num_files'], ARRAY['by_series', 'consistency', 'for_bill_series_consistency'], 'posda_files', 'Check a Series for Consistency
')
        ;

            insert into queries
            values ('ActivityStuffMoreWithEmailByUserDateRange', 'select
  distinct subprocess_invocation_id, background_subprocess_id, user_inbox_content_id,
  background_subprocess_report_id, file_id,
  background_subprocess_report.name as report_type,
  activity_id, when_script_started,
  when_background_entered, when_script_ended, 
  invoking_user, user_to_notify, button_name,
  operation_name, command_line
from
  subprocess_invocation natural left join background_subprocess natural left join background_subprocess_report
  natural left join user_inbox_content natural left join activity_inbox_content
where invoking_user = ? and background_subprocess_report.name = ''Email''
  and when_script_started >= ? and when_script_ended <=?
order by subprocess_invocation_id desc
', ARRAY['user', 'from', 'to'], 
                    ARRAY['subprocess_invocation_id', 'background_subprocess_id', 'user_inbox_content_id', 'background_subprocess_report_id', 'file_id', 'report_type', 'activity_id', 'when_script_started', 'when_background_entered', 'when_script_ended', 'invoking_user', 'user_to_notify', 'button_name', 'operation_name', 'command_line'], ARRAY['activity_timepoint_support'], 'posda_queries', 'Create An Activity Timepoint

')
        ;

            insert into queries
            values ('ShowFilesHiddenByCollectionSite', 'select 
  distinct project_name as collection,
  site_name as site,
  patient_id,
  reason_for as reason,
  prior_visibility as before,
  new_visibility as after,
  user_name as user,
  count(distinct file_id) as num_files,
  min(time_of_change) as earliest,
  max(time_of_change) as latest
from 
  file_visibility_change natural join
  file_patient natural join
  ctp_file
where
  project_name = ? and site_name = ?
group by
   collection, site, 
   patient_id,
   reason, before, after, user_name
order by
  earliest, patient_id', ARRAY['collection', 'site'], 
                    ARRAY['collection', 'site', 'patient_id', 'reason', 'before', 'after', 'user', 'num_files', 'earliest', 'latest'], ARRAY['old_hidden'], 'posda_files', 'Show Files Hidden By User Date Range')
        ;

            insert into queries
            values ('InsertFileLocation', 'insert into file_location(
  file_id, file_storage_root_id, rel_path
) values ( ?, ?, ?)', ARRAY['file_id', 'file_storage_root_id', 'rel_path'], 
                    '{}', ARRAY['NotInteractive', 'Backlog', 'Transaction', 'used_in_file_import_into_posda'], 'posda_files', 'Lock the file table in posda_files')
        ;

            insert into queries
            values ('GetDciodvfyWarningQuestionable', 'select
  dciodvfy_warning_id as id
from 
  dciodvfy_warning
where
  warning_type = ''QuestionableValue''
  and warning_reason = ?
  and warning_tag = ?
  and warning_index = ?
 ', ARRAY['warning_reason', 'warning_tag', 'warning_index'], 
                    ARRAY['id'], ARRAY['NotInteractive', 'used_in_dciodvfy'], 'posda_phi_simple', 'Get an dciodvfy_warnings row by warning_text (if present)')
        ;

            insert into queries
            values ('VisibleColSiteWithCtpLikeSite', 'select
  distinct project_name as collection, site_name as site, count(*) as num_files
from ctp_file
where visibility is null and project_name like ?
group by collection, site order by collection', ARRAY['pattern'], 
                    ARRAY['collection', 'site', 'num_files'], ARRAY['adding_ctp', 'find_patients', 'series_selection', 'ctp_col_site', 'select_for_phi'], 'posda_files', 'Get List of visible patients with CTP data')
        ;

            insert into queries
            values ('WhereSeriesSits', 'select distinct
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
', ARRAY['series_instance_uid'], 
                    ARRAY['collection', 'site', 'patient_id', 'study_instance_uid', 'series_instance_uid', 'num_files'], ARRAY['by_series_instance_uid', 'posda_files', 'sops'], 'posda_files', 'Get Collection, Site, Patient, Study Hierarchy in which series resides
')
        ;

            insert into queries
            values ('InsertFileCopyFromPublicRow', 'insert into file_copy_from_public(
  copy_from_public_id, sop_instance_uid, replace_file_id, copy_file_path
) values (
  ?, ?, ?, ?
)', ARRAY['copy_from_public_id', 'sop_instance_uid', 'replace_file_id', 'copy_file_path'], 
                    '{}', ARRAY['bills_test', 'copy_from_public'], 'posda_files', 'Add a filter to a tab')
        ;

            insert into queries
            values ('GetPatientMappingByCollection', 'select
  from_patient_id,
  to_patient_id,
  to_patient_name,
  collection_name,
  site_name,
  batch_number,
  date_shift,
  ''<'' || diagnosis_date || ''>'' as diagnosis_date,
  ''<'' || baseline_date || ''>'' as baseline_date,
  ''<'' || date_trunc(''year'', diagnosis_date) || ''>'' as year_of_diagnosis,
  baseline_date - diagnosis_date as computed_shift
from
  patient_mapping
where collection_name = ?
  ', ARRAY['collection_name'], 
                    ARRAY['from_patient_id', 'to_patient_id', 'to_patient_name', 'collection_name', 'site_name', 'batch_number', 'date_shift', 'diagnosis_date', 'baseline_date', 'year_of_diagnosis', 'computed_shift'], ARRAY['adding_ctp', 'for_scripting', 'patient_mapping', 'ACRIN-NSCLC-FDG-PET Curation'], 'posda_files', 'Retrieve entries from patient_mapping table')
        ;

            insert into queries
            values ('CtSeriesWithCtImageInfoByCollection', 'select
  distinct series_instance_uid, count(distinct file_id) as num_files
from file_series natural join file_ct_image natural join ctp_file
where kvp is not null and visibility is null and project_name = ? group by series_instance_uid', ARRAY['collection'], 
                    ARRAY['series_instance_uid', 'num_files'], ARRAY['populate_posda_files', 'bills_test', 'ct_image_consistency'], 'posda_files', 'Get CT Series with CT Image Info by collection

')
        ;

            insert into queries
            values ('FromDigestToDigestFromDicomEditCompare', 'select 
  from_file_digest, to_file_digest
from
  dicom_edit_compare
where
  subprocess_invocation_id = ?', ARRAY['subprocess_invocation_id'], 
                    ARRAY['from_file_digest', 'to_file_digest'], ARRAY['meta', 'test', 'hello', 'bills_test', 'hide_events'], 'posda_files', 'Add a filter to a tab')
        ;

            insert into queries
            values ('MsrkEquivalenceClassForRetry', 'update image_equivalence_class set
  processing_status = ''ReadyToProcess'',
  review_status = null
where image_equivalence_class_id = ?', ARRAY['image_equivalence_class_id'], 
                    '{}', ARRAY['by_collection', 'find_series', 'compare_collection_site', 'search_series', 'edit_files', 'simple_phi', 'dciodvfy', 'ctp_details', 'select_for_phi', 'visual_review_new_workflow'], 'posda_files', 'Get Series in A Collection, site with dicom_file_type, modality, and sop_count
')
        ;

            insert into queries
            values ('GetSopModalityPath', 'select 
  sop_instance_uid, modality,
  root_path || ''/'' || rel_path as path
from
  file_series natural join file_sop_common natural join file_location natural join file_storage_root
where
  file_id = ?', ARRAY['file_id'], 
                    ARRAY['sop_instance_uid', 'modality', 'path'], ARRAY['bills_test', 'comparing_posda_to_public'], 'posda_files', 'get sop_instance, modality, and path to file by file_id')
        ;

            insert into queries
            values ('ImportEventsWithTypeAndPatientId', 'select
  distinct import_event_id, import_time,  import_type, count(distinct file_id) as num_files
from
  import_event natural join file_import natural join file_patient
where
  import_type = ''multi file import'' and 
  patient_id like ?
group by import_event_id, import_time, import_type', ARRAY['patient_id_like'], 
                    ARRAY['import_event_id', 'import_time', 'import_type', 'num_files'], ARRAY['adding_ctp', 'find_patients', 'no_ctp_patients', 'import_event'], 'posda_files', 'Get Series in A Collection
')
        ;

            insert into queries
            values ('CreateBackgroundSubprocessParam', 'insert into background_subprocess_params(
  background_subprocess_id,
  param_index,
  param_value
) values (
  ?, ?, ?
)', ARRAY['background_subprocess_id', 'param_index', 'param_value'], 
                    '{}', ARRAY['NotInteractive', 'used_in_background_processing'], 'posda_queries', 'Create row in background_subprocess_params table

Used by background subprocess')
        ;

            insert into queries
            values ('GetNotQualifiedCTQPByLikeCollectionSiteWithFIleCount', 'select 
  collection, site, patient_id, qualified, count(distinct file_id) as num_files
from
  clinical_trial_qualified_patient_id join file_patient using (patient_id)
where collection like ? and site = ? and not qualified
group by collection, site, patient_id, qualified', ARRAY['collection_like', 'site'], 
                    ARRAY['collection', 'site', 'patient_id', 'qualified', 'num_files'], ARRAY['clin_qual'], 'posda_files', 'Create An Activity Timepoint

')
        ;

            insert into queries
            values ('BackgroundProcessStatsNew', 'select
  distinct operation_name, max(when_script_ended - when_script_started) as longest,
  min(when_script_ended - when_script_started) as shortest,
  avg(when_script_ended - when_script_started) as avg, count(*) as times_invoked,
  count(distinct invoking_user) as num_invokers,
  min(when_script_started) as first, max(when_script_started) as last
from
  background_subprocess natural join subprocess_invocation
where
  when_script_ended is not null
group by operation_name
order by last desc, times_invoked desc', '{}', 
                    ARRAY['operation_name', 'longest', 'shortest', 'avg', 'times_invoked', 'num_invokers', 'first', 'last'], ARRAY['invoking_user'], 'posda_files', 'Get a list of collections and sites
')
        ;

            insert into queries
            values ('InsCTQP', 'insert into clinical_trial_qualified_patient_id(
  collection, site, patient_id, qualified
) values (
  ?, ?, ?, ?
)
', ARRAY['collection', 'site', 'patient_id', 'qualified'], 
                    '{}', ARRAY['activity_timepoint_support'], 'posda_files', 'Create An Activity Timepoint

')
        ;

            insert into queries
            values ('InsertIntoDicomEditCompare', 'insert into dicom_edit_compare(
  edit_command_file_id,
  from_file_digest,
  to_file_digest,
  short_report_file_id,
  long_report_file_id
) values ( ?, ?, ?, ?, ?)', ARRAY['edit_command_file_id', 'from_file_digest', 'to_file_digest', 'short_report_file_id', 'long_report_file_id'], 
                    '{}', ARRAY['NotInteractive', 'Backlog', 'Transaction', 'used_in_file_import_into_posda'], 'posda_files', 'Lock the file table in posda_files')
        ;

            insert into queries
            values ('SeriesConsistency', 'select distinct
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
', ARRAY['series_instance_uid'], 
                    ARRAY['series_instance_uid', 'count', 'modality', 'series_number', 'laterality', 'series_date', 'series_time', 'performing_phys', 'protocol_name', 'series_description', 'operators_name', 'body_part_examined', 'patient_position', 'smallest_pixel_value', 'largest_pixel_value', 'performed_procedure_step_id', 'performed_procedure_step_start_date', 'performed_procedure_step_start_time', 'performed_procedure_step_desc', 'performed_procedure_step_comments'], ARRAY['by_series', 'consistency', 'series_consistency'], 'posda_files', 'Check a Series for Consistency
')
        ;

            insert into queries
            values ('CtImageDataConsistencyAcrossSeries', 'select 
  distinct kvp, scan_options, data_collection_diameter, reconstruction_diameter,
  dist_source_to_detect, dist_source_to_pat,gantry_tilt, table_height,
  rotation_dir, exposure_time, exposure, filter_type, generator_power, convolution_kernal,
  count(distinct file_id) as num_files
from file_ct_image where file_id in (
  select file_id from file_series natural join ctp_file where series_instance_uid = ?
)
group by
  kvp, scan_options, data_collection_diameter, reconstruction_diameter,
  dist_source_to_detect, dist_source_to_pat,gantry_tilt, table_height,
  rotation_dir, exposure_time, exposure, filter_type, generator_power, convolution_kernal
', ARRAY['series_instance_uid'], 
                    ARRAY['kvp', 'scan_options', 'data_collection_diameter', 'reconstruction_diameter', 'dist_source_to_detect', 'dist_source_to_pat', 'gantry_tilt', 'table_height', 'rotation_dir', 'exposure_time', 'filter_type', 'generator_power', 'convolution_kernal', 'num_files'], ARRAY['populate_posda_files', 'ct_image_consistency'], 'posda_files', 'Get CT Series with CT Image Info by collection

')
        ;

            insert into queries
            values ('ActivityStuffMoreWithEmailForAll', 'select
  distinct subprocess_invocation_id, background_subprocess_id, user_inbox_content_id,
  background_subprocess_report_id, file_id,
  background_subprocess_report.name as report_type,
  activity_id, when_script_started,
  when_background_entered, when_script_ended, 
  invoking_user, user_to_notify, button_name,
  operation_name, command_line
from
  subprocess_invocation natural left join background_subprocess natural left join background_subprocess_report
  natural left join user_inbox_content natural left join activity_inbox_content
where background_subprocess_report.name = ''Email''
order by subprocess_invocation_id desc
', '{}', 
                    ARRAY['subprocess_invocation_id', 'background_subprocess_id', 'user_inbox_content_id', 'background_subprocess_report_id', 'file_id', 'report_type', 'activity_id', 'when_script_started', 'when_background_entered', 'when_script_ended', 'invoking_user', 'user_to_notify', 'button_name', 'operation_name', 'command_line'], ARRAY['activity_timepoint_support'], 'posda_queries', 'Create An Activity Timepoint

')
        ;

            insert into queries
            values ('PosdaImagesByCollectionSite', 'select distinct
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
', ARRAY['collection', 'site'], 
                    ARRAY['PID', 'Modality', 'SopInstance', 'StudyDate', 'StudyDescription', 'SeriesDescription', 'StudyInstanceUID', 'SeriesInstanceUID', 'Mfr', 'Model', 'software_versions'], ARRAY['posda_files'], 'posda_files', 'List of all Files Images By Collection, Site
')
        ;

            insert into queries
            values ('SeriesVisualReviewResultsByLikeCollectionSiteSummary', 'select 
  distinct
  dicom_file_type,
  modality,
  review_status,
  processing_status,
  count(distinct series_instance_uid) as num_series,
  count(distinct file_id) as num_files
from 
  dicom_file natural join 
  file_series natural join 
  ctp_file join 
  image_equivalence_class using(series_instance_uid)
where
  project_name like  ? and
  visibility is null
group by
  dicom_file_type,
  modality,
  review_status,
  processing_status
', ARRAY['project_name'], 
                    ARRAY['dicom_file_type', 'modality', 'review_status', 'processing_status', 'num_series', 'num_files'], ARRAY['find_series', 'equivalence_classes', 'consistency', 'visual_review_results', 'hide_files'], 'posda_files', 'Get visual review status report by series for Collection, Site')
        ;

            insert into queries
            values ('GetDciodvfyErrorId', 'select currval(''dciodvfy_error_dciodvfy_error_id_seq'') as id', '{}', 
                    ARRAY['id'], ARRAY['NotInteractive', 'used_in_dciodvfy'], 'posda_phi_simple', 'Create a id of newly created dciodvfy_error row')
        ;

            insert into queries
            values ('SetLoadPathByImportEventIdAndFileId', 'update file_import set file_name = ? where file_id = ? and import_event_id = ?', ARRAY['file_name', 'file_id', 'import_event_id'], 
                    '{}', ARRAY['import_events', 'QIN-GBM-DSC-MRI-DRO/Barrow'], 'posda_files', 'Counts query by Collection, Site
')
        ;

            insert into queries
            values ('GetSsByCollection', 'select
  distinct project_name as collection,
  site_name as site,
  patient_id, file_id
from
  ctp_file natural join file_patient
where file_id in (
 select distinct file_id from file_structure_set
)
and project_name = ? and visibility is null
order by collection, site, patient_id, file_id
', ARRAY['collection'], 
                    ARRAY['collection', 'site', 'patient_id', 'file_id'], ARRAY['Structure Sets', 'sops', 'LinkageChecks', 'struct_linkages'], 'posda_files', 'Get list of plan which reference unknown SOPs

')
        ;

            insert into queries
            values ('GetDciodvfyErrorBadVm', 'select
  dciodvfy_error_id as id
from 
  dciodvfy_error
where
  error_type = ''BadValueMultiplicity''
  and error_tag = ?
  and error_value = ?
  and error_index = ?
  and error_module = ?
', ARRAY['error_tag', 'error_value', 'error_index', 'error_module'], 
                    ARRAY['id'], ARRAY['NotInteractive', 'used_in_dciodvfy'], 'posda_phi_simple', 'Get an dciodvfy_errors row by error_text (if present)')
        ;

            insert into queries
            values ('AreVisibleFilesMarkedAsBadOrUnreviewedInSeriesTest', 'select 
  collection,
  site,
  patient_id,
  series_instance_uid,
  dicom_file_type,
  modality,
  review_status,
  processing_status,
  count(distinct file_id) as num_files
from (
  select 
    distinct project_name as collection,
    site_name as site,
    patient_id,
    series_instance_uid,
    dicom_file_type,
    modality,
    review_status,
    processing_status,
    visibility,
    file_id
  from 
    dicom_file natural join 
    file_series natural join 
    file_patient natural join
    ctp_file natural join 
  (
    select file_id, review_status, processing_status
    from
      image_equivalence_class_input_image natural join
      image_equivalence_class join
      ctp_file using(file_id)
    where
      series_instance_uid = ?
  ) as foo
) as foo
where
  visibility is null 
group by
  collection,
  site,
  patient_id,
  series_instance_uid,
  dicom_file_type,
  modality,
  review_status,
  processing_status
', ARRAY['series_instance_uid'], 
                    ARRAY['collection', 'site', 'patient_id', 'series_instance_uid', 'dicom_file_type', 'modality', 'review_status', 'processing_status', 'visibility', 'num_files'], ARRAY['find_series', 'equivalence_classes', 'consistency', 'visual_review_results', 'hide_events'], 'posda_files', 'Get visual review status report by series for Collection, Site')
        ;

            insert into queries
            values ('GetActivityTaskStatus', 'select
  subprocess_invocation_id,
  operation_name,
  start_time,
  last_updated,
  status_text,
  expected_remaining_time,
  end_time
from
  activity_task_status natural join subprocess_invocation
where
  activity_id = ? and dismissed_time is null', ARRAY['activity_id'], 
                    ARRAY['operation_name', 'start_time', 'last_updated', 'status_text', 'expected_remaining_time', '  end_time'], ARRAY['Insert', 'NotInteractive'], 'posda_files', 'Insert Initial Patient Status
For use in scripts
Not really intended for interactive use
')
        ;

            insert into queries
            values ('DeleteLastTagFromQuery', 'update queries 
  set tags = tags[1:(array_upper(tags,1) -1)]
where name = ?', ARRAY['name'], 
                    '{}', ARRAY['meta', 'test', 'hello', 'query_tags'], 'posda_queries', 'Add a tag to a query')
        ;

            insert into queries
            values ('GetDciodvfyUnitScanWarningId', 'select currval(''dciodvfy_unit_scan_warning_dciodvfy_unit_scan_warning_id_seq'') as id', '{}', 
                    ARRAY['id'], ARRAY['NotInteractive', 'used_in_dciodvfy'], 'posda_phi_simple', 'Create a dciodvfy_scan_instance row')
        ;

            insert into queries
            values ('ShowAllVisibilityChangesBySeriesInstance', 'select
  distinct
  user_name,
  time_of_change,
  prior_visibility,
  new_visibility,
  reason_for,
  count (distinct file_id) as num_files
from
   file_visibility_change 
where file_id in (
  select distinct file_id 
  from file_series
  where series_instance_uid = ?
)
group by user_name, time_of_change,
  prior_visibility, new_visibility, reason_for
order by time_of_change', ARRAY['series_instance_uid'], 
                    ARRAY['user_name', 'time_of_change', 'prior_visibility', 'new_visibility', 'reason_for', 'num_files'], ARRAY['old_hidden'], 'posda_files', 'Show All Hide Events by Collection, Site')
        ;

            insert into queries
            values ('StudySeriesForFile', 'select study_instance_uid, series_instance_uid from file_series natural join file_study where file_id = ?', ARRAY['file_id'], 
                    ARRAY['study_instance_uid', 'series_instance_uid'], ARRAY['activity_timepoint_support'], 'posda_files', 'Create An Activity Timepoint

')
        ;

            insert into queries
            values ('RoundStatsForDateRange', 'select
  date_trunc(?, time_received) as time,
  count(*) as number_of_files,
  max(time_entered - time_received) as max_delay,
  min(time_entered - time_received) as min_delay
from request
where time_received > ? and time_received < ?
group by time order by time desc', ARRAY['interval', 'from', 'to'], 
                    ARRAY['time', 'number_of_files', 'max_delay', 'min_delay'], ARRAY['NotInteractive', 'Backlog', 'Backlog Monitor', 'for_bill'], 'posda_backlog', 'Summary of rounds')
        ;

            insert into queries
            values ('ValuesWithVrTagAndCount', 'select
    distinct vr, value, element_signature, private_disposition, count(*)  as num_files
from
    scan_event natural join series_scan natural join seen_value
    natural join element_signature natural join scan_element
where
    scan_event_id = ?
group by value, element_signature, vr, private_disposition
', ARRAY['scan_id'], 
                    ARRAY['vr', 'value', 'element_signature', 'private_disposition', 'num_files'], ARRAY['tag_usage', 'PrivateTagKb'], 'posda_phi', 'List of values seen in scan by VR (with count of elements)
')
        ;

            insert into queries
            values ('GetSimpleValuesByEleVr', 'select
  distinct value
from
  element_seen
  join element_value_occurance using(element_seen_id)
  join value_seen using(value_seen_id)
where element_sig_pattern = ? and vr = ?
', ARRAY['tag', 'vr'], 
                    ARRAY['value'], ARRAY['tag_values'], 'posda_phi_simple', 'Find Values for a given tag, vr in posda_phi_simple
')
        ;

            insert into queries
            values ('GetSeriesWithImageByCollectionSitePatient', 'select distinct
  project_name as collection, site_name as site,
  patient_id, modality, series_instance_uid, 
  count(distinct sop_instance_uid) as num_sops,
  count(distinct file_id) as num_files
from
  file_series natural join file_sop_common
  natural join file_patient
  natural join file_image natural join ctp_file
  natural join file_import natural join import_event
where 
  project_name = ? and 
  site_name = ? and 
  patient_id = ? and
  visibility is null
group by
  collection, site, patient_id, modality, series_instance_uid
', ARRAY['collection', 'site', 'patient_id'], 
                    ARRAY['collection', 'site', 'patient_id', 'modality', 'series_instance_uid', 'num_sops', 'num_files'], ARRAY['signature', 'phi_review', 'visual_review'], 'posda_files', 'Get a list of Series with images by CollectionSite
')
        ;

            insert into queries
            values ('ImportEventsByMatchingName', 'select
  import_event_id, import_comment, import_time, import_close_time, count(distinct file_id) as num_images
from 
  import_event natural join file_import
where
  import_comment like ?
group by import_event_id, import_comment, import_time, import_close_time', ARRAY['import_comment_like'], 
                    ARRAY['import_event_id', 'import_comment', 'import_time', 'import_close_time', 'num_images'], ARRAY['import_events'], 'posda_files', 'Get Import Events by matching comment')
        ;

            insert into queries
            values ('TagsInMultipleTagFilters', 'select distinct tag, count(*) as num_locations
from (
  select 
     query_tab_name,
      filter_name,
      unnest(tags_enabled) as tag
  from
    query_tabs join query_tabs_query_tag_filter using(query_tab_name)
    natural join query_tag_filter
) as foo
group by tag
order by num_locations desc', '{}', 
                    ARRAY['tag', 'num_locations'], ARRAY['meta', 'test', 'hello', 'query_tabs', 'bills_test'], 'posda_queries', 'Add a filter to a tab')
        ;

            insert into queries
            values ('SeriesInHierarchyBySeries', 'select distinct
  project_name as collection,
  site_name as site,
  patient_id,
  study_instance_uid,
  series_instance_uid
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
order by
  project_name, site_name, patient_id,
  study_instance_uid, series_instance_uid
', ARRAY['series_instance_uid'], 
                    ARRAY['collection', 'site', 'patient_id', 'study_instance_uid', 'series_instance_uid'], ARRAY['by_series_instance_uid', 'posda_files', 'sops'], 'posda_files', 'Get Collection, Site, Patient, Study Hierarchy in which series resides
')
        ;

            insert into queries
            values ('RTDOSEWithBadModality', 'select distinct
  project_name as collection,
  site_name as site, 
  patient_id,
  series_instance_uid,
  modality,
  dicom_file_type,
  count(distinct file_id) as num_files
from
  file_series natural join ctp_file natural join file_patient
  natural join dicom_file
where 
  dicom_file_type = ''RT Dose Storage'' and 
  visibility is null and
  modality != ''RTDOSE''
group by
  collection, site, patient_id, series_instance_uid, modality, dicom_file_type
order by
  collection, site, patient_id
', '{}', 
                    ARRAY['collection', 'site', 'patient_id', 'series_instance_uid', 'modality', 'dicom_file_type', 'num_files'], ARRAY['by_series', 'consistency', 'for_bill_series_consistency'], 'posda_files', 'Check a Series for Consistency
')
        ;

            insert into queries
            values ('ImportEventsWithMultiFileLikePatientId', 'select
  distinct import_event_id, import_time,  import_type, patient_id, count(distinct file_id) as num_files
from
  import_event natural join file_import natural join file_patient
where
  import_type = ''multi file import'' and 
  import_time > ? and import_time < ?
group by import_event_id, import_time, import_type, patient_id', ARRAY['from', 'to'], 
                    ARRAY['import_event_id', 'import_time', 'import_type', 'patient_id', 'num_files'], ARRAY['adding_ctp', 'find_patients', 'no_ctp_patients', 'import_event'], 'posda_files', 'Get Series in A Collection
')
        ;

            insert into queries
            values ('SimpleCountQuery', 'select
  distinct
    patient_id, dicom_file_type, modality,
    study_instance_uid, series_instance_uid,
    count(distinct sop_instance_uid) as num_sops,
    count(distinct file_id) as num_files
from
  ctp_file join file_patient using(file_id)
  join dicom_file using(file_id)
  join file_series using(file_id)
  join file_sop_common using(file_id)
  join file_study using(file_id)
where
  project_name = ?  and site_name = ? and visibility is null
group by
  patient_id, dicom_file_type, modality,
  study_instance_uid, series_instance_uid
order by
  patient_id, study_instance_uid, series_instance_uid,
  modality
', ARRAY['collection', 'site'], 
                    ARRAY['patient_id', 'dicom_file_type', 'modality', 'study_instance_uid', 'series_instance_uid', 'num_sops', 'num_files'], ARRAY['counts', 'count_queries'], 'posda_files', 'Counts query by Collection, Site
')
        ;

            insert into queries
            values ('PatientsWithEditedFiles', 'select
  distinct project_name as collection,
  site_name as site,
  patient_id,
  count(distinct sop_instance_uid) as num_sops,
  count(distinct file_id) as num_files
from
  ctp_file natural join
  file_patient natural join
  file_sop_common
where file_id in (
  select 
    distinct file_id 
  from 
    file f natural join dicom_edit_compare dec
  where
    f.digest = dec.to_file_digest and subprocess_invocation_id in (
      select distinct subprocess_invocation_id
      from dicom_edit_compare_disposition
      where current_disposition like ''Import Complete%''
    )
)
group by collection, site, patient_id
order by collection, site, patient_id', '{}', 
                    ARRAY['collection', 'site', 'patient_id', 'num_sops', 'num_files'], ARRAY['adding_ctp', 'for_scripting', 'patient_queries'], 'posda_files', 'Get a list of to files from the dicom_edit_compare table for a particular edit instance, with file_id and visibility

NB: Normally there should be no file_id (i.e. file has not been imported)')
        ;

            insert into queries
            values ('GetSlopeIntercept', 'select
  slope, intercept, si_units
from
  file_slope_intercept natural join slope_intercept
where
  file_id = ?
', ARRAY['file_id'], 
                    ARRAY['slope', 'intercept', 'si_units'], ARRAY['by_file_id', 'posda_files', 'slope_intercept'], 'posda_files', 'Get a Slope, Intercept for a particular file 
')
        ;

            insert into queries
            values ('CreateDciodvfyUnitScanWarning', 'insert into dciodvfy_unit_scan_warning(
  dciodvfy_scan_instance_id,
  dciodvfy_unit_scan_id,
  dciodvfy_warning_id
)values (?, ?, ?)', ARRAY[' dicodvfy_scan_instance_id', 'dciodvfy_unit_scan_id', 'dciodvfy_warning_id'], 
                    '{}', ARRAY['NotInteractive', 'used_in_dciodvfy'], 'posda_phi_simple', 'Create a dciodvfy_unit_scan_error row')
        ;

            insert into queries
            values ('WhatHasComeInRecentlyByCollectionLikeAndFileInPosdaCount', 'select
  distinct collection, site, date_trunc(?, time_received) as time,
  count(*) as number_of_files, count(distinct posda_file_id) as num_files_in_posda,
  max(time_entered - time_received) as max_delay,
  min(time_entered - time_received) as min_delay
from request natural join submitter
where time_received > ? and time_received < ?
and collection like ?
group by collection, site, time order by time desc, collection, site', ARRAY['interval', 'from', 'to', 'collection_like'], 
                    ARRAY['collection', 'site', 'time', 'number_of_files', 'num_files_in_posda', 'max_delay', 'min_delay'], ARRAY['NotInteractive', 'Backlog', 'Backlog Monitor', 'backlog_round_history'], 'posda_backlog', 'Summary of rounds')
        ;

            insert into queries
            values ('NumEquipSigsForPrivateTagSigs', 'select distinct element_signature, count(*) from (
select
  distinct element_signature, equipment_signature
from 
  equipment_signature natural join series_scan
  natural join scan_element natural join element_signature
  natural join scan_event
where scan_event_id = ? and is_private) as foo
group by element_signature
order by element_signature
', ARRAY['scan_id'], 
                    ARRAY['element_signature', 'count'], ARRAY['tag_usage'], 'posda_phi', 'Number of Equipment signatures in which tags are featured
')
        ;

            insert into queries
            values ('GetElementSignatureId', 'select currval(''element_signature_element_signature_id_seq'') as id', '{}', 
                    ARRAY['id'], ARRAY['NotInteractive', 'UsedInPhiSeriesScan', 'ElementDisposition'], 'posda_phi', 'Get current value of ElementSignatureId Sequence
')
        ;

            insert into queries
            values ('InsertFilePosdaReturnID', 'insert into file( digest, size, processing_priority, ready_to_process) values ( ?, ?, 1, false) on conflict  do nothing returning file_id;', ARRAY['digest', 'size'], 
                    ARRAY['file_id'], ARRAY['NotInteractive', 'Backlog', 'Transaction', 'used_in_file_import_into_posda'], 'posda_files', 'Insert a file without locking the table')
        ;

            insert into queries
            values ('FileNameReportByImportEventWithMrData', 'select
  file_id, patient_id,
  study_instance_uid, study_date, study_description, series_instance_uid,
  modality, series_date, series_description, dicom_file_type, file_name,
  mr_scanning_seq, mr_scanning_var, mr_scan_options,
  mr_acq_type, mr_slice_thickness, mr_repetition_time,
  mr_echo_time, mr_magnetic_field_strength, mr_spacing_between_slices,
  mr_echo_train_length, mr_software_version, mr_flip_angle
from
  file_import natural join file_patient natural join file_series natural join
  file_study natural join dicom_file natural left join file_mr
where
  import_event_id = ?
order by file_name', ARRAY['import_event_id'], 
                    ARRAY['file_id', 'patient_id', 'study_instance_uid', 'study_date', 'study_description', 'series_instance_uid', 'modality', 'series_date', 'series_description', 'dicom_file_type', 'file_name', 'mr_scanning_seq', 'mr_scanning_var', 'mr_scan_options', 'mr_acq_type', 'mr_slice_thickness', 'mr_repetition_time', 'mr_echo_time', 'mr_magnetic_field_strength', 'mr_spacing_between_slices', 'mr_echo_train_length', 'mr_software_version', 'mr_flip_angle'], ARRAY['import_events'], 'posda_files', 'List of values seen in scan by ElementSignature with VR and count
')
        ;

            insert into queries
            values ('TagsSeenSimplePrivateWithCount', 'select 
  distinct element_sig_pattern,
  vr,
  private_disposition, tag_name,
  count(distinct value) as num_values
from
  element_seen natural left join
  element_value_occurance
  natural left join value_seen
where
  is_private 
group by element_sig_pattern, vr, private_disposition, tag_name
order by element_sig_pattern;', '{}', 
                    ARRAY['element_sig_pattern', 'vr', 'private_disposition', 'tag_name', 'num_values'], ARRAY['by_collection', 'find_series', 'compare_collection_site', 'search_series', 'edit_files', 'phi_maint'], 'posda_phi_simple', 'Get all the data from tags_seen in posda_phi_simple database
')
        ;

            insert into queries
            values ('GetImageGeoBySop1', 'select
  iop, ipp, for_uid, series_instance_uid
from
  image_geometry natural join file_image_geometry natural join file_series
where
  file_id in 
  (
    select 
      file_id 
    from
      file_sop_common natural join ctp_file
    where
      sop_instance_uid = ? and visibility is null
  )', ARRAY['sop_instance_uid'], 
                    ARRAY['iop', 'ipp', 'for_uid', 'series_instance_uid'], ARRAY['LinkageChecks', 'BySopInstance'], 'posda_files', 'Get Geometric Information by Sop Instance UID from posda')
        ;

            insert into queries
            values ('PixDupsByCollecton', 'select 
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
', ARRAY['collection'], 
                    ARRAY['series_instance_uid', 'count'], ARRAY['pix_data_dups'], 'posda_files', 'Counts of duplicate pixel data in series by Collection
')
        ;

            insert into queries
            values ('PatientStudySeriesHierarchyByCollectionSiteWithCounts', 'select distinct
  patient_id,
  study_instance_uid,
  series_instance_uid,
  count(distinct file_id) as num_files
from
  file_study natural join ctp_file natural join file_series natural join file_patient
where 
  file_id in (
    select distinct file_id
    from ctp_file
    where project_name = ? and site_name = ? and
    visibility is null
  )
group by patient_id, study_instance_uid, series_instance_uid
order by patient_id, study_instance_uid, series_instance_uid', ARRAY['collection', 'site'], 
                    ARRAY['patient_id', 'study_instance_uid', 'series_instance_uid', 'num_files'], ARRAY['Hierarchy', 'apply_disposition'], 'posda_files', 'Construct list of files in a collection, site in a Patient, Study, Series Hierarchy')
        ;

            insert into queries
            values ('DismissInboxItem', '
update user_inbox_content
set date_dismissed = now()
where user_inbox_content_id = ?

', ARRAY['user_inbox_content_id'], 
                    '{}', '{}', 'posda_queries', 'Set the date_dismissed value on an Inbox item')
        ;

            insert into queries
            values ('ListOfAvailableQueriesByNameLike', 'select schema, name, description, tags from (
  select
    schema, name, description,
    array_to_string(tags, '','') as tags
  from queries
) as foo
where name like ?
order by name', ARRAY['name_like'], 
                    ARRAY['schema', 'name', 'description', 'tags'], ARRAY['AllCollections', 'q_list'], 'posda_queries', 'Get a list of available queries')
        ;

            insert into queries
            values ('FilesInHierarchyByPatient', 'select distinct
  project_name as collection,
  site_name as site,
  patient_id,
  study_instance_uid,
  series_instance_uid,
  study_date,
  count (distinct file_id) as num_files
from
  file_patient natural join
  file_study natural join
  file_series natural join
  ctp_file
where file_id in (
  select
    distinct file_id
  from
    file_patient natural join ctp_file
  where
    patient_id = ? and visibility is null
)
group by collection, site, patient_id, 
  study_instance_uid, series_instance_uid, study_date
order by
  project_name, site_name, patient_id,
  study_instance_uid, series_instance_uid
', ARRAY['patient_id'], 
                    ARRAY['collection', 'site', 'patient_id', 'study_instance_uid', 'series_instance_uid', 'study_date', 'num_files'], ARRAY['by_series_instance_uid', 'posda_files', 'sops'], 'posda_files', 'Get Collection, Site, Patient, Study Hierarchy in which series resides
')
        ;

            insert into queries
            values ('LockErrors', 'lock table dciodvfy_error', '{}', 
                    '{}', ARRAY['NotInteractive', 'used_in_dciodvfy'], 'posda_phi_simple', 'Create a dciodvfy_scan_instance row')
        ;

            insert into queries
            values ('SummaryOfSeriesInUnhiddenBadEquivalenceClasses', 'select distinct project_name as collection, site_name as site, patient_id, series_instance_uid, modality, dicom_file_type, count(distinct file_id) as num_files from
ctp_file natural join file_patient natural join file_series natural join dicom_file where file_id in (
select distinct file_id from file_sop_common natural join ctp_file where visibility is null and sop_instance_uid in (
select sop_instance_uid from file_sop_common where file_id in (
select distinct file_id from image_equivalence_class natural join image_equivalence_class_input_image where visual_review_instance_id = ? and review_status = ''Bad'' ))) group by collection, site, patient_id, series_instance_uid, modality, dicom_file_type', ARRAY['visual_review_instance_id'], 
                    ARRAY['collection', 'site', 'patient_id', 'series_instance_uid', 'modality', 'dicom_file_type', 'num_files'], ARRAY['by_collection', 'find_series', 'compare_collection_site', 'search_series', 'edit_files', 'simple_phi', 'dciodvfy', 'ctp_details', 'select_for_phi', 'visual_review_status'], 'posda_files', 'Get Series in A Collection, site with dicom_file_type, modality, and sop_count
')
        ;

            insert into queries
            values ('AllManifestsByCollectionLike', 'select
  distinct file_id, import_time, size, root_path || ''/'' || l.rel_path as path, i.file_name as alt_path
from
  file_location l join file_storage_root using(file_storage_root_id) 
  join file_import i using (file_id) natural join file join import_event using(import_event_id)
where
  file_id in (
    select distinct file_id from ctp_manifest_row where cm_collection like ?
  )', ARRAY['collection_like'], 
                    ARRAY['file_id', 'import_time', 'size', 'path', 'alt_path'], ARRAY['activity_timepoint_support', 'manifests'], 'posda_files', 'Create An Activity Timepoint

')
        ;

            insert into queries
            values ('ReviewEditsByTimeSpan', 'select
  distinct project_name,
  site_name,
  series_instance_uid,
  new_visibility,
  reason_for,
  min(time_of_change) as earliest,
  max(time_of_change) as latest,
  count(*) as num_files
from
  file_visibility_change natural join
  ctp_file natural join
  file_series
where
  time_of_change > ? and time_of_change < ?
group by
  project_name,
  site_name,
  series_instance_uid,
  new_visibility,
  reason_for', ARRAY['from', 'to'], 
                    ARRAY['project_name', 'site_name', 'series_instance_uid', 'new_visibility', 'reason_for', 'earliest', 'latest', 'num_files'], ARRAY['Hierarchy', 'review_visibility_changes'], 'posda_files', 'Show all file visibility changes by series over a time range')
        ;

            insert into queries
            values ('FirstFileInSeriesPosda', 'select root_path || ''/'' || rel_path as path
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
', ARRAY['series_instance_uid'], 
                    ARRAY['path'], ARRAY['by_series', 'UsedInPhiSeriesScan'], 'posda_files', 'First files in series in Posda
')
        ;

            insert into queries
            values ('PixelTypesWithSlopeCT', 'select
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
', '{}', 
                    ARRAY['photometric_interpretation', 'samples_per_pixel', 'bits_allocated', 'bits_stored', 'high_bit', 'pixel_representation', 'planar_configuration', 'modality', 'slope', 'intercept', 'count'], '{}', 'posda_files', 'Get distinct pixel types
')
        ;

            insert into queries
            values ('SelectPtInfoSummary', 'select 
  distinct pti_radiopharmaceutical as radiopharmaceutical, 
  pti_radionuclide_total_dose as total_dose,
  pti_radionuclide_half_life as half_life,
  pti_radionuclide_positron_fraction as positron_fraction, 
  pti_fov_shape as fov_shape,
  pti_fov_dimensions as fov_dim,
  pti_collimator_type as coll_type,
  pti_reconstruction_diameter as recon_diam, 
  count(*) as num_files
from file_pt_image 
group by 
  radiopharmaceutical,
  total_dose,
  half_life,
  positron_fraction,
  fov_shape,
  fov_dim,
  coll_type,
  recon_diam', '{}', 
                    ARRAY['radiopharmaceutical', 'total_dose', 'half_life', 'positron_fraction', 'fov_shape', 'fov_dim', 'coll_type', 'recon_diam', 'num_files'], ARRAY['populate_posda_files', 'bills_test'], 'posda_files', 'Gets count of all files which are PET''s which haven''t been imported into file_pt_image yet.

')
        ;

            insert into queries
            values ('PixelInfoByFileId', 'select
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
', ARRAY['image_id'], 
                    ARRAY['file', 'file_offset', 'size', 'bits_stored', 'bits_allocated', 'pixel_representation', 'number_of_frames', 'samples_per_pixel', 'pixel_rows', 'pixel_columns', 'photometric_interpretation'], '{}', 'posda_files', 'Get pixel descriptors for a particular image id
')
        ;

            insert into queries
            values ('DupSopsByCollectionSiteDateRange', 'select
  distinct collection, site, subj_id, 
  sop_instance_uid,
  count(distinct file_id) as num_files
from (
  select
    distinct project_name as collection,
    site_name as site, patient_id as subj_id,
    study_instance_uid, series_instance_uid,
    sop_instance_uid,
    file_id
  from
    ctp_file natural join file_sop_common
    natural join file_patient natural join file_study natural join file_series
  where
    sop_instance_uid in (
      select distinct sop_instance_uid 
      from (
        select distinct sop_instance_uid, count(distinct file_id)
        from file_sop_common natural join ctp_file
        where visibility is null and sop_instance_uid in (
          select distinct sop_instance_uid
          from file_sop_common natural join ctp_file
            join file_import using(file_id) 
            join import_event using(import_event_id)
          where project_name = ? and site_name = ? and
             visibility is null and import_time > ?
              and import_time < ?
        ) group by sop_instance_uid
      ) as foo 
      where count > 1
    )
    and visibility is null
  ) as foo
group by collection, site, subj_id, sop_instance_uid

', ARRAY['collection', 'site', 'from', 'to'], 
                    ARRAY['collection', 'site', 'subj_id', 'sop_instance_uid', 'num_files'], ARRAY['duplicates', 'dup_sops', 'hide_dup_sops'], 'posda_files', 'Return a count of duplicate SOP Instance UIDs
')
        ;

            insert into queries
            values ('PublicSeriesByCollectionMetadata', 'select
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
  q.software_versions,
   count( i.sop_instance_uid) as Images
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
  tdp.project = ? 
group by PID, StudyDate, Modality
', ARRAY['collection'], 
                    ARRAY['PID', 'Modality', 'StudyDate', 'StudyDescription', 'SeriesDescription', 'SeriesNumber', 'StudyInstanceUID', 'SeriesInstanceUID', 'Mfr', 'Model', 'software_versions', 'Images'], ARRAY['public'], 'public', 'List of all Series By Collection, Site on Public with metadata
')
        ;

            insert into queries
            values ('ActivityStuffMoreByUserByDateRange', 'select
  distinct subprocess_invocation_id, background_subprocess_id, user_inbox_content_id,
  background_subprocess_report_id, file_id,
  background_subprocess_report.name as report_type,
  activity_id, when_script_started,
  when_background_entered, when_script_ended, 
  invoking_user, user_to_notify, button_name,
  operation_name, command_line
from
  subprocess_invocation natural left join background_subprocess natural left join background_subprocess_report
  natural left join user_inbox_content natural left join activity_inbox_content
where invoking_user = ? and when_script_started >= ? and when_script_ended <= ?
order by subprocess_invocation_id desc
', ARRAY['user', 'from', 'to'], 
                    ARRAY['subprocess_invocation_id', 'background_subprocess_id', 'user_inbox_content_id', 'background_subprocess_report_id', 'file_id', 'report_type', 'activity_id', 'when_script_started', 'when_background_entered', 'when_script_ended', 'invoking_user', 'user_to_notify', 'button_name', 'operation_name', 'command_line'], ARRAY['activity_timepoint_support'], 'posda_queries', 'Create An Activity Timepoint

')
        ;

            insert into queries
            values ('SeriesSopsForCollectionSiteReport', 'select 
  distinct project_name as collection, site_name as site, count(distinct patient_id) as num_subjects,
  count(distinct series_instance_uid) as num_series, count(distinct sop_instance_uid) as num_images
from
  ctp_file natural join file_patient natural join file_series natural join file_sop_common natural join file_image
where visibility is null
group by collection, site
order by num_images desc', '{}', 
                    ARRAY['collection', 'site', 'num_subjects', 'num_series', 'num_images'], ARRAY['AllCollections', 'q_stats'], 'posda_files', 'Get a list of collections and sites
')
        ;

            insert into queries
            values ('ProjectCompletion', 'select
  ((now() - ?) / ?) * (cast(? as float) - cast(? as float)) + now() as projected_completion', ARRAY['start_time', 'num_done_1', 'num_to_do', 'num_done_2'], 
                    ARRAY['projected_completion'], ARRAY['bills_test'], 'posda_phi_simple', 'Status of PHI scans
')
        ;

            insert into queries
            values ('DciodvfyErrorsBySeriesAndScanInstance', 'select
  dciodvfy_error_id,
  error_type,
  error_tag,
  error_value,
  error_subtype,
  error_module,
  error_reason,
  error_index,
  error_text
from dciodvfy_error 
where  dciodvfy_error_id in (
  select distinct dciodvfy_error_id
  from (
    select
      distinct unit_uid, dciodvfy_error_id
    from
      dciodvfy_unit_scan
      natural join dciodvfy_unit_scan_error
    where
      dciodvfy_scan_instance_id = ? and unit_uid =?
  )
 as foo
)', ARRAY['dciodvfy_scan_instance_id', 'series_instance_uid'], 
                    ARRAY['dciodvfy_error_id', 'error_type', 'error_tag', 'error_value', 'error_subtype', 'error_module', 'error_reason', 'error_index', 'error_text'], ARRAY['tag_usage', 'dciodvfy'], 'posda_phi_simple', 'Show all the dciodvfy scans')
        ;

            insert into queries
            values ('SsSopToForByCollectionSite', 'select 
  distinct patient_id,  sop_instance_uid, 
  for_uid
from 
  roi natural join file_structure_set join file_sop_common using(file_id) join file_patient using (file_id)
where
  file_id in (
    select file_id 
    from ctp_file natural join file_structure_set 
    where project_name = ? and site_name = ? and visibility is null
  )
order by patient_id', ARRAY['collection', 'site'], 
                    ARRAY['patient_id', 'sop_instance_uid', 'for_uid'], ARRAY['Structure Sets', 'sops', 'LinkageChecks', 'struct_linkages'], 'posda_files', 'Get list of plan which reference unknown SOPs

')
        ;

            insert into queries
            values ('RoundCountsByCollection', 'select 
  round_id, num_requests
from round natural join round_counts
where collection = ?', ARRAY['collection'], 
                    ARRAY['round_id', 'num_requests'], ARRAY['NotInteractive', 'Backlog', 'Backlog Monitor'], 'posda_backlog', 'Summary of rounds')
        ;

            insert into queries
            values ('DismissInboxContenIItem', 'update user_inbox_content
set date_dismissed = now(),
current_status = ''dismissed''
where user_inbox_content_id = ?

', ARRAY['user_inbox_content_id'], 
                    '{}', '{}', 'posda_queries', 'Set the date_dismissed value on an Inbox item')
        ;

            insert into queries
            values ('RecordElementDispositionChange', 'insert into element_signature_change(
  element_signature_id, when_sig_changed,
  who_changed_sig, why_sig_changed,
  old_disposition, new_disposition,
  old_name_chain, new_name_chain
) values (
  ?, now(),
  ?, ?,
  ?, ?,
  ?, ?
)
', ARRAY['element_signature_id', 'who_changed_sig', 'why_sig_changed', 'old_disposition', 'new_disposition', 'old_name_chain', 'new_name_chain'], 
                    '{}', ARRAY['NotInteractive', 'Update', 'ElementDisposition'], 'posda_phi', 'Record a change to Element Disposition
For use in scripts
Not really intended for interactive use
')
        ;

            insert into queries
            values ('FindingImageProblemWithSeries', 'select
  distinct dicom_file_type, project_name,  
  patient_id, series_instance_uid, min(import_time), max(import_time), count(distinct file_id) 
from
  ctp_file natural join dicom_file natural join file_series natural join
  file_patient natural join file_import natural join 
  import_event 
where file_id in (
  select file_id 
  from (
    select file_id, image_id 
    from pixel_location left join image using(unique_pixel_data_id)
    where file_id in (
      select
         distinct file_id from file_import natural join import_event natural join dicom_file
      where import_time > ''2018-09-17''
    )
  ) as foo where image_id is null
) and visibility is null
 group by dicom_file_type, project_name, patient_id, series_instance_uid
order by patient_id', '{}', 
                    ARRAY['dicom_file_type', 'project_name', 'patient_id', 'series_instance_uid', 'min', 'max', 'count'], ARRAY['Exceptional-Responders_NCI_Oct2018_curation'], 'posda_files', 'Find files which have unique_pixel_data_id but no image_id, then find out where the hell they came from')
        ;

            insert into queries
            values ('MarkPrivateTags', 'update element_seen set
  is_private = true
where
  is_private is null and 
  element_sig_pattern like ''%"%''
', '{}', 
                    ARRAY['id', 'element_sig_pattern', 'vr', 'tag_name', 'disp'], ARRAY['tag_usage', 'simple_phi', 'simple_phi_maint', 'phi_maint'], 'posda_phi_simple', 'Private tags with no disposition with values in phi_simple')
        ;

            insert into queries
            values ('PatientsByTp', 'select distinct
    patient_id,
	series_instance_uid

from
    activity_timepoint_file
    natural join file_patient
	natural join file_series
where
    activity_timepoint_id = ?
', ARRAY['activity_timepoint_id'], 
                    ARRAY['patient_id', 'series_instance_uid'], ARRAY['activity_timepoint_support'], 'posda_queries', 'Get a list of patients, and their series in a timepoint')
        ;

            insert into queries
            values ('GetPatientMappingByPatientId', 'select
  from_patient_id,
  to_patient_id,
  to_patient_name,
  collection_name,
  site_name,
  batch_number,
  uid_root,
  diagnosis_date,
  baseline_date,
  date_shift,
  baseline_date - diagnosis_date + interval ''1 day'' as computed_shift
from
  patient_mapping
where
  to_patient_id = ?
  ', ARRAY['patient_id'], 
                    ARRAY['from_patient_id', 'to_patient_id', 'to_patient_name', 'collection_name', 'site_name', 'batch_number', 'uid_root', 'diagnosis_date', 'baseline_date', 'date_shift', 'computed_shift'], ARRAY['adding_ctp', 'for_scripting', 'patient_mapping'], 'posda_files', 'Retrieve entries from patient_mapping table')
        ;

            insert into queries
            values ('SeeIfDigestIsAlreadyKnownDistinguished', 'select count(*) from distinguished_pixel_digests where pixel_digest = ?', ARRAY['pixel_digest'], 
                    ARRAY['count'], ARRAY['meta', 'test', 'hello'], 'posda_files', 'Find Duplicated Pixel Digest')
        ;

            insert into queries
            values ('LockWarnings', 'lock table dciodvfy_warning', '{}', 
                    '{}', ARRAY['NotInteractive', 'used_in_dciodvfy'], 'posda_phi_simple', 'Create a dciodvfy_scan_instance row')
        ;

            insert into queries
            values ('CreateEquivalenceInputClass', 'insert into image_equivalence_class_input_image(
  image_equivalence_class_id,  file_id
) values (
  ?, ?
)
', ARRAY['image_equivlence_class_id', 'file_id'], 
                    '{}', ARRAY['consistency', 'equivalence_classes', 'NotInteractive'], 'posda_files', 'For building series equivalence classes')
        ;

            insert into queries
            values ('SeriesWithDupSopsByCollectionSiteNew', 'select
  distinct collection, site, subj_id, series_instance_uid, 
  count(distinct sop_instance_uid) as num_sops,
  count(distinct file_id) as num_files
from (
  select
    distinct project_name as collection,
    site_name as site, patient_id as subj_id,
    study_instance_uid, series_instance_uid,
    sop_instance_uid,
    file_id
  from
    ctp_file natural join file_sop_common
    natural join file_patient natural join file_study natural join file_series
  where
    sop_instance_uid in (
      select distinct sop_instance_uid from (
        select distinct sop_instance_uid, count(distinct file_id) from (
          select distinct file_id, sop_instance_uid 
          from
            ctp_file natural join file_sop_common
            natural join file_patient
          where
            visibility is null and project_name = ? and site_name = ?
        ) as foo group by sop_instance_uid order by count desc
      ) as foo 
      where count > 1
    )
    and visibility is null
  ) as foo
group by collection, site, subj_id,  series_instance_uid

', ARRAY['collection', 'site'], 
                    ARRAY['collection', 'site', 'subj_id', 'series_instance_uid', 'num_sops', 'num_files'], ARRAY['ACRIN-FMISO-Brain Duplicate Elimination', 'dup_sops'], 'posda_files', 'Return a count of duplicate SOP Instance UIDs
')
        ;

            insert into queries
            values ('AddHocQueryForHeadNeckPETCT', 'select
  distinct patient_id, study_instance_uid as study_uid, series_instance_uid as series_uid,
  count(distinct file_id) as num_files
from
  file_patient natural join file_study natural join file_series natural join ctp_file
where
  patient_id in
   (''HN-CHUM-050'', ''HN-CHUM-052'', ''HN-CHUM-054'', ''HN-CHUM-056'', ''HN-CHUM-030'', ''HN-CHUM-034'')
  and visibility is null
group by patient_id, study_uid, series_uid', '{}', 
                    ARRAY['patient_id', 'study_uid', 'series_uid', 'num_files'], ARRAY['meta', 'test', 'hello', 'bills_test'], 'posda_files', 'Add a filter to a tab')
        ;

            insert into queries
            values ('GetDciodvfyScanInstanceId', 'select currval(''dciodvfy_scan_instance_dciodvfy_scan_instance_id_seq'') as id', '{}', 
                    ARRAY['id'], ARRAY['NotInteractive', 'used_in_dciodvfy'], 'posda_phi_simple', 'Create a dciodvfy_scan_instance row')
        ;

            insert into queries
            values ('GetSimpleValueSeen', 'select
  value_seen_id as id
from 
  value_seen
where
  value = ?', ARRAY['value'], 
                    ARRAY['id'], ARRAY['used_in_simple_phi', 'NotInteractive', 'non_dicom_phi'], 'posda_phi_simple', 'Get value seen if exists')
        ;

            insert into queries
            values ('SeriesEquivalenceClassNoByProcessingStatus', 'select 
  distinct series_instance_uid, equivalence_class_number, count(*) 
from 
  image_equivalence_class natural join image_equivalence_class_input_image
where
  processing_status = ?
group by series_instance_uid, equivalence_class_number
order by series_instance_uid, equivalence_class_number', ARRAY['processing_status'], 
                    ARRAY['series_instance_uid', 'equivalence_class_number', 'count'], ARRAY['find_series', 'equivalence_classes', 'consistency'], 'posda_files', 'Find Series with more than n equivalence class')
        ;

            insert into queries
            values ('CountsByCollectionDateRangePlus', 'select
  distinct
    patient_id, image_type, dicom_file_type, modality,
    study_date, series_date,
    study_description,
    series_description, study_instance_uid, series_instance_uid,
    manufacturer, manuf_model_name, software_versions,
    count(distinct sop_instance_uid) as num_sops,
    count(distinct file_id) as num_files,
    min(import_time) as earliest,
    max(import_time) as latest
from
  ctp_file join file_patient using(file_id)
  join dicom_file using(file_id)
  join file_series using(file_id)
  join file_sop_common using(file_id)
  join file_study using(file_id)
  join file_equipment using(file_id)
  join file_import using(file_id)
  join import_event using(import_event_id)
  left join file_image using(file_id)
  left join image using (image_id)
where
  file_id in (
    select file_id 
    from file_import natural join import_event
    where import_time > ? and import_time < ?
  ) and project_name = ? and visibility is null
group by
  patient_id, image_type, dicom_file_type, modality, study_date, 
  series_date, study_description,
  series_description, study_instance_uid, series_instance_uid,
  manufacturer, manuf_model_name, software_versions
order by
  patient_id, study_instance_uid, series_instance_uid, image_type,
  modality, study_date, series_date, study_description,
  series_description,
  manufacturer, manuf_model_name, software_versions
', ARRAY['from', 'to', 'collection'], 
                    ARRAY['patient_id', 'image_type', 'dicom_file_type', 'modality', 'study_date', 'series_date', 'study_description', 'series_description', 'study_instance_uid', 'series_instance_uid', 'manufacturer', 'manuf_model_name', 'software_versions', 'num_sops', 'num_files', 'earliest', 'latest'], ARRAY['counts', 'count_queries'], 'posda_files', 'Counts query by Collection, Site
')
        ;

            insert into queries
            values ('GetFilesWithNoSeriesInfoByCollection', 'select
  file_id,
  root_path || ''/'' || rel_path as path
from
  file_storage_root natural join file_location
where file_id in (
select 
  distinct file_id
from 
 ctp_file c
where
  project_name = ? and 
  visibility is null and 
  not exists (
    select
      file_id 
    from
      file_series s 
    where
      s.file_id = c.file_id
  )
)', ARRAY['collection'], 
                    ARRAY['file_id', 'path'], ARRAY['reimport_queries', 'dicom_file_type'], 'posda_files', 'Get file path from id')
        ;

            insert into queries
            values ('SeriesFileByCollectionWithNoEquivalenceClass', 'select distinct
  series_instance_uid
from
  file_series s
where 
  file_id in (
    select distinct file_id
    from ctp_file
    where project_name = ? and visibility is null
  )
  and not exists (
    select 
      series_instance_uid
   from
      image_equivalence_class e
   where
      e.series_instance_uid = s.series_instance_uid
 )', ARRAY['collection'], 
                    ARRAY['series_instance_uid'], ARRAY['equivalence_classes'], 'posda_files', 'Construct list of series in a collection where no image_equivalence_class exists')
        ;

            insert into queries
            values ('CreateScanEvent', 'insert into scan_event(
  scan_started, scan_status, scan_description,
  num_series_to_scan, num_series_scanned
) values (
  now(), ''In Process'', ?,
  ?, 0
)

', ARRAY['description', 'num_series_to_scan'], 
                    '{}', ARRAY['UsedInPhiSeriesScan', 'NotInteractive'], 'posda_phi', 'Create Scan Element')
        ;

            insert into queries
            values ('GetScanInstanceById', 'select
  phi_scan_instance_id,
  start_time,
  end_time,
  description,
  num_series,
  num_series_scanned,
  file_query
from 
  phi_scan_instance
where phi_scan_instance_id = ?', ARRAY['phi_scan_instance_id'], 
                    ARRAY['phi_scan_instance_id', 'start_time', 'end_time', 'description', 'num_series', 'num_series_scanned', 'file_query'], ARRAY['adding_ctp', 'for_scripting', 'scan_status'], 'posda_phi_simple', 'Get a query_scan_instance by instance_id')
        ;

            insert into queries
            values ('GetBasicImageGeometry', 'select
  iop, ipp
from
  file_series
  join file_image using (file_id)
  join image_geometry using (image_id)
where 
  series_instance_uid = ?', ARRAY['series_instance_uid'], 
                    ARRAY['iop', 'ipp'], ARRAY['NotInteractive', 'used_in_import_edited_files', 'used_in_check_circular_view'], 'posda_files', 'Get file_id, and current visibility by digest
For use in scripts
Not really intended for interactive use
')
        ;

            insert into queries
            values ('IntakeSeriesByCollectionSite', 'select
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
', ARRAY['collection', 'site'], 
                    ARRAY['PID', 'Modality', 'StudyDate', 'StudyDescription', 'SeriesDescription', 'SeriesNumber', 'StudyInstanceUID', 'SeriesInstanceUID', 'Mfr', 'Model', 'software_versions'], ARRAY['intake'], 'intake', 'List of all Series By Collection, Site on Intake
')
        ;

            insert into queries
            values ('IntakePatientStudySeriesHierarchyByCollectionSite', 'select
  p.patient_id as patient_id,
  t.study_instance_uid as study_instance_uid,
  s.series_instance_uid as series_instance_uid
from
  general_series s,
  study t,
  patient p,
  trial_data_provenance tdp
where
  s.study_pk_id = t.study_pk_id and
  t.patient_pk_id = p.patient_pk_id and
  p.trial_dp_pk_id = tdp.trial_dp_pk_id and
  tdp.project = ? and
  tdp.dp_site_name = ?
', ARRAY['collection', 'site'], 
                    ARRAY['patient_id', 'study_instance_uid', 'series_instance_uid'], ARRAY['intake', 'Hierarchy'], 'intake', 'Patient, study, series hierarchy by Collection, Site on Intake
')
        ;

            insert into queries
            values ('PatientStudySeriesHierarchyByCollection', 'select distinct
  patient_id,
  study_instance_uid,
  series_instance_uid
from
  file_study natural join ctp_file natural join file_series natural join file_patient
where 
  file_id in (
    select distinct file_id
    from ctp_file
    where project_name = ? and visibility is null
  )
order by patient_id, study_instance_uid, series_instance_uid', ARRAY['collection'], 
                    ARRAY['patient_id', 'study_instance_uid', 'series_instance_uid'], ARRAY['Hierarchy'], 'posda_files', 'Construct list of files in a collection in a Patient, Study, Series Hierarchy')
        ;

            insert into queries
            values ('VisibilityChangeEventsByCollectionWithModality', 'select 
  distinct project_name as collection,
  site_name as site,
  modality,
  date_trunc(''day'', time_of_change) as when_done,
  user_name, prior_visibility, new_visibility, reason_for, count(distinct file_id) as num_files
from
   ctp_file natural join file_patient natural join file_series natural join file_visibility_change 
where project_name = ?
group by
 collection, site, modality, when_done, user_name, prior_visibility, new_visibility, reason_for
order by when_done desc', ARRAY['collection'], 
                    ARRAY['collection', 'site', 'modality', 'when_done', 'user_name', 'prior_visibility', 'new_visibility', 'reason_for', 'num_files'], ARRAY['meta', 'test', 'hello', 'bills_test', 'hide_events'], 'posda_files', 'Add a filter to a tab')
        ;

            insert into queries
            values ('ImageFrameOfReferenceBySeriesPublic', 'select
  distinct frame_of_reference_uid as for_uid,
  count(distinct sop_instance_uid) as num_files
from
  general_image i, general_series s
where
  s.general_series_pk_id = i.general_series_pk_id and s.series_instance_uid = ?
group by frame_of_reference_uid;', ARRAY['series_instance_uid'], 
                    ARRAY['for_uid', 'num_files'], ARRAY['Structure Sets', 'sops', 'LinkageChecks', 'struct_linkages'], 'public', 'Get list of plan which reference unknown SOPs

')
        ;

            insert into queries
            values ('MakeBacklogReadyForProcessing', 'update control_status
  set status = ''waiting to go inservice''
', '{}', 
                    '{}', ARRAY['NotInteractive', 'Backlog', 'Backlog Monitor'], 'posda_backlog', 'Mark Backlog as ready for Processor')
        ;

            insert into queries
            values ('GetStudyByFileId', 'select file_id from file_study where file_id = ?', ARRAY['file_id'], 
                    ARRAY['file_id'], ARRAY['bills_test', 'posda_db_populate'], 'posda_files', 'Add a filter to a tab')
        ;

            insert into queries
            values ('SummaryOfFromFiles', 'select
  distinct project_name as collection,
  site_name as site,
  patient_id,
  study_date,
  study_instance_uid,
  series_instance_uid,
  dicom_file_type,
  modality,
  visibility,
  count(distinct sop_instance_uid) as num_sops,
  count(distinct file_id) as num_files
from
  ctp_file natural join
  file_patient natural join
  file_sop_common natural join
  file_study natural join
  file_series natural join
  dicom_file
where file_id in (
  select
    file_id 
  from
    file f, dicom_edit_compare dec 
  where
    f.digest = dec.from_file_digest and dec.subprocess_invocation_id = ?
  )
group by collection, site, patient_id, study_date, study_instance_uid, series_instance_uid, 
  dicom_file_type, modality, visibility
order by collection, site, patient_id, study_date, study_instance_uid, modality', ARRAY['subprocess_invocation_id'], 
                    ARRAY['collection', 'site', 'patient_id', 'study_date', 'study_instance_uid', 'series_instance_uid', 'dicom_file_type', 'modality', 'visibility', 'num_sops', 'num_files'], ARRAY['adding_ctp', 'for_scripting'], 'posda_files', 'Get a list of to files from the dicom_edit_compare table for a particular edit instance, with file_id and visibility

NB: Normally there should be no file_id (i.e. file has not been imported)')
        ;

            insert into queries
            values ('StartTransactionPosda', 'begin
', '{}', 
                    '{}', ARRAY['NotInteractive', 'Backlog', 'Transaction', 'used_in_file_import_into_posda'], 'posda_files', 'Start a transaction in Posda files')
        ;

            insert into queries
            values ('RawFilesFromDate', 'select 
  file_type, max(file_id) as max_file_id, min(file_id) as min_file_id, 
  count(*) as num_files, max(size) as largest, min(size) as smallest,
  sum(size) as total_size, avg(size) as avg_size
from file
where file_id in (
  select
    file_id from (
      select
        distinct file_id, date_trunc(?, min(import_time)) as load_week
      from
        file_import natural join import_event
      group by file_id
  ) as foo
  where
    load_week >=? and load_week <  (now() + interval ''24:00:00'')
) 
group by file_type', ARRAY['date_type', 'from'], 
                    ARRAY['file_type', 'max_file_id', 'min_file_id', 'num_files', 'largest', 'smallest', 'total_size', 'avg_size'], ARRAY['downloads_by_date'], 'posda_files', 'Counts query by Collection, Site
')
        ;

            insert into queries
            values ('AllProcessedManifestsByCollectionLikeWithDate', 'select
  distinct file_id, import_time as date, cm_collection, cm_site,  sum(cm_num_files) as total_files
from
  ctp_manifest_row natural join file_import natural join import_event
where
  cm_collection like ?
group by file_id, date, cm_collection, cm_site', ARRAY['collection_like'], 
                    ARRAY['file_id', 'date', 'cm_collection', 'cm_site', 'total_files'], ARRAY['activity_timepoint_support', 'manifests'], 'posda_files', 'Create An Activity Timepoint

')
        ;

            insert into queries
            values ('GetInputFormatForAllCommands', 'select
  operation_name, input_line_format, command_line
from
  spreadsheet_operation
where input_line_format is not null and operation_type = ''background_process''
  and can_chain', '{}', 
                    ARRAY['operation_name', 'input_line_format', 'command_line'], ARRAY['spreadsheet_operations'], 'posda_files', 'Get List of visible patients with CTP data')
        ;

            insert into queries
            values ('GetCollectionCodes', 'select
 collection_name, collection_code
from
  collection_codes
  ', '{}', 
                    ARRAY['collection_name', 'collection_code'], ARRAY['adding_ctp', 'for_scripting'], 'posda_files', 'Retrieve entries from patient_mapping table')
        ;

            insert into queries
            values ('GetVisibleFilesBySeriesAndVisualReviewId', 'select
  file_id
from ctp_file
where visibility is null and file_id in (
  select
    file_id
  from
    image_equivalence_class natural join image_equivalence_class_input_image
  where
    visual_review_instance_id = ? and series_instance_uid = ?
)', ARRAY['visual_review_instance_id', 'series_instance_uid'], 
                    ARRAY['file_id'], ARRAY['signature', 'phi_review', 'visual_review', 'visual_review_new_workflow'], 'posda_files', 'Get a list of files which are hidden by series id and visual review id')
        ;

            insert into queries
            values ('AreVisibleFilesMarkedAsBadOrUnreviewedInSeries', 'select 
  collection,
  site,
  patient_id,
  series_instance_uid,
  dicom_file_type,
  modality,
  review_status,
  processing_status,
  count(distinct file_id) as num_files
from (
  select 
    distinct project_name as collection,
    site_name as site,
    patient_id,
    series_instance_uid,
    dicom_file_type,
    modality,
    review_status,
    processing_status,
    visibility,
    file_id
  from 
    dicom_file natural join 
    file_series natural join 
    file_patient natural join
    ctp_file natural join 
  (
    select file_id, review_status, processing_status
    from
      image_equivalence_class_input_image natural join
      image_equivalence_class join
      ctp_file using(file_id)
    where
      series_instance_uid = ?
  ) as foo
) as foo
where
  visibility is null and 
  review_status != ''Good'' and
  review_status != ''PassThrough''
group by
  collection,
  site,
  patient_id,
  series_instance_uid,
  dicom_file_type,
  modality,
  review_status,
  processing_status
', ARRAY['series_instance_uid'], 
                    ARRAY['collection', 'site', 'patient_id', 'series_instance_uid', 'dicom_file_type', 'modality', 'review_status', 'processing_status', 'visibility', 'file_id'], ARRAY['find_series', 'equivalence_classes', 'consistency', 'visual_review_results', 'hide_events'], 'posda_files', 'Get visual review status report by series for Collection, Site')
        ;

            insert into queries
            values ('GetPublicSopsForCompare', 'select
  i.patient_id,
  i.study_instance_uid,
  s.series_instance_uid,
  sop_instance_uid,
  sop_class_uid,
  s.modality,
  i.dicom_file_uri
from
  general_image i,
  trial_data_provenance tdp,
  general_series s
where  
  i.trial_dp_pk_id = tdp.trial_dp_pk_id 
  and tdp.project = ?
  and i.general_series_pk_id = s.general_series_pk_id', ARRAY['collection'], 
                    ARRAY['patient_id', 'study_instance_uid', 'series_instance_uid', 'sop_instance_uid', 'sop_class_uid', 'modality', 'dicom_file_uri'], ARRAY['public_posda_counts'], 'public', 'Generate a long list of all unhidden SOPs for a collection in public<br>
<em>This can generate a long list</em>')
        ;

            insert into queries
            values ('LockFilePosda', 'select 1', '{}', 
                    '{}', ARRAY['NotInteractive', 'Backlog', 'Transaction', 'used_in_file_import_into_posda'], 'posda_files', 'Lock the file table in posda_files')
        ;

            insert into queries
            values ('AllPixelInfoByModality', 'select
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
', ARRAY['bits_allocated'], 
                    ARRAY['file_id', 'file', 'file_offset', 'size', 'bits_stored', 'bits_allocated', 'pixel_representation', 'number_of_frames', 'samples_per_pixel', 'pixel_rows', 'pixel_columns', 'photometric_interpretation', 'modality'], '{}', 'posda_files', 'Get pixel descriptors for all files
')
        ;

            insert into queries
            values ('GetActivityInfo', 'select
  activity_id, brief_description, when_created, who_created, when_closed
from 
  activity
where
  activity_id = ?

', ARRAY['activity_id'], 
                    ARRAY['activity_id', 'brief_description', 'when_created', 'who_created', 'when_closed'], ARRAY['AllCollections', 'queries', 'activity_support'], 'posda_queries', 'Get a list of available queries')
        ;

            insert into queries
            values ('InsertNewRootPath', 'insert into file_storage_root  (root_path, current, storage_class) values ( ? , true, ''imported from File List Importer'') returning file_storage_root_id ', ARRAY['root_path'], 
                    ARRAY['file_storage_root_id'], ARRAY['Universal'], 'posda_files', 'Checks for the local environment''s ID for a certain root path. Used by python_import_csv_filelist.py to insert file info into local development environments for files physically stored and referenced in internal posda production. 

(import list will have the root path for a file in prod, this will find the local id for that path)')
        ;

            insert into queries
            values ('GetSopOfPlanReferenceByDose', 'select
  distinct rt_dose_referenced_plan_uid as sop_instance_uid,
  rt_dose_referenced_plan_class as sop_class_uid
from
  rt_dose natural join file_dose
where
  file_id = ?', ARRAY['file_id'], 
                    ARRAY['sop_instance_uid', 'sop_class_uid'], ARRAY['LinkageChecks', 'used_in_dose_linkage_check'], 'posda_files', 'Get Plan Reference Info for RTDOSE by file_id
')
        ;

            insert into queries
            values ('AgesAndStudyDates', 'select
  distinct patient_id, study_date, patient_age, count(distinct series_instance_uid) as num_series
from
  file_patient natural join file_series natural join file_study natural join ctp_file
where
  project_name = ? and visibility is null
group by
  patient_id, study_date, patient_age order by patient_id', ARRAY['collection'], 
                    ARRAY['patient_id', 'study_date', 'patient_age', 'num_series'], ARRAY['meta', 'test', 'hello', 'query_tabs', 'bills_test'], 'posda_files', 'Add a filter to a tab')
        ;

            insert into queries
            values ('HowManyFilesToCopyInCopyFromPublic', 'select
  count(*) as num_to_copy
from file_copy_from_public
where
  copy_from_public_id = ? and
  inserted_file_id is null', ARRAY['copy_from_public_id'], 
                    ARRAY['num_to_copy'], ARRAY['bills_test', 'copy_from_public'], 'posda_files', 'Add a filter to a tab')
        ;

            insert into queries
            values ('SubjectCountsDateRangeSummaryByCollectionSiteSubject', 'select 
  distinct patient_id,
  study_instance_uid,
  series_instance_uid,
  study_date, 
  min(import_time) as from,
  max(import_time) as to,
  count(distinct file_id) as num_files,
  count(distinct sop_instance_uid) as num_sops
from 
  ctp_file natural join 
  file_sop_common natural join
  file_study natural join
  file_series natural join
  file_patient natural join 
  file_import natural join 
  import_event
where
  project_name = ? and site_name = ? and visibility is null and patient_id = ?
group by patient_id, study_instance_uid, series_instance_uid, study_date
order by patient_id, study_date', ARRAY['collection', 'site', 'patient_id'], 
                    ARRAY['patient_id', 'study_instance_uid', 'series_instance_uid', 'study_date', 'from', 'to', 'num_files', 'num_sops'], ARRAY['counts', 'for_bill_counts'], 'posda_files', 'Counts query by Collection, Site
')
        ;

            insert into queries
            values ('GetNumPixDups', 'select distinct num_pix_dups, count(*) as num_pix_digs
from (
select
  distinct pixel_digest, count(*) as num_pix_dups
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
      image join file_image using(image_id)
      join ctp_file using(file_id)
      join file_patient fq using(file_id)
      join unique_pixel_data using(unique_pixel_data_id)
    where visibility is null
  ) as foo 
  group by 
    unique_pixel_data_id, project_name, pixel_digest,
    site_name, patient_id
) as foo 
group by pixel_digest) as foo
group by num_pix_dups
order by num_pix_digs desc', '{}', 
                    ARRAY['num_pix_dups', 'num_pix_digs'], ARRAY['pix_data_dups', 'pixel_duplicates'], 'posda_files', 'Find series with duplicate pixel count of <n>
')
        ;

            insert into queries
            values ('SimplePhiReportSelectedVR', 'select 
  distinct element_sig_pattern as element, vr, value, count(*) as num_series
from element_value_occurance natural join element_seen natural join value_seen
where 
  phi_scan_instance_id = ? and
  vr in (''SH'', ''OB'', ''PN'', ''DA'', ''ST'', ''AS'', ''DT'', ''LO'', ''UI'', ''CS'', ''AE'', ''LT'', ''ST'', ''UC'', ''UN'', ''UR'', ''UT'')
group by element_sig_pattern, vr, value;', ARRAY['scan_id'], 
                    ARRAY['element', 'vr', 'value', 'num_series'], ARRAY['tag_usage', 'simple_phi'], 'posda_phi_simple', 'Status of PHI scans
')
        ;

            insert into queries
            values ('SendEventsByReason', 'select
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
', ARRAY['reason'], 
                    ARRAY['send_started', 'duration', 'destination_host', 'destination_port', 'to_send', 'files_sent', 'invoking_user', 'reason_for_send'], ARRAY['send_to_intake'], 'posda_files', 'List of Send Events By Reason
')
        ;

            insert into queries
            values ('DuplicateDownloadsByCollection', 'select distinct patient_id, series_instance_uid, count(*)
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
', ARRAY['project_name', 'site_name'], 
                    ARRAY['series_instance_uid', 'count'], ARRAY['by_collection', 'duplicates', 'find_series'], 'posda_files', 'Number of files for a subject which have been downloaded more than once
')
        ;

            insert into queries
            values ('SimplePhiReportAllPrivateOnly', 'select 
  distinct ''<'' || element_sig_pattern || ''>''  as element, length(value) as val_length,
  vr, value, tag_name as description, private_disposition as disp, count(*) as num_series
from element_value_occurance natural join element_seen natural join value_seen
where 
  phi_scan_instance_id = ? and is_private
group by element_sig_pattern, vr, value, val_length, description, disp
order by vr, element, val_length', ARRAY['scan_id'], 
                    ARRAY['element', 'vr', 'disp', 'value', 'description', 'num_series'], ARRAY['tag_usage', 'simple_phi'], 'posda_phi_simple', 'Status of PHI scans
')
        ;

            insert into queries
            values ('GetNonDicomFilesByPatientId', 'select 
  file_id, non_dicom_file.file_type, file_sub_type, 
  collection, site, subject, visibility, date_last_categorized,
  size, digest, root_path || ''/'' || rel_path as path
from
  non_dicom_file join file using (file_id) natural join file_location natural join file_storage_root
where
  visibility is null
  and subject = ?
', ARRAY['patient_id'], 
                    ARRAY['file_id', 'file_type', 'file_sub_type', 'collection', 'site', 'subject', 'visibility', 'date_last_categorized', 'size', 'digest', 'path'], ARRAY['radcomp'], 'posda_files', 'Add a filter to a tab')
        ;

            insert into queries
            values ('AddHocQuery3', 'select distinct series_instance_uid, body_part_examined, count(distinct file_id) as num_files from file_series where file_id in (
select distinct file_id from import_event natural join file_import natural left join ctp_file where import_event_id in (9535631, 9543872, 9535664) and visibility is null) group by series_instance_uid, body_part_examined
', '{}', 
                    ARRAY['series_instance_uid', 'body_part_examined', 'num_files'], ARRAY['meta', 'test', 'hello', 'bills_test', 'bills_ad_hoc_scripts'], 'posda_files', 'Add a filter to a tab')
        ;

            insert into queries
            values ('SopNickname', 'select
  project_name, site_name, subj_id, sop_nickname, modality,
  has_modality_conflict
from
  sop_nickname
where
  sop_instance_uid = ?
', ARRAY['sop_instance_uid'], 
                    ARRAY['project_name', 'site_name', 'subj_id', 'sop_nickname', 'modality', 'has_modality_conflict'], '{}', 'posda_nicknames', 'Get a nickname, etc for a particular SOP Instance  uid
')
        ;

            insert into queries
            values ('StudyHierarchyByStudyUIDWithAcessionNoAndNumFiles', 'select distinct
  study_instance_uid, study_description,
  series_instance_uid, series_description,
  modality,
  ''<'' || accession_number || ''>'' as accession_number,
  count(distinct sop_instance_uid) as num_files
from
  file_study natural join ctp_file natural join file_series natural join file_sop_common
where study_instance_uid = ? and visibility is null
group by
  study_instance_uid, study_description,
  series_instance_uid, series_description, modality,accession_number
order by accession_number', ARRAY['study_instance_uid'], 
                    ARRAY['study_instance_uid', 'study_description', 'series_instance_uid', 'series_description', 'modality', 'accession_number', 'num_files'], ARRAY['by_study', 'Hierarchy'], 'posda_files', 'Show List of Study Descriptions, Series UID, Series Descriptions, and Count of SOPS for a given Study Instance UID')
        ;

            insert into queries
            values ('ReportOnStudiesWithSomeMissingStudyDates', 'select
  distinct patient_id, study_instance_uid, study_date, study_description, series_instance_uid,series_date,
  series_description, dicom_file_type, modality, count(distinct file_id) as num_files
from
  file_patient natural join file_study natural join file_series natural join dicom_file
where file_id in (
 select file_id from file_study natural join activity_timepoint_file 
 where activity_timepoint_id = ? and study_instance_uid in (
    select distinct study_instance_uid from (
      select distinct study_date, study_instance_uid
      from ctp_file natural join file_series natural join file_study natural join activity_timepoint_file
      where activity_timepoint_id = ? and visibility is null
    ) as foo 
    where study_date is null
  )
)
group by
  patient_id, study_instance_uid, study_date, study_description, series_instance_uid, series_date,
  series_description, dicom_file_type, modality
order by patient_id, modality', ARRAY['activity_timepoint_id', 'activity_timepoint_id_1'], 
                    ARRAY['patient_id', 'study_instance_uid', 'study_date', 'study_description', 'series_instance_uid', 'series_date', 'series_description', 'dicom_file_type', 'modality', 'num_files'], ARRAY['Exceptional-Responders_NCI_Oct2018_curation', 'New_HNSCC_Investigation'], 'posda_files', 'Find files which have unique_pixel_data_id but no image_id, then find out where the hell they came from')
        ;

            insert into queries
            values ('GetPosdaFileCreationRoot', 'select file_storage_root_id, root_path from file_storage_root where current and storage_class = ''created''', '{}', 
                    ARRAY['file_storage_root_id', 'root_path'], ARRAY['NotInteractive', 'Backlog', 'used_in_file_import_into_posda'], 'posda_files', 'Get the file_storage root for newly created files')
        ;

            insert into queries
            values ('GetInboxItem', 'select
	current_status,
	statuts_note,
	date_entered,
	date_dismissed,
	file_id
from user_inbox_content
natural join background_subprocess_report
where user_inbox_content_id = ?

', ARRAY['user_inbox_content_id'], 
                    ARRAY['current_status', 'status_note', 'date_entered', 'date_dismissed', 'file_id'], '{}', 'posda_queries', 'Get the details of a single Inbox item.')
        ;

            insert into queries
            values ('DistinctVisibleSeriesByCollectionSite', 'select distinct series_instance_uid, dicom_file_type, modality, count(distinct file_id)
from
  file_series natural join dicom_file natural join ctp_file
where
  project_name = ? and site_name = ? and visibility is null
group by series_instance_uid, dicom_file_type, modality
', ARRAY['project_name', 'site_name'], 
                    ARRAY['series_instance_uid', 'dicom_file_type', 'modality', 'count'], ARRAY['by_collection', 'find_series', 'compare_collection_site', 'search_series', 'edit_files', 'simple_phi', 'dciodvfy', 'ctp_details', 'select_for_phi', 'visual_review_selection'], 'posda_files', 'Get Series in A Collection, site with dicom_file_type, modality, and sop_count
')
        ;

            insert into queries
            values ('FilesInSeriesForApplicationOfPrivateDisposition', 'select
  distinct root_path || ''/'' || rel_path as path, 
  sop_instance_uid, modality
from
  file_location natural join file_storage_root 
  natural join ctp_file natural join file_series
  natural join file_sop_common
where
  series_instance_uid = ? and visibility is null
', ARRAY['series_instance_uid'], 
                    ARRAY['path', 'sop_instance_uid', 'modality'], ARRAY['find_files', 'ApplyDisposition'], 'posda_files', 'Get path, sop_instance_uid, and modality for all files in a series
')
        ;

            insert into queries
            values ('GetMaxStudyDate', 'select
   max(study_date) as study_date
from 
  file_patient natural join ctp_file natural join file_study
where
  patient_id = ?', ARRAY['patient_id'], 
                    ARRAY['study_date'], ARRAY['adding_ctp', 'for_scripting', 'non_dicom_phi', 'non_dicom_edit'], 'posda_files', 'Simple Phi Report with Meta Quotes')
        ;

            insert into queries
            values ('FilesInSeriesForApplicationOfPrivateDispositionPublic', 'select
  i.dicom_file_uri as path, i.sop_instance_uid, s.modality
from
  general_image i, general_series s
where
  i.general_series_pk_id = s.general_series_pk_id and
  s.series_instance_uid = ?', ARRAY['series_instance_uid'], 
                    ARRAY['path', 'sop_instance_uid', 'modality'], ARRAY['find_files', 'ApplyDisposition', 'intake'], 'public', 'Get path, sop_instance_uid, and modality for all files in a series
')
        ;

            insert into queries
            values ('PatientByImportEventIdVisibleFiles', 'select
  distinct patient_id, count(distinct file_id) as num_files
from file_patient
where file_id in (
  select distinct file_id
  from file_import natural join import_event natural left join ctp_file
  where import_event_id = ? and visibility is null
) group by patient_id order by patient_id', ARRAY['import_event_id'], 
                    ARRAY['patient_id', 'num_files'], ARRAY['ACRIN-NSCLC-FDG-PET Curation'], 'posda_files', 'Get the list of files by sop, excluding base series')
        ;

            insert into queries
            values ('GetPublicCopyInfoBySop', 'select dicom_file_uri, tdp.project, dp_site_name as site_name, dp_site_id as site_id
from general_image i, trial_data_provenance tdp 
where tdp.trial_dp_pk_id = i.trial_dp_pk_id and sop_instance_uid = ?', ARRAY['sop_instance_uid'], 
                    ARRAY['dicom_file_uri', 'project', 'site_name', 'site_id'], ARRAY['bills_test', 'copy_from_public'], 'public', 'Add a filter to a tab')
        ;

            insert into queries
            values ('SeriesWithMoreThanNEquivalenceClasses', 'select series_instance_uid, count from (
select distinct series_instance_uid, count(*) from image_equivalence_class group by series_instance_uid) as foo where count > ?', ARRAY['count'], 
                    ARRAY['series_instance_uid', 'count'], ARRAY['find_series', 'equivalence_classes', 'consistency'], 'posda_files', 'Find Series with more than n equivalence class')
        ;

            insert into queries
            values ('WhereSopSitsPublic', 'select distinct
  tdp.project as collection,
  tdp.dp_site_name as site,
  p.patient_id,
  i.study_instance_uid,
  i.series_instance_uid
from
  general_image i,
  patient p,
  trial_data_provenance tdp
where
  sop_instance_uid = ?
  and i.patient_pk_id = p.patient_pk_id
  and i.trial_dp_pk_id = tdp.trial_dp_pk_id
', ARRAY['sop_instance_uid'], 
                    ARRAY['collection', 'site', 'patient_id', 'study_instance_uid', 'series_instance_uid'], ARRAY['posda_files', 'sops', 'BySopInstance'], 'public', 'Get Collection, Patient, Study Hierarchy in which SOP resides
')
        ;

            insert into queries
            values ('GetCTQPByLikeCollectionSite', 'select 
  collection, site, patient_id, qualified
from
  clinical_trial_qualified_patient_id
where collection like ? and site = ?', ARRAY['collection_like', 'site'], 
                    ARRAY['collection', 'site', 'patient_id', 'qualified'], ARRAY['clin_qual'], 'posda_files', 'Create An Activity Timepoint

')
        ;

            insert into queries
            values ('DuplicateSopsInSeriesExperimentalSub', 'select 
    distinct sop_instance_uid, min(file_id) as first_f, max(file_id) as last_f
  from
     file_series natural join file_sop_common natural join ctp_file
  where
     series_instance_uid = ? and visibility is null
  group by sop_instance_uid', ARRAY['series_instance_uid'], 
                    ARRAY['sop_instance_uid', 'first_f', 'last_f'], ARRAY['by_series', 'dup_sops', 'ACRIN-FMISO-Brain Duplicate Elimination'], 'posda_files', 'List of Actual duplicate SOPs (i.e. different files, same SOP)
in a series
')
        ;

            insert into queries
            values ('DifferentDupSopsReceivedBetweenDatesByCollection', 'select * from (
select
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
) as foo where num_sops != num_files
', ARRAY['start_time', 'end_time', 'collection'], 
                    ARRAY['project_name', 'site_name', 'patient_id', 'study_instance_uid', 'series_instance_uid', 'num_sops', 'num_files', 'num_uploads', 'first_loaded', 'last_loaded'], ARRAY['receive_reports'], 'posda_files', 'Series received between dates with duplicate sops
')
        ;

            insert into queries
            values ('SimplePhiReportAllRelevantPrivateOnly', 'select 
  distinct ''<'' || element_sig_pattern || ''>''  as element, length(value) as val_length,
  vr, value, tag_name as description, private_disposition as disp, count(*) as num_series
from element_value_occurance natural join element_seen natural join value_seen
where 
  phi_scan_instance_id = ? and is_private and private_disposition not in (''d'', ''na'')
group by element_sig_pattern, vr, value, val_length, description, disp
order by vr, element, val_length', ARRAY['scan_id'], 
                    ARRAY['element', 'vr', 'value', 'description', 'disp', 'num_series'], ARRAY['tag_usage', 'simple_phi'], 'posda_phi_simple', 'Status of PHI scans
')
        ;

            insert into queries
            values ('DuplicateDownloadsBySubject', 'select count(*) from (
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
', ARRAY['subject_id', 'project_name', 'site_name'], 
                    ARRAY['count'], ARRAY['by_subject', 'duplicates', 'find_series'], 'posda_files', 'Number of files for a subject which have been downloaded more than once
')
        ;

            insert into queries
            values ('FilesInStudyForEdit', 'select
  distinct root_path || ''/'' || rel_path as path, 
  sop_instance_uid, modality
from
  file_location natural join file_storage_root 
  natural join ctp_file natural join file_series
  natural join file_study
  natural join file_sop_common
where
  study_instance_uid = ? and visibility is null
', ARRAY['study_instance_uid'], 
                    ARRAY['path', 'sop_instance_uid', 'modality'], ARRAY['find_files', 'ApplyDisposition'], 'posda_files', 'Get path, sop_instance_uid, and modality for all files in a series
')
        ;

            insert into queries
            values ('GetPosdaSopsForCompareLikeCollectionEqualSite', 'select
  distinct patient_id,
  study_instance_uid, 
  series_instance_uid, 
  sop_instance_uid,
  sop_class_uid,
  modality,
  dicom_file_type,
  root_path || ''/'' || rel_path as file_path,
  file_id
from
  ctp_file
  natural join dicom_file
  natural join file_patient
  natural join file_study
  natural join file_series
  natural join file_sop_common
  natural join file_location
  natural join file_storage_root
where
  project_name like ? and site_name = ?
  and visibility is null', ARRAY['collection', 'site'], 
                    ARRAY['patient_id', 'study_instance_uid', 'series_instance_uid', 'sop_instance_uid', 'sop_class_uid', 'modality', 'dicom_file_type', 'file_path', 'file_id'], ARRAY['public_posda_counts'], 'posda_files', 'Generate a long list of all unhidden SOPs for a collection in posda<br>
<em>This can generate a long list</em>')
        ;

            insert into queries
            values ('GetAllQualifiedCTQPByLikeCollectionWithFileCountAndLoadTimesOnlySinceDate', 'select * from (select 
  collection, site, patient_id, qualified, count(distinct file_id) as num_files, count (distinct sop_instance_uid) as num_sops,
  min(date_trunc(''day'',import_time)) as earliest_day, max(date_trunc(''day'', import_time)) as latest_day
from
  clinical_trial_qualified_patient_id join file_patient using (patient_id) join file_import using(file_id)
  join file_sop_common using(file_id)
  join import_event using(import_event_id)
where collection like ?
group by collection, site, patient_id, qualified) as foo where earliest_day >= ? ', ARRAY['collection_like', 'from'], 
                    ARRAY['collection', 'site', 'patient_id', 'qualified', 'num_files', 'num_sops', 'earliest_day', 'latest_day'], ARRAY['clin_qual'], 'posda_files', 'Create An Activity Timepoint

')
        ;

            insert into queries
            values ('InsertVisibilityChange', 'insert into file_visibility_change(
  file_id, user_name, time_of_change,
  prior_visibility, new_visibility, reason_for
)values(
  ?, ?, now(),
  ?, ?, ?
)
', ARRAY['file_id', 'user_name', 'prior_visibility', 'new_visibility', 'reason'], 
                    '{}', ARRAY['ImageEdit', 'NotInteractive'], 'posda_files', 'Insert Image Visibility Change

')
        ;

            insert into queries
            values ('IsFileProcessed', 'select is_dicom_file is not null as processed
from file
where file_id = ?
', ARRAY['file_id'], 
                    ARRAY['processed'], '{}', 'posda_files', '
')
        ;

            insert into queries
            values ('CreateSimpleSeriesScanInstance', 'insert into series_scan_instance(
scan_instance_id, series_instance_uid, start_time
)values(?, ?, now())', ARRAY['scan_instance_id', 'series_instance_uid'], 
                    '{}', ARRAY['used_in_simple_phi', 'NotInteractive'], 'posda_phi_simple', 'Create a new Simple PHI scan')
        ;

            insert into queries
            values ('FileIdsVisibleInSeries', 'select
  distinct file_id
from
  file_series natural join file_sop_common natural join ctp_file
where
  series_instance_uid = ? and visibility is null
', ARRAY['series_instance_uid'], 
                    ARRAY['file_id'], ARRAY['by_series_instance_uid', 'file_ids', 'posda_files'], 'posda_files', 'Get Distinct Unhidden Files in Series
')
        ;

            insert into queries
            values ('DicomFileTypesNotProcessedAll', 'select 
  distinct dicom_file_type, count(distinct file_id)
from
  dicom_file d
where
  not exists (
    select file_id 
    from file_series s
    where s.file_id = d.file_id
  )
group by dicom_file_type', '{}', 
                    ARRAY['dicom_file_type', 'count'], ARRAY['dicom_file_type'], 'posda_files', 'List of Distinct Dicom File Types which have unprocessed DICOM files
')
        ;

            insert into queries
            values ('GetElemenSeenIdBySigVr', 'select element_seen_id
from element_seen
where element_sig_pattern = ? and vr = ?', ARRAY['element_sig_pattern', 'vr'], 
                    ARRAY['element_seen_id'], ARRAY['NotInteractive', 'ElementDisposition', 'phi_maint'], 'posda_phi_simple', 'Get List of Private Elements By Disposition')
        ;

            insert into queries
            values ('GetReferencedButUnknownSsSops', 'select
  sop_instance_uid, 
  ss_referenced_from_plan as ss_sop_instance_uid 
from 
  plan p natural join file_plan join file_sop_common using(file_id)
where
  not exists (
  select
    sop_instance_uid 
  from
    file_sop_common fsc
  where
    p.ss_referenced_from_plan  = fsc.sop_instance_uid
)', '{}', 
                    ARRAY['sop_instance_uid', 'ss_sop_instance_uid'], ARRAY['Structure Sets', 'sops', 'LinkageChecks'], 'posda_files', 'Get list of plan which reference unknown SOPs

')
        ;

            insert into queries
            values ('ShowQueryTabHierarchy', 'select 
  query_tab_name, filter_name, tag, count(distinct query_name) as num_queries
from(
  select 
     query_tab_name,
      filter_name,
      unnest(tags_enabled) as tag
  from
    query_tabs join query_tabs_query_tag_filter using(query_tab_name)
    natural join query_tag_filter
) as foo
natural join(
  select
     name as query_name,
     unnest(tags) as tag
from queries
) as fie
group by query_tab_name, filter_name, tag
order by 
  query_tab_name, filter_name, tag', '{}', 
                    ARRAY['query_tab_name', 'filter_name', 'tag', 'num_queries'], ARRAY['meta', 'test', 'hello', 'query_tabs', 'bills_test'], 'posda_queries', 'Add a filter to a tab')
        ;

            insert into queries
            values ('DistinctSeriesByImportEvent', 'select
  distinct project_name as collection, site_name as site, 
  patient_id, patient_name, study_instance_uid, series_instance_uid, 
  dicom_file_type, modality, count(distinct file_id)
from
  file_patient natural join file_study natural join file_series natural join dicom_file
  natural left join ctp_file
where
  file_id in (
    select distinct file_id from file_import where import_event_id = ?
  )
group by collection, site, patient_id, patient_name,
  study_instance_uid, series_instance_uid, dicom_file_type, modality', ARRAY['import_event_id'], 
                    ARRAY['collection', 'site', 'patient_id', 'patient_name', 'study_instance_uid', 'series_instance_uid', 'dicom_file_type', 'modality', 'count'], ARRAY['select_for_phi', 'visual_review_selection'], 'posda_files', 'Get Series in A Collection, site with dicom_file_type, modality, and sop_count
')
        ;

            insert into queries
            values ('DiskSpaceByCollection', 'select
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
', ARRAY['collection'], 
                    ARRAY['collection', 'total_bytes'], ARRAY['by_collection', 'posda_files', 'storage_used'], 'posda_files', 'Get disk space used by collection
')
        ;

            insert into queries
            values ('UpdateActivityTaskStatusAndCompletionTime', 'update activity_task_status set
  status_text = ?,
  expected_remaining_time = ?,
  last_updated = now(),
  dismissed_time = null,
  dismissed_by = null
where
  activity_id = ? and
  subprocess_invocation_id = ?', ARRAY['status_text', 'expected_completion_time', 'activity_id', 'subprocess_invocation_id'], 
                    '{}', ARRAY['NotInteractive', 'Update'], 'posda_files', 'Update status_text and expected_completion_time in activity_task_status
For use in scripts
Not really intended for interactive use
')
        ;

            insert into queries
            values ('TagsSeenSimplePrivateWithCountAndNullDisp', 'select 
  distinct element_sig_pattern,
  vr,
  private_disposition, tag_name,
  count(distinct value) as num_values
from
  element_seen natural left join
  element_value_occurance
  natural left join value_seen
where
  is_private and private_disposition is null
group by element_sig_pattern, vr, private_disposition, tag_name
order by element_sig_pattern;', '{}', 
                    ARRAY['element_sig_pattern', 'vr', 'private_disposition', 'tag_name', 'num_values'], ARRAY['by_collection', 'find_series', 'compare_collection_site', 'search_series', 'edit_files', 'phi_maint'], 'posda_phi_simple', 'Get all the data from tags_seen in posda_phi_simple database
')
        ;

            insert into queries
            values ('FindStudiesWithMatchingDescriptionByCollection', 'select distinct study_instance_uid from (
  select distinct study_instance_uid, count(*) from (
    select distinct
      study_instance_uid, study_date, study_time,
      referring_phy_name, study_id, accession_number,
      study_description, phys_of_record, phys_reading,
      admitting_diag
    from
      file_study natural join ctp_file
    where
      project_name = ? and visibility is null and study_description = ?
    group by
      study_instance_uid, study_date, study_time,
      referring_phy_name, study_id, accession_number,
      study_description, phys_of_record, phys_reading,
      admitting_diag
  ) as foo
  group by study_instance_uid
) as foo
where count > 1
', ARRAY['collection', 'description'], 
                    ARRAY['study_instance_uid'], ARRAY['by_study', 'consistency'], 'posda_files', 'Find Studies by Collection with Null Study Description
')
        ;

            insert into queries
            values ('SeriesVisualReviewResultsExtendedByCollectionSiteStatus', 'select 
  distinct 
  project_name as collection,
  site_name as site,
  patient_id,
  series_instance_uid,
  dicom_file_type,
  modality,
  review_status,
  equivalence_class_number,
  count(distinct file_id) as num_files
from 
  dicom_file natural join 
  file_series natural join
  file_patient natural join
  ctp_file join 
  image_equivalence_class using(series_instance_uid)
where
  project_name = ? and
  site_name = ? and review_status = ? and visibility is null
group by
  collection,
  site,
  patient_id,
  series_instance_uid,
  dicom_file_type,
  modality,
  review_status,
  equivalence_class_number
order by
  series_instance_uid', ARRAY['project_name', 'site_name', 'status'], 
                    ARRAY['collection', 'site', 'series_instance_uid', 'patient_id', 'dicom_file_type', 'modality', 'review_status', 'num_files', 'equivalence_class_number'], ARRAY['find_series', 'equivalence_classes', 'consistency', 'visual_review_results', 'hide_files'], 'posda_files', 'Get visual review status report by series for Collection, Site')
        ;

            insert into queries
            values ('SeriesEquivalenceClassResults', 'select
  distinct series_instance_uid,
  equivalence_class_number, 
  review_status,
  count(distinct file_id) as files_in_class
from
  image_equivalence_class
  natural join image_equivalence_class_input_image
where series_instance_uid in (
  select 
    distinct series_instance_uid
  from
    ctp_file
    natural join file_series 
    join image_equivalence_class using(series_instance_uid) 
  where project_name = ? and visibility is null and review_status = ?
) group by
   series_instance_uid,
   equivalence_class_number,
   review_status
order by series_instance_uid, equivalence_class_number', ARRAY['project_name', 'status'], 
                    ARRAY['series_instance_uid', 'equivalence_class_number', 'review_status', 'files_in_class'], ARRAY['find_series', 'equivalence_classes', 'consistency', 'visual_review_results', 'hide_files'], 'posda_files', 'Get visual review status report by series for Collection, Site')
        ;

            insert into queries
            values ('DuplicateSopsWithLastLoadDateByCollection', 'select
  distinct sop_instance_uid, file_id, max(import_time) latest
from file_location join file_import using(file_id) join import_event using (import_event_id)  
  join file_sop_common using(file_id) join ctp_file using (file_id)
where sop_instance_uid in (
  select distinct sop_instance_uid from (
    select distinct sop_instance_uid, count(distinct file_id)
    from file_sop_common natural join ctp_file
    where project_name = ? and visibility is null group by sop_instance_uid
    ) as foo
  where count > 1
  ) and visibility is null
group by sop_instance_uid, file_id', ARRAY['collection'], 
                    ARRAY['collection'], ARRAY['meta', 'test', 'hello', 'bills_test'], 'posda_files', 'List of duplicate sops with file_ids and latest load date<br><br>
<bold>Warning: may generate a lot of output</bold>')
        ;

            insert into queries
            values ('DistinctSeriesBySubject', 'select distinct series_instance_uid, modality, count(*)
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
', ARRAY['subject_id', 'project_name', 'site_name'], 
                    ARRAY['series_instance_uid', 'modality', 'count'], ARRAY['by_subject', 'find_series'], 'posda_files', 'Get Series in A Collection, Site, Subject
')
        ;

            insert into queries
            values ('DistinctVisibleFileReportByCollectionSite', 'select distinct
  project_name as collection, site_name as site, patient_id, study_instance_uid,
  series_instance_uid, sop_instance_uid, dicom_file_type, modality, file_id
from
  file_patient natural join file_study natural join file_series natural join file_sop_common
  natural join dicom_file natural join ctp_file
where
  project_name = ? and site_name = ? and visibility is null
order by series_instance_uid', ARRAY['project_name', 'site_name'], 
                    ARRAY['collection', 'site', 'patient_id', 'study_instance_uid', 'series_instance_uid', 'sop_instance_uid', 'dicom_file_type', 'modality', 'file_id'], ARRAY['by_collection', 'find_series', 'compare_collection_site', 'search_series', 'edit_files', 'simple_phi', 'dciodvfy', 'ctp_details', 'select_for_phi', 'visual_review_selection', 'activity_timepoints'], 'posda_files', 'Get Series in A Collection, site with dicom_file_type, modality, and sop_count
')
        ;

            insert into queries
            values ('CreateNonDicomPathValueOccurance', 'insert into non_dicom_path_value_occurrance(
  non_dicom_path_seen_id,
  value_seen_id,
  non_dicom_file_scan_id
) values (
  ?, ?, ?
)', ARRAY['non_dicom_path_seen_id', 'value_seen_id', 'non_dicom_file_scan_id'], 
                    '{}', ARRAY['NotInteractive', 'non_dicom_phi'], 'posda_phi_simple', 'Create a dciodvfy_scan_instance row')
        ;

            insert into queries
            values ('PatientByImportEventId', 'select
  distinct patient_id, visibility, count(distinct file_id) as num_files
from file_patient natural left join ctp_file
where file_id in (
  select distinct file_id
  from file_import natural join import_event 
  where import_event_id = ?
) group by patient_id, visibility order by patient_id, visibility', ARRAY['import_event_id'], 
                    ARRAY['patient_id', 'visibility', 'num_files'], ARRAY['ACRIN-NSCLC-FDG-PET Curation'], 'posda_files', 'Get the list of files by sop, excluding base series')
        ;

            insert into queries
            values ('StartTransaction', 'begin', '{}', 
                    '{}', ARRAY['NotInteractive', 'used_in_dciodvfy'], 'posda_phi_simple', 'Create a dciodvfy_scan_instance row')
        ;

            insert into queries
            values ('CreateEquipmentSignature', 'insert into equipment_signature(equipment_signature)values(?)
', ARRAY['equipment_signature'], 
                    '{}', ARRAY['UsedInPhiSeriesScan', 'NotInteractive'], 'posda_phi', 'Create New Equipment Signature Id')
        ;

            insert into queries
            values ('SimplePhiReportByScanVrPrivateOnly', 'select 
  distinct element_sig_pattern as element, vr, value, 
  tag_name as description, private_disposition as disposition,
  count(*) as num_series
from element_value_occurance natural join element_seen natural join value_seen
where 
  phi_scan_instance_id = ? and vr = ?
  and is_private
group by element_sig_pattern, vr, value, tag_name, private_disposition', ARRAY['scan_id', 'vr'], 
                    ARRAY['element', 'vr', 'value', 'description', 'disposition', 'num_series'], ARRAY['tag_usage', 'simple_phi'], 'posda_phi_simple', 'Status of PHI scans
')
        ;

            insert into queries
            values ('ListOfPrivateElementsValues', 'select
  distinct value
from
  scan_element natural join seen_value
where
  element_signature_id = ?
order by value
', ARRAY['element_signature_id'], 
                    ARRAY['value'], ARRAY['ElementDisposition'], 'posda_phi', 'Get List of Values for Private Element based on element_signature_id')
        ;

            insert into queries
            values ('GetRoiList', 'select 
   roi_id, roi_num ,roi_name
from 
  roi natural join structure_set natural join file_structure_set 
  join file_sop_common using(file_id)
where
  sop_instance_uid = ?
', ARRAY['sop_instance_uid'], 
                    ARRAY['roi_id', 'roi_num', 'roi_name'], ARRAY['Structure Sets', 'sops', 'LinkageChecks'], 'posda_files', 'Get List of ROI''s in a structure Set

')
        ;

            insert into queries
            values ('RtstructSopsByCollectionSiteDateRange', 'select distinct
  sop_instance_uid
from
  file_series natural join ctp_file natural join file_sop_common
  natural join file_import natural join import_event
where 
  project_name = ? and site_name = ?
  and visibility is null and import_time > ? and 
  import_time < ?
  and modality = ''RTSTRUCT''', ARRAY['collection', 'site', 'from', 'to'], 
                    ARRAY['sop_instance_uid'], ARRAY['Hierarchy', 'apply_disposition', 'hash_unhashed'], 'posda_files', 'Construct list of files in a collection, site in a Patient, Study, Series Hierarchy')
        ;

            insert into queries
            values ('InsertRowFileMr', 'insert into file_mr(
  mr_scanning_seq, mr_scanning_var, mr_scan_options,
  mr_acq_type, mr_slice_thickness, mr_repetition_time,
  mr_echo_time,  mr_magnetic_field_strength, mr_spacing_between_slices,
  mr_echo_train_length, mr_software_version, mr_flip_angle,
  mr_nominal_pixel_spacing, mr_patient_position, mr_acquisition_number,
  mr_instance_number, mr_smallest_pixel, mr_largest_value,
  mr_window_center, mr_window_width, mr_rescale_intercept,
  mr_rescale_slope, mr_rescale_type, file_id
) values (
  ?, ?, ?,
  ?, ?, ?,
  ?, ?, ?,
  ?, ?, ?,
  ?, ?, ?,
  ?, ?, ?,
  ?, ?, ?,
  ?, ?, ?
)

', ARRAY['mr_scanning_seq', 'mr_scanning_var', 'mr_scan_options', 'mr_acq_type', 'mr_slice_thickness', 'mr_repetition_time', 'mr_echo_time', 'mr_magnetic_field_strength', 'mr_spacing_between_slices', 'mr_echo_train_length', 'mr_software_version', 'mr_flip_angle', 'mr_nominal_pixel_spacing', 'mr_patient_position', 'mr_acquisition_number', 'mr_instance_number', 'mr_smallest_pixel', 'mr_largest_pixel', 'mr_window_center', 'mr_window_width', 'mr_rescale_intercept', 'mr_rescale_slope', 'mr_rescale_type', 'file_id'], 
                    '{}', ARRAY['mr_images'], 'posda_files', 'Insert a Row in file_mr
')
        ;

            insert into queries
            values ('GetPlansReferencingGoodSS', 'select
  distinct project_name as collection,
  site_name as site,
  patient_id,
  series_instance_uid,
  file_id
from
  file_series natural join
  file_patient natural join ctp_file
where
  project_name = ? and
  visibility is null and
  file_id in (
select file_id from plan p natural join file_plan  where
exists (select sop_instance_uid from file_sop_common fsc where p.ss_referenced_from_plan 
= fsc.sop_instance_uid))', ARRAY['collection'], 
                    ARRAY['collection', 'site', 'patient_id', 'series_instance_uid', 'file_id'], ARRAY['Structure Sets', 'sops', 'LinkageChecks', 'plan_linkages'], 'posda_files', 'Get list of plan which reference unknown SOPs

')
        ;

            insert into queries
            values ('GetRoundId', 'select  currval(''round_round_id_seq'') as id
', '{}', 
                    ARRAY['file_id'], ARRAY['NotInteractive', 'Backlog'], 'posda_backlog', 'Get posda file id of created round row')
        ;

            insert into queries
            values ('ChangeEquivalenceClassStatus', 'update image_equivalence_class set
  review_status = ?,
  processing_status = ?
where
  image_equivalence_class_id = ?', ARRAY['review_status', 'processing_status', 'image_equivalence_class_id'], 
                    '{}', ARRAY['by_collection', 'find_series', 'compare_collection_site', 'search_series', 'edit_files', 'simple_phi', 'dciodvfy', 'ctp_details', 'select_for_phi', 'visual_review_new_workflow'], 'posda_files', 'Get Series in A Collection, site with dicom_file_type, modality, and sop_count
')
        ;

            insert into queries
            values ('DicomEditCompareDispositionStatus', 'select 
  subprocess_invocation_id as id, 
  current_disposition as status,
  date_trunc(''minute'', start_creation_time) as started_at,
  date_trunc(''second'', last_updated - start_creation_time) as run_time,
  date_trunc(''second'', now() - last_updated) as since_update, 
  process_pid as pid,
  number_edits_scheduled as total_edits,
  number_edits_scheduled - (number_compares_with_diffs + number_compares_without_diffs) as remaining
from
dicom_edit_compare_disposition', '{}', 
                    ARRAY['id', 'status', 'started_at', 'run_time', 'since_update', 'pid', 'total_edits', 'remaining'], ARRAY['adding_ctp', 'for_scripting'], 'posda_files', 'Status of entries in dicom_edit_comparison')
        ;

            insert into queries
            values ('SsRoiForsBySopInstance', 'select 
  distinct for_uid
from
  roi natural join file_structure_set
where
  file_id in (
    select file_id 
    from file_sop_common natural join ctp_file
    where sop_instance_uid = ? and visibility is null
  )', ARRAY['sop_instance_uid'], 
                    ARRAY['for_uid'], ARRAY['Structure Sets', 'sops', 'LinkageChecks', 'struct_linkages'], 'posda_files', 'Get list of plan which reference unknown SOPs

')
        ;

            insert into queries
            values ('GetSeriesWithSignatureByCollectionSiteDateRange', 'select distinct
  series_instance_uid, dicom_file_type, 
  modality|| '':'' || coalesce(manufacturer, ''<undef>'') || '':'' 
  || coalesce(manuf_model_name, ''<undef>'') ||
  '':'' || coalesce(software_versions, ''<undef>'') as signature,
  count(distinct series_instance_uid) as num_series,
  count(distinct file_id) as num_files
from
  file_series natural join file_equipment natural join ctp_file
  natural join dicom_file join file_import using(file_id)
  join import_event using(import_event_id)
where project_name = ? and site_name = ? and visibility is null
  and import_time > ? and import_time < ?
group by series_instance_uid, dicom_file_type, signature
', ARRAY['collection', 'site', 'from', 'to'], 
                    ARRAY['series_instance_uid', 'dicom_file_type', 'signature', 'num_series', 'num_files'], ARRAY['signature', 'phi_review'], 'posda_files', 'Get a list of Series with Signatures by Collection
')
        ;

            insert into queries
            values ('UpdateElementDispositionSimple', 'update
  element_seen
set
  private_disposition = ?
where
  element_seen_id = ?', ARRAY['disp', 'id'], 
                    '{}', ARRAY['tag_usage', 'used_in_phi_maint', 'phi_maint'], 'posda_phi_simple', 'Private tags with no disposition with values in phi_simple')
        ;

            insert into queries
            values ('FindStructureSets', 'select
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
    where modality = ''CT'' and project_name = ''Exceptional-Responders'' and file_id in (
      select
         distinct file_id from file_import natural join import_event natural join dicom_file
      where import_time > ''2018-09-17''
    )
  ) as foo where image_id is null
) 
and visibility is null
group by dicom_file_type, project_name, patient_id
order by patient_id', '{}', 
                    ARRAY['dicom_file_type', 'project_name', 'patient_id', 'min', 'max', 'count'], ARRAY['Exceptional-Responders_NCI_Oct2018_curation'], 'posda_files', 'Find files which have unique_pixel_data_id but no image_id, then find out where the hell they came from')
        ;

            insert into queries
            values ('GetDciodvfyErrorUnrecogPub', 'select
  dciodvfy_error_id as id
from 
  dciodvfy_error
where
  error_type = ''UnrecognizedPublicTag''
  and error_tag = ?
', ARRAY['error_tag'], 
                    ARRAY['id'], ARRAY['NotInteractive', 'used_in_dciodvfy'], 'posda_phi_simple', 'Get an dciodvfy_errors row by error_tag where error_type = ''UnrecognizedPublicTag''')
        ;

            insert into queries
            values ('GetSeriesWithSignatureIntake', 'select
  distinct  s.series_instance_uid,
  concat(
    COALESCE(e.manufacturer, ''''), 
    ''_'',
    COALESCE(e.manufacturer_model_name, ''''),
     ''_'',
    COALESCE(e.software_versions, '''') 
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
  )', ARRAY['collection', 'site'], 
                    ARRAY['series_instance_uid', 'signature'], ARRAY['signature'], 'intake', 'Get a list of Series with Signatures by Collection Intake
')
        ;

            insert into queries
            values ('GetAllQualifiedCTQPByLikeCollectionWithFileCountAndLoadTimesSinceDate', 'select * from (select 
  collection, site, patient_id, qualified, count(distinct file_id) as num_files,
  min(date_trunc(''day'',import_time)) as earliest_day, max(date_trunc(''day'', import_time)) as latest_day
from
  clinical_trial_qualified_patient_id join file_patient using (patient_id) join file_import using(file_id)
  join import_event using(import_event_id)
where collection like ?
group by collection, site, patient_id, qualified) as foo where latest_day >= ? ', ARRAY['collection_like', 'from'], 
                    ARRAY['collection', 'site', 'patient_id', 'qualified', 'num_files', 'earliest_day', 'latest_day'], ARRAY['clin_qual'], 'posda_files', 'Create An Activity Timepoint

')
        ;

            insert into queries
            values ('PixelDataIdByFileId', 'select
  distinct file_id, image_id, unique_pixel_data_id
from
  file_image natural join image
where
  file_id = ?
', ARRAY['file_id'], 
                    ARRAY['file_id', 'image_id', 'unique_pixel_data_id'], ARRAY['by_file_id', 'pixel_data_id', 'posda_files'], 'posda_files', 'Get unique_pixel_data_id for file_id 
')
        ;

            insert into queries
            values ('FindStudiesWithNullDescriptionByCollection', 'select distinct study_instance_uid from (
  select distinct study_instance_uid, count(*) from (
    select distinct
      study_instance_uid, study_date, study_time,
      referring_phy_name, study_id, accession_number,
      study_description, phys_of_record, phys_reading,
      admitting_diag
    from
      file_study natural join ctp_file
    where
      project_name = ? and visibility is null and study_description is null
    group by
      study_instance_uid, study_date, study_time,
      referring_phy_name, study_id, accession_number,
      study_description, phys_of_record, phys_reading,
      admitting_diag
  ) as foo
  group by study_instance_uid
) as foo
where count > 1
', ARRAY['collection'], 
                    ARRAY['study_instance_uid'], ARRAY['by_study', 'consistency'], 'posda_files', 'Find Studies by Collection with Null Study Description
')
        ;

            insert into queries
            values ('IntakeImagesByCollectionSiteSubj', 'select
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
', ARRAY['collection', 'site', 'patient_id'], 
                    ARRAY['PID', 'Modality', 'SopInstance', 'FilePath'], ARRAY['SymLink', 'intake'], 'intake', 'List of all Files Images By Collection, Site
')
        ;

            insert into queries
            values ('PixelInfoBySeries', 'select
  f.file_id as file_id, root_path || ''/'' || rel_path as file,
  file_offset, size, modality,
  bits_stored, bits_allocated, pixel_representation, number_of_frames,
  samples_per_pixel, pixel_rows, pixel_columns, photometric_interpretation,
  planar_configuration
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
)
', ARRAY['series_instance_uid'], 
                    ARRAY['file_id', 'file', 'file_offset', 'size', 'bits_stored', 'bits_allocated', 'pixel_representation', 'number_of_frames', 'samples_per_pixel', 'pixel_rows', 'pixel_columns', 'photometric_interpretation', 'planar_configuration', 'modality'], '{}', 'posda_files', 'Get pixel descriptors for all files in a series
')
        ;

            insert into queries
            values ('GetFilesNotHiddenInDicomFileCompare', 'select
  distinct from_file_digest
from
  dicom_edit_compare
where
  from_file_digest in 
  (
    select from_file_digest from 
    (
      select distinct from_file_digest 
      from dicom_edit_compare dec, file f natural join ctp_file
      where dec.from_file_digest = f.digest and visibility is null and edit_command_file_id = ?
      except
      select from_file_digest from dicom_edit_compare dec
      where not exists
      (
        select file_id from file f where dec.to_file_digest = f.digest
       ) 
       and edit_command_file_id = ?
    ) as foo
  )
  and edit_command_file_id = ?
', ARRAY['command_file_id', 'command_file_id_1', 'command_file_id_2'], 
                    ARRAY['from_file_digest'], ARRAY['used_in_file_import_into_posda', 'used_in_file_migration'], 'posda_files', 'Get Files not hidden but replacement imported')
        ;

            insert into queries
            values ('RoundSummary1AvoidingCrash', 'select
  distinct round_id,
  round_start, 
  round_end - round_start as duration, 
  round_end, 
  sum(num_entered + num_dups)
from
  round natural join round_collection
where
  round_end is not null 
group by 
  round_id, round_start, duration, round_end 
order by round_id', '{}', 
                    ARRAY['round_id', 'round_start', 'duration', 'round_end', 'sum'], ARRAY['NotInteractive', 'Backlog', 'Backlog Monitor', 'backlog_analysis_reporting_tools'], 'posda_backlog', 'Summary of rounds')
        ;

            insert into queries
            values ('FindInconsistentSeriesExtended', 'select series_instance_uid from (
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
', ARRAY['collection'], 
                    ARRAY['series_instance_uid'], ARRAY['consistency', 'find_series'], 'posda_files', 'Find Inconsistent Series Extended to include image type
')
        ;

            insert into queries
            values ('GetTheBaseCtSeriesForLGCP', 'select
  patient_id, series_instance_uid, count(distinct file_id) as num_files
from 
  file_series natural join file_patient natural join ctp_file
where series_instance_uid in (
 ''1.3.6.1.4.1.14519.5.2.1.5826.1402.983508919695337135620677418685'',
 ''1.3.6.1.4.1.14519.5.2.1.5826.1402.170224599052836213374813274674'',
 ''1.3.6.1.4.1.14519.5.2.1.5826.1402.124599233476878991434251967746'',
 ''1.3.6.1.4.1.14519.5.2.1.5826.1402.122505729234908340647352438768'',
 ''1.3.6.1.4.1.14519.5.2.1.5826.1402.246380096059125471917249164954'',
 ''1.3.6.1.4.1.14519.5.2.1.5826.1402.199118463594923165410399883739'')
 and visibility is null
group by patient_id, series_instance_uid', '{}', 
                    ARRAY['patient_id', 'series_instance_uid', 'num_files'], ARRAY['Curation of Lung-Fused-CT-Pathology'], 'posda_files', 'Get the list of series which serve as a basis for fixing SOP instance UID''s in Lung-Fused-CT-Pathology')
        ;

            insert into queries
            values ('RoiInfoByFileIdWithCountsAndOffsets', 'select
  roi_id, for_uid, linked_sop_instance_uid,
  max_x, max_y, max_z,
  min_x, min_y, min_z,
  roi_name, roi_description , roi_interpreted_type,
  contour_file_offset + coalesce (data_set_start, 0) as contour_real_file_offset,
  contour_length,
  root_path || ''/'' || rel_path as path
from
  roi natural join file_roi_image_linkage natural join file_location natural join file_storage_root natural join file_meta
where file_id = ?
', ARRAY['file_id'], 
                    ARRAY['roi_id', 'for_uid', 'linked_sop_instance_uid', 'max_x', 'max_y', 'max_z', 'min_x', 'min_y', 'min_z', 'roi_name', 'roi_description', 'roi_interpreted_type', 'contour_real_file_offset', 'contour_length', 'path'], ARRAY['LinkageChecks', 'used_in_struct_linkage_check'], 'posda_files', 'Get list of Roi with info by file_id

')
        ;

            insert into queries
            values ('GetNonDicomFilesByCollection', 'select 
  file_id, file_type, file_sub_type, collection, site, subject, visibility, date_last_categorized
from
  non_dicom_file
where
  collection = ? and
  visibility is null
', ARRAY['collection'], 
                    ARRAY['file_id', 'file_type', 'file_sub_type', 'collection', 'site', 'subject', 'visibility', 'date_last_categorized'], ARRAY['radcomp'], 'posda_files', 'Add a filter to a tab')
        ;

            insert into queries
            values ('InsertActivityTaskStatus', 'insert into activity_task_status(
  activity_id,
  subprocess_invocation_id,
  start_time,
  status_text,
  last_updated
) values (
  ?,
  ?,
  now(),
   ''Initializing'',
  now()
)', ARRAY['activity_id', 'subprocess_invocation_id'], 
                    '{}', ARRAY['Insert', 'NotInteractive'], 'posda_files', 'Insert Initial Patient Status
For use in scripts
Not really intended for interactive use
')
        ;

            insert into queries
            values ('ConflictingDispositions', 'select
  element_sig_pattern, vr, tag_name, private_disposition
 from 
  element_seen 
where element_sig_pattern in (
  select 
    distinct element_sig_pattern 
  from (
    select 
      distinct element_sig_pattern, count(distinct private_disposition) 
    from element_seen 
    group by element_sig_pattern 
    order by count desc
  ) as foo 
  where count > 1
) order by element_sig_pattern;', '{}', 
                    ARRAY['element_sig_pattern', 'vr', 'tag_name', 'private_disposition'], ARRAY['tag_usage', 'simple_phi_maint', 'phi_maint'], 'posda_phi_simple', 'Private tags with no disposition with values in phi_simple')
        ;

            insert into queries
            values ('CreateCopyFromPublicEntry', 'insert into copy_from_public(
  who, why, when_row_created, status_of_copy
) values (
  ?, ?, now(), ?
)', ARRAY['who', 'why', 'status_of_copy'], 
                    '{}', ARRAY['bills_test', 'copy_from_public'], 'posda_files', 'Add a filter to a tab')
        ;

            insert into queries
            values ('TagsSeenPrivateWithCountNullDisp', 'select
  distinct element_signature, 
  vr, 
  private_disposition, 
  name_chain, 
  count(distinct value) as num_values
from
  element_signature natural left join
  scan_element natural left join
  seen_value
where is_private and private_disposition is null
group by element_signature, vr, private_disposition, name_chain
order by element_signature, vr', '{}', 
                    ARRAY['element_signature', 'vr', 'private_disposition', 'name_chain', 'num_values'], ARRAY['by_collection', 'find_series', 'compare_collection_site', 'search_series', 'edit_files', 'phi_maint'], 'posda_phi', 'Get all the data from tags_seen in posda_phi database
')
        ;

            insert into queries
            values ('FileStorageRootSummary', 'select 
  distinct file_storage_root_id,
  root_path,
  storage_class,
  count(distinct file_id) as num_files
from
  file_storage_root
  natural join file_location
group by file_storage_root_id, root_path, storage_class;', '{}', 
                    ARRAY['file_storage_root_id', 'root_path', 'storage_class', 'num_files'], ARRAY['used_in_file_import_into_posda', 'used_in_file_migration'], 'posda_files', 'Get count of files relative to storage root')
        ;

            insert into queries
            values ('ListOfPrivateElementsWithDispositions', 'select
  element_signature, vr , private_disposition as disposition, element_signature_id, name_chain
from
  element_signature
where
  is_private
order by element_signature
', '{}', 
                    ARRAY['element_signature', 'vr', 'disposition', 'element_signature_id', 'name_chain'], ARRAY['NotInteractive', 'Update', 'ElementDisposition'], 'posda_phi', 'Get Disposition of element by sig and VR')
        ;

            insert into queries
            values ('FindPotentialDistinguishedPixelDigests', 'select 
  distinct project_name as collection,
  site_name as site,
  patient_id,
  series_instance_uid,
  modality,
  dicom_file_type,
  digest as pixel_digest,
  pixel_rows,
  pixel_columns,
  bits_allocated,
  count(*)
from
  ctp_file
  natural join file_patient
  natural join file_series
  natural join file_image
  natural join dicom_file
  join image using (image_id)
  join unique_pixel_data using(unique_pixel_data_id)
where
  file_id in 
  (select 
    distinct file_id 
  from
    file_image 
  where
    image_id in
    (select
       image_id from 
       (select
         distinct image_id, count(distinct file_id) 
       from
         file_image 
       group by image_id
       ) as foo
     where count > 10
  )
) and visibility is null 
group by collection, site, patient_id, series_instance_uid,
modality, dicom_file_type,
digest, pixel_rows, pixel_columns, bits_allocated
order by digest, collection, site, patient_id

', '{}', 
                    ARRAY['collection', 'site', 'patient_id', 'series_instance_uid', 'modality', 'dicom_file_type', 'pixel_digest', 'pixel_rows', 'pixel_columns', 'bits_allocated', 'count'], ARRAY['duplicates', 'distinguished_digest'], 'posda_files', 'Return a count of duplicate SOP Instance UIDs
')
        ;

            insert into queries
            values ('PixelTypesWithNoGeo', 'select
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
', '{}', 
                    ARRAY['photometric_interpretation', 'samples_per_pixel', 'bits_allocated', 'bits_stored', 'high_bit', 'pixel_representation', 'planar_configuration'], ARRAY['find_pixel_types', 'image_geometry', 'posda_files'], 'posda_files', 'Get pixel types with no geometry
')
        ;

            insert into queries
            values ('LockNonDicomEditCompareDisposition', 'lock non_dicom_edit_compare_disposition
', '{}', 
                    '{}', ARRAY['adding_ctp', 'for_scripting', 'non_dicom_import'], 'posda_files', 'Lock table non_dicom_edit_compare_disposition

From script only.  Don''t run from user interface.')
        ;

            insert into queries
            values ('PatientStudySeriesEquivalenceClassNoByProcessingStatus', 'select 
  distinct patient_id, study_instance_uid, series_instance_uid, equivalence_class_number, count(*) 
from 
  image_equivalence_class natural join image_equivalence_class_input_image natural join
  file_study natural join file_series natural join file_patient
where
  processing_status = ?
group by patient_id, study_instance_uid, series_instance_uid, equivalence_class_number
order by patient_id, study_instance_uid, series_instance_uid, equivalence_class_number', ARRAY['processing_status'], 
                    ARRAY['patient_id', 'study_instance_uid', 'series_instance_uid', 'equivalence_class_number', 'count'], ARRAY['find_series', 'equivalence_classes', 'consistency', 'visual_review'], 'posda_files', 'Find Series with more than n equivalence class')
        ;

            insert into queries
            values ('FileIdByPixelType', 'select
  distinct file_id
from
  image natural join file_image
where
  photometric_interpretation = ? and
  samples_per_pixel = ? and
  bits_allocated = ? and
  bits_stored = ? and
  high_bit = ? and
  (pixel_representation = ?  or pixel_representation is null) and
  (planar_configuration = ? or planar_configuration is null)
limit 100', ARRAY['photometric_interpretation', 'samples_per_pixel', 'bits_allocated', 'bits_stored', 'high_bit', 'pixel_representation', 'planar_configuration'], 
                    ARRAY['file_id'], ARRAY['all', 'find_pixel_types', 'posda_files'], 'posda_files', 'Get distinct pixel types
')
        ;

            insert into queries
            values ('CountOfFilesRemainingToBeHiddenByScanInstance', 'select
  count(distinct file_id) as num_files
from
  file_sop_common natural
  join ctp_file
where
  visibility is null and
  sop_instance_uid in (
    select
      sop_instance_uid
    from
      file_sop_common
      where file_id in (
          select
            distinct file_id
          from
             image_equivalence_class natural join
             image_equivalence_class_input_image
           where
             visual_review_instance_id = ? and
             review_status = ''Bad''
        )
     )', ARRAY['visual_review_instance_id'], 
                    ARRAY['num_files'], ARRAY['by_collection', 'find_series', 'compare_collection_site', 'search_series', 'edit_files', 'simple_phi', 'dciodvfy', 'ctp_details', 'select_for_phi', 'visual_review_status'], 'posda_files', 'Get Series in A Collection, site with dicom_file_type, modality, and sop_count
')
        ;

            insert into queries
            values ('RoundSummary1ByDateRange', 'select
  distinct round_id,
  round_start, 
  round_end - round_start as duration, 
  round_end, 
  sum(num_entered + num_dups),
  ((round_end - round_start) / sum(num_entered + num_dups)) as sec_per_file
from
  round natural join round_collection
where
  round_end is not null and round_end > ? and round_end < ?
group by 
  round_id, round_start, duration, round_end 
order by round_id', ARRAY['from', 'to'], 
                    ARRAY['round_id', 'round_start', 'duration', 'round_end', 'sum', 'sec_per_file'], ARRAY['NotInteractive', 'Backlog', 'Backlog Monitor', 'backlog_status'], 'posda_backlog', 'Summary of rounds')
        ;

            insert into queries
            values ('GetDciodvfyWarningRetiredAttr', 'select
  dciodvfy_warning_id as id
from 
  dciodvfy_warning
where
  warning_type = ''RetiredAttribute''
  and warning_tag = ?
  and warning_desc = ?', ARRAY['warning_tag', 'warning_desc'], 
                    ARRAY['id'], ARRAY['NotInteractive', 'used_in_dciodvfy'], 'posda_phi_simple', 'Get dciodvfy_warnings row where warning_type = GetDciodvfyWarningRetiredAttr')
        ;

            insert into queries
            values ('ShowAllVisibilityChangesBySopInstance', 'select
  file_id,
  user_name,
  time_of_change,
  prior_visibility,
  new_visibility,
  reason_for
from
   file_visibility_change 
where file_id in (
  select file_id 
  from file_sop_common
  where sop_instance_uid = ?
)
order by time_of_change', ARRAY['sop_instance_uid'], 
                    ARRAY['file_id', 'user_name', 'time_of_change', 'prior_visibility', 'new_visibility', 'reason_for'], ARRAY['old_hidden'], 'posda_files', 'Show All Hide Events by Collection, Site')
        ;

            insert into queries
            values ('AllPrivateDispositions', 'select 
  distinct element_sig_pattern, vr, tag_name, element_seen_id, private_disposition
from 
  element_seen
where
  is_private
order by element_sig_pattern,vr', '{}', 
                    ARRAY['element_sig_pattern', 'tag_name', 'vr', 'element_seen_id', 'private_disposition'], ARRAY['tag_usage', 'used_in_phi_maint', 'phi_maint'], 'posda_phi_simple', 'Private tags with no disposition with values in phi_simple')
        ;

            insert into queries
            values ('DuplicateSOPInstanceUIDs', 'select
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
', ARRAY['collection', 'site', 'subject'], 
                    ARRAY['sop_instance_uid', 'first', 'last', 'count'], ARRAY['duplicates'], 'posda_files', 'Return a count of duplicate SOP Instance UIDs
')
        ;

            insert into queries
            values ('GetDciodvfyWarningAttrSpecWithValue', 'select
  dciodvfy_warning_id as id
from 
  dciodvfy_warning
where
  warning_type = ''AttributeSpecificWarningWithValue''
  and warning_tag = ?
  and warning_desc = ?
  and warning_value = ?


  ', ARRAY['warning_tag', 'warning_desc', 'warning_value'], 
                    ARRAY['id'], ARRAY['NotInteractive', 'used_in_dciodvfy'], 'posda_phi_simple', 'Get dciodvfy_warning row where subtype = AttributeSpecificWarningWithValue')
        ;

            insert into queries
            values ('ShowQueryTabHierarchyByTabWithQueryCounts', 'select distinct query_tab_name, filter_name, tag, count(distinct query_name) as num_queries
from(
select
  query_tab_name, filter_name, tag, query_name
from (
  select 
     query_tab_name,
      filter_name,
      unnest(tags_enabled) as tag
  from
    query_tabs join query_tabs_query_tag_filter using(query_tab_name)
    natural join query_tag_filter
  where query_tab_name = ?
) as foo
natural join(
  select name as query_name, unnest(tags) as tag
from queries
) as fie
) as foo
group by query_tab_name, filter_name, tag
order by filter_name, tag', ARRAY['query_tab_name'], 
                    ARRAY['query_tab_name', 'filter_name', 'tag', 'num_queries'], ARRAY['meta', 'test', 'hello', 'query_tabs', 'bills_test'], 'posda_queries', 'Add a filter to a tab')
        ;

            insert into queries
            values ('QueryArgsByQueryId', 'select
  arg_index as num, arg_name as name, arg_value as value
from
  dbif_query_args
where
  query_invoked_by_dbif_id = ?
order by arg_index', ARRAY['id'], 
                    ARRAY['num', 'name', 'value'], ARRAY['AllCollections', 'q_stats'], 'posda_queries', 'Get a list of collections and sites
')
        ;

            insert into queries
            values ('GetNonDicomPathSeen', 'select
  non_dicom_path_seen_id 
from
  non_dicom_path_seen
where
  non_dicom_file_type = ? and
  non_dicom_path = ?', ARRAY['file_type', 'path'], 
                    '{}', ARRAY['NotInteractive', 'non_dicom_phi'], 'posda_phi_simple', 'Create a dciodvfy_scan_instance row')
        ;

            insert into queries
            values ('WhereSeriesSitsQuick', 'select distinct
  project_name as collection,
  site_name as site,
  patient_id,
  study_instance_uid,
  series_instance_uid
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
  limit 1
)', ARRAY['series_instance_uid'], 
                    ARRAY['collection', 'site', 'patient_id', 'study_instance_uid', 'series_instance_uid'], ARRAY['by_series_instance_uid', 'posda_files', 'sops', 'used_in_simple_phi'], 'posda_files', 'Get Collection, Site, Patient, Study Hierarchy in which series resides
')
        ;

            insert into queries
            values ('DiskSpaceByCollectionSummaryWithDups', 'select
  distinct project_name as collection, sum(size) as total_bytes
from
  ctp_file natural join file natural join file_import
where
  file_id in (
  select distinct file_id
  from ctp_file
  )
group by project_name
order by total_bytes
', '{}', 
                    ARRAY['collection', 'total_bytes'], ARRAY['by_collection', 'posda_files', 'storage_used', 'summary'], 'posda_files', 'Get disk space used for all collections
')
        ;

            insert into queries
            values ('GetFileVisibility', 'select distinct visibility from ctp_file where file_id = ?', ARRAY['file_id'], 
                    ARRAY['visibility'], ARRAY['used_in_file_import_into_posda', 'used_in_file_migration'], 'posda_files', 'Get current visibility by file_id
')
        ;

            insert into queries
            values ('PatientIdMappingByPatientId', 'select
  from_patient_id, to_patient_id, to_patient_name, collection_name, site_name,
  batch_number, diagnosis_date, baseline_date, date_shift, uid_root
from 
  patient_mapping
where
  from_patient_id = ?', ARRAY['from_patient_id'], 
                    ARRAY['from_patient_id', 'to_patient_id', 'to_patient_name', 'collection_name', 'site_name', 'batch_number', 'diagnosis_date', 'baseline_date', 'date_shift', 'uid_root'], ARRAY['adding_ctp', 'for_scripting', 'non_dicom_phi', 'non_dicom_edit'], 'posda_files', 'Simple Phi Report with Meta Quotes')
        ;

            insert into queries
            values ('InsertIntoNonDicomEditCompareFixed', 'insert into non_dicom_edit_compare(
  subprocess_invocation_id,
  from_file_digest,
  to_file_digest,
  report_file_id,
  to_file_path
) values ( ?, ?, ?, ?, ?)', ARRAY['subprocess_invocation_id', 'from_file_digest', 'to_file_digest', 'report_file_id', 'to_file_path'], 
                    '{}', ARRAY['NotInteractive', 'Backlog', 'Transaction', 'used_in_file_import_into_posda', 'public_posda_counts', 'non_dicom_edit'], 'posda_files', 'Lock the file table in posda_files')
        ;

            insert into queries
            values ('GetDciodvfyWarningAttrSpec', 'select
  dciodvfy_warning_id as id
from 
  dciodvfy_warning
where
  warning_type = ''AttributeSpecificWarning''
  and warning_tag = ?
  and warning_desc= ?', ARRAY['warning_tag', 'warning_desc'], 
                    ARRAY['id'], ARRAY['NotInteractive', 'used_in_dciodvfy'], 'posda_phi_simple', 'Get dciodvfy_warning row where subtype = AttributeSpecificWarning')
        ;

            insert into queries
            values ('GetPatientInfoById', 'select
  file_id,
  patient_name,
  patient_id,
  id_issuer,
  dob,
  sex,
  time_ob,
  other_ids
  other_name,
  ethnic_group,
  comments
from file_patient
where file_id = ?', ARRAY['file_id'], 
                    ARRAY['file_id', 'modality', 'series_instance_uid', 'series_number', 'laterality', 'series_date', 'series_time', 'performing_phys', 'protocol_name', 'series_description', 'operators_name', 'body_part_examined', 'patient_position', 'smallest_pixel_value', 'largest_pixel_value', 'performed_procedure_step_id', 'performed_procedure_step_start_date', 'performed_procedure_step_start_time', 'performed_procedure_step_desc', 'performed_procedure_step_comments', 'performed_procedure_step_comments', 'date_fixed'], ARRAY['reimport_queries'], 'posda_files', 'Get file path from id')
        ;

            insert into queries
            values ('CreateCtpFileRow', 'insert into ctp_file(
  file_id, project_name, site_name, site_id, file_visibility, batch, study_year
) values (
  ?, ?, ?, ?, ?, ?, ?
)', ARRAY['file_id', 'project_name', 'site_name', 'site_id', 'file_visibility', 'batch', 'study_year'], 
                    '{}', ARRAY['meta', 'test', 'hello', 'query_tabs', 'bills_test'], 'posda_files', 'create ctp_file row')
        ;

            insert into queries
            values ('InsertIntoDicomEditCompareFixed', 'insert into dicom_edit_compare(
  subprocess_invocation_id,
  from_file_digest,
  to_file_digest,
  short_report_file_id,
  long_report_file_id,
  to_file_path
) values ( ?, ?, ?, ?, ?, ?)', ARRAY['subprocess_invocation_id', 'from_file_digest', 'to_file_digest', 'short_report_file_id', 'long_report_file_id', 'to_file_path'], 
                    '{}', ARRAY['NotInteractive', 'Backlog', 'Transaction', 'used_in_file_import_into_posda', 'public_posda_counts'], 'posda_files', 'Lock the file table in posda_files')
        ;

            insert into queries
            values ('AddFilterToTab', 'insert into query_tabs_query_tag_filter(query_tab_name, filter_name, sort_order)
values(?, ?, ?)', ARRAY['query_tab_name', 'filter_name', 'sort_order'], 
                    '{}', ARRAY['meta', 'test', 'hello', 'query_tabs', 'bills_test'], 'posda_queries', 'Add a filter to a tab')
        ;

            insert into queries
            values ('PixelTypesWithGeoRGB', 'select
  distinct photometric_interpretation,
  samples_per_pixel,
  bits_allocated,
  bits_stored,
  high_bit,
  pixel_representation,
  planar_configuration,
  iop, count(distinct image_id) as num_images
from
  image natural left join image_geometry
where
  photometric_interpretation = ''RGB''
group by photometric_interpretation,
  samples_per_pixel, bits_allocated, bits_stored, high_bit, pixel_representation,
  planar_configuration, iop
order by photometric_interpretation
', '{}', 
                    ARRAY['photometric_interpretation', 'samples_per_pixel', 'bits_allocated', 'bits_stored', 'high_bit', 'pixel_representation', 'planar_configuration', 'iop', 'num_images'], ARRAY['find_pixel_types', 'image_geometry', 'posda_files', 'rgb'], 'posda_files', 'Get distinct pixel types with geometry and rgb
')
        ;

            insert into queries
            values ('CreateActivityTimepoint', 'insert into activity_timepoint(
  activity_id, when_created, who_created, comment, creating_user
) values (
  ?, now(), ?, ?, ?
)', ARRAY['actiity_id', 'who_created', 'comment', 'creating_user'], 
                    '{}', ARRAY['by_collection', 'find_series', 'compare_collection_site', 'search_series', 'edit_files', 'simple_phi', 'dciodvfy', 'ctp_details', 'select_for_phi', 'visual_review_selection', 'activity_timepoint_support'], 'posda_queries', 'Create An Activity Timepoint

')
        ;

            insert into queries
            values ('RoundStatsWithSubjByCollectionForDateRange', 'select
  distinct collection, site, subj, date_trunc(?, time_received) as time,
  count(*) as number_of_files,
  max(time_entered - time_received) as max_delay,
  min(time_entered - time_received) as min_delay
from request natural join submitter
where time_received > ? and time_received < ? and collection = ?
group by collection, site, subj, time order by time desc, collection', ARRAY['interval', 'from', 'to', 'collection'], 
                    ARRAY['collection', 'site', 'subj', 'time', 'number_of_files', 'max_delay', 'min_delay'], ARRAY['NotInteractive', 'Backlog', 'Backlog Monitor', 'for_bill'], 'posda_backlog', 'Summary of rounds')
        ;

            insert into queries
            values ('PhiNonDicomScanStatus', 'select 
   phi_non_dicom_scan_instance_id as id,
   pndsi_description as description,
   pndsi_start_time as start_time,
   pndsi_num_files as num_files_to_scan,
   pndsi_num_files_scanned as num_files_scanned,
   pndsi_end_time as end_time
from
  phi_non_dicom_scan_instance
order by start_time
', '{}', 
                    ARRAY['id', 'description', 'start_time', 'num_files_to_scan', 'num_files_scanned', 'end_time'], ARRAY['tag_usage', 'non_dicom_phi_status'], 'posda_phi_simple', 'Status of PHI scans
')
        ;

            insert into queries
            values ('PatientStudySeriesFileHierarchyByCollectionSite', 'select distinct
  patient_id,
  study_instance_uid,
  series_instance_uid,
  sop_instance_uid,
  modality
from
  file_study natural join ctp_file natural join file_series natural join file_patient
  natural join file_sop_common
where 
  file_id in (
    select distinct file_id
    from ctp_file
    where project_name = ? and site_name = ? and visibility is null
  )
order by patient_id, study_instance_uid, series_instance_uid', ARRAY['collection', 'site'], 
                    ARRAY['patient_id', 'study_instance_uid', 'series_instance_uid', 'modality'], ARRAY['Hierarchy'], 'posda_files', 'Construct list of files in a collection, site in a Patient, Study, Series, with Modality of file')
        ;

            insert into queries
            values ('CreateNonDicomFileScanInstance', 'insert into non_dicom_file_scan(
  phi_non_dicom_scan_instance_id,
  file_type,
  file_in_posda,
  posda_file_id
) values (
  ?, ?, true, ?
)', ARRAY['phi_non_dicom_scan_instance_id', 'file_type', 'posda_file_id'], 
                    '{}', ARRAY['NotInteractive', 'non_dicom_phi'], 'posda_phi_simple', 'Create a dciodvfy_scan_instance row')
        ;

            insert into queries
            values ('GetUnpopulatedMrFiles', 'select
  distinct file_id, root_path || ''/'' || rel_path as path
from 
  file_storage_root natural join file_location
where
  file_id in (
    select file_id from dicom_file d natural left join ctp_file
    where visibility is null and dicom_file_type = ''MR Image Storage''
    and not exists (
      select file_id from file_mr m where m.file_id = d.file_id
    )
  )', '{}', 
                    ARRAY['file_id', 'path'], ARRAY['mr_images'], 'posda_files', 'Counts query by Collection, Site
')
        ;

            insert into queries
            values ('AllManifestsByCollection', 'select
  distinct file_id, import_time, size, root_path || ''/'' || l.rel_path as path, i.file_name as alt_path
from
  file_location l join file_storage_root using(file_storage_root_id) 
  join file_import i using (file_id) natural join file join import_event using(import_event_id)
where
  file_id in (
    select distinct file_id from ctp_manifest_row where cm_collection = ?
  )', ARRAY['collection'], 
                    ARRAY['file_id', 'import_time', 'size', 'path', 'alt_path'], ARRAY['activity_timepoint_support', 'manifests'], 'posda_files', 'Create An Activity Timepoint

')
        ;

            insert into queries
            values ('InsertInitialDicomDD', 'insert into dicom_element(tag, name, keyword, vr, vm, is_retired, comments)
values (?,?,?,?,?,?,?)', ARRAY['tag', 'name', 'keyword', 'vr', 'vm', 'is_retired', 'comments'], 
                    '{}', ARRAY['Insert', 'NotInteractive', 'dicom_dd'], 'dicom_dd', 'Insert row into dicom_dd database')
        ;

            insert into queries
            values ('VolumeReferencedByStruct', 'select 
  distinct for_uid, study_instance_uid, series_instance_uid, count(distinct sop_instance) as num_sops
from
  ss_volume natural join ss_for natural join file_structure_set
where
  file_id = ?
group by
  for_uid, study_instance_uid, series_instance_uid', ARRAY['file_id'], 
                    ARRAY['for_uid', 'study_instance_uid', 'series_instance_uid', 'num_sops'], ARRAY['Test Case based on Soft-tissue-Sarcoma'], 'posda_files', 'Find All of the Structure Sets In Soft-tissue-Sarcoma')
        ;

            insert into queries
            values ('FirstFileForSopPosda', 'select
  root_path || ''/'' || rel_path as path,
  modality
from 
  file_location natural join file_storage_root
  natural join file_sop_common
  natural join file_series
  natural join ctp_file
where
  sop_instance_uid = ? and visibility is null
limit 1', ARRAY['sop_instance_uid'], 
                    ARRAY['path', 'modality'], ARRAY['by_series', 'UsedInPhiSeriesScan'], 'posda_files', 'First files in series in Posda
')
        ;

            insert into queries
            values ('GetAllInboxItems', 'select
  user_inbox_content_id,
  background_subprocess_report_id,
  current_status,
  date_entered
from user_inbox_content 
natural join user_inbox
where user_name = ?
order by date_entered desc
', ARRAY['user_name'], 
                    ARRAY['user_inbox_content_id', 'background_subprocess_report_id', 'current_status', 'date_entered'], '{}', 'posda_queries', 'Get a list of all messages from the user''s inbox.')
        ;

            insert into queries
            values ('GetDciodvfyWarningUnrecogTag', 'select
  dciodvfy_warning_id as id
from 
  dciodvfy_warning
where
  warning_type = ''UnrecognizedTag''
  and warning_tag = ?
  and warning_comment = ?
 ', ARRAY['warning_tag', 'warning_comment'], 
                    ARRAY['id'], ARRAY['NotInteractive', 'used_in_dciodvfy'], 'posda_phi_simple', 'Get an dciodvfy_warnings row by warning_text (if present)')
        ;

            insert into queries
            values ('DupReport', 'select
  distinct collection,
  sum(num_entered) num_files,
  sum(num_dups) num_dups,
  (cast(sum(num_dups) as float)/cast((sum(num_entered) + sum(num_dups)) as float))*100.0 as
   percent_dups
from
  round_collection
group by collection
order by percent_dups desc', '{}', 
                    ARRAY['collection', 'num_files', 'num_dups', 'percent_dups'], ARRAY['Backlog', 'Backlog Monitor', 'backlog_analysis_reporting_tools'], 'posda_backlog', 'Report on Percentage of duplicates by collection')
        ;

            insert into queries
            values ('InsertActivityInboxContent', 'insert into activity_inbox_content(
 activity_id, user_inbox_content_id
) values (
  ?, ?
)
', ARRAY['activity_id', 'user_inbox_content_id'], 
                    '{}', ARRAY['AllCollections', 'queries', 'activity_support'], 'posda_queries', 'Get a list of available queries')
        ;

            insert into queries
            values ('GetPosdaSopsForCompare', 'select
  distinct patient_id,
  study_instance_uid, 
  series_instance_uid, 
  sop_instance_uid,
  sop_class_uid,
  modality,
  dicom_file_type,
  root_path || ''/'' || rel_path as file_path,
  file_id
from
  ctp_file
  natural join dicom_file
  natural join file_patient
  natural join file_study
  natural join file_series
  natural join file_sop_common
  natural join file_location
  natural join file_storage_root
where
  project_name = ? 
  and visibility is null', ARRAY['collection'], 
                    ARRAY['patient_id', 'study_instance_uid', 'series_instance_uid', 'sop_instance_uid', 'sop_class_uid', 'modality', 'dicom_file_type', 'file_path', 'file_id'], ARRAY['public_posda_counts'], 'posda_files', 'Generate a long list of all unhidden SOPs for a collection in posda<br>
<em>This can generate a long list</em>')
        ;

            insert into queries
            values ('DistinctSopsInCollectionSiteIntakeWithFile', 'select
  distinct i.sop_instance_uid, i.dicom_file_uri
from
  general_image i,
  trial_data_provenance tdp
where
  i.trial_dp_pk_id = tdp.trial_dp_pk_id and
  tdp.project = ? and tdp.dp_site_name = ?
order by sop_instance_uid
', ARRAY['collection', 'site'], 
                    ARRAY['sop_instance_uid', 'dicom_file_uri'], ARRAY['by_collection', 'files', 'intake', 'sops', 'compare_collection_site'], 'intake', 'Get Distinct SOPs in Collection with number files
')
        ;

            insert into queries
            values ('DuplicateSOPInstanceUIDsByCollectionWithoutHidden1', 'select
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
', '{}', 
                    ARRAY['collection', 'site', 'patient_id', 'study_instance_uid', 'series_instance_uid'], ARRAY['receive_reports'], 'posda_files', 'Return a count of visible duplicate SOP Instance UIDs
')
        ;

            insert into queries
            values ('UploadCountsBetweenDatesByCollection', 'select distinct 
  project_name, site_name, patient_id, 
  study_instance_uid, series_instance_uid,
  count(*)
from
  ctp_file natural join file_study
  natural join file_series
  natural join file_patient
where file_id in (
  select file_id
  from
    file_import natural join import_event
    natural join ctp_file
  where
    import_time > ? and import_time < ? 
    and project_name = ?
)
group by
  project_name, site_name, patient_id, 
  study_instance_uid, series_instance_uid
order by 
  project_name, site_name, patient_id, 
  study_instance_uid, series_instance_uid
 ', ARRAY['start_time', 'end_time', 'collection'], 
                    ARRAY['project_name', 'site_name', 'patient_id', 'study_instance_uid', 'series_instance_uid', 'count'], ARRAY['receive_reports'], 'posda_files', 'Counts of uploads received between dates for a collection
Organized by Subject, Study, Series, count of files_uploaded
')
        ;

            insert into queries
            values ('RelinquishBacklogControl', 'update control_status
set status = ''idle'',
  processor_pid =  null,
  pending_change_request = null,
  source_pending_change_request = null,
  request_time = null', '{}', 
                    '{}', ARRAY['NotInteractive', 'Backlog'], 'posda_backlog', 'relese control of posda_backlog')
        ;

            insert into queries
            values ('missing file_study', 'select distinct patient_id, dicom_file_type, series_instance_uid, modality, count(distinct file_id) as num_files,
  min(import_time) as earliest, max(import_time) as latest
from 
file_patient natural join dicom_file natural join file_series
natural join file_import natural join import_event
where file_id in (
select file_id from 
ctp_file where project_name =? and site_name = ? and visibility is null and not exists (select file_id from file_study where file_study.file_id = ctp_file.file_id)) group by patient_id, dicom_file_type, series_instance_uid, modality', ARRAY['collection', 'site'], 
                    ARRAY['patient_id', 'dicom_file_type', 'series_instance_uid', 'modality', 'num_files', 'earliest', 'latest'], ARRAY['meta', 'test', 'hello', 'query_tabs', 'bills_test'], 'posda_files', 'Add a filter to a tab')
        ;

            insert into queries
            values ('FindInconsistentSeriesByCollectionSite', 'select series_instance_uid from (
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
    project_name = ? and site_name = ? and visibility is null
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
', ARRAY['collection', 'site'], 
                    ARRAY['series_instance_uid'], ARRAY['consistency', 'find_series'], 'posda_files', 'Find Inconsistent Series
')
        ;

            insert into queries
            values ('GeFromToFilesFromNonDicomEditCompare', 'select 
  file_id as from_file_id, 
  foo.to_file_id 
from 
  file, 
  (
    select 
      from_file_digest, 
      file_id as to_file_id
    from 
      file,
       non_dicom_edit_compare 
    where 
      to_file_digest = digest
      and subprocess_invocation_id = ?
  ) as foo
where 
  from_file_digest = digest;', ARRAY['subprocess_invocation_id'], 
                    ARRAY['from_file_id', 'to_file_id'], ARRAY['adding_ctp', 'for_scripting', 'non_dicom_import'], 'posda_files', 'Retrieve entries from patient_mapping table')
        ;

            insert into queries
            values ('SimplePhiReportAll', 'select 
  distinct element_sig_pattern as element, vr, value, tag_name as description, count(*) as num_series
from element_value_occurance natural join element_seen natural join value_seen
where 
  phi_scan_instance_id = ?
group by element_sig_pattern, vr, value, description
order by vr, element, value', ARRAY['scan_id'], 
                    ARRAY['element', 'vr', 'value', 'description', 'num_series'], ARRAY['tag_usage', 'simple_phi'], 'posda_phi_simple', 'Status of PHI scans
')
        ;

            insert into queries
            values ('FileNameReportByImportEvent', 'select
  file_id, patient_id,
  study_instance_uid, study_date, study_description, series_instance_uid,
  modality, series_date, series_description, dicom_file_type, file_name
from
  file_import natural join file_patient natural join file_series natural join
  file_study natural join dicom_file
where
  import_event_id = ?
order by file_name', ARRAY['import_event_id'], 
                    ARRAY['file_id', 'patient_id', 'study_instance_uid', 'study_date', 'study_description', 'series_instance_uid', 'modality', 'series_date', 'series_description', 'dicom_file_type', 'file_name'], ARRAY['import_events'], 'posda_files', 'List of values seen in scan by ElementSignature with VR and count
')
        ;

            insert into queries
            values ('IncrementPhiNonDicomFilesScanned', 'update phi_non_dicom_scan_instance
set pndsi_num_files_scanned = pndsi_num_files_scanned + 1
where phi_non_dicom_scan_instance_id = ?', ARRAY['phi_non_dicom_scan_instance_id'], 
                    '{}', ARRAY['used_in_simple_phi', 'NotInteractive', 'non_dicom_phi'], 'posda_phi_simple', 'Get value seen if exists')
        ;

            insert into queries
            values ('GetElementByPublicDisposition', 'select
  element_signature, disposition
from
  element_signature natural join public_disposition
where
  sop_class_uid = ? and name = ? and
  not is_private and disposition = ?
', ARRAY['sop_class_uid', 'name', 'disposition'], 
                    ARRAY['element_signature', 'disposition'], ARRAY['NotInteractive', 'ElementDisposition'], 'posda_phi', 'Get List of Public Elements By Disposition, Sop Class, and name')
        ;

            insert into queries
            values ('PotentialDuplicateSopSeriesByCollectionSite', 'select distinct collection, site, subj_id, study_instance_uid, series_instance_uid, 
count(distinct sop_instance_uid)
from
(select
  distinct collection, site, subj_id, study_instance_uid, series_instance_uid, sop_instance_uid,
  file_id, file_path
from (
  select
    distinct project_name as collection,
    site_name as site, patient_id as subj_id,
    study_instance_uid, series_instance_uid,
    sop_instance_uid,
    file_id, root_path ||''/'' || rel_path as file_path
  from
    ctp_file natural join file_sop_common
    natural join file_patient natural join file_study natural join file_series
    join file_location using(file_id) join file_storage_root using(file_storage_root_id)
  where
    sop_instance_uid in (
      select distinct sop_instance_uid from (
        select distinct sop_instance_uid, count(distinct file_id) from (
          select distinct file_id, sop_instance_uid 
          from
            ctp_file natural join file_sop_common
            natural join file_patient
          where
            visibility is null and project_name = ? and site_name = ?
        ) as foo group by sop_instance_uid order by count desc
      ) as foo 
      where count > 1
    )
    and visibility is null
  ) as foo
order by sop_instance_uid
) as foo
group by collection, site, subj_id, study_instance_uid, series_instance_uid

', ARRAY['collection', 'site'], 
                    ARRAY['collection', 'site', 'subj_id', 'study_instance_uid', 'series_instance_uid', 'count'], ARRAY['duplicates', 'dup_sops', 'hide_dup_sops', 'sops_different_series'], 'posda_files', 'Return a count of duplicate SOP Instance UIDs
')
        ;

            insert into queries
            values ('GetQualifiedCTQPByLikeCollectionSiteWithNoFiles', 'select 
  collection, site, patient_id, qualified
from
  clinical_trial_qualified_patient_id p
where collection like ? and site = ? and qualified and
  not exists (select file_id from file_patient f where f.patient_id = p.patient_id)
group by collection, site, patient_id, qualified', ARRAY['collection_like', 'site'], 
                    ARRAY['collection', 'site', 'patient_id', 'qualified'], ARRAY['clin_qual'], 'posda_files', 'Create An Activity Timepoint

')
        ;

            insert into queries
            values ('PixelTypesWithSOP', 'select
  distinct photometric_interpretation,
  samples_per_pixel,
  bits_allocated,
  bits_stored,
  high_bit,
  coalesce(number_of_frames,1) > 1 as is_multi_frame,
  pixel_representation,
  planar_configuration,
  modality,
  dicom_file_type,
  count(*)
from
  image natural join file_image natural join file_series natural join dicom_file
group by
  photometric_interpretation,
  samples_per_pixel,
  bits_allocated,
  bits_stored,
  high_bit,
  is_multi_frame,
  pixel_representation,
  planar_configuration,
  modality,
  dicom_file_type
order by
  count desc', '{}', 
                    ARRAY['photometric_interpretation', 'samples_per_pixel', 'bits_allocated', 'bits_stored', 'high_bit', 'is_multi_frame', 'pixel_representation', 'planar_configuration', 'modality', 'dicom_file_type', 'count'], ARRAY['all', 'find_pixel_types', 'posda_files'], 'posda_files', 'Get distinct pixel types
')
        ;

            insert into queries
            values ('InsertInitialPatientStatus', 'insert into patient_import_status(
  patient_id, patient_import_status
) values (?, ?)
', ARRAY['patient_id', 'status'], 
                    NULL, ARRAY['Insert', 'NotInteractive', 'PatientStatus'], 'posda_files', 'Insert Initial Patient Status
For use in scripts
Not really intended for interactive use
')
        ;

            insert into queries
            values ('ColumnsInTable', 'select attname as column_name
FROM pg_attribute,pg_class 
WHERE attrelid=pg_class.oid 
AND relname= ?
AND attstattarget <>0; 
', ARRAY['table_name'], 
                    ARRAY['column_name'], ARRAY['AllCollections', 'postgres_stats', 'table_size'], 'posda_queries', 'Get a list of collections and sites
')
        ;

            insert into queries
            values ('PatientStudySeriesHierarchyByCollectionSiteExtMore', 'select distinct
  patient_id,
  study_instance_uid,
  series_instance_uid,
  dicom_file_type,
  modality,
  count (distinct file_id) as num_files,
  min(import_time) as first_loaded,
  max(import_time) as last_loaded
from
  file_study natural join
  ctp_file natural join
  dicom_file natural join
  file_series natural join
  file_patient join
  file_import using(file_id) join
  import_event using(import_event_id)
where 
  file_id in (
    select distinct file_id
    from ctp_file
    where project_name = ? and site_name = ? and
    visibility is null
  )
group by patient_id, study_instance_uid, series_instance_uid,
  dicom_file_type, modality
order by patient_id, study_instance_uid, series_instance_uid', ARRAY['collection', 'site'], 
                    ARRAY['patient_id', 'study_instance_uid', 'series_instance_uid', 'dicom_file_type', 'modality', 'num_files', 'first_loaded', 'last_loaded'], ARRAY['Hierarchy', 'phi_simple', 'simple_phi'], 'posda_files', 'Construct list of files in a collection, site in a Patient, Study, Series Hierarchy')
        ;

            insert into queries
            values ('SubjectsWithDupSopsByCollectionSite', 'select
  distinct collection, site, subj_id, 
  count(distinct file_id) as num_files,
  count(distinct sop_instance_uid) as num_sops,
  min(import_time) as earliest,
  max(import_time) as latest
from (
  select
    distinct project_name as collection,
    site_name as site, patient_id as subj_id,
    file_id, sop_instance_uid, import_time
  from
    ctp_file natural join file_sop_common
    natural join file_patient natural join file_import
    natural join import_event
  where
    sop_instance_uid in (
      select distinct sop_instance_uid from (
        select distinct sop_instance_uid, count(*) from (
          select distinct file_id, sop_instance_uid 
          from
            ctp_file natural join file_sop_common
            natural join file_patient
          where
            project_name = ? and site_name = ?
            and visibility is null
        ) as foo group by sop_instance_uid order by count desc
      ) as foo 
      where count > 1
    )
    and visibility is null
  ) as foo
group by collection, site, subj_id
', ARRAY['collection', 'site'], 
                    ARRAY['collection', 'site', 'subj_id', 'num_sops', 'num_files', 'earliest', 'latest'], ARRAY['dup_sops'], 'posda_files', 'Return a count of duplicate SOP Instance UIDs
')
        ;

            insert into queries
            values ('NonDicomDifferenceReportByEditId', 'select
  distinct report_file_id, count(distinct to_file_path) as num_files
from non_dicom_edit_compare
where subprocess_invocation_id =?
group by report_file_id
order by report_file_id', ARRAY['subprocess_invocation_id'], 
                    ARRAY['report_file_id', 'num_files'], ARRAY['used_in_file_import_into_posda', 'used_in_file_migration', 'non_dicom_edit'], 'posda_files', 'Get count of files relative to storage root')
        ;

            insert into queries
            values ('SeriesSentToIntakeByDate', 'select
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
', ARRAY['from_date', 'to_date'], 
                    ARRAY['send_started', 'duration', 'series_instance_uid', 'destination_host', 'destination_port', 'to_send', 'files_sent', 'invoking_user', 'reason_for_send'], ARRAY['send_to_intake'], 'posda_files', 'List of Series Sent To Intake By Date
')
        ;

            insert into queries
            values ('FileIdsByActivityTimepointId', 'select
 file_id
from
  activity_timepoint_file
where
  activity_timepoint_id = ?', ARRAY['activity_timepoint_id'], 
                    ARRAY['file_id'], ARRAY['activity_timepoint_support'], 'posda_queries', 'Get files in an activity_timepoint')
        ;

            insert into queries
            values ('GetPixelPaddingInfoByCollection', 'select
  distinct modality, pixel_pad, slope, intercept, manufacturer, 
  image_type, pixel_representation as signed, count(*)
from                                           
  file_series natural join file_equipment natural join ctp_file natural join
  file_slope_intercept natural join slope_intercept natural join file_image natural join image
where                                                 
  modality = ''CT'' and project_name = ? and visibility is null
group by 
  modality, pixel_pad, slope, intercept, manufacturer, image_type, signed
', ARRAY['collection'], 
                    ARRAY['modality', 'pixel_pad', 'slope', 'intercept', 'manufacturer', 'image_type', 'signed', 'count'], ARRAY['PixelPadding'], 'posda_files', 'Get Pixel Padding Summary Info
')
        ;

            insert into queries
            values ('AllPublicSignaturesByScanId', 'select distinct element_signature as public_signature
from
  scan_event natural join series_scan
  natural join scan_element natural join element_signature
where
  scan_event_id = ? 
  and not is_private
order by public_signature', ARRAY['scan_id'], 
                    ARRAY['public_signature'], ARRAY['tag_usage'], 'posda_phi', 'List of non-private Element Signatures seen by Scan')
        ;

            insert into queries
            values ('GetCopyFromPublicInfo', 'select
  copy_from_public_id,
  when_row_created,
  who,
  why, 
  num_file_rows_populated as num_files,
  status_of_copy,
  pid_of_running_process
from
  copy_from_public
', '{}', 
                    ARRAY['copy_from_public_id', 'when_row_created', 'who', 'why', 'num_files', 'status_of_copy', 'pid_of_running_process'], ARRAY['bills_test', 'copy_from_public', 'public_posda_consistency'], 'posda_files', 'Add a filter to a tab')
        ;

            insert into queries
            values ('FilesInCollectionSiteForApplicationOfPrivateDisposition', 'select
  distinct file_id, root_path || ''/'' || rel_path as path, 
  patient_id, study_instance_uid, series_instance_uid,
  sop_instance_uid
from
  file_location natural join file_storage_root natural join file_patient
  natural join ctp_file natural join file_study 
  natural join file_sop_common natural join file_series
  
where
  project_name = ? and site_name = ? and visibility is null
', ARRAY['collection', 'site'], 
                    ARRAY['file_id', 'path', 'patient_id', 'study_instance_uid', 'series_instance_uid', 'sop_instance_uid'], ARRAY['by_collection_site', 'find_files'], 'posda_files', 'Get everything you need to negotiate a presentation_context
for all files in a Collection Site
')
        ;

            insert into queries
            values ('HiddenCountsByCollectionSiteDateRangePlus', 'select
  distinct
    patient_id, image_type, dicom_file_type, modality,
    study_date, series_date,
    study_description,
    series_description, study_instance_uid, series_instance_uid,
    manufacturer, manuf_model_name, software_versions,
    count(distinct sop_instance_uid) as num_sops,
    count(distinct file_id) as num_files,
    min(import_time) as earliest,
    max(import_time) as latest
from
  ctp_file join file_patient using(file_id)
  join dicom_file using(file_id)
  join file_series using(file_id)
  join file_sop_common using(file_id)
  join file_study using(file_id)
  join file_equipment using(file_id)
  join file_import using(file_id)
  join import_event using(import_event_id)
  left join file_image using(file_id)
  left join image using (image_id)
where
  file_id in (
    select distinct file_id 
    from file_import natural join import_event natural join ctp_file
    where import_time > ? and import_time < ?
    and project_name = ? and site_name = ? and visibility = ''hidden'')
group by
  patient_id, image_type, dicom_file_type, modality, study_date, 
  series_date, study_description,
  series_description, study_instance_uid, series_instance_uid,
  manufacturer, manuf_model_name, software_versions
order by
  patient_id, study_instance_uid, series_instance_uid, image_type,
  modality, study_date, series_date, study_description,
  series_description,
  manufacturer, manuf_model_name, software_versions
', ARRAY['from', 'to', 'collection', 'site'], 
                    ARRAY['patient_id', 'image_type', 'dicom_file_type', 'modality', 'study_date', 'series_date', 'study_description', 'series_description', 'study_instance_uid', 'series_instance_uid', 'manufacturer', 'manuf_model_name', 'software_versions', 'num_sops', 'num_files', 'earliest', 'latest'], ARRAY['counts', 'count_queries'], 'posda_files', 'Counts query by Collection, Site
')
        ;

            insert into queries
            values ('InsertIntoPatientMappingIntBatch', 'insert into patient_mapping(
  from_patient_id,
  to_patient_id,
  to_patient_name,
  collection_name,
  site_name,
  batch_number,
  date_shift) values (
  ?, ?, ?, ?, ?, ?, interval ?)', ARRAY['from_patient_id', 'to_patient_id', 'to_patient_name', 'collection_name', 'site_name', 'batch_number', 'date_shift'], 
                    '{}', ARRAY['adding_ctp', 'mapping_tables', 'insert_pat_mapping'], 'posda_files', 'Make an entry into the patient_mapping table with batch and interval')
        ;

            insert into queries
            values ('NonDicomPhiReportJsonMetaQuotes', 'select 
  distinct non_dicom_file_type as type, ''<'' ||non_dicom_path || ''>'' as path,
  ''<'' || value || ''>'' as q_value, count(distinct posda_file_id) as num_files
from 
  non_dicom_path_value_occurrance natural join
  non_dicom_path_seen natural join
  value_seen natural join
  non_dicom_file_scan natural join
  phi_non_dicom_scan_instance
where 
  phi_non_dicom_scan_instance_id = ? and file_type = ''json''
group by type, path, q_value
order by type, path, q_value', ARRAY['scan_id'], 
                    ARRAY['type', 'path', 'q_value', 'num_files'], ARRAY['adding_ctp', 'for_scripting', 'non_dicom_phi'], 'posda_phi_simple', 'Simple Phi Report with Meta Quotes')
        ;

            insert into queries
            values ('HideFileWithNoCtp', 'insert into ctp_file(file_id, project_name, trial_name, site_name, visibility)
values(?, ''UNKNOWN'', ''UNKNOWN'', ''UNKNOWN'', ''hidden'')', ARRAY['file_id'], 
                    '{}', ARRAY['ImageEdit', 'NotInteractive'], 'posda_files', 'Hide a file which currently has no ctp_file row

Insert a ctp_file row with:
project_name = ''UNKNOWN''
site_name = ''UNKNOWN''
visibility = ''hidden''
')
        ;

            insert into queries
            values ('GetExistenceClassModalityUniquenessOfReferencedFile', 'select
  distinct file_id,
  project_name as collection,
  site_name as site,
  patient_id,
  dicom_file_type as sop_class,
  modality,
  sop_class_uid,
  series_instance_uid
from
  file_sop_common natural join
  dicom_file natural join
  file_series natural join
  file_patient natural join
  ctp_file 
where
  sop_instance_uid = ? and visibility is null', ARRAY['sop_instance_uid'], 
                    ARRAY['file_id', 'collection', 'site', 'patient_id', 'sop_class', 'modality', 'sop_class_uid', 'series_instance_uid'], ARRAY['LinkageChecks', 'used_in_dose_linkage_check', 'used_in_plan_linkage_check'], 'posda_files', 'Get Information related to uniqueness, modality, sop_class of a file reference by Sop Instance')
        ;

            insert into queries
            values ('InsertFileImport', 'insert into file_import(
  import_event_id, file_id,  file_name
) values (
  currval(''import_event_import_event_id_seq''),?, ?
)
', ARRAY['file_id', 'file_name'], 
                    '{}', ARRAY['NotInteractive', 'Backlog'], 'posda_files', 'Create an import_event')
        ;

            insert into queries
            values ('ImportIntoFileSeries', 'insert into file_series
  (file_id, modality, series_instance_uid,
   series_number, laterality, series_date,
   series_time, performing_phys, protocol_name,
   series_description, operators_name, body_part_examined,
   patient_position, smallest_pixel_value, largest_pixel_value,
   performed_procedure_step_id, performed_procedure_step_start_date,
       performed_procedure_step_start_time,
   performed_procedure_step_desc, performed_procedure_step_comments)
values
  (?, ?, ?,
   ?, ?, ?,
   ?, ?, ?,
   ?, ?, ?,
   ?, ?, ?,
   ?, ?, ?,
   ?, ?)
', ARRAY['file_id', 'modality', 'series_instance_uid', 'series_number', 'laterality', 'series_date', 'series_time', 'performing_phys', 'protocol_name', 'series_description', 'operators_name', 'body_part_examined', 'patient_position', 'smallest_pixel_value', 'largest_pixel_value', 'performed_procedure_step_id', 'performed_procedure_step_start_date', 'performed_procedure_step_start_time', 'performed_procedure_step_desc', 'performed_procedure_step_comments'], 
                    '{}', ARRAY['reimport_queries'], 'posda_files', 'Get file path from id')
        ;

            insert into queries
            values ('FilesByCollectionSiteWithVisibility', 'select
  distinct
  file_id,
  project_name as collection,
  site_name as site,
  patient_id,
  series_instance_uid,
  sop_instance_uid,
  file_id,
  visibility
from
  ctp_file
  join file_patient using(file_id)
  join file_series using(file_id)
  join file_sop_common using(file_id)
where 
  project_name = ?', ARRAY['collection'], 
                    ARRAY['collection', 'site', 'patient_id', 'series_instance_uid', 'sop_instance_uid', 'file_id', 'visibility'], ARRAY['hide_files'], 'posda_files', 'Get List of files for Collection, Site with visibility')
        ;

            insert into queries
            values ('RoisInStructureSetByFileId', 'select file_id, roi_num, roi_name, roi_interpreted_type
from roi natural join file_structure_set where file_id = ?', ARRAY['file_id'], 
                    ARRAY['file_id', 'roi_num', 'roi_name', 'roi_interpreted_type'], ARRAY['Test Case based on Soft-tissue-Sarcoma'], 'posda_files', 'Find All of the Structure Sets In Soft-tissue-Sarcoma')
        ;

            insert into queries
            values ('PublicFileBySopInstanceUid', 'select
  dicom_file_uri as file_path
from
  general_image
where
  sop_instance_uid = ?
', ARRAY['sop_instance_uid'], 
                    ARRAY['file_path'], ARRAY['public', 'used_in_simple_phi'], 'public', 'List of all Series By Collection, Site on Intake
')
        ;

            insert into queries
            values ('CollectionSiteFromTp', 'select distinct
    project_name as collection_name,
    site_name
from
    activity_timepoint_file
    natural join ctp_file
where
    activity_timepoint_id = ?
', ARRAY['activity_timepoint_id'], 
                    ARRAY['collection_name', 'site_name'], ARRAY['activity_timepoint_support'], 'posda_queries', 'Get the collection and site from a TP')
        ;

            insert into queries
            values ('PosdaTotalsWithDateRangeWithHidden', 'select 
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
', ARRAY['start_time', 'end_time'], 
                    ARRAY['project_name', 'site_name', 'num_subjects', 'num_studies', 'num_series', 'total_files'], '{}', 'posda_files', 'Get posda totals by date range
')
        ;

            insert into queries
            values ('InsertIntoCollectionCodes', 'insert into collection_codes(collection_name, collection_code)
values (?, ?)', ARRAY['collection_name', 'collection_code'], 
                    '{}', ARRAY['adding_ctp', 'mapping_tables', 'for_scripting'], 'posda_files', 'Make an entry into the collection_codes table')
        ;

            insert into queries
            values ('MRWithBadModality', 'select distinct
  project_name as collection,
  site_name as site, 
  patient_id,
  series_instance_uid,
  modality,
  dicom_file_type,
  count(distinct file_id) as num_files
from
  file_series natural join ctp_file natural join file_patient
  natural join dicom_file
where 
  dicom_file_type = ''MR Image Storage'' and 
  visibility is null and
  modality != ''MR''
group by
  collection, site, patient_id, series_instance_uid, modality, dicom_file_type
order by
  collection, site, patient_id
', '{}', 
                    ARRAY['collection', 'site', 'patient_id', 'series_instance_uid', 'modality', 'dicom_file_type', 'num_files'], ARRAY['by_series', 'consistency', 'for_bill_series_consistency'], 'posda_files', 'Check a Series for Consistency
')
        ;

            insert into queries
            values ('GetPublicTagNameAndVrBySignature', 'select
  name,
  vr
from dicom_element
where tag = ?
', ARRAY['tag'], 
                    ARRAY['name', 'vr'], ARRAY['DispositionReport', 'NotInteractive', 'used_in_reconcile_tag_names'], 'dicom_dd', 'Get the relevant features of a private tag by signature
Used in DispositionReport.pl - not for interactive use
')
        ;

            insert into queries
            values ('FileTypeAndIsDicom', 'select file_type, is_dicom_file
from file
where file_id = ?
', ARRAY['file_id'], 
                    ARRAY['file_type', 'is_dicom_file'], ARRAY['NotInteractive', 'used_in_background_processing'], 'posda_files', 'Get the file_type of a file, by file_id
')
        ;

            insert into queries
            values ('SimplePhiReportAllPublicOnlyMetaQuote', 'select 
  distinct ''<'' || element_sig_pattern || ''>''  as element, length(value) as val_length,
  vr, ''<'' || value || ''>'' as q_value, tag_name as description, ''k'' as disp, count(*) as num_series
from element_value_occurance natural join element_seen natural join value_seen
where 
  phi_scan_instance_id = ? and not is_private
group by element_sig_pattern, vr, value, val_length, description
order by vr, element, val_length', ARRAY['scan_id'], 
                    ARRAY['element', 'vr', 'disp', 'q_value', 'description', 'num_series'], ARRAY['adding_ctp', 'for_scripting', 'phi_reports'], 'posda_phi_simple', 'Simple Phi Report with Meta Quotes')
        ;

            insert into queries
            values ('FastCurrentPatientStatii', 'select 
  patient_id,
  patient_import_status
from 
  patient_import_status
', '{}', 
                    ARRAY['patient_id', 'patient_import_status'], ARRAY['counts', 'patient_status', 'for_bill_counts'], 'posda_files', 'Get the current status of all patients')
        ;

            insert into queries
            values ('MakePosdaFileReadyToProcess', 'update file
  set ready_to_process = true
where file_id = ?', ARRAY['file_id'], 
                    '{}', ARRAY['NotInteractive', 'Backlog', 'used_in_file_import_into_posda'], 'posda_files', 'Lock the file table in posda_files')
        ;

            insert into queries
            values ('WhatHasComeInRecentlyWithSubjectByCollectionLike', 'select
  distinct collection, site, subj, date_trunc(?, time_received) as time,
  count(*) as number_of_files,
  max(time_entered - time_received) as max_delay,
  min(time_entered - time_received) as min_delay
from request natural join submitter
where time_received > ? and time_received < ?
and collection like ?
group by collection, site, subj, time order by time desc, collection, site, subj', ARRAY['interval', 'from', 'to', 'collection_like'], 
                    ARRAY['collection', 'site', 'subj', 'time', 'number_of_files', 'max_delay', 'min_delay'], ARRAY['NotInteractive', 'Backlog', 'Backlog Monitor', 'backlog_round_history'], 'posda_backlog', 'Summary of rounds')
        ;

            insert into queries
            values ('NumFilesInSeries', 'select count(distinct file_id) as num_files from file_series natural join ctp_file where 
series_instance_uid = ? and visibility is null', ARRAY['series_instance_uid'], 
                    ARRAY['num_files'], ARRAY['bills_test'], 'posda_files', 'Get number of files in series')
        ;

            insert into queries
            values ('ContourInfoByRoiIdAndSopInst', 'select
  contour_file_offset,
  contour_length,
  contour_digest,
  num_points,
  contour_type
from
 file_roi_image_linkage 
where
  linked_sop_instance_uid =? and roi_id = ?
', ARRAY['linked_sop_instance_uid', 'roi_id'], 
                    ARRAY['contour_file_offset', 'contour_length', 'contour_digest', 'num_points', 'contour_type'], ARRAY['LinkageChecks', 'used_in_struct_linkage_check'], 'posda_files', 'Get list of Roi with info by file_id

')
        ;

            insert into queries
            values ('AreVisibleFilesMarkedAsBadOrUnreviewedInSeriesBad', 'select 
  distinct project_name as collection,
  site_name as site,
  patient_id,
  series_instance_uid,
  dicom_file_type,
  modality,
  review_status,
  processing_status,
  count(distinct file_id) as num_files
from 
  dicom_file natural join 
  file_series natural join 
  file_patient natural join
  ctp_file join 
  image_equivalence_class using(series_instance_uid)
where
  series_instance_uid = ?
  and visibility is null and 
  review_status != ''Good'' and
  review_status != ''PassThrough''
group by
  collection,
  site,
  patient_id,
  series_instance_uid,
  dicom_file_type,
  modality,
  review_status,
  processing_status', ARRAY['series_instance_uid'], 
                    ARRAY['collection', 'site', 'patient_id', 'series_instance_uid', 'dicom_file_type', 'modality', 'review_status', 'processing_status', 'num_files'], ARRAY['find_series', 'equivalence_classes', 'consistency', 'visual_review_results', 'hide_events'], 'posda_files', 'Get visual review status report by series for Collection, Site')
        ;

            insert into queries
            values ('ListOfQueriesPerformed', 'select
  query_invoked_by_dbif_id as id,
  query_name,
  query_end_time - query_start_time as duration,
  invoking_user as invoked_by,
  query_start_time as at, 
  number_of_rows
from
  query_invoked_by_dbif
', '{}', 
                    ARRAY['id', 'query_name', 'duration', 'invoked_by', 'at', 'number_of_rows'], ARRAY['AllCollections', 'q_stats'], 'posda_queries', 'Get a list of collections and sites
')
        ;

            insert into queries
            values ('DifferenceReportByEditId', 'select
  distinct short_report_file_id, long_report_file_id, count(distinct to_file_path) as num_files
from dicom_edit_compare
where subprocess_invocation_id =?
group by short_report_file_id, long_report_file_id order by short_report_file_id', ARRAY['subprocess_invocation_id'], 
                    ARRAY['short_report_file_id', 'long_report_file_id', 'num_files'], ARRAY['used_in_file_import_into_posda', 'used_in_file_migration'], 'posda_files', 'Get count of files relative to storage root')
        ;

            insert into queries
            values ('GetListCollectionsWithNoDefinedCounts', 'select distinct collection
from submitter s
where collection not in (
  select collection from collection_count_per_round c
  where s.collection = c.collection
)
', '{}', 
                    ARRAY['collection'], ARRAY['NotInteractive', 'Backlog', 'Backlog Monitor'], 'posda_backlog', 'Get a list of all collections in backlog with no defined counts')
        ;

            insert into queries
            values ('FindNumUnpopulatedPets', 'select
  count(distinct file_id) as num_unimported_pets
from file_location natural join file_storage_root
where file_id in
(
  select distinct file_id from dicom_file df
  where dicom_file_type = ''Positron Emission Tomography Image Storage''
  and not exists (select file_id from file_pt_image pti where pti.file_id = df.file_id)
)', '{}', 
                    ARRAY['num_unimported_pets'], ARRAY['populate_posda_files', 'bills_test'], 'posda_files', 'Gets count of all files which are PET''s which haven''t been imported into file_pt_image yet.

')
        ;

            insert into queries
            values ('GetDicomEditCompareFromFiles', 'select 
  file_id,
  project_name,
  visibility
from 
  file natural left join ctp_file
where
  file_id in (
    select file_id from file f, dicom_edit_compare dec
    where f.digest = dec.from_file_digest and subprocess_invocation_id = ?
  )', ARRAY['subprocess_invocation_id'], 
                    ARRAY['file_id', 'project_name', 'visibility'], ARRAY['adding_ctp', 'for_scripting'], 'posda_files', 'Get a list of from files from the dicom_edit_compare table for a particular edit instance, with visibility

NB: project_name will be null if there is no ctp_file row (so to hide the file you need to create a row with
       project_name = ''UNKNOWN'', site_name = ''UNKNOWN'' and visibility = ''hidden'' (if you want to hide the file)')
        ;

            insert into queries
            values ('UpdateCountsDb', 'insert into totals_by_collection_site(
  count_report_id,
  collection_name, site_name,
  num_subjects, num_studies, num_series, num_sops
) values (
  currval(''count_report_count_report_id_seq''),
  ?, ?,
  ?, ?, ?, ?
)
', ARRAY['project_name', 'site_name', 'num_subjects', 'num_studies', 'num_series', 'num_files'], 
                    NULL, ARRAY['intake', 'posda_counts'], 'posda_counts', '')
        ;

            insert into queries
            values ('GetEditStatusByEditId', 'select
  subprocess_invocation_id as id,
  start_creation_time, end_creation_time - start_creation_time as duration,
  number_edits_scheduled as to_edit,
  number_compares_with_diffs as changed,
  number_compares_without_diffs as not_changed,
  current_disposition as disposition,
  dest_dir
from
  dicom_edit_compare_disposition
where
  subprocess_invocation_id = ?
order by start_creation_time desc', ARRAY['edit_id'], 
                    ARRAY['id', 'start_creation_time', 'duration', 'to_edit', 'changed', 'not_changed', 'disposition', 'dest_dir'], ARRAY['adding_ctp', 'find_patients', 'series_selection', 'check_edits', 'edit_status'], 'posda_files', 'Get List of visible patients with CTP data')
        ;

            insert into queries
            values ('FilesByScanValueLikeTag', 'select
  distinct series_instance_uid,
  series_scanned_file as file, 
  element_signature, value, sequence_level,
  item_number
from
  scan_event natural join series_scan natural join seen_value
  natural join element_signature natural join 
  scan_element natural left join sequence_index
where
  scan_event_id = ? and value like ? and element_signature = ?
order by series_instance_uid, file
', ARRAY['scan_id', 'value', 'tag'], 
                    ARRAY['series_instance_uid', 'file', 'element_signature', 'value', 'sequence_level', 'item_number'], ARRAY['tag_usage', 'phi_review'], 'posda_phi', 'Find out where specific value, tag combinations occur in a scan
')
        ;

            insert into queries
            values ('FilesByTagWithValue', 'select
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
', ARRAY['tag'], 
                    ARRAY['series_instance_uid', 'file', 'element_signature', 'value'], ARRAY['tag_usage'], 'posda_phi', 'Find out where specific value, tag combinations occur in a scan
')
        ;

            insert into queries
            values ('RawFilesByDateRange', 'select 
  file_type, max(file_id) as max_file_id, min(file_id) as min_file_id, 
  count(*) as num_files, max(size) as largest, min(size) as smallest,
  sum(size) as total_size, avg(size) as avg_size
from file
where file_id in (
  select
    file_id from (
      select
        distinct file_id, date_trunc(?, min(import_time)) as load_week
      from
        file_import natural join import_event
      group by file_id
  ) as foo
  where
    load_week >=? and load_week <  ?
) 
group by file_type', ARRAY['date_type', 'from', 'to'], 
                    ARRAY['file_type', 'max_file_id', 'min_file_id', 'num_files', 'largest', 'smallest', 'total_size', 'avg_size'], ARRAY['downloads_by_date'], 'posda_files', 'Counts query by Collection, Site
')
        ;

            insert into queries
            values ('ListOfFirstNFilesByImportEventId', 'select
  file_id, root_path || ''/'' || rel_path as path
from
  file_storage_root natural join file_location
where file_id in (
  select file_id from file_import where import_event_id = ?
  limit ?
)', ARRAY['import_event_id', 'limit'], 
                    ARRAY['file_id', 'path'], ARRAY['import_events', 'QIN-GBM-DSC-MRI-DRO/Barrow'], 'posda_files', 'Counts query by Collection, Site
')
        ;

            insert into queries
            values ('AddNewDataToRoiTable', 'update roi set
  max_x = ?,
  max_y = ?,
  max_z = ?,
  min_x = ?,
  min_y = ?,
  min_z = ?,
  roi_interpreted_type = ?,
  roi_obser_desc = ?,
  roi_obser_label = ?
where
  roi_id = ?', ARRAY['max_x', 'max_y', 'max_z', 'min_x', 'min_y', 'min_z', 'roi_interpreted_type', 'roi_obser_desc', 'roi_obser_label', 'roi_id'], 
                    '{}', ARRAY['NotInteractive', 'used_in_processing_structure_set_linkages'], 'posda_files', 'Get the file_storage root for newly created files')
        ;

            insert into queries
            values ('FindInconsistentSeriesIgnoringTime', 'select series_instance_uid from (
select distinct series_instance_uid, count(*) from (
  select distinct
    series_instance_uid, modality, series_number, laterality, series_date,
    performing_phys, protocol_name, series_description,
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
    performing_phys, protocol_name, series_description,
    operators_name, body_part_examined, patient_position,
    smallest_pixel_value, largest_pixel_value, performed_procedure_step_id,
    performed_procedure_step_start_date, performed_procedure_step_start_time,
    performed_procedure_step_desc, performed_procedure_step_comments
) as foo
group by series_instance_uid
) as foo
where count > 1
', ARRAY['collection'], 
                    ARRAY['series_instance_uid'], ARRAY['consistency', 'find_series', 'series_consistency'], 'posda_files', 'Find Inconsistent Series
')
        ;

            insert into queries
            values ('AgesStudyDatesSeriesByCollection', 'select
  distinct patient_id, study_date, patient_age, series_instance_uid, modality
from
  file_patient natural join file_series natural join file_study natural join ctp_file
where
  project_name = ? and visibility is null

', ARRAY['collection'], 
                    ARRAY['patient_id', 'study_date', 'patient_age', 'series_instance_uid', 'modality'], ARRAY['meta', 'test', 'hello', 'query_tabs', 'bills_test'], 'posda_files', 'Add a filter to a tab')
        ;

            insert into queries
            values ('UpdateNonDicomFileTypeSubTypeCollectionSiteSubjectById', 'update non_dicom_file set
  file_type = ?,
  file_sub_type = ?,
  collection = ?,
  site = ?,
  subject = ?
where file_id = ?', ARRAY['file_type', 'file_sub_type', 'collection', 'site', 'subject', 'file_id'], 
                    '{}', ARRAY['adding_ctp', 'for_scripting', 'non_dicom_import'], 'posda_files', 'Get stuff from non_dicom_file by id
')
        ;

            insert into queries
            values ('WhereSopSits', 'select distinct
  project_name as collection,
  site_name as site,
  patient_id,
  study_instance_uid,
  series_instance_uid,
  sop_instance_uid
from
  file_patient natural join
  file_study natural join
  file_series natural join
  file_sop_common natural join
  ctp_file
where file_id in (
  select
    distinct file_id
  from
    file_sop_common natural join ctp_file
  where
    sop_instance_uid = ? and visibility is null
)
', ARRAY['sop_instance_uid'], 
                    ARRAY['collection', 'site', 'patient_id', 'study_instance_uid', 'series_instance_uid'], ARRAY['posda_files', 'sops', 'BySopInstance'], 'posda_files', 'Get Collection, Site, Patient, Study Hierarchy in which SOP resides
')
        ;

            insert into queries
            values ('SimplePhiScanStatusInProcess', 'select
  phi_scan_instance_id as id,
  start_time,
  now() - start_time as duration,
  description,
  num_series as to_scan,
  num_series_scanned as scanned,
  (((now() - start_time) / num_series_scanned) * (num_series -
  num_series_scanned)) + now() as projected_completion,
  (cast(num_series_scanned as float) / 
    cast(num_series as float)) * 100.0 as percentage,
  file_query
from
  phi_scan_instance
where
   num_series > num_series_scanned
   and num_series_scanned > 0
order by id
', '{}', 
                    ARRAY['id', 'description', 'start_time', 'duration', 'to_scan', 'scanned', 'percentage', 'projected_completion', 'file_query'], ARRAY['tag_usage', 'simple_phi', 'phi_status', 'scan_status'], 'posda_phi_simple', 'Status of PHI scans
')
        ;

            insert into queries
            values ('InsertIntoPatientMappingIntNoBatch', 'insert into patient_mapping(
  from_patient_id,
  to_patient_id,
  to_patient_name,
  collection_name,
  site_name,
  date_shift) values (
  ?, ?, ?, ?, ?, interval ?)', ARRAY['from_patient_id', 'to_patient_id', 'to_patient_name', 'collection_name', 'site_name', 'date_shift'], 
                    '{}', ARRAY['adding_ctp', 'mapping_tables', 'insert_pat_mapping'], 'posda_files', 'Make an entry into the patient_mapping table with no batch and interval')
        ;

            insert into queries
            values ('DupSopsReceivedBetweenDatesByCollection', 'select
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
', ARRAY['start_time', 'end_time', 'collection'], 
                    ARRAY['project_name', 'site_name', 'patient_id', 'study_instance_uid', 'series_instance_uid', 'num_sops', 'num_files', 'num_uploads', 'first_loaded', 'last_loaded'], ARRAY['receive_reports'], 'posda_files', 'Series received between dates with duplicate sops
')
        ;

            insert into queries
            values ('GetFileIdVisibilityByPatientId', 'select distinct file_id, visibility
from file_patient natural left join ctp_file
where patient_id = ?', ARRAY['patient_id'], 
                    ARRAY['file_id', 'visibility'], ARRAY['ImageEdit', 'edit_files'], 'posda_files', 'Get File id and visibility for all files in a series')
        ;

            insert into queries
            values ('GetFromFileIdGivenToFileId', 'select file_id as from_file_id from file where digest = (
select from_file_digest as digest from dicom_edit_compare where to_file_digest = (select digest as to_file_digest from file where file_id = ?))', ARRAY['to_file_id'], 
                    ARRAY['from_file_id'], ARRAY['edit_status'], 'posda_files', 'Get List of visible patients with CTP data')
        ;

            insert into queries
            values ('UpdateNonDicomFileById', 'update non_dicom_file set
  file_type = ?, 
  file_sub_type = ?, 
  collection = ?,
  site = ?,
  subject = ?,
  visibility = ?,
  date_last_categorized = now()
where 
  file_id = ?', ARRAY['file_type', 'file_sub_type', 'collection', 'site', 'subject', 'visibility', 'file_id'], 
                    '{}', ARRAY['radcomp'], 'posda_files', 'Add a filter to a tab')
        ;

            insert into queries
            values ('GetSimplePhiScanId', 'select currval(''phi_scan_instance_phi_scan_instance_id_seq'') as id', '{}', 
                    ARRAY['id'], ARRAY['used_in_simple_phi', 'NotInteractive'], 'posda_phi_simple', 'Create a new Simple PHI scan')
        ;

            insert into queries
            values ('DistinctSopsInCollectionSitePublicWithFile', 'select
  distinct i.sop_instance_uid, i.dicom_file_uri
from
  general_image i,
  trial_data_provenance tdp
where
  i.trial_dp_pk_id = tdp.trial_dp_pk_id and
  tdp.project = ? and tdp.dp_site_name = ?
order by sop_instance_uid
', ARRAY['collection', 'site'], 
                    ARRAY['sop_instance_uid', 'dicom_file_uri'], ARRAY['by_collection', 'files', 'intake', 'sops', 'compare_collection_site'], 'public', 'Get Distinct SOPs in Collection with number files
')
        ;

            insert into queries
            values ('HowManyFilesHiddenInCopyFromPublic', 'select
  count(*) as num_hidden
from file_copy_from_public c, ctp_file p
where
  c.copy_from_public_id = ? and
  (p.file_id = c.replace_file_id and p.visibility is not null) ', ARRAY['copy_from_public_id'], 
                    ARRAY['num_hidden'], ARRAY['bills_test', 'copy_from_public'], 'posda_files', 'Add a filter to a tab')
        ;

            insert into queries
            values ('QueriesRunning', 'select 
  datname, pid,
  now() - backend_start as time_backend_running,
  now() - query_start as time_query_running, 
  now() - state_change as time_since_state_change,
  state
from pg_stat_activity
  order by datname, state', '{}', 
                    ARRAY['datname', 'pid', 'time_backend_running', 'time_query_running', 'time_since_state_change', 'state'], ARRAY['AllCollections', 'postgres_stats', 'postgres_query_stats'], 'posda_backlog', 'Get a list of collections and sites
')
        ;

            insert into queries
            values ('FindQueryNameMatching', 'select
  distinct name
from
  queries
where
  name ~ ?
order by name', ARRAY['name_matching'], 
                    ARRAY['name'], ARRAY['meta', 'test', 'hello'], 'posda_queries', 'Find all queries with name matching arg')
        ;

            insert into queries
            values ('FromFilesVisibilitySummaryByEditId', 'select
  distinct visibility, count(distinct file_id) as num_files
from ctp_file
where 
  file_id in (
    select distinct file_id from file f, dicom_edit_compare dec
     where f.digest = dec.from_file_digest and 
        subprocess_invocation_id = ?
  )
group by visibility', ARRAY['subprocess_invocation_id'], 
                    ARRAY['visibility', 'num_files'], ARRAY['adding_ctp', 'find_patients', 'series_selection', 'check_edits'], 'posda_files', 'Get List of visible patients with CTP data')
        ;

            insert into queries
            values ('GetFilesAndSopsByStudy', 'select 
  distinct patient_id,
  study_instance_uid,
  series_instance_uid,
  sop_instance_uid,
  file_id, 
  root_path || ''/'' || rel_path as path
from
  file_patient natural join
  file_study natural join
  file_series natural join
  file_sop_common natural join
  file_location natural join
  file_storage_root natural left join
  ctp_file
where 
  study_instance_uid = ? and
  visibility is null', ARRAY['study_instance_uid'], 
                    ARRAY['patient_id', 'study_instance_uid', 'series_instance_uid', 'sop_instance_uid', 'file_id', 'path'], ARRAY['ImageEdit', 'edit_files'], 'posda_files', 'Get File id and visibility for all files in a series')
        ;

            insert into queries
            values ('GetVisibleFilePathPosdaBySopInst', 'select
  root_path || ''/'' || rel_path as path
from
  file_location natural join file_storage_root
where
  file_id in (
    select file_id from file_sop_common natural join ctp_file
    where sop_instance_uid = ? and visibility is null
)', ARRAY['sop_instance_uid'], 
                    ARRAY['path'], ARRAY['posda_files', 'sops', 'BySopInstance'], 'posda_files', 'Get Collection, Site, Patient, Study Hierarchy in which SOP resides
')
        ;

            insert into queries
            values ('GetDciodvfyWarningUncat', 'select
  dciodvfy_warning_id as id
from 
  dciodvfy_warning
where
  warning_type = ''Uncategorized''
  and warning_text = ?', ARRAY['warning_text'], 
                    ARRAY['id'], ARRAY['NotInteractive', 'used_in_dciodvfy'], 'posda_phi_simple', 'Get an dciodvfy_warnings row by warning_text (if present)')
        ;

            insert into queries
            values ('GetDupContourCounts', 'select 
  distinct file_id, count(*) as num_dup_contours
from
  file_roi_image_linkage 
where 
  contour_digest in (
  select contour_digest
  from (
    select 
      distinct contour_digest, count(*)
    from
      file_roi_image_linkage group by contour_digest
  ) as foo
  where count > 1
) group by file_id order by num_dup_contours desc', '{}', 
                    ARRAY['file_id', 'num_dup_contours'], ARRAY['Structure Sets', 'sops', 'LinkageChecks', 'dup_contours'], 'posda_files', 'Get list of plan which reference unknown SOPs

')
        ;

            insert into queries
            values ('StudyHierarchyByStudyUID', 'select distinct
  study_instance_uid, study_description,
  series_instance_uid, series_description,
  modality,
  count(distinct sop_instance_uid) as number_of_sops
from
  file_study natural join ctp_file natural join file_series natural join file_sop_common
where study_instance_uid = ? and visibility is null
group by
  study_instance_uid, study_description,
  series_instance_uid, series_description, modality', ARRAY['study_instance_uid'], 
                    ARRAY['study_instance_uid', 'study_description', 'series_instance_uid', 'series_description', 'modality', 'number_of_sops'], ARRAY['by_study', 'Hierarchy'], 'posda_files', 'Show List of Study Descriptions, Series UID, Series Descriptions, and Count of SOPS for a given Study Instance UID')
        ;

            insert into queries
            values ('PrivateTagCountReport', 'select 
  distinct element_signature, vr, count(*) as times_seen,
  count(distinct value) as num_distinct_values 
from
  element_signature natural join scan_element natural join seen_value
where
  is_private
group by element_signature, vr
order by element_signature, vr, times_seen, num_distinct_values;
', '{}', 
                    ARRAY['element_signature', 'vr', 'times_seen', 'num_distinct_values'], ARRAY['postgres_status', 'PrivateTagKb'], 'posda_phi', 'Get List of all Private Tags ever scanned with occurance and distinct value counts')
        ;

            insert into queries
            values ('GetAttachmentFiles', 'select 
  fl.file_id,
  root_path || ''/'' || rel_path as path,
  ndf.file_type as ext
from
  non_dicom_file ndf,
  file_location as fl natural join file_storage_root,
  non_dicom_attachments a
where
  a.non_dicom_file_id = ndf.file_id and 
  a.non_dicom_file_id = fl.file_id and
  ndf.collection = ?', ARRAY['collection'], 
                    ARRAY['file_id', 'path', 'ext'], ARRAY['radcomp'], 'posda_files', 'Add a filter to a tab')
        ;

            insert into queries
            values ('GetSsByCollectionSite', 'select
  distinct project_name as collection,
  site_name as site,
  patient_id, file_id
from
  ctp_file natural join file_patient
where file_id in (
 select distinct file_id from file_structure_set
)
and project_name = ? and site_name = ? and visibility is null
order by collection, site, patient_id, file_id
', ARRAY['collection', 'site'], 
                    ARRAY['collection', 'site', 'patient_id', 'file_id'], ARRAY['Structure Sets', 'sops', 'LinkageChecks', 'struct_linkages'], 'posda_files', 'Get list of plan which reference unknown SOPs

')
        ;

            insert into queries
            values ('GetDciodvfyWarningDubious', 'select
  dciodvfy_warning_id as id
from 
  dciodvfy_warning
where
  warning_type = ''DubiousValue''
  and warning_tag = ?
  and warning_desc = ?
  and warning_value = ?
  and warning_reason = ?', ARRAY['warning_tag', 'warning_desc', 'warning_value', 'warning_reason'], 
                    ARRAY['id'], ARRAY['NotInteractive', 'used_in_dciodvfy'], 'posda_phi_simple', 'Get an dciodvfy_warnings row by warning_text (if present)')
        ;

            insert into queries
            values ('GetDciodvfyWarningId', 'select currval(''dciodvfy_warning_dciodvfy_warning_id_seq'') as id', '{}', 
                    ARRAY['id'], ARRAY['NotInteractive', 'used_in_dciodvfy'], 'posda_phi_simple', 'Get id of recently created dciodvfy_warnings row')
        ;

            insert into queries
            values ('AllProcessedManifests', 'select
  distinct file_id, cm_collection, cm_site, cm_patient_id, sum(cm_num_files) as total_files
from
  ctp_manifest_row
group by file_id, cm_collection, cm_site, cm_patient_id', '{}', 
                    ARRAY['file_id', 'cm_collection', 'cm_site', 'cm_patient_id', 'total_files'], ARRAY['activity_timepoint_support', 'manifests'], 'posda_files', 'Create An Activity Timepoint

')
        ;

            insert into queries
            values ('DiskSpaceByCollectionSiteSummary', 'select
  distinct project_name as collection, site_name as site, sum(size) as total_bytes
from
  ctp_file natural join file
where
  file_id in (
  select distinct file_id
  from ctp_file
  )
group by project_name, site_name
order by total_bytes
', '{}', 
                    ARRAY['collection', 'site', 'total_bytes'], ARRAY['by_collection', 'posda_files', 'storage_used', 'summary'], 'posda_files', 'Get disk space used for all collections, sites
')
        ;

            insert into queries
            values ('GetDciodvfyErrorAttrSpec', 'select
  dciodvfy_error_id as id
from 
  dciodvfy_error
where
  error_type = ''AttributeSpecificError''
  and error_tag = ?
  and error_subtype= ?', ARRAY['error_tag', 'error_subtype'], 
                    ARRAY['id'], ARRAY['NotInteractive', 'used_in_dciodvfy'], 'posda_phi_simple', 'Get dciodvfy_errors row where subtype = AttributeSpecificError')
        ;

            insert into queries
            values ('GetFileIdByDigest', 'select file_id from file where digest = ?', ARRAY['digest'], 
                    ARRAY['file_id'], ARRAY['import_events', 'QIN-GBM-DSC-MRI-DRO/Barrow'], 'posda_files', 'Counts query by Collection, Site
')
        ;

            insert into queries
            values ('AllProcessedManifestsByCollectionLikeWithPatientAndQualAndDate', 'select
  distinct file_id, import_time as date, cm_collection, collection, cm_site, site, cm_patient_id, qualified,
  sum(cm_num_files) as total_files
from
  ctp_manifest_row m natural join file_import natural join import_event, clinical_trial_qualified_patient_id c
where
  cm_collection like ? and m.cm_patient_id = c.patient_id
group by file_id, date, cm_collection, collection, cm_site, site, cm_patient_id, qualified
order by date', ARRAY['collection_like'], 
                    ARRAY['file_id', 'date', 'cm_collection', 'collection', 'cm_site', 'site', 'cm_patient_id', 'qualified', 'total_files'], ARRAY['activity_timepoint_support', 'manifests'], 'posda_files', 'Create An Activity Timepoint

')
        ;

            insert into queries
            values ('PopulatePixelInfoInDicomFile', 'update dicom_file set
  has_pixel_data = true,
  pixel_data_digest = ?,
  pixel_data_offset = ?,
  pixel_data_length = ?
where file_id = ?', ARRAY['pixel_data_digest', 'pixel_data_offset', 'pixel_data_length', 'file_id'], 
                    '{}', ARRAY['adding_pixels_to_dicom_file'], 'posda_files', 'see name')
        ;

            insert into queries
            values ('GetDocxToConvert', 'select 
  file_id, file_type, file_sub_type, collection, site, subject, visibility, date_last_categorized
from
  non_dicom_file
where
 collection = ? and file_type = ''docx'' and visibility is null', ARRAY['collection'], 
                    ARRAY['file_id', 'file_type', 'file_sub_type', 'collection', 'site', 'subject', 'visibility', 'date_last_categorized'], ARRAY['radcomp'], 'posda_files', 'Add a filter to a tab')
        ;

            insert into queries
            values ('GetImportEventId', 'select  currval(''import_event_import_event_id_seq'') as id
', '{}', 
                    ARRAY['id'], ARRAY['NotInteractive', 'Backlog', 'used_in_file_import_into_posda'], 'posda_files', 'Get posda file id of created import_event row')
        ;

            insert into queries
            values ('KnownBlankImagesInSeries', 'select distinct pixel_digest, count(*) as num_files from (
  select file_id, digest as pixel_digest
  from
    file_image join image using (image_id) join unique_pixel_data using (unique_pixel_data_id)
  where file_id in (select file_id from file_series natural join ctp_file where series_instance_uid = ?)
)
as foo group by pixel_digest', ARRAY['series_instance_uid'], 
                    ARRAY['pixel_digest', 'num_files'], ARRAY['by_series'], 'posda_files', 'List of SOPs, files, and import times in a series
')
        ;

            insert into queries
            values ('InsertIntoPatientMappingNew', 'insert into patient_mapping(
  from_patient_id,
  to_patient_id,
  to_patient_name,
  collection_name,
  site_name,
  batch_number,
  date_shift,
  diagnosis_date, baseline_date, uid_root) values (
  ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)', ARRAY['from_patient_id', 'to_patient_id', 'to_patient_name', 'collection_name', 'site_name', 'batch_number', 'date_shift', 'diagnosis_date', 'baseline_date', 'uid_root'], 
                    '{}', ARRAY['adding_ctp', 'mapping_tables', 'insert_pat_mapping', 'non_dicom_edit'], 'posda_files', 'Make an entry into the patient_mapping table with no batch and interval')
        ;

            insert into queries
            values ('GetNonDicomFiles', 'select 
  file_id, file_type, file_sub_type, collection, site, subject, visibility, date_last_categorized
from
  non_dicom_file
where
  visibility is null
', '{}', 
                    ARRAY['file_id', 'file_type', 'file_sub_type', 'collection', 'site', 'subject', 'visibility', 'date_last_categorized'], ARRAY['radcomp'], 'posda_files', 'Add a filter to a tab')
        ;

            insert into queries
            values ('FindingCtFilesWithImageProblem', 'select distinct file_id, root_path || ''/'' || rel_path as path
from (
  select file_id, image_id 
  from file natural left join file_image
  where file_id in (
    select
       distinct file_id from file_import natural join import_event
       natural join ctp_file natural join file_series
    where import_time > ''2018-09-17'' and visibility is null and
      project_name = ''Exceptional-Responders'' and modality = ''CT''
  )
) as foo natural join file_location natural join file_storage_root
where image_id is null
', '{}', 
                    ARRAY['file_id', 'path'], ARRAY['Exceptional-Responders_NCI_Oct2018_curation'], 'posda_files', 'Find files which have unique_pixel_data_id but no image_id, then find out where the hell they came from')
        ;

            insert into queries
            values ('GetValueForTagAllScans', 'select
  distinct element_signature as tag, value
from
  scan_element natural join series_scan natural join
  seen_value natural join element_signature
where element_signature = ?
order by value', ARRAY['tag'], 
                    ARRAY['tag', 'value'], ARRAY['tag_values'], 'posda_phi', 'Find Values for a given tag for all scanned series in a phi scan instance
')
        ;

            insert into queries
            values ('GetPosdaFileStorageRoots', 'select
 file_storage_root_id as id, root_path as root, current, storage_class
from
  file_storage_root
', '{}', 
                    ARRAY['id', 'root', 'current', 'storage_class'], ARRAY['NotInteractive', 'Backlog'], 'posda_files', 'Get Posda File Storage Roots')
        ;

            insert into queries
            values ('CreateEquivalenceClassNew', 'insert into image_equivalence_class(
  series_instance_uid,
  equivalence_class_number,
  visual_review_instance_id,
  processing_status
) values (
  ?, ?, ?, ''Preparing''
)
', ARRAY['series_instance_uid', 'equivalence_class_number', 'visual_review_instance_id'], 
                    '{}', ARRAY['consistency', 'find_series', 'equivalence_classes', 'NotInteractive'], 'posda_files', 'For building series equivalence classes')
        ;

            insert into queries
            values ('FilesByScanWithValue', 'select
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
', ARRAY['scan_id', 'tag'], 
                    ARRAY['series_instance_uid', 'file', 'element_signature', 'value'], ARRAY['tag_usage'], 'posda_phi', 'Find out where specific value, tag combinations occur in a scan
')
        ;

            insert into queries
            values ('AbreviatedCountsByCollectionLike', 'select
  distinct
    project_name as collection, site_name as site,
    patient_id, 
    count(distinct sop_instance_uid) as num_sops,
    count(distinct file_id) as num_files,
    min(import_time) as earliest,
    max(import_time) as latest
from
  ctp_file join file_patient using(file_id)
  join dicom_file using(file_id)
  join file_series using(file_id)
  join file_sop_common using(file_id)
  join file_study using(file_id)
  join file_equipment using(file_id)
  join file_import using(file_id)
  join import_event using(import_event_id)
  left join file_image using(file_id)
  left join image using (image_id)
where
  file_id in (
    select file_id 
    from file_import natural join import_event
  ) and project_name like ? and visibility is null
group by
  collection, site, patient_id
order by
  collection, site, patient_id
', ARRAY['collection_like'], 
                    ARRAY['collection', 'site', 'patient_id', 'num_sops', 'num_files', 'earliest', 'latest'], ARRAY['counts', 'count_queries'], 'posda_files', 'Counts query by Collection like pattern
')
        ;

            insert into queries
            values ('GetElementByPrivateDispositionSimple', 'select
  element_sig_pattern as element_signature, private_disposition as disposition
from
  element_seen
where
  is_private and private_disposition = ?
', ARRAY['private_disposition'], 
                    ARRAY['element_signature', 'disposition'], ARRAY['NotInteractive', 'ElementDisposition'], 'posda_phi_simple', 'Get List of Private Elements By Disposition')
        ;

            insert into queries
            values ('GetSubmissionFormsToConvert', 'select 
  file_id, file_type, file_sub_type, collection, site, subject, visibility, date_last_categorized
from
  non_dicom_file
where
 collection = ? and file_type = ''docx'' and file_sub_type = ''radcomp data submittal form'' and visibility is null', ARRAY['collection'], 
                    ARRAY['file_id', 'file_type', 'file_sub_type', 'collection', 'site', 'subject', 'visibility', 'date_last_categorized'], ARRAY['radcomp'], 'posda_files', 'Add a filter to a tab')
        ;

            insert into queries
            values ('GetSeriesSignature', 'select distinct
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
', ARRAY['collection'], 
                    ARRAY['dicom_file_type', 'signature', 'num_series', 'num_files'], ARRAY['signature'], 'posda_files', 'Get a list of Series Signatures by Collection
')
        ;

            insert into queries
            values ('RoundInfoLastCompleteRound', 'select
  round_id, collection,
  round_created,
  round_start,  
  round_end,
  round_aborted,
  wait_count,
  process_count,
  num_entered,
  num_failed,
  num_dups,
  num_requests,
  priority
from
  round natural join round_counts natural join round_collection
where round_id in (
  select max(round_id) as round_id from round where round_end is not null
)
order by round_id, collection', '{}', 
                    ARRAY['round_id', 'collection', 'round_created', 'round_start', 'round_end', 'round_aborted', 'wait_count', 'process_count', 'num_entered', 'num_failed', 'num_dups', 'num_requests', 'priority'], ARRAY['NotInteractive', 'Backlog', 'Backlog Monitor', 'backlog_status'], 'posda_backlog', 'Summary of round by id')
        ;

            insert into queries
            values ('StructVolByFileId', 'select
  distinct sop_instance,
  sop_class,
  study_instance_uid,
  series_instance_uid,
  for_uid
from
  file_structure_set natural join
  ss_for natural join
  ss_volume
where file_id = ?', ARRAY['file_id'], 
                    ARRAY['sop_instance', 'sop_class', 'study_instance_uid', 'series_instance_uid', 'for_uid'], ARRAY['LinkageChecks', 'used_in_struct_linkage_check'], 'posda_files', 'Get list of Roi with info by file_id

')
        ;

            insert into queries
            values ('ActivityStuffMoreWithEmailByUser', 'select
  distinct subprocess_invocation_id, background_subprocess_id, user_inbox_content_id,
  background_subprocess_report_id, file_id,
  background_subprocess_report.name as report_type,
  activity_id, when_script_started,
  when_background_entered, when_script_ended, 
  invoking_user, user_to_notify, button_name,
  operation_name, command_line
from
  subprocess_invocation natural left join background_subprocess natural left join background_subprocess_report
  natural left join user_inbox_content natural left join activity_inbox_content
where invoking_user = ? and background_subprocess_report.name = ''Email''
order by subprocess_invocation_id desc
', ARRAY['user'], 
                    ARRAY['subprocess_invocation_id', 'background_subprocess_id', 'user_inbox_content_id', 'background_subprocess_report_id', 'file_id', 'report_type', 'activity_id', 'when_script_started', 'when_background_entered', 'when_script_ended', 'invoking_user', 'user_to_notify', 'button_name', 'operation_name', 'command_line'], ARRAY['activity_timepoint_support'], 'posda_queries', 'Create An Activity Timepoint

')
        ;

            insert into queries
            values ('FilesByCollectionSitePatientVisibility', 'select
  distinct project_name as collection,
  site_name as site,
  patient_id, file_id, visibility
from
  ctp_file natural join file_patient
where
  project_name = ? and
  site_name = ? and
  patient_id = ? and visibility = ?
order by collection, site, patient_id

', ARRAY['collection', 'site', 'patient_id', 'visibility'], 
                    ARRAY['collection', 'site', 'patient_id', 'file_id', 'visibility'], ARRAY['duplicates', 'dup_sops', 'hide_dup_sops', 'sops_different_series'], 'posda_files', 'Return a count of duplicate SOP Instance UIDs
')
        ;

            insert into queries
            values ('ListOfQueriesPerformedByDate', 'select
  query_invoked_by_dbif_id as id,
  query_name,
  query_end_time - query_start_time as duration,
  invoking_user as invoked_by,
  query_start_time as at, 
  number_of_rows
from
  query_invoked_by_dbif
where query_start_time > ? and query_end_time < ?
', ARRAY['from', 'to'], 
                    ARRAY['id', 'query_name', 'duration', 'invoked_by', 'at', 'number_of_rows'], ARRAY['AllCollections', 'q_stats_by_date'], 'posda_queries', 'Get a list of collections and sites
')
        ;

            insert into queries
            values ('GetScanEventEventId', 'select currval(''scan_event_scan_event_id_seq'') as id
', '{}', 
                    ARRAY['num_series_scanned', 'id'], ARRAY['UsedInPhiSeriesScan', 'NotInteractive'], 'posda_phi', 'Get current value of scan_event_id')
        ;

            insert into queries
            values ('DistinctSeriesByCollectionSite', 'select distinct series_instance_uid, dicom_file_type, modality, count(distinct file_id)
from
  file_series natural join dicom_file natural join ctp_file
where
  project_name = ? and site_name = ? and visibility is null
group by series_instance_uid, dicom_file_type, modality
', ARRAY['project_name', 'site_name'], 
                    ARRAY['series_instance_uid', 'dicom_file_type', 'modality', 'count'], ARRAY['by_collection', 'find_series', 'compare_collection_site', 'search_series', 'edit_files', 'simple_phi', 'dciodvfy', 'ctp_details', 'select_for_phi', 'visual_review_selection'], 'posda_files', 'Get Series in A Collection, site with dicom_file_type, modality, and sop_count
')
        ;

            insert into queries
            values ('GetSimpleValueSeenId', 'select currval(''value_seen_value_seen_id_seq'') as id', '{}', 
                    ARRAY['id'], ARRAY['used_in_simple_phi', 'NotInteractive'], 'posda_phi_simple', 'Get index of newly created value_seen')
        ;

            insert into queries
            values ('ToFileWithVisibilityBySopFromDicomEditCompare', 'select 
  sop_instance_uid,
  file_id as to_file_id,
  visibility as to_file_visibility
from
  ctp_file natural join file natural join file_sop_common,
  dicom_edit_compare
where
  to_file_digest = file.digest and
  subprocess_invocation_id = ?
order by sop_instance_uid', ARRAY['subprocess_invocation_id'], 
                    ARRAY['sop_instance_uid', 'to_file_id', 'to_file_visibility'], ARRAY['meta', 'test', 'hello', 'bills_test', 'hide_events'], 'posda_files', 'Add a filter to a tab')
        ;

            insert into queries
            values ('ReviewEditsBySite', 'select
  distinct project_name,
  site_name,
  series_instance_uid, 
  new_visibility, 
  reason_for,
  min(time_of_change) as earliest,
  max(time_of_change) as latest,
  count(*) as num_files
from
  file_visibility_change natural join
  ctp_file natural join
  file_series
where 
  site_name = ?
group by 
  project_name, site_name, series_instance_uid, new_visibility, reason_for', ARRAY['site'], 
                    ARRAY['project_name', 'site_name', 'series_instance_uid', 'new_visibility', 'reason_for', 'earliest', 'latest', 'num_files'], ARRAY['Hierarchy', 'review_visibility_changes'], 'posda_files', 'Show all file visibility changes by series for site')
        ;

            insert into queries
            values ('ImportEventsWithType', 'select
  distinct import_event_id, import_time,  import_type, count(distinct file_id) as num_files
from
  import_event natural join file_import
where
  import_type = ''multi file import'' and 
  import_time > ? and import_time < ?
group by import_event_id, import_time, import_type', ARRAY['from', 'to'], 
                    ARRAY['import_event_id', 'import_time', 'import_type', 'num_files'], ARRAY['adding_ctp', 'find_patients', 'no_ctp_patients', 'import_event'], 'posda_files', 'Get Series in A Collection
')
        ;

            insert into queries
            values ('RoundStatsWithCollectionSiteForDateRange', 'select
  distinct collection, site, date_trunc(?, time_received) as time,
  count(*) as number_of_files,
  max(time_entered - time_received) as max_delay,
  min(time_entered - time_received) as min_delay
from request natural join submitter
where time_received > ? and time_received < ?
group by collection, site, time order by time desc, collection, site', ARRAY['interval', 'from', 'to'], 
                    ARRAY['collection', 'site', 'time', 'number_of_files', 'max_delay', 'min_delay'], ARRAY['NotInteractive', 'Backlog', 'Backlog Monitor', 'for_bill'], 'posda_backlog', 'Summary of rounds')
        ;

            insert into queries
            values ('SeriesSendEventsByReason', 'select
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
    reason_for_send = ?
  group by dicom_send_event_id
) as foo
natural join dicom_send_event
order by send_started
', ARRAY['reason'], 
                    ARRAY['series_instance_uid', 'send_started', 'duration', 'destination_host', 'destination_port', 'to_send', 'files_sent', 'invoking_user', 'reason_for_send'], ARRAY['send_to_intake'], 'posda_files', 'List of Send Events By Reason
')
        ;

            insert into queries
            values ('SlopeInterceptByPixelType', 'select 
  distinct slope, intercept, count(*)
from (select
    distinct photometric_interpretation,
    samples_per_pixel,
    bits_allocated,
    bits_stored,
    high_bit,
    coalesce(number_of_frames,1) > 1 as is_multi_frame,
    pixel_representation,
    planar_configuration,
    modality,
    file_id
  from
    image natural join file_image natural join file_series
  ) as foo natural join file_slope_intercept natural join slope_intercept
where
  photometric_interpretation = ? and
  samples_per_pixel = ? and
  bits_allocated = ? and
  bits_stored = ? and
  high_bit = ? and
  pixel_representation = ? and
  modality = ?
group by slope, intercept
', ARRAY['photometric_interpretation', 'samples_per_pixel', 'bits_allocated', 'bits_stored', 'high_bit', 'pixel_representation', 'modality'], 
                    ARRAY['slope', 'intercept', 'count'], ARRAY['all', 'find_pixel_types', 'posda_files'], 'posda_files', 'Get distinct pixel types
')
        ;

            insert into queries
            values ('AddPatientAge', 'update file_patient set
  patient_age = ?
where file_id = ?', ARRAY['age', 'file_id'], 
                    '{}', ARRAY['meta', 'test', 'hello', 'query_tabs', 'bills_test'], 'posda_files', 'Add a filter to a tab')
        ;

            insert into queries
            values ('CreateSubprocessInvocationSpreadsheet', 'insert into subprocess_invocation(
 from_spreadsheet, from_button,
 spreadsheet_uploaded_id, command_line, invoking_user, when_invoked
) values (
  true, false, ?, ?, ?, now()
)', ARRAY['spreadsheet_uploaded_id', 'command_line', 'invoking_user'], 
                    '{}', ARRAY['NotInteractive', 'used_in_background_processing'], 'posda_queries', 'Create a row in subprocess_invocation table

Used when invoking a spreadsheet operation from a spreadsheet')
        ;

            insert into queries
            values ('CreateDciodvfyWarning', 'insert into dciodvfy_warning(
  warning_type,
  warning_tag,
  warning_desc,
  warning_iod,
  warning_comment,
  warning_value,
  warning_reason,
  warning_index,
  warning_text
) values (
  ?, ?, ?, ?,
  ?, ?, ?, ?,
  ?
)', ARRAY['warning_type', 'warning_tag', 'warning_desc', 'warning_iod', 'warning_comment', 'warning_value', 'warning_reason', 'warning_index', 'warning_text'], 
                    '{}', ARRAY['NotInteractive', 'used_in_dciodvfy'], 'posda_phi_simple', 'Create a dciodvfy_warnings row')
        ;

            insert into queries
            values ('GetQueryArgs', 'select args from queries where name = ?', ARRAY['name'], 
                    ARRAY['args'], ARRAY['bills_test', 'posda_db_populate'], 'posda_queries', 'Add a filter to a tab')
        ;

            insert into queries
            values ('GetSeriesListByDciodvyScanInstance', 'select distinct(unit_uid) as series_instance_uid from dciodvfy_unit_scan natural join dciodvfy_unit_scan_warning  where dciodvfy_scan_instance_id = ? union 
select distinct(unit_uid) as series_instance_uid from dciodvfy_unit_scan natural join dciodvfy_unit_scan_error  where dciodvfy_scan_instance_id = ?
', ARRAY['dciodvfy_scan_instance_id', 'repeat_scan_instance_id'], 
                    ARRAY['series_instance_uid'], ARRAY['tag_usage', 'dciodvfy'], 'posda_phi_simple', 'Show all the dciodvfy scans')
        ;

            insert into queries
            values ('GetCtInfoBySeries', 'select 
  distinct 
  kvp,
  scan_options,
  data_collection_diameter,
  reconstruction_diameter,
  dist_source_to_detect,
  dist_source_to_pat,
  gantry_tilt,
  rotation_dir,
  exposure_time,
  filter_type,
  generator_power, 
  convolution_kernal,
  table_feed_per_rot
from file_ct_image natural join file_patient natural join file_series natural join ctp_file 
where series_instance_uid = ? and visibility is null
', ARRAY['series_instance_uid'], 
                    ARRAY['kvp', 'scan_options', 'data_collection_diameter', 'reconstruction_diameter', 'dist_source_to_detect', 'dist_source_to_pat', 'gantry_tilt', 'rotation_dir', 'exposure_time', 'filter_type', 'generator_power', 'convolution_kernal', 'table_feed_per_rot'], ARRAY['populate_posda_files', 'bills_test'], 'posda_files', 'Gets count of all files which are PET''s which haven''t been imported into file_pt_image yet.

')
        ;

            insert into queries
            values ('SubprocessesByUser', 'select
  distinct subprocess_invocation_id, 
  when_script_started, when_background_entered, when_script_ended, user_to_notify, 
  button_name, operation_name, count(distinct background_subprocess_report_id) as num_reports 
from
  subprocess_invocation natural left join background_subprocess natural left join
  background_subprocess_report
where invoking_user = ?
group by
  subprocess_invocation_id, when_script_started, when_background_entered,
  when_script_ended, user_to_notify, button_name, operation_name
order by subprocess_invocation_id desc', ARRAY['invoking_user'], 
                    ARRAY['subprocess_invocation_id', 'when_script_started', 'when_background_entered', 'when_script_ended', 'user_to_notify', 'button_name', 'operation_name', 'num_reports'], ARRAY['AllCollections', 'queries', 'activity_support'], 'posda_queries', 'Get a list of available queries')
        ;

            insert into queries
            values ('UpdateSeriesScanned', 'update scan_event
set num_series_scanned = ?
where scan_event_id = ?', ARRAY['num_series_scanned', 'scan_event_id'], 
                    '{}', ARRAY['UsedInPhiSeriesScan', 'NotInteractive'], 'posda_phi', 'Update Series Scanned in scan event
')
        ;

            insert into queries
            values ('ListOfDciodvfyWarningsWithCounts', 'select distinct warning_type, warning_tag, warning_desc, warning_iod, warning_comment, warning_value, warning_reason, warning_index, count(distinct dciodvfy_unit_scan_id)  as num_scan_units from dciodvfy_warning
natural join dciodvfy_unit_scan_error group by 
warning_type, warning_tag, warning_desc, warning_iod, warning_comment, warning_value, warning_reason, warning_index
order by warning_type, warning_tag, warning_desc, warning_iod, warning_comment, warning_value, warning_reason, warning_index', '{}', 
                    ARRAY['warning_type', 'warning_tag', 'warning_desc', 'warning_iod', 'warning_comment', 'warning_value', 'warning_reason', 'warning_index', 'num_scan_units'], ARRAY['tag_usage', 'dciodvfy'], 'posda_phi_simple', 'All dciodvfy warnings in DB')
        ;

            insert into queries
            values ('GetPatientIdsByDateRangeLikeCollection', 'select 
  distinct patient_id, import_type
from
  clinical_trial_qualified_patient_id join file_patient using (patient_id) 
  join file_import using(file_id)
  join import_event using(import_event_id)
where 
  collection like ? and import_time > ? and import_time < ? and import_type not like ''script%''', ARRAY['collection_like', 'from', 'to'], 
                    ARRAY['patient_id', 'import_type'], ARRAY['clin_qual'], 'posda_files', 'Create An Activity Timepoint

')
        ;

            insert into queries
            values ('VisibilityChangesBySeries', 'select
  distinct project_name as collection, 
  site_name as site, patient_id,
  user_name, prior_visibility, new_visibility,
  date_trunc(''hour'',time_of_change) as time, 
  reason_for, series_instance_uid, count(*) as num_files
from
  file_visibility_change natural join
  ctp_file natural join 
  file_patient natural join 
  file_series
where
  project_name = ? and site_name = ? and
  series_instance_uid = ?
group by 
  collection, site, patient_id, user_name, prior_visibility, new_visibility,
  time, reason_for, series_instance_uid
order by time, collection, site, patient_id, series_instance_uid
', ARRAY['collection', 'site', 'series_instance_uid'], 
                    ARRAY['collection', 'site', 'patient_id', 'user_name', 'prior_visibility', 'new_visibility', 'time', 'reason_for', 'series_instance_uid', 'num_files'], ARRAY['find_series', 'equivalence_classes', 'consistency', 'visual_review_results', 'hide_files'], 'posda_files', 'Get visual review status report by series for Collection, Site')
        ;

            insert into queries
            values ('DistinctSeriesByCollectionLikePublic', 'select
  distinct s.series_instance_uid, modality, count(*) as num_images
from
  general_image i, general_series s,
  trial_data_provenance tdp
where
  s.general_series_pk_id = i.general_series_pk_id and
  i.trial_dp_pk_id = tdp.trial_dp_pk_id and
  tdp.project like ?
group by series_instance_uid, modality', ARRAY['collection_like'], 
                    ARRAY['series_instance_uid', 'modality', 'num_images'], ARRAY['by_collection', 'find_series', 'public'], 'public', 'Get Series in A Collection
')
        ;

            insert into queries
            values ('FilesByModalityByCollectionSite', 'select
  distinct patient_id, modality, series_instance_uid, sop_instance_uid, root_path || ''/'' || rel_path as path
from
  file_patient natural join file_series natural join file_sop_common natural join ctp_file
  natural join file_location natural join file_storage_root
where
  modality = ? and
  project_name = ? and 
  site_name = ? and
  visibility is null', ARRAY['modality', 'project_name', 'site_name'], 
                    ARRAY['patient_id', 'modality', 'series_instance_uid', 'sop_instance_uid', 'path'], ARRAY['FindSubjects', 'intake', 'FindFiles'], 'posda_files', 'Find All Files with given modality in Collection, Site')
        ;

            insert into queries
            values ('PrivsteTagsDispositionsAndValuesByScanId', 'select 
  distinct element_seen_id, element_sig_pattern, tag_name, private_disposition, value
from
  element_value_occurance natural join element_seen natural join value_seen 
where
  phi_scan_instance_id = ? and element_sig_pattern like ''%"%''
order by element_sig_pattern;
', ARRAY['phi_scan_instance_id'], 
                    ARRAY['element_seen_id', 'element_sig_pattern', 'tag_name', 'private_disposition', 'value'], ARRAY['tag_usage', 'simple_phi_maint', 'phi_maint'], 'posda_phi_simple', 'Private tags with no disposition with values in phi_simple')
        ;

            insert into queries
            values ('PopulateFilePtImageRow', 'insert into file_pt_image(
  file_id,
  pti_trigger_time,
  pti_frame_time,
  pti_intervals_acquired,
  pti_intervals_rejected,
  pti_reconstruction_diameter,
  pti_gantry_detector_tilt,
  pti_table_height,
  pti_fov_shape,
  pti_fov_dimensions,
  pti_collimator_type,
  pti_convoution_kernal,
  pti_actual_frame_duration,
  pti_energy_range_lower_limit,
  pti_energy_range_upper_limit,
  pti_radiopharmaceutical,
  pti_radiopharmaceutical_volume,
  pti_radiopharmaceutical_start_time,
  pti_radiopharmaceutical_stop_time,
  pti_radionuclide_total_dose,
  pti_radionuclide_half_life,
  pti_radionuclide_positron_fraction,
  pti_number_of_slices,
  pti_number_of_time_slices,
  pti_type_of_detector_motion,
  pti_image_id,
  pti_series_type,
  pti_units,
  pti_counts_source,
  pti_reprojection_method,
  pti_randoms_correction_method,
  pti_attenuation_correction_method,
  pti_decay_correction,
  pti_reconstruction_method,
  pti_detector_lines_of_response_used,
  pti_scatter_correction_method,
  pti_axial_mash,
  pti_transverse_mash,
  pti_coincidence_window_width,
  pti_secondary_counts_type,
  pti_frame_reference_time,
  pti_primary_counts_accumulated,
  pti_secondary_counts_accumulated,
  pti_slice_sensitivity_factor,
  pti_decay_factor,
  pti_dose_calibration_factor,
  pti_scatter_fraction_factor,
  pti_dead_time_factor,
  pti_image_index
) values (
  ?, ?, ?, ?, ?, ?, ?, ?, ?, ?,
  ?, ?, ?, ?, ?, ?, ?, ?, ?, ?,
  ?, ?, ?, ?, ?, ?, ?, ?, ?, ?,
  ?, ?, ?, ?, ?, ?, ?, ?, ?, ?,
  ?, ?, ?, ?, ?, ?, ?, ?, ?
)', ARRAY['file_id', 'pti_trigger_time', 'pti_frame_time', 'pti_intervals_acquired', 'pti_intervals_rejected', 'pti_reconstruction_diameter', 'pti_gantry_detector_tilt', 'pti_table_height', 'pti_fov_shape', 'pti_fov_dimensions', 'pti_collimator_type', 'pti_convoution_kernal', 'pti_actual_frame_duration', 'pti_energy_range_lower_limit', 'pti_energy_range_upper_limit', 'pti_radiopharmaceutical', 'pti_radiopharmaceutical_volume', 'pti_radiopharmaceutical_start_time', 'pti_radiopharmaceutical_stop_time', 'pti_radionuclide_total_dose', 'pti_radionuclide_half_life', 'pti_radionuclide_positron_fraction', 'pti_number_of_slices', 'pti_number_of_time_slices', 'pti_type_of_detector_motion', 'pti_image_id', 'pti_series_type', 'pti_units', 'pti_counts_source', 'pti_reprojection_method', 'pti_randoms_correction_method', 'pti_attenuation_correction_method', 'pti_decay_correction', 'pti_reconstruction_method', 'pti_detector_lines_of_response_used', 'pti_scatter_correction_method', 'pti_axial_mash', 'pti_transverse_mash', 'pti_coincidence_window_width', 'pti_secondary_counts_type', 'pti_frame_reference_time', 'pti_primary_counts_accumulated', 'pti_secondary_counts_accumulated', 'pti_slice_sensitivity_factor', 'pti_decay_factor', 'pti_dose_calibration_factor', 'pti_scatter_fraction_factor', 'pti_dead_time_factor', 'pti_image_index'], 
                    '{}', ARRAY['populate_posda_files', 'bills_test'], 'posda_files', 'Get Series in A Collection
')
        ;

            insert into queries
            values ('GetQuery', 'select 
 query
from pg_stat_activity
where pid = ?', ARRAY['pid'], 
                    ARRAY['query'], ARRAY['AllCollections', 'postgres_stats', 'postgres_query_stats'], 'posda_backlog', 'Get a list of collections and sites
')
        ;

            insert into queries
            values ('GetPatientMappingByCollectionSiteSimple', 'select
  from_patient_id,
  to_patient_id,
  to_patient_name,
  collection_name,
  site_name,
  batch_number,
  diagnosis_date,
  baseline_date,
  date_shift,
  baseline_date - diagnosis_date + interval ''1 day'' as computed_shift
from
  patient_mapping
where
  collection_name = ?
  and site_name = ?
  ', ARRAY['collection_name', 'site_name'], 
                    ARRAY['from_patient_id', 'to_patient_id', 'to_patient_name', 'collection_name', 'site_name', 'batch_number', 'diagnosis_date', 'baseline_date', 'date_shift', 'computed_shift'], ARRAY['adding_ctp', 'for_scripting', 'patient_mapping'], 'posda_files', 'Retrieve entries from patient_mapping table')
        ;

            insert into queries
            values ('VisibilityChangeEventsByCollectionForAllFiles', 'select
  distinct project_name as collection, 
  site_name as site,
  user_name, 
  date_trunc(''hour'',time_of_change) as time, 
  reason_for, count(distinct file_id)
from
  file_visibility_change natural join
  ctp_file
where
  project_name = ?
group by collection, site, user_name, time, reason_for
order by time, collection, site', ARRAY['collection'], 
                    ARRAY['collection', 'site', 'user_name', 'time', 'reason_for', 'count'], ARRAY['find_series', 'equivalence_classes', 'consistency', 'visual_review_results', 'hide_files', 'old_hidden'], 'posda_files', 'Show Received before date by collection, site')
        ;

            insert into queries
            values ('ListOpenActivities', 'select
  distinct activity_id,
  brief_description,
  when_created,
  who_created,
  count(distinct user_inbox_content_id) as num_items
from
  activity natural left join activity_inbox_content
where when_closed is null
group by activity_id, brief_description, when_created, who_created
order by activity_id desc', '{}', 
                    ARRAY['activity_id', 'brief_description', 'when_created', 'who_created', 'num_items'], ARRAY['AllCollections', 'queries', 'activities'], 'posda_queries', 'Get a list of available queries')
        ;

            insert into queries
            values ('GetInsertedSendId', 'select currval(''dicom_send_event_dicom_send_event_id_seq'') as id
', '{}', 
                    ARRAY['id'], ARRAY['NotInteractive', 'SeriesSendEvent'], 'posda_files', 'Get dicom_send_event_id after creation
For use in scripts.
Not meant for interactive use
')
        ;

            insert into queries
            values ('LinkEmailToActivity', 'insert into activity_inbox_content(
 activity_id, user_inbox_content_id
) values (
  ?, ?
)', ARRAY['activity_id', 'user_inbox_content_id'], 
                    '{}', ARRAY['activity_timepoint_support'], 'posda_queries', 'Create An Activity Timepoint

')
        ;

            insert into queries
            values ('GetNonDicomEditCompareFromFiles', 'select 
  file_id,
  collection,
  visibility
from 
  file join non_dicom_file using(file_id)
where
  file_id in (
    select file_id from file f, non_dicom_edit_compare ndec
    where f.digest = ndec.from_file_digest and subprocess_invocation_id = ?
  )', ARRAY['subprocess_invocation_id'], 
                    ARRAY['file_id', 'collection', 'visibility'], ARRAY['adding_ctp', 'for_scripting', 'non_dicom_import'], 'posda_files', 'Get a list of from files from the non_dicom_edit_compare table for a particular edit instance, with visibility

NB: collection will be null if there is no non_dicom_file row.  This shouldn''t ever happen.  ever!  abort and investigate
       visibility, on the other hand, should always be null.  ')
        ;

            insert into queries
            values ('IncrementEditsDone', 'update dicom_edit_event
  set edits_done = edits_done + 1
where
  dicom_edit_event_id = ?', ARRAY['dicom_edit_event_id'], 
                    '{}', ARRAY['Insert', 'NotInteractive', 'used_in_import_edited_files'], 'posda_files', 'Increment edits done in dicom_edit_event table
For use in scripts
Not really intended for interactive use
')
        ;

            insert into queries
            values ('AllSopsReceivedBetweenDatesByCollection', 'select
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
', ARRAY['start_time', 'end_time', 'collection'], 
                    ARRAY['project_name', 'site_name', 'patient_id', 'study_instance_uid', 'series_instance_uid', 'num_sops', 'first_loaded', 'last_loaded'], ARRAY['receive_reports'], 'posda_files', 'Series received between dates regardless of duplicates
')
        ;

            insert into queries
            values ('DatesOfUploadByCollectionSiteVisible', 'select distinct date_trunc as date, count(*) as num_uploads from (
 select 
  date_trunc(''day'', import_time),
  file_id
from file_import natural join import_event natural join file_sop_common
  natural join ctp_file
where project_name = ? and site_name = ? and visibility is null
) as foo
group by date
order by date
', ARRAY['collection', 'site'], 
                    ARRAY['date', 'num_uploads'], ARRAY['receive_reports'], 'posda_files', 'Show me the dates with uploads for Collection from Site
')
        ;

            insert into queries
            values ('SeriesWithDupSopsByCollectionSite', 'select
  distinct collection, site, subj_id, study_instance_uid, series_instance_uid, 
  count(distinct sop_instance_uid) as num_sops,
  count(distinct file_id) as num_files
from (
  select
    distinct project_name as collection,
    site_name as site, patient_id as subj_id,
    study_instance_uid, series_instance_uid,
    sop_instance_uid,
    file_id
  from
    ctp_file natural join file_sop_common
    natural join file_patient natural join file_study natural join file_series
  where
    sop_instance_uid in (
      select distinct sop_instance_uid from (
        select distinct sop_instance_uid, count(distinct file_id) from (
          select distinct file_id, sop_instance_uid 
          from
            ctp_file natural join file_sop_common
            natural join file_patient
          where
            visibility is null and project_name = ? and site_name = ?
        ) as foo group by sop_instance_uid order by count desc
      ) as foo 
      where count > 1
    )
    and visibility is null
  ) as foo
group by collection, site, subj_id, study_instance_uid, series_instance_uid

', ARRAY['collection', 'site'], 
                    ARRAY['collection', 'site', 'subj_id', 'num_sops', 'num_files', 'study_instance_uid', 'series_instance_uid'], ARRAY['duplicates', 'dup_sops', 'hide_dup_sops'], 'posda_files', 'Return a count of duplicate SOP Instance UIDs
')
        ;

            insert into queries
            values ('FinalizeSimpleSeriesScan', 'update series_scan_instance set
  num_files = ?,
  end_time = now()
where
  series_scan_instance_id = ?', ARRAY['num_files', 'id'], 
                    '{}', ARRAY['used_in_simple_phi', 'NotInteractive'], 'posda_phi_simple', 'Finalize Series Scan')
        ;

            insert into queries
            values ('InsertFilePosda', 'insert into file(
  digest, size, processing_priority, ready_to_process
) values ( ?, ?, 1, ''false'')', ARRAY['digest', 'size'], 
                    '{}', ARRAY['NotInteractive', 'Backlog', 'Transaction', 'used_in_file_import_into_posda'], 'posda_files', 'Lock the file table in posda_files')
        ;

            insert into queries
            values ('UpdateComparePublicToPosdaInstance', 'update compare_public_to_posda_instance set
  number_compares_completed = ?,
  num_failed = ?,
  status_of_compare = ''Comparisons In Progress'',
  last_updated = now()
where
  compare_public_to_posda_instance_id = ?
', ARRAY['number_compares_complete', 'num_failed', 'compare_public_to_posda_instance_id'], 
                    '{}', ARRAY['adding_ctp', 'for_scripting'], 'posda_files', 'Update an entry in dicom_edit_compare_disposition

From script only.  Don''t run from user interface (needs valid subprocess_invocation_id)')
        ;

            insert into queries
            values ('FindInconsistentSeriesIgnoringTimeAll', 'select series_instance_uid from (
select distinct series_instance_uid, count(*) from (
  select distinct
    series_instance_uid, modality, series_number, laterality, series_date,
    performing_phys, protocol_name, series_description,
    operators_name, body_part_examined, patient_position,
    smallest_pixel_value, largest_pixel_value, performed_procedure_step_id,
    performed_procedure_step_start_date, performed_procedure_step_start_time,
    performed_procedure_step_desc, performed_procedure_step_comments,
    count(*)
  from
    file_series natural join ctp_file
  where
    visibility is null
  group by
    series_instance_uid, modality, series_number, laterality, series_date,
    performing_phys, protocol_name, series_description,
    operators_name, body_part_examined, patient_position,
    smallest_pixel_value, largest_pixel_value, performed_procedure_step_id,
    performed_procedure_step_start_date, performed_procedure_step_start_time,
    performed_procedure_step_desc, performed_procedure_step_comments
) as foo
group by series_instance_uid
) as foo
where count > 1
', '{}', 
                    ARRAY['series_instance_uid'], ARRAY['consistency', 'find_series', 'series_consistency'], 'posda_files', 'Find Inconsistent Series
')
        ;

            insert into queries
            values ('UpdPosdaPhiEleName', 'update
  element_signature
set
  name_chain = ?
where
  element_signature = ? and
  vr = ?

', ARRAY['name', 'element_signature', 'vr'], 
                    '{}', ARRAY['NotInteractive', 'used_in_reconcile_tag_names'], 'posda_phi', 'Update name_chain in element signature')
        ;

            insert into queries
            values ('DupSopsByImportEvent', 'select sop_instance_uid, num_files from (
  select
    distinct sop_instance_uid, count(distinct file_id) as num_files
  from (
    select distinct sop_instance_uid, file_id, visibility
    from file_sop_common natural left join ctp_file
    where file_id in (
      select
        distinct file_id from file_import where import_event_id in (select import_event_id from (
          select
            distinct import_event_id, import_time,  import_type, count(distinct file_id) as num_files
          from
            import_event natural join file_import natural join file_patient
          where
            import_event_id = ?
           group by import_event_id, import_time, import_type
         ) as foo
      )
    )
  ) as foo where visibility is null
  group by sop_instance_uid
) as foo
where num_files > 1
', ARRAY['import_event_id'], 
                    ARRAY['sop_instance_uid', 'num_files'], ARRAY['adding_ctp', 'find_patients', 'no_ctp_patients', 'import_event'], 'posda_files', 'Get Series in A Collection
')
        ;

            insert into queries
            values ('GetCopyInformation', 'select
  status_of_copy,
  pid_of_running_process
from
  copy_from_public
where copy_from_public_id = ?', ARRAY['copy_from_public_id'], 
                    ARRAY['status_of_copy', 'pid_of_running_process'], ARRAY['bills_test', 'copy_from_public'], 'posda_files', 'Add a filter to a tab')
        ;

            insert into queries
            values ('patient_id_and_collection_by_like_collection', 'select distinct project_name as collection, patient_id from file_patient natural join ctp_file where project_name like ? and visibility is null', ARRAY['like_collection'], 
                    ARRAY['collection', 'patient_id'], ARRAY['meta', 'test', 'hello', 'query_tabs', 'bills_test'], 'posda_files', 'Add a filter to a tab')
        ;

            insert into queries
            values ('UpdateNameChain', 'update element_signature set 
  name_chain = ?
where
  element_signature = ? and
  vr = ?
', ARRAY['name_chain', 'element_signature', 'vr'], 
                    '{}', ARRAY['NotInteractive', 'Update', 'ElementDisposition'], 'posda_phi', 'Update Element Disposition
For use in scripts
Not really intended for interactive use
')
        ;

            insert into queries
            values ('FindInconsistentSeriesIgnoringTimeCollectionSite', 'select series_instance_uid from (
select distinct series_instance_uid, count(*) from (
  select distinct
    series_instance_uid, modality, series_number, laterality, series_date,
    performing_phys, protocol_name, series_description,
    operators_name, body_part_examined, patient_position,
    smallest_pixel_value, largest_pixel_value, performed_procedure_step_id,
    performed_procedure_step_start_date, performed_procedure_step_start_time,
    performed_procedure_step_desc, performed_procedure_step_comments,
    count(*)
  from
    file_series natural join ctp_file
  where
    project_name = ? and site_name = ? and visibility is null
  group by
    series_instance_uid, modality, series_number, laterality, series_date,
    performing_phys, protocol_name, series_description,
    operators_name, body_part_examined, patient_position,
    smallest_pixel_value, largest_pixel_value, performed_procedure_step_id,
    performed_procedure_step_start_date, performed_procedure_step_start_time,
    performed_procedure_step_desc, performed_procedure_step_comments
) as foo
group by series_instance_uid
) as foo
where count > 1
', ARRAY['collection', 'site'], 
                    ARRAY['series_instance_uid'], ARRAY['consistency', 'find_series', 'series_consistency'], 'posda_files', 'Find Inconsistent Series by Collection Site
')
        ;

            insert into queries
            values ('ListVisualReviewInstances', 'select
  visual_review_instance_id, visual_review_reason,
  visual_review_scheduler,
  visual_review_num_series,
  when_visual_review_scheduled, 
  visual_review_num_series_done,
  visual_review_num_equiv_class,
  when_visual_review_sched_complete
from visual_review_instance', '{}', 
                    ARRAY['visual_review_instance_id', 'visual_review_reason', 'visual_review_scheduler', 'visual_review_num_series', 'when_visual_review_scheduled', 'visual_review_num_series_done', 'visual_review_num_equiv_class', 'when_visual_review_sched_complete'], ARRAY['signature', 'phi_review', 'visual_review', 'visual_review_new_workflow'], 'posda_files', 'Get a list of files which are hidden by series id and visual review id')
        ;

            insert into queries
            values ('FileIdPathTimesLoadedCountsBySopInstance', 'select
  distinct file_id,
  root_path || ''/'' || file_location.rel_path as path,
  min(import_time) as first_loaded,
  count(distinct import_time) as times_loaded,
  max(import_time) as last_loaded
from
  file_location
  natural join file_storage_root
  join file_import using(file_id)
  join import_event using (import_event_id)
  natural join file_sop_common where sop_instance_uid = ?
group by file_id, path
order by first_loaded', ARRAY['sop_instance_uid'], 
                    ARRAY['file_id', 'path', 'first_loaded', 'times_loaded', 'last_loaded'], ARRAY['SeriesSendEvent', 'by_series', 'find_files', 'for_send'], 'posda_files', 'Get file path from id')
        ;

            insert into queries
            values ('GetStructureSetsByActivityTimepoint', 'select 
  file_id, root_path || ''/'' || rel_path as path, patient_id
from
  file_structure_set natural join activity_timepoint_file natural join file_location natural join file_storage_root
  natural join file_patient
where
  activity_timepoint_id = ?', ARRAY['activity_timepoint_id'], 
                    ARRAY['file_id', 'path', 'patient_id'], ARRAY['Structure Sets', 'sops', 'LinkageChecks'], 'posda_files', 'Get List of file_ids for structure sets in an activity timepoint
')
        ;

            insert into queries
            values ('RoundSummary2', 'select
  round_id,
  round_created,
  round_start,  
  round_end,
  round_aborted,
  wait_count,
  process_count
from
  round
order by round_id', '{}', 
                    ARRAY['round_id', 'round_created', 'round_start', 'round_end', 'round_aborted', 'wait_count', 'process_count'], ARRAY['NotInteractive', 'Backlog', 'Backlog Monitor'], 'posda_backlog', 'Summary of rounds')
        ;

            insert into queries
            values ('ActivityStuffByUser', 'select
  distinct subprocess_invocation_id, background_subprocess_id, user_inbox_content_id,
  activity_id, when_script_started,
  when_background_entered, when_script_ended, user_to_notify, button_name,
  operation_name, count(distinct background_subprocess_report_id) as num_reports
from
  subprocess_invocation natural left join background_subprocess natural left join background_subprocess_report
  natural left join user_inbox_content natural left join activity_inbox_content
where invoking_user = ?
group by
  subprocess_invocation_id, background_subprocess_id, user_inbox_content_id,
  activity_id, when_script_started, when_background_entered,
  when_script_ended, user_to_notify, button_name, operation_name
order by subprocess_invocation_id desc', ARRAY['user'], 
                    ARRAY['subprocess_invocation_id', 'background_subprocess_id', 'user_inbox_content_id', 'activity_id', 'when_script_started', 'when_background_entered', 'when_script_ended', 'user_to_notify', 'button_name', 'operation_name', 'num_reports'], ARRAY['activity_timepoint_support'], 'posda_queries', 'Create An Activity Timepoint

')
        ;

            insert into queries
            values ('ListOfDciodvfyErrors', 'select 
  distinct error_type,
  error_tag, 
  error_value,
  error_subtype,
  error_module, 
  error_reason,
  error_index,
  count(distinct dciodvfy_unit_scan_id)  as num_scan_units 
from 
  dciodvfy_error
  natural join dciodvfy_unit_scan_error
group by 
  error_type,
  error_tag, 
  error_value,
  error_subtype,
  error_module, 
  error_reason,
  error_index
order by
  error_type,
  error_tag, 
  error_value,
  error_subtype,
  error_module, 
  error_reason,
  error_index', '{}', 
                    ARRAY['error_type', 'error_tag', 'error_value', 'error_subtype', 'error_module', 'error_reason', 'error_index', 'num_scan_units'], ARRAY['tag_usage', 'dciodvfy'], 'posda_phi_simple', 'All dciodvfy errors in DB')
        ;

            insert into queries
            values ('ReviewEditsByCollectionSite', 'select
  distinct project_name,
  site_name,
  series_instance_uid, 
  new_visibility, 
  reason_for,
  min(time_of_change) as earliest,
  max(time_of_change) as latest,
  count(*) as num_files
from
  file_visibility_change natural join
  ctp_file natural join
  file_series
where 
  project_name = ? and site_name = ?
group by 
  project_name, site_name, series_instance_uid, new_visibility, reason_for', ARRAY['collection', 'site'], 
                    ARRAY['project_name', 'site_name', 'series_instance_uid', 'new_visibility', 'reason_for', 'earliest', 'latest', 'num_files'], ARRAY['Hierarchy', 'review_visibility_changes'], 'posda_files', 'Show all file visibility changes by series for collection, site')
        ;

            insert into queries
            values ('SeriesWithMultipleSopsByVisualReviewId', 'select 
  distinct series_instance_uid, dicom_file_type, modality, visibility, count(distinct file_id) as num_files
from file_series natural join dicom_file natural join ctp_file
where series_instance_uid in (
  select series_instance_uid from (
    select
      distinct series_instance_uid, count(distinct dicom_file_type) as num_types, 
      count(distinct modality) as num_modalities 
    from (
      select 
        distinct series_instance_uid, dicom_file_type, modality
      from 
        file_series natural join dicom_file natural join image_equivalence_class
      where visual_review_instance_id = ?
     ) as foo
    group by series_instance_uid
  ) as foo 
  where num_types > 1 or num_modalities > 1
) group by series_instance_uid, dicom_file_type, modality, visibility order by series_instance_uid', ARRAY['visual_review_instance_id'], 
                    ARRAY['series_instance_uid', 'dicom_file_type', 'modality', 'visibility', 'num_files'], ARRAY['by_collection', 'find_series', 'compare_collection_site', 'search_series', 'edit_files', 'simple_phi', 'dciodvfy', 'ctp_details', 'select_for_phi', 'visual_review_new_workflow'], 'posda_files', 'Get Series in A Collection, site with dicom_file_type, modality, and sop_count
')
        ;

            insert into queries
            values ('GetReferencedButUnknownPlanSops', 'select
  sop_instance_uid, 
  rt_dose_referenced_plan_uid as plan_sop_instance_uid 
from 
  rt_dose d natural join file_dose join file_sop_common using(file_id)
where
  not exists (
  select
    sop_instance_uid 
  from
    file_sop_common fsc
  where
    d.rt_dose_referenced_plan_uid = fsc.sop_instance_uid
)', '{}', 
                    ARRAY['sop_instance_uid', 'plan_sop_instance_uid'], ARRAY['Structure Sets', 'sops', 'LinkageChecks'], 'posda_files', 'Get list of doses which reference unknown SOPs

')
        ;

            insert into queries
            values ('ListOfDciodvfyWarnings', 'select distinct warning_type, warning_tag, warning_desc, warning_iod, warning_comment, warning_value, warning_reason, warning_index
 from dciodvfy_warning
order by warning_type, warning_tag, warning_desc, warning_iod, warning_comment, warning_value, warning_reason, warning_index', '{}', 
                    ARRAY['warning_type', 'warning_tag', 'warning_desc', 'warning_iod', 'warning_comment', 'warning_value', 'warning_reason', 'warning_index'], ARRAY['tag_usage', 'dciodvfy'], 'posda_phi_simple', 'All dciodvfy warnings in DB')
        ;

            insert into queries
            values ('AddWaitCount', 'update round
  set wait_count = ?
where
  round_id = ?
', ARRAY['wait_count', 'round_id'], 
                    '{}', ARRAY['NotInteractive', 'Backlog'], 'posda_backlog', 'Set wait_count in round')
        ;

            insert into queries
            values ('SubprocessInvocationByUser', 'select 
  distinct subprocess_invocation_id, 
  background_subprocess_id, spreadsheet_uploaded_id, query_invoked_by_dbif_id,
  button_name, invoking_user, when_invoked, operation_name,
  max(line_number) as num_lines
from 
  subprocess_invocation natural left join subprocess_lines
  natural left join background_subprocess
where 
  invoking_user = ?
group by 
  subprocess_invocation_id, 
  background_subprocess_id, spreadsheet_uploaded_id, query_invoked_by_dbif_id,
  button_name, invoking_user, when_invoked, operation_name
order by when_invoked desc', ARRAY['invoking_user'], 
                    ARRAY['subprocess_invocation_id', 'background_subprocess_id', 'spreadsheet_uploaded_id', 'query_invoked_by_dbif_id', 'button_name', 'invoking_user', 'when_invoked', 'operation_name', 'num_lines'], ARRAY['meta', 'test', 'hello', 'query_tabs', 'bills_test', 'subprocess'], 'posda_queries', 'Add a filter to a tab')
        ;

            insert into queries
            values ('DistinctValuesByTagWithFileCount', 'select distinct element_signature, value, count(*) as num_files
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
', ARRAY['tag'], 
                    ARRAY['element_signature', 'value', 'num_files'], ARRAY['tag_usage'], 'posda_phi', 'Distinct values for a tag with file count
')
        ;

            insert into queries
            values ('DatesOfUpload', 'select 
  distinct project_name as collection, site_name as site,
  date_trunc as date, count(*) as num_uploads from (
   select 
    project_name,
    site_name,
    date_trunc(''day'', import_time),
    file_id
  from file_import natural join import_event
    natural join ctp_file 
) as foo
group by project_name, site_name, date
order by date, project_name, site_name', '{}', 
                    ARRAY['collection', 'site', 'date', 'num_uploads'], ARRAY['receive_reports'], 'posda_files', 'Show me the dates with uploads for Collection from Site
')
        ;

            insert into queries
            values ('GetSimilarDupContourCounts', 'select
  distinct
  project_name as collection,
  site_name as site,
  patient_id,
  series_instance_uid,
  sop_instance_uid,
  file_id
from
   ctp_file
   natural join file_patient
   natural join file_series
   natural join file_sop_common
where file_id in (
  select distinct file_id from (
    select 
      distinct file_id, count(*) as num_dup_contours
    from
      file_roi_image_linkage 
    where 
      contour_digest in (
      select contour_digest
     from (
        select 
          distinct contour_digest, count(*)
        from
          file_roi_image_linkage group by contour_digest
     ) as foo
      where count > 1
    ) group by file_id order by num_dup_contours desc
  ) as foo
  where num_dup_contours = ?
)
', ARRAY['num_dup_contours'], 
                    ARRAY['collection', 'site', 'patient_id', 'series_instance_uid', 'sop_instance_uid', 'file_id'], ARRAY['Structure Sets', 'sops', 'LinkageChecks', 'dup_contours'], 'posda_files', 'Get list of plan which reference unknown SOPs

')
        ;

            insert into queries
            values ('VisualReviewStatusDetails', 'select distinct image_equivalence_class_id, series_instance_uid, processing_status, review_status, visibility, count(distinct file_id) as num_files
from image_equivalence_class natural join image_equivalence_class_input_image natural join dicom_file natural join ctp_file
where visual_review_instance_id = ? and dicom_file_type = ? and
  processing_status = ? and (review_status is null or review_status = ?) group by image_equivalence_class_id, series_instance_uid, processing_status, review_status, visibility;
', ARRAY['visual_review_instance_id', 'dicom_file_type', 'processing_status', 'review_status'], 
                    ARRAY['image_equivalence_class_id', 'series_instance_uid', 'processing_status', 'review_status', 'visibility', 'num_files'], ARRAY['by_collection', 'find_series', 'compare_collection_site', 'search_series', 'edit_files', 'simple_phi', 'dciodvfy', 'ctp_details', 'select_for_phi', 'visual_review_new_workflow'], 'posda_files', 'Get Series in A Collection, site with dicom_file_type, modality, and sop_count
')
        ;

            insert into queries
            values ('Sops In Public By Series', 'select 
  tdp.project as collection, dp_site_name as site, patient_id,
  study_instance_uid, series_instance_uid, sop_instance_uid 
from
  general_image i, trial_data_provenance tdp
where
  tdp.trial_dp_pk_id = i.trial_dp_pk_id and series_instance_uid = ?
', ARRAY['series_instance_uid'], 
                    ARRAY['collection', 'site', 'patient_id', 'study_instance_uid', 'series_instance_uid', 'sop_instance_uid'], ARRAY['Reconcile Public and Posda for CPTAC'], 'public', 'Get the list of files by sop, excluding base series')
        ;

            insert into queries
            values ('RowsInDicomFileWithNoPixelInfo', 'select 
  file_id, root_path || ''/'' || rel_path as path
from dicom_file natural join file_location natural join file_storage_root
where has_pixel_data is null limit ?', ARRAY['num_rows'], 
                    ARRAY['file_id', 'path'], ARRAY['adding_pixels_to_dicom_file'], 'posda_files', 'List of files (id, path) which are dicom_files with undefined pixel info')
        ;

            insert into queries
            values ('AllSeenValuesByElementVr', 'select distinct value 
from element_value_occurance natural join value_seen natural join element_seen
where element_sig_pattern = ? and vr = ? order by value', ARRAY['element_sig_pattern', 'vr'], 
                    ARRAY['value'], ARRAY['NotInteractive', 'used_in_reconcile_tag_names'], 'posda_phi_simple', 'Get the relevant features of an element_signature in posda_phi_simple schema')
        ;

            insert into queries
            values ('TagsSeen', 'select
  element_signature, vr, is_private, private_disposition, name_chain
from
  element_signature order by element_signature', '{}', 
                    ARRAY['element_signature', 'vr', 'is_private', 'private_disposition', 'name_chain'], ARRAY['by_collection', 'find_series', 'compare_collection_site', 'search_series', 'edit_files', 'phi_maint'], 'posda_phi', 'Get all the data from tags_seen in posda_phi database
')
        ;

            insert into queries
            values ('CountsByCollectionSiteSubjectDateRange', 'select
  distinct
    patient_id, image_type, modality, study_date, study_description,
    series_description, study_instance_uid, series_instance_uid,
    manufacturer, manuf_model_name, software_versions,
    count(distinct sop_instance_uid) as num_sops,
    count(distinct file_id) as num_files,
    min(import_time) as earliest,
    max(import_time) as latest
from
  ctp_file join file_patient using(file_id)
  join file_series using(file_id)
  join file_sop_common using(file_id)
  join file_study using(file_id)
  join file_equipment using(file_id)
  join file_import using(file_id)
  join import_event using(import_event_id)
  left join file_image using(file_id)
  left join image using (image_id)
where
  project_name = ? and site_name = ? and patient_id = ? and visibility is null
  and import_time > ? and import_time < ?
group by
  patient_id, image_type, modality, study_date, study_description,
  series_description, study_instance_uid, series_instance_uid,
  manufacturer, manuf_model_name, software_versions
order by
  patient_id, study_instance_uid, series_instance_uid, image_type,
  modality, study_date, study_description,
  series_description,
  manufacturer, manuf_model_name, software_versions
', ARRAY['collection', 'site', 'subject', 'from', 'to'], 
                    ARRAY['patient_id', 'image_type', 'modality', 'study_date', 'study_description', 'series_description', 'study_instance_uid', 'series_instance_uid', 'manufacturer', 'manuf_model_name', 'software_versions', 'num_sops', 'num_files', 'earliest', 'latest'], ARRAY['counts', 'count_queries'], 'posda_files', 'Counts query by Collection, Site
')
        ;

            insert into queries
            values ('GetDciodvfyScanDesc', 'select 
  type_of_unit,
  description_of_scan,
  number_units,
  scanned_so_far,
  start_time,
  end_time
from 
  dciodvfy_scan_instance
where dciodvfy_scan_instance_id = ?
', ARRAY['scan_id'], 
                    ARRAY['type_of_unit', 'description_of_scan', 'number_units', 'scanned_so_far', 'start_time', 'end_time'], ARRAY['tag_usage', 'dciodvfy'], 'posda_phi_simple', 'Get info about a dciodvfy scan')
        ;

            insert into queries
            values ('WhereFileSits', 'select distinct
  project_name as collection,
  site_name as site,
  patient_id,
  study_instance_uid,
  series_instance_uid,
  sop_instance_uid
from
  file_patient natural join
  file_study natural join
  file_series natural join
  file_sop_common natural left join
  ctp_file
where file_id = ? and visibility is null', ARRAY['file_id'], 
                    ARRAY['collection', 'site', 'patient_id', 'study_instance_uid', 'series_instance_uid', 'sop_instance_uid'], ARRAY['posda_files', 'sops', 'BySopInstance', 'by_file'], 'posda_files', 'Get Collection, Site, Patient, Study Hierarchy in which SOP resides
')
        ;

            insert into queries
            values ('AllValuesByElementSigIdAndScanId', 'select
  distinct value
from
  seen_value natural join scan_element
where
  element_signature_id = ? and series_scan_id in (
  select
    series_scan_id 
  from 
    series_scan
  where 
    scan_event_id = ?
  )
order by value
', ARRAY['element_signature_id', 'scan_id'], 
                    ARRAY['value'], ARRAY['tag_usage'], 'posda_phi', 'List of values seen in scan with specified tag
')
        ;

            insert into queries
            values ('MarkFileAsInPosda', 'update request
set
  file_in_posda = true,
  time_entered = now(),
  posda_file_id = ?
where
  request_id = ?

', ARRAY['posda_file_id', 'request_id'], 
                    '{}', ARRAY['NotInteractive', 'Backlog'], 'posda_backlog', 'Update a request status to indicate file in Posda')
        ;

            insert into queries
            values ('ListOfPrivateElementsWithDispositionsByScanId', 'select
  distinct element_signature, vr , private_disposition as disposition,
  element_signature_id, name_chain
from
  element_signature natural join scan_element natural join series_scan
where
  is_private and scan_event_id = ?
order by element_signature
', ARRAY['scan_id'], 
                    ARRAY['element_signature', 'vr', 'disposition', 'element_signature_id', 'name_chain'], ARRAY['NotInteractive', 'Update', 'ElementDisposition'], 'posda_phi', 'Get Disposition of element by sig and VR')
        ;

            insert into queries
            values ('DistinctSopsInCollection', 'select distinct sop_instance_uid
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
', ARRAY['collection'], 
                    ARRAY['sop_instance_uid'], ARRAY['by_collection', 'posda_files', 'sops'], 'posda_files', 'Get Distinct SOPs in Collection with number files
Only visible files
')
        ;

            insert into queries
            values ('PatientStudySeriesFileHierarchyByCollectionExcludingSeriesByDescription', 'select distinct
  patient_id,
  study_instance_uid,
  series_instance_uid,
  sop_instance_uid,
  root_path || ''/'' || rel_path as path
from
  file_study natural join ctp_file natural join file_series natural join file_patient
  natural join file_sop_common natural join file_location
  natural join file_storage_root
where 
  file_id in (
    select distinct file_id
    from ctp_file natural join file_series
    where project_name = ? and visibility is null and series_description not like ?
  )
order by patient_id, study_instance_uid, series_instance_uid', ARRAY['collection', 'exclude_series_descriptions_matching'], 
                    ARRAY['patient_id', 'study_instance_uid', 'series_instance_uid', 'path'], ARRAY['Hierarchy'], 'posda_files', 'Construct list of files in a collection in a Patient, Study, Series Hierarchy excluding series by series_description')
        ;

            insert into queries
            values ('GetAllQualifiedCTQPByLikeCollectionWithFileCountAndLoadTimesAndStudyDateOnlySinceDate', 'select * from (select 
  collection, site, patient_id, qualified, study_date,
  count(distinct file_id) as num_files, count (distinct sop_instance_uid) as num_sops,
  min(date_trunc(''day'',import_time)) as earliest_day, max(date_trunc(''day'', import_time)) as latest_day
from
  clinical_trial_qualified_patient_id join file_patient using (patient_id) 
  join file_study using(file_id) join file_import using(file_id)
  join file_sop_common using(file_id)
  join import_event using(import_event_id)
where collection like ?
group by collection, site, patient_id, qualified, study_date) as foo where earliest_day >= ? ', ARRAY['collection_like', 'from'], 
                    ARRAY['collection', 'site', 'patient_id', 'qualified', 'num_files', 'num_sops', 'earliest_day', 'latest_day'], ARRAY['clin_qual'], 'posda_files', 'Create An Activity Timepoint

')
        ;

            insert into queries
            values ('PatientStudySeriesFileHierarchyByCollectionIncludingSeriesByDescription', 'select distinct
  patient_id,
  study_instance_uid,
  series_instance_uid,
  sop_instance_uid,
  root_path || ''/'' || rel_path as path
from
  file_study natural join ctp_file natural join file_series natural join file_patient
  natural join file_sop_common natural join file_location
  natural join file_storage_root
where 
  file_id in (
    select distinct file_id
    from ctp_file natural join file_series
    where project_name = ? and visibility is null and series_description like ?
  )
order by patient_id, study_instance_uid, series_instance_uid', ARRAY['collection', 'exclude_series_descriptions_matching'], 
                    ARRAY['patient_id', 'study_instance_uid', 'series_instance_uid', 'path'], ARRAY['Hierarchy'], 'posda_files', 'Construct list of files in a collection in a Patient, Study, Series Hierarchy excluding series by series_description')
        ;

            insert into queries
            values ('DuplicateSOPInstanceUIDsGlobalWithHidden', 'select distinct collection, site, patient_id, count(*)
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
', '{}', 
                    ARRAY['collection', 'site', 'patient_id', 'count'], ARRAY['receive_reports'], 'posda_files', 'Return a report of duplicate SOP Instance UIDs ignoring visibility
')
        ;

            insert into queries
            values ('FindQueryByTag', 'select
  distinct name from (
  select name, unnest(tags) as tag
  from queries) as foo
where
  tag = ?', ARRAY['tag_name'], 
                    ARRAY['name'], ARRAY['meta', 'test', 'hello'], 'posda_queries', 'Find all queries matching tag')
        ;

            insert into queries
            values ('DistinctVisibleFileReportBySeries', 'select distinct
	coalesce(project_name, ''UNKNOWN'') as collection,
	coalesce(site_name, ''UNKNOWN'') as site,
	patient_id,
	study_instance_uid,
	series_instance_uid,
	sop_instance_uid,
	dicom_file_type,
	modality,
	file_id
from
	file_patient
	natural join file_study
	natural join file_series
	natural join file_sop_common
	natural join dicom_file
	natural left join ctp_file
where
	series_instance_uid = ?
	and visibility is null
order by series_instance_uid
', ARRAY['series_instance_uid'], 
                    ARRAY['collection', 'site', 'patient_id', 'study_instance_uid', 'series_instance_uid', 'sop_instance_uid', 'dicom_file_type', 'modality', 'file_id'], ARRAY['by_collection', 'find_series', 'compare_collection_site', 'search_series', 'edit_files', 'simple_phi', 'dciodvfy', 'ctp_details', 'select_for_phi', 'visual_review_selection', 'activity_timepoints'], 'posda_files', 'Get Series in A Collection, site with dicom_file_type, modality, and sop_count
')
        ;

            insert into queries
            values ('SubjectsWithDupSopsWithStudySeries', 'select 
  distinct project_name, site_name, patient_id, count(distinct file_id)
from
  ctp_file natural join file_sop_common natural join file_patient
where sop_instance_uid in (
  select distinct sop_instance_uid
  from (
    select
      distinct sop_instance_uid, count(*)
    from (
      select
        sop_instance_uid, study_instance_uid, series_instance_uid
      from
        file_sop_common natural join file_series natural join file_study
    )as foo group by sop_instance_uid
  ) as foo where count > 1
)
group by
  project_name, site_name, patient_id
order by 
  project_name, site_name, patient_id, count desc
  ', '{}', 
                    ARRAY['project_name', 'site_name', 'patient_id', 'count'], ARRAY['pix_data_dups'], 'posda_files', 'Find list of series with SOP with conflicting study or series')
        ;

            insert into queries
            values ('GetScanEventId', 'select currval(''series_scan_series_scan_id_seq'') as id', '{}', 
                    '{}', ARRAY['UsedInPhiSeriesScan', 'NotInteractive'], 'posda_phi', 'List of values seen in scan by VR (with count of elements)
')
        ;

            insert into queries
            values ('GetCountSsVolumeBySeriesUid', 'select
  distinct sop_instance_uid, count(distinct sop_instance_link) as num_links 
from (
  select 
    sop_instance_uid, for_uid, study_instance_uid, series_instance_uid,
    sop_class as sop_class_uid, sop_instance as sop_instance_link
  from
    ss_for natural join ss_volume natural join
    file_structure_set join file_sop_common using (file_id)
  where structure_set_id in (
    select 
      structure_set_id 
    from
      file_structure_set fs, file_sop_common sc
    where
      sc.file_id = fs.file_id and sop_instance_uid in (
         select distinct sop_instance_uid from file_sop_common natural join file_series
         where series_instance_uid = ?
     )
  )
) as foo 
group by sop_instance_uid', ARRAY['series_instance_uid'], 
                    ARRAY['sop_instance_uid', 'num_links'], ARRAY['Structure Sets', 'sops', 'LinkageChecks'], 'posda_files', 'Get Structure Set Volume

')
        ;

            insert into queries
            values ('tags_by_role', 'select
  filter_name as role, unnest(tags_enabled) as tag
from query_tag_filter where filter_name = ?', ARRAY['role'], 
                    ARRAY['role', 'tag'], ARRAY['roles'], 'posda_queries', 'Show a complete list of associated tags for a role
')
        ;

            insert into queries
            values ('AddBackgroundTimeAndRowsToBackgroundProcess', 'update background_subprocess set
  when_background_entered = now(),
  input_rows_processed = ?,
  background_pid = ?
where
  background_subprocess_id = ?

', ARRAY['input_rows', 'background_pid', 'background_subprocess_id'], 
                    NULL, ARRAY['NotInteractive', 'used_in_background_processing'], 'posda_queries', 'N
o
n
e')
        ;

            insert into queries
            values ('ActivityTimepointsForActivity', 'select
  distinct activity_id, a.when_created as activity_created,
  brief_description as activity_description, activity_timepoint_id,
  t.when_created as timepoint_created, 
  comment, creating_user, count(distinct file_id) as num_files
from
  activity a join activity_timepoint t using(activity_id) join 
  activity_timepoint_file using(activity_timepoint_id)
where
  activity_id = ?
group by
  activity_id, activity_created, activity_description, activity_timepoint_id,
  timepoint_created, comment, creating_user
order by activity_timepoint_id desc', ARRAY['activity_id'], 
                    ARRAY['activity_id', 'activity_created', 'activity_description', 'activity_timepoint_id', 'timepoint_created', 'comment', 'creating_user', 'num_files'], ARRAY['by_collection', 'find_series', 'compare_collection_site', 'search_series', 'edit_files', 'simple_phi', 'dciodvfy', 'ctp_details', 'select_for_phi', 'visual_review_selection', 'activity_timepoints'], 'posda_queries', 'Get Series in A Collection, site with dicom_file_type, modality, and sop_count
')
        ;

            insert into queries
            values ('SelectCtInfoSummaryByCollection', 'select 
  distinct 
  project_name as collection,
  site_name as site,
  patient_id,
  series_instance_uid,
  kvp,
  scan_options,
  data_collection_diameter,
  reconstruction_diameter,
  dist_source_to_detect,
  dist_source_to_pat,
  gantry_tilt,
  rotation_dir,
  exposure_time,
  filter_type,
  generator_power, 
  convolution_kernal,
  table_feed_per_rot,
  count(*) as num_files
from file_ct_image natural join file_patient natural join file_series natural join ctp_file 
where project_name = ? and visibility is null
group by
  collection,
  site,
  patient_id,
  series_instance_uid,
  kvp,
  scan_options,
  data_collection_diameter,
  reconstruction_diameter,
  dist_source_to_detect,
  dist_source_to_pat,
  gantry_tilt,
  rotation_dir,
  exposure_time,
  filter_type,
  generator_power, 
  convolution_kernal,
  table_feed_per_rot
order by patient_id', ARRAY['collection'], 
                    ARRAY['collection', 'site', 'patient_id', 'series_instance_uid', 'kvp', 'scan_options', 'data_collection_diameter', 'reconstruction_diameter', 'dist_source_to_detect', 'dist_source_to_pat', 'gantry_tilt', 'rotation_dir', 'exposure_time', 'filter_type', 'generator_power', 'convolution_kernal', 'table_feed_per_rot'], ARRAY['populate_posda_files', 'bills_test'], 'posda_files', 'Gets count of all files which are PET''s which haven''t been imported into file_pt_image yet.

')
        ;

            insert into queries
            values ('EquivalenceClassStatusSummaryByCollection', 'select
  distinct project_name as collection,
  processing_status,
  review_status, count(distinct image_equivalence_class_id)
from
  image_equivalence_class join file_series using(series_instance_uid) join ctp_file using(file_id)
where project_name = ?
group by collection, processing_status, review_status', ARRAY['collection'], 
                    ARRAY['collection', 'processing_status', 'review_status', 'count'], ARRAY['find_series', 'equivalence_classes', 'consistency', 'visual_review'], 'posda_files', 'Find Series with more than n equivalence class')
        ;

            insert into queries
            values ('PatientReport', 'select
  distinct project_name as collection,
  site_name as site,
  patient_id, study_instance_uid, study_description,
  series_instance_uid, series_description,
  count(distinct file_id) as num_files,
  min(import_time) as earliest_upload,
  max(import_time) as latest_upload,
  count(distinct import_event_id) as num_uploads
from
  file_patient natural join file_study natural join
  file_series natural join ctp_file natural join
  file_import natural join import_event
where
  project_name = ? and
  site_name = ? and
  patient_id = ?
  and visibility is null
group by 
  collection, site,
  patient_id, study_instance_uid, study_description,
  series_instance_uid, series_description
order by
  study_instance_uid, series_instance_uid, num_files', ARRAY['collection', 'site', 'patient_id'], 
                    ARRAY['collection', 'site', 'patient_id', 'study_instance_uid', 'study_description', 'series_instance_uid', 'series_description', 'num_files', 'earliest_upload', 'latest_upload', 'num_uploads'], ARRAY['meta', 'test', 'hello', 'bills_test'], 'posda_files', 'Add a filter to a tab')
        ;

            insert into queries
            values ('VisualReviewScanInstances', 'select 
  visual_review_instance_id as id, visual_review_reason as reason,
  visual_review_scheduler as who_by, visual_review_num_series as num_series,
  when_visual_review_scheduled as when_scheduled,
  visual_review_num_series_done as num_done,
  visual_review_num_equiv_class as num_equiv,
  when_visual_review_sched_complete as sched_finish_time
from visual_review_instance
  order by when_scheduled desc', '{}', 
                    ARRAY['id', 'reason', 'who_by', 'num_series', 'when_scheduled', 'num_done', 'num_equiv', 'sched_finish_time'], ARRAY['by_collection', 'find_series', 'compare_collection_site', 'search_series', 'edit_files', 'simple_phi', 'dciodvfy', 'ctp_details', 'select_for_phi', 'visual_review_status'], 'posda_files', 'Get Series in A Collection, site with dicom_file_type, modality, and sop_count
')
        ;

            insert into queries
            values ('GetUsersBoundVariables', 'select
  binding_user as user,
  bound_variable_name as variable,
  bound_value as  value
from
  user_variable_binding
where
  binding_user = ?

', ARRAY['user'], 
                    ARRAY['user', 'variable', 'binding'], ARRAY['AllCollections', 'queries', 'activity_support', 'variabler_binding'], 'posda_queries', 'Get list of variables with bindings for a user')
        ;

            insert into queries
            values ('HowManyFilesToHideInCopyFromPublic', 'select
  count(*) as num_to_hide
from file_copy_from_public c, ctp_file p
where
  c.copy_from_public_id = ? and
  (p.file_id = c.replace_file_id and p.visibility is null) ', ARRAY['copy_from_public_id'], 
                    ARRAY['num_to_hide'], ARRAY['bills_test', 'copy_from_public'], 'posda_files', 'Add a filter to a tab')
        ;

            insert into queries
            values ('PosdaTotalsWithDateRange', 'select 
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
', ARRAY['start_time', 'end_time'], 
                    ARRAY['project_name', 'site_name', 'num_subjects', 'num_studies', 'num_series', 'total_files'], '{}', 'posda_files', 'Get posda totals by date range
')
        ;

            insert into queries
            values ('CreateBackgroundSubprocessError', 'insert into background_subprocess(
  subprocess_invocation_id,
  input_rows_processed,
  command_executed,
  foreground_pid,
  background_pid,
  when_script_started,
  when_background_entered,
  user_to_notify,
  process_error
) values (
  ?, ?, ?, ?, ?, ?, now(), ?, ?
)', ARRAY['subprocess_invocation_id', 'input_rows_processed', 'command_executed', 'foreground_pid', 'background_pid', 'when_script_started', 'user_to_notify', 'process_error'], 
                    '{}', ARRAY['NotInteractive', 'used_in_background_processing'], 'posda_queries', 'Create row in background_subprocess table with an error in initialization

Used by background subprocess')
        ;

            insert into queries
            values ('ListOpenActivitiesOld', 'select
  activity_id,
  brief_description,
  when_created,
  who_created
from
  activity
where when_closed is null
order by activity_id desc', '{}', 
                    ARRAY['activity_id', 'brief_description', 'when_created', 'who_created'], ARRAY['AllCollections', 'queries', 'activity_support'], 'posda_queries', 'Get a list of available queries')
        ;

            insert into queries
            values ('PatientStudySeriesHierarchyByCollectionSiteWithDateRange', 'select distinct
  patient_id,
  study_instance_uid,
  series_instance_uid
from
  file_study natural join 
  ctp_file natural join 
  file_series natural join 
  file_patient
where 
  file_id in (
    select distinct file_id
    from 
      ctp_file  natural join
      file_import natural join
      import_event
    where project_name = ? and site_name = ? and
    visibility is null and
    import_time > ? and import_time < ?
  )
order by patient_id, study_instance_uid, series_instance_uid', ARRAY['collection', 'site', 'from', 'to'], 
                    ARRAY['patient_id', 'study_instance_uid', 'series_instance_uid'], ARRAY['Hierarchy', 'apply_disposition'], 'posda_files', 'Construct list of files in a collection, site in a Patient, Study, Series Hierarchy with upload times within a date range')
        ;

            insert into queries
            values ('GetZipUploadEventsByDateRange', 'select distinct import_event_id, count(distinct file_id)  as num_files 
from file_import natural join import_event
where
import_time > ? and import_time < ? and import_comment = ''zip''
group by import_event_id', ARRAY['from', 'to'], 
                    ARRAY['import_event_id', 'num_files'], ARRAY['radcomp'], 'posda_files', 'Add a filter to a tab')
        ;

            insert into queries
            values ('GetFilesAndSopsBySeries', 'select 
  distinct patient_id,
  study_instance_uid,
  series_instance_uid,
  sop_instance_uid,
  file_id, 
  root_path || ''/'' || rel_path as path
from
  file_patient natural join
  file_study natural join
  file_series natural join
  file_sop_common natural join
  file_location natural join
  file_storage_root natural left join
  ctp_file
where 
  series_instance_uid = ? and
  visibility is null', ARRAY['series_instance_uid'], 
                    ARRAY['patient_id', 'study_instance_uid', 'series_instance_uid', 'sop_instance_uid', 'file_id', 'path'], ARRAY['ImageEdit', 'edit_files'], 'posda_files', 'Get File id and visibility for all files in a series')
        ;

            insert into queries
            values ('PublicSeriesByCollection', 'select
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
  tdp.project = ? 
', ARRAY['collection'], 
                    ARRAY['PID', 'Modality', 'StudyDate', 'StudyDescription', 'SeriesDescription', 'SeriesNumber', 'StudyInstanceUID', 'SeriesInstanceUID', 'Mfr', 'Model', 'software_versions'], ARRAY['public'], 'public', 'List of all Series By Collection, Site on Public
')
        ;

            insert into queries
            values ('FirstFilesInSeries', 'select root_path || ''/'' || rel_path as path
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
', ARRAY['series_instance_uid'], 
                    ARRAY['path'], ARRAY['by_series'], 'posda_files', 'First files uploaded by series
')
        ;

            insert into queries
            values ('GetEquipmentSignature', 'select * from equipment_signature where equipment_signature = ?
', ARRAY['equipment_signature'], 
                    ARRAY['equipment_signature_id', 'equipment_signature'], ARRAY['UsedInPhiSeriesScan', 'NotInteractive'], 'posda_phi', 'Get Equipment Signature Id')
        ;

            insert into queries
            values ('GetElemenSeenIdBySig', 'select element_seen_id
from element_seen
where element_sig_pattern = ?', ARRAY['element_sig_pattern'], 
                    ARRAY['element_seen_id'], ARRAY['NotInteractive', 'ElementDisposition', 'phi_maint'], 'posda_phi_simple', 'Get List of Private Elements By Disposition')
        ;

            insert into queries
            values ('BackgroundSubprocessBySubprocessId', 'select 
  background_subprocess_id, subprocess_invocation_id, 
  input_rows_processed,  when_script_started, when_background_entered,
  when_script_ended, user_to_notify, process_error
from 
  background_subprocess
where 
  subprocess_invocation_id = ?
order by when_script_started desc', ARRAY['subprocess_invocaton_id'], 
                    ARRAY['background_subprocess_id', 'subprocess_invocation_id', 'input_rows_processed', 'when_script_started', 'when_background_entered', 'when_script_ended', 'user_to_notify', 'process_error'], ARRAY['meta', 'test', 'hello', 'query_tabs', 'bills_test', 'subprocess'], 'posda_queries', 'Add a filter to a tab')
        ;

            insert into queries
            values ('DistinctSeriesByCollectionSiteBatch', 'select distinct series_instance_uid, dicom_file_type, modality, count(distinct file_id)
from
  file_study natural join file_series natural join dicom_file natural join ctp_file
where
  project_name = ? and site_name = ? and batch = ? and visibility is null
group by series_instance_uid, dicom_file_type, modality
', ARRAY['project_name', 'site_name', 'batch'], 
                    ARRAY['series_instance_uid', 'dicom_file_type', 'modality', 'count'], ARRAY['by_collection', 'find_series', 'compare_collection_site', 'search_series', 'edit_files', 'simple_phi', 'dciodvfy'], 'posda_files', 'Get Series in A Collection, site with dicom_file_type, modality, and sop_count
')
        ;

            insert into queries
            values ('GetFilesWithSeriesButNoStudy', 'select 
  distinct file_id
from
  file_series se natural join ctp_file
where
  not exists (
    select file_id from file_study st where st.file_id = se.file_id
  ) and
  visibility is null
  and project_name = ?', ARRAY['collection'], 
                    ARRAY['file_id'], ARRAY['posda_db_populate', 'dicom_file_type'], 'posda_files', 'Add a filter to a tab')
        ;

            insert into queries
            values ('GetWeeksRangeByDate', 'select 
  date_trunc(''week'', foo) as start_week,
  date_trunc(''week'', foo + interval ''7 days'') as end_week,
  date_trunc(''day'', foo + interval ''1 day'') as end_partial_week
where foo in (
  select to_timestamp(?, ''yyyy-mm-dd'') as foo
)', ARRAY['from'], 
                    ARRAY['start_week', 'end_week', 'end_partial_week'], ARRAY['downloads_by_date'], 'posda_files', 'Counts query by Collection, Site
')
        ;

            insert into queries
            values ('FindTagsInQueries', 'select
  distinct tag from (
  select name, unnest(tags) as tag
  from queries) as foo
order by tag', '{}', 
                    ARRAY['tag'], ARRAY['meta', 'test', 'hello', 'query_tags'], 'posda_queries', 'Find all queries matching tag')
        ;

            insert into queries
            values ('FindQueryMatching', 'select
  distinct name
from
  queries
where
  query ~ ?
order by name', ARRAY['query_matching'], 
                    ARRAY['name'], ARRAY['meta', 'test', 'hello'], 'posda_queries', 'Find all queries with name matching arg')
        ;

            insert into queries
            values ('DuplicateSOPInstanceUIDsGlobalWithoutHidden', 'select
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
', '{}', 
                    ARRAY['collection', 'site', 'patient_id', 'study_instance_uid', 'series_instance_uid', 'sop_instance_uid', 'file_id'], ARRAY['receive_reports'], 'posda_files', 'Return a report of visible duplicate SOP Instance UIDs
')
        ;

            insert into queries
            values ('ActivityStuffMoreForAllByDateRange', 'select
  distinct subprocess_invocation_id, background_subprocess_id, user_inbox_content_id,
  background_subprocess_report_id, file_id,
  background_subprocess_report.name as report_type,
  activity_id, when_script_started,
  when_background_entered, when_script_ended, 
  invoking_user, user_to_notify, button_name,
  operation_name, command_line
from
  subprocess_invocation natural left join background_subprocess natural left join background_subprocess_report
  natural left join user_inbox_content natural left join activity_inbox_content
where when_script_started >= ? and when_script_ended <= ?
order by subprocess_invocation_id desc
', ARRAY['from', 'to'], 
                    ARRAY['subprocess_invocation_id', 'background_subprocess_id', 'user_inbox_content_id', 'background_subprocess_report_id', 'file_id', 'report_type', 'activity_id', 'when_script_started', 'when_background_entered', 'when_script_ended', 'invoking_user', 'user_to_notify', 'button_name', 'operation_name', 'command_line'], ARRAY['activity_timepoint_support'], 'posda_queries', 'Create An Activity Timepoint

')
        ;

            insert into queries
            values ('subprocess_invocations', 'select command_line, when_invoked, spreadsheet_uploaded_id from subprocess_invocation
where from_spreadsheet
order by when_invoked', '{}', 
                    ARRAY['command_line', 'when_invoked', 'spreadsheet_uploaded_id'], ARRAY['meta', 'test', 'hello', 'query_tabs', 'bills_test'], 'posda_queries', 'Add a filter to a tab')
        ;

            insert into queries
            values ('ValuesWithVrTagAndCountLimited', 'select distinct vr, value, element_signature, num_files from (
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
', ARRAY['scan_id'], 
                    ARRAY['vr', 'value', 'element_signature', 'num_files'], ARRAY['tag_usage'], 'posda_phi', 'List of values seen in scan by VR (with count of elements)
')
        ;

            insert into queries
            values ('PossiblyRunningBackgroundSubprocesses', 'select
  subprocess_invocation_id, background_subprocess_id,
  when_script_started, when_background_entered, command_line,
  now()-when_background_entered as time_in_background, background_pid
from
  subprocess_invocation natural join background_subprocess
where
  when_background_entered is not null and when_script_ended is null and
  subprocess_invocation_id != 0 and crash is null
order by subprocess_invocation_id', '{}', 
                    ARRAY['subprocess_invocation_id', 'background_subprocess_id', 'when_script_started', 'when_background_entered', 'command_line', 'time_in_background', 'background_pid'], ARRAY['meta', 'test', 'hello', 'query_tabs', 'bills_test', 'subprocess'], 'posda_queries', 'Add a filter to a tab')
        ;

            insert into queries
            values ('PatientStudySeriesHierarchyByCollectionMatchingSeriesDesc', 'select distinct
  patient_id,
  study_instance_uid,
  series_instance_uid
from
  file_study natural join ctp_file natural join file_series natural join file_patient
where 
  file_id in (
    select distinct file_id
    from ctp_file natural join file_series
    where project_name = ? and visibility is null and series_description like ?
  )
order by patient_id, study_instance_uid, series_instance_uid', ARRAY['collection', 'series_descriptions_matching'], 
                    ARRAY['patient_id', 'study_instance_uid', 'series_instance_uid'], ARRAY['Hierarchy'], 'posda_files', 'Construct list of series in a collection in a Patient, Study, Series Hierarchy excluding matching SeriesDescriptons')
        ;

            insert into queries
            values ('ListOfQueriesPerformedAllWithLatestAndCount', 'select
  query_name,
  max(query_start_time) as last_invocation, 
  count(query_invoked_by_dbif_id) as num_invocations,
  sum(query_end_time - query_start_time) as total_query_time,
  avg(query_end_time - query_start_time) as avg_query_time
from 
  query_invoked_by_dbif
group by query_name
order by last_invocation  desc', '{}', 
                    ARRAY['query_name', 'last_invocation', 'num_invocations', 'total_query_time', 'avg_query_time'], ARRAY['AllCollections', 'q_stats'], 'posda_queries', 'Get a list of collections and sites
')
        ;

            insert into queries
            values ('SeriesByDistinguishedDigest', 'select
  distinct project_name as collection,
  site_name as site,
  patient_id,
  series_instance_uid,
  count(distinct sop_instance_uid) as num_sops
from
  ctp_file natural join
  file_patient natural
  join file_series natural
  join file_sop_common
where file_id in(
  select file_id 
  from
    file_image
    join image using (image_id)
    join unique_pixel_data using (unique_pixel_data_id)
  where digest = ?
  ) and visibility is null
group by collection, site, patient_id, series_instance_uid
order by collection, site, patient_id', ARRAY['distinguished_pixel_digest'], 
                    ARRAY['collection', 'site', 'patient_id', 'series_instance_uid', 'num_sops'], ARRAY['duplicates', 'distinguished_digest'], 'posda_files', 'show series with distinguished digests and counts')
        ;

            insert into queries
            values ('PublicDifferenceReportBySubprocessId', 'select
  distinct short_report_file_id, long_report_file_id,
  count(distinct sop_instance_uid) as num_sops,
  count(distinct from_file_id) as num_files
from posda_public_compare
where background_subprocess_id =?
group by short_report_file_id, long_report_file_id order by short_report_file_id', ARRAY['subprocess_invocation_id'], 
                    ARRAY['short_report_file_id', 'long_report_file_id', 'num_sops', 'num_files'], ARRAY['used_in_file_import_into_posda', 'used_in_file_migration'], 'posda_files', 'Get count of files relative to storage root')
        ;

            insert into queries
            values ('DatabaseSizes', 'select d.datname AS Name,  pg_catalog.pg_get_userbyid(d.datdba) AS Owner,
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
    LIMIT 20
', '{}', 
                    ARRAY['name', 'owner', 'size'], ARRAY['AllCollections', 'postgres_stats', 'database_size'], 'posda_files', 'Get a list of collections and sites
')
        ;

            insert into queries
            values ('CreateDicomEditCompareDisposition', 'insert into dicom_edit_compare_disposition(
  subprocess_invocation_id, start_creation_time, current_disposition, process_pid, dest_dir
)values (
  ?, now(), ''Starting Up'', ?, ?
)', ARRAY['subprocess_invocation_id', 'process_pid', 'dest_dir'], 
                    '{}', ARRAY['adding_ctp', 'for_scripting'], 'posda_files', 'Create an entry in dicom_edit_compare_disposition

From script only.  Don''t run from user interface (needs valid subprocess_invocation_id)')
        ;

            insert into queries
            values ('FilePathComponentsByFileId', 'select
  root_path, rel_path
from
  file_location natural join file_storage_root
where
  file_id = ?', ARRAY['file_id'], 
                    ARRAY['root_path', 'rel_path'], ARRAY['SeriesSendEvent', 'by_series', 'find_files', 'for_send', 'for_comparing_dups', 'used_in_file_import_into_posda'], 'posda_files', 'Get file path from id')
        ;

            insert into queries
            values ('dicom_files_ids_with_no_ctp_file_like_pat', 'select 
  distinct patient_id,
  dicom_file_type, 
  modality, 
  file_id,
  root_path || ''/'' || rel_path as file_path
from
  dicom_file d natural join
  file_patient natural join 
  file_series natural join
  file_location natural join
  file_storage_root
where not exists (select file_id from ctp_file c where c.file_id = d.file_id) and patient_id like ?
', ARRAY['patient_id_pattern'], 
                    ARRAY['patient_id', 'dicom_file_type', 'modality', 'file_id', 'file_path'], ARRAY['meta', 'test', 'hello', 'query_tabs', 'bills_test'], 'posda_files', 'Add a filter to a tab')
        ;

            insert into queries
            values ('VisibilityChangeEventsByCollectionByHourNoSeries', 'select 
  distinct project_name as collection,
  site_name as site,
  patient_id,
  date_trunc(''hour'', time_of_change) as when_done,
  user_name, prior_visibility, new_visibility, reason_for, count(distinct file_id) as num_files,
  count (distinct series_instance_uid) as num_series
from
   ctp_file natural join file_patient natural join file_series natural join file_visibility_change 
where project_name = ?
group by
 collection, site, patient_id, when_done, user_name, prior_visibility, new_visibility, reason_for
order by when_done desc', ARRAY['collection'], 
                    ARRAY['collection', 'site', 'patient_id', 'when_done', 'user_name', 'prior_visibility', 'new_visibility', 'reason_for', 'num_files', 'num_series'], ARRAY['meta', 'test', 'hello', 'bills_test', 'hide_events', 'show_hidden'], 'posda_files', 'Add a filter to a tab')
        ;

            insert into queries
            values ('CreateDciodvfyUnitScanError', 'insert into dciodvfy_unit_scan_error(
  dciodvfy_scan_instance_id,
  dciodvfy_unit_scan_id,
  dciodvfy_error_id
)values (?, ?, ?)', ARRAY[' dicodvfy_scan_instance_id', 'dciodvfy_unit_scan_id', 'dciodvfy_error_id'], 
                    '{}', ARRAY['NotInteractive', 'used_in_dciodvfy'], 'posda_phi_simple', 'Create a dciodvfy_unit_scan_error row')
        ;

            insert into queries
            values ('FilePathCountAndLoadTimesBySopInstance', 'select
  distinct file_id,
  root_path || ''/'' || file_location.rel_path as path,
  min(import_time) as first_loaded,
  count(distinct import_time) as times_loaded,
  max(import_time) as last_loaded
from
  file_location
  natural join file_storage_root
  join file_import using(file_id)
  join import_event using (import_event_id)
  natural join file_sop_common
where sop_instance_uid = ?
group by file_id, path;', ARRAY['sop_instance_uid'], 
                    ARRAY['file_id', 'path', 'first_loaded', 'times_loaded', 'last_loaded'], ARRAY['SeriesSendEvent', 'by_series', 'find_files', 'for_send', 'for_comparing_dups'], 'posda_files', 'Get file path from id')
        ;

            insert into queries
            values ('SimplePhiReportAllRelevantPrivateOnlyNew', 'select 
  distinct ''<'' || element_sig_pattern || ''>''  as element, length(value) as val_length,
  vr, value, tag_name as description, private_disposition as disp, count(*) as num_series
from element_value_occurance natural join element_seen natural join value_seen
where 
  phi_scan_instance_id = ? and is_private and private_disposition not in (''d'', ''na'', ''h'', ''o'', ''oi'')
group by element_sig_pattern, vr, value, val_length, description, disp
order by vr, element, val_length', ARRAY['scan_id'], 
                    ARRAY['element', 'vr', 'value', 'description', 'disp', 'num_series'], ARRAY['tag_usage', 'simple_phi'], 'posda_phi_simple', 'Status of PHI scans
')
        ;

            insert into queries
            values ('PatientStatusChangeByCollection', 'select
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
', ARRAY['collection'], 
                    ARRAY['patient_id', 'from', 'to', 'by', 'why', 'when'], ARRAY['PatientStatus'], 'posda_files', 'Get History of Patient Status Changes by Collection
')
        ;

            insert into queries
            values ('FindInconsistentStudyIgnoringStudyTimeByCollectionLike', 'select distinct study_instance_uid from (
  select distinct study_instance_uid, count(*) from (
    select distinct
      study_instance_uid, study_date,
      referring_phy_name, study_id, accession_number,
      study_description, phys_of_record, phys_reading,
      admitting_diag
    from
      file_study natural join ctp_file
    where
      project_name like ? and visibility is null
    group by
      study_instance_uid, study_date,
      referring_phy_name, study_id, accession_number,
      study_description, phys_of_record, phys_reading,
      admitting_diag
  ) as foo
  group by study_instance_uid
) as foo
where count > 1
', ARRAY['collection_like'], 
                    ARRAY['study_instance_uid'], ARRAY['by_study', 'consistency', 'study_consistency'], 'posda_files', 'Find Inconsistent Studies
')
        ;

            insert into queries
            values ('Sops In Posda By Series', 'select 
  distinct project_name as collection, site_name as site, patient_id,
  study_instance_uid, series_instance_uid,
  modality, sop_instance_uid
from
  file_series natural join file_patient natural join ctp_file natural join
  file_sop_common natural join file_study
where file_id in (
  select
    file_id
from
    file_series natural join ctp_file
  where 
    visibility is null and series_instance_uid = ?
  )
', ARRAY['series_instance_uid'], 
                    ARRAY['collection', 'site', 'patient_id', 'study_instance_uid', 'series_instance_uid', 'modality', 'sop_instance_uid'], ARRAY['Reconcile Public and Posda for CPTAC'], 'posda_files', 'Get the list of files by sop, excluding base series')
        ;

            insert into queries
            values ('background_emails_by_date', 'select 
  background_subprocess_report_id as id, 
  button_name, operation_name, invoking_user, when_invoked, file_id, name
from background_subprocess_report natural join background_subprocess natural join subprocess_invocation where invoking_user = ? and name = ''Email'' and when_invoked > ? and when_invoked < ?
order by when_invoked desc', ARRAY['invoking_user', 'from', 'to'], 
                    ARRAY['id', 'button_name', 'operation_name', 'invoking_user', 'when_invoked', 'file_id', 'name'], ARRAY['meta', 'test', 'hello', 'query_tabs', 'bills_test'], 'posda_queries', 'Add a filter to a tab')
        ;

            insert into queries
            values ('FileStorageRootSummaryExtended', 'select 
  distinct file_storage_root_id,
  root_path,
  storage_class,
  count(distinct file_id) as num_files,
  sum(size) as total_bytes
from
  file_storage_root
  natural join file_location
  natural join file
group by file_storage_root_id, root_path, storage_class;', '{}', 
                    ARRAY['file_storage_root_id', 'root_path', 'storage_class', 'num_files', 'total_bytes'], ARRAY['used_in_file_import_into_posda', 'bills_test'], 'posda_files', 'Get count of files relative to storage root')
        ;

            insert into queries
            values ('GetUnkQualifiedCTQPByLikeCollectionSiteWithFIleCount', 'select 
  collection, site, patient_id, qualified, count(distinct file_id) as num_files
from
  clinical_trial_qualified_patient_id join file_patient using (patient_id)
where collection like ? and site = ? and qualified is null
group by collection, site, patient_id, qualified', ARRAY['collection_like', 'site'], 
                    ARRAY['collection', 'site', 'patient_id', 'qualified', 'num_files'], ARRAY['clin_qual'], 'posda_files', 'Create An Activity Timepoint

')
        ;

            insert into queries
            values ('GetToFileIdGivenFromFileId', 'select file_id as to_file_id from file where digest in (
select to_file_digest as digest from dicom_edit_compare where from_file_digest in
(select digest as from_file_digest from file where file_id = ?))', ARRAY['from_file_id'], 
                    ARRAY['to_file_id'], ARRAY['edit_status'], 'posda_files', 'Get List of visible patients with CTP data')
        ;

            insert into queries
            values ('SeriesNotScheduledForVisualReviewByCollectionSiteSummary', 'select 
  distinct
  series_instance_uid,
  dicom_file_type,
  modality,
  count(distinct file_id) as num_files
from 
  dicom_file natural join 
  file_series natural join 
  ctp_file
where
  file_id in (
    select file_id from file_series
    where series_instance_uid in
    (
       select distinct series_instance_uid
       from file_series fs natural join ctp_file
       where
         project_name = ? and
         site_name = ? and visibility is null
         and not exists (
           select series_instance_uid
           from image_equivalence_class ie
           where ie.series_instance_uid = fs.series_instance_uid
         )
    )
  )
group by
  series_instance_uid,
  dicom_file_type,
  modality', ARRAY['project_name', 'site_name'], 
                    ARRAY['series_instance_uid', 'dicom_file_type', 'modality', 'num_files'], ARRAY['find_series', 'equivalence_classes', 'consistency', 'visual_review_results', 'hide_files'], 'posda_files', 'Get Series which have no image_equivalence class by collection, site')
        ;

            insert into queries
            values ('SimplePublicPhiReportSelectedVrWithMetaquotes', 'select 
  distinct ''<'' || element_sig_pattern || ''>'' as element, vr, ''<'' || value || ''>'' as q_value, tag_name as description, 
  '' '' as disp, count(*) as num_series
from element_value_occurance natural join element_seen natural join value_seen
where 
  phi_scan_instance_id = ? and
  not is_private and
  vr in (''SH'', ''OB'', ''PN'', ''DA'', ''ST'', ''AS'', ''DT'', ''LO'', ''UI'', ''CS'', ''AE'', ''LT'', ''ST'', ''UC'', ''UN'', ''UR'', ''UT'')
group by element, vr, q_value, tag_name, disp
order by vr, element, q_value', ARRAY['scan_id'], 
                    ARRAY['element', 'vr', 'q_value', 'description', 'disp', 'num_series'], ARRAY['adding_ctp', 'for_scripting', 'phi_reports'], 'posda_phi_simple', 'Simple Phi Report with Meta Quotes')
        ;

            insert into queries
            values ('SendEventSummary', 'select
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
', '{}', 
                    ARRAY['reason_for_send', 'num_events', 'files_sent', 'earliest_send', 'finished', 'duration'], ARRAY['send_to_intake'], 'posda_files', 'Summary of SendEvents by Reason
')
        ;

            insert into queries
            values ('PatientStudySeriesHierarchyByCollectionSiteMatchingSeriesDesc', 'select distinct
  patient_id,
  study_instance_uid,
  series_instance_uid
from
  file_study natural join ctp_file natural join file_series natural join file_patient
where 
  file_id in (
    select distinct file_id
    from ctp_file natural join file_series
    where project_name = ? and site_name = ? 
    and visibility is null and series_description like ?
  )
order by patient_id, study_instance_uid, series_instance_uid', ARRAY['collection', 'site', 'series_descriptions_matching'], 
                    ARRAY['patient_id', 'study_instance_uid', 'series_instance_uid'], ARRAY['Hierarchy'], 'posda_files', 'Construct list of series in a collection in a Patient, Study, Series Hierarchy excluding matching SeriesDescriptons')
        ;

            insert into queries
            values ('GetLoadPathByImportEventId', 'select file_id, rel_path from file_import where import_event_id = ?', ARRAY['import_event_id'], 
                    ARRAY['file_id', 'rel_path'], ARRAY['radcomp'], 'posda_files', 'Add a filter to a tab')
        ;

            insert into queries
            values ('AllHiddenSubjects', 'select
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
', '{}', 
                    ARRAY['patient_id', 'project_name', 'site_name', 'num_files'], ARRAY['FindSubjects'], 'posda_files', 'Find All Subjects which have only hidden files
')
        ;

            insert into queries
            values ('Checking Duplicate Pixel Data By Series', 'select 
  distinct project_name as collection, site_name as site, patient_id,
  dicom_file_type, pixel_data_digest, sop_instance_uid
from
  file_series natural join file_patient natural join ctp_file natural join
  file_sop_common natural join dicom_file
where pixel_data_digest in (
  select
    distinct pixel_data_digest
  from
    file_series natural join ctp_file natural join dicom_file
  where 
    visibility is null and series_instance_uid = ?
  )
order by pixel_data_digest', ARRAY['series_instance_uid'], 
                    ARRAY['collection', 'site', 'patient_id', 'dicom_file_type', 'pixel_data_digest', 'sop_instance_uid'], ARRAY['CPTAC Bolus September 2018'], 'posda_files', 'Get the list of files by sop, excluding base series')
        ;

            insert into queries
            values ('SubjectsWithModalityByCollectionSiteIntake', 'select
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
', ARRAY['modality', 'project_name', 'site_name'], 
                    ARRAY['patient_id', 'modality', 'num_files'], ARRAY['FindSubjects', 'SymLink', 'intake'], 'intake', 'Find All Subjects with given modality in Collection, Site
')
        ;

            insert into queries
            values ('ListOfAvailableQueriesForDescEdit', 'select
  name, description, query,
  array_to_string(tags, '','') as tags
from queries
order by name', '{}', 
                    ARRAY['name', 'description', 'query', 'tags'], ARRAY['AllCollections', 'q_list'], 'posda_queries', 'Get a list of available queries')
        ;

            insert into queries
            values ('StartRound', 'update round
  set round_start = now()
where
  round_id = ?
', ARRAY['round_id'], 
                    '{}', ARRAY['NotInteractive', 'Backlog'], 'posda_backlog', 'Close row in round (set end time)')
        ;

            insert into queries
            values ('PrivateTagValuesWithVrTagAndCountWhereDispositionIsNull', 'select
  distinct vr , value, element_signature, private_disposition, count(*) as num_files
from
  element_signature natural left join scan_element natural left join series_scan natural left join seen_value
where
  is_private and private_disposition is null
group by
  vr, value, element_signature, private_disposition
', '{}', 
                    ARRAY['vr', 'value', 'element_signature', 'private_disposition', 'count'], ARRAY['DispositionReport', 'NotInteractive'], 'posda_phi', 'Get the disposition of a public tag by signature
Used in DispositionReport.pl - not for interactive use
')
        ;

            insert into queries
            values ('GetPosdaPhiElementSigInfo', 'select
  element_signature,
  vr,
  is_private,
  private_disposition,
  name_chain
from element_signature

', '{}', 
                    ARRAY['element_signature', 'vr', 'is_private', 'private_disposition', 'name_chain'], ARRAY['NotInteractive', 'used_in_reconcile_tag_names'], 'posda_phi', 'Get the relevant features of an element_signature in posda_phi schema')
        ;

            insert into queries
            values ('GetNonDicomFileScanId', 'select
  currval(''non_dicom_file_scan_non_dicom_file_scan_id_seq'') as id', '{}', 
                    ARRAY['id'], ARRAY['used_in_simple_phi', 'NotInteractive', 'non_dicom_phi'], 'posda_phi_simple', 'Get value seen if exists')
        ;

            insert into queries
            values ('InsertRoundCollection', 'insert into round_collection(
  round_id, collection,
  num_entered, num_failed,
  num_dups
) values (
  ?, ?,
  ?, ?,
  ?
)
', ARRAY['round_id', 'collection', 'num_entered', 'num_failed', 'num_dups'], 
                    '{}', ARRAY['NotInteractive', 'Backlog'], 'posda_backlog', 'Insert a row into round_collection')
        ;

            insert into queries
            values ('InsertIntoPublicPosdaFileComparison', 'insert into public_to_posda_file_comparison(
  compare_public_to_posda_instance_id,
  sop_instance_uid,
  posda_file_id,
  posda_file_path,
  public_file_path,
  short_report_file_id,
  long_report_file_id   
)values(
  ?, ?, ?, ?,
  ?, ?, ?
)
', ARRAY['compare_public_to_posda_instance_id', 'sop_instance_uid', 'posda_file_id', 'posda_file_path', 'public_file_path', 'short_report_file_id', 'long_report_file_id'], 
                    '{}', ARRAY['activity_timepoint_support'], 'posda_files', 'Insert a column into public_to_posda_file_comparison')
        ;

            insert into queries
            values ('get_file_to_fix_ctp', 'select
  file_id, root_path || ''/'' || file_location.rel_path as file_path 
from
  file_patient  natural join
  file_import natural join
  import_event join file_location using(file_id) join file_storage_root using (file_storage_root_id)
where 
  import_time > ? and not exists
  (select file_id from ctp_file where ctp_file.file_id = file_patient.file_id)
limit ?', ARRAY['from', 'limit'], 
                    ARRAY['file_id', 'file_path'], ARRAY['meta', 'test', 'hello', 'query_tabs', 'bills_test'], 'posda_files', 'Add a filter to a tab')
        ;

            insert into queries
            values ('GetEquipmentSignatureId', 'select currval(''equipment_signature_equipment_signature_id_seq'') as id', '{}', 
                    ARRAY['id'], ARRAY['NotInteractive', 'UsedInPhiSeriesScan'], 'posda_phi', 'Get current value of EquipmentSignatureId Sequence
')
        ;

            insert into queries
            values ('HowManyFilesCopiedInCopyFromPublic', 'select
  count(*) as num_copied
from file_copy_from_public
where
  copy_from_public_id = ? and
  inserted_file_id is not null', ARRAY['copy_from_public_id'], 
                    ARRAY['num_copied'], ARRAY['bills_test', 'copy_from_public'], 'posda_files', 'Add a filter to a tab')
        ;

            insert into queries
            values ('CancelQueryByPid', 'select 
  pg_cancel_backend(?)', ARRAY['pid'], 
                    ARRAY['pg_cancel_backend'], ARRAY['AllCollections', 'postgres_stats', 'postgres_query_stats'], 'posda_backlog', 'Get a list of collections and sites
')
        ;

            insert into queries
            values ('list_of_roles', 'select
  filter_name as role
from query_tag_filter', '{}', 
                    ARRAY['role'], ARRAY['roles'], 'posda_queries', 'Show a complete list of roles
')
        ;

            insert into queries
            values ('FilesVisibilityByCollectionSitePatient', 'select
  distinct project_name as collection,
  site_name as site,
  patient_id, file_id, visibility
from
  ctp_file natural join file_patient
where
  project_name = ? and
  site_name = ? and
  patient_id = ?
order by collection, site, patient_id

', ARRAY['collection', 'site', 'patient_id'], 
                    ARRAY['collection', 'site', 'patient_id', 'file_id', 'visibility'], ARRAY['duplicates', 'dup_sops', 'hide_dup_sops', 'sops_different_series'], 'posda_files', 'Return a count of duplicate SOP Instance UIDs
')
        ;

            insert into queries
            values ('FilesWithNoCtp', 'select
  distinct file_id
from
  file_patient p
where
  not exists(
  select file_id from ctp_file c
  where c.file_id = p.file_id
)
', '{}', 
                    ARRAY['file_id'], ARRAY['adding_ctp'], 'posda_files', 'Get Series in A Collection
')
        ;

            insert into queries
            values ('background_reports', 'select 
  background_subprocess_report_id as id, 
  button_name, operation_name, invoking_user, when_invoked, file_id, name
from background_subprocess_report natural join background_subprocess natural join subprocess_invocation where invoking_user = ?
order by when_invoked desc', ARRAY['invoking_user'], 
                    ARRAY['id', 'button_name', 'operation_name', 'invoking_user', 'when_invoked', 'file_id', 'name'], ARRAY['meta', 'test', 'hello', 'query_tabs', 'bills_test', 'subprocess'], 'posda_queries', 'Add a filter to a tab')
        ;

            insert into queries
            values ('InsertRoundCounts', 'insert into round_counts(
  round_id, collection,
  num_requests, priority
) values (
  ?, ?,
  ?, ?
)
', ARRAY['round_id', 'collection', 'num_requests', 'priority'], 
                    '{}', ARRAY['NotInteractive', 'Backlog'], 'posda_backlog', 'Insert a row into round_counts')
        ;

            insert into queries
            values ('ListOfAvailableQueries', 'select
  schema, name, description,
  array_to_string(tags, '','') as tags
from queries
order by name', '{}', 
                    ARRAY['schema', 'name', 'description', 'tags'], ARRAY['AllCollections', 'q_list'], 'posda_queries', 'Get a list of available queries')
        ;

            insert into queries
            values ('TotalsLike', 'select 
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
', ARRAY['pattern'], 
                    ARRAY['project_name', 'site_name', 'num_subjects', 'num_studies', 'num_series', 'total_files'], '{}', 'posda_files', 'Get Posda totals for with collection matching pattern
')
        ;

            insert into queries
            values ('RoiForBySopInstanceUid', 'select 
  distinct for_uid, count(*) as num_files
from
  file_series natural join file_sop_common natural join file_for natural join ctp_file
where 
  series_instance_uid = ? and visibility is null
group by for_uid', ARRAY['series_instance_uid'], 
                    ARRAY['for_uid', 'num_files'], ARRAY['Structure Sets', 'sops', 'LinkageChecks', 'struct_linkages'], 'posda_files', 'Get list of plan which reference unknown SOPs

')
        ;

            insert into queries
            values ('WhatHasComeInRecentlyWithSubject', 'select
  distinct collection, site, subj, date_trunc(?, time_received) as time,
  count(*) as number_of_files,
  max(time_entered - time_received) as max_delay,
  min(time_entered - time_received) as min_delay
from request natural join submitter
where time_received > ? and time_received < ?
group by collection, site, subj, time order by time desc, collection, site, subj', ARRAY['interval', 'from', 'to'], 
                    ARRAY['collection', 'site', 'subj', 'time', 'number_of_files', 'max_delay', 'min_delay'], ARRAY['NotInteractive', 'Backlog', 'Backlog Monitor', 'backlog_round_history'], 'posda_backlog', 'Summary of rounds')
        ;

            insert into queries
            values ('FindTagsInQuery', 'select
  tag from (
  select name, unnest(tags) as tag
  from queries) as foo
where
  name = ?', ARRAY['name'], 
                    ARRAY['tag'], ARRAY['meta', 'test', 'hello', 'query_tags'], 'posda_queries', 'Find all queries matching tag')
        ;

            insert into queries
            values ('GetPublicSopsForCompareLikeCollection', 'select
  i.patient_id,
  i.study_instance_uid,
  s.series_instance_uid,
  sop_instance_uid,
  sop_class_uid,
  s.modality,
  i.dicom_file_uri
from
  general_image i,
  trial_data_provenance tdp,
  general_series s
where  
  i.trial_dp_pk_id = tdp.trial_dp_pk_id 
  and tdp.project like ?
  and i.general_series_pk_id = s.general_series_pk_id', ARRAY['collection'], 
                    ARRAY['patient_id', 'study_instance_uid', 'series_instance_uid', 'sop_instance_uid', 'sop_class_uid', 'modality', 'dicom_file_uri'], ARRAY['public_posda_counts'], 'public', 'Generate a long list of all unhidden SOPs for a collection in public<br>
<em>This can generate a long list</em>')
        ;

            insert into queries
            values ('InboxContentByActivityId', 'select
 user_name, user_inbox_content_id as id, operation_name,
  when_script_started as when, 
  file_id, subprocess_invocation_id as sub_id,
  command_line,
  file_id_in_posda as spreadsheet_file_id
from 
  activity_inbox_content natural join user_inbox natural join
  user_inbox_content natural join background_subprocess_report
  natural join background_subprocess natural join subprocess_invocation
  natural left join spreadsheet_uploaded
where activity_id = ?
order by when_script_started desc', ARRAY['activity_id'], 
                    ARRAY['user_name', 'id', 'operation_name', 'when', 'file_id', 'sub_id', 'command_line', 'spreadsheet_file_id'], ARRAY['AllCollections', 'queries', 'activity_support'], 'posda_queries', 'Get a list of available queries')
        ;

            insert into queries
            values ('GetFileStorageRootByStorageClass', 'select
  root_path
from
  file_storage_root
where 
 storage_class = ?
  and current', ARRAY['storage_class'], 
                    ARRAY['root_path'], ARRAY['NotInteractive', 'used_in_import_edited_files', 'used_in_check_circular_view'], 'posda_files', 'Get root path for a storage_class')
        ;

            insert into queries
            values ('VisualReviewSeriesByIdProcessingStatusAndDicomFileTypeWhereReviewStatusIsNull', 'select 
  distinct image_equivalence_class_id, series_instance_uid
from
  visual_review_instance natural join image_equivalence_class natural join
  image_equivalence_class_input_image natural join dicom_file natural join 
  file_series natural join ctp_file
where
  visual_review_instance_id = ? and review_status is null and processing_status = ? and dicom_file_type = ?
', ARRAY['visual_review_instance_id', 'processing_status', 'dicom_file_type'], 
                    ARRAY['image_equivalence_class_id', 'series_instance_uid'], ARRAY['by_collection', 'find_series', 'compare_collection_site', 'search_series', 'edit_files', 'simple_phi', 'dciodvfy', 'ctp_details', 'select_for_phi', 'visual_review_new_workflow'], 'posda_files', 'Get Series in A Collection, site with dicom_file_type, modality, and sop_count
')
        ;

            insert into queries
            values ('GetDciodvfyUnitScanId', 'select currval(''dciodvfy_unit_scan_dciodvfy_unit_scan_id_seq'') as id', '{}', 
                    ARRAY['id'], ARRAY['NotInteractive', 'used_in_dciodvfy'], 'posda_phi_simple', 'Create a dciodvfy_scan_instance row')
        ;

            insert into queries
            values ('FromAndToFileIdWithVisibilityFromDigests', 'select 
(select file_id from file where digest = ?) as from_file_id,
(select file_id from file where digest = ?) as to_file_id,
(select visibility as from_file_visibility from ctp_file natural join file where digest = ?) as from_visibility,
(select visibility as from_file_visibility from ctp_file natural join file where digest = ?) as to_visibility', ARRAY['from_digest_1', 'to_digest_1', 'from_digest_2', 'to_digest_2'], 
                    ARRAY['from_file_id', 'to_file_id', 'from_visibility', 'to_visibility'], ARRAY['meta', 'test', 'hello', 'bills_test', 'hide_events'], 'posda_files', 'Add a filter to a tab')
        ;

            insert into queries
            values ('ExportFilepathAndSize', 'select 
  root_path,
  rel_path,
  size,
  digest 
from file 
  natural join file_location 
  natural join file_storage_root 
  natural join ctp_file 
where project_name = ? 
  and site_name = ? and visibility is null', ARRAY['collection', 'site'], 
                    ARRAY['root_path', 'rel_path', 'size', 'digest'], ARRAY['Universal'], 'posda_files', 'Creates an export list for importing with python_import_csv_filelist.py')
        ;

            insert into queries
            values ('FilesAndLoadTimesInSeries', 'select
  distinct sop_instance_uid, file_id, import_time
from
  file_sop_common natural join file_series
  natural join file_import natural join import_event
where
  series_instance_uid = ?
order by 
  sop_instance_uid, import_time, file_id
', ARRAY['series_instance_uid'], 
                    ARRAY['sop_instance_uid', 'import_time', 'file_id'], ARRAY['by_series'], 'posda_files', 'List of SOPs, files, and import times in a series
')
        ;

            insert into queries
            values ('InsertDistinguishedValue', 'insert into distinguished_pixel_digest_pixel_value(
  pixel_digest, pixel_value, num_occurances
  ) values (
  ?, ?, ?
)', ARRAY['pixel_digest', 'value', 'num_occurances'], 
                    '{}', ARRAY['duplicates', 'distinguished_digest'], 'posda_files', 'insert distinguished pixel digest')
        ;

            insert into queries
            values ('GetFileCountByLikeLoadPath', 'select distinct import_event_id, count(distinct file_id)  as num_files from file_import where rel_path like ? group by import_event_id;', ARRAY['like_rel_path'], 
                    ARRAY['import_event_id', 'num_files'], ARRAY['radcomp'], 'posda_files', 'Add a filter to a tab')
        ;

            insert into queries
            values ('CreateConversionEvent', 'insert into conversion_event(
  time_of_conversion, who_invoked_conversion, conversion_program
) values (
  now(), ?, ?
)
', ARRAY['who_invoked_conversion', 'conversion_program'], 
                    '{}', ARRAY['radcomp'], 'posda_files', 'Add a filter to a tab')
        ;

            insert into queries
            values ('GetSsVolumeReferencingKnownImagesByCollection', 'select 
  distinct project_name as collection, 
  site_name as site, patient_id, 
  file_id 
from 
  ctp_file natural join file_patient 
where file_id in (
   select
    distinct file_id from ss_volume v 
    join ss_for using(ss_for_id) 
    join file_structure_set using (structure_set_id) 
  where 
     exists (
       select file_id 
       from file_sop_common s 
       where s.sop_instance_uid = v.sop_instance
  )
)
and project_name = ?
and visibility is null
order by collection, site, patient_id', ARRAY['collection'], 
                    ARRAY['collection', 'site', 'patient_id', 'file_id'], ARRAY['Structure Sets', 'sops', 'LinkageChecks', 'struct_linkages'], 'posda_files', 'Get list of plan which reference unknown SOPs

')
        ;

            insert into queries
            values ('NonDicomPhiReportCsvMetaQuotesLimit', 'select 
  distinct non_dicom_file_type as type, ''<'' ||non_dicom_path || ''>'' as path,
  ''<'' || value || ''>'' as q_value, count(distinct posda_file_id) as num_files
from 
  non_dicom_path_value_occurrance natural join
  non_dicom_path_seen natural join
  value_seen natural join
  non_dicom_file_scan natural join
  phi_non_dicom_scan_instance
where 
  phi_non_dicom_scan_instance_id = ? and file_type = ''csv''
group by type, path, q_value
order by type, path, q_value
limit ?', ARRAY['scan_id', 'limit'], 
                    ARRAY['type', 'path', 'q_value', 'num_files'], ARRAY['adding_ctp', 'for_scripting', 'non_dicom_phi', 'non_dicom_edit'], 'posda_phi_simple', 'Simple Phi Report with Meta Quotes')
        ;

            insert into queries
            values ('CountsByCollectionSiteDateRange', 'select
  distinct
    patient_id, image_type, modality, study_date, study_description,
    series_description, study_instance_uid, series_instance_uid,
    manufacturer, manuf_model_name, software_versions,
    count(distinct sop_instance_uid) as num_sops,
    count(distinct file_id) as num_files,
    min(import_time) as earliest,
    max(import_time) as latest
from
  ctp_file join file_patient using(file_id)
  join file_series using(file_id)
  join file_sop_common using(file_id)
  join file_study using(file_id)
  join file_equipment using(file_id)
  join file_import using(file_id)
  join import_event using(import_event_id)
  left join file_image using(file_id)
  left join image using (image_id)
where
  project_name = ? and site_name = ? and visibility is null
  and import_time > ? and import_time < ?
group by
  patient_id, image_type, modality, study_date, study_description,
  series_description, study_instance_uid, series_instance_uid,
  manufacturer, manuf_model_name, software_versions
order by
  patient_id, study_instance_uid, series_instance_uid, image_type,
  modality, study_date, study_description,
  series_description,
  manufacturer, manuf_model_name, software_versions
', ARRAY['collection', 'site', 'from', 'to'], 
                    ARRAY['patient_id', 'image_type', 'modality', 'study_date', 'study_description', 'series_description', 'study_instance_uid', 'series_instance_uid', 'manufacturer', 'manuf_model_name', 'software_versions', 'num_sops', 'num_files', 'earliest', 'latest'], ARRAY['counts', 'for_bill_counts'], 'posda_files', 'Counts query by Collection, Site
')
        ;

            insert into queries
            values ('CreateEquivalenceClass', 'insert into image_equivalence_class(
  series_instance_uid, equivalence_class_number,
  processing_status
) values (
  ?, ?, ''Preparing''
)
', ARRAY['series_instance_uid', 'equivalence_class_number'], 
                    '{}', ARRAY['consistency', 'find_series', 'equivalence_classes', 'NotInteractive'], 'posda_files', 'For building series equivalence classes')
        ;

            insert into queries
            values ('DistinctSeriesByCollectionExceptModality', 'select distinct series_instance_uid, modality, count(*)
from (
select distinct series_instance_uid, sop_instance_uid, modality from (
select
   distinct series_instance_uid, modality, sop_instance_uid,
   file_id
 from file_series natural join file_sop_common
   natural join ctp_file
where
  project_name = ? and modality != ?
  and visibility is null)
as foo
group by series_instance_uid, sop_instance_uid, modality)
as foo
group by series_instance_uid, modality
', ARRAY['project_name', 'modality'], 
                    ARRAY['series_instance_uid', 'modality', 'count'], ARRAY['by_collection', 'find_series'], 'posda_files', 'Get Series in A Collection with modality other than specified
')
        ;

            insert into queries
            values ('GetPublicHierarchyBySopInstance', 'select
  i.patient_id, s.study_instance_uid, s.series_instance_uid, modality, sop_instance_uid
from 
  general_image i, general_series s where sop_instance_uid = ? and
  s.general_series_pk_id = i.general_series_pk_id', ARRAY['sop_instance_uid'], 
                    ARRAY['patient_id', 'study_instance_uid', 'series_instance_uid', 'modality', 'sop_instance_uid'], ARRAY['Hierarchy'], 'public', 'Get Patient, Study, Series, Modality, Sop Instance by sop_instance from public database')
        ;

            insert into queries
            values ('DatesOfUploadByCollectionSite', 'select distinct date_trunc as date, count(*) as num_uploads from (
 select 
  date_trunc(''day'', import_time),
  file_id
from file_import natural join import_event
  natural join ctp_file
where project_name = ? and site_name = ? 
) as foo
group by date
order by date
', ARRAY['collection', 'site'], 
                    ARRAY['date', 'num_uploads'], ARRAY['receive_reports'], 'posda_files', 'Show me the dates with uploads for Collection from Site
')
        ;

            insert into queries
            values ('CreateScanElement', 'insert into scan_element(
  element_signature_id, seen_value_id, series_scan_id
)values(
  ?, ?, ?)
', ARRAY['element_signature_id', 'seen_value_id', 'series_scan_id'], 
                    '{}', ARRAY['UsedInPhiSeriesScan', 'NotInteractive'], 'posda_phi', 'Create Scan Element')
        ;

            insert into queries
            values ('VisibilityChangeEventsByCollectionDateRangeForHiddenFilesWithSeries', 'select
  distinct project_name as collection, 
  site_name as site, patient_id,
  user_name, prior_visibility, new_visibility,
  date_trunc(''hour'',time_of_change) as time, 
  reason_for, series_instance_uid, count(*)
from
  file_visibility_change natural join
  ctp_file natural join 
  file_patient natural join 
  file_series
where
  project_name = ? and
  visibility is not null and
  time_of_change > ? and time_of_change < ?
group by 
  collection, site, patient_id, user_name, prior_visibility, new_visibility,
  time, reason_for, series_instance_uid
order by time, collection, site, patient_id, series_instance_uid', ARRAY['collection', 'from', 'to'], 
                    ARRAY['collection', 'site', 'patient_id', 'user_name', 'prior_visibility', 'new_visibility', 'time', 'series_instance_uid', 'reason_for', 'count'], ARRAY['find_series', 'equivalence_classes', 'consistency', 'visual_review_results', 'hide_files', 'old_hidden'], 'posda_files', 'Show Received before date by collection, site')
        ;

            insert into queries
            values ('GetFiletypes', 'select distinct file_type, count(*) as num_files from file group by file_type
 ', '{}', 
                    ARRAY['file_type', 'num_files'], ARRAY['downloads_by_date'], 'posda_files', 'Counts query by Collection, Site
')
        ;

            insert into queries
            values ('ComplexDuplicatePixelData', 'select 
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
', ARRAY['count'], 
                    ARRAY['project_name', 'site_name', 'patient_id', 'series_instance_uid', 'count'], ARRAY['pix_data_dups', 'pixel_duplicates'], 'posda_files', 'Find series with duplicate pixel count of <n>
')
        ;

            insert into queries
            values ('DicomFileSummaryByImportEvent', 'select
  distinct project_name as collection,
  site_name as site,
  patient_id as patient,
  study_instance_uid as study,
  series_instance_uid as series,
  dicom_file_type as file_type,
  modality,
  count(distinct sop_instance_uid) as num_sops,
  count(distinct file_id) as num_files
from
  file_patient natural join
  file_study natural join
  file_series natural join
  file_sop_common natural join
  dicom_file natural left join
  ctp_file
where file_id in (
  select distinct file_id from import_event natural join file_import where import_event_id = ?
)
group by collection, site, patient, study, series, file_type, modality
order by collection, site, patient, series, file_type', ARRAY['import_event_id'], 
                    ARRAY['collection', 'site', 'patient', 'study', 'series', 'file_type', 'modality', 'num_sops', 'num_files'], ARRAY['adding_ctp', 'for_scripting'], 'posda_files', 'A summary of DICOM files in a particular upload')
        ;

            insert into queries
            values ('AddErrorToBackgroundProcess', 'update background_subprocess set
  process_error = ?
where
 subprocess_invocation_id = ?
', ARRAY['process_error', 'background_subprocess_id'], 
                    '{}', ARRAY['NotInteractive', 'used_in_background_processing'], 'posda_queries', 'Add a error to a background_subprocess  row

used in a background subprocess when an error occurs')
        ;

            insert into queries
            values ('IntakeImagesByCollectionSitePlus', 'select
  p.patient_id,
  i.sop_instance_uid,
  t.study_instance_uid,
  s.series_instance_uid
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

', ARRAY['collection', 'site'], 
                    NULL, ARRAY['intake'], 'intake', 'N
o
n
e')
        ;

            insert into queries
            values ('ActiveQueriesOld', 'select
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
', ARRAY['db_name'], 
                    ARRAY['db_name', 'pid', 'user_id', 'user', 'waiting', 'since_xact_start', 'since_query_start', 'since_back_end_start', 'current_query'], ARRAY['postgres_status'], 'posda_files', 'Show active queries for a database
Works for PostgreSQL 8.4.20 (Current Linux)
')
        ;

            insert into queries
            values ('DupSopsBeforeDateForHiding', 'select distinct file_id, latest from (
  select
    distinct sop_instance_uid, file_id, max(import_time) latest
  from file_location join file_import using(file_id) join import_event using (import_event_id)  
    join file_sop_common using(file_id) join ctp_file using (file_id)
  where sop_instance_uid in (
    select distinct sop_instance_uid from (
      select distinct sop_instance_uid, count(distinct file_id)
      from file_sop_common natural join ctp_file
      where project_name = ? and visibility is null group by sop_instance_uid
      ) as foo
    where count > 1
    ) and visibility is null
  group by sop_instance_uid, file_id
) as foo where latest < ?', ARRAY['collection', 'break_date'], 
                    ARRAY['file_id', 'latest'], ARRAY['meta', 'test', 'hello', 'bills_test'], 'posda_files', 'List of duplicate sops with file_ids and latest load date<br><br>
<bold>Warning: may generate a lot of output</bold>')
        ;

            insert into queries
            values ('GetSimpleElementSeen', 'select
  element_seen_id as id
from 
  element_seen
where
  element_sig_pattern = ? and
  vr = ?', ARRAY['element_sig_pattern', 'vr'], 
                    ARRAY['id'], ARRAY['used_in_simple_phi', 'NotInteractive'], 'posda_phi_simple', 'Get an element_seen row by element, vr (if present)')
        ;

            insert into queries
            values ('PTWithBadModality', 'select distinct
  project_name as collection,
  site_name as site, 
  patient_id,
  series_instance_uid,
  modality,
  dicom_file_type,
  count(distinct file_id) as num_files
from
  file_series natural join ctp_file natural join file_patient
  natural join dicom_file
where 
  dicom_file_type = ''Positron Emission Tomography Image Storage'' and 
  visibility is null and
  modality != ''PT''
group by
  collection, site, patient_id, series_instance_uid, modality, dicom_file_type
order by
  collection, site, patient_id
', '{}', 
                    ARRAY['collection', 'site', 'patient_id', 'series_instance_uid', 'modality', 'dicom_file_type', 'num_files'], ARRAY['by_series', 'consistency', 'for_bill_series_consistency'], 'posda_files', 'Check a Series for Consistency
')
        ;

            insert into queries
            values ('AllPatientDetails', 'select
  distinct project_name as collection,
  site_name as site,
  visibility,
  patient_id,
  patient_name,
  study_instance_uid,
  study_date,
  series_instance_uid,
  modality,
  count (distinct file_id) as num_files
from
  file_patient natural left join
  file_study natural left join
  file_series natural left join
  ctp_file
where
  project_name is null and site_name is null and visibility is null
group by
  project_name, site_name, visibility, 
  patient_id, patient_name, study_instance_uid, study_date,
  series_instance_uid, modality
order by 
  project_name, site_name, patient_id, study_date,
  modality
', '{}', 
                    ARRAY['collection', 'site', 'visibility', 'patient_id', 'patient_name', 'study_instance_uid', 'study_date', 'series_instance_uid', 'modality', 'num_files'], ARRAY['adding_ctp', 'find_patients'], 'posda_files', 'Get Series in A Collection
')
        ;

            insert into queries
            values ('SeriesWithDupSopsByCollectionSiteDateRange', 'select
  distinct collection, site, subj_id, study_instance_uid, series_instance_uid, 
  count(distinct sop_instance_uid) as num_sops,
  count(distinct file_id) as num_files
from (
  select
    distinct project_name as collection,
    site_name as site, patient_id as subj_id,
    study_instance_uid, series_instance_uid,
    sop_instance_uid,
    file_id
  from
    ctp_file natural join file_sop_common
    natural join file_patient natural join file_study natural join file_series
  where
    sop_instance_uid in (
      select distinct sop_instance_uid 
      from (
        select distinct sop_instance_uid, count(distinct file_id)
        from file_sop_common natural join ctp_file
        where visibility is null and sop_instance_uid in (
          select distinct sop_instance_uid
          from file_sop_common natural join ctp_file
            join file_import using(file_id) 
            join import_event using(import_event_id)
          where project_name = ? and site_name = ? and
             visibility is null and import_time > ?
              and import_time < ?
        ) group by sop_instance_uid
      ) as foo 
      where count > 1
    )
    and visibility is null
  ) as foo
group by collection, site, subj_id, study_instance_uid, series_instance_uid

', ARRAY['collection', 'site', 'from', 'to'], 
                    ARRAY['collection', 'site', 'subj_id', 'num_sops', 'num_files', 'study_instance_uid', 'series_instance_uid'], ARRAY['duplicates', 'dup_sops', 'hide_dup_sops'], 'posda_files', 'Return a count of duplicate SOP Instance UIDs
')
        ;

            insert into queries
            values ('FileTypeModalityCountsByImportIdWithPatId', 'select
  distinct  patient_id, dicom_file_type, modality, count(*) as num_files
from file_series natural join dicom_file natural join file_patient
where file_id in (
  select distinct file_id
  from file_import natural join import_event
  where import_event_id = ?
) and modality = ?
group by patient_id, dicom_file_type, modality', ARRAY['import_event_id', 'modality'], 
                    ARRAY['patient_id', 'dicom_file_type', 'modality', 'num_files'], ARRAY['ACRIN-NSCLC-FDG-PET Curation'], 'posda_files', 'Get the list of files by sop, excluding base series')
        ;

            insert into queries
            values ('RoundRunningTimeCurrentRound', 'select now() - round_start as running_time from round where round_id in (
select round_id from round where round_end is null and round_start is not null)', '{}', 
                    ARRAY['running_time'], ARRAY['NotInteractive', 'Backlog', 'Backlog Monitor', 'backlog_status'], 'posda_backlog', 'Summary of round by id')
        ;

            insert into queries
            values ('FileSizeByPublic', 'select distinct project as collection, sum(dicom_size) as total_disc_used from general_image group by project order by total_disc_used desc', '{}', 
                    ARRAY['collection', 'total_disc_used'], ARRAY['AllCollections', 'queries'], 'public', 'Get a list of available queries')
        ;

            insert into queries
            values ('MakeEquivClassPassThrough', 'update image_equivalence_class set
  review_status = ''PassThrough'',
  processing_status = ''Reviewed''
where
  image_equivalence_class_id = ?', ARRAY['image_equivalence_class_id'], 
                    '{}', ARRAY['by_collection', 'find_series', 'compare_collection_site', 'search_series', 'edit_files', 'simple_phi', 'dciodvfy', 'ctp_details', 'select_for_phi', 'visual_review_new_workflow'], 'posda_files', 'Get Series in A Collection, site with dicom_file_type, modality, and sop_count
')
        ;

            insert into queries
            values ('ReviewSummaryForCollection', 'select 
  distinct project_name as collection,
  site_name as site,
  dicom_file_type,
  modality,
  coalesce(visibility, ''visable'') as visiblity,
  review_status,
  count(distinct series_instance_uid) as num_series 
from
  image_equivalence_class natural join file_series
  natural join ctp_file natural join dicom_file
where
  project_name = ? 
group by project_name, site, dicom_file_type, modality, visibility, review_status;', ARRAY['collection'], 
                    ARRAY['collection', 'site', 'dicom_file_type', 'modality', 'visibility', 'review_status', 'num_series'], ARRAY['find_series', 'equivalence_classes', 'consistency', 'visual_review_results', 'hide_events'], 'posda_files', 'Get visual review status report by series for Collection, Site')
        ;

            insert into queries
            values ('VisiblePatientsWithCtp', 'select
  distinct project_name as collection, site_name as site, patient_id,
  count(distinct series_instance_uid) as num_series,
  count(distinct file_id) as num_files,
  min(import_time) as first_import,
  max(import_time) as last_import
from
  file_patient sc natural join file_series
  natural join file_import natural join import_event
  natural join ctp_file
where
  visibility is null
group by collection, site, patient_id', '{}', 
                    ARRAY['patient_id', 'num_series', 'num_files'], ARRAY['adding_ctp', 'find_patients', 'series_selection', 'ctp_patients', 'select_for_phi'], 'posda_files', 'Get List of visible patients with CTP data')
        ;

            insert into queries
            values ('GetPatientMappingByCollectionSite', 'select
  from_patient_id,
  to_patient_id,
  to_patient_name,
  collection_name,
  site_name,
  batch_number,
  date_shift,
  ''<'' || diagnosis_date || ''>'' as diagnosis_date,
  ''<'' || baseline_date || ''>'' as baseline_date,
  ''<'' || date_trunc(''year'', diagnosis_date) || ''>'' as year_of_diagnosis,
  baseline_date - diagnosis_date as computed_shift
from
  patient_mapping
where collection_name = ? and site_name = ?
  ', ARRAY['collection_name', 'site_name'], 
                    ARRAY['from_patient_id', 'to_patient_id', 'to_patient_name', 'collection_name', 'site_name', 'batch_number', 'date_shift', 'diagnosis_date', 'baseline_date', 'year_of_diagnosis', 'computed_shift'], ARRAY['adding_ctp', 'for_scripting', 'patient_mapping', 'ACRIN-NSCLC-FDG-PET Curation'], 'posda_files', 'Retrieve entries from patient_mapping table')
        ;

            insert into queries
            values ('GetAllQualifiedCTQPByLikeCollectionWithFileCountAndLoadTimesSinceDateWithEarlier', 'select * from (select 
  collection, site, patient_id, qualified, count(distinct file_id) as num_files,
  count(distinct sop_instance_uid) as num_sops,
  min(date_trunc(''day'',import_time)) as earliest_day, max(date_trunc(''day'', import_time)) as latest_day
from
  clinical_trial_qualified_patient_id join file_patient using (patient_id) join file_import using(file_id)
  join file_sop_common using(file_id)
  join import_event using(import_event_id)
where collection like ?
group by collection, site, patient_id, qualified) as foo where latest_day >= ? and earliest_day < ?', ARRAY['collection_like', 'from', 'from_again'], 
                    ARRAY['collection', 'site', 'patient_id', 'qualified', 'num_files', 'num_sops', 'earliest_day', 'latest_day'], ARRAY['clin_qual'], 'posda_files', 'Create An Activity Timepoint

')
        ;

            insert into queries
            values ('FindPotentialDistinguishedSops', 'select 
  distinct project_name as collection,
  site_name as site, 
  patient_id, 
  image_id,
  count(*)
from
  ctp_file
  natural join file_patient
  natural join file_image
where
  file_id in 
  (select 
    distinct file_id 
  from
    file_image 
  where
    image_id in
    (select
       image_id from 
       (select
         distinct image_id, count(distinct file_id) 
       from
         file_image 
       group by image_id
       ) as foo
     where count > 1000
  )
) group by collection, site, patient_id, image_id
order by collection, site, image_id, patient_id

', '{}', 
                    ARRAY['collection', 'site', 'patient_id', 'image_id', 'count'], ARRAY['duplicates', 'distinguished_digest'], 'posda_files', 'Return a count of duplicate SOP Instance UIDs
')
        ;

            insert into queries
            values ('GetDosesReferencingBadPlans', 'select
  sop_instance_uid
from
  file_sop_common
where file_id in (
  select 
    file_id
  from
    rt_dose d natural join file_dose  
  where
    not exists (
      select
        sop_instance_uid 
      from
        file_sop_common fsc 
      where d.rt_dose_referenced_plan_uid = fsc.sop_instance_uid
  )
)', '{}', 
                    ARRAY['sop_instance_uid'], ARRAY['Structure Sets', 'sops', 'LinkageChecks'], 'posda_files', 'Get list of plan which reference unknown SOPs

')
        ;

            insert into queries
            values ('RollbackPosda', 'rollback', '{}', 
                    '{}', ARRAY['NotInteractive', 'Backlog', 'Transaction'], 'posda_files', 'Abort a transaction in Posda files')
        ;

            insert into queries
            values ('AllSopsReceivedBetweenDates', 'select
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
', ARRAY['start_time', 'end_time'], 
                    ARRAY['project_name', 'site_name', 'patient_id', 'study_instance_uid', 'series_instance_uid', 'num_sops', 'first_loaded', 'last_loaded'], ARRAY['receive_reports'], 'posda_files', 'Series received between dates regardless of duplicates
')
        ;

            insert into queries
            values ('CountsBySeriesInstanceUidPlusNoImageType', 'select
  distinct
    patient_id, study_date, series_instance_uid, modality,
    study_description, series_description,
    count(distinct sop_instance_uid) as num_sops,
    count(distinct file_id) as num_files,
    min(import_time) as earliest,
    max(import_time) as latest
from
  ctp_file join file_patient using(file_id)
  join dicom_file using(file_id)
  join file_series using(file_id)
  join file_sop_common using(file_id)
  join file_study using(file_id)
  join file_equipment using(file_id)
  join file_import using(file_id)
  join import_event using(import_event_id)
  left join file_image using(file_id)
  left join image using (image_id)
where
  file_id in (
    select file_id 
    from file_series
    where series_instance_uid  = ?
  ) and project_name = ? and visibility is null
group by
  patient_id, study_date, series_instance_uid, study_description, series_description, modality
order by
  patient_id, study_date, modality, series_description, series_instance_uid,
  study_description
', ARRAY['SeriesInstanceUid', 'collection'], 
                    ARRAY['patient_id', 'study_date', 'modality', 'series_description', 'series_date', 'study_description', 'study_instance_uid', 'series_instance_uid', 'manufacturer', 'manuf_model_name', 'software_versions', 'num_sops', 'num_files', 'earliest', 'latest'], ARRAY['counts', 'count_queries'], 'posda_files', 'Counts query by Collection, Site
')
        ;

            insert into queries
            values ('GetPublicSopCountByPatientId', 'select
  distinct i.patient_id,
  count(distinct sop_instance_uid) as num_sops
from
  general_image i,
  trial_data_provenance tdp,
  general_series s
where  
  i.trial_dp_pk_id = tdp.trial_dp_pk_id 
  and i.patient_id = ?
  and i.general_series_pk_id = s.general_series_pk_id
group by i.patient_id', ARRAY['patient_id'], 
                    ARRAY['patient_id', 'num_sops'], ARRAY['public_posda_counts'], 'public', 'Generate a long list of all unhidden SOPs for a collection in public<br>
<em>This can generate a long list</em>')
        ;

            insert into queries
            values ('GoInService', 'update control_status
set status = ''service process running'',
  processor_pid = ?', ARRAY['pid'], 
                    '{}', ARRAY['NotInteractive', 'Backlog'], 'posda_backlog', 'Claim control of posda_backlog')
        ;

            insert into queries
            values ('UpdPosdaPhiSimpleEleName', 'update
  element_seen
set
  tag_name = ?,
  is_private = ?
where
  element_sig_pattern = ? and
  vr = ?

', ARRAY['name', 'is_private', 'element_signature', 'vr'], 
                    '{}', ARRAY['NotInteractive', 'used_in_reconcile_tag_names'], 'posda_phi_simple', 'Update name_chain in element_seen')
        ;

            insert into queries
            values ('PatientDetails', 'select
  distinct project_name as collection,
  site_name as site,
  visibility,
  patient_id,
  patient_name,
  study_instance_uid,
  study_date,
  series_instance_uid,
  modality,
  count (distinct file_id) as num_files
from
  file_patient natural left join
  file_study natural left join
  file_series natural left join
  ctp_file
where
  patient_id = ?
group by
  project_name, site_name, visibility, 
  patient_id, patient_name, study_instance_uid, study_date,
  series_instance_uid, modality
order by 
  project_name, site_name, patient_id, study_date,
  modality
', ARRAY['patient_id'], 
                    ARRAY['collection', 'site', 'visibility', 'patient_id', 'patient_name', 'study_instance_uid', 'study_date', 'series_instance_uid', 'modality', 'num_files'], ARRAY['adding_ctp', 'find_patients', 'no_ctp_details', 'ctp_details'], 'posda_files', 'Get Series in A Collection
')
        ;

            insert into queries
            values ('LastNPhiScans', 'select
  phi_scan_instance_id as id,
  start_time,
  end_time,
  end_time - start_time as duration,
  description,
  num_series as to_scan,
  num_series_scanned as scanned
from 
  phi_scan_instance
order by id desc
  limit ?
', ARRAY['n'], 
                    ARRAY['id', 'start_time', 'end_time', 'duration', 'description', 'to_scan', 'scanned'], ARRAY['tag_usage', 'simple_phi', 'phi_status'], 'posda_phi_simple', 'Status of PHI scans
')
        ;

            insert into queries
            values ('AddProcessCount', 'update round
  set process_count = ?
where
  round_id = ?
', ARRAY['process_count', 'round_id'], 
                    '{}', ARRAY['NotInteractive', 'Backlog'], 'posda_backlog', 'Set Process Count in round')
        ;

            insert into queries
            values ('CountsByCollectionDateRangePlusNoImageType', 'select
  distinct
    patient_id, study_date, series_instance_uid, modality,
    study_description, series_description,
    count(distinct sop_instance_uid) as num_sops,
    count(distinct file_id) as num_files,
    min(import_time) as earliest,
    max(import_time) as latest
from
  ctp_file join file_patient using(file_id)
  join dicom_file using(file_id)
  join file_series using(file_id)
  join file_sop_common using(file_id)
  join file_study using(file_id)
  join file_equipment using(file_id)
  join file_import using(file_id)
  join import_event using(import_event_id)
  left join file_image using(file_id)
  left join image using (image_id)
where
  file_id in (
    select file_id 
    from file_import natural join import_event
    where import_time > ? and import_time < ?
  ) and project_name = ? and visibility is null
group by
  patient_id, study_date, series_instance_uid, study_description, series_description, modality
order by
  patient_id, study_date, modality, series_description, series_instance_uid,
  study_description
', ARRAY['from', 'to', 'collection'], 
                    ARRAY['patient_id', 'study_date', 'series_instance_uid', 'modality', 'study_description', 'series_description', 'num_sops', 'num_files', 'latest', 'earliest'], ARRAY['counts', 'count_queries'], 'posda_files', 'Counts query by Collection, Site
')
        ;

            insert into queries
            values ('GetDciodvfyErrorAttrPres', 'select
  dciodvfy_error_id as id
from 
  dciodvfy_error
where
  error_type = ''AttributesPresentWhenConditionNotSatisfied''
  and error_tag = ?
  and error_module = ?', ARRAY['error_tag', 'error_module'], 
                    ARRAY['id'], ARRAY['NotInteractive', 'used_in_dciodvfy'], 'posda_phi_simple', 'Get an dciodvfy_errors row by error_text (if present)')
        ;

            insert into queries
            values ('VisibleColSiteWithCtp', 'select
  distinct project_name as collection, site_name as site,
  count(distinct series_instance_uid) as num_series,
  count(distinct file_id) as num_files,
  min(import_time) as first_import,
  max(import_time) as last_import
from
  file_series
  natural join file_import natural join import_event
  natural join ctp_file
where
  visibility is null
group by collection, site', '{}', 
                    ARRAY['collection', 'site', 'num_series', 'num_files'], ARRAY['adding_ctp', 'find_patients', 'series_selection', 'ctp_col_site', 'select_for_phi'], 'posda_files', 'Get List of visible patients with CTP data')
        ;

            insert into queries
            values ('FileWithInfoBySopInPublic', 'select
  frame_of_reference_uid as frame_of_ref,
  image_orientation_patient as iop,
  image_position_patient as ipp,
  pixel_spacing,
  i_rows as pixel_rows,
  i_columns as pixel_columns
from
  general_image i, general_series s
where
  i.general_series_pk_id = s.general_series_pk_id and
  sop_instance_uid = ?', ARRAY['sop_instance_uid'], 
                    ARRAY['frame_of_ref', 'iop', 'ipp', 'pixel_spacing', 'pixel_rows', 'pixel_columns'], ARRAY['LinkageChecks', 'used_in_struct_linkage_check'], 'public', 'Get list of Roi with info by file_id

')
        ;

            insert into queries
            values ('InboxContentByDateRange', 'select
  activity_id, brief_description as activity_description,
  user_name, user_inbox_content_id, operation_name,
  when_script_started as when, 
  file_id, subprocess_invocation_id as sub_id,
  command_line,
  file_id_in_posda as spreadsheet_file_id
from 
  activity natural join activity_inbox_content natural join user_inbox natural join
  user_inbox_content natural join background_subprocess_report
  natural join background_subprocess natural join subprocess_invocation
  natural left join spreadsheet_uploaded
where 
  when_script_started > ? and when_script_started < ?
order by activity_id, when_script_started', ARRAY['from', 'to'], 
                    ARRAY['activity_id', 'activity_description', 'user_name', 'user_inbox_content_id', 'operation_name', 'when', 'file_id', 'sub_id', 'command_line', 'spreadsheet_file_id'], ARRAY['AllCollections', 'queries', 'activity_support'], 'posda_queries', 'Get a list of available queries')
        ;

            insert into queries
            values ('ShowQueryTabHierarchyWithQueries', 'select 
  distinct query_tab_name, filter_name, tag, query_name
from(
  select 
     query_tab_name,
      filter_name,
      unnest(tags_enabled) as tag
  from
    query_tabs join query_tabs_query_tag_filter using(query_tab_name)
    natural join query_tag_filter
) as foo
natural join(
  select
     name as query_name,
     unnest(tags) as tag
from queries
) as fie
order by 
  query_tab_name, filter_name, tag, query_name', '{}', 
                    ARRAY['query_tab_name', 'filter_name', 'tag', 'query_name'], ARRAY['meta', 'test', 'hello', 'query_tabs', 'bills_test'], 'posda_queries', 'Add a filter to a tab')
        ;

            insert into queries
            values ('ListOfCollectionsAndSitesLikeCollection', 'select 
    distinct project_name, site_name, count(*) 
from 
   ctp_file natural join file_study natural join
   file_series
where
  visibility is null and project_name like ?
group by project_name, site_name
order by project_name, site_name
', ARRAY['CollectionLike'], 
                    ARRAY['project_name', 'site_name', 'count'], ARRAY['AllCollections', 'universal'], 'posda_files', 'Get a list of collections and sites
')
        ;

            insert into queries
            values ('RemoveTagFromQuery', 'update queries
set tags = array_remove(tags, ?::text)
where name = ?', ARRAY['tag_name', 'query_name'], 
                    '{}', ARRAY['meta'], 'posda_queries', 'Remove a tag from a query')
        ;

            insert into queries
            values ('DeleteFirstTagFromQuery', 'update queries 
  set tags = tags[(array_lower(tags,1) + 1):(array_upper(tags,1))]
where name = ?', ARRAY['name'], 
                    '{}', ARRAY['meta', 'test', 'hello', 'query_tags'], 'posda_queries', 'Add a tag to a query')
        ;

            insert into queries
            values ('ValuesByVrWithTagAndCount', 'select distinct value, element_signature, private_disposition, num_files from (
  select
    distinct value, element_signature, private_disposition, vr, count(*)  as num_files
  from
    scan_event natural join series_scan natural join seen_value
    natural join element_signature natural join scan_element
  where
    scan_event_id = ? and vr = ?
  group by value, element_signature, vr
) as foo
order by value
', ARRAY['scan_id', 'vr'], 
                    ARRAY['value', 'element_signature', 'private_disposition', 'num_files'], ARRAY['tag_usage'], 'posda_phi', 'List of values seen in scan by VR (with count of elements)
')
        ;

            insert into queries
            values ('CreateNewQueryTab', 'insert into query_tabs (
  query_tab_name,
  query_tab_description, 
  defines_dropdown,
  sort_order,
  defines_search_engine)
values(
  ?, ?, true, ?, false
)', ARRAY['query_tab_name', 'query_tab_description', 'sort_order'], 
                    '{}', ARRAY['meta', 'test', 'hello', 'query_tabs'], 'posda_queries', 'Create a new query tab')
        ;

            insert into queries
            values ('AddHocQuery', 'select
  distinct patient_id, study_instance_uid as study_uid, series_instance_uid as series_uid,
  count(distinct file_id) as num_files
from
  file_patient natural join file_study natural join file_series natural join ctp_file
where
  patient_id in
   (''HN-CHUM-050'', ''HN-CHUM-052'', ''HN-CHUM-054'', ''HN-CHUM-056'', ''HN-CHUM-030'', ''HN-CHUM-032'')
  and visibility is null
group by patient_id, study_uid, series_uid', '{}', 
                    ARRAY['patient_id', 'study_uid', 'series_uid', 'num_files'], ARRAY['meta', 'test', 'hello', 'bills_test', 'bills_ad_hoc_scripts'], 'posda_files', 'Add a filter to a tab')
        ;

            insert into queries
            values ('GetEquivalenceClassId', 'select currval(''image_equivalence_class_image_equivalence_class_id_seq'') as id', '{}', 
                    ARRAY['id'], ARRAY['NotInteractive', 'equivalence_classes'], 'posda_files', 'Get current value of EquivalenceClassId Sequence
')
        ;

            insert into queries
            values ('GetActivities', 'select
  activity_id, brief_description, when_created, who_created, when_closed
from activity

', '{}', 
                    ARRAY['activity_id', 'brief_description', 'when_created', 'who_created', 'when_closed'], ARRAY['AllCollections', 'queries', 'activity_support'], 'posda_queries', 'Get a list of available queries')
        ;

            insert into queries
            values ('FilesEarlierThanDateByCollectionSite', 'select 
  distinct file_id, visibility as old_visibility
from 
  ctp_file natural join file_import natural join import_event
where
  project_name = ? and site_name = ? and visibility is null
  and import_time < ?
 ', ARRAY['collection', 'site', 'before'], 
                    ARRAY['file_id', 'old_visibility'], ARRAY['find_series', 'equivalence_classes', 'consistency', 'visual_review_results', 'hide_files'], 'posda_files', 'Show Received before date by collection, site')
        ;

            insert into queries
            values ('InsertEditEventRow', 'insert into dicom_edit_event(
  edit_desc_file, time_started, edit_comment, num_files, process_id, edits_done
) values (?, now(), ?, ?, ?, 0)
', ARRAY['edit_desc_file', 'edit_comment', 'num_files', 'process_id'], 
                    '{}', ARRAY['Insert', 'NotInteractive', 'used_in_import_edited_files'], 'posda_files', 'Insert edit_event
For use in scripts
Not really intended for interactive use
')
        ;

            insert into queries
            values ('ListClosedActivities', 'select
  activity_id,
  brief_description,
  when_created,
  who_created,
  when_closed
from
  activity 
where when_closed is not null
order by activity_id', '{}', 
                    ARRAY['activity_id', 'brief_description', 'when_created', 'who_created', 'when_closed'], ARRAY['AllCollections', 'queries', 'activities'], 'posda_queries', 'Get a list of available queries')
        ;

            insert into queries
            values ('GetSopListByCollectionSite', 'select 
  distinct project_name as collection, site_name as site,
  patient_id, study_instance_uid, series_instance_uid,
  sop_instance_uid
from
  ctp_file natural join file_patient natural join
  file_study natural join file_series natural join file_sop_common
where
  project_name = ? and site_name = ? and visibility is null;', ARRAY['collection', 'site'], 
                    ARRAY['collection', 'site', 'patient_id', 'study_instance_uid', 'series_instance_uid', 'sop_instance_uid'], ARRAY['bills_test', 'comparing_posda_to_public'], 'posda_files', 'Get a full list of sops with collection, site, patient, study_instance_uid and series_instance_uid
by collection, site

<bold>This may generate a large number of rows</bold>')
        ;

            insert into queries
            values ('GetEndOfWeek', 'select 
  date_trunc(''week'', to_timestamp(?, ''yyyy-mm-dd'') + interval ''1 week'') as end_week
 ', ARRAY['from'], 
                    ARRAY['end_week'], ARRAY['downloads_by_date'], 'posda_files', 'Counts query by Collection, Site
')
        ;

            insert into queries
            values ('DupSopsWithFileIdByCollectionSiteDateRange', 'select
  distinct collection, site, subj_id, 
  sop_instance_uid,
  file_id,
  visibility
from (
  select
    distinct project_name as collection,
    site_name as site, patient_id as subj_id,
    study_instance_uid, series_instance_uid,
    sop_instance_uid,
    file_id,
    visibility
  from
    ctp_file natural join file_sop_common
    natural join file_patient natural join file_study natural join file_series
  where
    sop_instance_uid in (
      select distinct sop_instance_uid 
      from (
        select distinct sop_instance_uid, count(distinct file_id)
        from file_sop_common natural join ctp_file
        where visibility is null and sop_instance_uid in (
          select distinct sop_instance_uid
          from file_sop_common natural join ctp_file
            join file_import using(file_id) 
            join import_event using(import_event_id)
          where project_name = ? and site_name = ? and
             visibility is null and import_time > ?
              and import_time < ?
        ) group by sop_instance_uid
      ) as foo 
      where count > 1
    )
    and visibility is null
  ) as foo
order by sop_instance_uid


', ARRAY['collection', 'site', 'from', 'to'], 
                    ARRAY['collection', 'site', 'subj_id', 'sop_instance_uid', 'file_id', 'visibility'], ARRAY['duplicates', 'dup_sops', 'hide_dup_sops'], 'posda_files', 'Return a count of duplicate SOP Instance UIDs
')
        ;

            insert into queries
            values ('CreateSimpleValueSeen', 'insert into value_seen(
value
)values(?)', ARRAY['value'], 
                    '{}', ARRAY['used_in_simple_phi', 'NotInteractive'], 'posda_phi_simple', 'Create a new Simple Value Seen')
        ;

            insert into queries
            values ('GetReportOnSeriesWithNoStudy', 'select 
  distinct project_name as collection,
  site_name as site, patient_id, series_instance_uid, visibility, count(*) as num_files
from ctp_file natural join file natural join file_patient natural join file_series  where digest in (
select digest from file where file_id in (
select file_id from file_series where not exists(select file_id from file_study where file_series.file_id = file_study.file_id))) group by project_name, site_name, patient_id, series_instance_uid,visibility;', '{}', 
                    ARRAY['collection', 'site', 'patient_id', 'series_instance_uid', 'visibility', 'num_files'], ARRAY['posda_db_populate', 'dicom_file_type'], 'posda_files', 'Add a filter to a tab')
        ;

            insert into queries
            values ('PixelDataIdByFileIdWithOtherFileId', 'select
  distinct f.file_id as file_id, image_id, unique_pixel_data_id, 
  l.file_id as other_file_id
from
  file_image f natural join image natural join unique_pixel_data
  join pixel_location l using(unique_pixel_data_id)
where
  f.file_id = ?
', ARRAY['file_id'], 
                    ARRAY['file_id', 'image_id', 'unique_pixel_data_id', 'other_file_id'], ARRAY['by_file_id', 'duplicates', 'pixel_data_id', 'posda_files'], 'posda_files', 'Get unique_pixel_data_id for file_id 
')
        ;

            insert into queries
            values ('CreateBackgroundSubprocess', 'insert into background_subprocess(
  subprocess_invocation_id,
  command_executed,
  foreground_pid,
  when_script_started,
  user_to_notify
) values (
  ?, ?, ?, now(), ?
)
returning background_subprocess_id', ARRAY['subprocess_invocation_id', 'command_executed', 'foreground_pid', 'user_to_notify'], 
                    '{}', ARRAY['NotInteractive', 'used_in_background_processing'], 'posda_queries', 'Create row in background_subprocess table

Used by background subprocess')
        ;

            insert into queries
            values ('GetFileHierarchyByCollection', 'select 
  distinct root_path || ''/'' || rel_path as path,
  patient_id,
  study_instance_uid,
  series_instance_uid,
  file_id 
from 
  ctp_file natural join
  file_patient natural join
  file_study natural join
  file_series natural join
  file_location natural join
  file_storage_root
where
  project_name = ?
  and visibility is null', ARRAY['collection'], 
                    ARRAY['path', 'patient_id', 'study_instance_uid', 'series_instance_uid', 'file_id'], ARRAY['used_in_file_import_into_posda', 'used_in_file_migration'], 'posda_files', 'Get root_path for a file_storage_root
')
        ;

            insert into queries
            values ('SeriesLike', 'select
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
', ARRAY['collection', 'site', 'description_matching'], 
                    ARRAY['collection', 'site', 'pat_id', 'series_instance_uid', 'series_description', 'count'], ARRAY['find_series', 'pattern', 'posda_files'], 'posda_files', 'Select series not matching pattern
')
        ;

            insert into queries
            values ('NonDicomPhiReportCsvMetaQuotes', 'select 
  distinct non_dicom_file_type as type, ''<'' ||non_dicom_path || ''>'' as path,
  ''<'' || value || ''>'' as q_value, count(distinct posda_file_id) as num_files
from 
  non_dicom_path_value_occurrance natural join
  non_dicom_path_seen natural join
  value_seen natural join
  non_dicom_file_scan natural join
  phi_non_dicom_scan_instance
where 
  phi_non_dicom_scan_instance_id = ? and file_type = ''csv''
group by type, path, q_value
order by type, path, q_value
', ARRAY['scan_id'], 
                    ARRAY['type', 'path', 'q_value', 'num_files'], ARRAY['adding_ctp', 'for_scripting', 'non_dicom_phi', 'non_dicom_edit'], 'posda_phi_simple', 'Simple Phi Report with Meta Quotes')
        ;

            insert into queries
            values ('GetValuesForTag', 'select
  distinct element_signature as tag, value
from
  scan_element natural join series_scan natural join
  seen_value natural join element_signature
where element_signature = ? and scan_event_id = ?
', ARRAY['tag', 'scan_id'], 
                    ARRAY['tag', 'value'], ARRAY['tag_values'], 'posda_phi', 'Find Values for a given tag for all scanned series in a phi scan instance
')
        ;

            insert into queries
            values ('DatabaseSize', 'SELECT d.datname AS Name,  pg_catalog.pg_get_userbyid(d.datdba) AS Owner,
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
', '{}', 
                    ARRAY['Name', 'Owner', 'Size'], ARRAY['postgres_status'], 'posda_files', 'Show active queries for a database
Works for PostgreSQL 9.4.5 (Current Mac)
')
        ;

            insert into queries
            values ('GetSsVolumeReferencingUnknownImages', 'select 
  project_name as collection, 
  site_name as site, patient_id, 
  file_id 
from 
  ctp_file natural join file_patient 
where file_id in (
   select
    distinct file_id from ss_volume v 
    join ss_for using(ss_for_id) 
    join file_structure_set using (structure_set_id) 
  where 
     not exists (
       select file_id 
       from file_sop_common s 
       where s.sop_instance_uid = v.sop_instance
  )
)
order by collection, site, patient_id', '{}', 
                    ARRAY['collection', 'site', 'patient_id', 'file_id'], ARRAY['Structure Sets', 'sops', 'LinkageChecks', 'struct_linkages'], 'posda_files', 'Get list of plan which reference unknown SOPs

')
        ;

            insert into queries
            values ('GetFullCopyFromPublicInfo', 'select 
  copy_from_public_id as id, who, why, 
  num_file_rows_populated as num_files, 
  (
    select count(*) as num_waiting 
    from file_copy_from_public fc 
    where fc.copy_from_public_id = copy_from_public.copy_from_public_id and 
       not exists
       (
         select file_id from ctp_file where ctp_file.file_id = fc.replace_file_id and visibility is not null
       )
  ),
  (
    select count(*) as num_copied
    from file_copy_from_public fc
    where fc.copy_from_public_id = copy_from_public.copy_from_public_id and
    fc.inserted_file_id is not null
  )
from
  copy_from_public 
where copy_from_public_id = ?', ARRAY['copy_from_public_id'], 
                    ARRAY['id', 'who', 'why', 'num_files', 'num_waiting', 'num_copied'], ARRAY['bills_test', 'copy_from_public', 'public_posda_consistency'], 'posda_files', 'Add a filter to a tab')
        ;

            insert into queries
            values ('PlanSopToForByCollectionSite', 'select 
  distinct patient_id,  sop_instance_uid, 
  for_uid
from 
  file_for natural join file_plan join file_sop_common using(file_id) join file_patient using (file_id)
where
  file_id in (
    select file_id 
    from ctp_file natural join file_plan 
    where project_name = ? and site_name = ? and visibility is null
  )
order by patient_id', ARRAY['collection', 'site'], 
                    ARRAY['patient_id', 'sop_instance_uid', 'for_uid'], ARRAY['Structure Sets', 'sops', 'LinkageChecks', 'plan_linkages'], 'posda_files', 'Get list of plan which reference unknown SOPs

')
        ;

            insert into queries
            values ('CountsByCollectionLike', 'select
  distinct
    project_name as collection, site_name as site,
    patient_id, image_type, dicom_file_type, modality,
    study_date, series_date,
    study_description,
    series_description, study_instance_uid, series_instance_uid,
    manufacturer, manuf_model_name, software_versions,
    count(distinct sop_instance_uid) as num_sops,
    count(distinct file_id) as num_files,
    min(import_time) as earliest,
    max(import_time) as latest
from
  ctp_file join file_patient using(file_id)
  join dicom_file using(file_id)
  join file_series using(file_id)
  join file_sop_common using(file_id)
  join file_study using(file_id)
  join file_equipment using(file_id)
  join file_import using(file_id)
  join import_event using(import_event_id)
  left join file_image using(file_id)
  left join image using (image_id)
where
  file_id in (
    select file_id 
    from file_import natural join import_event
  ) and project_name like ? and visibility is null
group by
  collection, site, patient_id, image_type, dicom_file_type, modality, study_date, 
  series_date, study_description,
  series_description, study_instance_uid, series_instance_uid,
  manufacturer, manuf_model_name, software_versions
order by
  collection, site, patient_id, study_instance_uid, series_instance_uid, image_type,
  modality, study_date, series_date, study_description,
  series_description,
  manufacturer, manuf_model_name, software_versions
', ARRAY['collection_like'], 
                    ARRAY['collection', 'site', 'patient_id', 'image_type', 'dicom_file_type', 'modality', 'study_date', 'series_date', 'study_description', 'series_description', 'study_instance_uid', 'series_instance_uid', 'manufacturer', 'manuf_model_name', 'software_versions', 'num_sops', 'num_files', 'earliest', 'latest'], ARRAY['counts', 'count_queries'], 'posda_files', 'Counts query by Collection like pattern
')
        ;

            insert into queries
            values ('WhatHasComeInRecentlyByCollectionLike', 'select
  distinct collection, site, date_trunc(?, time_received) as time,
  count(*) as number_of_files,
  max(time_entered - time_received) as max_delay,
  min(time_entered - time_received) as min_delay
from request natural join submitter
where time_received > ? and time_received < ?
and collection like ?
group by collection, site, time order by time desc, collection, site', ARRAY['interval', 'from', 'to', 'collection_like'], 
                    ARRAY['collection', 'site', 'time', 'number_of_files', 'max_delay', 'min_delay'], ARRAY['NotInteractive', 'Backlog', 'Backlog Monitor', 'backlog_round_history'], 'posda_backlog', 'Summary of rounds')
        ;

            insert into queries
            values ('SeriesWithMultipleDupSopsByCollectionSite', 'select
  distinct collection, site, subj_id, study_instance_uid, series_instance_uid, 
  count(distinct sop_instance_uid) as num_sops,
  count(distinct file_id) as num_files
from (
  select
    distinct project_name as collection,
    site_name as site, patient_id as subj_id,
    study_instance_uid, series_instance_uid,
    sop_instance_uid,
    file_id
  from
    ctp_file natural join file_sop_common
    natural join file_patient natural join file_study natural join file_series
  where
    sop_instance_uid in (
      select distinct sop_instance_uid from (
        select distinct sop_instance_uid, count(*) from (
          select distinct file_id, sop_instance_uid 
          from
            ctp_file natural join file_sop_common
            natural join file_patient
          where
            visibility is null and project_name = ? and site_name = ?
        ) as foo group by sop_instance_uid order by count desc
      ) as foo 
      where count > 2
    )
    and visibility is null
  ) as foo
group by collection, site, subj_id, study_instance_uid, series_instance_uid

', ARRAY['collection', 'site'], 
                    ARRAY['collection', 'site', 'subj_id', 'num_sops', 'num_files', 'study_instance_uid', 'series_instance_uid'], ARRAY['duplicates'], 'posda_files', 'Return a count of duplicate SOP Instance UIDs
')
        ;

            insert into queries
            values ('FindDuplicatedPixelDigestsNew', 'select
  distinct pixel_digest, num_files
from (
  select
    distinct pixel_data_digest as pixel_digest, count(distinct file_id) as num_files
  from
    dicom_file
  where 
    has_pixel_data
    group by pixel_data_digest
) as foo 
where num_files > 3
order by num_files desc', '{}', 
                    ARRAY['pixel_digest', 'num_files'], ARRAY['meta', 'test', 'hello'], 'posda_files', 'Find Duplicated Pixel Digest')
        ;

            insert into queries
            values ('ForConstructingSeriesEquivalenceClasses', 'select distinct 
 series_instance_uid, modality, series_number, laterality, series_date, dicom_file_type,
  performing_phys, protocol_name, series_description,
  operators_name, body_part_examined, patient_position,
  smallest_pixel_value, largest_pixel_value, performed_procedure_step_id,
  performed_procedure_step_start_date,
  performed_procedure_step_desc, performed_procedure_step_comments, image_type,
  iop, pixel_rows, pixel_columns,
  file_id,ipp
from
  file_series natural join ctp_file natural join dicom_file
  left join file_image using(file_id)
  left join image using (image_id)
  left join file_image_geometry using (file_id)
  left join image_geometry using (image_geometry_id)
where series_instance_uid = ? and visibility is null
 


', ARRAY['series_instance_uid'], 
                    ARRAY['series_instance_uid', 'modality', 'series_number', 'laterality', 'series_date', 'dicom_file_type', 'performing_phys', 'protocol_name', 'series_description', 'operators_name', 'body_part_examined', 'patient_position', 'smallest_pixel_value', 'largest_pixel_value', 'performed_procedure_step_id', 'performed_procedure_step_start_date', 'performed_procedure_step_desc', 'performed_procedure_step_comments', 'image_type', 'iop', 'pixel_rows', 'pixel_columns', 'file_id', 'ipp'], ARRAY['consistency', 'find_series', 'equivalence_classes'], 'posda_files', 'For building series equivalence classes')
        ;

            insert into queries
            values ('PublicPatientsByCollectionSite', 'select
  distinct p.patient_id as PID, count(distinct i.image_pk_id) as num_images
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
group by PID
', ARRAY['collection', 'site'], 
                    ARRAY['PID', 'num_images'], ARRAY['public'], 'public', 'List of all Files Images By Collection, Site
')
        ;

            insert into queries
            values ('RTPLANWithBadModality', 'select distinct
  project_name as collection,
  site_name as site, 
  patient_id,
  series_instance_uid,
  modality,
  dicom_file_type,
  count(distinct file_id) as num_files
from
  file_series natural join ctp_file natural join file_patient
  natural join dicom_file
where 
  dicom_file_type = ''RT Plan Storage'' and 
  visibility is null and
  modality != ''RTPLAN''
group by
  collection, site, patient_id, series_instance_uid, modality, dicom_file_type
order by
  collection, site, patient_id
', '{}', 
                    ARRAY['collection', 'site', 'patient_id', 'series_instance_uid', 'modality', 'dicom_file_type', 'num_files'], ARRAY['by_series', 'consistency', 'for_bill_series_consistency'], 'posda_files', 'Check a Series for Consistency
')
        ;

            insert into queries
            values ('DistinguishedDigests', 'select
   pixel_digest as distinguished_pixel_digest,
   type_of_pixel_data,
   sample_per_pixel,
   number_of_frames,
   pixel_rows,
   pixel_columns,
   bits_stored,
   bits_allocated,
   high_bit,
   pixel_mask,
   num_distinct_pixel_values,
   pixel_value,
   num_occurances
from 
  distinguished_pixel_digests natural join
  distinguished_pixel_digest_pixel_value', '{}', 
                    ARRAY['distinguished_pixel_digest', 'type_of_pixel_data', 'sample_per_pixel', 'number_of_frames', 'pixel_rows', 'pixel_columns', 'bits_stored', 'bits_allocated', 'high_bit', 'pixel_mask', 'num_distinct_values', 'pixel_value', 'num_occurances'], ARRAY['duplicates', 'distinguished_digest'], 'posda_files', 'show series with distinguished digests and counts')
        ;

            insert into queries
            values ('GetDciodvfyErrorCantBeNegative', 'select
  dciodvfy_error_id as id
from 
  dciodvfy_error
where
  error_type = ''CantBeNegative''
  and error_tag = ?
  and error_value = ?
', ARRAY['error_tag', 'error_value'], 
                    ARRAY['id'], ARRAY['NotInteractive', 'used_in_dciodvfy'], 'posda_phi_simple', 'Get an dciodvfy_errors row by error_tag where error_type = ''CantBeNegative''')
        ;

            insert into queries
            values ('DicomFileTypesNotProcessed', 'select 
  distinct dicom_file_type, count(distinct file_id)
from
  dicom_file d natural join ctp_file
where
  visibility is null  and
  not exists (
    select file_id 
    from file_series s
    where s.file_id = d.file_id
  )
group by dicom_file_type', '{}', 
                    ARRAY['dicom_file_type', 'count'], ARRAY['dicom_file_type'], 'posda_files', 'List of Distinct Dicom File Types which have unprocessed DICOM files
')
        ;

            insert into queries
            values ('ManifestsByFileId', 'select
  cm_collection,
  cm_site,
  cm_patient_id,
  cm_study_date,
  cm_series_instance_uid,
  cm_study_description,
  cm_series_description,
  cm_modality,
  cm_num_files
from
  ctp_manifest_row
where
  file_id = ?
order by 
  cm_index', ARRAY['file_id'], 
                    ARRAY['cm_collection', 'cm_site', 'cm_patient_id', 'cm_study_date', 'cm_series_instance_uid', 'cm_study_description', 'cm_series_description', 'cm_modality', 'cm_num_files'], ARRAY['activity_timepoint_support', 'manifests'], 'posda_files', 'Get a manifest from database

')
        ;

            insert into queries
            values ('GetMatchingRootID', 'select file_storage_root_id from file_storage_root where root_path = ?', ARRAY['root_path'], 
                    ARRAY['file_storage_root_id'], ARRAY['Universal'], 'posda_files', 'Checks for the local environment''s ID for a certain root path. Used by python_import_csv_filelist.py to insert file info into local development environments for files physically stored and referenced in internal posda production. 

(import list will have the root path for a file in prod, this will find the local id for that path)')
        ;

            insert into queries
            values ('GetNonDicomFilesByCollectionWithPath', 'select 
  file_id, file_type, file_sub_type, collection, site, subject, visibility, date_last_categorized, rel_path
from
  non_dicom_file natural join file_import
where
  collection = ? and
  visibility is null
', ARRAY['collection'], 
                    ARRAY['file_id', 'file_type', 'file_sub_type', 'collection', 'site', 'subject', 'visibility', 'date_last_categorized', 'rel_path'], ARRAY['radcomp'], 'posda_files', 'Add a filter to a tab')
        ;

            insert into queries
            values ('IntakeImagesByCollectionSite', 'select
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
', ARRAY['collection', 'site'], 
                    ARRAY['PID', 'Modality', 'SopInstance', 'ImageType', 'StudyDate', 'StudyDescription', 'SeriesDescription', 'SeriesNumber', 'StudyInstanceUID', 'SeriesInstanceUID', 'Mfr', 'Model', 'software_versions'], ARRAY['intake'], 'intake', 'List of all Files Images By Collection, Site
')
        ;

            insert into queries
            values ('GetSeriesWithSignatureByCollectionSite', 'select distinct
  series_instance_uid, dicom_file_type, 
  modality|| '':'' || coalesce(manufacturer, ''<undef>'') || '':'' 
  || coalesce(manuf_model_name, ''<undef>'') ||
  '':'' || coalesce(software_versions, ''<undef>'') as signature,
  count(distinct series_instance_uid) as num_series,
  count(distinct file_id) as num_files
from
  file_series natural join file_equipment natural join ctp_file
  natural join dicom_file
where project_name = ? and site_name = ? and visibility is null
group by series_instance_uid, dicom_file_type, signature
', ARRAY['collection', 'site'], 
                    ARRAY['series_instance_uid', 'dicom_file_type', 'signature', 'num_series', 'num_files'], ARRAY['signature', 'phi_review'], 'posda_files', 'Get a list of Series with Signatures by Collection
')
        ;

            insert into queries
            values ('AllVisibleSubjects', 'select
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
', '{}', 
                    ARRAY['patient_id', 'status', 'project_name', 'site_name', 'num_files'], ARRAY['FindSubjects', 'PatientStatus'], 'posda_files', 'Find All Subjects which have at least one visible file
')
        ;

            insert into queries
            values ('SafeToHideDupSopsBeforeDate', 'select distinct sop_instance_uid from (
  select
    distinct sop_instance_uid, file_id, max(import_time) latest
  from file_location join file_import using(file_id) join import_event using (import_event_id)  
    join file_sop_common using(file_id) join ctp_file using (file_id)
  where sop_instance_uid in (
    select distinct sop_instance_uid from (
      select distinct sop_instance_uid, count(distinct file_id)
      from file_sop_common natural join ctp_file
      where project_name = ? and visibility is null group by sop_instance_uid
      ) as foo
    where count > 1
    ) and visibility is null
  group by sop_instance_uid, file_id
) as foo where latest < ?
except
select distinct sop_instance_uid from (
  select
    distinct sop_instance_uid, file_id, max(import_time) latest
  from file_location join file_import using(file_id) join import_event using (import_event_id)  
    join file_sop_common using(file_id) join ctp_file using (file_id)
  where sop_instance_uid in (
    select distinct sop_instance_uid from (
      select distinct sop_instance_uid, count(distinct file_id)
      from file_sop_common natural join ctp_file
      where project_name = ? and visibility is null group by sop_instance_uid
      ) as foo
    where count > 1
    ) and visibility is null
  group by sop_instance_uid, file_id
) as foo where latest >= ?', ARRAY['collection', 'break_date', 'collection_1', 'break_date_1'], 
                    ARRAY['collection'], ARRAY['meta', 'test', 'hello', 'bills_test'], 'posda_files', 'List of duplicate sops with file_ids and latest load date<br><br>
<bold>Warning: may generate a lot of output</bold>')
        ;

            insert into queries
            values ('UpdateNonDicomEditCompareDisposition', 'update non_dicom_edit_compare_disposition set
  num_edits_scheduled = ?,
  num_compares_with_diffs = ?,
  num_compares_without_diffs = ?,
  current_disposition = ''Comparisons In Progress'',
  last_updated = now()
where
  subprocess_invocation_id = ?
', ARRAY['number_edits_scheduled', 'number_compares_with_diffs', 'number_compares_without_diffs', 'subprocess_invocation_id'], 
                    '{}', ARRAY['adding_ctp', 'for_scripting', 'non_dicom_edit'], 'posda_files', 'Update an entry in dicom_edit_compare_disposition

From script only.  Don''t run from user interface (needs valid subprocess_invocation_id)')
        ;

            insert into queries
            values ('GetDciodvfyErrorUnrecog', 'select
  dciodvfy_error_id as id
from 
  dciodvfy_error
where
  error_type = ''UnrecognizedEnumeratedValue''
  and error_value = ?
  and error_tag = ?
  and error_index = ?', ARRAY['error_value', 'error_tag', 'error_index'], 
                    ARRAY['id'], ARRAY['NotInteractive', 'used_in_dciodvfy'], 'posda_phi_simple', 'Get an dciodvfy_errors row by error_text (if present)')
        ;

            insert into queries
            values ('DispositonsNeededSimple', 'select 
  distinct 
  element_seen_id as id, 
  element_sig_pattern,
  vr,
  tag_name,
  value
from
  element_seen
  natural join element_value_occurance
  natural join value_seen
where
  is_private and 
  private_disposition is null
', '{}', 
                    ARRAY['id', 'element_sig_pattern', 'vr', 'tag_name', 'value'], ARRAY['tag_usage', 'simple_phi_maint', 'phi_maint'], 'posda_phi_simple', 'Private tags with no disposition with values in phi_simple')
        ;

            insert into queries
            values ('BackgroundProcessStatsWithInvoker', 'select
  distinct command_executed, invoking_user as invoker, 
  max(when_script_ended - when_script_started) as longest,
  min(when_script_ended - when_script_started) as shortest,
  avg(when_script_ended - when_script_started) as avg, count(*) as times_invoked,
  min(when_script_started) as first, max(when_script_started) as last
from
  background_subprocess natural join subprocess_invocation
where
  when_script_ended is not null
group by command_executed, invoker', '{}', 
                    ARRAY['command_executed', 'invoker', 'longest', 'shortest', 'avg', 'times_invoked', 'first', 'last'], ARRAY['invoking_user'], 'posda_files', 'Get a list of collections and sites
')
        ;

            insert into queries
            values ('AllProcessedManifestsBySite', 'select
  distinct file_id, cm_collection, cm_site,  sum(cm_num_files) as total_files
from
  ctp_manifest_row
where
  cm_site = ?
group by file_id, cm_collection, cm_site', ARRAY['site'], 
                    ARRAY['file_id', 'cm_collection', 'cm_site', 'total_files'], ARRAY['activity_timepoint_support', 'manifests'], 'posda_files', 'Create An Activity Timepoint

')
        ;

            insert into queries
            values ('ListOfAvailableQueriesByTag', 'select tag, name, description from (
  select
    unnest(tags) as tag,
    name, description
  from queries
) as foo
where tag = ?
order by name', ARRAY['tag'], 
                    ARRAY['tag', 'name', 'description'], ARRAY['AllCollections', 'q_list'], 'posda_queries', 'Get a list of available queries')
        ;

            insert into queries
            values ('CloseActivity', 'update activity set
  when_closed = now()
where
  activity_id = ?', ARRAY['activity_id'], 
                    '{}', ARRAY['activity_timepoint_support', 'activity_support'], 'posda_queries', 'Close an activity

')
        ;

            insert into queries
            values ('RTSTRUCTWithBadModality', 'select distinct
  project_name as collection,
  site_name as site, 
  patient_id,
  series_instance_uid,
  modality,
  dicom_file_type,
  count(distinct file_id) as num_files
from
  file_series natural join ctp_file natural join file_patient
  natural join dicom_file
where 
  dicom_file_type = ''RT Structure Set Storage'' and 
  visibility is null and
  modality != ''RTSTRUCT''
group by
  collection, site, patient_id, series_instance_uid, modality, dicom_file_type
order by
  collection, site, patient_id
', '{}', 
                    ARRAY['collection', 'site', 'patient_id', 'series_instance_uid', 'modality', 'dicom_file_type', 'num_files'], ARRAY['by_series', 'consistency', 'for_bill_series_consistency'], 'posda_files', 'Check a Series for Consistency
')
        ;

            insert into queries
            values ('ListSrPublic', 'select 
  tdp.project as collection, dp_site_name as site, i.patient_id, dicom_file_uri 
from
  general_image i, general_series s, trial_data_provenance tdp
where
  tdp.trial_dp_pk_id = i.trial_dp_pk_id and s.modality = ''SR'' and s.general_series_pk_id = i.general_series_pk_id
  and tdp.project like ?', ARRAY['collection_like'], 
                    ARRAY['collection', 'site', 'patient_id', 'dicom_file_uri'], ARRAY['meta', 'test', 'hello', 'query_tabs', 'bills_test', 'view_structured_reports'], 'public', 'Add a filter to a tab')
        ;

            insert into queries
            values ('ListOfAvailableQueriesByTagLike', 'select distinct name, description, tags from (
  select
    unnest(tags) as tag,
    name, description,
    array_to_string(tags, '','') as tags
  from queries
) as foo
where tag like ?
order by name', ARRAY['tag'], 
                    ARRAY['name', 'description', 'tags'], ARRAY['AllCollections', 'q_list'], 'posda_queries', 'Get a list of available queries')
        ;

            insert into queries
            values ('ListOfPublicElementsWithDispositionsBySopClassName', 'select
  element_signature, vr , disposition, name_chain
from
  element_signature natural join public_disposition
where
  sop_class_uid = ? and name = ?
order by element_signature
', ARRAY['sop_class_uid', 'name'], 
                    ARRAY['element_signature', 'vr', 'disposition', 'name_chain'], ARRAY['NotInteractive', 'Update', 'ElementDisposition'], 'posda_phi', 'Get Public Disposition of element by sig and VR for SOP Class and name')
        ;

            insert into queries
            values ('PrependTagToQuery', 'update queries
set tags = array_prepend(?, tags)
where name = ?', ARRAY['tag', 'name'], 
                    '{}', ARRAY['meta', 'test', 'hello', 'query_tags'], 'posda_queries', 'Add a tag to a query')
        ;

            insert into queries
            values ('VisualReviewStatusById', 'select
  distinct visual_review_instance_id as id, processing_status, review_status, dicom_file_type,
  count(distinct image_equivalence_class_id) as num_equiv, 
  count(distinct series_instance_uid) as num_series
from
  image_equivalence_class natural join image_equivalence_class_input_image 
  natural join dicom_file natural join ctp_file
where
  visual_review_instance_id = ?
group by id, processing_status, review_status, dicom_file_type', ARRAY['id'], 
                    ARRAY['id', 'processing_status', 'review_status', 'dicom_file_type', 'num_equiv', 'num_series'], ARRAY['by_collection', 'find_series', 'compare_collection_site', 'search_series', 'edit_files', 'simple_phi', 'dciodvfy', 'ctp_details', 'select_for_phi', 'visual_review_reports', 'visual_review_new_workflow'], 'posda_files', 'Get Series in A Collection, site with dicom_file_type, modality, and sop_count
')
        ;

            insert into queries
            values ('SubjectsWithDupSopsWithConflictingPixels', 'select 
  distinct project_name, site_name, patient_id, count(distinct file_id)
from
  ctp_file natural join file_sop_common natural join file_patient
where sop_instance_uid in (
  select distinct sop_instance_uid
  from (
    select
      distinct sop_instance_uid, count(*)
    from (
      select
        sop_instance_uid, unique_pixel_data.digest as pixel_digest
      from
        file_sop_common natural join file natural join file_image join
        image using (image_id) join unique_pixel_data using (unique_pixel_data_id)
    )as foo group by sop_instance_uid
  ) as foo where count > 1
)
group by
  project_name, site_name, patient_id
order by 
  project_name, site_name, patient_id, count desc
  ', '{}', 
                    ARRAY['project_name', 'site_name', 'patient_id', 'count'], ARRAY['pix_data_dups'], 'posda_files', 'Find list of series with SOP with duplicate pixel data')
        ;

            insert into queries
            values ('ShowQueryTabHierarchyByTab', 'select 
     query_tab_name,
      filter_name,
      unnest(tags_enabled) as tag
  from
    query_tabs join query_tabs_query_tag_filter using(query_tab_name)
    natural join query_tag_filter
  where query_tab_name = ?
', ARRAY['query_tab_name'], 
                    ARRAY['query_tab_name', 'filter_name', 'tag'], ARRAY['meta', 'test', 'hello', 'query_tabs', 'bills_test'], 'posda_queries', 'Add a filter to a tab')
        ;

            insert into queries
            values ('DoesDoseReferenceBadPlan', 'select
  distinct project_name as collection,
  site_name as site,
  patient_id,
  series_instance_uid,
  file_id
from
  file_series natural join
  file_patient natural join ctp_file
where
  project_name = ? and
  visibility is null and
  file_id in (
select file_id from rt_dose d natural join file_dose  where
not exists (select sop_instance_uid from file_sop_common fsc where d.rt_dose_referenced_plan_uid
= fsc.sop_instance_uid))', ARRAY['collection'], 
                    ARRAY['collection', 'site', 'patient_id', 'series_instance_uid', 'file_id'], ARRAY['LinkageChecks', 'used_in_dose_linkage_check'], 'posda_files', 'Get list of RTDOSE which reference unknown SOPs

')
        ;

            insert into queries
            values ('GetPosdaSopsForCompareLikeCollectionForSite', 'select
  distinct patient_id,
  study_instance_uid, 
  series_instance_uid, 
  sop_instance_uid,
  sop_class_uid,
  modality,
  dicom_file_type,
  root_path || ''/'' || rel_path as file_path,
  file_id
from
  ctp_file
  natural join dicom_file
  natural join file_patient
  natural join file_study
  natural join file_series
  natural join file_sop_common
  natural join file_location
  natural join file_storage_root
where
  project_name like ? and site_name = ?
  and visibility is null', ARRAY['collection', 'site'], 
                    ARRAY['patient_id', 'study_instance_uid', 'series_instance_uid', 'sop_instance_uid', 'sop_class_uid', 'modality', 'dicom_file_type', 'file_path', 'file_id'], ARRAY['public_posda_counts'], 'posda_files', 'Generate a long list of all unhidden SOPs for a collection in posda<br>
<em>This can generate a long list</em>')
        ;

            insert into queries
            values ('SimplePhiReportByScanVrScreenDeletedPT', 'select 
  distinct element_sig_pattern as element, vr, value, 
  tag_name as description, 
  private_disposition as disposition, count(*) as num_series
from element_value_occurance natural join element_seen natural join value_seen
where 
  phi_scan_instance_id = ? and vr = ? and
  private_disposition in (''k'', ''oi'', ''h'', ''o'', null)
group by element_sig_pattern, vr, value, tag_name, private_disposition', ARRAY['scan_id', 'vr'], 
                    ARRAY['element', 'vr', 'value', 'description', 'disposition', 'num_series'], ARRAY['tag_usage', 'simple_phi'], 'posda_phi_simple', 'Status of PHI scans
')
        ;

            insert into queries
            values ('GetPublicSopsForCompareByPatientId', 'select
  distinct i.patient_id,
  i.study_instance_uid,
  s.series_instance_uid,
  sop_instance_uid,
  sop_class_uid,
  s.modality,
  count(*) as num_files
from
  general_image i,
  trial_data_provenance tdp,
  general_series s
where  
  i.trial_dp_pk_id = tdp.trial_dp_pk_id 
  and i.general_series_pk_id = s.general_series_pk_id
  and i.patient_id = ?', ARRAY['patient_id'], 
                    ARRAY['patient_id', 'study_instance_uid', 'series_instance_uid', 'sop_instance_uid', 'sop_class_uid', 'modality', 'num_files'], ARRAY['public_posda_counts'], 'public', 'Generate a long list of all unhidden SOPs for a collection in public<br>
<em>This can generate a long list</em>')
        ;

            insert into queries
            values ('InboxContentAllByUserToDismiss', 'select
 user_name, user_inbox_content_id as id, operation_name,
  current_status,
  activity_id, brief_description,
  when_script_started as when, 
  file_id, subprocess_invocation_id as sub_id,
  command_line,
  file_id_in_posda as spreadsheet_file_id
from 
  user_inbox natural join
  user_inbox_content natural join background_subprocess_report
  natural join background_subprocess natural left join subprocess_invocation
  natural left join spreadsheet_uploaded
  natural left join activity_inbox_content natural left join
  activity
where user_name = ? and activity_id is null and current_status != ''dismissed''
order by user_inbox_content_id desc', ARRAY['user_name'], 
                    ARRAY['user_name', 'id', 'operation_name', 'current_status', 'activity_id', 'brief_description', 'when', 'file_id', 'command_line', 'spreadsheet_file_id'], ARRAY['AllCollections', 'queries', 'activity_support'], 'posda_queries', 'Get a list of available queries')
        ;

            insert into queries
            values ('InsertCollectionCountPerRound', 'insert into collection_count_per_round(
  collection, file_count
) values (
  ?, ?
)
', ARRAY['collection', 'num_files'], 
                    '{}', ARRAY['NotInteractive', 'Backlog'], 'posda_backlog', 'Insert a row into collection count per round')
        ;

            insert into queries
            values ('DistinctSopsInSeriesForComparePublic', 'select 
  sop_instance_uid, sop_class_uid, i.patient_id, modality
from
  general_image i, general_series s
where
  s.series_instance_uid = i.series_instance_uid and s.series_instance_uid = ?', ARRAY['series_instance_uid'], 
                    ARRAY['sop_instance_uid', 'sop_class_uid', 'modality', 'count'], ARRAY['compare_series'], 'public', 'Get Distinct SOPs in Series with number files
Only visible filess
')
        ;

            insert into queries
            values ('DoseSopToForByCollectionSite', 'select 
  distinct patient_id,  sop_instance_uid, 
  for_uid
from 
  file_for natural join file_dose join file_sop_common using(file_id) join file_patient using (file_id)
where
  file_id in (
    select file_id 
    from ctp_file natural join file_dose 
    where project_name = ? and site_name = ? and visibility is null
  )
order by patient_id', ARRAY['collection', 'site'], 
                    ARRAY['patient_id', 'sop_instance_uid', 'for_uid'], ARRAY['Structure Sets', 'sops', 'LinkageChecks', 'dose_linkages'], 'posda_files', 'Get list of plan which reference unknown SOPs

')
        ;

            insert into queries
            values ('GetFilePathAndModality', 'select
  root_path || ''/'' || rel_path as path, modality
from
  file_location natural join file_storage_root join file_series using(file_id)
where
  file_id = ?', ARRAY['file_id'], 
                    ARRAY['path', 'modality'], ARRAY['AllCollections', 'universal', 'public_posda_consistency'], 'posda_files', 'Get path to file by id')
        ;

            insert into queries
            values ('GetCollectionSitePatientStudyDateFileCountMaxMinLoadDateForPatientsByDateRange', 'select * from (select 
  collection, site, patient_id, qualified, study_date,
  count(distinct file_id) as num_files, count (distinct sop_instance_uid) as num_sops,
  min(date_trunc(''day'',import_time)) as earliest_day, max(date_trunc(''day'', import_time)) as latest_day
from
  clinical_trial_qualified_patient_id join file_patient using (patient_id) 
  join file_study using(file_id) join file_import using(file_id)
  join file_sop_common using(file_id)
  join import_event using(import_event_id)
where patient_id in (
  select 
    distinct patient_id
  from
    clinical_trial_qualified_patient_id join file_patient using (patient_id) 
    join file_import using(file_id)
    join import_event using(import_event_id)
  where 
    collection like ? and import_time > ? and import_time < ? and import_type not like ''script%''
)
group by collection, site, patient_id, qualified, study_date) as foo
where earliest_day < ?', ARRAY['collection_like', 'from', 'to', 'to_again'], 
                    ARRAY['collection', 'site', 'patient_id', 'qualified', 'study_date', 'num_files', 'num_sops', 'earliest_day', 'latest_day'], ARRAY['clin_qual'], 'posda_files', 'Create An Activity Timepoint

')
        ;

            insert into queries
            values ('RoundSummary1VeryRecent', 'select
  distinct round_id,
  round_start, 
  round_end - round_start as duration, 
  round_end, 
  sum(num_entered + num_dups),
  ((round_end - round_start) / sum(num_entered + num_dups)) as sec_per_file
from
  round natural join round_collection
where
  round_end is not null and (now() - round_end) < ''1:00''
group by 
  round_id, round_start, duration, round_end 
order by round_id', '{}', 
                    ARRAY['round_id', 'round_start', 'duration', 'round_end', 'sum', 'sec_per_file'], ARRAY['NotInteractive', 'Backlog', 'Backlog Monitor', 'backlog_status'], 'posda_backlog', 'Summary of rounds')
        ;

            insert into queries
            values ('UnHideFilesCSP', 'update ctp_file set visibility = null where file_id in (
  select
    distinct file_id
  from
    ctp_file natural join file_patient
  where
    project_name = ? and site_name = ?
    and visibility = ''hidden'' and patient_id = ?
);
', ARRAY['collection', 'site', 'subject'], 
                    NULL, '{}', 'posda_files', 'UnHide all files hidden by Collection, Site, Subject
')
        ;

            insert into queries
            values ('FindUnpopulatedPets', 'select
  file_id, root_path || ''/'' || rel_path as file_path
from file_location natural join file_storage_root
where file_id in
(
  select distinct file_id from dicom_file df
  where dicom_file_type = ''Positron Emission Tomography Image Storage''
  and not exists (select file_id from file_pt_image pti where pti.file_id = df.file_id)
)', '{}', 
                    ARRAY['file_id', 'file_path'], ARRAY['populate_posda_files', 'bills_test'], 'posda_files', 'Get''s all files which are PET''s which haven''t been imported into file_pt_image yet.

<bold>Don''t run interactively</bold>')
        ;

            insert into queries
            values ('GetAdverseFileEventsByEditEventId', 'select
  adverse_file_event_id,
  file_id,
  event_description,
  when_occured
from
  adverse_file_event natural join
  dicom_edit_event_adverse_file_event
where
  dicom_edit_event_id = ?', ARRAY['dicom_edit_event_id'], 
                    ARRAY['adverse_file_event_id', 'file_id', 'event_description', 'when_occured'], ARRAY['NotInteractive', 'used_in_import_edited_files'], 'posda_files', 'Get List of Adverse File Events for a given dicom_edit_event
For use in scripts
Not really intended for interactive use
')
        ;

            insert into queries
            values ('UpdCTQP', 'update clinical_trial_qualified_patient_id
  set qualified = ?
where
  collection = ? and site = ? and patient_id = ?
 ', ARRAY['qualified', 'collection', 'site', 'patient_id'], 
                    '{}', ARRAY['activity_timepoint_support'], 'posda_files', 'Create An Activity Timepoint

')
        ;

            insert into queries
            values ('ShowAllHideEventsByCollectionSiteModality', 'select
  file_id,
  user_name,
  time_of_change,
  prior_visibility,
  new_visibility,
  reason_for
from
   file_visibility_change 
where file_id in (
  select file_id 
  from ctp_file natural join file_series
  where project_name = ? and site_name = ? and
  modality = ?
)', ARRAY['collection', 'site', 'modality'], 
                    ARRAY['file_id', 'user_name', 'time_of_change', 'prior_visibility', 'new_visibility', 'reason_for'], ARRAY['old_hidden'], 'posda_files', 'Show All Hide Events by Collection, Site')
        ;

            insert into queries
            values ('SeriesInCollectionSiteForApplicationOfPrivateDisposition', 'select
  distinct 
  patient_id, study_instance_uid, series_instance_uid
from
  file_patient natural join ctp_file natural join file_study 
  natural join file_sop_common natural join file_series
where
  collection = ? and site = ? and visibility is null
', ARRAY['collection', 'site'], 
                    ARRAY['patient_id', 'study_instance_uid', 'series_instance_uid'], ARRAY['by_collection_site', 'find_files'], 'posda_files', 'Get a patient, study, series hierarchy by collection, site')
        ;

            insert into queries
            values ('DismissInboxContentItem', 'update user_inbox_content
set date_dismissed = now(),
current_status = ''dismissed''
where user_inbox_content_id = ?

', ARRAY['user_inbox_content_id'], 
                    '{}', '{}', 'posda_queries', 'Set the date_dismissed value on an Inbox item')
        ;

            insert into queries
            values ('FindInconsistentSeries', 'select series_instance_uid from (
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
', ARRAY['collection'], 
                    ARRAY['series_instance_uid'], ARRAY['consistency', 'find_series', 'for_bill_series_consistency'], 'posda_files', 'Find Inconsistent Series
')
        ;

            insert into queries
            values ('PrivateTagsByEquipment', 'select distinct element_signature from (
select
  distinct element_signature, equipment_signature
from 
  equipment_signature natural join series_scan
  natural join scan_element natural join element_signature
  natural join scan_event
where scan_event_id = ? and is_private ) as foo
where equipment_signature = ?
order by element_signature;
', ARRAY['scan_id', 'equipment_signature'], 
                    ARRAY['element_signature'], ARRAY['tag_usage'], 'posda_phi', 'Which equipment signatures for which private tags
')
        ;

            insert into queries
            values ('FirstFileInSeriesIntake', 'select
  dicom_file_uri as path
from
  general_image
where
  series_instance_uid =  ?
limit 1
', ARRAY['series_instance_uid'], 
                    ARRAY['path'], ARRAY['by_series', 'intake', 'UsedInPhiSeriesScan'], 'intake', 'First files in series in Intake
')
        ;

            insert into queries
            values ('DistinctSopsInCollectionIntakeWithFile', 'select
  distinct i.sop_instance_uid, i.dicom_file_uri
from
  general_image i,
  trial_data_provenance tdp
where
  i.trial_dp_pk_id = tdp.trial_dp_pk_id and
  tdp.project = ?
order by sop_instance_uid
', ARRAY['collection'], 
                    ARRAY['sop_instance_uid', 'dicom_file_uri'], ARRAY['by_collection', 'files', 'intake', 'sops'], 'intake', 'Get Distinct SOPs in Collection with number files
Only visible files
')
        ;

            insert into queries
            values ('CreateSimplePhiScanRow', 'insert into phi_scan_instance(
description, num_series, start_time, num_series_scanned,file_query
)values(?, ?,now(), 0,?)', ARRAY['description', 'num_series', 'file_query'], 
                    '{}', ARRAY['used_in_simple_phi', 'NotInteractive'], 'posda_phi_simple', 'Create a new Simple PHI scan')
        ;

            insert into queries
            values ('CreateDicomFileEditRow', 'insert into dicom_file_edit(
  dicom_edit_event_id, from_file_digest, to_file_digest
) values (?, ?, ?)
', ARRAY['dicom_edit_event_id', 'from_file_digest', 'to_file_digest'], 
                    '{}', ARRAY['Insert', 'NotInteractive', 'used_in_import_edited_files'], 'posda_files', 'Insert dicom_edit_event row
For use in scripts
Not really intended for interactive use
')
        ;

            insert into queries
            values ('Series In Public By PatientId', 'select 
  distinct series_instance_uid
from
  general_image i, trial_data_provenance tdp
where
  tdp.trial_dp_pk_id = i.trial_dp_pk_id and patient_id = ?
', ARRAY['patient_id'], 
                    ARRAY['series_instance_uid'], ARRAY['Reconcile Public and Posda for CPTAC'], 'public', 'Get the list of files by sop, excluding base series')
        ;

            insert into queries
            values ('PlansWithNoFrameOfRef', 'select 
  file_id,
  root_path || ''/'' || rel_path as path
from
  file_location natural join file_storage_root natural join ctp_file
where 
  file_id in (
    select file_id 
    from file_plan p
    where not exists (select for_uid from file_for f where f.file_id = p.file_id)
  )', '{}', 
                    ARRAY['file_id', 'path'], ARRAY['Structure Sets', 'sops', 'LinkageChecks', 'plan_linkages'], 'posda_files', 'Get list of plan which reference unknown SOPs

')
        ;

            insert into queries
            values ('SeriesWithDupSopsWithConflictingPixels', 'select 
  distinct project_name, site_name, patient_id, study_instance_uid, 
  series_instance_uid, count(distinct file_id)
from
  ctp_file natural join file_sop_common natural join file_patient natural join 
  file_study natural join file_series 
where sop_instance_uid in (
  select distinct sop_instance_uid
  from (
    select
      distinct sop_instance_uid, count(*)
    from (
      select
        sop_instance_uid, unique_pixel_data.digest as pixel_digest
      from
        file_sop_common natural join file natural join file_image join
        image using (image_id) join unique_pixel_data using (unique_pixel_data_id)
    )as foo group by sop_instance_uid
  ) as foo where count > 1
)
group by
  project_name, site_name, patient_id, study_instance_uid, series_instance_uid
order by 
  project_name, site_name, patient_id, count desc
  ', '{}', 
                    ARRAY['project_name', 'site_name', 'patient_id', 'study_instance_uid', 'series_instance_uid', 'count'], ARRAY['pix_data_dups'], 'posda_files', 'Find list of series with SOP with duplicate pixel data')
        ;

            insert into queries
            values ('RoundStatsByCollectionForDateRange', 'select
  distinct collection, site, date_trunc(?, time_received) as time,
  count(*) as number_of_files,
  max(time_entered - time_received) as max_delay,
  min(time_entered - time_received) as min_delay
from request natural join submitter
where time_received > ? and time_received < ? and collection = ?
group by collection, site, time order by time desc, collection', ARRAY['interval', 'from', 'to', 'collection'], 
                    ARRAY['collection', 'site', 'time', 'number_of_files', 'max_delay', 'min_delay'], ARRAY['NotInteractive', 'Backlog', 'Backlog Monitor', 'for_bill'], 'posda_backlog', 'Summary of rounds')
        ;

            insert into queries
            values ('DistinctSeriesBySubjectPublic', 'select
  distinct s.series_instance_uid, modality, count(*) as num_images
from
  general_image i, general_series s,
  trial_data_provenance tdp
where
  s.general_series_pk_id = i.general_series_pk_id and
  i.patient_id = ? and i.trial_dp_pk_id = tdp.trial_dp_pk_id and
  tdp.project = ?
group by series_instance_uid, modality
', ARRAY['subject_id', 'project_name'], 
                    ARRAY['series_instance_uid', 'modality', 'num_images'], ARRAY['by_subject', 'find_series', 'public'], 'public', 'Get Series in A Collection, Site, Subject
')
        ;

            insert into queries
            values ('GetBacklogCountAndPrioritySummary', 'select
  distinct collection, file_count as priority, count(*) as num_requests
from
  submitter natural join request natural join collection_count_per_round
where
  not file_in_posda
group by collection, file_count
', '{}', 
                    ARRAY['collection', 'priority', 'num_requests'], ARRAY['NotInteractive', 'Backlog', 'backlog_status'], 'posda_backlog', 'Get List of Collections with Backlog and Priority Counts')
        ;

            insert into queries
            values ('ListOfPublicDispositionTables', 'select
  distinct sop_class_uid, name, count(*)
from
  public_disposition
group by
  sop_class_uid, name
order by
  sop_class_uid, name', '{}', 
                    ARRAY['sop_class_uid', 'name', 'count'], ARRAY['NotInteractive', 'ElementDisposition'], 'posda_phi', 'Get List of Public Disposition Tables')
        ;

            insert into queries
            values ('EquipmentByValueSignature', 'select distinct value, vr, element_signature, equipment_signature, count(*)
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
', ARRAY['scan_id', 'value', 'tag_signature'], 
                    ARRAY['value', 'vr', 'element_signature', 'equipment_signature', 'count'], ARRAY['tag_usage'], 'posda_phi', 'List of equipment, values seen in scan by VR with count
')
        ;

            insert into queries
            values ('SubjectsWithDuplicateSopsWithConflictingGeometricInfo', 'select distinct patient_id, study_instance_uid, series_instance_uid, count(*)
from
  file_patient natural join file_sop_common natural join file_series natural join file_study
where sop_instance_uid in (
  select sop_instance_uid from (
    select distinct sop_instance_uid, count(*) from (
    select 
      distinct sop_instance_uid, iop as image_orientation_patient,
      ipp as image_position_patient,
      pixel_spacing,
      pixel_rows as i_rows,
      pixel_columns as i_columns
    from
      file_sop_common join 
      file_patient using (file_id) join
      file_image using (file_id) join 
      file_series using (file_id) join
      file_study using (file_id) join
      image using (image_id) join
      file_image_geometry using (file_id) join
      image_geometry using (image_geometry_id) 
    ) as foo 
    group by sop_instance_uid
  ) as foo where count > 1
) group by patient_id, study_instance_uid, series_instance_uid', '{}', 
                    ARRAY['patient_id', 'study_instance_uid', 'series_instance_uid', 'count'], ARRAY['duplicates'], 'posda_files', 'Return a count of duplicate SOP Instance UIDs with conflicting Geometric Information by Patient Id, study, series
')
        ;

            insert into queries
            values ('GetPrivateTagNameAndVrBySignature', 'select
  pt_consensus_name as name,
  pt_consensus_vr as vr
from pt
where pt_signature = ?
', ARRAY['signature'], 
                    ARRAY['name', 'vr'], ARRAY['DispositionReport', 'NotInteractive', 'used_in_reconcile_tag_names'], 'posda_private_tag', 'Get the relevant features of a private tag by signature
Used in DispositionReport.pl - not for interactive use
')
        ;

            insert into queries
            values ('insert_list_of_roles', 'update query_tag_filter
set tags_enabled = ?
where filter_name = ?', ARRAY['tag_list', 'role'], 
                    '{}', ARRAY['roles'], 'posda_queries', 'Insert a list of tags for a role
')
        ;

            insert into queries
            values ('WindowLevelByPixelType', 'select 
  distinct window_width, window_center, count(*)
from (select
    distinct photometric_interpretation,
    samples_per_pixel,
    bits_allocated,
    bits_stored,
    high_bit,
    coalesce(number_of_frames,1) > 1 as is_multi_frame,
    pixel_representation,
    planar_configuration,
    modality,
    file_id
  from
    image natural join file_image natural join file_series
  ) as foo natural join file_win_lev natural join window_level
where
  photometric_interpretation = ? and
  samples_per_pixel = ? and
  bits_allocated = ? and
  bits_stored = ? and
  high_bit = ? and
  pixel_representation = ? and
  modality = ?
group by window_width, window_center
', ARRAY['photometric_interpretation', 'samples_per_pixel', 'bits_allocated', 'bits_stored', 'high_bit', 'pixel_representation', 'modality'], 
                    ARRAY['window_width', 'window_center', 'count'], ARRAY['all', 'find_pixel_types', 'posda_files'], 'posda_files', 'Get distinct pixel types
')
        ;

            insert into queries
            values ('WhatHasComeInRecentlyWithSubjectByCollectionLikeAndFileInPosdaCount', 'select
  distinct collection, site, subj, date_trunc(?, time_received) as time,
  count(*) as number_of_files, count(distinct posda_file_id) as num_files_in_posda,
  max(time_entered - time_received) as max_delay,
  min(time_entered - time_received) as min_delay
from request natural join submitter
where time_received > ? and time_received < ?
and collection like ?
group by collection, site, subj, time order by time desc, collection, site, subj', ARRAY['interval', 'from', 'to', 'collection_like'], 
                    ARRAY['collection', 'site', 'subj', 'time', 'number_of_files', 'num_files_in_posda', 'max_delay', 'min_delay'], ARRAY['NotInteractive', 'Backlog', 'Backlog Monitor', 'backlog_round_history'], 'posda_backlog', 'Summary of rounds')
        ;

            insert into queries
            values ('DistinctSeriesByCollectionSiteIntake', 'select
  distinct s.series_instance_uid, modality, count(*) as num_images
from
  general_image i, general_series s,
  trial_data_provenance tdp
where
  s.general_series_pk_id = i.general_series_pk_id and
  i.trial_dp_pk_id = tdp.trial_dp_pk_id and
  tdp.project = ? and tdp.dp_site_name = ?
group by series_instance_uid, modality', ARRAY['project_name', 'site_name'], 
                    ARRAY['series_instance_uid', 'modality', 'num_images'], ARRAY['by_collection', 'find_series', 'intake', 'compare_collection_site', 'simple_phi'], 'intake', 'Get Series in A Collection, Site
')
        ;

            insert into queries
            values ('FinalizePhiNonDicomInstance', 'update phi_non_dicom_scan_instance
set pndsi_end_time = now()
where phi_non_dicom_scan_instance_id = ?', ARRAY['phi_non_dicom_scan_instance_id'], 
                    '{}', ARRAY['used_in_simple_phi', 'NotInteractive', 'non_dicom_phi'], 'posda_phi_simple', 'Get value seen if exists')
        ;

            insert into queries
            values ('GetThisWeeksRange', 'select 
  date_trunc(''week'', now()) as start_week,
  date_trunc(''week'', now() + interval ''7 days'') as end_week,
  date_trunc(''day'', now() + interval ''1 day'') as end_partial_week,
  date_trunc(''day'', now()) as today
', '{}', 
                    ARRAY['start_week', 'end_week', 'end_partial_week', 'today'], ARRAY['downloads_by_date'], 'posda_files', 'Counts query by Collection, Site
')
        ;

            insert into queries
            values ('IntakeSeriesWithSignatureByCollectionSite', 'select
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
', ARRAY['collection', 'site'], 
                    ARRAY['series_instance_uid', 'Modality', 'signature'], ARRAY['intake'], 'intake', 'List of all Series By Collection, Site on Intake
')
        ;

            insert into queries
            values ('RowsInDicomFileWithNoPixelInfoEarliest', 'select 
  file_id, root_path || ''/'' || rel_path as path
from dicom_file natural join file_location natural join file_storage_root
where has_pixel_data is null and file_is_present
order by file_id limit ?', ARRAY['num_rows'], 
                    ARRAY['file_id', 'path'], ARRAY['adding_pixels_to_dicom_file'], 'posda_files', 'List of files (id, path) which are dicom_files with undefined pixel info')
        ;

            insert into queries
            values ('CloseRound', 'update round
  set round_end = now()
where
  round_id = ?
', ARRAY['round_id'], 
                    '{}', ARRAY['NotInteractive', 'Backlog'], 'posda_backlog', 'Close row in round (set end time)')
        ;

            insert into queries
            values ('GetSsVolumeReferencingUnknownImagesByCollection', 'select 
  distinct project_name as collection, 
  site_name as site, patient_id, 
  file_id 
from 
  ctp_file natural join file_patient 
where file_id in (
   select
    distinct file_id from ss_volume v 
    join ss_for using(ss_for_id) 
    join file_structure_set using (structure_set_id) 
  where 
     not exists (
       select file_id 
       from file_sop_common s 
       where s.sop_instance_uid = v.sop_instance
  )
)
and project_name = ?
and visibility is null
order by collection, site, patient_id', ARRAY['collection'], 
                    ARRAY['collection', 'site', 'patient_id', 'file_id'], ARRAY['Structure Sets', 'sops', 'LinkageChecks', 'struct_linkages'], 'posda_files', 'Get list of plan which reference unknown SOPs

')
        ;

            insert into queries
            values ('ImageFrameOfReferenceBySeries', 'select 
  distinct for_uid, count(*) as num_files
from
  file_series natural join file_sop_common natural join file_for natural join ctp_file
where 
  series_instance_uid = ? and visibility is null
group by for_uid', ARRAY['series_instance_uid'], 
                    ARRAY['for_uid', 'num_files'], ARRAY['Structure Sets', 'sops', 'LinkageChecks', 'struct_linkages'], 'posda_files', 'Get list of plan which reference unknown SOPs

')
        ;

            insert into queries
            values ('RtdoseSopsByCollectionSiteDateRange', 'select distinct
  sop_instance_uid
from
  file_series natural join ctp_file natural join file_sop_common
  natural join file_import natural join import_event
where 
  project_name = ? and site_name = ?
  and visibility is null and import_time > ? and 
  import_time < ?
  and modality = ''RTDOSE''', ARRAY['collection', 'site', 'from', 'to'], 
                    ARRAY['sop_instance_uid'], ARRAY['Hierarchy', 'apply_disposition', 'hash_unhashed'], 'posda_files', 'Construct list of files in a collection, site in a Patient, Study, Series Hierarchy')
        ;

            insert into queries
            values ('GetRoiContoursAndFiles', 'select distinct root_path || ''/'' || rel_path as file_path, roi_id, roi_contour_id, roi_num, contour_num, geometric_type, number_of_points 
from roi_contour natural join roi natural join structure_set natural join file_structure_set natural join file_storage_root natural join file_location
where file_id = ?', ARRAY['file_id'], 
                    ARRAY['file_path', 'roi_id', 'roi_contour_id', 'roi_num', 'contour_num', 'geometric_type', 'number_of_points'], ARRAY['Structure Sets', 'sops', 'LinkageChecks'], 'posda_files', 'Get Structure Set Volume

')
        ;

            insert into queries
            values ('GetFileIdVisibilityBySeriesInstanceUid', 'select distinct file_id, visibility
from file_series natural left join ctp_file
where series_instance_uid = ?', ARRAY['series_instance_uid'], 
                    ARRAY['file_id', 'visibility'], ARRAY['ImageEdit', 'edit_files'], 'posda_files', 'Get File id and visibility for all files in a series')
        ;

            insert into queries
            values ('PosdaImagesByCollectionSitePlus', 'select distinct
  patient_id,
  sop_instance_uid,
  study_instance_uid,
  series_instance_uid,
  digest
from
  file
  natural join  file_patient
  natural join file_series
  natural join file_sop_common
  natural join file_study
   natural join ctp_file
where
  file_id in (
  select distinct file_id from ctp_file
  where project_name = ? and site_name = ? and visibility is null)

', ARRAY['collection', 'site'], 
                    ARRAY['patient_id', 'sop_instance_uid', 'study_instance_uid', 'series_instance_uid', 'digest'], ARRAY['posda_files'], 'posda_files', 'List of all Files Images By Collection, Site
')
        ;

            insert into queries
            values ('GetDciodvfyErrorMissingAttr', 'select
  dciodvfy_error_id as id
from 
  dciodvfy_error
where
  error_type = ''MissingAttributes''
  and error_subtype = ?
  and error_tag = ?
  and error_module = ?', ARRAY['error_subtype', 'error_tag', 'error_module'], 
                    ARRAY['id'], ARRAY['NotInteractive', 'used_in_dciodvfy'], 'posda_phi_simple', 'Get an dciodvfy_errors row by error_text (if present)')
        ;

            insert into queries
            values ('VisibilityChangeEventsByReasonFor', 'select 
  distinct project_name as collection,
  site_name as site,
  patient_id,
  date_trunc(''hour'', time_of_change) as when_done,
  user_name, prior_visibility, new_visibility, reason_for, count(distinct file_id) as num_files,
  count (distinct series_instance_uid) as num_series
from
   ctp_file natural join file_patient natural join file_series natural join file_visibility_change 
where reason_for = ?
group by
 collection, site, patient_id, when_done, user_name, prior_visibility, new_visibility, reason_for
order by when_done desc', ARRAY['reason_for'], 
                    ARRAY['collection', 'site', 'patient_id', 'when_done', 'user_name', 'prior_visibility', 'new_visibility', 'reason_for', 'num_files', 'num_series'], ARRAY['meta', 'test', 'hello', 'bills_test', 'hide_events', 'show_hidden'], 'posda_files', 'Add a filter to a tab')
        ;

            insert into queries
            values ('GetSeriesWithImageAndNoEquivalenceClassByCollectionSiteDateRange', 'select distinct
  project_name as collection, site_name as site,
  patient_id, modality, series_instance_uid, 
  count(distinct sop_instance_uid) as num_sops,
  count(distinct file_id) as num_files
from
  file_series fs natural join file_sop_common
  natural join file_patient
  natural join file_image natural join ctp_file
  natural join file_import natural join import_event
where project_name = ? and site_name = ? and visibility is null
  and import_time > ? and import_time < ?
  and (
    select count(*) 
    from image_equivalence_class ie
    where ie.series_instance_uid = fs.series_instance_uid
  ) = 0
group by
  collection, site, patient_id, modality, series_instance_uid
', ARRAY['collection', 'site', 'from', 'to'], 
                    ARRAY['collection', 'site', 'patient_id', 'modality', 'series_instance_uid', 'num_sops', 'num_files'], ARRAY['signature', 'phi_review', 'visual_review'], 'posda_files', 'Get a list of Series with images by CollectionSite
')
        ;

            insert into queries
            values ('RoundWithIntervalOverlap', 'select
  round_id, collection,
  round_created,
  round_start,  
  round_end - round_start as duration,
  wait_count,
  process_count,
  num_entered,
  num_failed,
  num_dups,
  num_requests,
  priority
from
  round natural join round_counts natural join round_collection
where collection = ? and 
  round_end > ? and round_start < ?
order by round_id, collection', ARRAY['collection', 'from', 'to'], 
                    ARRAY['round_id', 'collection', 'num_dups', 'round_created', 'round_start', 'duration', 'wait_count', 'process_count', 'num_entered', 'num_failed', 'num_dups', 'num_requests', 'priority'], ARRAY['NotInteractive', 'Backlog', 'Backlog Monitor', 'backlog_analysis_reporting_tools', 'backlog_round_history'], 'posda_backlog', 'Summary of rounds')
        ;

            insert into queries
            values ('RoundCountsByCollection2Recent', 'select
  round_id, collection,
  round_created,
  round_start - round_created as q_time,  
  round_end - round_created as duration,
  wait_count,
  process_count,
  num_entered,
  num_failed,
  num_dups,
  num_requests,
  priority
from
  round natural join round_counts natural join round_collection
where collection = ? and (now() - round_end) < ''1:00''
order by round_id, collection', ARRAY['collection'], 
                    ARRAY['round_id', 'collection', 'round_created', 'q_time', 'duration', 'wait_count', 'process_count', 'num_entered', 'num_failed', 'num_dups', 'num_requests', 'priority'], ARRAY['NotInteractive', 'Backlog', 'Backlog Monitor', 'backlog_status'], 'posda_backlog', 'Summary of rounds')
        ;

            insert into queries
            values ('FileTypeModalityCountsByImportId', 'select
  distinct  dicom_file_type, modality, count(*) as num_files
from file_series natural join dicom_file
where file_id in (
  select distinct file_id
  from file_import natural join import_event
  where import_event_id = ?
) group by dicom_file_type, modality', ARRAY['import_event_id'], 
                    ARRAY['dicom_file_type', 'modality', 'num_files'], ARRAY['ACRIN-NSCLC-FDG-PET Curation'], 'posda_files', 'Get the list of files by sop, excluding base series')
        ;

            insert into queries
            values ('GetValueForTagBySeries', 'select
  distinct series_instance_uid, element_signature as tag, value
from
  series_scan natural join scan_element natural join seen_value natural join element_signature
where
  series_instance_uid = ? and element_signature = ?', ARRAY['series_instance_uid', 'tag'], 
                    ARRAY['series_instance_uid', 'tag', 'value'], ARRAY['tag_values'], 'posda_phi', 'Find Distinct value for a given tag for a particular scanned series
')
        ;

            insert into queries
            values ('CreateSubprocessLine', 'insert into subprocess_lines(
 subprocess_invocation_id,
 line_number,
 line
) values (
  ?, ?, ?
)', ARRAY['subprocess_invocation_id', 'line_number', 'line'], 
                    '{}', ARRAY['NotInteractive', 'used_in_background_processing'], 'posda_queries', 'Create a row in subprocess_lines table

Used when invoking a spreadsheet operation from a either a button or a spreadsheet 
to record data retrieved from subprocess (i.e response displayed on screen)')
        ;

            insert into queries
            values ('GetNRequestsForCollection', 'select 
  distinct request_id, collection, received_file_path, file_digest, time_received, size
from 
  request natural join submitter
where
  collection = ? and not file_in_posda 
order by time_received 
limit ?
', ARRAY['collection', 'num_rows'], 
                    ARRAY['request_id', 'collection', 'received_file_path', 'file_digest', 'time_received', 'size'], ARRAY['NotInteractive', 'Backlog'], 'posda_backlog', 'Get N Requests for a Given Collection')
        ;

            insert into queries
            values ('GetSimpleValuesForTag', 'select
  distinct value
from
  element_seen natural join
  element_value_occurance natural join
  value_seen
where element_sig_pattern = ? and vr = ?
', ARRAY['tag', 'vr'], 
                    ARRAY['value'], ARRAY['tag_values'], 'posda_phi_simple', 'Find Values for a given tag, vr in posda_phi_simple
')
        ;

            insert into queries
            values ('SentToIntakeByDate', 'select
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
', ARRAY['from_date', 'to_date'], 
                    ARRAY['send_started', 'duration', 'destination_host', 'destination_port', 'to_send', 'files_sent', 'invoking_user', 'reason_for_send'], ARRAY['send_to_intake'], 'posda_files', 'List of Files Sent To Intake By Date
')
        ;

            insert into queries
            values ('GetPublicInfoBySop', 'select 
  tdp.project, dp_site_name as site_name, dp_site_id as site_id,
  patient_id, study_instance_uid, series_instance_uid
from 
  general_image i, trial_data_provenance tdp 
where 
  tdp.trial_dp_pk_id = i.trial_dp_pk_id and sop_instance_uid = ?', ARRAY['sop_instance_uid'], 
                    ARRAY['project', 'site_name', 'site_id', 'patient_id', 'study_instance_uid', 'series_instance_uid'], ARRAY['bills_test', 'comparing_posda_to_public'], 'public', 'Add a filter to a tab')
        ;

            insert into queries
            values ('FileType', 'select file_type
from file
where file_id = ?
', ARRAY['file_id'], 
                    ARRAY['file_type'], ARRAY['NotInteractive', 'used_in_background_processing'], 'posda_files', 'Get the file_type of a file, by file_id
')
        ;

            insert into queries
            values ('FilesByReviewStatusByCollectionSiteWithVisibility', 'select
  distinct
  file_id,
  project_name as collection,
  site_name as site,
  patient_id,
  series_instance_uid,
  sop_instance_uid,
  file_id,
  visibility
from
  image_equivalence_class_input_image
  join ctp_file using(file_id)
  join file_patient using(file_id)
  join file_series using(file_id)
  join file_sop_common using(file_id)
where 
  image_equivalence_class_id in (
    select
      image_equivalence_class_id 
    from
      image_equivalence_class 
      join file_series using(series_instance_uid)
      join ctp_file using(file_id)
    where 
      project_name = ? and site_name = ?
      and review_status = ?
)', ARRAY['collection', 'site', 'status'], 
                    ARRAY['collection', 'site', 'patient_id', 'series_instance_uid', 'sop_instance_uid', 'file_id', 'visibility'], ARRAY['find_series', 'equivalence_classes', 'consistency', 'visual_review_results', 'hide_files'], 'posda_files', 'Get visual review status report by series for Collection, Site')
        ;

            insert into queries
            values ('InsertImportEvent', '  insert into import_event(
    import_type, import_time
  ) values (
    ''Processing Backlog'', ?
  )', ARRAY['time_tag'], 
                    '{}', ARRAY['NotInteractive', 'Backlog'], 'posda_files', 'Create an import_event')
        ;

            insert into queries
            values ('DistinctDispositionsNeededSimple', 'select 
  distinct 
  element_seen_id as id, 
  element_sig_pattern,
  vr,
  tag_name
from
  element_seen
  natural join element_value_occurance
  natural join value_seen
where
  is_private and 
  private_disposition is null
', '{}', 
                    ARRAY['id', 'element_sig_pattern', 'vr', 'tag_name'], ARRAY['tag_usage', 'simple_phi_maint', 'phi_maint'], 'posda_phi_simple', 'Private tags with no disposition with values in phi_simple')
        ;

            insert into queries
            values ('CurrentPatientWithoutStatii', 'select 
  distinct project_name as collection,
  site_name as site,
  patient_id,
  ''<undef>'' as patient_import_status
from 
  ctp_file natural join file_patient p
where 
  visibility is null and
  not exists (select * from patient_import_status s where p.patient_id = s.patient_id)', '{}', 
                    ARRAY['collection', 'site', 'patient_id', 'patient_import_status'], ARRAY['counts', 'patient_status', 'for_bill_counts'], 'posda_files', 'Get the current status of all patients')
        ;

            insert into queries
            values ('UpdateSendEvent', 'update dicom_send_event
  set send_ended = now()
where dicom_send_event_id = ?
', ARRAY['id'], 
                    NULL, ARRAY['NotInteractive', 'SeriesSendEvent'], 'posda_files', 'Update dicom_send_event_id after creation and completion of send
For use in scripts.
Not meant for interactive use
')
        ;

            insert into queries
            values ('PlanToSsLinkageByCollectionSite', 'select
  sop_instance_uid as referencing_plan, ss_referenced_from_plan as referenced_ss
from
  file_plan natural join plan join file_sop_common using(file_id) natural join ctp_file
where
  project_name = ? and site_name = ? and visibility is null', ARRAY['collection', 'site'], 
                    ARRAY['referencing_plan', 'referenced_ss'], ARRAY['Structure Sets', 'sops', 'LinkageChecks', 'plan_linkages', 'struct_linkages'], 'posda_files', 'Get list of plan which reference unknown SOPs

')
        ;

            insert into queries
            values ('CountsBySiteCollectionLikeDateRangePlus', 'select
  distinct
    patient_id, image_type, dicom_file_type, modality,
    study_date, series_date,
    study_description,
    series_description, study_instance_uid, series_instance_uid,
    manufacturer, manuf_model_name, software_versions,
    count(distinct sop_instance_uid) as num_sops,
    count(distinct file_id) as num_files,
    min(import_time) as earliest,
    max(import_time) as latest
from
  ctp_file join file_patient using(file_id)
  join dicom_file using(file_id)
  join file_series using(file_id)
  join file_sop_common using(file_id)
  join file_study using(file_id)
  join file_equipment using(file_id)
  join file_import using(file_id)
  join import_event using(import_event_id)
  left join file_image using(file_id)
  left join image using (image_id)
where
  file_id in (
    select file_id 
    from file_import natural join import_event
    where import_time > ? and import_time < ?
  ) and project_name like ? and site_name like ? and visibility is null
group by
  patient_id, image_type, dicom_file_type, modality, study_date, 
  series_date, study_description,
  series_description, study_instance_uid, series_instance_uid,
  manufacturer, manuf_model_name, software_versions
order by
  patient_id, study_instance_uid, series_instance_uid, image_type,
  modality, study_date, series_date, study_description,
  series_description,
  manufacturer, manuf_model_name, software_versions
', ARRAY['from', 'to', 'collection_like', 'site'], 
                    ARRAY['patient_id', 'image_type', 'dicom_file_type', 'modality', 'study_date', 'series_date', 'study_description', 'series_description', 'study_instance_uid', 'series_instance_uid', 'manufacturer', 'manuf_model_name', 'software_versions', 'num_sops', 'num_files', 'earliest', 'latest'], ARRAY['counts', 'count_queries'], 'posda_files', 'Counts query by Collection, Site
')
        ;

            insert into queries
            values ('UpdateSeriesScan', 'update series_scan
  set series_scan_status = ?
where series_scan_id = ?', ARRAY['series_scan_status', 'series_scan_id'], 
                    '{}', ARRAY['UsedInPhiSeriesScan', 'NotInteractive'], 'posda_phi', 'Update Series Scan to set status
')
        ;

            insert into queries
            values ('ActivityStuffMoreForAll', 'select
  distinct subprocess_invocation_id, background_subprocess_id, user_inbox_content_id,
  background_subprocess_report_id, file_id,
  background_subprocess_report.name as report_type,
  activity_id, when_script_started,
  when_background_entered, when_script_ended, 
  invoking_user, user_to_notify, button_name,
  operation_name, command_line
from
  subprocess_invocation natural left join background_subprocess natural left join background_subprocess_report
  natural left join user_inbox_content natural left join activity_inbox_content
order by subprocess_invocation_id desc
', '{}', 
                    ARRAY['subprocess_invocation_id', 'background_subprocess_id', 'user_inbox_content_id', 'background_subprocess_report_id', 'file_id', 'report_type', 'activity_id', 'when_script_started', 'when_background_entered', 'when_script_ended', 'invoking_user', 'user_to_notify', 'button_name', 'operation_name', 'command_line'], ARRAY['activity_timepoint_support'], 'posda_queries', 'Create An Activity Timepoint

')
        ;

            insert into queries
            values ('GetCurrentEditEventRowId', 'select currval(''dicom_edit_event_dicom_edit_event_id_seq'') as id', '{}', 
                    ARRAY['id'], ARRAY['NotInteractive', 'used_in_import_edited_files'], 'posda_files', 'Get current dicom_edit_event_id
For use in scripts
Not really intended for interactive use
')
        ;

            insert into queries
            values ('GetSeenValueId', 'select currval(''seen_value_seen_value_id_seq'') as id', '{}', 
                    ARRAY['id'], ARRAY['UsedInPhiSeriesScan', 'NotInteractive'], 'posda_phi', 'Get current value of seen_value_id sequence')
        ;

            insert into queries
            values ('InsertUserBoundVariable', 'insert into user_variable_binding(
  binding_user, bound_variable_name, bound_value
) values (
  ?, ?, ?
)
 ', ARRAY['user', 'variable_name', 'value'], 
                    ARRAY['user', 'variable', 'binding'], ARRAY['AllCollections', 'queries', 'activity_support', 'variabler_binding'], 'posda_queries', 'Get list of variables with bindings for a user')
        ;

            insert into queries
            values ('DistinctDispositonsNeededSimple', 'select 
  distinct 
  element_seen_id as id, 
  element_sig_pattern,
  vr,
  tag_name
from
  element_seen
  natural join element_value_occurance
  natural join value_seen
where
  is_private and 
  private_disposition is null
', '{}', 
                    ARRAY['id', 'element_sig_pattern', 'vr', 'tag_name'], ARRAY['tag_usage', 'simple_phi_maint', 'phi_maint'], 'posda_phi_simple', 'Private tags with no disposition with values in phi_simple')
        ;

            insert into queries
            values ('AddCompletionTimeToBackgroundProcess', 'update background_subprocess set
  when_script_ended = now()
where
  background_subprocess_id = ?
', ARRAY['background_subprocess_id'], 
                    '{}', ARRAY['NotInteractive', 'used_in_background_processing'], 'posda_queries', 'Add when_script_ended to a background_subprocess  row

used in a background subprocess when complete')
        ;

            insert into queries
            values ('ListOfQueriesPerformedByUser', 'select
  query_invoked_by_dbif_id as id,
  query_name,
  query_end_time - query_start_time as duration,
  invoking_user as invoked_by,
  query_start_time as at, 
  number_of_rows
from
  query_invoked_by_dbif
where
  invoking_user = ?', ARRAY['user'], 
                    ARRAY['id', 'query_name', 'duration', 'invoked_by', 'at', 'number_of_rows'], ARRAY['AllCollections', 'q_stats'], 'posda_queries', 'Get a list of collections and sites
')
        ;

            insert into queries
            values ('DuplicatesInDifferentSeriesByCollectionSite', 'select
  distinct collection, site, subj_id, study_instance_uid, series_instance_uid, sop_instance_uid,
  file_id, file_path
from (
  select
    distinct project_name as collection,
    site_name as site, patient_id as subj_id,
    study_instance_uid, series_instance_uid,
    sop_instance_uid,
    file_id, root_path ||''/'' || rel_path as file_path
  from
    ctp_file natural join file_sop_common
    natural join file_patient natural join file_study natural join file_series
    join file_location using(file_id) join file_storage_root using(file_storage_root_id)
  where
    sop_instance_uid in (
      select distinct sop_instance_uid from (
        select distinct sop_instance_uid, count(distinct file_id) from (
          select distinct file_id, sop_instance_uid 
          from
            ctp_file natural join file_sop_common
            natural join file_patient
          where
            visibility is null and project_name = ? and site_name = ?
        ) as foo group by sop_instance_uid order by count desc
      ) as foo 
      where count > 1
    )
    and visibility is null
  ) as foo
order by sop_instance_uid

', ARRAY['collection', 'site'], 
                    ARRAY['collection', 'site', 'subj_id', 'study_instance_uid', 'series_instance_uid', 'sop_instance_uid', 'file_id', 'file_path'], ARRAY['duplicates', 'dup_sops', 'hide_dup_sops', 'sops_different_series'], 'posda_files', 'Return a count of duplicate SOP Instance UIDs
')
        ;

            insert into queries
            values ('FilesRemainingToBeHiddenByScanInstance', 'select
  distinct file_id
from
  file_sop_common natural
  join ctp_file
where
  visibility is null and
  sop_instance_uid in (
    select
      sop_instance_uid
    from
      file_sop_common
      where file_id in (
          select
            distinct file_id
          from
             image_equivalence_class natural join
             image_equivalence_class_input_image
           where
             visual_review_instance_id = ? and
             review_status = ''Bad''
        )
     )', ARRAY['visual_review_instance_id'], 
                    ARRAY['file_id'], ARRAY['by_collection', 'find_series', 'compare_collection_site', 'search_series', 'edit_files', 'simple_phi', 'dciodvfy', 'ctp_details', 'select_for_phi', 'visual_review_status'], 'posda_files', 'Get Series in A Collection, site with dicom_file_type, modality, and sop_count
')
        ;

            insert into queries
            values ('TotalPosdaSeriesCounts', 'select
  distinct project_name as collection, site_name as site,  count(distinct series_instance_uid) as num_series,
  count(distinct file_id) as num_files
from 
  ctp_file natural join file_series 
where
  visibility is null group by collection, site           
order by collection, site', '{}', 
                    ARRAY['collection', 'site', 'num_series', 'num_files'], ARRAY['meta', 'test', 'hello', 'query_tabs', 'bills_test'], 'posda_files', 'Files for a specific patient which were first received after a specific time')
        ;

            insert into queries
            values ('CountsByCollectionSiteSubject', 'select
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
', ARRAY['collection', 'site', 'patient_id'], 
                    ARRAY['patient_id', 'image_type', 'dicom_file_type', 'modality', 'study_date', 'study_description', 'series_description', 'study_instance_uid', 'series_instance_uid', 'manufacturer', 'manuf_model_name', 'software_versions', 'num_sops', 'num_files'], ARRAY['counts'], 'posda_files', 'Counts query by Collection, Site, Subject
')
        ;

            insert into queries
            values ('GetPosdaSopsForCompareLikeCollection', 'select
  distinct patient_id,
  study_instance_uid, 
  series_instance_uid, 
  sop_instance_uid,
  sop_class_uid,
  modality,
  dicom_file_type,
  root_path || ''/'' || rel_path as file_path,
  file_id
from
  ctp_file
  natural join dicom_file
  natural join file_patient
  natural join file_study
  natural join file_series
  natural join file_sop_common
  natural join file_location
  natural join file_storage_root
where
  project_name like ? 
  and visibility is null', ARRAY['collection'], 
                    ARRAY['patient_id', 'study_instance_uid', 'series_instance_uid', 'sop_instance_uid', 'sop_class_uid', 'modality', 'dicom_file_type', 'file_path', 'file_id'], ARRAY['public_posda_counts'], 'posda_files', 'Generate a long list of all unhidden SOPs for a collection in posda<br>
<em>This can generate a long list</em>')
        ;

            insert into queries
            values ('DistinctHiddenFilesInSeries', 'select
  distinct file_id
from
  file_series natural join file_sop_common natural join ctp_file
where
  series_instance_uid = ? and visibility is not null
', ARRAY['series_instance_uid'], 
                    ARRAY['file_id'], ARRAY['by_series_instance_uid', 'file_ids', 'posda_files'], 'posda_files', 'Get Distinct Unhidden Files in Series
')
        ;

            insert into queries
            values ('DistinctSopsInSeries', 'select distinct sop_instance_uid, count(*)
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
', ARRAY['series_instance_uid'], 
                    ARRAY['sop_instance_uid', 'count'], ARRAY['by_series_instance_uid', 'duplicates', 'posda_files', 'sops'], 'posda_files', 'Get Distinct SOPs in Series with number files
Only visible filess
')
        ;

            insert into queries
            values ('AreVisibleFilesMarkedAsBadOrUnreviewed', 'select 
  distinct series_instance_uid,
  dicom_file_type,
  modality,
  review_status,
  processing_status,
  count(distinct file_id) as num_files
from 
  dicom_file natural join 
  file_series natural join 
  ctp_file join 
  image_equivalence_class using(series_instance_uid)
where
  project_name = ? and
  site_name = ?
  and visibility is null
group by
  series_instance_uid,
  dicom_file_type,
  modality,
  review_status,
  processing_status
order by
  series_instance_uid', ARRAY['collection', 'site'], 
                    ARRAY['series_instance_uid', 'dicom_file_type', 'modality', 'review_status', 'processing_status', 'num_files'], ARRAY['find_series', 'equivalence_classes', 'consistency', 'visual_review_results', 'hide_events'], 'posda_files', 'Get visual review status report by series for Collection, Site')
        ;

            insert into queries
            values ('SeriesVisualReviewResultsByCollectionSiteStatus', 'select 
  distinct series_instance_uid,
  dicom_file_type,
  modality,
  review_status,
  count(distinct file_id) as num_files
from 
  dicom_file natural join 
  file_series natural join 
  ctp_file join 
  image_equivalence_class using(series_instance_uid)
where
  project_name = ? and
  site_name = ? and review_status = ?
group by
  series_instance_uid,
  dicom_file_type,
  modality,
  review_status
order by
  series_instance_uid', ARRAY['project_name', 'site_name', 'status'], 
                    ARRAY['series_instance_uid', 'dicom_file_type', 'modality', 'review_status', 'num_files'], ARRAY['find_series', 'equivalence_classes', 'consistency', 'visual_review_results', 'hide_files'], 'posda_files', 'Get visual review status report by series for Collection, Site')
        ;

            insert into queries
            values ('GetCountSsVolume', 'select count(distinct sop_instance_uid) as num_links from 
(select 
  for_uid, study_instance_uid, series_instance_uid,
  sop_class as sop_class_uid, sop_instance as sop_instance_uid
  from ss_for natural join ss_volume where structure_set_id in (
    select 
      structure_set_id 
    from
      file_structure_set fs, file_sop_common sc
    where
      sc.file_id = fs.file_id and sop_instance_uid = ?
)
) as foo;', ARRAY['sop_instance_uid'], 
                    ARRAY['num_links'], ARRAY['Structure Sets', 'sops', 'LinkageChecks'], 'posda_files', 'Get Structure Set Volume

')
        ;

            insert into queries
            values ('WherePatientSits', 'select
  distinct project_name as collection,
  site_name as site,
  visibility,
  patient_id,
  patient_name,
  series_instance_uid,
  modality,
  count (distinct file_id) as num_files
from
  file_patient natural left join
  file_series natural left join
  ctp_file
where
  patient_id = ?
group by
  project_name, site_name, visibility, 
  patient_id, patient_name,
  series_instance_uid, modality
order by 
  project_name, site_name, patient_id,
  modality
', ARRAY['patient_id'], 
                    ARRAY['collection', 'site', 'visibility', 'patient_id', 'patient_name', 'series_instance_uid', 'modality', 'num_files'], ARRAY['adding_ctp'], 'posda_files', 'Get Series in A Collection
')
        ;

            insert into queries
            values ('GetEditStatusExt', 'select
  subprocess_invocation_id as id,
  start_creation_time, end_creation_time - start_creation_time as duration,
  number_edits_scheduled as to_edit,
  number_compares_with_diffs as changed,
  number_compares_without_diffs as not_changed,
  current_disposition as disposition,
  dest_dir, command_line, b.crash
from
  dicom_edit_compare_disposition  join subprocess_invocation using (subprocess_invocation_id)
  join background_subprocess b using(subprocess_invocation_id)
order by start_creation_time desc', '{}', 
                    ARRAY['id', 'start_creation_time', 'duration', 'to_edit', 'changed', 'not_changed', 'disposition', 'dest_dir', 'command_line', 'crash'], ARRAY['adding_ctp', 'find_patients', 'series_selection', 'check_edits', 'testing_edit_objects', 'edit_status', 'crash'], 'posda_files', 'Get List of visible patients with CTP data')
        ;

            insert into queries
            values ('CreateSimpleElementValueOccurance', 'insert into element_value_occurance(
element_seen_id, value_seen_id, series_scan_instance_id, phi_scan_instance_id
)values(?, ?, ?, ?)', ARRAY['element_seen_id', 'value_seen_id', 'series_scan_instance_id', 'scan_instance_id'], 
                    '{}', ARRAY['used_in_simple_phi', 'NotInteractive'], 'posda_phi_simple', 'Create a new scanned value instance')
        ;

            insert into queries
            values ('GetFromToDigestsEditCompare', 'select from_file_digest, to_file_digest from dicom_edit_compare where subprocess_invocation_id = ?', ARRAY['subprocess_invocation_id'], 
                    ARRAY['from_file_digest', 'to_file_digest'], ARRAY['bills_test', 'posda_db_populate'], 'posda_files', 'Add a filter to a tab')
        ;

            insert into queries
            values ('VrsSeen', 'select distinct vr, count(*) from (
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
', ARRAY['scan_id'], 
                    ARRAY['vr', 'count'], ARRAY['tag_usage'], 'posda_phi', 'List of VR''s seen in scan (with count)
')
        ;

            insert into queries
            values ('NumFilesToMigrate', 'select
  count(*) as num_files
from
  file_location natural join file_storage_root
where
  storage_class = ?', ARRAY['storage_class'], 
                    ARRAY['num_files'], ARRAY['used_in_file_import_into_posda', 'used_in_file_migration'], 'posda_files', 'Get count of files relative to storage root')
        ;

            insert into queries
            values ('GetDupContourCountsExtendedByCollection', 'select
  project_name as collection,
  site_name as site,
  patient_id,
  file_id,
  num_dup_contours
from (
  select 
    distinct file_id, count(*) as num_dup_contours
  from
    file_roi_image_linkage 
  where 
    contour_digest in (
    select contour_digest
    from (
      select 
        distinct contour_digest, count(*)
      from
        file_roi_image_linkage group by contour_digest
    ) as foo
    where count > 1
  ) group by file_id 
) foo join ctp_file using (file_id) join file_patient using(file_id)
where project_name = ? and visibility is null
order by num_dup_contours desc', ARRAY['collection'], 
                    ARRAY['collection', 'site', 'patient_id', 'file_id', 'num_dup_contours'], ARRAY['Structure Sets', 'sops', 'LinkageChecks', 'dup_contours'], 'posda_files', 'Get list of plan which reference unknown SOPs

')
        ;

            insert into queries
            values ('ListOfQueriesPerformedByQueryName', 'select
  query_invoked_by_dbif_id as id,
  query_name,
  query_end_time - query_start_time as duration,
  invoking_user as invoked_by,
  query_start_time as at, 
  number_of_rows
from
  query_invoked_by_dbif
where
 query_name = ?', ARRAY['query_name'], 
                    ARRAY['id', 'query_name', 'duration', 'invoked_by', 'at', 'number_of_rows'], ARRAY['AllCollections', 'q_stats'], 'posda_queries', 'Get a list of collections and sites
')
        ;

            insert into queries
            values ('GetPosdaPhiSimplePrivateElements', 'select
  element_seen_id,
  element_sig_pattern,
  vr,
  is_private,
  private_disposition,
  tag_name
from element_seen
where element_sig_pattern like ''%"%''

', '{}', 
                    ARRAY['element_seen_id', 'element_sig_pattern', 'vr', 'is_private', 'private_disposition', 'tag_name'], ARRAY['NotInteractive', 'used_in_reconcile_tag_names'], 'posda_phi_simple', 'Get the relevant features of an element_signature in posda_phi_simple schema')
        ;

            insert into queries
            values ('ListOfElementSignaturesAndVrs', 'select
  distinct element_signature, vr, name_chain, count(*)
from
  element_signature
group by element_signature, vr, name_chain
', '{}', 
                    ARRAY['element_signature', 'vr', 'name_chain', 'count'], ARRAY['NotInteractive', 'Update', 'ElementDisposition'], 'posda_phi', 'Get Disposition of element by sig and VR')
        ;

            insert into queries
            values ('DuplicateFilesBySop', 'select
  distinct
    project_name as collection, site_name as site,
    patient_id, sop_instance_uid, modality, file_id,
    root_path || ''/'' || file_location.rel_path as file_path,
    count(*) as num_uploads,
    min(import_time) as first_upload, 
    max(import_time) as last_upload
from
  file_patient left join ctp_file using(file_id)
  join file_sop_common using(file_id)
  join file_series using(file_id)
  join file_location using(file_id)
  join file_storage_root using(file_storage_root_id)
  join file_import using (file_id)
  join import_event using (import_event_id)
where
  sop_instance_uid = ?
  and visibility is null
group by
  project_name, site_name, patient_id, sop_instance_uid, modality, 
  file_id, file_path
order by
  collection, site, patient_id, sop_instance_uid, modality
', ARRAY['sop_instance_uid'], 
                    ARRAY['collection', 'site', 'patient_id', 'sop_instance_uid', 'modality', 'file_id', 'file_path', 'num_uploads', 'first_upload', 'last_upload'], ARRAY['duplicates'], 'posda_files', 'Counts query by Collection, Site
')
        ;

            insert into queries
            values ('DistinctSeriesByPatient', 'select distinct series_instance_uid, patient_id, count(distinct file_id) as num_files,
  count(distinct sop_instance_uid) as num_sops
from
  file_series natural join file_patient natural join file_sop_common
  natural left join ctp_file
where
  patient_id = ? and visibility is null
group by series_instance_uid, patient_id

', ARRAY['patient_id'], 
                    ARRAY['series_instance_uid', 'patient_id', 'num_files', 'num_sops'], ARRAY['find_series', 'search_series', 'send_series', 'phi_simple', 'simple_phi', 'dciodvfy', 'series_selection', 'ctp_details'], 'posda_files', 'Get Series in for a patient
')
        ;

            insert into queries
            values ('GetEquipmentInfoById', 'select
  file_id,
  manufacturer,
  institution_name,
  institution_addr,
  station_name,
  inst_dept_name,
  manuf_model_name,
  dev_serial_num,
  software_versions,
  spatial_resolution,
  last_calib_date,
  last_calib_time,
  pixel_pad
from file_equipment
where file_id = ?', ARRAY['file_id'], 
                    ARRAY['file_id', 'manufacturer', 'institution_name', 'institution_addr', 'station_name', 'inst_dept_name', 'manuf_model_name', 'dev_serial_num', 'software_versions', 'spatial_resolution', 'last_calib_date', 'last_calib_time', 'pixel_pad'], ARRAY['reimport_queries'], 'posda_files', 'Get file path from id')
        ;

            insert into queries
            values ('CreateDciodvfyError', 'insert into dciodvfy_error(
  error_type, error_tag, error_subtype, error_module,
  error_reason, error_index, error_value, error_text
) values (
  ?, ?, ?, ?,
  ?, ?, ?, ?
)', ARRAY['error_type', 'error_tag', 'error_subtype', 'error_module', 'error_reason', 'error_index', 'error_value', 'error_text'], 
                    '{}', ARRAY['NotInteractive', 'used_in_dciodvfy'], 'posda_phi_simple', 'Create a dciodvfy_errors row by error_text ')
        ;

            insert into queries
            values ('GetXlsToConvert', 'select 
  file_id, file_type, file_sub_type, collection, site, subject, visibility, date_last_categorized
from
  non_dicom_file
where
 collection = ? and file_type = ''xls'' and visibility is null', ARRAY['collection'], 
                    ARRAY['file_id', 'file_type', 'file_sub_type', 'collection', 'site', 'subject', 'visibility', 'date_last_categorized'], ARRAY['radcomp'], 'posda_files', 'Add a filter to a tab')
        ;

            insert into queries
            values ('dicom_files_with_no_ctp_file_like_pat', 'select 
  distinct patient_id,
  dicom_file_type, 
  modality, 
  count(distinct file_id) as num_files, 
  min(import_time) as earliest, 
  max(import_time) as latest 
from
  dicom_file d natural join
  file_patient natural join 
  file_series natural join
  file_import natural join
  import_event
where not exists (select file_id from ctp_file c where c.file_id = d.file_id) and patient_id like ?
group by patient_id, dicom_file_type, modality', ARRAY['patient_id_pattern'], 
                    ARRAY['patient_id', 'dicom_file_type', 'modality', 'num_files', 'earliest', 'latest'], ARRAY['meta', 'test', 'hello', 'query_tabs', 'bills_test'], 'posda_files', 'Add a filter to a tab')
        ;

            insert into queries
            values ('VisibleImagesWithDetailsByVisualIdAndTypeAndStatus', 'select 
  distinct patient_id, study_instance_uid, series_instance_uid, sop_instance_uid, modality, 
  root_path || ''/'' || rel_path as path
from 
  file_patient natural join file_study natural join file_series natural join 
  file_location natural join file_storage_root natural join
  file_sop_common natural join ctp_file
where series_instance_uid in (
  select
    distinct series_instance_uid
  from
    image_equivalence_class natural join file_series natural join
    image_equivalence_class_input_image natural join dicom_file natural join ctp_file
  where
    visual_review_instance_id = ? and 
    processing_status = ? and review_status = ? and 
    dicom_file_type = ?
)
and visibility is null', ARRAY['visual_review_instance_id', 'processing_status', 'review_status', 'dicom_file_type'], 
                    ARRAY['patient_id', 'study_instance_uid', 'series_instance_uid', 'sop_instance_uid', 'modality', 'path'], ARRAY['by_collection', 'find_series', 'compare_collection_site', 'search_series', 'edit_files', 'simple_phi', 'dciodvfy', 'ctp_details', 'select_for_phi', 'visual_review_new_workflow'], 'posda_files', 'Get Series in A Collection, site with dicom_file_type, modality, and sop_count
')
        ;

            insert into queries
            values ('RoiLinkagesByFileId', 'select
  distinct roi_id,
  linked_sop_instance_uid as sop_instance_uid,
  contour_type
from
  file_roi_image_linkage
where file_id =?', ARRAY['file_id'], 
                    ARRAY['roi_id', 'sop_instance_uid', 'contour_type'], ARRAY['LinkageChecks', 'used_in_struct_linkage_check'], 'posda_files', 'Get list of Roi with info by file_id

')
        ;

            insert into queries
            values ('GetDciodvfyErrorAttrSpecWithIndex', 'select
  dciodvfy_error_id as id
from 
  dciodvfy_error
where
  error_type = ''AttributeSpecificErrorWithIndex''
  and error_tag = ?
  and error_subtype= ?
  and error_index = ?', ARRAY['error_tag', 'error_subtype', 'error_index'], 
                    ARRAY['id'], ARRAY['NotInteractive', 'used_in_dciodvfy'], 'posda_phi_simple', 'Get dciodvfy_errors row where subtype = AttributeSpecificErrorWithIndex')
        ;

            insert into queries
            values ('GetPlansAndSSReferences', 'select sop_instance_uid as plan_referencing,
ss_referenced_from_plan as ss_referenced
from plan natural join file_plan join file_sop_common using(file_id)', '{}', 
                    ARRAY['plan_referencing', 'ss_referenced'], ARRAY['Structure Sets', 'sops', 'LinkageChecks'], 'posda_files', 'Get list of plan and ss sops where plan references ss

')
        ;

            insert into queries
            values ('DiskSpaceByCollectionSummary', 'select
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
', '{}', 
                    ARRAY['collection', 'total_bytes'], ARRAY['by_collection', 'posda_files', 'storage_used', 'summary'], 'posda_files', 'Get disk space used for all collections
')
        ;

            insert into queries
            values ('FindInconsistentStudyIgnoringStudyTimeIncludingPatientIdAll', 'select distinct study_instance_uid from (
  select distinct study_instance_uid, count(*) from (
    select distinct
      patient_id, study_instance_uid, study_date,
      referring_phy_name, study_id, accession_number,
      study_description, phys_of_record, phys_reading,
      admitting_diag
    from
      file_study natural join file_patient natural join ctp_file
    where
      visibility is null
    group by
      patient_id, study_instance_uid, study_date,
      referring_phy_name, study_id, accession_number,
      study_description, phys_of_record, phys_reading,
      admitting_diag
  ) as foo
  group by study_instance_uid
) as foo
where count > 1
', '{}', 
                    ARRAY['study_instance_uid'], ARRAY['by_study', 'consistency', 'study_consistency'], 'posda_files', 'Find Inconsistent Studies
')
        ;

            insert into queries
            values ('PhiScanStatus', 'select
  phi_scan_instance_id as id,
  start_time,
  end_time,
  end_time - start_time as duration,
  description,
  num_series as to_scan,
  num_series_scanned as scanned
from 
  phi_scan_instance
order by id
', '{}', 
                    ARRAY['id', 'start_time', 'end_time', 'duration', 'description', 'to_scan', 'scanned'], ARRAY['tag_usage', 'phi_review', 'phi_status', 'scan_status'], 'posda_phi_simple', 'Status of PHI scans
')
        ;

            insert into queries
            values ('ManifestsByDate', 'select
  distinct file_id, import_time, size, root_path || ''/'' || l.rel_path as path, i.file_name as alt_path
from
  file_location l join file_storage_root using(file_storage_root_id) 
  join file_import i using (file_id) natural join file join import_event using(import_event_id)
where
  import_time >?and import_time < ? and
  file_type like ''%ASCII%'' and
  l.rel_path like ''%/Manifests/%''
order by import_time', ARRAY['from', 'to'], 
                    ARRAY['file_id', 'import_time', 'size', 'path', 'alt_path'], ARRAY['activity_timepoint_support', 'manifests'], 'posda_files', 'Create An Activity Timepoint

')
        ;

            insert into queries
            values ('ToExamineRecentFiles', 'select 
  file_id, project_name as collection, site_name as site,
  patient_id, series_instance_uid, dicom_file_type, modality
from
  ctp_file natural join file_patient natural join dicom_file natural join file_series where file_id in 
  (
     select file_id from 
     (  
        select 
           distinct file_id, min(import_time) as import_time 
        from 
          file_import natural join import_event 
        where file_id in 
        (
          select 
            distinct file_id 
          from 
             ctp_file natural join file_import natural join import_event
             natural join file_patient 
           where patient_id =? and import_time > ?
         ) group by file_id
      ) as foo
      where import_time > ?
  )', ARRAY['patient_id', 'import_time_1', 'import_time_2'], 
                    ARRAY['file_id', 'collection', 'site', 'patient_id', 'series_instance_uid', 'dicom_file_type', 'modality'], ARRAY['meta', 'test', 'hello', 'query_tabs', 'bills_test'], 'posda_files', 'Files for a specific patient which were first received after a specific time')
        ;

            insert into queries
            values ('DistinctSeriesHierarchyByCollectionPublic', 'select
  distinct i. patient_id, i.study_instance_uid, s.series_instance_uid, modality, count(*) as num_images
from
  general_image i, general_series s,
  trial_data_provenance tdp
where
  s.general_series_pk_id = i.general_series_pk_id and
  i.trial_dp_pk_id = tdp.trial_dp_pk_id and
  tdp.project = ?
group by patient_id, study_instance_uid, series_instance_uid, modality', ARRAY['project_name'], 
                    ARRAY['patient_id', 'study_instance_uid', 'series_instance_uid', 'modality', 'num_images'], ARRAY['by_collection', 'find_series', 'public', 'series_search'], 'public', 'Get Series in A Collection
')
        ;

            insert into queries
            values ('RoundStatsWithCollectionSiteSubjectForDateRange', 'select
  distinct collection, site, subj, date_trunc(?, time_received) as time,
  count(*) as number_of_files,
  max(time_entered - time_received) as max_delay,
  min(time_entered - time_received) as min_delay
from request natural join submitter
where time_received > ? and time_received < ?
group by collection, site, subj, time order by time desc, collection, site, subj', ARRAY['interval', 'from', 'to'], 
                    ARRAY['collection', 'site', 'subj', 'time', 'number_of_files', 'max_delay', 'min_delay'], ARRAY['NotInteractive', 'Backlog', 'Backlog Monitor', 'for_bill'], 'posda_backlog', 'Summary of rounds')
        ;
