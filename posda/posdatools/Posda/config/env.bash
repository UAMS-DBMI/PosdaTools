#
#Copyright 2010, Bill Bennett
# Part of the Posda package
# Posda may be copied only under the terms of either the Artistic License or the
# GNU General Public License, which may be found in the Posda Distribution,
# or at http://posda.com/License.html

#
# Some lines I add to ~/.profile to set up my Posda environment
#
export PERL5LIB=$HOME/Posda/include:$PERL5LIB
export PATH=$HOME/Posda/bin:\
$HOME/Posda/bin/contrib:\
$HOME/Posda/bin/DB:\
$HOME/Posda/bin/dclunie:\
$HOME/Posda/bin/dcmtk:\
$HOME/Posda/bin/FrameOfRef:\
$HOME/Posda/bin/ae:\
$HOME/Posda/bin/test:\
$HOME/Posda/bin/dvtk:\
$HOME/Posda/bin/temp:\
$HOME/Posda/bin/DoseManip:\
$PATH
export POSDA_HOME=$HOME/Posda
export POSDA_DEBUG=0
export POSDA_TEST_COMMANDS=$POSDA_HOME/test/Dispatch
export POSDA_TEST_SCRIPTS=$POSDA_HOME/test/Scripts
export POSDA_TPL=$POSDA_HOME/tpl
export POSDA_TEST_BIN=$POSDA_HOME/bin/test
export DVTK_DEFS=$HOME/DVTK/DVT/definitions
