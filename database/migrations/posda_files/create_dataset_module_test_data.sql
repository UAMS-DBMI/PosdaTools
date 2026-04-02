INSERT INTO "public".recordset_license ( license_id, license_label, license_url, is_public_access ) VALUES ( 1, 'CC BY 3.0', 'https://creativecommons.org/licenses/by/3.0/', true );
INSERT INTO "public".recordset_license ( license_id, license_label, license_url, is_public_access ) VALUES ( 2, 'CC BY 4.0', 'https://creativecommons.org/licenses/by/4.0/', true );
INSERT INTO "public".recordset_license ( license_id, license_label, license_url, is_public_access ) VALUES ( 3, 'CC BY-NC 4.0', 'https://creativecommons.org/licenses/by-nc/4.0/', true );
INSERT INTO "public".recordset_license ( license_id, license_label, license_url, is_public_access ) VALUES ( 4, 'TCIA Limited', 'https://www.cancerimagingarchive.net/nih-controlled-data-access-policy/', false );

SELECT setval('recordset_license_license_id_seq', COALESCE(MAX(license_id), 0), true) FROM recordset_license;

INSERT INTO "public".transfer_destination ( destination_id, destination_name, destination_abbr ) VALUES ( 1, 'Imaging Data Commons', 'idc' );
INSERT INTO "public".transfer_destination ( destination_id, destination_name, destination_abbr ) VALUES ( 2, 'General Commons', 'gc' );
INSERT INTO "public".transfer_destination ( destination_id, destination_name, destination_abbr ) VALUES ( 3, 'WordPress', 'wp' );
INSERT INTO "public".transfer_destination ( destination_id, destination_name, destination_abbr ) VALUES ( 4, 'Aspera Faspex', 'asp' );
INSERT INTO "public".transfer_destination ( destination_id, destination_name, destination_abbr ) VALUES ( 5, 'NBIA', 'nbia' );

SELECT setval('transfer_destination_destination_id_seq', COALESCE(MAX(destination_id), 0), true) FROM transfer_destination;

INSERT INTO "public".dataset ( dataset_id, dataset_doi, dataset_type, dataset_short_title, dataset_title, dataset_name, active, when_created, who_updated, when_updated, who_created ) VALUES ( 1, '10.7937/k9/tcia.2015.u1x8a5nr', 'collection', 'RIDER Lung CT', 'Coffee-break lung CT dataset with scan images reconstructed at multiple imaging parameters', 'RIDER-LUNG-CT', true, NOW(), 'admin', NOW(), 'admin' );
INSERT INTO "public".dataset ( dataset_id, dataset_doi, dataset_type, dataset_short_title, dataset_title, dataset_name, active, when_created, who_updated, when_updated, who_created ) VALUES ( 2, '10.7937/tcia.2020.jit9grk8', 'analysis_result', 'RIDER-LungCT-Seg', 'RIDER Lung CT Segmentation Labels from: Decoding tumour phenotype by noninvasive imaging using a quantitative radiomics approach', 'RIDER-LUNGCT-SEG', true, NOW(), 'admin', NOW(), 'admin' );
INSERT INTO "public".dataset_relation ( dataset_id, related_dataset_id, relation_type ) VALUES ( 2, 1, 'isDerivedFrom' );

SELECT setval('dataset_dataset_id_seq', COALESCE(MAX(dataset_id), 0), true) FROM dataset;

INSERT INTO "public".recordset ( recordset_id, recordset_doi, dataset_id, license_id, recordset_type, recordset_title, recordset_name, active, when_created, who_created, when_updated, who_updated ) VALUES ( 1, null, 1, 2, 'radiology', 'radiology_01_public', 'Radiology 01 Public', true, NOW(), 'admin', NOW(), 'admin'  );
INSERT INTO "public".recordset ( recordset_id, recordset_doi, dataset_id, license_id, recordset_type, recordset_title, recordset_name, active, when_created, who_created, when_updated, who_updated ) VALUES ( 2, null, 1, 2, 'radiology', 'radiology_02_public', 'Radiology 02 Public', true, NOW(), 'admin', NOW(), 'admin'  );
INSERT INTO "public".recordset ( recordset_id, recordset_doi, dataset_id, license_id, recordset_type, recordset_title, recordset_name, active, when_created, who_created, when_updated, who_updated ) VALUES ( 3, null, 1, 4, 'radiology', 'radiology_03_limited', 'Radiology 03 Limited', true, NOW(), 'admin', NOW(), 'admin'  );
INSERT INTO "public".recordset ( recordset_id, recordset_doi, dataset_id, license_id, recordset_type, recordset_title, recordset_name, active, when_created, who_created, when_updated, who_updated ) VALUES ( 4, null, 1, 2, 'clinical', 'clinical_01_public', 'Clinical 01 Public', true, NOW(), 'admin', NOW(), 'admin'  );
INSERT INTO "public".recordset ( recordset_id, recordset_doi, dataset_id, license_id, recordset_type, recordset_title, recordset_name, active, when_created, who_created, when_updated, who_updated ) VALUES ( 5, null, 2, 2, 'annotation', 'annotation_01_public', 'Image Annotations 01 Public', true, NOW(), 'admin', NOW(), 'admin'  );
INSERT INTO "public".recordset ( recordset_id, recordset_doi, dataset_id, license_id, recordset_type, recordset_title, recordset_name, active, when_created, who_created, when_updated, who_updated ) VALUES ( 6, null, 2, 4, 'annotation', 'annotation_02_limited', 'Image Annotations 02 Limited', true, NOW(), 'admin', NOW(), 'admin'  );

