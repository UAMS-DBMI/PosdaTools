-- 
-- Copyright 2008, Bill Bennett
--  Part of the Posda package
--  Posda may be copied only under the terms of either the Artistic License or the
--  GNU General Public License, which may be found in the Posda Distribution,
--  or at http://posda.com/License.html
-- 
-- file_id indices
CREATE INDEX ctp_file_file_id_index ON ctp_file(file_id);
CREATE INDEX ctp_proj_site_file_index ON ctp_file(file_id, project_name, site_name);
CREATE INDEX ctp_proj_site_index ON ctp_file(project_name, site_name);
CREATE INDEX dicom_file_file_id_index ON dicom_file(file_id);
CREATE INDEX file_ct_image_file_id_index ON file_ct_image(file_id);
CREATE INDEX file_import_file_id_idx ON file_import(file_id);
CREATE INDEX file_import_import_event_id_idx ON file_import(import_event_id);
CREATE INDEX file_patient_file_id_index ON file_patient(file_id);
CREATE INDEX file_series_file_id_index ON file_series(file_id);
CREATE INDEX file_sop_common_file_id_idx ON file_sop_common(file_id);
CREATE INDEX file_sop_common_sop_instance_uid_index ON file_sop_common(sop_instance_uid);
CREATE INDEX file_study_file_id_index ON file_study(file_id);
CREATE INDEX image_geometry_image_id_index ON image_geometry(image_id);
CREATE UNIQUE INDEX import_event_import_event_id_idx ON import_event(import_event_id);
CREATE INDEX import_event_import_time_idx ON import_event(import_time);
CREATE INDEX file_visibility_change_idx ON file_visibility_change(file_id);
