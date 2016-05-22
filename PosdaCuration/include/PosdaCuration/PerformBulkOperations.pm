#!/usr/bin/perl -w
#
use strict;
use Storable;
use PosdaCuration::ExtractionManagerIf;
package PosdaCuration::PerformBulkOperations;
use vars qw( @ISA );
@ISA = ( "Dispatch::EventHandler" );
sub new {
  my($class, $root, $col, $site, $session, $user, $port, $async) = @_;
  my $pid = $0;
  my $root_dir = "$root/$col/$site";
  unless(-d $root_dir) { die "root_dir is not a directory" };
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
  for my $subj (@{$this->{subjs}}){
    print STDERR "Locking $this->{coll}, $this->{site}, " .
      "$this->{subj}, $description\n";
    my $lines = $this->{exif}->LockForEdit(
      $this->{coll}, $this->{site}, $this->{subj}, "BulkEdit: $description");
    my %resp;
    for my $line (@$lines){
      if($line =~ /(.*):\s*(.*)$/){
        my $k = $1; my $v = $2;
        $resp{$k} = $v;
      }
    }
    if(exists($resp{Locked}) && $resp{Locked} eq "OK"){  
      print STDERR "Locked $this->{coll}, " .
        "$this->{site}, $subj, Id: $resp{Id}\n";
      for my $k (sort keys %resp){
        print STDERR "\t$k: $resp{$k}\n";
      }
      my $cmd_file = 
        &{$edit_func}($this->{coll}, $this->{site}, $subj, \%resp);
      if($cmd_file) {
        print STDERR "Applying Edits, Id: $resp{Id}\n";
        my $lines = $this->{exif}->AppyEdits(
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
        print STDERR "Unlocking Id: $resp{Id}:\n";
        my $rlines = $this->{exif}->ReleaseLockWithNoEdit($resp{Id});
        for my $rline (@$rlines){
          print STDERR "\t$rline\n";
        }
      }
    } else {
      print STDERR "Error locking $this->{coll}, $this->{site}, $subj:\n" .
        "\t$resp{Error}\n";
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
    push @List, &{$map_func}($this->{coll}, $this->{site}, $subj, $results);
  }
  return \@List;
}
sub MapUnlockedASync{
  my($this, $map_func, $description, $when_done) = @_;
  die "MapEditsAsync not yet implemented";
}
