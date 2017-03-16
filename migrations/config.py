environments = {
    "dev": {"hostname": "localhost"},
    "prod": {"hostname": "tcia-utilities"},
}

targets = [
    'posda_queries',
    'posda_files',
    'posda_auth',
    'posda_nicknames',
    'private_tag_kb',
    'dicom_roots',
]

t_env = {
    "dev": {
      "hostname": "localhost",
      "targets": {
        'posda_queries': 'posda_queries',
        'posda_files': 'posda_files',
        'posda_auth': 'posda_auth',
        'posda_nicknames': 'posda_nicknames',
        'private_tag_kb': 'private_tag_kb',
        'dicom_roots': 'dicom_roots',
      }
    },
    "prod": {
      "hostname": "tcia-utilities",
      "targets": {
        'posda_queries': 'posda_queries',
        'posda_files': 'posda_files',
        'posda_auth': 'posda_auth',
        'posda_nicknames': 'posda_nicknames',
        'private_tag_kb': 'private_tag_kb',
        'dicom_roots': 'dicom_roots',
      }
    },
    "prod2": {
      "hostname": "tcia-utilities",
      "targets": {
        'posda_queries': 'N_posda_queries',
        'posda_files': 'N_posda_files',
        'posda_auth': 'N_posda_auth',
        'posda_nicknames': 'N_posda_nicknames',
        'private_tag_kb': 'N_private_tag_kb',
        'dicom_roots': 'N_dicom_roots',
      }
    },
}
