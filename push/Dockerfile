FROM debian:12

RUN apt-get update \
 && apt-get install -y \
    python3 \
    python3-pip \
 	rclone \
 && apt-get clean \
 && rm -rf /var/lib/apt/lists/*


COPY ./requirements.txt /

RUN pip install --break-system-packages -r /requirements.txt

COPY ./push.py /

CMD "/push.py"
