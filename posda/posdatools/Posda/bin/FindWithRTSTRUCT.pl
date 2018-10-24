#!/usr/bin/perl -w
use strict;
use PosdaCuration::PerformBulkOperations;
use Posda::UUID;
use Posda::Try;
my $sub = sub {
  my($coll, $site, $subj, $f_list, $info) = @_;
  if(exists $info->{"hierarchy.pinfo"}){
    my $message = "";
    my $h = $info->{"hierarchy.pinfo"};
    for my $pat (keys %$h){
      for my $st (keys %{$h->{$pat}->{studies}}){
        my $sth = $h->{$pat}->{studies}->{$st};
        for my $se (keys %{$sth->{series}}){
          my $se_h = $sth->{series}->{$se};
          if($se_h->{modality} eq "RTSTRUCT"){
            $message .= "\t$se_h->{uid}\n";
          }
        }
      }
    }
    if($message ne ""){
      return "$coll, $site, $subj following series have RTSTRUCT:\n" .
        $message;
    }
  }
  return undef;
};
my $usage = <<EOF;
FindWithRTSTRUCT.pl <collection> <site> <port> <root>
EOF
unless($#ARGV == 3) { die $usage }
my $collection = $ARGV[0];
my $site = $ARGV[1];
my $port = $ARGV[2];
my $root = $ARGV[3];
my $user = `whoami`;
chomp $user;
my $session = Posda::UUID::GetGuid;
my $Bulk = PosdaCuration::PerformBulkOperations->new(
  $root, $collection, $site, $session, $user, $port);
my $list = $Bulk->MapUnlocked($sub, $0);
for my $line (@$list){
  if(defined $line){
    print "$line\n";
  }
}
