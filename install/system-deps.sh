#!/bin/bash
#
# Install system deps
#

BASE_DEPS="
	vim
	perl
	perl-devel
	openssl-devel
	python39
	python39-devel
	unzip
	python39-psycopg2
	python39-numpy
	redis
	nginx
"

PERL_DEPS="
	perl-JSON
	perl-JSON-PP
	perl-DBD-Pg
	perl-DBD-MySQL
	perl-TermReadKey
	perl-Try-Tiny
	perl-LDAP
	perl-File-Slurp
	perl-Time-Piece
	perl-autodie
	perl-Env
	perl-App-cpanminus
"

yum module enable -y python39

yum install -y $BASE_DEPS
yum install -y $PERL_DEPS
yum groupinstall -y "Development Tools"
