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
