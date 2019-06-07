from sanic import response
from sanic.response import json, text, HTTPResponse
from sanic.views import HTTPMethodView
from sanic.exceptions import NotFound


from ..util import asynctar
from ..util import db
from ..util import json_objects, json_records

import logging


# /vris
async def get_all_vris(request, **kwargs):
    """Return a list of all VRIs"""
    # This really should allow filtering, limiting, paging, etc

    query = """\
select
    *
from visual_review_instance
    """

    return json_records(
        await db.fetch(query)
    )


# /vris/<vri>
async def get_vri_details(request, vri, **kwargs):
    query = """\
select
	project_name,
	site_name,
	count(distinct series_instance_uid) series_count,
	count(file_id) file_count
from image_equivalence_class
natural join image_equivalence_class_input_image
natural join ctp_file
where visual_review_instance_id = $1
  and processing_status = 'ReadyToReview'
group by project_name, site_name
    """

    return json_records(
        await db.fetch_one(query, [int(vri)])
    )

# /vris/<vri>/counts
async def get_vri_counts(request, vri, **kwargs):
    """Return counts of IECs in each review state"""
    query = """\
select
	coalesce(review_status, 'Unreviewed') as review_status,
	count(distinct image_equivalence_class_id)
from image_equivalence_class
natural join image_equivalence_class_input_image
where visual_review_instance_id = $1
  and processing_status in ('ReadyToReview', 'Reviewed')
group by review_status
    """

    return json_records(
        await db.fetch(query, [int(vri)])
    )

# /vris/<vri>/<state>
# Maybe change this so that it always returns the full list of
# iecs for each state. Then, if you're looking at unreviewed, you can
# choose to skip an iec when you load it, if it is alreay reviewed
# Yes ^
async def get_iecs_for_state(request, vri, state, **kwargs):
    """Return the list of IECs for the given VRI in the given state"""

    # Map of 
    #   state parameter => review_status
    state_map = {
        'good': 'Good',
        'bad': 'Bad',
        'blank': 'Blank',
        'unreviewed': None,
    }

    mapped_state = state_map[state.lower()]

    # Special case for unreviewed
    if mapped_state is None:
        query = """\
            select
                    image_equivalence_class_id
            from image_equivalence_class
            where visual_review_instance_id = $1
              and processing_status = 'ReadyToReview'
              and review_status is null
        """
        return json_records(
            await db.fetch(query, [int(vri)])
        )


    query = """\
        select
                image_equivalence_class_id
        from image_equivalence_class
        where visual_review_instance_id = $1
          and processing_status = 'Reviewed'
          and review_status = $2
    """

    return json_records(
        await db.fetch(query, [int(vri), mapped_state])
    )

