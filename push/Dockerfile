FROM python:3-alpine

COPY ./requirements.txt /

RUN pip install --break-system-packages -r /requirements.txt

COPY ./push.py /

CMD "/push.py"
