FROM nginx:1.13.10-alpine

COPY default.conf /etc/nginx/conf.d/
COPY www /www

COPY quince/dist/ /quince/
COPY kaleidoscope/dist/ /kaleidoscope/
