#!/usr/bin/perl -w
use strict;
use Posda::DB::PosdaFilesQueries;
use Digest::MD5;
use Posda::UUID;
use Time::Piece;
use Posda::Try;
use Posda::PrivateDispositions;
my $usage = <<EOF;
FixAcrin.pl <from_file> <to_file> <uid_root> <offset> <low_date> <high_date>
  Changes Patient_id and Patient name based on existing Patient id:
    "1" => "ACRIN_FLT_Breast_001", 
    "2" => "ACRIN_FLT_Breast_002", 
    ...
  Then applies private tag disposition from knowledge base to <from_file>
  writes result into <to_file>
  UID's not hashed if they begin with <uid_root>
  date's only offset if result between <low_date> and <high_date>
EOF
unless($#ARGV == 5) { die $usage }
my ($from_file, $to_file, $uid_root, $offset, $low_date, $high_date)
   = @ARGV;
if($low_date =~ /^(....)-(..)-(..)$/){ $low_date = "$1$2$3" }
if($high_date =~ /^(....)-(..)-(..)$/){ $high_date = "$1$2$3" }
unless($low_date =~ /^(....)(..)(..)$/){
}
my $pd = Posda::PrivateDispositions->new(
  $uid_root, $offset, $low_date, $high_date);
my $try = Posda::Try->new($from_file);
unless(exists $try->{dataset}){ die "$from_file is not a DICOM file" }
my $ds = $try->{dataset};
### Specific for ACRIN
my $patient_id = $ds->Get("(0010,0020)");
unless($patient_id =~ /^(\d+)$/){
  die "Patent id is not integer";
}
my $len = length($patient_id);
my $pad = 3 - $len;
my $new_patid = ("0" x $pad) . $patient_id;
$patient_id = "ACRIN-FLT-Breast_$new_patid";
$ds->Insert("(0010,0020)", $patient_id);
$ds->Insert("(0010,0010)", $patient_id);
### End Specific for ACRIN 
$pd->Apply($ds);
eval {
  $ds->WritePart10($to_file, $try->{xfr_stx}, "POSDA", undef, undef);
};
if($@){
  print STDERR "Can't write $to_file ($@)\n";
  exit;
}
print "Wrote $to_file\n";
1;
