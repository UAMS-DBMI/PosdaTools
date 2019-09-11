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
from .resources import rois
from .resources import importer
from .resources import dashboard
from .resources import vrstatus
from .resources import send_to_public_status
from .resources import iecs


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
    app.blueprint(
        generate_rois_blueprint(),
        url_prefix='/v1/rois'
    )
    app.blueprint(
        generate_import_blueprint(),
        url_prefix='/v1/import'
    )
    app.blueprint(
        generate_dashboard_blueprint(),
        url_prefix='/v1/dashboard'
    )
    app.blueprint(
        generate_vrstatus_blueprint(),
        url_prefix='/v1/vrstatus'
    )
    app.blueprint(
        generate_iecs_blueprint(),
        url_prefix='/v1/iecs'
    )

def generate_dashboard_blueprint():
    blueprint = Blueprint('dashboard')

    blueprint.add_route(
        dashboard.slow_dbif_queries,
        '/slow_dbif_queries/<days>'
    )
    blueprint.add_route(
        dashboard.PossiblyRunningBackgroundSubprocesses,
        '/prbs'
    )
    blueprint.add_route(
        dashboard.background_subprocess_stats_by_user_this_week,
        '/bsbu'
    )
    blueprint.add_route(
        dashboard.files_without_type,
        '/fwt'
    )
    blueprint.add_route(
        dashboard.files_without_location,
        '/fwl'
    )
    blueprint.add_route(
        dashboard.get_file_time_chart,
        '/ftc'
    )
    blueprint.add_route(
        dashboard.table_lock_alert,
        '/tla'
    )
    blueprint.add_route(
        dashboard.get_query_runtime_versus_invocations,
        '/qrvi'
    )
    return blueprint

def generate_vrstatus_blueprint():
    blueprint = Blueprint('vrstatus')


    blueprint.add_route(
        vrstatus.find_vr_ready_to_begin_status_updates,
        '/find_vr_ready_to_begin_status_updates'
    )
    blueprint.add_route(
        vrstatus.get_reviewed_percentage_for_vr,
        '/get_reviewed_percentage_for_vr/<visual_review_instance_id>'
    )
    blueprint.add_route(
        vrstatus.update_activity_status,
        '/update_activity_status/<visual_review_instance_id>/<new_status>'
    )
    blueprint.add_route(
        vrstatus.get_visible_bads_for_vr,
        '/get_visible_bads_for_vr/<visual_review_instance_id>'
    )
    blueprint.add_route(
        vrstatus.finish_activity_status,
        '/finish_activity_status/<visual_review_instance_id>'
    )
    return blueprint

def generate_send_to_public_status_blueprint():
    blueprint = Blueprint('send_to_public_status')


    blueprint.add_route(
        send_to_public_status.find_send_ready_to_begin_status_updates,
        '/find_send_ready_to_begin_status_updates'
    )
    blueprint.add_route(
        send_to_public_status.get_success_percentage_for_send,
        '/get_success_percentage_for_send/<subprocess_invocation_id>'
    )
    blueprint.add_route(
        send_to_public_status.update_activity_status,
        '/update_activity_status/<subprocess_invocation_id>/<new_status>'
    )
    blueprint.add_route(
        send_to_public_status.finish_activity_status,
        '/finish_activity_status/<subprocess_invocation_id>'
    )
    return blueprint

def generate_iecs_blueprint():
    blueprint = Blueprint('iecs')

    blueprint.add_route(
        iecs.get_iec_details,
        '/<iec>'
    )
    blueprint.add_route(
        iecs.get_iec_files,
        '/<iec>/files'
    )

    return blueprint

def generate_rois_blueprint():
    blueprint = Blueprint('rois')

    blueprint.add_route(
        rois.get_contours_for_sop,
        '/sop/<sop>'
    )
    blueprint.add_route(
        rois.get_contours_for_file,
        '/file/<file_id>'
    )
    blueprint.add_route(
        rois.get_rois_for_series,
        '/series/<series>'
    )
    blueprint.add_route(
        rois.get_series_rois_from_file,
        '/file/<file_id>/series'
    )

    return blueprint

def generate_import_blueprint():
    blueprint = Blueprint('import')

    # blueprint.add_route(
    #     co.get_all_collections,
    #     '/'
    # )

    blueprint.add_route(
        importer.ImportEvent.as_view(),
        '/event'
    )
    blueprint.add_route(
        importer.CloseImportEvent.as_view(),
        '/event/<event_id>/close'
    )
    blueprint.add_route(
        importer.ImportFile.as_view(),
        '/file'
    )

    return blueprint

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
    blueprint.add_route(fi.get_iec_files, '/iec/<iec_id>')
    blueprint.add_route(fi.get_pixel_data, '/<file_id>/pixels')
    blueprint.add_route(fi.get_data, '/<file_id>/data')
    blueprint.add_route(fi.get_details, '/<file_id>/details')

    return blueprint
