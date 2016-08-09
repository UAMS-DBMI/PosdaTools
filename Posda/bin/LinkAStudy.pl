#!/usr/bin/perl -w
use strict;
use PosdaCuration::PerformBulkOperations;
use Posda::UUID;
use Posda::Try;
sub MakeSub{
  my($study_id, $link_root) = @_;
  my $sub = sub {
    my($coll, $site, $subj, $f_list, $info) = @_;
    my $lines;
    file:
    for my $f (@$f_list){
      my $dig = $info->{"dicom.pinfo"}->{FilesToDigest}->{$f};
      my $f_info = $info->{"dicom.pinfo"}->{FilesByDigest}->{$dig};
      if($f_info->{study_uid} eq $study_id){
        if($f =~ /\/([^\/]+)$/){
          my $fp = $1;
          $lines .= "ln $f $link_root/$fp\n";
        }
      }
    }
    return $lines;
  };
  return $sub;
};
my $usage = "LinkASubject.pl <collection> <site> <subj> <port> <root> <link_root> <study_inst_uid>";
unless($#ARGV == 6) { die $usage }
my $coll = $ARGV[0];
my $site = $ARGV[1];
my $subj = $ARGV[2];
my $port = $ARGV[3];
my $root = $ARGV[4];
my $link_root = $ARGV[5];
my $study_uid = $ARGV[6];
my $user = `whoami`;
chomp $user;
my $session = Posda::UUID::GetGuid;
my $Bulk = PosdaCuration::PerformBulkOperations->new(
  $root,
  $coll, $site, $session, $user, $port);
$Bulk->SetSubjectList([$subj]);
my $List = $Bulk->MapUnlocked(MakeSub($study_uid, $link_root), $0);
for my $line (@$List) { print $line };
