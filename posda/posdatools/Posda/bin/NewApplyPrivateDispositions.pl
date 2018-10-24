#!/usr/bin/perl -w
use strict;
use Posda::DB::PosdaFilesQueries;
use Digest::MD5;
use Posda::UUID;
use Time::Piece;
use Posda::Try;
use Posda::PrivateDispositions;
my $usage = <<EOF;
NewApplyPrivateDisposition.pl <from_file> <to_file> <uid_root> <offset>
  Applies private tag disposition from knowledge base to <from_file>
  writes result into <to_file>
  UID's not hashed if they begin with <uid_root>
EOF
unless($#ARGV == 3) { die $usage }
my ($from_file, $to_file, $uid_root, $offset) = @ARGV;
my $pd = Posda::PrivateDispositions->new(
  $uid_root, $offset, undef, undef);
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