SELECT setval('recordset_recordset_id_seq', COALESCE(MAX(recordset_id), 0), true) FROM recordset;

INSERT INTO "public".recordset_destination ( recordset_id, destination_id, default_display, default_transfer_mode ) VALUES ( 1, 1, true, 'group' ); -- Radiology - public - IDC - default - grouped transfer
INSERT INTO "public".recordset_destination ( recordset_id, destination_id, default_display, default_transfer_mode ) VALUES ( 1, 5, false, 'single' ); -- Radiology - public - NBIA - not - single payload
INSERT INTO "public".recordset_destination ( recordset_id, destination_id, default_display, default_transfer_mode ) VALUES ( 2, 1, true, 'group' ); -- Radiology - public - IDC - default - grouped transfer
INSERT INTO "public".recordset_destination ( recordset_id, destination_id, default_display, default_transfer_mode ) VALUES ( 2, 5, false, 'single' ); -- Radiology - public - NBIA - not - single payload
INSERT INTO "public".recordset_destination ( recordset_id, destination_id, default_display, default_transfer_mode ) VALUES ( 3, 2, true, 'single' ); -- Radiology - limited - GC - default - single payload
INSERT INTO "public".recordset_destination ( recordset_id, destination_id, default_display, default_transfer_mode ) VALUES ( 4, 2, true, 'single' ); -- Clinical - public - WP - default - single payload
INSERT INTO "public".recordset_destination ( recordset_id, destination_id, default_display, default_transfer_mode ) VALUES ( 4, 1, false, 'group' ); -- Clinical - public - IDC - not - grouped transfer
INSERT INTO "public".recordset_destination ( recordset_id, destination_id, default_display, default_transfer_mode ) VALUES ( 5, 1, true, 'group' ); -- Annotation - public - IDC - default - grouped transfer
INSERT INTO "public".recordset_destination ( recordset_id, destination_id, default_display, default_transfer_mode ) VALUES ( 6, 2, true, 'single' ); -- Annotation - limited - GC - default - single payload

INSERT INTO "public".recordset_release ( recordset_release_id, recordset_id, release_number, release_date, release_notes, when_created, who_created, when_updated, who_updated ) VALUES ( 1, 1, 2, NOW(), 'Initial Release', NOW(), 'admin', NOW(), 'admin' );
INSERT INTO "public".recordset_release ( recordset_release_id, recordset_id, release_number, release_date, release_notes, when_created, who_created, when_updated, who_updated ) VALUES ( 2, 2, 2, NOW(), 'Initial Release', NOW(), 'admin', NOW(), 'admin' );
INSERT INTO "public".recordset_release ( recordset_release_id, recordset_id, release_number, release_date, release_notes, when_created, who_created, when_updated, who_updated ) VALUES ( 3, 3, 2, NOW(), 'Initial Release', NOW(), 'admin', NOW(), 'admin' );
INSERT INTO "public".recordset_release ( recordset_release_id, recordset_id, release_number, release_date, release_notes, when_created, who_created, when_updated, who_updated ) VALUES ( 4, 4, 2, NOW(), 'Initial Release', NOW(), 'admin', NOW(), 'admin' );
INSERT INTO "public".recordset_release ( recordset_release_id, recordset_id, release_number, release_date, release_notes, when_created, who_created, when_updated, who_updated ) VALUES ( 5, 5, 2, NOW(), 'Initial Release', NOW(), 'admin', NOW(), 'admin' );
INSERT INTO "public".recordset_release ( recordset_release_id, recordset_id, release_number, release_date, release_notes, when_created, who_created, when_updated, who_updated ) VALUES ( 6, 6, 2, NOW(), 'Initial Release', NOW(), 'admin', NOW(), 'admin' );

SELECT setval('recordset_release_recordset_release_id_seq', COALESCE(MAX(recordset_release_id), 0), true) FROM recordset_release;

