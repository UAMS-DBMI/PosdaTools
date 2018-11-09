"""
    This file defines all of the endpoints

    A given resource may be connected to more than one endpoint.

    TODO: Once blueprint chaining is supported in Sanic,
          adjust this to use a second blueprint for the api version
"""

from sanic import Blueprint

from .resources import collections as co
from .resources import studies as st
from .resources import series as se
from .resources import files as fi


def configure_blueprints(app):
    """Setup the main endpoints, adding each blueprint to the app"""

    app.blueprint(
        generate_collections_blueprint(),
        url_prefix='/v1/collections'
    )
    app.blueprint(
        generate_studies_blueprint(),
        url_prefix='/v1/studies'
    )
    app.blueprint(
        generate_series_blueprint(),
        url_prefix='/v1/series'
    )
    app.blueprint(
        generate_files_blueprint(),
        url_prefix='/v1/files'
    )


def generate_collections_blueprint():
    blueprint = Blueprint('collections')

    blueprint.add_route(
        co.get_all_collections,
        '/'
    )
    blueprint.add_route(
        co.get_single_collection,
        '/<collection_id>/<site_id>'
    )
    blueprint.add_route(
        co.get_all_patients,
        '/<collection_id>/<site_id>/patients'
    )
    blueprint.add_route(
        co.get_single_patient,
        '/<collection_id>/<site_id>/patients/<patient_id>'
    )
    blueprint.add_route(
        co.get_all_studies,
        '/<collection_id>/<site_id>/patients/<patient_id>/studies'
    )
    blueprint.add_route(
        st.get_single_study,
        '/<collection_id>/<site_id>/patients/<patient_id>/studies/<study_id>'
    )

    return blueprint

def generate_studies_blueprint():
    blueprint = Blueprint('studies')

    blueprint.add_route(
        st.get_all_studies,
        '/'
    )
    blueprint.add_route(
        st.get_single_study,
        '/<study_id>'
    )
    blueprint.add_route(
        st.get_all_series,
        '/<study_id>/series'
    )

    return blueprint

def generate_series_blueprint():
    blueprint = Blueprint('series')

    blueprint.add_route(
        se.get_all_series,
        '/'
    )
    blueprint.add_route(
        se.get_single_series,
        '/<series_id>'
    )
    blueprint.add_route(
        se.get_all_files,
        '/<series_id>/files'
    )

    return blueprint


def generate_files_blueprint():
    blueprint = Blueprint('files')
    a = blueprint.add_route

    blueprint.add_route(fi.get_all_files, '/')
    blueprint.add_route(fi.get_single_file, '/<file_id>')
    blueprint.add_route(fi.get_series_files, '/series/<series_uid>')
    blueprint.add_route(fi.get_iec_files, '/iec/<series_uid>')
    blueprint.add_route(fi.get_pixel_data, '/<file_id>/pixels')
    blueprint.add_route(fi.get_data, '/<file_id>/data')

    return blueprint
