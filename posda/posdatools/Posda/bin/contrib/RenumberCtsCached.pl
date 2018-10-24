#!/usr/bin/perl -w
#
#Copyright 2008, Bill Bennett
# Part of the Posda package
# Posda may be copied only under the terms of either the Artistic License or the
# GNU General Public License, which may be found in the Posda Distribution,
# or at http://posda.com/License.html
#
#
use strict;
use Storable;
use Debug;
my $dbg = sub { print @_ };
my $Root = $ARGV[0];
my $NewRoot = $ARGV[1];
my $CacheRoot = $ARGV[2];
my %Pats;
opendir DIR, $Root or die "can't open $Root";
while (my $f = readdir DIR){
  unless($f =~ /\.info$/) { next }
  my $info = retrieve("$Root/$f");
  my $dir = $info->{dir};
  if(keys %{$info->{FileCollectionAnalysis}->{hierarchy}} == 0){
    next;
  }
  unless($dir =~ /LYMPH/) { next }
  for my $pat (keys %{$info->{FileCollectionAnalysis}->{hierarchy}}){
    my $dest_dir = "$NewRoot/$pat";
    for my $st (keys %{$info->{FileCollectionAnalysis}->{hierarchy}->{$pat}}){
      for my $se (
        keys %{$info->{FileCollectionAnalysis}->{hierarchy}->{$pat}->{$st}}
      ){
        my $s = 
          $info->{FileCollectionAnalysis}->{hierarchy}->{$pat}->{$st}->{$se};
        my $sc = $info->{FileCollectionAnalysis}->{series_consistency}->{$se};
        if(keys %{$sc->{"(0008,0060)"}} == 1){
          $Pats{$pat}->{$se}->{modality} = 
            [ keys %{$sc->{"(0008,0060)"}} ]->[0];
        } else {
          print STDERR "Pat: $pat, series: $se has inconsistent modality\n";
        }
        for my $f (keys %$s){
          unless($f =~ /\/([^\/]+)$/) {
            die "Can't separate filename from $f";
          }
          my $fn = $1;
          my $new_f = "$Root/$fn";
          my $digest = 
            $info->{files}->{$f}->{digest};
          unless($digest =~ /^(.)(.)/){
            die "Can't get first two chars of digest file name";
          }
          my $dig_fn = "$CacheRoot/dicom_info/$1/$2/$digest.dcminfo";
          unless(-f $dig_fn) {
            die "Digest file ($dig_fn) not found";
          }
          my $dcm_info = retrieve($dig_fn);
          my $to = "$NewRoot/$pat/$se/$fn";
          my $to_pat_dir = "$NewRoot/$pat";
          unless(-d $to_pat_dir) { mkdir $to_pat_dir }
          my $to_dir = "$NewRoot/$pat/$se";
          unless(-d $to_dir) { mkdir $to_dir }
          $Pats{$pat}->{$se}->{files}->{$f}->{from} = $f;
          $Pats{$pat}->{$se}->{files}->{$f}->{to} = $to;
          $Pats{$pat}->{$se}->{files}->{$f}->{info} = $dcm_info;
        }
        if($Pats{$pat}->{$se}->{modality} eq "CT"){
          my @files = sort 
            {
              $Pats{$pat}->{$se}->{files}->{$a}->{norm_z} <=>
              $Pats{$pat}->{$se}->{files}->{$b}->{norm_z}
            }
            keys %{$Pats{$pat}->{$se}->{files}};
          my $index = 1;
          for my $f (@files){
            keys %{$Pats{$pat}->{$se}->{files}};
            my $from = $Pats{$pat}->{$se}->{files}->{$f}->{from};
            my $to = $Pats{$pat}->{$se}->{files}->{$f}->{to};
            my $cmd = "ChangeDicomElements.pl \"$from\" \"$to\" " .
            "\"(0020,0013)\" $index";
            $index += 1;
            print "$cmd\n";
          }
        } else {
          for my $f ($Pats{$pat}->{$se}->{files}){
            my $from = $Pats{$pat}->{$se}->{files}->{$f}->{from};
            my $to = $Pats{$pat}->{$se}->{files}->{$f}->{to};
            my $cmd = "cp \"$from\" \"$to\"";
            print "$cmd\n";
          }
        }
      }
    }
  }
}
