#!/usr/bin/perl -w
use strict;
use PosdaCuration::PerformBulkOperations;
use Posda::UUID;
use Posda::Try;
my $usage = <<EOF;
ShowErrors.pl <collection> <site> <subj> <port> <root>
EOF
my $dciodvfy = "/opt/dicom3tools/bin/dciodvfy";
my $sub = sub {
  my($coll, $site, $subj, $f_list, $info, $nn) = @_;
  my $studies = $info->{"hierarchy.pinfo"}->{$subj}->{studies};
  my $files_by_digest = $info->{"dicom.pinfo"}->{FilesByDigest};
  my $file_to = $info->{"dicom.pinfo"}->{FilesToDigest};
  my $title;
  my %StudyErrors;
  my @Messages;
  for my $i (keys %$studies){
    my $study_uid = $studies->{$i}->{uid};
    my $study_nn = $nn->FromStudy($study_uid);
    my $series_hash = $studies->{$i}->{series};
    for my $j (keys %$series_hash){
      my $series_uid = $series_hash->{$j}->{uid};
      my $series_nn = $nn->FromSeries($series_uid);
      my $first_file =
        [keys %{$series_hash->{$j}->{files}}]->[0];
      my $cmd = "$dciodvfy \"$first_file\"";
      open FILE, "$cmd 2>&1|grep Error|grep -v \"(0x0018,0x9445)\"|sort -u |";
      my @lines;
      while (my $line = <FILE>){
        chomp $line;
        push @Messages, "$subj|$study_nn|$series_nn|$line";
      }
      close FILE;
      if($#lines >= 0){
        $StudyErrors{$study_nn}->{$series_nn} = join "\n", @lines;
      }
    }
  }
  my $ret = join "\n", @Messages;
  return $ret;
  my $mess;
  for my $study (sort keys %StudyErrors){
    for my $series (sort keys %{$StudyErrors{$study}}){
      $mess .= "----------\nErrors in $coll//$site//$subj//$study//$series:\n" .
        "$StudyErrors{$study}->{$series}\n";
    }
  }
  if($mess) { $mess = "##########################\n" . $mess }
  return $mess;
};
unless($#ARGV == 4) { die $usage }
my $collection = $ARGV[0];
my $site = $ARGV[1];
my $subj = $ARGV[2];
my $port = $ARGV[3];
my $root = $ARGV[4];
my $user = `whoami`;
chomp $user;
my $session = Posda::UUID::GetGuid;
my $Bulk = PosdaCuration::PerformBulkOperations->new(
  $root, $collection, $site, $session, $user, $port);
$Bulk->SetSubjectList([$subj]);
my $list = $Bulk->MapUnlocked($sub, $0);
my %Messages;
for my $blob (@$list){
  if(defined($blob) && $blob ne ""){
    my @lines = split(/\n/, $blob);
    for my $line (@lines){
      if($line =~ /^([^\|]*)\|([^\|]*)\|([^\|]*)\|(.*)$/){
        my $subj = $1; my $study = $2; my $series = $3; my $mess = $4;
        $Messages{$mess}->{$subj}->{$study}->{$series} = $1;
      }
    }
  }
}
my %Where;
for my $m (keys %Messages){
  my $where = "";
  for my $subj (sort keys %{$Messages{$m}}){
    $where .= ":$subj:";
    for my $st (sort keys %{$Messages{$m}->{$subj}}){
      $where .= "$st:";
      for my $se (sort keys %{$Messages{$m}->{$subj}->{$st}}){
        $where .= "$se";
      }
    }
  }
  $Where{$where}->{$m} = 1;
}
my %Dups;
for my $w (keys %Where){
  my @mess = sort keys %{$Where{$w}};
  if(@mess > 1){
    my $root = shift @mess;
    $Dups{$root} = \@mess;
  }
}
my %AlreadyPrinted;
for my $m (sort keys %Messages){
  if(exists $AlreadyPrinted{$m}) { next }
  print "#########################\n$m\n";
  if(exists $Dups{$m}){
    for my $i (@{$Dups{$m}}){
      print "$i\n";
      $AlreadyPrinted{$i} = 1;
    }
  }
  for my $subj (sort keys %{$Messages{$m}}){
    print "  $subj ";
    for my $st (sort keys %{$Messages{$m}->{$subj}}){
#      print "\t\t$st:";
      for my $se (sort keys %{$Messages{$m}->{$subj}->{$st}}){
        print " $se";
      }
    }
    print "\n";
  }
}
