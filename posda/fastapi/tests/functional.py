"""
    Tests for Posda-Api (FastAPI)

    TODO: These are currently tied to actual PROD data
          all of that should be fixed and replaced with
          mock data! But how?
"""

import unittest
import requests
import hashlib

ROOT = "http://localhost/papi/v1"
# ROOT = "http://tcia-posda-rh-2.ad.uams.edu/papi/v1"


class TestApi(unittest.TestCase):

    def test_root(self):
        req = requests.get(ROOT)
        self.assertEqual(req.status_code, 404)


    def test_collections_root(self):
        req = requests.get(ROOT + "/collections")

        self.assertEqual(req.status_code, 200)
        self.assertGreater(len(req.json()), 0)

    def test_collections(self):
        req = requests.get(ROOT + "/collections/LDCT/Lahey")
        obj = req.json()

        self.assertEqual(req.status_code, 200)
        self.assertEqual(obj['collection'], 'LDCT')
        self.assertEqual(obj['site'], 'Lahey')
        self.assertIn('file_count', obj)
        self.assertIn('patient_count', obj)

    def test_collections_patients_root(self):
        req = requests.get(ROOT + "/collections/LDCT/Lahey/patients")
        obj = req.json()

        self.assertEqual(req.status_code, 200)
        self.assertIn({'patient': 'LDCT-01-001'}, obj)

    def test_collections_patients(self):
        req = requests.get(ROOT + "/collections/LDCT/Lahey/patients/LDCT-01-001")
        obj = req.json()

        self.assertEqual(req.status_code, 200)

        self.assertIn('patient', obj)
        self.assertIn('patient_id', obj)
        self.assertIn('patient_sex', obj)
        self.assertIn('patient_ethnic_group', obj)
        self.assertIn('comments', obj)
        self.assertIn('file_count', obj)
        self.assertIn('study_count', obj)

        self.assertEqual(obj['patient'], 'LDCT-01-001')
        self.assertEqual(obj['study_count'], 1)


    def test_collections_patients_studies(self):
        req = requests.get(
            ROOT + "/collections/LDCT/Lahey/patients/LDCT-01-001/studies"
        )
        obj = req.json()

        self.assertEqual(req.status_code, 200)
        self.assertEqual(obj[0]['study_instance_uid'],
            '1.3.6.1.4.1.14519.5.2.1.3983.1600.175911262200889415475108687483')


    def test_studies_root(self):
        req = requests.get(ROOT + "/studies")

        self.assertEqual(req.status_code, 401)

    def test_studies(self):
        req = requests.get(
            ROOT + 
            "/studies/"
            "1.3.6.1.4.1.14519.5.2.1.3983.1600.175911262200889415475108687483")
        self.assertEqual(req.status_code, 200)
        obj = req.json()

        self.assertEqual(obj, {'study_date': '2007-02-28',
                               'study_time': '11:12:59',
                               'series_count': 3})

    def test_studies_series(self):
        req = requests.get(
            ROOT + 
            "/studies/"
            "1.3.6.1.4.1.14519.5.2.1.4792.1600.108467762757913801129608477056"
            "/series")
        obj = req.json()

        self.assertEqual(req.status_code, 200)
        self.assertEqual(obj, [
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
                            ])

    def test_series_root(self):
        req = requests.get(ROOT + "/series/")

        # listing is not not allowed on this endpoint
        self.assertEqual(req.status_code, 401)


    def test_series(self):
        req = requests.get(
            ROOT + 
            "/series/"
            "1.3.6.1.4.1.14519.5.2.1.4792.1600.751332489324940646100460626198"
        )
        obj = req.json()

        self.assertEqual(req.status_code, 200)
        self.assertEqual(obj, {'series_instance_uid': '1.3.6.1.4.1.14519.5.2.1.4792.1600.751332489324940646100460626198', 'series_date': 1200700800, 'series_time': '10:27:08', 'modality': 'CT', 'laterality': None, 'series_description': 'Scout', 'file_count': 2})


    def test_series_files(self):
        req = requests.get(
            ROOT + 
            "/series/"
            "1.3.6.1.4.1.14519.5.2.1.4792.1600.751332489324940646100460626198"
            "/files"
        )
        obj = req.json()

        self.assertEqual(req.status_code, 200)
        self.assertEqual(obj, [{'file_id': 1152289}, 
                               {'file_id': 1152288}])


    def test_files_root(self):
        req = requests.get(ROOT + "/files")

        # listing is not not allowed on this endpoint
        self.assertEqual(req.status_code, 401)


    def test_files(self):
        req = requests.get(
            ROOT +
            "/files/"
            "1152289"
        )
        obj = req.json()

        self.assertEqual(req.status_code, 200)
        self.assertEqual(obj, {'file_id': 1152289,
                               'digest': '6870a8d530182ac9d798897fff0a8620',
                               'size': 1345932,
                               'is_dicom_file': True,
                               'file_type': 'parsed dicom file',
                               'processing_priority': 1,
                               'ready_to_process': True})

    @unittest.skip("not done yet, yo")
    def test_files_data(self):
        req = requests.get(
            ROOT +
            "/files/"
            "1152289"
            "/data"
        )

        self.assertEqual(req.status_code, 200)

        md5 = hashlib.md5()
        md5.update(req.content)
        self.assertEqual(md5.hexdigest(), '6870a8d530182ac9d798897fff0a8620')


    @unittest.skip("not done yet, yo")
    def test_files_pixel_data(self):
        req = requests.get(
            ROOT +
            "/files/"
            "1152289"
            "/pixel_data"
        )

        self.assertEqual(req.status_code, 200)

        md5 = hashlib.md5()
        md5.update(req.content)
        self.assertEqual(md5.hexdigest(), '6870a8d530182ac9d798897fff0a8620')
