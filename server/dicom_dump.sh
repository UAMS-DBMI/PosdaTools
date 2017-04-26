#!/usr/bin/env bash

POSDA_ROOT=/home/posda/PosdaTools

PERL5LIB=$POSDA_ROOT/Posda/include $POSDA_ROOT/Posda/bin/DumpDicom.pl $1
