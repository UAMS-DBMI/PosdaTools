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
  die "Patient id is not integer";
}
my $len = length($patient_id);
my $pad = 3 - $len;
my $new_patid = ("0" x $pad) . $patient_id;
$patient_id = "ACRIN-FLT-Breast_$new_patid";
$ds->Insert("(0010,0020)", $patient_id);
$ds->Insert("(0010,0010)", $patient_id);
my @EleToShift = (
  "(0018,1012)", "(0008,0023)", "(0008,0012)", "(0008,0022)");
for my $el (@EleToShift){
  my $date = $ds->Get($el);
  if(defined($date) && $date ne ""){
    my $new_date = $pd->ShiftDate($date);
    if($new_date ne $date){
      $ds->Insert($el, $new_date);
    }
  }
}
my @PatToShift = (
  "(0054,0016)[<0>](0018,1078)", "(0054,0016)[<0>](0018,1079)");
for my $pat (@PatToShift){
  my $m = $ds->Search($pat);
  if($m && ref($m) eq "ARRAY" && $#$m >= 0){
    for my $s (@$m){
      my $el = $pat;
      $el =~ s/<0>/$s->[0]/;
      my $date = $ds->Get($el);
      if(defined($date) && $date ne ""){
        my $new_date = $pd->ShiftDate($date);
        if($new_date ne $date){
          $ds->Insert($el, $new_date);
        }
      }
    }
  }
}
my @UidToHash = (
  "(0008,1120)[<0>](0008,1155)",
  "(0008,1250)[<0>](0020,000d)",
  "(0008,1250)[<0>](0020,000e)",
  "(0008,9121)[<0>](0008,1155)",
);
uid:
for my $i (@UidToHash){
  my $m = $ds->Search($i);
  if($m && ref($m) eq "ARRAY" && $#$m >= 0){
    for my $s (@$m){
     my $el = $i;
      $el =~ s/<0>/$s->[0]/;
      my $uid = $ds->Get($el);
      unless(defined $uid){ next uid }
      if($uid =~/^$uid_root.*$/){
        next uid;
      } else {
        my $old = $uid;
        my $ctx = Digest::MD5->new;
        $ctx->add($old);
        my $dig = $ctx->digest;
        my $new_uid = "$uid_root." . Posda::UUID::FromDigest($dig);
        if($new_uid =~ /^(.{64})/){
          $new_uid = $1;
        }
        $ds->Insert($el, $new_uid);
      }
    }
  }
}
my @ElesToDelete = (
  "(0012,0031)"
);
for my $i (@ElesToDelete){
  $ds->Delete($i);
}

my %MapNEG = (
  NEG1 => -1,
  NEG4 => -4,
  NEG5 => -5,
  NEG9 => -9,
  NEG13 => -13,
);
my %Map345678 = (
  19600305 => 65,
  19600318 => 78,
  19600102 => 1,
  19600107 => 6,
);
my $offs = $ds->Get("(0012,0050)");
if(exists $MapNEG{$offs}){
  $ds->Insert("(0012,0050)", $MapNEG{$offs});
} elsif ($offs eq "345678"){
  my $date = $ds->Get("(0008,0020)");
  if(exists $Map345678{$date}){
    $ds->Insert("(0012,0050)",$Map345678{$date});
  } else {
    print STDERR "No date mapping for offset 345678 ($date)\n";
  }
}

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
