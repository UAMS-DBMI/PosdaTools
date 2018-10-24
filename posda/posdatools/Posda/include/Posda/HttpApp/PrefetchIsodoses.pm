#!/usr/bin/perl -w
#
use strict;
package Posda::HttpApp::PrefetchIsodoses;
use Dispatch::LineReader;
use Dispatch::NamedObject;
use Storable qw ( store_fd fd_retrieve );
use Debug;
my $dbg = sub {print @_ };
use vars qw( @ISA );
@ISA = ( "Dispatch::NamedObject" );
sub new {
  my($class, $sess, $path, $cache_dir, $sel_dose_op, $s_image) = @_;
  my $this = Dispatch::NamedObject->new($sess, $path);
  bless $this, $class;
  $this->{Exports}->{PrefetchStatus} = 1;
  $this->{cache_dir} = $cache_dir;
  unless(-d $cache_dir) {
    unless(mkdir($cache_dir)){ die "can't mkdir $cache_dir" }
  }
  $this->{sel_dose} = $sel_dose_op;
  $this->{s_image} = $s_image;
  $this->{num_sub_procs} = 0;
  $this->{ImportsFromAbove}->{PrefetchStatusChange} = 1;
  $this->Init;
  return $this;
}
sub Init{
  my($this) = @_;
  $this->{queue} = [];
  $this->{ImageList} = $this->RouteAbove("GetSelectedImageSet");
  my $fm = $this->get_obj("FileManager");
  unless(
    exists $this->{sel_dose}->{dose_file} &&
    -f $this->{sel_dose}->{dose_file}
  ){ return }
  my $dose_info = $fm->DicomInfo($this->{sel_dose}->{dose_file});
  my $d_dig = $this->{sel_dose}->{dose_dig};
  my @IsoDoseList;
  if(exists $this->{ImageList} && ref($this->{ImageList}) eq "ARRAY"){
    for my $i (@{$this->{ImageList}}){
      my $z = $i->{z};
      my $i_dig = $i->{ds_dig};
      my $img_info = $fm->DicomInfo($i->{file});
      my $base_file = "$this->{cache_dir}/$d_dig" . "_$z.iso";
      my @levels;
      for my $j (keys %{$this->{sel_dose}->{isodoses}}){
        my $level = sprintf("%05d", 
          1000 * $this->{sel_dose}->{isodoses}->{$j}->{GyValue});
        push(@levels, $level);
      }
      my $cmd = "IsoDoseExtraction.pl";
      my @slice_iop = split(/\\/, $img_info->{norm_iop});
      my @dose_iop = split(/\\/, $dose_info->{norm_iop});
      my $slice_ipp =
        [$img_info->{norm_x}, $img_info->{norm_y}, $img_info->{norm_z}];
      my $dose_ipp =
        [$dose_info->{norm_x}, $dose_info->{norm_y}, $dose_info->{norm_z}];
      my @slice_pix_sp = split(/\\/, $img_info->{"(0028,0030)"});
      my @dose_pix_sp = split(/\\/, $dose_info->{"(0028,0030)"});
      my($d_pix_off, $d_pix_len) = $fm->PixelDataInfo(
        $this->{sel_dose}->{dose_file});
      my $dose_gfov_len = $dose_info->{gfov_len};
      my $ds_off = $fm->GetDsOffset($this->{sel_dose}->{dose_file});
      my $dose_gfov_off = $ds_off + $dose_info->{ds_gfov_offset};
      my $args = {
        z => $z,
        slice_iop => [
          [$slice_iop[0], $slice_iop[1], $slice_iop[2]],
          [$slice_iop[3], $slice_iop[4], $slice_iop[5]],
        ],
        slice_ipp => $slice_ipp,
        slice_rows => $img_info->{"(0028,0010)"},
        slice_cols => $img_info->{"(0028,0011)"},
        slice_pix_sp => \@slice_pix_sp,
        dose_file_name => $this->{sel_dose}->{dose_file},
        dose_iop => [
          [$dose_iop[0], $dose_iop[1], $dose_iop[2]],
          [$dose_iop[3], $dose_iop[4], $dose_iop[5]],
        ],
        dose_ipp => $dose_ipp,
        dose_pix_offset => $d_pix_off,
        dose_pix_length => $d_pix_len,
        dose_rows => $dose_info->{"(0028,0010)"},
        dose_cols => $dose_info->{"(0028,0011)"},
        dose_gfov_offset => $dose_gfov_off,
        dose_gfov_length => $dose_gfov_len,
        dose_bytes => ($dose_info->{"(0028,0100)"} == 32) ? 4 : 2,
        dose_pix_sp => \@dose_pix_sp,
        dose_scaling => $dose_info->{"(3004,000e)"},
        dose_units => ($dose_info->{"(3004,0002)"} eq "GY") ? "GRAY" : "CGRAY",
        base_isodose_file_name => $base_file,
        levels => \@levels,
      };
      level:
      for my $i (@levels){
        unless(-f "$base_file" . "_$i" . "_0"){
          push(@IsoDoseList, $args);
          last level
        }
      }
    }
  }
  $this->{queue} = [
    sort
    {
       abs($a->{z} - $this->{s_image}->{z})
         <=>
       abs($b->{z} - $this->{s_image}->{z})
     }
     @IsoDoseList
  ];
  $this->KickList;
}
sub CleanUp{
  my($this) = @_;
  delete $this->{queue};
  $this->{CleanedUp} = 1;
}
sub Reset{
  my($this, $sel_dose_op, $s_image) = @_;
  $this->{sel_dose} = $sel_dose_op;
  $this->{s_image} = $s_image;
  $this->Init;
}
sub KickList{
  my($this) = @_;
  if($this->{Deleted}) {
    print STDERR "$this->{path}: calling KickList when deleted\n";
    return;
  }
  if($this->{num_sub_procs} > 1){ return }
  if($#{$this->{queue}} < 0){ return $this->Finished }
  iso_dose:
  while(my $next = shift @{$this->{queue}}){
    my($sock, $pid) = $this->ReadWriteChild("IsoDoseExtraction.pl");
    $this->{num_sub_procs} += 1;
    delete $this->{child_pid};
    store_fd($next, $sock);
    Dispatch::LineReader->new_fh($sock,
      $this->CreateNotifierClosure("NoOp"),
      $this->CreateNotifierClosure("IsodoseFinished", $next),
      $pid
    );
    return $this->KickList;
  }
}
sub RequestNotify{
  my($this, $files, $callback) = @_;
  $this->{NotifyCallback} = $callback;
  $this->{NotifyFiles} = $files;
  $this->NotifyUp("PrefetchStatusChange");
}
sub IsodoseFinished{
  my($this, $next) = @_;
  if($this->{CleanedUp}) { return };
  $this->{num_sub_procs} -= 1;
  if($this->{NotifyCallback}){
    delete $this->{NotifyFiles}->{$next->{base_isodose_file_name}};
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
  $this->NotifyUp("PrefetchStatusChange");
  $this->{Deleted} = 1;
  $this->DeleteSelf;
}
sub PrefetchStatus{
  my($this) = @_;
  my $waiting = (exists $this->{NotifyCallback}) ? "yes" : "no";
  return [["isodoses", $waiting, scalar(@{$this->{queue}})]];
}
1;
