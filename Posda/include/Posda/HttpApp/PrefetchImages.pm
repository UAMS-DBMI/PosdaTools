#!/usr/bin/perl -w
#$Source: /home/bbennett/pass/archive/Posda/include/Posda/HttpApp/PrefetchImages.pm,v $
#$Date: 2013/08/08 14:14:15 $
#$Revision: 1.7 $
#
use strict;
package Posda::HttpApp::PrefetchImages;
use Dispatch::LineReader;
use Dispatch::NamedObject;
use Storable qw ( store_fd fd_retrieve );
use Debug;
my $dbg = sub {print STDERR @_ };
use vars qw( @ISA );
@ISA = ( "Dispatch::NamedObject" );
sub new {
  my($class, $sess, $path, $cache_dir, $sel_image, $wc, $ww) = @_;
  my $this = Dispatch::NamedObject->new($sess, $path);
  bless $this, $class;
  $this->{Exports}->{PrefetchStatus} = 1;
  $this->{cache_dir} = $cache_dir;
  unless(-d $cache_dir) {
    unless(mkdir($cache_dir)){ die "can't mkdir $cache_dir" }
  }
  $this->{sel_image} = $sel_image;
  $this->{window_center} = $wc;
  $this->{window_width} = $ww;
  $this->{num_sub_procs} = 0;
  $this->{ImportsFromAbove}->{PrefetchStatusChange} = 1;
  $this->{ImportsFromAbove}->{GetSelectedImageSet} = 1;
  $this->Init;
  return $this;
}
sub Init{
  my($this) = @_;
  $this->{queue} = [];
  $this->{image_list} = $this->RouteAbove("GetSelectedImageSet");;
  my $fm = $this->get_obj("FileManager");
  my @list_of_images;
  img:
  for my $img (@{$this->{image_list}}){
    my $ds_digest = $img->{dataset_digest};
    my $file_name = $img->{file};
    my $info = $fm->DicomInfo($file_name);
    unless(defined($info) && ref($info) eq "HASH"){next info}
    my $sop = $img->{sop};
    my $root = $this->GrayJpegRoot($img->{ds_digest});
    my $gray_file_name = "$root.gray";
    my $jpeg_file_name = "$root.jpeg";
    my $bytes;
    my $bits_alloc = $info->{"(0028,0100)"};
    if    ($bits_alloc == 8) { $bytes = 1 }
    elsif ($bits_alloc == 16){ $bytes = 2 }
    elsif ($bits_alloc == 32){ $bytes = 4 }
    else { die "unsupported bits_alloc: $bits_alloc" }
    my $signed = $info->{"(0028,0103)"};
    unless($signed) { $signed = 0 }
    my($pixel_offset, $pixel_length) = $fm->PixelDataInfo($file_name);
    if(-f $jpeg_file_name) { next img }
    push(@list_of_images, {
      source_file_name => $file_name,
      pixel_offset => $pixel_offset,
      pixel_length => $pixel_length,
      gray_file_name => $gray_file_name,
      jpeg_file_name => $jpeg_file_name,
      bytes => $bytes,
      signed => $signed,
      norm_z => $info->{norm_z},
      rows => $info->{"(0028,0010)"},
      cols => $info->{"(0028,0011)"},
      slope => $info->{"(0028,1053)"},
      intercept => $info->{"(0028,1052)"},
      sop => $sop,
      window_center => $this->{window_center},
      window_width => $this->{window_width},
    });
  }
  if(exists $this->{sel_image}->{z}){
    my @extract_list = sort 
      { 
        abs($a->{norm_z} - $this->{sel_image}->{z})
        <=>
        abs($b->{norm_z} - $this->{sel_image}->{z})
      }
      @list_of_images;
    $this->{queue} = \@extract_list;
  } else {
    $this->{queue} = \@list_of_images;
  }
#  print STDERR "extract list: ";
#  Debug::GenPrint($dbg, $this->{queue}, 1);
#  print STDERR "\n";
  $this->KickList;
}
sub CleanUp{
  my($this) = @_;
  delete $this->{queue};
  $this->{CleanedUp} = 1;
}
sub GrayJpegRoot{
  my($this, $ds_digest) = @_;
  unless($this->{window_center}) { $this->{window_center} = 20 }
  unless($this->{window_width}) { $this->{window_width} = 470 }
  return("$this->{cache_dir}/" .
    "$ds_digest" .
    "_$this->{window_center}" . "_$this->{window_width}");
}
sub Reset{
  my($this, $sel_image, $wc, $ww) = @_;
  $this->{sel_image} = $sel_image;
  $this->{window_center} = $wc;
  $this->{window_width} = $ww;
  $this->Init;
}
sub KickList{
  my($this) = @_;
  if($this->{num_sub_procs} > 0){ return }
  if($#{$this->{queue}} < 0){ return $this->Finished }
  image:
  while(my $next = shift @{$this->{queue}}){
    if(-f $next->{jpeg_file_name}) { next image }
    my($sock, $pid) = $this->ReadWriteChild("PrefetchImagePixels.pl");
    $this->{num_sub_procs} += 1;
    delete $this->{child_pid};
    store_fd($next, $sock);
    Dispatch::LineReader->new_fh($sock,
      $this->CreateNotifierClosure("NoOp"),
      $this->CreateNotifierClosure("ImageFinished", $next),
      $pid
    );
    return $this->KickList;
  }
}
sub RequestNotify{
  my($this, $jpeg, $callback) = @_;
  $this->{Notify}->{$jpeg} = $callback;
  $this->NotifyUp("PrefetchStatusChange");
}
sub ImageFinished{
  my($this, $next) = @_;
  if($this->{CleanedUp}) { return }
  $this->{num_sub_procs} -= 1;
  if($this->{Notify}->{$next->{jpeg_file_name}}){
    my $callback = $this->{Notify}->{$next->{jpeg_file_name}};
    delete $this->{Notify}->{$next->{jpeg_file_name}};
    $this->NotifyUp("PrefetchStatusChange");
    &$callback();
  }
  unless($this->{Deleted}){
    $this->KickList;
  }
}
sub Finished{
  my($this) = @_;
  if(
    exists $this->{Notify} &&
    ref($this->{Notify}) eq "HASH" &&
    scalar(keys %{$this->{Notify}})
  ){
    print STDERR "Prefetch Images finished with notifications not posted:\n";
    for my $i (keys %{$this->{Notify}}){
      print STDERR "\t$i\n";
    }
    delete $this->{Notify};
  }
  $this->NotifyUp("PrefetchStatusChange");
  $this->{Deleted} = 1;
  $this->DeleteSelf;
}
sub PrefetchStatus{
  my($this) = @_;
  my $waiting = (exists $this->{NotifyCallback}) ? "yes" : "no";
  return [["images", $waiting, scalar(@{$this->{queue}})]];
}
1;
