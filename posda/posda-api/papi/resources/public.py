from sanic import response
from sanic.response import json, text, HTTPResponse
from sanic.views import HTTPMethodView

from posda.database import Database


from ..util import json_objects, json_records

from ..models import Collection


async def test(request, **kwargs):
    query = """
        select
                tdp.project as Collection,'|',
                group_concat(distinct s.modality) as Modalities,'|',
                count(distinct p.patient_id) as Pts,'|',
                count(distinct t.study_instance_uid) as Studies,'|',
                count(distinct s.series_instance_uid) as Series,'|',
                count(distinct i.sop_instance_uid) as Images, '|',
                format(sum(i.dicom_size)/1000000000,1) as GBytes
         
             from
                general_image i,
                general_series s,
                study t,
                patient p,
                trial_data_provenance tdp
         
             where
                i.general_series_pk_id = s.general_series_pk_id and
                s.study_pk_id = t.study_pk_id and
                t.patient_pk_id = p.patient_pk_id and
                p.trial_dp_pk_id = tdp.trial_dp_pk_id and
                tdp.project = 'CPTAC-CCRCC'
                and s.visibility = 1
         
             group by tdp.project
    """


    with Database("public") as conn:
        cur = conn.cursor()

        return json_records(
            cur.execute(query)
        )

