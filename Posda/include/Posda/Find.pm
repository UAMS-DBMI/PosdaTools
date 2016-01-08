#!/usr/bin/perl -w
#$Source: /home/bbennett/pass/archive/Posda/include/Posda/Find.pm,v $
#$Date: 2013/05/13 12:35:23 $
#$Revision: 1.10 $
#
#Copyright 2008, Bill Bennett
# Part of the Posda package
# Posda may be copied only under the terms of either the Artistic License or the
# GNU General Public License, which may be found in the Posda Distribution,
# or at http://posda.com/License.html
#
package Posda::Find;
use strict;
use Posda::Dataset;
use Posda::Parser;
use File::Find;

sub MakeWanted {
  my($callback) = @_;
  my $wanted = sub {
    my $f_name = $File::Find::name;
    if(-d $f_name) { return }
    unless(-r $f_name) { return }
    my($df, $ds, $size, $xfr_stx, $errors) = 
      Posda::Dataset::Try($f_name);
    unless(defined $ds){ return }
    &$callback($f_name, $df, $ds, $size, $xfr_stx, $errors);
  };
  return $wanted;
}

sub MakeWantedNew {
  my($callback) = @_;
  my $wanted = sub {
    my $f_name = $File::Find::name;
    if(-d $f_name) { return }
    unless(-r $f_name) { return }
    my $try = Posda::Try->new($f_name);
    unless(defined $try){ return }
    &$callback($try);
  };
  return $wanted;
}

sub MakeWantedDicomOnly {
  my($callback) = @_;
  my $wanted = sub {
    my $f_name = $File::Find::name;
    if(-d $f_name) { return }
    unless(-r $f_name) { return }
    my $try = Posda::Try->new($f_name);
    unless(defined $try){ return }
    if($try->{status} eq "parsed dicom file"){
      &$callback($try);
    }
  };
  return $wanted;
}
sub FastMakeWantedDicomOnly {
  my($callback) = @_;
  my $wanted = sub {
    my $f_name = $File::Find::name;
    if(-d $f_name) { return }
    unless(-r $f_name) { return }
    my $try = Posda::Try->new($f_name, 1000);
    unless(defined $try){ return }
    if($try->{status} eq "parsed dicom file"){
      &$callback($try);
    }
  };
  return $wanted;
}

sub MakeWantedMetaHeader{
  my($callback) = @_;
  my $wanted = sub {
    my $f_name = $File::Find::name;
    if(-d $f_name) { return }
    unless(-r $f_name) { return }
    unless(open FILE, $f_name) { return }
    my $mh = eval {Posda::Parser::ReadMetaHeader(*FILE)};
    if($@) { 
      close FILE;
      # error message can go here
      return;
    }
    close FILE;
    if($mh){
      &$callback({file => $f_name, mh => $mh});
    }
  };
  return $wanted;
}

sub SearchDir{
  my($dir, $cb) = @_;
  find({wanted => MakeWanted($cb), follow => 1}, $dir);
}

sub AllFiles{
  my($dir, $cb) = @_;
  find({wanted => MakeWantedNew($cb), follow => 1}, $dir);
}

sub DicomOnly{
  my($dir, $cb) = @_;
  find({wanted => MakeWantedDicomOnly($cb), follow => 1}, $dir);
}
sub FastDicomOnly{
  my($dir, $cb) = @_;
  find({wanted => FastMakeWantedDicomOnly($cb), follow => 1}, $dir);
}
sub MetaHeader{
  my($dir, $cb) = @_;
  find({wanted => MakeWantedMetaHeader($cb), follow => 1}, $dir);
}
sub CollectMetaHeaders{
  my($dir) = @_;
  my @list;
  my $cb = sub {
    my($foo) = @_;
    my $file = $foo->{file};
    my $mh = $foo->{mh};
    my $offset = $mh->{DataSetStart};
    my $length = $mh->{DataSetSize};
    my $sop_class = $mh->{metaheader}->{"(0002,0002)"};
    my $sop_inst = $mh->{metaheader}->{"(0002,0003)"};
    my $xfr_stx = $mh->{xfrstx};
    unless(defined($sop_class) && defined($sop_inst)){ return }
    push(@list, {
      file => $file,
      offset => $offset,
      length => $length,
      sop_class => $sop_class,
      sop_inst => $sop_inst,
      xfr_stx => $xfr_stx,
    });
  };
  MetaHeader($dir, $cb);
  return \@list;
}
1;
