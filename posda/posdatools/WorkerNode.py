#!/usr/bin/python3 -u
"""
Posda Worker Node management program.

This program interfaces with the Posda API and Redis queue
in order to accept work items and process them.

It must have access to the shared storage and configuration of
the main Posda installation, and it must be able to connect directly
to the Redis instance, as well as the api.

Those settings are read from the environment variables:
    * POSDA_INTERNAL_API_URL
    * POSDA_REDIS_HOST
    * POSDA_WORKER_PRIORITY
    * POSDA_WORKER_NAME

"""
import redis
import requests
import subprocess
import tempfile
import hashlib
import platform
import logging

from posda.config import Config
import posda.logging.autoconfig

BASE_URL = None   # the base of the Posda API, as accessible from this node
NODE_NAME = None  # the name of this node reported in the work table


def main():
    global BASE_URL
    global NODE_NAME

    logging.info("worker node started")

    api_url = Config.get('internal-api-url')
    redis_host = Config.get('redis-host', default='redis')
    worker_priority = Config.get('worker-priority', default=0)
    NODE_NAME = Config.get('worker-name', default=platform.node())

    logging.info("configuration loaded: %s",
                 {
                     "api_url": api_url,
                     "redis_host": redis_host,
                     "worker_priority": worker_priority,
                     "NODE_NAME": NODE_NAME
                 })

    redis_db = redis.StrictRedis(host=redis_host, db=0, decode_responses=True)
    logging.info("connected to redis")

    BASE_URL = f"{api_url}/v1"

    work_loop(redis_db, worker_priority)


def work_loop(redis_db, priority):
    """Continually wait for new work items, and process them"""

    queue_name = f"work_queue_{priority}"

    while True:
        sr = redis_db.brpop(keys=queue_name, timeout=5)
        if sr is None:
            # if the timeout is reached, sr will be None
            continue

        _, work_id = sr

        try:
            process_work_item(work_id)
        except Exception as e:
            logging.error(e)
            set_status_errored(work_id, None, None)


def process_work_item(work_id: int):
    """Process a single work item.

    For the given work_id:
        * set the status to running
        * get the details of the work item, and subprocess invocation
        * generate the command_line and execute it
        * record stderr and stdout, upload to posda
        * set the status to finished or failure, depending on return code
    """
    logging.info(f'new work item {work_id}')

    set_status_running(work_id)
    work_item = get_work_item(work_id)
    subp = get_subprocess_info(work_item['subprocess_invocation_id'])

    command_line = subp['command_line'].replace(
        "<?bkgrnd_id?>", str(subp['subprocess_invocation_id']))
    logging.debug(command_line)

    stdout_fp = tempfile.TemporaryFile()
    stderr_fp = tempfile.TemporaryFile()

    stdin_path = get_path_from_file_id(work_item['input_file_id'])
    stdin_fp = open(stdin_path)

    return_code = subprocess.Popen(command_line,
                                   shell=True,
                                   stdin=stdin_fp,
                                   stdout=stdout_fp,
                                   stderr=stderr_fp).wait()

    logging.info(f'Subprocess returned: {return_code}')

    stdin_fp.close()

    stdout_file_id = upload_file(stdout_fp)
    stderr_file_id = upload_file(stderr_fp)

    logging.info(f'stdout:{stdout_file_id} stderr:{stderr_file_id}')

    stdout_fp.close()
    stderr_fp.close()

    if return_code != 0:
        set_status_errored(work_id, stderr_file_id, stdout_file_id)
    else:
        set_status_finished(work_id, stderr_file_id, stdout_file_id)


def set_status_finished(work_id: int,
                        stderr_file_id: int,
                        stdout_file_id: int) -> None:
    """Set the status of the work item to finished

    If provided, set the stderr and stdout files as well
    """
    set_status_x("finished", work_id, stderr_file_id, stdout_file_id)


def set_status_errored(work_id: int,
                       stderr_file_id: int,
                       stdout_file_id: int) -> None:
    """Set the status of the work item to errored

    If provided, set the stderr and stdout files as well
    """
    set_status_x("errored", work_id, stderr_file_id, stdout_file_id)


