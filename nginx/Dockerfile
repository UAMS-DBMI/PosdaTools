FROM nginx:1.13.10-alpine

RUN apk --update add nodejs-npm make

COPY dashboard /dashboard
COPY default.conf /etc/nginx/conf.d/
COPY www /www

RUN cd /dashboard && \
    make

RUN cp -r /dashboard/dist/posda-dashboard /www/dashboard

VOLUME ["/quince/", "/kaleidoscope/"]
