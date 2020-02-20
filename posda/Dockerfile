FROM alpine:latest as d3tbuild

RUN apk add --update --no-cache \
	imake \
	makedepend \
	alpine-sdk \
	coreutils \
	tar \
	gzip \
	bzip2

RUN mkdir /build
RUN wget -O /build/tools.tar.bz2 https://www.dclunie.com/dicom3tools/workinprogress/dicom3tools_1.00.snapshot.20190724083540.tar.bz2
RUN cd /build && \
	tar xf tools.tar.bz2 && \
	cd dicom3tools_1.00.snapshot.20190724083540 && \
	./Configure && \
	imake -I./config && \
	make World && \
	make && \
	make install

FROM alpine:latest

# Base system deps
RUN apk --update add alpine-sdk \
					 vim \
					 perl \
					 perl-utils \
					 perl-dev \
					 wget \
					 openssl-dev \
					 bash \
					 python \
					 python3 \
					 python3-dev \
					 py2-pip \
					 cairo-dev \
					 postgresql-client \
					 file \
					 tzdata \
					 unzip \
					 py3-psycopg2 \
					 py3-numpy \
					 cmake \
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


# Swig is needed to build python wrapper for GDCM
RUN apk --update add swig

# Build GDCM tools
RUN mkdir -p /build/build
RUN wget -O /build/master.zip https://github.com/malaterre/GDCM/archive/master.zip
RUN unzip -d /build /build/master.zip
RUN cd /build/build && \
	cmake -DGDCM_BUILD_APPLICATIONS=ON -DGDCM_USE_SYSTEM_OPENJPEG=OFF -DGDCM_WRAP_PYTHON=ON -DPYTHON_EXECUTABLE=/usr/bin/python3 -DGDCM_BUILD_SHARED_LIBS=ON ../GDCM-master && \
	make -j 16 && \
	make install

# The GDCM make install does not put the generated python files
# in the right place. Move them there
RUN cp /usr/local/lib/*.py /usr/lib/python3.6/site-packages/ && \
	cp /usr/local/lib/_gdcmswig.so /usr/lib/python3.6/site-packages/

# Install needed python utils
RUN pip3 install xlsx2csv mysql-connector python-box pydicom

RUN addgroup -g 2123 fakeposda
RUN adduser -D -G fakeposda posda

# COPY --chown=posda:fakeposda posda-api/ /posda-api/
# RUN pip3 install -r /posda-api/requirements.frozen.txt

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

# Copy actual posdatools last, to speed up rebuilds
COPY --chown=posda:fakeposda posdatools /home/posda/posdatools

COPY --from=d3tbuild /usr/local/bin/* /usr/local/bin/

USER posda:fakeposda
ENTRYPOINT ["/docker-entrypoint"]
CMD ["main"]

EXPOSE 64610-64700
