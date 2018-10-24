#!/usr/bin/perl -w
#
use strict;
package Posda::HttpApp::PrefetchContours;
use Dispatch::LineReader;
use Dispatch::NamedObject;
use Storable qw ( store_fd fd_retrieve );
use Debug;
my $dbg = sub {print STDERR @_ };
use vars qw( @ISA );
@ISA = ( "Dispatch::NamedObject" );
sub new {
  my($class, $sess, $path, $cache_dir, $ss, $ss_info, $s_image) = @_;
  my $this = Dispatch::NamedObject->new($sess, $path);
  bless $this, $class;
  $this->{Exports}->{PrefetchStatus} = 1;
  $this->{cache_dir} = $cache_dir;
  unless(-d $cache_dir) {
    unless(mkdir($cache_dir)){ die "can't mkdir $cache_dir" }
  }
  $this->{ss} = $ss;
  $this->{ss_info} = $ss_info;
  $this->{s_image} = $s_image;
  $this->{num_sub_procs} = 0;
  $this->Init;
  $this->{ImportsFromAbove}->{PrefetchStatusChange} = 1;
  return $this;
}
sub Init{
  my($this) = @_;
  $this->{queue} = [];
  unless(-f $this->{ss}) {
    print STDERR "$this->{path}: no ss\n";
    return
  }
  unless(
    $this->{s_image} && ref($this->{s_image}) eq "HASH" &&
    -f $this->{s_image}->{file}
  ){
    print STDERR "$this->{path}: no selected image\n";
    return
  }
  my @list_of_rois;
  my %sops;
  my $fm = $this->get_obj("FileManager");
  my $struct_ds_offset = $fm->GetDsOffset($this->{ss});
  my $i_inf = $fm->DicomInfo($this->{s_image});
  for my $roi (keys %{$this->{ss_info}->{rois}}){
    if(
      defined $this->{ss_info}->{rois}->{$roi}->{contours} &&
      ref($this->{ss_info}->{rois}->{$roi}->{contours}) eq "ARRAY"
    ){
      my $c_list = $this->{ss_info}->{rois}->{$roi}->{contours};
      contour:
      for my $c (0 .. $#{$c_list}){
        my $file_name = $this->RoiCacheFileName($roi, $c);
        if(-f $file_name) { next contour }
        push(@list_of_rois, {
          struct_set => $this->{ss},
          norm_iop => $this->{s_image}->{info}->{norm_iop},
          norm_x => $this->{s_image}->{info}->{norm_x},
          norm_y => $this->{s_image}->{info}->{norm_y},
          norm_z => $this->{s_image}->{info}->{norm_z},
          rows => $this->{s_image}->{info}->{"(0028,0010)"},
          cols => $this->{s_image}->{info}->{"(0028,0011)"},
          pix_sp => $this->{s_image}->{info}->{"(0028,0030)"},
          offset => $struct_ds_offset + $c_list->[$c]->{ds_offset},
          roi => $roi,
          c => $c,
          length => $c_list->[$c]->{length},
          ref => $c_list->[$c]->{ref},
          num_pts => $c_list->[$c]->{num_pts},
          file_name => $this->RoiCacheFileName($roi, $c),
        });
        $sops{$c_list->[$c]->{ref}} = 1;
      }
    }
  }
  my %sops_to_z;
  sop:
  for my $sop (keys %sops){
    my $info = $fm->DicomInfoBySop($sop);
    if(ref($info) eq "ARRAY"){ $info = $info->[0] }
    unless(defined($info) && ref($info) eq "HASH"){next sop}
    my $z = $info->{norm_z};
    $sops_to_z{$sop} = $z;
  }
  my @extract_list = sort 
    { 
      abs($a->{norm_z} - $sops_to_z{$a->{ref}})
      <=>
      abs($b->{norm_z} - $sops_to_z{$b->{ref}})
    }
    @list_of_rois;
  $this->{queue} = \@extract_list;
  $this->KickList;
}
sub RoiCacheFileName{
  my($this, $roin, $cn) = @_;
  my $dir = "$this->{cache_dir}";
  my $fn = "$this->{ss_info}->{dataset_digest}_${roin}_$cn";
  return "$dir/$fn";
}
sub CleanUp{
  my($this) = @_;
  delete $this->{queue};
  $this->{CleanedUp} = 1;
}
sub Reset{
  my($this, $ss, $ss_info, $s_image) = @_;
  $this->{ss} = $ss;
  $this->{ss_info} = $ss_info;
  $this->{s_image} = $s_image;
  $this->Init;
}
sub KickList{
  my($this) = @_;
  if($this->{num_sub_procs} > 3){ return }
  if($#{$this->{queue}} < 0){ return $this->Finished }
  roi:
  while(my $next = shift @{$this->{queue}}){
    if(-f $next->{file_name}) { next roi }
    my($sock, $pid) = $this->ReadWriteChild("ConstructRoiContour.pl");
    $this->{num_sub_procs} += 1;
    delete $this->{child_pid};
    store_fd($next, $sock);
    Dispatch::LineReader->new_fh($sock,
      $this->CreateNotifierClosure("NoOp"),
      $this->CreateNotifierClosure("RoiFinished", $next),
      $pid
    );
    unless($this->{Deleted}){
      return $this->KickList;
    }
  }
}
sub RequestNotify{
  my($this, $files, $callback) = @_;
  $this->{NotifyCallback} = $callback;
  $this->{NotifyFiles} = $files;
  $this->NotifyUp("PrefetchStatusChange");
}
sub RoiFinished{
  my($this, $next) = @_;
  if($this->{CleanedUp}){ return }
  $this->{num_sub_procs} -= 1;
  if($this->{NotifyCallback}){
    delete $this->{NotifyFiles}->{$next->{file_name}};
    unless(scalar keys %{$this->{NotifyFiles}}){
      my $cb = $this->{NotifyCallback};
      delete $this->{NotifyCallback};
      delete $this->{NotifyFiles};
      $this->NotifyUp("PrefetchStatusChange");
      &$cb();
    }
  }
  unless($this->{Deleted}){
    $this->KickList;
  }
}
sub Finished{
  my($this) = @_;
  if(exists $this->{NotifyCallback}){
    print STDERR "Prefetch Contours finished with notifications not posted:\n";
    if(exists $this->{NotifyFiles} && ref($this->{NotifyFiles}) eq "HASH"){
      for my $i (keys %{$this->{NotifyFiles}}){
        print STDERR "\t$i\n";
      }
    }
    delete $this->{NotifyCallback};
    delete $this->{NotifyFiles};
  }
  $this->NotifyUp("PrefetchStatusChange");
  $this->{Deleted} = 1;
  $this->DeleteSelf;
}
sub PrefetchStatus{
  my($this) = @_;
  my $waiting = (exists $this->{NotifyCallback}) ? "yes" : "no";
  return [["contours", $waiting, scalar(@{$this->{queue}})]];
}
1;
