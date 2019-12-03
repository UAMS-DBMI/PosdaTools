FROM python:3.7

COPY ./app/requirements.txt /
RUN pip install -r /requirements.txt

COPY start.sh /
COPY ./app /app

WORKDIR /app
CMD ["/start.sh"]
