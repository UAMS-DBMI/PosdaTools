#!/usr/bin/perl -w
#
use strict;
package Posda::DirectoryManager;
use Dispatch::EventHandler;
use Dispatch::LineReader;
use vars qw( @ISA );
@ISA = qw( Dispatch::EventHandler );
sub new{
  my($class, $dir, $fm, $high, $low) = @_;
  unless(defined($high) && $high > 1 && $high > $low){ $high = 20 }
  unless(defined($low) && $low >= 1 && $high > $low){
    $low = ($high - 5 <= 0) ? 1: $high - 5
  }
  my $this = {
    DirectoryManager => {
      high => $high,
      low => $low,
    },
  };
  bless($this, $class);
  $this->InvokeAfterDelay("DM_Initialize", 0, $dir, $fm);
  return $this;
}
sub DM_GetFileManager{
  my($this) = @_;
  my $fm;
  if($this->{FM_TYPE} eq "Named"){
    $fm = $this->get_obj($this->{FM_NAME});
  } elsif($this->{FM_TYPE} eq "Ref"){
    $fm = $this->{FM};
  } elsif ($this->{FM_TYPE} eq "global"){
    $fm = $main::FILE_MANAGER_SINGLETON;
  } else {
    die "no FM_TYPE";
  }
  return $fm;
}
sub DM_Initialize{
  my($this, $dir, $fm) = @_;
  if(-f "$dir/.FileBOM.info") {
    $this->{DirectoryManager}->{BOM} = $this->ReadBom("$dir/.FileBOM.info");
  }
  if(
    $fm && ref($fm) && ref($fm) ne "ARRAY" &&
    ref($fm) ne "SCALAR" && ref($fm) ne "HASH" &&
    $fm->isa("Posda::FileInfoManager")
  ){
    $this->{FM_TYPE} = "Ref";
    $this->{FM} = $fm;
  } elsif($fm && ref($fm) eq ""){
    unless($this->can("get_obj")){
      die "can't find FileInfoManager (name but no getobj)";
    }
    $this->{FM_TYPE} = "Named";
    $this->{FM_NAME} = $fm;
  } elsif(!defined($fm) ){
    $fm = $main::FILE_MANAGER_SINGLETON;
    if(
      $fm && ref($fm) && ref($fm) ne "ARRAY" &&
      ref($fm) ne "SCALAR" && ref($fm) ne "HASH" &&
      $fm->isa("Posda::FileInfoManager")
    ){
      $this->{FM_TYPE} = "global";
    } else { die "can't locate FileInfoManager not defined, no singleton" }
  } else { die "can't locate FileInfoManageri $fm" }
  unless(-d $dir) { die "$dir is not a directory" }
  $this->{DirectoryManager}->{dir} = $dir;
  $this->{DirectoryManager}->{state} = "Initializing";
  $this->{DirectoryManager}->{Processed} = {};
  $this->{DirectoryManager}->{Awaited} = {};
  $this->{DirectoryManager}->{FileFinder} = Dispatch::LineReader->new_cmd(
    "find \"$dir\" -follow -type f",
    $this->DM_HandleFoundFile,
    $this->CreateNotifierClosure("DM_EndOfFinder")
  );
  $this->{DirectoryManager}->{state} = "Waiting";
}
sub DM_EndOfFinder{
  my($this) = @_;
  delete $this->{DirectoryManager}->{FileFinder};
  $this->DM_CheckForEnd;
}
sub ReadBom{
  my($this, $file) = @_;
  my $hash = {};
  open my $fh, "<$file" or die "can't open $file for reading";
  while (my $line = <$fh>){
    chomp $line;
    my($file, $digest, $size, $m_time) = split(/\|/, $line);
    unless($file =~ /\.FileBOM.info/){
      $hash->{$file} = {
        digest => $digest,
        size => $size,
        m_time => $m_time,
      };
    }
  }
  return $hash;
}
sub WriteBom{
  my($this, $hash, $file) = @_;
  my $fh;
  if(open $fh, ">$file"){
    for my $file (keys %$hash){
      my $h = $hash->{$file};
      print $fh "$file|$h->{digest}|$h->{size}|$h->{m_time}\n";
    }
    close $fh;
  } else {
    print STDERR "Can't open $file for writing\n";
  }
}
sub DM_HandleFoundFile{
  my($this) = @_;
  my $clos = sub {
    my($file) = @_;
    unless(-f $file){ return } # Find aborted
    if($file =~ /\.FileBOM.info$/) { return } # ignore BOM
    my $do_fast_queue = 0;
    my $old_m_time;
    my $old_size;
    my $old_digest;
    if(exists $this->{DirectoryManager}->{BOM}->{$file}){
      $old_digest = $this->{DirectoryManager}->{BOM}->{$file}->{digest};
      $old_size = $this->{DirectoryManager}->{BOM}->{$file}->{size};
      $old_m_time = $this->{DirectoryManager}->{BOM}->{$file}->{m_time};
      my @foo = stat $file;
      my $m_time = $foo[9];
      my $size = $foo[7];
      if($size eq $old_size && $m_time eq $old_m_time){
        $do_fast_queue = 1;
      }
    }
    my $notifier = $this->CreateNotifierClosure("DM_FileComplete", $file);
    my $fm = $this->DM_GetFileManager;
    if($do_fast_queue){
      $this->{DirectoryManager}->{Awaited}->{$file} = 1;
      unless(
        $fm->QueueFileWithDigestEtc(
          $file, $old_digest, $old_size, $old_m_time, 1, $notifier)
      ){
        delete($this->{DirectoryManager}->{Awaited}->{$file});
        $this->{DirectoryManager}->{Processed}->{$file} = 1;
        $this->{DirectoryManager}->{NumProcessed} = 
          scalar keys %{$this->{DirectoryManager}->{Processed}};
      }
    } else {
      if($fm->QueueFile($file, 1, $notifier)){
        $this->{DirectoryManager}->{Awaited}->{$file} = 1;
      } else {
        $this->{DirectoryManager}->{Processed}->{$file} = 1;
        $this->{DirectoryManager}->{NumProcessed} = 
          scalar keys %{$this->{DirectoryManager}->{Processed}};
      }
    }
    my $queued = scalar keys %{$this->{DirectoryManager}->{Awaited}};
    $this->DM_FlowControl;
  };
  return $clos;
}
sub DM_FlowControl{
  my($this) = @_;
  if(defined $this->{DirectoryManager}->{FileFinder}){
    my $queued = scalar keys %{$this->{DirectoryManager}->{Awaited}};
    if(
      $this->{DirectoryManager}->{FileFinder}->paused && $queued <= 
      $this->{DirectoryManager}->{low}
    ){ 
      $this->{DirectoryManager}->{FileFinder}->resume;
    } elsif(
      !$this->{DirectoryManager}->{FileFinder}->paused && $queued >= 
      $this->{DirectoryManager}->{high}
    ){
      $this->{DirectoryManager}->{FileFinder}->pause;
    }
  } else {
  }
}
sub DM_FileComplete{
  my($this, $file) = @_;
  if($this->{Abort}) { return }
  $this->{DirectoryManager}->{Processed}->{$file} = 1;
  $this->{DirectoryManager}->{NumProcessed} = 
    scalar keys %{$this->{DirectoryManager}->{Processed}};
  delete $this->{DirectoryManager}->{Awaited}->{$file};
  $this->DM_FlowControl;
  $this->DM_CheckForEnd;
}
sub DM_CheckForEnd{
  my($this) = @_;
  if($this->{Abort}){ return }
  if(
    $this->{DirectoryManager}->{state} eq "Initializing" ||
    $this->{DirectoryManager}->{state} eq "Initialized"  ||
    defined($this->{DirectoryManager}->{FileFinder})
  ){
    return;
  } elsif($this->{DirectoryManager}->{state} eq "Waiting"){
    if(scalar(keys %{$this->{DirectoryManager}->{Awaited}}) == 0){
      delete $this->{DirectoryManager}->{Awaited};
      $this->{DirectoryManager}->{state} = "Initialized";
      my $hash;
      my $fm = $this->DM_GetFileManager;
      for my $i (keys %{$this->{DirectoryManager}->{Processed}}){
        unless(exists $fm->{ManagedFiles}->{by_file}->{$i}){
          print STDERR "Unmanaged but processed file: $i\n";
        }
        my $f_info = $fm->{ManagedFiles}->{by_file}->{$i};
        $hash->{$i} = {
          digest => $f_info->{digest},
          size => $f_info->{size},
          m_time => $f_info->{m_time},
        };
      }
      print STDERR "Writing BOM for $this->{DirectoryManager}->{dir}\n";
      $this->WriteBom($hash, "$this->{DirectoryManager}->{dir}/.FileBOM.info");
      $this->DM_Initialized;
    }
  } else {
    $this->Die("Bad DirectoryManager state:" .
     " $this->{DirectoryManager}->{state}");
  }
}
sub Abort{
  my($this) = @_;
  $this->{DirectoryManager}->{Abort} = 1;
  if(
    $this->{DirectoryManager}->{FileFinder} &&
    $this->{DirectoryManager}->{FileFinder}->can("Abort")
  ){
    $this->{DirectoryManager}->{FileFinder}->Abort;
  }
};
sub DM_Initialized{
  my($this) = @_;
  ## Invoked when the directory is set up
  ## Derived Classes override this...
}
sub GetFileList{
  my($this) = @_;
  unless(exists $this->{DirectoryManager}->{Processed}){ return [] }
  return [keys %{$this->{DirectoryManager}->{Processed}}];
}
1;
