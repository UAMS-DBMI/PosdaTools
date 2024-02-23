#!/usr/bin/python3 -u

import os
import subprocess
import pathlib
import psycopg2
import psycopg2.extras
import boto3
from boto3.session import Session, Config
from botocore.exceptions import ClientError
import requests
import logging
import signal

logging.basicConfig(level=logging.INFO)

FS_BASE = pathlib.Path(
    os.environ.get('NBIA_STORAGE_ROOT',
                   '/home/posda/storage-from-posda'))

ROSS_BASE = pathlib.Path(
    os.environ.get('DCM4CHEE_ROOT',
                   'tcia/storage-posda'))

ROSS_BUCKET = os.environ.get('DCM4CHEE_BUCKET',
                             'dicom')

COUNT=os.environ.get('DCM4CHEE_COUNT',
                     5)

S3_URL=os.environ.get('DCM4CHEE_S3_URL',
                     'http://s3.ross.hpc.uams.edu:9020')

S3_ACCESS_KEY_ID=os.environ.get('DCM4CHEE_S3_ACCESS_KEY_ID',
                                'none')
S3_SECRET_KEY=os.environ.get('DCM4CHEE_S3_SECRET_KEY',
                             'none')

DCM4CHEE_CLIENT_ID=os.environ.get('DCM4CHEE_CLIENT_ID',
                                 'none')
DCM4CHEE_CLIENT_SECRET=os.environ.get('DCM4CHEE_CLIENT_SECRET',
                                     'none')
DCM4CHEE_LOGIN_URL=os.environ.get(
    'DCM4CHEE_LOGIN_URL',
    'https://keycloak.dbmi.cloud/auth/realms/dcm4che/protocol/openid-connect/token'
)
DCM4CHEE_SUBMIT_URL=os.environ.get(
    'DCM4CHEE_SUBMIT_URL',
    'https://dicom.cancerimagingarchive.net/dcm4chee-arc/aets/DCM4CHEE/rs/instances/storage/ross1'
)


S3_CLIENT = None
EXIT_SOON=False

def handle_sigint(sig, frame):
    global EXIT_SOON
    print('Shutting down after this batch...')
    EXIT_SOON = True


def connect_to_s3():
    logging.info("Connecting to S3 endpoint...")
    session = Session(aws_access_key_id=S3_ACCESS_KEY_ID,
                      aws_secret_access_key=S3_SECRET_KEY)

    s3 = session.client('s3', endpoint_url=S3_URL, verify=False,
                          config=Config(signature_version='s3v4',
                                        s3={'addressing_style': 'path'}))

    return s3


def login_to_dcm4chee():
    logging.info("Logging into dcm4chee server/Keycloak to get token...")
    data = {
        'grant_type': 'client_credentials',
        'client_id': DCM4CHEE_CLIENT_ID,
        'client_secret': DCM4CHEE_CLIENT_SECRET,
    }

    response = requests.post(
        DCM4CHEE_LOGIN_URL,
        data=data,
        # verify=False,
    )

    response.raise_for_status()

    return response.json()['access_token']

def send_payload(token, payload):
    headers = {
        'Authorization': 'Bearer ' + token,
        'Content-Type': 'text/plain',
    }

    response = requests.post(
        DCM4CHEE_SUBMIT_URL,
        headers=headers,
        data=payload,
    )

    response.raise_for_status()
    return response

def main():
    global S3_CLIENT

    logging.debug("starting up")

    token = login_to_dcm4chee()
    logging.debug(token)

    S3_CLIENT = connect_to_s3()
    logging.debug("connected to s3")

    conn = psycopg2.connect(dbname="posda_files")
    conn.autocommit = False

    while not EXIT_SOON:
        with conn:
            cur = conn.cursor(cursor_factory = psycopg2.extras.RealDictCursor)
            cur.execute(f"""\
                update dcm4chee_copy
                set processed = true
                where (subprocess_invocation_id, file_id) in (
                    select
                        subprocess_invocation_id,
                        file_id
                    from
                        dcm4chee_copy
                    where processed = false
                    for update skip locked
                    limit {COUNT}
                )
                returning *
            """)
            logging.debug(f"query ran successfully, with limit={COUNT}")

            # process in batches
            batch = [row for row in cur]
            process(batch, token)

            conn.commit()


def copy_into_place(item):
    src_path = item['src_path']

    bucket = ROSS_BUCKET
    filename = src_path
    object_name = str(ROSS_BASE / item['rel_path'])

    logging.info(f"sending {filename} to {bucket}:{object_name}")

    try:
        res = S3_CLIENT.upload_file(filename, bucket, object_name)
    except ClientError as e:
        print(e)
        return

def submit_to_dcm4che(batch_d, token):
    payload = '\n'.join([str(i['pay_path']) for i in batch_d])
    logging.debug(f"created payload, length is {len(payload)}")

    resp = send_payload(token, payload)
    logging.info("Payload sent successfully")

def process(batch, token):
    logging.debug("beginning processing on batch")

    for item in batch:
        item['src_path'] = FS_BASE / item['rel_path']
        item['pay_path'] = ROSS_BASE / item['rel_path']
        copy_into_place(item)

    submit_to_dcm4che(batch, token)


if __name__ == '__main__':
    # setup SIGINT capture so we don't die in the middle of things
    signal.signal(signal.SIGINT, handle_sigint)
    main()
