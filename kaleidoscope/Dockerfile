FROM alpine:3.8

RUN apk --update add alpine-sdk \
					 python3 \
					 postgresql-client \
					 python3-dev  \
					 nodejs \
					 npm

COPY kaleidoscope/ /app/
RUN pip3 install -r /app/server/requirements.txt
RUN cd /app && make

COPY docker-entrypoint /

VOLUME ["/home/posda/cache", "/html"]

CMD ["/docker-entrypoint"]
