-- Test data for Posda Dataset / Recordset Release Module
-- Aligned to add_dataset_module_tables.sql as currently modeled.

BEGIN;

-- -----------------------------------------------------------------------------
-- Lookup tables
-- -----------------------------------------------------------------------------

INSERT INTO public.dataset_type (dataset_type_id, dataset_type_name) VALUES
    (1, 'Collection'),
    (2, 'Analysis Result');
SELECT setval(pg_get_serial_sequence('public.dataset_type', 'dataset_type_id'), COALESCE(MAX(dataset_type_id), 0), true) FROM public.dataset_type;

INSERT INTO public.dataset_relation_type (relation_type_id, forward_label, reverse_label) VALUES
    (1, 'isDerivedFrom', 'isSourceOf');
SELECT setval(pg_get_serial_sequence('public.dataset_relation_type', 'relation_type_id'), COALESCE(MAX(relation_type_id), 0), true) FROM public.dataset_relation_type;

INSERT INTO public.recordset_type (recordset_type_id, recordset_type_name) VALUES
    (1, 'Radiology Images'),
    (2, 'Histopathology Images'),
    (3, 'Image Annotations'),
    (4, 'Clinical Data'),
    (5, 'Other');
SELECT setval(pg_get_serial_sequence('public.recordset_type', 'recordset_type_id'), COALESCE(MAX(recordset_type_id), 0), true) FROM public.recordset_type;

INSERT INTO public.transfer_mode (transfer_mode_id, transfer_mode_name) VALUES
    (1, 'single dataset'),
    (2, 'grouped bundle'),
    (3, 'clinical update');
SELECT setval(pg_get_serial_sequence('public.transfer_mode', 'transfer_mode_id'), COALESCE(MAX(transfer_mode_id), 0), true) FROM public.transfer_mode;

INSERT INTO public.recordset_license (license_id, license_name, license_label, license_url, is_public_access) VALUES
    (1, 'Creative Commons Attribution 3.0 Unported', 'CC BY 3.0', 'https://creativecommons.org/licenses/by/3.0/', true),
    (2, 'Creative Commons Attribution 4.0 International', 'CC BY 4.0', 'https://creativecommons.org/licenses/by/4.0/', true),
    (3, 'Creative Commons Attribution-NonCommercial 4.0 International', 'CC BY-NC 4.0', 'https://creativecommons.org/licenses/by-nc/4.0/', true),
    (4, 'TCIA Limited Access', 'TCIA Limited', 'https://www.cancerimagingarchive.net/nih-controlled-data-access-policy/', false);
SELECT setval(pg_get_serial_sequence('public.recordset_license', 'license_id'), COALESCE(MAX(license_id), 0), true) FROM public.recordset_license;

INSERT INTO public.transfer_destination (destination_id, destination_name, destination_abbr) VALUES
    (1, 'Imaging Data Commons', 'idc'),
    (2, 'General Commons', 'gc'),
    (3, 'WordPress', 'wp'),
    (4, 'Aspera Faspex', 'asp'),
    (5, 'NBIA', 'nbia');
SELECT setval(pg_get_serial_sequence('public.transfer_destination', 'destination_id'), COALESCE(MAX(destination_id), 0), true) FROM public.transfer_destination;

-- -----------------------------------------------------------------------------
-- Dataset and dataset relationship test data
-- -----------------------------------------------------------------------------

INSERT INTO public.dataset (
    dataset_id,
    dataset_name,
    dataset_type_id,
    dataset_doi,
    active,
    when_created,
    who_created,
    when_updated,
    who_updated
) VALUES
    (
        1,
        'RIDER-LUNG-CT',
        1,
        '10.7937/k9/tcia.2015.u1x8a5nr',
        true,
        NOW(),
        'admin',
        NOW(),
        'admin'
    ),
    (
        2,
        'RIDER-LUNGCT-SEG',
        2,
        '10.7937/tcia.2020.jit9grk8',
        true,
        NOW(),
        'admin',
        NOW(),
        'admin'
    );
