package Posda::FileVisualizer::StructureSet::BulkRenderRoiSlices;;
use strict;

use Posda::PopupWindow;
use Posda::DB qw( Query );
use Posda::Try;
use Posda::FlipRotate;
use Posda::File::Import 'insert_file';
use Posda::Config 'Config';
use Digest::MD5;
use File::Temp qw/ tempfile /;

use Redis;
use constant REDIS_HOST => Config('redis_host') . ':6379';

my $redis = undef;
sub ConnectToRedis {
  unless($redis) {
    $redis = Redis->new(server => REDIS_HOST);
  }
}
sub QuitRedis {
  if ($redis) {
    $redis->quit;
  }
  $redis = undef;
}



use vars qw( @ISA );
@ISA = ("Posda::FileVisualizer");

sub SpecificInitialize {
  my ($self, $params) = @_;
  $self->{title} = "Bulk Roi Slice Renderer";
  $self->{params} = $params;
  $self->PrepareInputForBackgrounder;
  $self->{mode} = "waiting";
}

sub ContentResponse {
  my ($self, $http, $dyn) = @_;
  if($self->{mode} eq "waiting"){
  $http->queue("To send to subprocess:<pre>");
  for my $i (@{$self->{render_lines}}){
    $http->queue("$i\n");
  }
  $http->queue("</pre>");
  } elsif ($self->{mode} eq "queued"){
    $http->queue("Queued background job: $self->{work_id}");
  } else {
    $http->queue("Unknown mode: \"$self->{mode}\"");
  }
}

sub MenuResponse{
  my ($self, $http, $dyn) = @_;
  unless($self->{mode} eq "queued"){
    $self->NotSoSimpleButton($http, {
      op => "StartBackgroundProcess",
      caption => "Start",
      sync => "Reload();"
    });
  }
}

sub PrepareInputForBackgrounder{
  my ($self) = @_;
  my $params = $self->{params};
  my @rend;
  $self->{render_lines} = \@rend;
  push(@rend, "Structure Set File Id: $params->{file_id}");
  push(@rend, "Structure Set File Path: $params->{file_path}");
  my $selected_rois = $params->{SelectedRoi};
  for my $roi (keys %{$selected_rois}){
    push @rend, "BEGIN ROI: $roi";
    $self->SlicesForRoi($roi, \@rend);
    push @rend, "END ROI: $roi";
  }
}

sub SlicesForRoi{
  my ($self, $roi, $rend) = @_;
  my $roi_p = $self->{params}->{Rois}->{$roi};
  sop:
  for my $sop (keys %{$roi_p->{referencing_contours_by_reference}}){
    if(exists $self->{params}->{AlreadyRendered}->{$roi}->{$sop}){ next sop }
    my $sop_d = $self->GetSopData($sop);
    my $c_list = $roi_p->{referencing_contours_by_reference}->{$sop};
    my $i_file_id = $sop_d->{file_id};
    push @$rend, "BEGIN SLICE: $i_file_id";
    $self->RenderContour($rend, $roi, $sop_d, $c_list);
    push @$rend, "END SLICE: $i_file_id";
  }
}

sub RenderContour{
  my($self, $rend, $roi, $sop_d, $c_list) = @_;
  my @iop = split(/\\/, $sop_d->{iop});
  my @ipp = split(/\\/, $sop_d->{ipp});
  my @pix_sp = split(/\\/, $sop_d->{pixel_spacing});
  my $rows = $sop_d->{pixel_rows};
  my $cols = $sop_d->{pixel_columns};
  push @$rend, sprintf("Iop: (%s,%s,%s),(%s,%s,%s)",
    $iop[0],$iop[1],$iop[2],$iop[3],$iop[4],$iop[5]);
  push @$rend, sprintf("Ipp: (%s,%s,%s)",
    $ipp[0],$ipp[1],$ipp[2]);
  push @$rend, sprintf("Pix sp: (%s,%s)",
    $pix_sp[0],$pix_sp[1]);
  push @$rend, "Rows: $rows";
  push @$rend, "Cols: $cols";
  my $cont_p = $self->{params}->{Rois}->{$roi}->{contours};
  for my $i (@$c_list){
    my $c_p = $cont_p->[$i];
    push @$rend, "CONTOUR: ($c_p->{ds_offset},$c_p->{length}," .
      "$c_p->{num_pts})";
  }
}

sub GetSopData{
  my ($self, $sop) = @_;
  for my $series (keys %{$self->{params}->{Series}}){
    if(
      exists $self->{params}->{Series}->
        {$series}->{img_list}->{$sop}
    ){
      return $self->{params}->{Series}
          ->{$series}->{img_list}->{$sop};
    }
  }
  return undef;
}

sub StartBackgroundProcess{
  my ($self, $http, $dyn) = @_;
  #create subprocess_invocation row
  my $new_id = Query("CreateSubprocessInvocationButton")
    ->FetchOneHash(undef, 'background',
      "RenderSliceFromContours.pl <?bkgrnd_id?> " .
      "$self->{params}->{activity_id} " .
      "$self->{params}->{notify}",
      undef,
      $self->get_user, 'RenderSliceFromContours'
    )->{subprocess_invocation_id};
  unless($new_id) {
    die "Couldn't create row in subprocess_invocation";
  }

  #create input_file
  my ($fh,$tempfilename) = tempfile();
  for my $i (@{$self->{render_lines}}){
    print $fh "$i\n";
  }
  close $fh;

  #call API to import
  my $worker_input_file_id;
  my $resp = Posda::File::Import::insert_file($tempfilename);
  if ($resp->is_error){
      die $resp->error;
  }else{
    $worker_input_file_id =  $resp->file_id;
  }
  unlink $tempfilename;

  # add to the work table for worker nodes
  my $priority = 1;
  my $work_id = Query("CreateNewWorkWithPriority")
                ->FetchOneHash($new_id,
                  $worker_input_file_id, "work_queue_$priority")
                ->{work_id};


  ConnectToRedis();
  unless($redis){
    die "Couldn't connect to redis";
  }
  $redis->lpush("work_queue_$priority", $work_id);
  QuitRedis();

  $self->{mode} = "queued";
  $self->{work_id} = $work_id;

}
1;
