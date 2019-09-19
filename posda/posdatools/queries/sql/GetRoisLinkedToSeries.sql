-- Name: GetRoisLinkedToSeries
-- Schema: posda_files
-- Columns: ['roi_num', 'roi_name', 'roi_color', 'image_file_id', 'file_id', 'data_set_start', 'contour_file_offset', 'contour_length', 'num_points', 'true_offset']
-- Args: ['sop_instance_uid']
-- Tags: ['LinkageChecks', 'used_in_struct_linkage_check']
-- Description: Get list of Roi with info by file_id
-- 
-- 

select
                roi_num,
                roi_name,
                roi_color,
                file_sop_common.file_id as image_file_id,
                fril.file_id as file_id,
                data_set_start,
                contour_file_offset,
                contour_length,
                num_points,
                data_set_start + contour_file_offset as true_offset,
                (
                    select root_path || '/' || rel_path
                    from file_location
                    natural join file_storage_root
                    where file_location.file_id = fril.file_id
                    limit 1
                ) as filename,
                (
                    select iop
                    from file_image
                    natural join image_geometry
                    where file_image.file_id = file_sop_common.file_id
                    limit 1
                ) as iop,
                (
                    select ipp
                    from file_image
                    natural join image_geometry
                    where file_image.file_id = file_sop_common.file_id
                    limit 1
                ) as ipp,
                (
                    select pixel_spacing
                    from file_image
                    natural join image
                    where file_image.file_id = file_sop_common.file_id
                    limit 1
                ) as pixel_spacing
        from file_sop_common
        join file_roi_image_linkage fril
                on fril.linked_sop_instance_uid = file_sop_common.sop_instance_uid
        join ctp_file on fril.file_id = ctp_file.file_id
        join file_meta
                on file_meta.file_id = fril.file_id
        natural join roi
        where sop_instance_uid = ? and visibility is null