SELECT setval(pg_get_serial_sequence('public.dataset', 'dataset_id'), COALESCE(MAX(dataset_id), 0), true) FROM public.dataset;

-- Dataset 2 isDerivedFrom Dataset 1.
-- The reverse relation is derived from dataset_relation_type.reverse_label as isSourceOf.
INSERT INTO public.dataset_relation (dataset_id, related_dataset_id, relation_type_id) VALUES
    (2, 1, 1);

-- -----------------------------------------------------------------------------
-- Recordsets and destination defaults
-- -----------------------------------------------------------------------------

INSERT INTO public.recordset (
    recordset_id,
    recordset_name,
    recordset_type_id,
    dataset_id,
    license_id,
    recordset_doi,
    active,
    when_created,
    who_created,
    when_updated,
    who_updated
) VALUES
    (1, 'Radiology 01 Public', 1, 1, 2, null, true, NOW(), 'admin', NOW(), 'admin'),
    (2, 'Radiology 02 Public', 1, 1, 2, null, true, NOW(), 'admin', NOW(), 'admin'),
    (3, 'Radiology 03 Limited', 1, 1, 4, null, true, NOW(), 'admin', NOW(), 'admin'),
    (4, 'Clinical 01 Public', 4, 1, 2, null, true, NOW(), 'admin', NOW(), 'admin'),
    (5, 'Image Annotations 01 Public', 3, 2, 2, null, true, NOW(), 'admin', NOW(), 'admin'),
    (6, 'Image Annotations 02 Limited', 3, 2, 4, null, true, NOW(), 'admin', NOW(), 'admin');
SELECT setval(pg_get_serial_sequence('public.recordset', 'recordset_id'), COALESCE(MAX(recordset_id), 0), true) FROM public.recordset;

INSERT INTO public.recordset_destination (recordset_id, destination_id, default_display, transfer_mode_id) VALUES
    (1, 1, true,  2), -- Radiology public: IDC default, grouped bundle
    (1, 5, false, 1), -- Radiology public: NBIA alternative, single dataset
    (2, 1, true,  2), -- Radiology public: IDC default, grouped bundle
    (2, 5, false, 1), -- Radiology public: NBIA alternative, single dataset
    (3, 2, true,  1), -- Radiology limited: General Commons default, single dataset
    (4, 3, true,  1), -- Clinical public: WordPress default, single dataset
    (4, 1, false, 2), -- Clinical public: IDC alternative, grouped bundle
    (5, 1, true,  2), -- Annotation public: IDC default, grouped bundle
    (6, 2, true,  1); -- Annotation limited: General Commons default, single dataset

-- -----------------------------------------------------------------------------
-- Immutable recordset releases and file membership
-- Assumes public.file contains file_id values 1 through 26.
-- -----------------------------------------------------------------------------

INSERT INTO public.recordset_release (
    recordset_release_id,
    recordset_id,
    release_number,
    release_date,
    release_notes,
    when_created,
    who_created,
    when_updated,
    who_updated
) VALUES
    (1, 1, 1, NOW(), 'Initial Release', NOW(), 'admin', NOW(), 'admin'),
    (2, 2, 1, NOW(), 'Initial Release', NOW(), 'admin', NOW(), 'admin'),
    (3, 3, 1, NOW(), 'Initial Release', NOW(), 'admin', NOW(), 'admin'),
    (4, 4, 1, NOW(), 'Initial Release', NOW(), 'admin', NOW(), 'admin'),
    (5, 5, 1, NOW(), 'Initial Release', NOW(), 'admin', NOW(), 'admin'),
    (6, 6, 1, NOW(), 'Initial Release', NOW(), 'admin', NOW(), 'admin');
SELECT setval(pg_get_serial_sequence('public.recordset_release', 'recordset_release_id'), COALESCE(MAX(recordset_release_id), 0), true) FROM public.recordset_release;

