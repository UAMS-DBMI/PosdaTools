# posda-api

FROM alpine:latest

RUN apk --update add alpine-sdk \
					 python3 \
					 python3-dev \
					 postgresql-client

COPY posda-api/ /app/
RUN pip3 install -r /app/requirements.txt

CMD ["python3", "/app/api-server.py"]
