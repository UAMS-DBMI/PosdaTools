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
					 unzip

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
				   K/KE/KEN/xls2csv-1.07.tar.gz

RUN mkdir /home/posda

RUN pip3 install xlsx2csv

# # # Install Quince
# RUN mkdir -p /quince && mkdir -p /root/quince/server && chown nginx:nginx /quince
# COPY --chown=nginx:nginx quince/dist/ /quince/
# COPY quince/server /root/quince/server
# RUN pip3 install -r /root/quince/server/requirements.txt

# # # Install Kaleidoscope
# RUN mkdir -p /kaleidoscope && mkdir -p /root/kaleidoscope/server && chown nginx:nginx /kaleidoscope
# COPY --chown=nginx:nginx kaleidoscope/dist/ /kaleidoscope/
# COPY kaleidoscope/server /root/kaleidoscope/server
# RUN pip3 install -r /root/kaleidoscope/server/requirements.txt

# # # Install k-base
# RUN mkdir -p /k-base && mkdir -p /home/posda/cache/k-storage
# COPY kaleidoscope-base/ /k-base/
# RUN cd /k-base && npm install && make

COPY posdatools /home/posda/posdatools

WORKDIR /home/posda
VOLUME ["/home/posda/cache"]
COPY docker-entrypoint /
COPY posda.env /home/posda/posdatools/

ENTRYPOINT ["/docker-entrypoint"]
CMD ["main"]

EXPOSE 64610-64700
