#!/usr/bin/perl -w
use strict;
use PosdaCuration::PerformBulkOperations;
use Posda::UUID;
use Posda::Try;
sub MakeSub{
  my($series_nn) = @_;
  my $sub = sub {
    my($coll, $site, $subj, $f_list, $info, $nn) = @_;
    my $series_uid = $nn->ToSeries($series_nn);
    my $f_by_dig = $info->{"dicom.pinfo"}->{FilesByDigest};
    my $f_to_dig = $info->{"dicom.pinfo"}->{FilesToDigest};
    my %f_sum;
    for my $f (@$f_list){
      my $f_info = $f_by_dig->{$f_to_dig->{$f}};
      if($f_info->{series_uid} eq $series_uid){
        $f_sum{$f} = $f_info;
      }
    }
    my %table;
    for my $f (keys %f_sum){
      my $info = $f_sum{$f};
      my $pixel_digest = $info->{pixel_digest};
      my $loc = $info->{normalized_loc};
      my $i = $info->{"(0020,0013)"};
      $table{$i} = {
        dig => $pixel_digest,
        loc => $loc,
      };
    }
    my $message;
    for my $i (sort {$a <=> $b} keys %table){
      $message .= "$i, $table{$i}->{loc}, $table{$i}->{dig}\n";
    }
    if($message ne ""){
      return $message;
    }
    return undef;
  };
  return $sub;
}
my $usage = <<EOF;
SeriesPixelDigestReport.pl <port> <root> <collection> <site> <subj> <series_nn>
EOF
unless($#ARGV == 5) { die $usage }
my $port = $ARGV[0];
my $root = $ARGV[1];
my $collection = $ARGV[2];
my $site = $ARGV[3];
my $subj = $ARGV[4];
my $series_nn = $ARGV[5];
my $user = `whoami`;
chomp $user;
my $session = Posda::UUID::GetGuid;
my $Bulk = PosdaCuration::PerformBulkOperations->new(
  $root, $collection, $site, $session, $user, $port);
$Bulk->SetSubjectList([$subj]);
my $list = $Bulk->MapUnlocked(MakeSub($series_nn), $0);
for my $line (@$list){
  if(defined $line){
    print "$line\n";
  }
}
