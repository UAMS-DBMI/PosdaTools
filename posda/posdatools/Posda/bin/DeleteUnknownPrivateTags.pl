#!/usr/bin/perl -w
use strict;
use PosdaCuration::PerformBulkOperations;
use Posda::UUID;
use Posda::Try;
use DBI;
my %KnownPrivateTags;
{
  my $db_name = 'private_tag_kb';
  my $db_host = 'tcia-utilities';
  my $db_user = 'postgres';
  my $db_pass = '';
  my $dbh = DBI->connect("DBI:Pg:database=$db_name;host=$db_host",
                       "$db_user", "$db_pass");
  my $q = $dbh->prepare("select distinct pt_short_signature from pt");
  $q->execute;
  while(my $h = $q->fetchrow_hashref){
    $KnownPrivateTags{$h->{pt_short_signature}} = 1;
  }
}
sub MakeDumpSub{
  my($edits) = @_;
  my $sub = sub {
    my($ele, $sig) = @_;
    if($sig =~ /^\(....,\"[^\"]+\",..\)$/){
      unless(exists $KnownPrivateTags{$sig}){
        $edits->{$sig} = 1;
      }
    }
  };
  return $sub;
}
sub MakeSub{
  my($series_nns) = @_;
  my $sub = sub {
    my($coll, $site, $subj, $f_list, $info, $nick_names) = @_;
    my $lines;
    my $files_edited = 0;
    my $edits = {};
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
          my %to_del;
          my $try = Posda::Try->new($f);
          unless(exists $try->{dataset}){
            print STDERR "$f isn't a dicom file\n";
            next file;
          }
          $try->{dataset}->MapPvt(MakeDumpSub(\%to_del));
          if((keys %to_del) > 0){
            my $num_deletes = keys %to_del;
            for my $del (keys %to_del){
              $edits->{$f}->{full_ele_deletes}->{$del} = 1;
            }
            $files_edited += 1;
          }
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
my $usage = "DeleteUnknownPrivateTags.pl <port> <root> <collection> <site> <subj> <series_nn> [<series_nn> ...]\n";
unless($#ARGV >= 5) { die $usage }
my $port = shift @ARGV; # $ARGV[0];
my $root = shift @ARGV; # $ARGV[1];
my $coll = shift @ARGV; # $ARGV[2];
my $site = shift @ARGV; # $ARGV[3];
my $subj = shift @ARGV; # $ARGV[4];
my $series_nns = \@ARGV;
my $user = `whoami`;
chomp $user;
my $session = Posda::UUID::GetGuid;
my $Bulk = PosdaCuration::PerformBulkOperations->new(
  $root,
  $coll, $site, $session, $user, $port);
$Bulk->SetSubjectList([$subj]);
$Bulk->MapEdits(MakeSub($series_nns), $0);
