INSERT INTO "public".recordset_license ( license_id, license_label, license_url, is_public_access ) VALUES ( 0, 'CC BY 3.0', 'https://creativecommons.org/licenses/by/3.0/', true );
INSERT INTO "public".recordset_license ( license_id, license_label, license_url, is_public_access ) VALUES ( 1, 'CC BY 4.0', 'https://creativecommons.org/licenses/by/4.0/', true );
INSERT INTO "public".recordset_license ( license_id, license_label, license_url, is_public_access ) VALUES ( 2, 'CC BY-NC 4.0', 'https://creativecommons.org/licenses/by-nc/4.0/', true );
INSERT INTO "public".recordset_license ( license_id, license_label, license_url, is_public_access ) VALUES ( 3, 'TCIA Limited', 'https://www.cancerimagingarchive.net/nih-controlled-data-access-policy/', false );

INSERT INTO "public".transfer_destination ( destination_id, name, abbr ) VALUES ( 0, 'Imaging Data Commons', 'idc' );
INSERT INTO "public".transfer_destination ( destination_id, name, abbr ) VALUES ( 1, 'General Commons', 'gc' );
INSERT INTO "public".transfer_destination ( destination_id, name, abbr ) VALUES ( 2, 'WordPress', 'wp' );
INSERT INTO "public".transfer_destination ( destination_id, name, abbr ) VALUES ( 3, 'Aspera Faspex', 'asp' );
INSERT INTO "public".transfer_destination ( destination_id, name, abbr ) VALUES ( 4, 'NBIA', 'nbia' );

INSERT INTO "public".dataset ( dataset_id, dataset_doi, dataset_type, dataset_short_title, dataset_title, dataset_name, active, when_created, who_updated, when_updated, who_created ) VALUES ( 0, '10.7937/k9/tcia.2015.u1x8a5nr', 'collection', 'RIDER Lung CT', 'Coffee-break lung CT dataset with scan images reconstructed at multiple imaging parameters', 'RIDER-LUNG-CT', true, NOW(), 'admin', NOW(), 'admin' );
INSERT INTO "public".dataset ( dataset_id, dataset_doi, dataset_type, dataset_short_title, dataset_title, dataset_name, active, when_created, who_updated, when_updated, who_created ) VALUES ( 1, '10.7937/tcia.2020.jit9grk8', 'analysis_result', 'RIDER-LungCT-Seg', 'RIDER Lung CT Segmentation Labels from: Decoding tumour phenotype by noninvasive imaging using a quantitative radiomics approach', 'RIDER-LUNGCT-SEG', true, NOW(), 'admin', NOW(), 'admin' );
INSERT INTO "public".dataset_relation ( dataset_id, related_dataset_id, relation_type ) VALUES ( 1, 0, 'isDerivedFrom' );

INSERT INTO "public".recordset ( recordset_id, recordset_doi, dataset_id, license_id, recordset_type, recordset_title, recordset_name, active, when_created, who_created, when_updated, who_updated ) VALUES ( 0, null, 0, 1, 'radiology', 'radiology_01_public', 'Radiology 01 Public', true, NOW(), 'admin', NOW(), 'admin'  );
INSERT INTO "public".recordset ( recordset_id, recordset_doi, dataset_id, license_id, recordset_type, recordset_title, recordset_name, active, when_created, who_created, when_updated, who_updated ) VALUES ( 1, null, 0, 1, 'radiology', 'radiology_02_public', 'Radiology 02 Public', true, NOW(), 'admin', NOW(), 'admin'  );
INSERT INTO "public".recordset ( recordset_id, recordset_doi, dataset_id, license_id, recordset_type, recordset_title, recordset_name, active, when_created, who_created, when_updated, who_updated ) VALUES ( 2, null, 0, 3, 'radiology', 'radiology_03_limited', 'Radiology 03 Limited', true, NOW(), 'admin', NOW(), 'admin'  );
INSERT INTO "public".recordset ( recordset_id, recordset_doi, dataset_id, license_id, recordset_type, recordset_title, recordset_name, active, when_created, who_created, when_updated, who_updated ) VALUES ( 3, null, 0, 1, 'clinical', 'clinical_01_public', 'Clinical 01 Public', true, NOW(), 'admin', NOW(), 'admin'  );
INSERT INTO "public".recordset ( recordset_id, recordset_doi, dataset_id, license_id, recordset_type, recordset_title, recordset_name, active, when_created, who_created, when_updated, who_updated ) VALUES ( 4, null, 1, 1, 'annotation', 'annotation_01_public', 'Image Annotations 01 Public', true, NOW(), 'admin', NOW(), 'admin'  );
INSERT INTO "public".recordset ( recordset_id, recordset_doi, dataset_id, license_id, recordset_type, recordset_title, recordset_name, active, when_created, who_created, when_updated, who_updated ) VALUES ( 5, null, 1, 3, 'annotation', 'annotation_02_limited', 'Image Annotations 02 Limited', true, NOW(), 'admin', NOW(), 'admin'  );

