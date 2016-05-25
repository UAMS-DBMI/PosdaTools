#!/usr/bin/perl -w
#
use strict;
use Storable;
use PosdaCuration::ExtractionManagerIf;
use Dispatch::EventHandler;
package PosdaCuration::PerformBulkOperations;
use vars qw( @ISA );
@ISA = ( "Dispatch::EventHandler" );
sub new {
  my($class, $root, $col, $site, $session, $user, $port, $async) = @_;
  my $pid = $$;
  my $root_dir = "$root/$col/$site";
  unless(-d $root_dir) { die "$root_dir is not a directory" };
  opendir ROOT, $root_dir or die "Can't opendir $root_dir";
  my @subjs;
  while (my $subj = readdir(ROOT)){
    if($subj =~ /^\./) {next}
    unless(-d "$root_dir/$subj") { next }
    push(@subjs, $subj);
  }
  closedir ROOT;
  my $ExIf = PosdaCuration::ExtractionManagerIf->new(
    $port, $user, $session, $pid, 0
  );
  my $this = {
    pid => $pid,
    root => $root,
    coll => $col,
    site => $site,
    session => $session,
    user => $user,
    port => $port,
    root_dir => $root_dir,
    subjs => \@subjs,
    exif => $ExIf,
    async => $async
  };
  return bless $this, $class;
}
sub SetSubjectList{
  my($this, $list) = @_;
  $this->{subjs} = $list;
}
my $check_async = sub {
  my($this, $resp_hand) = @_;
  if($this->{async}){
    unless(defined($resp_hand) && ref($resp_hand) eq "CODE"){
      die "no response handler in async mode";
    }
  } elsif(defined $resp_hand) {
    print STDERR "Response handler defined in sync mode - ???\n";
  }
};
sub MapEdits{
  my($this, $edit_func, $description, $when_done) = @_;
  &$check_async($this, $when_done);
  if(defined($when_done) && ref($when_done) eq "CODE"){
    return $this->MapEditsAsync($edit_func, $description, $when_done);
  } else {
    return $this->MapEditsSync($edit_func, $description, $when_done);
  }
}
sub MapEditsSync{
  my($this, $edit_func, $description) = @_;
  subj:
  for my $subj (sort @{$this->{subjs}}){
    my $RevHistFile = "$this->{root_dir}/$subj/rev_hist.pinfo";
    my $rev_hist = Storable::retrieve($RevHistFile);
    my $current_rev = $rev_hist->{CurrentRev};
    my $old_info_dir = "$this->{root_dir}/$subj/revisions/$current_rev";
    my $source_dir = "$old_info_dir/files";
    my $lines = $this->{exif}->LockForEdit(
      $this->{coll}, $this->{site}, $subj, "BulkEdit: $description");
    my %resp;
    for my $line (@$lines){
      if($line =~ /(.*):\s*(.*)$/){
        my $k = $1; my $v = $2;
        $resp{$k} = $v;
      }
    }
    if(exists($resp{Locked}) && $resp{Locked} eq "OK"){  
      my $destination_dir = $resp{"Destination File Directory"};
      my $revision_dir = $resp{"Revision Dir"};
      my $results;
      for my $i ("dicom.pinfo", "send_hist.pinfo", "error.pinfo",
        "consistency.pinfo", "hierarchy.pinfo", "link_info.pinfo",
        "FileCollectionAnalysis.pinfo"
      ){
        if(-f "$old_info_dir/$i") {
          $results->{$i} = Storable::retrieve("$old_info_dir/$i");
        }
      }
      my @f_list = keys %{$results->{"dicom.pinfo"}->{FilesToDigest}};
      my $cmd_hash = 
        &{$edit_func}($this->{coll}, $this->{site}, $subj, \@f_list, $results);
      my $cmd_file;
      if(keys %$cmd_hash > 0){
        for my $f_name (keys %$cmd_hash){
          $cmd_hash->{$f_name}->{from_file} = $f_name;
          my $short;
          if($f_name =~ /\/([^\/]+)$/){
            $short = $1;
          }
          $cmd_hash->{$f_name}->{to_file} = "$destination_dir/$short";
        }
        my $cmd_file_content = {
          cache_dir => "/cache/bbennett/Data/dicom_info",
          source => "$source_dir",
          destination => $destination_dir,
          info_dir => $revision_dir,
          operation => "EditAndAnalyze",
          parallelism => 3,
          FileEdits => $cmd_hash,
          files_to_link => {},
        };
        for my $f (keys %{$results->{"dicom.pinfo"}->{FilesToDigest}}){
          my $dig = $results->{"dicom.pinfo"}->{FilesToDigest}->{$f};
          my $short;
          if($f =~ /\/([^\/]+)$/){
            $short = $1;
          } else {
            die "Can't extract short from $f\n";
          }
          unless(exists $cmd_hash->{$f}){
            $cmd_file_content->{files_to_link}->{$short} = $dig;
          }
        }
        $cmd_file = "$revision_dir/creation.pinfo";
        Storable::store $cmd_file_content, $cmd_file;
      }
      if($cmd_file) {
        print STDERR "Applying Edits, Id: $resp{Id}\n";
        my $lines = $this->{exif}->ApplyEdits(
          $resp{Id},
          "$description",
          $cmd_file
        );
        my %resp;
        for my $line (@$lines){
          if($line =~ /(.*):\s*(.*)$/){
            my $k = $1; my $v = $2;
            $resp{$k} = $v;
          }
        }
      } else {
        my $rlines = $this->{exif}->ReleaseLockWithNoEdit($resp{Id});
      }
    } else {
      print STDERR "Error locking $this->{coll}, $this->{site}, $subj:\n";
        for my $i (keys %resp){
          print STDERR "\t$i: $resp{$i}\n";
        }
    }
  }
}
sub MapEditsAsync{
  my($this, $edit_func, $when_done) = @_;
  die "MapEditsAsync not yet implemented";
}
sub MapUnlocked{
  my($this, $map_func, $description, $when_done) = @_;
  &$check_async($this, $when_done);
  if(defined($when_done) && ref($when_done) eq "CODE"){
    return $this->MapUnlockedAsync($map_func, $description, $when_done);
  } else {
    return $this->MapUnlockedSync($map_func, $description, $when_done);
  }
}
sub MapUnlockedSync{
  my($this, $map_func, $description) = @_;
  my @List;
  subj:
  for my $subj (sort @{$this->{subjs}}){
    unless(
      -d "$this->{root_dir}/$subj" &&
      -f "$this->{root_dir}/$subj/rev_hist.pinfo"){ next subj }
    my $rev_hist = Storable::retrieve("$this->{root_dir}/$subj/rev_hist.pinfo");
    my $current_rev = $rev_hist->{CurrentRev};
    my $old_info_dir = "$this->{root_dir}/$subj/revisions/$current_rev";
    my $source_dir = "$old_info_dir/files";
    unless(-d $old_info_dir && -f "$old_info_dir/dicom.pinfo"){ next subj }
    my $results;
    for my $i ("dicom.pinfo", "send_hist.pinfo", "error.pinfo",
      "consistency.pinfo", "hierarchy.pinfo", "link_info.pinfo",
      "FileCollectionAnalysis.pinfo"
    ){
      if(-f "$old_info_dir/$i") {
        $results->{$i} = Storable::retrieve("$old_info_dir/$i");
      }
    }
    my @f_list = keys %{$results->{"dicom.pinfo"}->{FilesToDigest}};
    my $v = &{$map_func}($this->{coll}, $this->{site}, $subj, \@f_list,
      $results);
    push @List, $v;
  }
  return \@List;
}
sub MapUnlockedASync{
  my($this, $map_func, $description, $when_done) = @_;
  die "MapEditsAsync not yet implemented";
}
