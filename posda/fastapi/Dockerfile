FROM python:3.10

COPY ./app/requirements.txt /
RUN pip install -r /requirements.txt

COPY start_api.sh /
COPY ./app /app

WORKDIR /app
CMD ["/start_api.sh"]