INSERT INTO "public".recordset_destination ( recordset_id, destination_id, default_display, default_transfer_mode ) VALUES ( 0, 0, true, 'group' ); -- Radiology - public - IDC - default - grouped transfer
INSERT INTO "public".recordset_destination ( recordset_id, destination_id, default_display, default_transfer_mode ) VALUES ( 0, 4, false, 'single' ); -- Radiology - public - NBIA - not - single payload
INSERT INTO "public".recordset_destination ( recordset_id, destination_id, default_display, default_transfer_mode ) VALUES ( 1, 0, true, 'group' ); -- Radiology - public - IDC - default - grouped transfer
INSERT INTO "public".recordset_destination ( recordset_id, destination_id, default_display, default_transfer_mode ) VALUES ( 1, 4, false, 'single' ); -- Radiology - public - NBIA - not - single payload
INSERT INTO "public".recordset_destination ( recordset_id, destination_id, default_display, default_transfer_mode ) VALUES ( 2, 1, true, 'single' ); -- Radiology - limited - GC - default - single payload
INSERT INTO "public".recordset_destination ( recordset_id, destination_id, default_display, default_transfer_mode ) VALUES ( 3, 1, true, 'single' ); -- Clinical - public - WP - default - single payload
INSERT INTO "public".recordset_destination ( recordset_id, destination_id, default_display, default_transfer_mode ) VALUES ( 3, 0, false, 'group' ); -- Clinical - public - IDC - not - grouped transfer
INSERT INTO "public".recordset_destination ( recordset_id, destination_id, default_display, default_transfer_mode ) VALUES ( 4, 0, true, 'group' ); -- Annotation - public - IDC - default - grouped transfer
INSERT INTO "public".recordset_destination ( recordset_id, destination_id, default_display, default_transfer_mode ) VALUES ( 5, 1, true, 'single' ); -- Annotation - limited - GC - default - single payload

INSERT INTO "public".recordset_release ( recordset_release_id, recordset_id, release_number, release_date, release_notes, when_created, who_created, when_updated, who_updated ) VALUES ( 0, 0, 1, NOW(), 'Initial Release', NOW(), 'admin', NOW(), 'admin' );
INSERT INTO "public".recordset_release ( recordset_release_id, recordset_id, release_number, release_date, release_notes, when_created, who_created, when_updated, who_updated ) VALUES ( 1, 1, 1, NOW(), 'Initial Release', NOW(), 'admin', NOW(), 'admin' );
INSERT INTO "public".recordset_release ( recordset_release_id, recordset_id, release_number, release_date, release_notes, when_created, who_created, when_updated, who_updated ) VALUES ( 2, 2, 1, NOW(), 'Initial Release', NOW(), 'admin', NOW(), 'admin' );
INSERT INTO "public".recordset_release ( recordset_release_id, recordset_id, release_number, release_date, release_notes, when_created, who_created, when_updated, who_updated ) VALUES ( 3, 3, 1, NOW(), 'Initial Release', NOW(), 'admin', NOW(), 'admin' );
INSERT INTO "public".recordset_release ( recordset_release_id, recordset_id, release_number, release_date, release_notes, when_created, who_created, when_updated, who_updated ) VALUES ( 4, 4, 1, NOW(), 'Initial Release', NOW(), 'admin', NOW(), 'admin' );
INSERT INTO "public".recordset_release ( recordset_release_id, recordset_id, release_number, release_date, release_notes, when_created, who_created, when_updated, who_updated ) VALUES ( 5, 5, 1, NOW(), 'Initial Release', NOW(), 'admin', NOW(), 'admin' );


