FROM alpine:latest

RUN apk --update add alpine-sdk \
					 python3 \
					 postgresql-client \
					 python3-dev  \
					 nodejs \
					 npm

COPY kaleidoscope/ /app/
RUN pip3 install -r /app/server/requirements.txt
RUN cd /app && make

COPY run.sh /

VOLUME ["/home/posda/cache", "/html"]

CMD ["/run.sh"]
