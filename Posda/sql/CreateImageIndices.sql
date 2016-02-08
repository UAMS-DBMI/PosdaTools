-- 
-- Copyright 2008, Bill Bennett
--  Part of the Posda package
--  Posda may be copied only under the terms of either the Artistic License or the
--  GNU General Public License, which may be found in the Posda Distribution,
--  or at http://posda.com/License.html
-- 
-- file_id indices
create index file_import_file_id_index on file_import(file_id);
create index dicom_file_file_id_index on dicom_file(file_id);
create index ctp_file_file_id_index on ctp_file(file_id);
create index ctp_file_file_id_index on ctp_file(file_id);
create index dicom_file_errors_file_id_index on dicom_file_errors(file_id);
