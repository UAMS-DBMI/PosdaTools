#!/usr/bin/perl -w
use strict;
use PosdaCuration::PerformBulkOperations;
use Posda::UUID;
use Posda::Try;
sub MakeSub{
  my($series_nns, $tag) = @_;
  my $sub = sub {
    my($coll, $site, $subj, $f_list, $info, $nick_names) = @_;
    my $lines;
    my $files_edited = 0;
    my $edits = {};
    my $edit = {
      full_ele_additions => {
        $tag => "",
      },
    };
    my @series_uids;
    nick:
    for my $series_nn(@$series_nns){
      my $series = $nick_names->ToSeries($series_nn);
      unless($series) { next nick }
      push @series_uids, $series;
    }
    series:
    for my $series_uid (@series_uids){
      file:
      for my $f (@$f_list){
        my $dig = $info->{"dicom.pinfo"}->{FilesToDigest}->{$f};
        my $f_info = $info->{"dicom.pinfo"}->{FilesByDigest}->{$dig};
        if($f_info->{series_uid} eq $series_uid){
          $edits->{$f} = $edit;
          $files_edited += 1;
        }
      }
    }
    if($files_edited > 0){
      print "$files_edited edited\n";
      return $edits;
    } else {
      print "No files edited\n";
      return undef;
    }
  };
  return $sub;
};
my $usage = "InsertNullValue.pl <port> <root> <tag> <collection> <site> <subj> <series_nn> [<series_nn> ...]\n";
unless($#ARGV >= 6) { die $usage }
my $port = shift @ARGV; # $ARGV[0];
my $root = shift @ARGV; # $ARGV[1];
my $tag = shift @ARGV; # $ARGV[2];
my $coll = shift @ARGV; # $ARGV[3];
my $site = shift @ARGV; # $ARGV[4];
my $subj = shift @ARGV; # $ARGV[5];
my $series_nns = \@ARGV;
my $user = `whoami`;
chomp $user;
my $session = Posda::UUID::GetGuid;
my $Bulk = PosdaCuration::PerformBulkOperations->new(
  $root,
  $coll, $site, $session, $user, $port);
$Bulk->SetSubjectList([$subj]);
$Bulk->MapEdits(MakeSub($series_nns, $tag), $0);
