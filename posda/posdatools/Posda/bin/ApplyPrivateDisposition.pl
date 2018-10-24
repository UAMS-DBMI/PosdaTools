#!/usr/bin/perl -w
use strict;
use Posda::DB::PosdaFilesQueries;
use Digest::MD5;
use Posda::UUID;
use Time::Piece;
use Posda::Try;
use Posda::PrivateDispositions;
my $usage = <<EOF;
ApplyPrivateDisposition.pl <from_file> <to_file> <uid_root> <offset> <low_date> <high_date>
  Applies private tag disposition from knowledge base to <from_file>
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