INSERT INTO "public".recordset_release_file ( recordset_release_id, file_id ) VALUES ( 1, 1 );
INSERT INTO "public".recordset_release_file ( recordset_release_id, file_id ) VALUES ( 1, 2 );
INSERT INTO "public".recordset_release_file ( recordset_release_id, file_id ) VALUES ( 1, 3 );
INSERT INTO "public".recordset_release_file ( recordset_release_id, file_id ) VALUES ( 1, 4 );
INSERT INTO "public".recordset_release_file ( recordset_release_id, file_id ) VALUES ( 1, 5 );
INSERT INTO "public".recordset_release_file ( recordset_release_id, file_id ) VALUES ( 2, 6 );
INSERT INTO "public".recordset_release_file ( recordset_release_id, file_id ) VALUES ( 2, 7 );
INSERT INTO "public".recordset_release_file ( recordset_release_id, file_id ) VALUES ( 2, 8 );
INSERT INTO "public".recordset_release_file ( recordset_release_id, file_id ) VALUES ( 2, 9 );
INSERT INTO "public".recordset_release_file ( recordset_release_id, file_id ) VALUES ( 2, 10 );
INSERT INTO "public".recordset_release_file ( recordset_release_id, file_id ) VALUES ( 3, 11 );
INSERT INTO "public".recordset_release_file ( recordset_release_id, file_id ) VALUES ( 3, 12 );
INSERT INTO "public".recordset_release_file ( recordset_release_id, file_id ) VALUES ( 3, 13 );
INSERT INTO "public".recordset_release_file ( recordset_release_id, file_id ) VALUES ( 3, 14 );
INSERT INTO "public".recordset_release_file ( recordset_release_id, file_id ) VALUES ( 3, 15 );
INSERT INTO "public".recordset_release_file ( recordset_release_id, file_id ) VALUES ( 4, 16 );
INSERT INTO "public".recordset_release_file ( recordset_release_id, file_id ) VALUES ( 5, 17 );
INSERT INTO "public".recordset_release_file ( recordset_release_id, file_id ) VALUES ( 5, 18 );
INSERT INTO "public".recordset_release_file ( recordset_release_id, file_id ) VALUES ( 5, 19 );
INSERT INTO "public".recordset_release_file ( recordset_release_id, file_id ) VALUES ( 5, 20 );
INSERT INTO "public".recordset_release_file ( recordset_release_id, file_id ) VALUES ( 5, 21 );
INSERT INTO "public".recordset_release_file ( recordset_release_id, file_id ) VALUES ( 6, 22 );
INSERT INTO "public".recordset_release_file ( recordset_release_id, file_id ) VALUES ( 6, 23 );
INSERT INTO "public".recordset_release_file ( recordset_release_id, file_id ) VALUES ( 6, 24 );
INSERT INTO "public".recordset_release_file ( recordset_release_id, file_id ) VALUES ( 6, 25 );
INSERT INTO "public".recordset_release_file ( recordset_release_id, file_id ) VALUES ( 6, 26 );

INSERT INTO "public".recordset_draft ( recordset_draft_id, recordset_id, cloned_from_release_id, draft_name, draft_status, draft_notes, when_created, who_created, when_updated, who_updated ) VALUES ( 1, 1, 1, 'Version 2 Draft', 'open', null, NOW(), 'admin', NOW(), 'admin' );
INSERT INTO "public".recordset_draft ( recordset_draft_id, recordset_id, cloned_from_release_id, draft_name, draft_status, draft_notes, when_created, who_created, when_updated, who_updated ) VALUES ( 2, 2, 2, 'Version 2 Draft', 'open', null, NOW(), 'admin', NOW(), 'admin' );
INSERT INTO "public".recordset_draft ( recordset_draft_id, recordset_id, cloned_from_release_id, draft_name, draft_status, draft_notes, when_created, who_created, when_updated, who_updated ) VALUES ( 3, 3, 3, 'Version 2 Draft', 'open', null, NOW(), 'admin', NOW(), 'admin' );
INSERT INTO "public".recordset_draft ( recordset_draft_id, recordset_id, cloned_from_release_id, draft_name, draft_status, draft_notes, when_created, who_created, when_updated, who_updated ) VALUES ( 4, 4, 4, 'Version 2 Draft', 'open', null, NOW(), 'admin', NOW(), 'admin' );
INSERT INTO "public".recordset_draft ( recordset_draft_id, recordset_id, cloned_from_release_id, draft_name, draft_status, draft_notes, when_created, who_created, when_updated, who_updated ) VALUES ( 5, 5, 5, 'Version 2 Draft', 'open', null, NOW(), 'admin', NOW(), 'admin' );
INSERT INTO "public".recordset_draft ( recordset_draft_id, recordset_id, cloned_from_release_id, draft_name, draft_status, draft_notes, when_created, who_created, when_updated, who_updated ) VALUES ( 6, 6, 6, 'Version 2 Draft', 'open', null, NOW(), 'admin', NOW(), 'admin' );

