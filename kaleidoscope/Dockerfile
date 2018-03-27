FROM alpine:latest

RUN apk --update add alpine-sdk \
					 python3 \
					 postgresql-client \
					 python3-dev 

COPY kaleidoscope/server/ /app/
RUN pip3 install -r /app/requirements.txt

VOLUME ["/home/posda/cache"]

CMD ["python3", "/app/server.py"]
