"""
    Tests for Posda-Api

    TODO: These are currently tied to actual PROD data
          all of that should be fixed and replaced with
          mock data! But how?
"""

import pytest
import requests
import hashlib

ROOT = "http://localhost:8087/v1"


def test_root():
    req = requests.get(ROOT)
    assert req.status_code == 404


def test_collections_root():
    req = requests.get(ROOT + "/collections")

    assert req.status_code == 200
    assert len(req.json()) > 1

def test_collections():
    req = requests.get(ROOT + "/collections/LDCT/BOSTONU")
    obj = req.json()

    assert req.status_code == 200
    assert obj['collection'] == 'LDCT'
    assert obj['site'] == 'BOSTONU'
    assert 'file_count' in obj
    assert 'patient_count' in obj

def test_collections_patients_root():
    req = requests.get(ROOT + "/collections/LDCT/BOSTONU/patients")
    obj = req.json()

    assert req.status_code == 200
    assert {'patient': 'LDCT-07-001'} in obj

def test_collections_patients():
    req = requests.get(ROOT + "/collections/LDCT/BOSTONU/patients/LDCT-07-001")
    obj = req.json()

    assert req.status_code == 200

    assert 'patient' in obj
    assert 'patient_id' in obj
    assert 'patient_sex' in obj
    assert 'patient_ethnic_group' in obj
    assert 'comments' in obj
    assert 'file_count' in obj
    assert 'study_count' in obj

    assert obj['patient'] == 'LDCT-07-001'
    assert obj['study_count'] == 1


def test_collections_patients_studies():
    req = requests.get(
        ROOT + "/collections/LDCT/BOSTONU/patients/LDCT-07-001/studies"
    )
    obj = req.json()

    assert req.status_code == 200
    assert obj[0]['study_instance_uid'] == \
        '1.3.6.1.4.1.14519.5.2.1.4792.1600.108467762757913801129608477056'


def test_studies_root():
    req = requests.get(ROOT + "/studies")

    assert req.status_code == 401

def test_studies():
    req = requests.get(
        ROOT + 
        "/studies/"
        "1.3.6.1.4.1.14519.5.2.1.4792.1600.108467762757913801129608477056")
    obj = req.json()

    assert req.status_code == 200
    assert obj == {'study_date': 1200700800,
                   'study_time': '10:27:08',
                   'series_count': 6}

def test_studies_series():
    req = requests.get(
        ROOT + 
        "/studies/"
        "1.3.6.1.4.1.14519.5.2.1.4792.1600.108467762757913801129608477056"
        "/series")
    obj = req.json()

    assert req.status_code == 200
    assert obj == [
        {'series_instance_uid': 
         '1.3.6.1.4.1.14519.5.2.1.4792.1600.114574119903422033397802325435'}, 
        {'series_instance_uid': 
         '1.3.6.1.4.1.14519.5.2.1.4792.1600.138854165364608815979917459531'}, 
        {'series_instance_uid': 
         '1.3.6.1.4.1.14519.5.2.1.4792.1600.145468087448161358735649950068'}, 
        {'series_instance_uid': 
         '1.3.6.1.4.1.14519.5.2.1.4792.1600.172996149212712697622981481117'}, 
        {'series_instance_uid': 
         '1.3.6.1.4.1.14519.5.2.1.4792.1600.220280098748387011483480028744'}, 
        {'series_instance_uid': 
         '1.3.6.1.4.1.14519.5.2.1.4792.1600.751332489324940646100460626198'}
    ]

def test_series_root():
    req = requests.get(ROOT + "/series/")

    # listing is not not allowed on this endpoint
    assert req.status_code == 401


def test_series():
    req = requests.get(
        ROOT + 
        "/series/"
        "1.3.6.1.4.1.14519.5.2.1.4792.1600.751332489324940646100460626198"
    )
    obj = req.json()

    assert req.status_code == 200
    assert obj == {'series_instance_uid': '1.3.6.1.4.1.14519.5.2.1.4792.1600.751332489324940646100460626198', 'series_date': 1200700800, 'series_time': '10:27:08', 'modality': 'CT', 'laterality': None, 'series_description': 'Scout', 'file_count': 2}


def test_series_files():
    req = requests.get(
        ROOT + 
        "/series/"
        "1.3.6.1.4.1.14519.5.2.1.4792.1600.751332489324940646100460626198"
        "/files"
    )
    obj = req.json()

    assert req.status_code == 200
    assert obj == [{'file_id': 1152289}, 
           {'file_id': 1152288}]


def test_files_root():
    req = requests.get(ROOT + "/files")

    # listing is not not allowed on this endpoint
    assert req.status_code == 401


def test_files():
    req = requests.get(
        ROOT +
        "/files/"
        "1152289"
    )
    obj = req.json()

    assert req.status_code == 200
    assert obj == {'file_id': 1152289,
                   'digest': '6870a8d530182ac9d798897fff0a8620',
                   'size': 1345932,
                   'is_dicom_file': True,
                   'file_type': 'parsed dicom file',
                   'processing_priority': 1,
                   'ready_to_process': True}

def test_files_data():
    req = requests.get(
        ROOT +
        "/files/"
        "1152289"
        "/data"
    )

    assert req.status_code == 200

    md5 = hashlib.md5()
    md5.update(req.content)
    assert md5.hexdigest() == '6870a8d530182ac9d798897fff0a8620'


def test_files_pixel_data():
    req = requests.get(
        ROOT +
        "/files/"
        "1152289"
        "/pixel_data"
    )

    assert req.status_code == 200

    md5 = hashlib.md5()
    md5.update(req.content)
    assert md5.hexdigest() == '6870a8d530182ac9d798897fff0a8620'