SELECT setval('recordset_draft_recordset_draft_id_seq', COALESCE(MAX(recordset_draft_id), 0), true) FROM recordset_draft;

INSERT INTO "public".recordset_draft_file ( recordset_draft_id, file_id ) VALUES ( 1, 1 );
INSERT INTO "public".recordset_draft_file ( recordset_draft_id, file_id ) VALUES ( 1, 2 );
INSERT INTO "public".recordset_draft_file ( recordset_draft_id, file_id ) VALUES ( 1, 3 );
INSERT INTO "public".recordset_draft_file ( recordset_draft_id, file_id ) VALUES ( 1, 4 );
INSERT INTO "public".recordset_draft_file ( recordset_draft_id, file_id ) VALUES ( 1, 5 );
INSERT INTO "public".recordset_draft_file ( recordset_draft_id, file_id ) VALUES ( 2, 6 );
INSERT INTO "public".recordset_draft_file ( recordset_draft_id, file_id ) VALUES ( 2, 7 );
INSERT INTO "public".recordset_draft_file ( recordset_draft_id, file_id ) VALUES ( 2, 8 );
INSERT INTO "public".recordset_draft_file ( recordset_draft_id, file_id ) VALUES ( 2, 9 );
INSERT INTO "public".recordset_draft_file ( recordset_draft_id, file_id ) VALUES ( 2, 10 );
INSERT INTO "public".recordset_draft_file ( recordset_draft_id, file_id ) VALUES ( 3, 11 );
INSERT INTO "public".recordset_draft_file ( recordset_draft_id, file_id ) VALUES ( 3, 12 );
INSERT INTO "public".recordset_draft_file ( recordset_draft_id, file_id ) VALUES ( 3, 13 );
INSERT INTO "public".recordset_draft_file ( recordset_draft_id, file_id ) VALUES ( 3, 14 );
INSERT INTO "public".recordset_draft_file ( recordset_draft_id, file_id ) VALUES ( 3, 15 );
INSERT INTO "public".recordset_draft_file ( recordset_draft_id, file_id ) VALUES ( 4, 16 );
INSERT INTO "public".recordset_draft_file ( recordset_draft_id, file_id ) VALUES ( 5, 17 );
INSERT INTO "public".recordset_draft_file ( recordset_draft_id, file_id ) VALUES ( 5, 18 );
INSERT INTO "public".recordset_draft_file ( recordset_draft_id, file_id ) VALUES ( 5, 19 );
INSERT INTO "public".recordset_draft_file ( recordset_draft_id, file_id ) VALUES ( 5, 20 );
INSERT INTO "public".recordset_draft_file ( recordset_draft_id, file_id ) VALUES ( 5, 21 );
INSERT INTO "public".recordset_draft_file ( recordset_draft_id, file_id ) VALUES ( 6, 22 );
INSERT INTO "public".recordset_draft_file ( recordset_draft_id, file_id ) VALUES ( 6, 23 );
INSERT INTO "public".recordset_draft_file ( recordset_draft_id, file_id ) VALUES ( 6, 24 );
INSERT INTO "public".recordset_draft_file ( recordset_draft_id, file_id ) VALUES ( 6, 25 );
INSERT INTO "public".recordset_draft_file ( recordset_draft_id, file_id ) VALUES ( 6, 26 );

INSERT INTO "public".dataset_release ( dataset_release_id, dataset_id, release_number, release_date, release_notes, when_created, who_created, when_updated, who_updated ) VALUES ( 1, 1, 2, NOW(), 'Initial Release', NOW(), 'admin', NOW(), 'admin' );
INSERT INTO "public".dataset_release ( dataset_release_id, dataset_id, release_number, release_date, release_notes, when_created, who_created, when_updated, who_updated ) VALUES ( 2, 2, 2, NOW(), 'Initial Release', NOW(), 'admin', NOW(), 'admin' );

SELECT setval('dataset_release_dataset_release_id_seq', COALESCE(MAX(dataset_release_id), 0), true) FROM dataset_release;

INSERT INTO "public".dataset_release_recordset ( dataset_release_id, recordset_release_id ) VALUES ( 1, 1 );
INSERT INTO "public".dataset_release_recordset ( dataset_release_id, recordset_release_id ) VALUES ( 1, 2 );
INSERT INTO "public".dataset_release_recordset ( dataset_release_id, recordset_release_id ) VALUES ( 1, 3 );
INSERT INTO "public".dataset_release_recordset ( dataset_release_id, recordset_release_id ) VALUES ( 1, 4 );
INSERT INTO "public".dataset_release_recordset ( dataset_release_id, recordset_release_id ) VALUES ( 2, 5 );
INSERT INTO "public".dataset_release_recordset ( dataset_release_id, recordset_release_id ) VALUES ( 2, 6 );