#!/usr/bin/perl -w
use strict;
my $usage = <<EOF;
SymLinkToIntake.pl <root_dir>
  reads lines in the following format on STDIN:
<patient_id>,<modality>,<sop_instance_uid>,<path_on_intake>
...

Translates <path_on_intake> to the equivalent mount on utilies, and 
creates a symlink:
<root_dir>/<patient_id>/<modality>_<sop_instance_uid>.dcm => <converted_path>

Dies if <root_dir> is not present.
Creates <root_dir>/<patient_id> if necessary.  Dies if it can't.
EOF
unless($#ARGV == 0){ die $usage }
if($ARGV[0] eq '-h'){ die $usage }
unless(-d $ARGV[0]) { die "$ARGV[0] is not a directory" }
while(my $line = <STDIN>){
  chomp $line;
  my($patient_id, $modality, $sop_inst, $path_on_intake) =
    split(/\s*,\s*/, $line);
  my $dir = "$ARGV[0]/$patient_id";
  unless(-d $dir) {
    unless(mkdir $dir) { die "Can't mkdir $dir ($!)" }
  }
  my $path_on_utilities = $path_on_intake;
  $path_on_utilities =~ s/sdd1/intake1-data/;
  my $link = "$dir/${modality}_$sop_inst.dcm";
  if(symlink $path_on_utilities, $link){
    print "created symlink $link => $path_on_utilities\n";
  } else {
    print "couldn't create ($!) symlink $link => $path_on_utilities\n";
  }
}