INSERT INTO "public".recordset_release_file ( recordset_release_id, file_id ) VALUES ( 0, 1 );
INSERT INTO "public".recordset_release_file ( recordset_release_id, file_id ) VALUES ( 0, 2 );
INSERT INTO "public".recordset_release_file ( recordset_release_id, file_id ) VALUES ( 0, 3 );
INSERT INTO "public".recordset_release_file ( recordset_release_id, file_id ) VALUES ( 0, 4 );
INSERT INTO "public".recordset_release_file ( recordset_release_id, file_id ) VALUES ( 0, 5 );
INSERT INTO "public".recordset_release_file ( recordset_release_id, file_id ) VALUES ( 1, 6 );
INSERT INTO "public".recordset_release_file ( recordset_release_id, file_id ) VALUES ( 1, 7 );
INSERT INTO "public".recordset_release_file ( recordset_release_id, file_id ) VALUES ( 1, 8 );
INSERT INTO "public".recordset_release_file ( recordset_release_id, file_id ) VALUES ( 1, 9 );
INSERT INTO "public".recordset_release_file ( recordset_release_id, file_id ) VALUES ( 1, 10 );
INSERT INTO "public".recordset_release_file ( recordset_release_id, file_id ) VALUES ( 2, 11 );
INSERT INTO "public".recordset_release_file ( recordset_release_id, file_id ) VALUES ( 2, 12 );
INSERT INTO "public".recordset_release_file ( recordset_release_id, file_id ) VALUES ( 2, 13 );
INSERT INTO "public".recordset_release_file ( recordset_release_id, file_id ) VALUES ( 2, 14 );
INSERT INTO "public".recordset_release_file ( recordset_release_id, file_id ) VALUES ( 2, 15 );
INSERT INTO "public".recordset_release_file ( recordset_release_id, file_id ) VALUES ( 3, 16 );
INSERT INTO "public".recordset_release_file ( recordset_release_id, file_id ) VALUES ( 4, 17 );
INSERT INTO "public".recordset_release_file ( recordset_release_id, file_id ) VALUES ( 4, 18 );
INSERT INTO "public".recordset_release_file ( recordset_release_id, file_id ) VALUES ( 4, 19 );
INSERT INTO "public".recordset_release_file ( recordset_release_id, file_id ) VALUES ( 4, 20 );
INSERT INTO "public".recordset_release_file ( recordset_release_id, file_id ) VALUES ( 4, 21 );
INSERT INTO "public".recordset_release_file ( recordset_release_id, file_id ) VALUES ( 5, 22 );
INSERT INTO "public".recordset_release_file ( recordset_release_id, file_id ) VALUES ( 5, 23 );
INSERT INTO "public".recordset_release_file ( recordset_release_id, file_id ) VALUES ( 5, 24 );
INSERT INTO "public".recordset_release_file ( recordset_release_id, file_id ) VALUES ( 5, 25 );
INSERT INTO "public".recordset_release_file ( recordset_release_id, file_id ) VALUES ( 5, 26 );

INSERT INTO "public".recordset_draft ( recordset_draft_id, recordset_id, cloned_from_release_id, draft_name, draft_status, draft_notes, when_created, who_created, when_updated, who_updated ) VALUES ( 0, 0, 0, 'Version 2 Draft', 'open', null, NOW(), 'admin', NOW(), 'admin' );
INSERT INTO "public".recordset_draft ( recordset_draft_id, recordset_id, cloned_from_release_id, draft_name, draft_status, draft_notes, when_created, who_created, when_updated, who_updated ) VALUES ( 1, 1, 1, 'Version 2 Draft', 'open', null, NOW(), 'admin', NOW(), 'admin' );
INSERT INTO "public".recordset_draft ( recordset_draft_id, recordset_id, cloned_from_release_id, draft_name, draft_status, draft_notes, when_created, who_created, when_updated, who_updated ) VALUES ( 2, 2, 2, 'Version 2 Draft', 'open', null, NOW(), 'admin', NOW(), 'admin' );
INSERT INTO "public".recordset_draft ( recordset_draft_id, recordset_id, cloned_from_release_id, draft_name, draft_status, draft_notes, when_created, who_created, when_updated, who_updated ) VALUES ( 3, 3, 3, 'Version 2 Draft', 'open', null, NOW(), 'admin', NOW(), 'admin' );
INSERT INTO "public".recordset_draft ( recordset_draft_id, recordset_id, cloned_from_release_id, draft_name, draft_status, draft_notes, when_created, who_created, when_updated, who_updated ) VALUES ( 4, 4, 4, 'Version 2 Draft', 'open', null, NOW(), 'admin', NOW(), 'admin' );
INSERT INTO "public".recordset_draft ( recordset_draft_id, recordset_id, cloned_from_release_id, draft_name, draft_status, draft_notes, when_created, who_created, when_updated, who_updated ) VALUES ( 5, 5, 5, 'Version 2 Draft', 'open', null, NOW(), 'admin', NOW(), 'admin' );

