#!/usr/bin/perl -w
#
#Copyright 2008, Bill Bennett
# Part of the Posda package
# Posda may be copied only under the terms of either the Artistic License or the
# GNU General Public License, which may be found in the Posda Distribution,
# or at http://posda.com/License.html
#
use strict;
use Posda::Try;
use Cwd;
my $usage = "RoiNameToDesc.pl <file>";
unless($#ARGV == 0){ die "$usage\n" }
my $file = $ARGV[0];
unless($file =~ /^\//) { $file = getcwd . "/$file" }
unless(-f $file) { die "$file is not file" }
my $try = Posda::Try->new($file);
unless(exists $try->{dataset}) { die "$file isn't a dicom file" }
my $m_l = $try->{dataset}->Search("(3006,0020)[<0>](3006,0026)");
for my $m (@$m_l){
  my $el1 = "(3006,0020)[$m->[0]](3006,0026)";
  my $el2 = "(3006,0020)[$m->[0]](3006,0028)";
  my $v = $try->{dataset}->Get($el1);
  $try->{dataset}->Insert($el2, $v);
}
my $new_name = "$file.new";
$try->{dataset}->WritePart10($new_name, $try->{xfr_stx}, "POSDA");
#unlink $file;
#link $new_name, $file;
#unlink $new_file;
