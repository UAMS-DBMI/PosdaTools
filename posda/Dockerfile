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
	http://www.dclunie.com/dicom3tools/workinprogress/dicom3tools_1.00.snapshot.20200727055401.tar.bz2
RUN cd /build && \
	tar xf tools.tar.bz2 && \
	cd dicom3tools_1.00.snapshot.20200727055401 && \
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

# Copy actual posdatools last, to speed up rebuilds
COPY --chown=posda:fakeposda posdatools /home/posda/posdatools

USER posda:fakeposda
ENTRYPOINT ["/docker-entrypoint"]
CMD ["main"]

EXPOSE 64610-64700
