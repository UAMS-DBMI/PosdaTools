FROM alpine:3.17 as builder
RUN apk --update add alpine-sdk tar make xz \
	libpng libjpeg openjpeg-dev \
	bzip2-dev \
	xz-dev \
	zlib-dev \
	tiff-dev \
	libpng-dev \
	libjpeg-turbo-dev

COPY ImageMagick-7.0.8-49.tar.gz /
COPY dcm_add_force_unsigned.patch /

RUN cd / \
 && tar xf /ImageMagick-7.0.8-49.tar.gz \
 && cd /ImageMagick-7.0.8-49 \
 && patch -p1 -i /dcm_add_force_unsigned.patch \
 && ./configure --prefix=/opt/im \
 && make -j 16 \
 && make install


FROM alpine:3.17
RUN apk --update add \
	imagemagick \
	xz-libs \
	openjpeg \
	libgomp \
	libgcc \
	python3 \
	py3-pip \
	redis \
	openjdk8-jre-base \
    py3-psycopg2

COPY --from=builder /opt/im /opt/im
COPY dcm4che-5.22.1-bin.zip /
RUN unzip /dcm4che-5.22.1-bin.zip -d /opt && rm -f /dcm4che-5.22.1-bin.zip

ENV PATH="/opt/im/bin:/opt/dcm4che-5.22.1/bin:${PATH}"

COPY requirements.txt /
RUN pip3 install -r /requirements.txt

COPY *.py /scripts/

# FROM node-builder as quince-builder
# COPY quince /quince
# RUN cd /quince && \
# 	make


# FROM nginx:1.13.10-alpine

# COPY default.conf /etc/nginx/conf.d/
# COPY www /www


# COPY --from=dashboard-builder /dashboard/dist/posda-dashboard /www/dashboard
# COPY --from=quince-builder /quince/dist /www/quince

# EXPOSE 80
