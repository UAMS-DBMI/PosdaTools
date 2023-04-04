# k-base

FROM alpine:3.8

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

RUN addgroup -g 2123 fakeposda
RUN adduser -D -G fakeposda posda

COPY --chown=posda:fakeposda k-base/ /k-base/
COPY --chown=posda:fakeposda run.sh /k-base/
RUN cd /k-base && npm install && make


WORKDIR /k-base
USER posda:fakeposda
VOLUME ["/home/posda/cache"]

CMD ["/k-base/run.sh"]
