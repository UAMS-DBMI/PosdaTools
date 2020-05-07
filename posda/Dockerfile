###############################################################################
# Build Dicom 3 tools
###############################################################################
FROM alpine:3.11.3 as d3tbuild

RUN apk add --update --no-cache \
	imake \
	makedepend \
	alpine-sdk \
	coreutils \
	tar \
	gzip \
	bzip2

RUN mkdir /build
RUN wget -O /build/tools.tar.bz2 \
  http://www.dclunie.com/dicom3tools/workinprogress/dicom3tools_1.00.snapshot.20191225060430.tar.bz2
RUN cd /build && \
	tar xf tools.tar.bz2 && \
	cd dicom3tools_1.00.snapshot.20191225060430 && \
	./Configure && \
	imake -I./config && \
	make -j 16 World && \
	make -j 16 && \
	make install

###############################################################################
# Build GDCM (Grassroots DICOM)
###############################################################################
FROM alpine:3.11.3 as gdcmbuild

# Placed here to cache it early
RUN mkdir -p /build/build
RUN wget -O /build/master.zip https://github.com/malaterre/GDCM/archive/master.zip
RUN unzip -d /build /build/master.zip

RUN apk add --update --no-cache \
	cmake \
	python3 \
	python3-dev \
	swig \
	imake \
	makedepend \
	alpine-sdk \
	coreutils \
	tar \
	gzip \
	bzip2

RUN cd /build/build && \
	cmake -DGDCM_BUILD_APPLICATIONS=ON \
		  -DGDCM_USE_SYSTEM_OPENJPEG=OFF \
		  -DGDCM_WRAP_PYTHON=ON \
		  -DPYTHON_EXECUTABLE=/usr/bin/python3 \
		  -DGDCM_BUILD_SHARED_LIBS=ON \
		  ../GDCM-master && \
	make -j 16 && \
	make install

###############################################################################
# Build Openslide (no package for alpine exists :( )
###############################################################################
FROM alpine:3.11.3 as osbuild

ARG OPENSLIDE_VERSION=3.4.1
ARG OPENSLIDE_URL=https://github.com/openslide/openslide/releases/download

RUN apk add --update \
	alpine-sdk \
	wget \
	zlib-dev \
	libxml2-dev \
	jpeg-dev \
	openjpeg-dev \
	tiff-dev \
	glib-dev \
	gdk-pixbuf-dev \
	sqlite-dev \
	libjpeg-turbo-dev \
	libexif-dev \
	lcms2-dev \
	fftw-dev \
	giflib-dev \
	libpng-dev \
	libwebp-dev \
	orc-dev \
	poppler-dev \
	librsvg-dev \
	libgsf-dev \
	openexr-dev

WORKDIR /usr/local/src

RUN wget ${OPENSLIDE_URL}/v${OPENSLIDE_VERSION}/openslide-${OPENSLIDE_VERSION}.tar.gz \
	&& tar xf openslide-${OPENSLIDE_VERSION}.tar.gz \
    && cd openslide-${OPENSLIDE_VERSION} \
	&& ./configure \
	&& make \
	&& make install


###############################################################################
# Build Final Image
###############################################################################
FROM alpine:3.11.3

# Base system deps
RUN apk --update add alpine-sdk \
					 vim \
					 perl \
					 perl-utils \
					 perl-dev \
					 wget \
					 openssl-dev \
					 bash \
					 python3 \
					 python3-dev \
					 cairo-dev \
					 postgresql-client \
					 file \
					 tzdata \
					 unzip \
					 py3-psycopg2 \
					 py3-numpy \
					 py3-pillow \
					 redis \
					 procps

# Perl modules from Alpine repos
RUN apk --update add perl-json \
					 perl-data-uuid \
					 perl-dbd-pg \
					 perl-dbd-mysql \
					 perl-switch \
					 perl-term-readkey \
					 perl-text-csv \
					 perl-regexp-common \
					 perl-try-tiny \
					 perl-ldap \
					 perl-datetime \
					 perl-file-slurp

# # Perl modules that are not in system repositories
RUN cpan App::cpanminus
RUN cpanm --notest REST::Client \
				   Time::Piece \
				   Text::Markdown \
				   Modern::Perl \
				   Method::Signatures::Simple \
				   K/KE/KEN/xls2csv-1.07.tar.gz \
				   Redis \
				   HTTP::Request::StreamingUpload


# Install needed python utils
RUN pip3 install xlsx2csv mysql-connector python-box pydicom

RUN addgroup -g 2123 fakeposda
RUN adduser -D -G fakeposda posda

COPY --chown=posda:fakeposda fastapi/app /fastapi/
COPY --chown=posda:fakeposda fastapi/start_api.sh /
RUN pip3 install -r /fastapi/requirements.txt

# Work around issue with volume persmissions
RUN mkdir /home/posda/cache
RUN chown posda:fakeposda /home/posda/cache
VOLUME ["/home/posda/cache"]

COPY docker-entrypoint /
COPY --chown=posda:fakeposda posda.env /home/posda/posdatools/

WORKDIR /home/posda
ENV PYTHONPATH /home/posda/posdatools/python

COPY --from=d3tbuild /usr/local/bin/* /usr/local/bin/

# Copy GDCM into place
COPY --from=gdcmbuild /usr/local/lib/*.py /usr/lib/python3.8/site-packages/
COPY --from=gdcmbuild /usr/local/lib/_gdcmswig.so /usr/lib/python3.8/site-packages/
COPY --from=gdcmbuild /usr/local/bin/* /usr/local/bin/
COPY --from=gdcmbuild /usr/local/lib/* /usr/local/lib/

# copy openslide into place
COPY --from=osbuild /usr/local/bin/* /usr/local/bin/
COPY --from=osbuild /usr/local/lib/* /usr/local/lib/
COPY --from=osbuild /usr/local/include/* /usr/local/include/
# extra packages needed for openslide
RUN apk add gdk-pixbuf openjpeg

# Extra python libs
RUN pip3 install pandas openslide-python


# Copy actual posdatools last, to speed up rebuilds
COPY --chown=posda:fakeposda posdatools /home/posda/posdatools

# TODO: move this up
RUN apk add --update docker-cli

# Allow the posda user to use docker, with sudo
# TODO: This needs to be adjusted to only allow running docker!
RUN echo "%fakeposda ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers



USER posda:fakeposda
ENTRYPOINT ["/docker-entrypoint"]
CMD ["main"]

EXPOSE 64610-64700
