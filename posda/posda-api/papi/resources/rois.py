from sanic import response
from sanic.response import json, text, HTTPResponse
from sanic.views import HTTPMethodView

from ..util import db
from ..util import json_objects, json_records, json
from ..util import roi


async def test(request):
    return text("test error, not allowed", status=401)


async def get_rois_for_series(request, series, **kwargs):
    query = """\
        select
            roi_num,
            roi_name as name,
            roi_color as color,
            array_agg(file_sop_common.file_id) as file_ids
        from file_series
        natural join file_sop_common
        join ctp_file on ctp_file.file_id = file_sop_common.file_id
        join file_roi_image_linkage
            on linked_sop_instance_uid = sop_instance_uid
        natural join roi
        where series_instance_uid = $1
        and ctp_file.visibility is null
        group by roi_num, roi_name, roi_color
        order by roi_num
    """

    results = await db.fetch(query, [series])
    rois = []
    for result in results:
        r = {}
        r['roi_num'] = result['roi_num']
        r['name'] = result['name']
        r['color'] = roi.format_color(result['color'])
        r['file_ids'] = result['file_ids']
        rois.append(r)

    return json(rois)

async def get_series_rois_from_file(request, file_id, **kwargs):
    ret = await db.fetch_one("""\
        select series_instance_uid
        from file_series
        where file_id = $1
    """, [int(file_id)])

    return await get_rois_for_series(
        request,
        ret['series_instance_uid'],
        **kwargs
    )

async def get_contours_for_sop(request, sop, **kwargs):
    query = """\
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
        join ctp_file
                on fril.file_id = ctp_file.file_id
        join file_meta
                on file_meta.file_id = fril.file_id
        natural join roi
        where sop_instance_uid = $1
          and ctp_file.visibility is null
    """

    raw_contours = await db.fetch(query, [sop])

    contours = []

    for cont in raw_contours:
        c = await roi.get_transformed_contour(
            length=cont['contour_length'],
            num_points=cont['num_points'],
            offset=cont['true_offset'],
            filename=cont['filename'],
            iop=cont['iop'],
            ipp=cont['ipp'],
            pixel_spacing=cont['pixel_spacing'],
        )

        contours.append({
            'name': cont['roi_name'],
            'color': roi.format_color(cont['roi_color']),
            'points': c.tolist(),
        })

    return json(contours)


async def get_contours_for_file(request, file_id, **kwargs):
    ret = await db.fetch_one("""\
        select sop_instance_uid
        from file_sop_common
        where file_id = $1
    """, [int(file_id)])


    return await get_contours_for_sop(
        request,
        ret['sop_instance_uid'],
        **kwargs
    )
