FROM alpine:latest

RUN apk --update add alpine-sdk \
					 python3 \
					 postgresql-client \
					 python3-dev  \
					 nodejs	\
					 npm

COPY quince/ /app/
RUN pip3 install -r /app/server/requirements.txt
RUN cd /app && make

VOLUME ["/home/posda/cache", "/html"]

CMD ["python3", "/app/server/server.py"]
