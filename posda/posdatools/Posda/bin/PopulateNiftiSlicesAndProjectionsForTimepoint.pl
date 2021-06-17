#!/usr/bin/perl -w
use strict;
use Posda::BackgroundProcess;
use Posda::DB qw(Query);
use File::Temp;
use Nifti::Parser;
use FileHandle;
use Digest::MD5;
use Debug;
my $dbg = sub { print STDERR @_ };

my $usage = <<EOF;
Usage:
PopulateNiftiSlicesAndProjectionsForTimepoint.pl <?bkgrnd_id?> <activity_id> <notify>
or
PopulateNiftiSlicesAndProjectionsForTimepoint.pl -h

Expects no lines on STDIN

uses queries:
  FileIdTypePathFromActivity
  ChangeFileType
  NiftiSlicesByNiftiFile
  NiftiVolRenderingsByNiftiId
  GetImportEventIdByImportComment
  FileNameFileIdInImportById
  CreateNiftiJpegSlice
  CreateNiftiJpegVolProjection

EOF

if($#ARGV == 0  && $ARGV[0] eq -h ) {
  print STDOUT  "$usage\n";
  exit;
 }
if($#ARGV != 2){ die "Wrong args: $usage\n" }
my($invoc_id, $act_id, $notify) = @ARGV;

print "Forking background process\n";
#############################
# This is code which sets up the Background Process and Starts it
my $b = Posda::BackgroundProcess->new($invoc_id, $notify, $act_id);
$b->Daemonize;
# now in the background...
$b->SetActivityStatus("Finding Files in Timepoint");
my %NiftiFilesInTp;
my $files_found = 0;
my $nifti_files_found = 0;
Query("FileIdTypePathFromActivity")->RunQuery(sub{
  my($row) = @_;
  my($file_id, $file_type, $path) = @$row;
  $files_found += 1;
  my $nifti = Nifti::Parser->new($path);
  if(defined $nifti){
    $nifti_files_found += 1;
    $NiftiFilesInTp{$file_id} = $nifti;
    $nifti->Close;
    if($file_type ne "Nifti Image"){
      Query("ChangeFileType")->RunQuery(sub{}, sub{}, "Nifti Image", $file_id);
    }
  } else  {
#    $b->WriteToEmail("failed to nifti parse: $path\n");
  }
  $b->SetActivityStatus("Found $nifti_files_found of $files_found examined");
}, sub {}, $act_id);
$b->WriteToEmail("Found $nifti_files_found nifti files in " .
  "$files_found files in latest timepoint for activity $act_id\n");
my $tmp_dir = File::Temp->newdir;
$b->WriteToEmail("temp dir: $tmp_dir\n");
nifti_file:
for my $nfid (keys %NiftiFilesInTp){
  my $nifti = $NiftiFilesInTp{$nfid};
  my $nifti_file_path = $nifti->{file_name};
  my $start_file_processing = time;
  $b->WriteToEmail("processing nifti_file $nifti_file_path\n");

  my %NiftiSlicesInDb;
  my %NiftiVolProjectionsInDb;
  my %NiftiFileProjectionsInDb;


  my($num_slices, $num_vols) = $nifti->NumSlicesAndVols;
  my $expected_slice_renderings = $num_vols * $num_slices * 2;
  my $expected_vol_projections = $num_vols * 3;
  my $expected_file_projections = 3;

  my $slice_renderings_found = 0;
  Query("NiftiSlicesByNiftiFile")->RunQuery(sub {
    my($row) = @_;
    my($vol_num, $slice_num, $flipped, $jpeg_file_id) = @$row;
    $slice_renderings_found += 1;
    my $flip_stat = $flipped ? "f" : "n";
    $NiftiSlicesInDb{$vol_num}->{$slice_num}->{$flip_stat} = $jpeg_file_id;
  }, sub{}, $nfid);

  my $volume_projections_found = 0;
  Query("NiftiVolRenderingsByNiftiId")->RunQuery(sub{
    my($row) = @_;
    $volume_projections_found += 1;
    my($vol_num, $proj_type, $jpeg_file_id) = @$row;
    $NiftiVolProjectionsInDb{$vol_num}->{$proj_type} = $jpeg_file_id;
  }, sub{}, $nfid);

  my $file_projections_found = 0;
  Query("NiftiFileRenderingsByNiftiId")->RunQuery(sub{
    my($row) = @_;
    $file_projections_found += 1;
    my($proj_type, $jpeg_file_id) = @$row;
    $NiftiFileProjectionsInDb{$proj_type} = $jpeg_file_id;
  }, sub{}, $nfid);

  $b->WriteToEmail("Found $slice_renderings_found renderings of ".
    "$expected_slice_renderings\n");
  $b->WriteToEmail("Found $volume_projections_found volume projections of ".
    "$expected_vol_projections\n");
  $b->WriteToEmail("Found $file_projections_found file projections of ".
    "$expected_file_projections\n");

  my $ImportComment = "RenderingSlicesAndProjections for Nifti file $nfid";
  my $now = time;
  my $ctx = Digest::MD5->new;
  $ctx->add($ImportComment);
  $ctx->add($now);
  my $hash = $ctx->hexdigest;
  my $short = substr($hash, 10, 5);
  $ImportComment = "($short)$ImportComment";

  my $slices_rendered = 0;
  my $slices_to_render = $expected_slice_renderings - $slice_renderings_found;
  my $vols_to_render = $expected_vol_projections - $volume_projections_found;
  my $files_to_render = $expected_file_projections - $file_projections_found;
  my $total_to_render = $slices_to_render + $vols_to_render + $files_to_render;
  #print STDERR
  #  "Nifti file: $nfid\n" .
  #  "slices to render: $slices_to_render\n" .
  #  "vols to render: $vols_to_render\n" .
  #  "files to render: $files_to_render\n" .
  #  "total to render: $total_to_render\n";
  if($total_to_render < 0){
    my $elapsed = time - $start_file_processing;
    $b->WriteToEmail("Nothing to render for nifti_file $nfid " .
      "($elapsed seconds)\n");
    next nifti_file;
  }
  open IMPORT, "|ImportMultipleFilesIntoPosda.pl \"$ImportComment\"" or 
    die "Can't open importer";
  my @JpegsRendered;
  my $start_slice_rendering = time;
  if($slices_to_render > 0){
    slice_rendering:
    for my $vol(0 .. $num_vols - 1){
      for my $slice (0 .. $num_slices - 1){
        for my $flip_stat ("f", "n"){
          if(exists $NiftiSlicesInDb{$vol}->{$slice}->{$flip_stat}){
            next slice_rendering;
          }
          if($slices_rendered == $slices_to_render){
             print STDERR "Hmmm -this doesn't look right:\n";
             print STDERR "$vol, $slice, $flip_stat\n";
             print STDERR "NiftiSlicesInDb: ";
             Debug::GenPrint($dbg, \%NiftiSlicesInDb, 1);
             print STDERR "\n";
             last slice_rendering;
          }
          $slices_rendered += 1;
          my $cmd = "ExtractNiftiSlice.pl $nfid $nifti_file_path $vol $slice " .
            " $flip_stat $tmp_dir";
          open SUB, "$cmd|" or die "can't open cmd: $cmd\n";
          my $jpeg_file_path;
          while(my $line = <SUB>){
            chomp $line;
            if($line =~ /Jpeg: (.*)$/){
              $jpeg_file_path = $1;
            }
          }
          if(defined $jpeg_file_path){
            print IMPORT "$jpeg_file_path\n";
            push @JpegsRendered, [$jpeg_file_path, "slice", $nfid, $vol,
              $slice, $flip_stat];
          } else {
            $b->WriteToEmail("Couldn't find jpeg: $vol $slice $flip_stat\n");
          }
          $b->SetActivityStatus("Rendered $slices_rendered slices " .
            "(of $slices_to_render) for file: $nfid");
          if($slices_rendered == $slices_to_render){ last slice_rendering }
        }
      }
    }
  }
  my $slice_rendering_time = time - $start_slice_rendering;
  my $vol_rendering_start = time;
  if($vols_to_render > 0){
    #print STDERR "Rendering $vols_to_render volumes\n";
    vol_rendering:
    for my $vol (0 .. $num_vols - 1){
      my $vol_needed = 0;
      my @types_needed;
      if(exists $NiftiVolProjectionsInDb{$vol}){
        for my $t ("avg", "max", "min"){
          unless(exists $NiftiVolProjectionsInDb{$vol}->{$t}){
            $vol_needed = 1;
            push @types_needed, $t;
          }
        }
      } else {
        $vol_needed = 1;
        push @types_needed, "avg";
        push @types_needed, "max";
        push @types_needed, "min";
      }
      if($vol_needed){
        my $cmd = "ProjectNiftiVolume.pl $nfid $nifti_file_path $vol $tmp_dir";
        $b->SetActivityStatus("Rendering volume projection $nfid $vol");
        open REND, "$cmd|" or die "can't open $cmd\n";
        my %type_to_file;
        type:
        while(my $line = <REND>){
          chomp $line;
          if($line =~ /Jpeg (.*): (.*)$/){
            my $type = $1;
            my $file = $2;
            $type_to_file{$type} = $file;
          }
        }
        close REND;
        type:
        for my $t (@types_needed){
          unless (exists $type_to_file{$t}){
            print STDERR "projection type $t not rendered for volume $vol of " .
              "file $nfid\n";
            next type;
          }
          my $file = $type_to_file{$t};
          print IMPORT "$file\n";
          push @JpegsRendered, [$file, "file_vol_proj", $nfid, $vol, $t];
        }
      }
    }
  }
  my $vol_rendering_time = time -$vol_rendering_start;
  my $projection_rendering_start = time;
  if($files_to_render > 0){
    my @types_needed;
    for my $t ("avg", "min", "max"){
      unless(exists $NiftiFileProjectionsInDb{$t}){
        push @types_needed, $t;
      }
    }
    if($#types_needed >= 0){
      my $cmd = "ProjectNiftiFile.pl $nfid $nifti_file_path $tmp_dir";
      $b->SetActivityStatus("Rendering file projection $nfid");
      open REND, "$cmd|" or die "can't open $cmd\n";
      my %type_to_file;
      type:
      while(my $line = <REND>){
        chomp $line;
        if($line =~ /Jpeg (.*): (.*)$/){
          my $type = $1;
          my $file = $2;
          $type_to_file{$type} = $file;
        }
      }
      close REND;
      type:
      for my $t (@types_needed){
        unless (exists $type_to_file{$t}){
          print "projection type $t not rendered for file $nfid\n";
          next type;
        }
        my $file = $type_to_file{$t};
        print IMPORT "$file\n";
        push @JpegsRendered, [$file, "file_proj", $nfid, $t];
      }
    }
  }
  my $projection_rendering_time = time - $projection_rendering_start;
  my $db_update_start = time;
  close IMPORT;
  my $import_event_id;
  Query("GetImportEventIdByImportComment")->RunQuery(sub {
    my($row) = @_;
    $import_event_id = $row->[0];
  }, sub{}, $ImportComment);
  unless(defined $import_event_id) {
    $b->WriteToEmail("Couldn't retrieve import_event_id for $nfid\n");
  }
  my %ImportedFileToFileId;
  Query('FileNameFileIdInImportById')->RunQuery(sub{
    my($row) = @_;
    my($file_name, $file_id) = @$row;
    $ImportedFileToFileId{$file_name} = $file_id;
  }, sub{}, $import_event_id);
  my $files_imported = 0;
  my $num_jpegs_rendered = @JpegsRendered;
  $b->SetActivityStatus("Inserting rows in db for $num_jpegs_rendered " .
    "rendered jpegs");
  for my $r (@JpegsRendered){
    my $file_name = $r->[0];
    my $render_type = $r->[1];
    my $file_id = $ImportedFileToFileId{$file_name};
    if(defined $file_id){
      if($render_type eq "slice"){
        my $nifti_file_id = $r->[2];
        my $vol = $r->[3];
        my $slice = $r->[4];
        my $flipped = ($r->[5] eq 'f') ? 1 : 0;
        Query('CreateNiftiJpegSlice')->RunQuery(sub{}, sub {},
        $nfid, $vol, $slice, $flipped, $file_id);
        $files_imported += 1;
      } elsif($render_type eq "file_vol_proj"){
        # push @JpegsRendered, [$file, "file_vol_proj", $nfid, $vol, $t];
        my $nifti_file_id = $r->[2];
        my $vol = $r->[3];
        my $proj_type = $r->[4];
        Query('CreateNiftiJpegVolProjection')->RunQuery(sub{}, sub {},
        $nfid, $vol, $proj_type, $file_id);
        $files_imported += 1;
      } elsif($render_type eq "file_proj"){
        # push @JpegsRendered, [$file, "file_proj", $nfid, $t];
        my $nifti_file_id = $r->[2];
        my $proj_type = $r->[3];
        Query('CreateNiftiJpegProjection')->RunQuery(sub{}, sub {},
        $nfid, $proj_type, $file_id);
        $files_imported += 1;
      }
    } else {
      print STDERR "Couldn't find imported file $file_name $nfid\n";
    }
  }
  my $db_update_time = time - $db_update_start;
  $b->WriteToEmail("$files_imported rendered jpegs for $nfid\n" .
    "$slice_rendering_time secs rendering slices; " .
    "$vol_rendering_time secs rendering volumes; " .
    "$projection_rendering_time secs rendering projection; " .
    "$db_update_time updating db\n"
  );
}

$b->Finish("Done: $nifti_files_found found of $files_found");
