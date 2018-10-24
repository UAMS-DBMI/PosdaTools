-- Name: InsertFileFrameOfRef
-- Schema: posda_files
-- Columns: []
-- Args: ['file_id', 'for_uid', 'position_ref_indicator']
-- Tags: ['Structure Sets', 'sops', 'LinkageChecks', 'plan_linkages']
-- Description: Get list of plan which reference unknown SOPs
-- 
-- 

insert into file_for(file_id, for_uid, position_ref_indicator) values(?, ?, ?)