FROM alpine:latest as builder
RUN apk --update add nodejs-npm make

COPY dashboard /dashboard
COPY quince /quince

RUN cd /dashboard && \
    make

RUN cd /quince && \
	make


FROM nginx:1.13.10-alpine

COPY default.conf /etc/nginx/conf.d/
COPY www /www


COPY --from=builder /dashboard/dist/posda-dashboard /www/dashboard
COPY --from=builder /quince/dist /www/quince

EXPOSE 80
