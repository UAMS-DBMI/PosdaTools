#!/usr/bin/env bash

echoerr() { echo "$@" 1>&2; }

POSDA_ROOT=/home/posda/posdatools

#PERL5LIB=$POSDA_ROOT/Posda/include $POSDA_ROOT/Posda/bin/DumpDicom.pl $1
PATH=$PATH:$POSDA_ROOT/Posda/bin


echoerr "Dumping file $1"
PERL5LIB=$POSDA_ROOT/Posda/include $POSDA_ROOT/Posda/bin/contrib/IheDumpFile.pl $1
