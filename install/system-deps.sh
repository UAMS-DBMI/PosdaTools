#!/bin/bash
#
# Install system deps
#

BASE_DEPS="
	vim
	perl
	perl-devel
	openssl-devel
	python3
	python3-devel
	unzip
	python3-psycopg2
	python36-numpy
	redis
	nginx
"

PERL_DEPS="
	perl-JSON
	perl-JSON-PP
	perl-JSON-XS
	perl-Data-UUID
	perl-DBD-Pg
	perl-DBD-MySQL
	perl-Switch
	perl-TermReadKey
	perl-Text-CSV
	perl-Regexp-Common
	perl-Try-Tiny
	perl-LDAP
	perl-DateTime
	perl-File-Slurp
	perl-REST-Client
	perl-Time-Piece
	perl-Text-Markdown
	perl-Modern-Perl
	perl-Redis
	perl-autodie
	perl-Env
	perl-App-cpanminus
"

yum install -y $BASE_DEPS
yum install -y $PERL_DEPS
yum groupinstall -y "Development Tools"

# Postgresql 13

# enabled Software Collections - different on RHEL vs CentOS
# CentOS
yum install -y centos-release-scl

# RHEL 7
#yum-config-manager --enable rhel-server-rhscl-7-rpms

# install postgresql13
# yum install -y rh-postgresql13 rh-postgresql13-server
yum install -y rh-python38


