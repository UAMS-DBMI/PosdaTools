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
				   Redis


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

RUN adduser -D posda

COPY --chown=posda:posda posda-api/ /posda-api/
RUN pip3 install -r /posda-api/requirements.txt


# Work around issue with volume persmissions
RUN mkdir /home/posda/cache
RUN chown posda:posda /home/posda/cache
VOLUME ["/home/posda/cache"]

COPY docker-entrypoint /
COPY --chown=posda:posda posda.env /home/posda/posdatools/

WORKDIR /home/posda
ENV PYTHONPATH /home/posda/posdatools/python

# Copy actual posdatools last, to speed up rebuilds
COPY --chown=posda:posda posdatools /home/posda/posdatools

USER posda:posda
ENTRYPOINT ["/docker-entrypoint"]
CMD ["main"]

EXPOSE 64610-64700
