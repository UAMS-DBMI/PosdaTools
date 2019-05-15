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


FROM nginx:1.13.10-alpine

COPY default.conf /etc/nginx/conf.d/
COPY www /www


COPY --from=dashboard-builder /dashboard/dist/posda-dashboard /www/dashboard
COPY --from=quince-builder /quince/dist /www/quince

EXPOSE 80