def set_status_x(status: str,
                 work_id: int,
                 stderr_file_id: int,
                 stdout_file_id: int) -> None:
    req = requests.post(
        f'{BASE_URL}/worker/status/{work_id}/{status}',
        json={
            'stderr_file_id': stderr_file_id,
            'stdout_file_id': stdout_file_id
        }
    )

    if req.status_code != 200:
        raise RuntimeError(req.content)


def get_subprocess_info(subprocess_invocation_id: int) -> dict:
    req = requests.get(
        f'{BASE_URL}/worker/subprocess/{subprocess_invocation_id}')
    if req.status_code != 200:
        logging.error(f'Subprocess info returned: {req.status_code}')
        raise RuntimeError(f'Subprocess info returned: {req.status_code}')

    subp = req.json()

    # because the API does not currectly return 404 when a
    # subprocess_invocation_id is invalid, duplicate the error here if we
    # get back []
    if subp == []:
        raise RuntimeError(
            f"No such subprocess_invocation_id: {subprocess_invocation_id}")

    logging.debug(subp)

    return subp


def get_path_from_file_id(file_id: int) -> str:
    req = requests.get(f'{BASE_URL}/files/{file_id}/path')
    if req.status_code != 200:
        logging.error(f'Filepath returned: {req.status_code}')
        raise RuntimeError(f'Filepath returned: {req.status_code}')

    obj = req.json()
    logging.debug(obj)

    # because the API does not currectly return 404 when a file_id
    # is invalid, duplicate the error here if we get back []
    if obj == []:
        raise RuntimeError(f"No such file_id: {file_id}")

    return obj['file_path']


def set_status_running(work_id: int) -> None:
    req = requests.post(f'{BASE_URL}/worker/status/{work_id}/running',
                        json={"node_hostname": NODE_NAME})
    logging.debug(f'changed status to running: {work_id}')

    if req.status_code != 200:
        raise RuntimeError(req.content)


def get_work_item(work_id: int) -> object:
    req = requests.get(f'{BASE_URL}/worker/status/{work_id}')
    if req.status_code != 200:
        logging.error(f'Work item status returned: {req.status_code}')
        raise RuntimeError(f'Work item status returned: {req.status_code}')

    work_item = req.json()
    # because the API does not currectly return 404 when a work_id is invalid,
    # duplicate the error here if we get back []
    if work_item == []:
        raise RuntimeError(f"No such work_id: {work_id}")
    logging.debug(work_item)

    return work_item


def md5sum(fp):
    fp.seek(0)
    hash_md5 = hashlib.md5()
    for chunk in iter(lambda: fp.read(4096), b""):
        hash_md5.update(chunk)
    return hash_md5.hexdigest()


def upload_file(fp):
    digest = md5sum(fp)
    fp.seek(0)
    params = {'digest': digest}
    resp = requests.put(f'{BASE_URL}/import/file', params=params, data=fp)
    if resp.status_code != 200:
        logging.error(f'File uploading failed: {resp.status_code}')
        raise Exception("File upload failed")
    return resp.json()['file_id']


def test():
    """Some tests of this module, you should probably ignore this"""

    global BASE_URL
    global NODE_NAME

    # NODE_NAME = platform.node()
    NODE_NAME = "test-node-quasar2"

    # logging.basicConfig(level=logging.DEBUG)

    logging.info("testing")

    # api_url = "http://tcia-posda-rh-1.ad.uams.edu/papi"
    api_url = "http://localhost/papi"
    BASE_URL = api_url + "/v1"

    logging.info(BASE_URL)

    set_status_running(2)
    work_item = get_work_item(2)
    subp = get_subprocess_info(work_item['subprocess_invocation_id'])
    p = get_path_from_file_id(67)

    try:
        process_work_item(2)
    except Exception as e:
        logging.error(e)
        set_status_errored(2, None, None)


if __name__ == "__main__":
    main()
    # test()