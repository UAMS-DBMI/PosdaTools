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
PopulateNiftiSlicesAndProjectionsForTimepoint.pl <?bkgrnd_id?> <activity_id> <notify> <render_slices> <render_volumes> <render_projections> <verbose>
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
if($#ARGV != 6){ die "Wrong args: $usage\n" }
my($invoc_id, $act_id, $notify,
   $render_slices, $render_volumes, $render_projections, $verbose) = @ARGV;

print "Forking background process\n";
#############################
# This is code which sets up the Background Process and Starts it
my $b = Posda::BackgroundProcess->new($invoc_id, $notify, $act_id);
$b->Daemonize;
# now in the background...
my $tmp_dir = File::Temp->newdir;
$b->WriteToEmail("temp dir: $tmp_dir\n");
$b->SetActivityStatus("Finding Files in Timepoint");
my %NiftiFilesInTp;
my $files_found = 0;
my $nifti_files_found = 0;
my $find_start = time;
Query("FileIdTypePathFromActivity")->RunQuery(sub{
  my($row) = @_;
  my($file_id, $file_type, $path) = @$row;
  $files_found += 1;
  my $nifti;
  if($file_type =~ /gzip/){
    $nifti = Nifti::Parser->new_from_zip($path, $file_id, $tmp_dir);
  } else {
    $nifti = Nifti::Parser->new($path);
  }
  if(defined $nifti){
    $nifti_files_found += 1;
    $NiftiFilesInTp{$file_id} = $nifti;
    $nifti->Close;
    unless($file_type =~ /Nifti Image/){
      my $new_file_type = "Nifti Image";
      if($file_type =~ /gzip/){
        $new_file_type .= " (gzipped)";
      }
      Query("ChangeFileType")->RunQuery(sub{}, sub{}, $new_file_type, $file_id);
    }
  } else  {
#    $b->WriteToEmail("failed to nifti parse: $path\n");
  }
  $b->SetActivityStatus("Found $nifti_files_found of $files_found examined");
}, sub {}, $act_id);
my $find_time = time - $find_start;
$b->WriteToEmail("Found $nifti_files_found nifti files in " .
  "$files_found files in latest timepoint for activity $act_id\n");
$b->WriteToEmail("Find took $find_time seconds\n");
my $num_niftis = keys %NiftiFilesInTp;
my $current_file = 0;
nifti_file:
for my $nfid (keys %NiftiFilesInTp){
  $current_file += 1;
  my $nifti = $NiftiFilesInTp{$nfid};
  my $nifti_file_path = $nifti->{file_name};
  my $start_file_processing = time;
  my $FileMessage = "File $nfid ($current_file of $num_niftis) TempDir: $tmp_dir";
  if($verbose > 0){
    $b->WriteToEmail("Processing ($FileMessage) $nifti_file_path\n");
  }

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

  if($verbose > 1){
    $b->WriteToEmail("Found $slice_renderings_found slice renderings of ".
      "$expected_slice_renderings\n");
    $b->WriteToEmail("Found $volume_projections_found volume projections of ".
      "$expected_vol_projections\n");
    $b->WriteToEmail("Found $file_projections_found file projections of ".
      "$expected_file_projections\n");
  }

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
  if($total_to_render <= 0){
    my $elapsed = time - $start_file_processing;
    if($verbose > 1){
      $b->WriteToEmail("Nothing to render for nifti_file $nfid " .
        "($elapsed seconds)\n");
    }
    next nifti_file;
  }
  my @JpegsRendered;
  my $start_slice_rendering = time;
  if($render_slices){
    my $open_start = time;
    $nifti->Open;
    my $open_time = time - $open_start;
    if($verbose > 1){
      $b->WriteToEmail("$open_time seconds opening $FileMessage\n");
    }
    open IMPORT, "|ImportMultipleFilesIntoPosda.pl \"$ImportComment\"" or 
      die "Can't open importer";
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
  #          my $cmd = "ExtractNiftiSlice.pl $nfid $nifti_file_path $vol $slice " .
  #            " $flip_stat $tmp_dir";
  #          open SUB, "$cmd|" or die "can't open cmd: $cmd\n";
  #          my $jpeg_file_path;
  #          while(my $line = <SUB>){
  #            chomp $line;
  #            if($line =~ /Jpeg: (.*)$/){
  #              $jpeg_file_path = $1;
  #            }
  #          }
  #          if(defined $jpeg_file_path){
  #            print IMPORT "$jpeg_file_path\n";
  #            push @JpegsRendered, [$jpeg_file_path, "slice", $nfid, $vol,
  #              $slice, $flip_stat];
  #          } else {
  #            $b->WriteToEmail("Couldn't find jpeg: $vol $slice $flip_stat\n");
  #          }
            my $to_root = "nifti_$nfid" . "_$vol" . "_$slice";
            if($flip_stat eq "f"){
              $to_root .= "_f";
            } else {
              $to_root .= "_n";
            }
            my $gray_file = "$tmp_dir/$to_root.gray";
            my $jpeg_file = "$tmp_dir/$to_root.jpeg";
            print "Gray: $gray_file\n";
            print "Jpeg: $jpeg_file\n";
            unless(open OUT, ">$gray_file"){
              die "Can't open $gray_file for write ($!)";
            }
            if($flip_stat eq "f"){
              $nifti->PrintSliceFlippedScaled($vol, $slice, *OUT);
            } else {
              print "Calling PrintSliceScaled\n";
              $nifti->PrintSliceScaled($vol, $slice, *OUT);
            }
            close OUT;
            my($rows,$cols,$bytes) = $nifti->RowsColsAndBytes;
            my $cmd = "convert -endian MSB -size $rows" . 'x' . "$cols " .
              "-depth 8 gray:$gray_file $jpeg_file";
            `$cmd`;
            unlink $gray_file;
            if(-r $jpeg_file){
              print IMPORT "$jpeg_file\n";
              push @JpegsRendered, [$jpeg_file, "slice", $nfid, $vol,
                $slice, $flip_stat];
            } else {
              die "Jpeg: $jpeg_file didn't render";
            }
            $b->SetActivityStatus("Rendered $slices_rendered slices " .
              "(of $slices_to_render) for $FileMessage");
            if($slices_rendered == $slices_to_render){ last slice_rendering }
          }
        }
      }
    }
  } else {
    if($verbose > 1){
      $b->WriteToEmail("Skipping slice rendering (by request) ");
    }
  }
  my $slice_rendering_time = time - $start_slice_rendering;
  my $vol_rendering_start = time;
  if($render_volumes && $vols_to_render > 0){
    #print STDERR "Rendering $vols_to_render volumes\n";
    my %type_to_file;
    vol_rendering:
    for my $vol (0 .. $num_vols - 1){
      $b->SetActivityStatus("Rendering vol $vol of $num_vols $FileMessage");
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
        my($rows, $cols, $depth) = $nifti->RowsColsAndBytes;
        my $gray_avg = "$tmp_dir/nifti_$nfid" . "_$vol" . "_p_avg.gray";
        my $gray_min = "$tmp_dir/nifti_$nfid" . "_$vol" . "_p_min.gray";
        my $gray_max = "$tmp_dir/nifti_$nfid" . "_$vol" . "_p_max.gray";
        my $jpeg_avg = "$tmp_dir/nifti_$nfid" . "_$vol" . "_p_avg.jpeg";
        my $jpeg_min = "$tmp_dir/nifti_$nfid" . "_$vol" . "_p_min.jpeg";
        my $jpeg_max = "$tmp_dir/nifti_$nfid" . "_$vol" . "_p_max.jpeg";
        open FILE, ">$gray_avg" or die "Can't open $gray_avg ($!0)";
        open FILE1, ">$gray_min" or die "Can't open $gray_min ($!0)";
        open FILE2, ">$gray_max" or die "Can't open $gray_max($!0)";
        $nifti->PrintNormalizedVolumeProjections($vol, \*FILE, \*FILE1, \*FILE2);
        close FILE;
        close FILE1;
        close FILE2;
        my $cmd1 = "convert -endian MSB -size $rows" . 'x' . "$cols " .
          "-depth 8 $gray_avg $jpeg_avg";
        my $cmd2 = "convert -endian MSB -size $rows" . 'x' . "$cols " .
          "-depth 8 $gray_max $jpeg_max";
        my $cmd3 = "convert -endian MSB -size $rows" . 'x' . "$cols " .
          "-depth 8 $gray_min $jpeg_min";
        `$cmd1`;
        `$cmd2`;
        `$cmd3`;
        unlink $gray_avg;
        unlink $gray_max;
        unlink $gray_min;
        if(-r $jpeg_avg){
          $type_to_file{avg} = $jpeg_avg;
        }
        if(-r $jpeg_max){
          $type_to_file{max} = $jpeg_max;
        }
        if(-r $jpeg_min){
          $type_to_file{min} = $jpeg_min;
        }
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
  if($render_projections && $files_to_render > 0){
    my @types_needed;
    $b->SetActivityStatus("Rendering full projection $FileMessage");
    for my $t ("avg", "min", "max"){
      unless(exists $NiftiFileProjectionsInDb{$t}){
        push @types_needed, $t;
      }
    }
    if($#types_needed >= 0){
      my %type_to_file;
      my($rows, $cols, $depth) = $nifti->RowsColsAndBytes;
      my $gray_avg = "$tmp_dir/nifti_$nfid" . "_p_avg.gray";
      my $gray_min = "$tmp_dir/nifti_$nfid" . "_p_min.gray";
      my $gray_max = "$tmp_dir/nifti_$nfid" . "_p_max.gray";
      my $jpeg_avg = "$tmp_dir/nifti_$nfid" . "_p_avg.jpeg";
      my $jpeg_min = "$tmp_dir/nifti_$nfid" . "_p_min.jpeg";
      my $jpeg_max = "$tmp_dir/nifti_$nfid" . "_p_max.jpeg";
      open FILE, ">$gray_avg" or die "Can't open $gray_avg ($!0)";
      open FILE1, ">$gray_min" or die "Can't open $gray_min ($!0)";
      open FILE2, ">$gray_max" or die "Can't open $gray_max($!0)";
      $nifti->PrintNormalizedFileProjections(\*FILE, \*FILE1, \*FILE2);
      close FILE;
      close FILE1;
      close FILE2;
      my $cmd1 = "convert -endian MSB -size $rows" . 'x' . "$cols " .
        "-depth 8 $gray_avg $jpeg_avg";
      my $cmd2 = "convert -endian MSB -size $rows" . 'x' . "$cols " .
        "-depth 8 $gray_max $jpeg_max";
      my $cmd3 = "convert -endian MSB -size $rows" . 'x' . "$cols " .
        "-depth 8 $gray_min $jpeg_min";
      `$cmd1`;
      `$cmd2`;
      `$cmd3`;
      unlink $gray_avg;
      unlink $gray_max;
      unlink $gray_min;
      if(-r $jpeg_avg){
        $type_to_file{avg} = $jpeg_avg;
      }
      if(-r $jpeg_max){
        $type_to_file{max} = $jpeg_max;
      }
      if(-r $jpeg_min){
        $type_to_file{min} = $jpeg_min;
      }
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
    print STDERR "Couldn't retrieve import_event_id for $nfid\n";
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
      unlink $file_name;
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
  if($verbose > 0){
    $b->WriteToEmail("$files_imported rendered jpegs for $nfid\n" .
      "$slice_rendering_time secs rendering slices; " .
      "$vol_rendering_time secs rendering volumes; " .
      "$projection_rendering_time secs rendering projection; " .
      "$db_update_time updating db\n"
    );
  }
}

$b->Finish("Done: $nifti_files_found found of $files_found");