INSERT INTO "public".recordset_draft_file ( recordset_draft_id, file_id ) VALUES ( 0, 1 );
INSERT INTO "public".recordset_draft_file ( recordset_draft_id, file_id ) VALUES ( 0, 2 );
INSERT INTO "public".recordset_draft_file ( recordset_draft_id, file_id ) VALUES ( 0, 3 );
INSERT INTO "public".recordset_draft_file ( recordset_draft_id, file_id ) VALUES ( 0, 4 );
INSERT INTO "public".recordset_draft_file ( recordset_draft_id, file_id ) VALUES ( 0, 5 );
INSERT INTO "public".recordset_draft_file ( recordset_draft_id, file_id ) VALUES ( 1, 6 );
INSERT INTO "public".recordset_draft_file ( recordset_draft_id, file_id ) VALUES ( 1, 7 );
INSERT INTO "public".recordset_draft_file ( recordset_draft_id, file_id ) VALUES ( 1, 8 );
INSERT INTO "public".recordset_draft_file ( recordset_draft_id, file_id ) VALUES ( 1, 9 );
INSERT INTO "public".recordset_draft_file ( recordset_draft_id, file_id ) VALUES ( 1, 10 );
INSERT INTO "public".recordset_draft_file ( recordset_draft_id, file_id ) VALUES ( 2, 11 );
INSERT INTO "public".recordset_draft_file ( recordset_draft_id, file_id ) VALUES ( 2, 12 );
INSERT INTO "public".recordset_draft_file ( recordset_draft_id, file_id ) VALUES ( 2, 13 );
INSERT INTO "public".recordset_draft_file ( recordset_draft_id, file_id ) VALUES ( 2, 14 );
INSERT INTO "public".recordset_draft_file ( recordset_draft_id, file_id ) VALUES ( 2, 15 );
INSERT INTO "public".recordset_draft_file ( recordset_draft_id, file_id ) VALUES ( 3, 16 );
INSERT INTO "public".recordset_draft_file ( recordset_draft_id, file_id ) VALUES ( 4, 17 );
INSERT INTO "public".recordset_draft_file ( recordset_draft_id, file_id ) VALUES ( 4, 18 );
INSERT INTO "public".recordset_draft_file ( recordset_draft_id, file_id ) VALUES ( 4, 19 );
INSERT INTO "public".recordset_draft_file ( recordset_draft_id, file_id ) VALUES ( 4, 20 );
INSERT INTO "public".recordset_draft_file ( recordset_draft_id, file_id ) VALUES ( 4, 21 );
INSERT INTO "public".recordset_draft_file ( recordset_draft_id, file_id ) VALUES ( 5, 22 );
INSERT INTO "public".recordset_draft_file ( recordset_draft_id, file_id ) VALUES ( 5, 23 );
INSERT INTO "public".recordset_draft_file ( recordset_draft_id, file_id ) VALUES ( 5, 24 );
INSERT INTO "public".recordset_draft_file ( recordset_draft_id, file_id ) VALUES ( 5, 25 );
INSERT INTO "public".recordset_draft_file ( recordset_draft_id, file_id ) VALUES ( 5, 26 );

INSERT INTO "public".dataset_release ( dataset_release_id, dataset_id, release_number, release_date, release_notes, when_created, who_created, when_updated, who_updated ) VALUES ( 0, 0, 1, NOW(), 'Initial Release', NOW(), 'admin', NOW(), 'admin' );
INSERT INTO "public".dataset_release ( dataset_release_id, dataset_id, release_number, release_date, release_notes, when_created, who_created, when_updated, who_updated ) VALUES ( 1, 1, 1, NOW(), 'Initial Release', NOW(), 'admin', NOW(), 'admin' );

INSERT INTO "public".dataset_release_recordset ( dataset_release_id, recordset_release_id ) VALUES ( 0, 0 );
INSERT INTO "public".dataset_release_recordset ( dataset_release_id, recordset_release_id ) VALUES ( 0, 1 );
INSERT INTO "public".dataset_release_recordset ( dataset_release_id, recordset_release_id ) VALUES ( 0, 2 );
INSERT INTO "public".dataset_release_recordset ( dataset_release_id, recordset_release_id ) VALUES ( 0, 3 );
INSERT INTO "public".dataset_release_recordset ( dataset_release_id, recordset_release_id ) VALUES ( 1, 4 );
INSERT INTO "public".dataset_release_recordset ( dataset_release_id, recordset_release_id ) VALUES ( 1, 5 );