FROM alpine:latest as node-builder
RUN apk --update add nodejs-npm make

FROM node-builder as dashboard-builder

COPY dashboard /dashboard

RUN cd /dashboard && \
    make


FROM node-builder as quince-builder
COPY quince /quince
RUN cd /quince && \
	make

FROM node:current-alpine as roots-builder
RUN apk --update add make
COPY dicom-root /roots
RUN cd /roots && \
	make

FROM node:current-alpine as kohlrabi-builder
RUN apk --update add make
COPY Kohlrabi /kohlrabi
RUN cd /kohlrabi && \
  make

#FROM nginx:1.13.10-alpine
FROM bitnami/nginx:1.21

COPY default.conf /opt/bitnami/nginx/conf/server_blocks/
COPY www /www


COPY --from=dashboard-builder /dashboard/dist/posda-dashboard /www/dashboard
COPY --from=quince-builder /quince/dist /www/quince
COPY --from=roots-builder /roots/dist/dicom-root /www/roots
COPY --from=kohlrabi-builder /kohlrabi/build /www/kohlrabi
