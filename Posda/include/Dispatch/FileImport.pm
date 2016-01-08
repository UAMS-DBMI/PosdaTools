#!/usr/bin/perl -w
#$Source: /home/bbennett/pass/archive/Posda/include/Dispatch/FileImport.pm,v $
#$Date: 2010/09/14 14:14:16 $
#$Revision: 1.5 $
#
#Copyright 2008, Bill Bennett
# Part of the Posda package
# Posda may be copied only under the terms of either the Artistic License or the
# GNU General Public License, which may be found in the Posda Distribution,
# or at http://posda.com/License.html
#
package Dispatch::FileImport;
use strict;
use Posda::Dataset;
use File::Find;
sub FindFilesRecursive{
  my($this, $dir) = @_;
  my @list;
  my $foo = sub {
    if(-f $File::Find::name){
      push @list, $File::Find::name;
    }
  };
  find({wanted => $foo, follow => 1}, $dir);
  return \@list;
}

sub FindFilesFlat{
  my($this, $dir) = @_;
  my @list;
  my $res = opendir DIR, $dir;
  unless($res) {return \@list}
  while (my $file = readdir(DIR)){
    if($file =~ /^\./) { next }
    unless(-f "$dir/$file") { next }
    push(@list, "$dir/$file");
  }
  close DIR;
  return \@list;
}

sub MakeLoopStep{
  my($this) = @_;
  my $foo = sub {
    my $disp = shift;
    unless(
      exists($this->{file_list}) &&
      ref($this->{file_list}) eq "ARRAY" &&
      $#{$this->{file_list}} >= 0
    ){
      delete $this->{file_list};
      $this->ImportFinished;
      return;
    }
    my $file = shift(@{$this->{file_list}});
    my $try = Posda::Try->new($file);
    if(exists $try->{dataset}){
      my $sop_class = $try->{dataset}->Get("(0008,0016)");
      if(defined $sop_class){
        my $sop_instance = $try->{dataset}->Get("(0008,0018)");
        my $sop_prefix = Posda::DataDict::GetSopClassPrefix($sop_class);
        my $new_file_name = "${sop_prefix}_$sop_instance.dcm";
        if(-f "$this->{importing_to}/$new_file_name"){
          push(@{$this->{errors}},
            "File $file would overwrite existing file $new_file_name " .
            " in $this->{importing_to} -- Skipping");
        } else {
          my $xfr_stx = "1.2.840.10008.1.2";
          unless($try->{xfr_stx} eq $xfr_stx){
            push @{$this->{errors}},
              "Coercing xfr_stx $try->{xfr_stx} to $xfr_stx for $new_file_name"
          }
          my $dest_file = "$this->{importing_to}/$new_file_name";
          eval {
          $try->{dataset}->WritePart10($dest_file, $xfr_stx, 
            "POSDA", undef, undef);
           };
           if($@){
             push(@{$this->{errors}}, "Couldn't write to $dest_file ($@)");
           }
        }
      } else {
          push(@{$this->{errors}},
            "File $file is a DICOM file, but has no sop class uid " .
            "-- Skipping");
      }
    } else {
      push(@{$this->{errors}},
        "File $file is not a DICOM file " .
        "-- Skipping");
    }
    $disp->queue();
  };
  return $foo;
}

sub StartImport{
  my($this, $recursive) = @_;
  $this->{importing_from} = $this->{CurrentlySelectedDirectory};
  $this->{importing_to} = 
    $this->get_obj($this->{from_obj})->{directory};
  if($recursive){
    $this->{file_list} = FindFilesRecursive($this, $this->{importing_from});
  } else {
    $this->{file_list} = FindFilesFlat($this, $this->{importing_from});
  }
  my $loop = Dispatch::Select::Background->new(
    MakeLoopStep($this));
  $loop->queue();
}
#####################
sub InitializeImport{
  my($this) = @_;
  # nothing to do here
}
sub EndTest{
  my($this) = @_;
  if($#{$this->{file_list}} < 0){ return 1}
  return 0;
}
sub Iterate{
  my($this) = @_;
  my $file = shift(@{$this->{file_list}});
  my $try = Posda::Try->new($file);
  if(exists $try->{dataset}){
    my $sop_class = $try->{dataset}->Get("(0008,0016)");
    if(defined $sop_class){
      my $sop_instance = $try->{dataset}->Get("(0008,0018)");
      my $sop_prefix = Posda::DataDict::GetSopClassPrefix($sop_class);
      my $new_file_name = "${sop_prefix}_$sop_instance.dcm";
      if(-f "$this->{to}/$new_file_name"){
        $this->{log_obj}->log_error(
          "File $file would overwrite existing file $new_file_name " .
          " in $this->{to} -- Skipping");
      } else {
        my $xfr_stx = "1.2.840.10008.1.2";
        unless($try->{xfr_stx} eq $xfr_stx){
          $this->{log_obj}->log_error(
            "Coercing xfr_stx $try->{xfr_stx} to $xfr_stx for $new_file_name");
        }
        my $dest_file = "$this->{to}/$new_file_name";
        eval {
          $try->{dataset}->WritePart10($dest_file, $xfr_stx, 
            "POSDA", undef, undef);
        };
        if($@){
          $this->{log_obj}->log_error(
            "Couldn't write to $dest_file ($@)"
          );
        }
      }
    } else {
        $this->{log_obj}->log_error(
          "File $file is a DICOM file, but has no sop class uid " .
          "-- Skipping");
    }
  } else {
    $this->{log_obj}->log_error(
      "File $file is not a DICOM file " .
      "-- Skipping");
  }
}
sub FinalizeImport{
  my($this) = @_;
  $this->{notifier}->queue();
}
sub DoImport{
  my($this, $notifier, $log_obj) = @_;
  $this->{notifier} = $notifier;
  $this->{log_obj} = $log_obj;
  Dispatch::Iterator::Iterate($this, 
    "InitializeImport", "Iterate", "EndTest", "FinalizeImport");
}
sub new {
  my($class, $from, $to, $recursive) = @_;
  my $this = {
    from => $from,
    to => $to,
  };
  if($recursive) {
    $this->{file_list} = FindFilesRecursive($this, $this->{from});
  } else {
    $this->{file_list} = FindFilesFlat($this, $this->{from});
  }
  return bless $this, $class;
}

1;