INSERT INTO public.recordset_release_file (recordset_release_id, file_id) VALUES
    (1, 1),  (1, 2),  (1, 3),  (1, 4),  (1, 5),
    (2, 6),  (2, 7),  (2, 8),  (2, 9),  (2, 10),
    (3, 11), (3, 12), (3, 13), (3, 14), (3, 15),
    (4, 16),
    (5, 17), (5, 18), (5, 19), (5, 20), (5, 21),
    (6, 22), (6, 23), (6, 24), (6, 25), (6, 26);

-- -----------------------------------------------------------------------------
-- Editable drafts cloned from current immutable releases
-- -----------------------------------------------------------------------------

INSERT INTO public.recordset_draft (
    recordset_draft_id,
    recordset_id,
    draft_name,
    draft_status,
    draft_notes,
    cloned_from_release_id,
    when_created,
    who_created,
    when_updated,
    who_updated
) VALUES
    (1, 1, 'Version 2 Draft', 'open', null, 1, NOW(), 'admin', NOW(), 'admin'),
    (2, 2, 'Version 2 Draft', 'open', null, 2, NOW(), 'admin', NOW(), 'admin'),
    (3, 3, 'Version 2 Draft', 'open', null, 3, NOW(), 'admin', NOW(), 'admin'),
    (4, 4, 'Version 2 Draft', 'open', null, 4, NOW(), 'admin', NOW(), 'admin'),
    (5, 5, 'Version 2 Draft', 'open', null, 5, NOW(), 'admin', NOW(), 'admin'),
    (6, 6, 'Version 2 Draft', 'open', null, 6, NOW(), 'admin', NOW(), 'admin');
SELECT setval(pg_get_serial_sequence('public.recordset_draft', 'recordset_draft_id'), COALESCE(MAX(recordset_draft_id), 0), true) FROM public.recordset_draft;

INSERT INTO public.recordset_draft_file (recordset_draft_id, file_id) VALUES
    (1, 1),  (1, 2),  (1, 3),  (1, 4),  (1, 5),
    (2, 6),  (2, 7),  (2, 8),  (2, 9),  (2, 10),
    (3, 11), (3, 12), (3, 13), (3, 14), (3, 15),
    (4, 16),
    (5, 17), (5, 18), (5, 19), (5, 20), (5, 21),
    (6, 22), (6, 23), (6, 24), (6, 25), (6, 26);

-- -----------------------------------------------------------------------------
-- Dataset releases composed from immutable recordset releases
-- -----------------------------------------------------------------------------

INSERT INTO public.dataset_release (
    dataset_release_id,
    dataset_id,
    release_number,
    release_date,
    release_notes,
    when_created,
    who_created,
    when_updated,
    who_updated
) VALUES
    (1, 1, 1, NOW(), 'Initial Release', NOW(), 'admin', NOW(), 'admin'),
    (2, 2, 1, NOW(), 'Initial Release', NOW(), 'admin', NOW(), 'admin');
SELECT setval(pg_get_serial_sequence('public.dataset_release', 'dataset_release_id'), COALESCE(MAX(dataset_release_id), 0), true) FROM public.dataset_release;

INSERT INTO public.dataset_release_recordset (dataset_release_id, recordset_release_id) VALUES
    (1, 1),
    (1, 2),
    (1, 3),
    (1, 4),
    (2, 5),
    (2, 6);

-- -----------------------------------------------------------------------------
-- Dataset release transfers and destination-specific publication state
-- -----------------------------------------------------------------------------

