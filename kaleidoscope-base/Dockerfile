# k-base

FROM alpine:latest

# Base system deps
RUN apk --update add alpine-sdk \
					 wget \
					 openssl-dev \
					 bash \
					 nodejs-npm \
					 cairo-dev \
					 postgresql-client \
					 file \
					 tzdata

COPY k-base/ /k-base/
RUN cd /k-base && npm install && make

VOLUME ["/home/posda/cache"]

CMD ["/k-base/run.sh"]
