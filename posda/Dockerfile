###############################################################################
# Build Dicom 3 tools
###############################################################################
FROM buildpack-deps:bullseye as d3tbuild

RUN apt-get update && apt-get install -y \
	xutils-dev

RUN mkdir /build
RUN wget -O /build/tools.tar.bz2 \
	https://www.dclunie.com/dicom3tools/workinprogress/dicom3tools_1.00.snapshot.20220618093127.tar.bz2

RUN cd /build && \
	tar xf tools.tar.bz2 && \
	cd dicom3tools* && \
	./Configure && \
	imake -I./config && \
	make -j $(nproc) World && \
	make -j $(nproc) && \
	make install

################################################################################
## Build dcm2niix (for covnerting to nifti)
################################################################################

FROM buildpack-deps:bullseye as dcm2niixbuild

RUN apt-get update && apt-get install -y \
	cmake \
	git

RUN git clone https://github.com/rordenlab/dcm2niix.git
RUN cd dcm2niix && \
	mkdir build && \
	cd build && \
	cmake -DUSE_JPEGLS=ON .. && \
	make

################################################################################
################################################################################
################################################################################
## the real container starts here
################################################################################
################################################################################
################################################################################
################################################################################
FROM debian:bullseye

RUN apt-get update && apt-get install -y \
	libgdcm-tools



# Base system deps

RUN apt-get update && apt-get install -y \
	time \
	file \
	vim \
	libperl-dev \
	wget \
	libssl-dev \
	python3 \
	python3-dev \
	python3-cairo-dev \
	libcairo2-dev \
	postgresql-client \
	file \
	tzdata \
	unzip \
	python3-pip \
	python3-psycopg2 \
	python3-numpy \
	redis-tools \
	procps \
	rclone \
	less


# Perl modules from repos
RUN apt-get update && apt-get install -y \
	libdata-uuid-perl \
	libdbd-pg-perl \
	libdbd-mysql-perl \
	libswitch-perl \
	libterm-readkey-perl \
	libtext-csv-perl \
	libtext-csv-xs-perl \
	libregexp-common-perl \
	libtry-tiny-perl \
	libnet-ldap-perl \
	libdatetime-perl \
	libfile-slurp-perl \
	libunicode-map-perl \
	librest-client-perl \
	libtext-markdown-perl \
	libmodern-perl-perl \
	libredis-perl \
	libjson-perl \
	libtext-diff-perl \
	cpanminus



# Perl modules that are not in system repositories
RUN cpanm --notest \
				   K/KE/KEN/xls2csv-1.07.tar.gz \
				   HTTP::Request::StreamingUpload


# Install needed python utils
RUN pip3 install xlsx2csv mysql-connector python-box pydicom redis tifffile imagecodecs openslide-python


RUN addgroup --gid 2123 fakeposda
RUN adduser --system --ingroup fakeposda --uid 1000 posda

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

# copy dcm2niix into place
COPY --from=dcm2niixbuild /dcm2niix/build/bin/dcm2niix /usr/local/bin/dcm2niix

## Add Imagemagick
RUN apt-get update && apt-get install -y \
	imagemagick \
	libjpeg-dev
RUN pip3 install Pillow

RUN apt-get clean && \
	rm -rf /var/lib/{apt,dpkg,cache,log}/

# Copy actual posdatools last, to speed up rebuilds
COPY --chown=posda:fakeposda posdatools /home/posda/posdatools

USER posda:fakeposda
ENTRYPOINT ["/docker-entrypoint"]
CMD ["main"]