INSERT INTO public.dataset_release_transfer (
    dataset_release_transfer_id,
    dataset_release_id,
    destination_id,
    transfer_name,
    transfer_mode_id,
    transfer_status,
    transfer_notes,
    when_created,
    who_created,
    when_updated,
    who_updated
) VALUES
    (1, 1, 1, 'RIDER-LUNG-CT IDC grouped release', 2, 'draft', 'Initial grouped IDC test transfer', NOW(), 'admin', NOW(), 'admin'),
    (2, 1, 3, 'RIDER-LUNG-CT WordPress release', 1, 'draft', 'Initial WordPress test transfer', NOW(), 'admin', NOW(), 'admin'),
    (3, 2, 1, 'RIDER-LUNGCT-SEG IDC grouped release', 2, 'draft', 'Initial IDC test transfer for analysis result', NOW(), 'admin', NOW(), 'admin'),
    (4, 1, 5, 'RIDER-LUNG-CT NBIA release', 1, 'draft', 'Initial NBIA test transfer', NOW(), 'admin', NOW(), 'admin'),
    (5, 1, 2, 'RIDER-LUNG-CT General Commons limited release', 1, 'draft', 'Initial General Commons test transfer', NOW(), 'admin', NOW(), 'admin');
SELECT setval(pg_get_serial_sequence('public.dataset_release_transfer', 'dataset_release_transfer_id'), COALESCE(MAX(dataset_release_transfer_id), 0), true) FROM public.dataset_release_transfer;

-- Transfer recordset membership. Manifest file IDs are left null so this script does
-- not require extra test manifest files in public.file.
INSERT INTO public.transfer_recordset (dataset_release_transfer_id, recordset_release_id, retriever_manifest_file_id) VALUES
    (1, 1, null),
    (1, 2, null),
    (1, 4, null),
    (2, 4, null),
    (3, 5, null),
    (4, 1, null),
    (4, 2, null),
    (5, 3, null);

INSERT INTO public.transfer_idc (
    dataset_release_transfer_id,
    gcs_url,
    dataset_manifest_file_id,
    recordset_manifest_file_id,
    clinical_manifest_file_id,
    published,
    "public"
) VALUES
    (1, 'gs://idc-test-bucket/rider-lung-ct/v1', null, null, null, false, false),
    (3, 'gs://idc-test-bucket/rider-lungct-seg/v1', null, null, null, false, false);

INSERT INTO public.transfer_wp (
    dataset_release_transfer_id,
    wp_media_file_id,
    published,
    "public"
) VALUES
    (2, null, false, false);

INSERT INTO public.transfer_nbia (
    dataset_release_transfer_id,
    collection,
    site,
    published,
    "public"
) VALUES
    (4, 'RIDER-LUNG-CT', 'TCIA', false, false);

INSERT INTO public.transfer_gc (
    dataset_release_transfer_id,
    published,
    "public"
) VALUES
    (5, false, false);

-- -----------------------------------------------------------------------------
-- WordPress object mapping examples
-- -----------------------------------------------------------------------------

INSERT INTO public.wp_object_map (
    map_id,
    posda_object_type,
    posda_object_id,
    wp_object_type,
    wp_object_id,
    wp_edit_url,
    wp_view_url,
    parent_wp_object_id,
    when_synced
) VALUES
    (1, 'dataset', 1, 'collection', 1001, 'https://wp.example.org/wp-admin/post.php?post=1001&action=edit', 'https://wp.example.org/collections/rider-lung-ct', null, NOW()),
    (2, 'dataset', 2, 'analysis_result', 1002, 'https://wp.example.org/wp-admin/post.php?post=1002&action=edit', 'https://wp.example.org/analysis-results/rider-lungct-seg', 1001, NOW()),
    (3, 'recordset', 1, 'download', 2001, 'https://wp.example.org/wp-admin/post.php?post=2001&action=edit', 'https://wp.example.org/downloads/radiology-01-public', 1001, NOW()),
    (4, 'recordset', 4, 'download', 2004, 'https://wp.example.org/wp-admin/post.php?post=2004&action=edit', 'https://wp.example.org/downloads/clinical-01-public', 1001, NOW()),
    (5, 'dataset_release', 1, 'version', 3001, 'https://wp.example.org/wp-admin/post.php?post=3001&action=edit', 'https://wp.example.org/collections/rider-lung-ct/v1', 1001, NOW());
SELECT setval(pg_get_serial_sequence('public.wp_object_map', 'map_id'), COALESCE(MAX(map_id), 0), true) FROM public.wp_object_map;

COMMIT;
