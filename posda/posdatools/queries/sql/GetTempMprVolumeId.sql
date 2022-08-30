-- Name: GetTempMprVolumeId
-- Schema: posda_files
-- Columns: []
-- Args: ['temp_mpr_volume_description']
-- Tags: ['TempMprVolume']
-- Description: Get the id of a row in temp_mpr_volume from it's description
-- 

select temp_mpr_volume_id
from temp_mpr_volume
where temp_mpr_volume_description = ?
