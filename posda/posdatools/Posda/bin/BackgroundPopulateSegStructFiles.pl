#!/usr/bin/perl -w
use strict;
use Posda::DB 'Query';
use Posda::SegToStruct;
use Posda::BackgroundProcess;
use File::Temp qw/ tempfile /;

use Debug;
my $dbg = sub { print STDERR @_ };

my $usage = <<EOF;
BackgroundPopulateSegStructFiles.pl <?bkgrnd_id?> <activity_id> <notify>
  activity_id - activity id
  notify - Posda user to notify upon completion

Expects a list of file_id's on STDIN

EOF
if($#ARGV == 0 && $ARGV[0] eq "-h"){
  print $usage;
  exit;
}

unless($#ARGV == 2){
  my $num_args = @ARGV;
  print "Error: wrong number args ($num_args vs 3)\n" .
        "usage:\n $usage\n";
  my $cmd = "BackgroundPopulateSegStructFiles.pl ";
  for my $i (@ARGV){
    $cmd .= " \"$i\"";
  }
  die "###$cmd\n###wrong number args ($num_args vs 3)";
}
my($invoc_id, $act_id, $notify) = @ARGV;

my %FileIds;
while (my $line = <STDIN>){
  chomp $line;
  $FileIds{$line} = 1;
}
my $num_files = keys %FileIds;
if($num_files <= 0){
  print "No files to process\n";
  exit;
}
print "Going to background to process $num_files files\n";
my $back = Posda::BackgroundProcess->new($invoc_id, $notify, $act_id);
$back->Daemonize;
my $f_remaining = $num_files;
my $f_succeded = 0;
my $f_failed = 0;
my $slices_extracted = 0;
my $q = Query("FilePathByFileId");
###  File Loop
file:
for my $f (keys %FileIds){
  $back->SetActivityStatus("Running - fr: $f_remaining, fs: $f_succeded, "  .
    "ff: $f_failed, se: $slices_extracted");

  ### Parse File and see if it is a seg_bitmap
  my $path;
  $q->RunQuery(sub{
    my($row) = @_;
    $path = $row->[0];
  }, sub {}, $f);
  unless(defined($path) && -r $path){
    $back->WriteToEmail("No path found for file_id $f\n");
    $f_failed += 1;
    $f_remaining -= 1;
    next file;
  }
  my $seg_obj;
  eval { $seg_obj = Posda::SegToStruct->new($path) };
  if($@){
    $back->WriteToEmail("file_id ($f) isn't a seg_bitmap: $@\n");
    $f_failed += 1;
    $f_remaining -= 1;
    next file;
  }
  ### end - Parse File and see if it is a seg_bitmap

  ### Make sure file has a seg_bitmap_file row
  my $seg_bitmap_file_id;
  my $seg_bitmap_file_row;
  my $col_names = [
   "seg_bitmap_file_id", "number_segmentations", "num_slices",
   "rows", "cols", "patient_id", "study_instance_uid",
   "series_instance_uid", "sop_instance_uid", "frame_of_reference_uid",
   "pixel_offset",
  ];
  Query("GetSegBitmapFileByFileId")->RunQuery(sub {
    my($row) = @_;
    $seg_bitmap_file_id = $row->[0];
    $seg_bitmap_file_row = $row;
  }, sub {}, $f);
  
  # Get parameters from structure
  my $parms;
  $parms->{seg_bitmap_file_id} = $f;
  $parms->{number_segmentations} = keys %{$seg_obj->{segmentations}};
  $parms->{num_slices} = @{$seg_obj->{frame_descriptor}};
  $parms->{rows} = $seg_obj->{rows};
  $parms->{cols} = $seg_obj->{cols};
  $parms->{frame_of_reference_uid} = $seg_obj->{frame_of_reference_uid};
  $parms->{patient_id} = $seg_obj->{patient_id};
  $parms->{study_instance_uid} = $seg_obj->{study_instance_uid};
  $parms->{series_instance_uid} = $seg_obj->{series_instance_uid};
  $parms->{sop_instance_uid} = $seg_obj->{sop_instance_uid};
  $parms->{frame_of_reference_uid} = $seg_obj->{frame_of_reference_uid};
  $parms->{pixel_offset} = $seg_obj->{pixel_offset};
  if(defined $seg_bitmap_file_id){ # Check seg_bitmap_file table against parameters
    for my $i (0 .. $#{$col_names}){
      my $col_name = $col_names->[$i];
      unless($seg_bitmap_file_row->[$i] eq $parms->{$col_name}){
        $back->WriteToEmail("for file $f, " .
          "row in seg_bitmap_file exists, and col $col_name " .
          "doesn't match file contents\n");
        $f_failed += 1;
        $f_remaining -= 1;
        next file;
      }
    }
  } else { # Populate seg_bitmap_file_table
    $parms->{seg_bitmap_file_id} = $f;
    Query("InsertSegBitmapFileRow")->RunQuery(sub {}, sub {}, 
      $parms->{seg_bitmap_file_id},
      $parms->{number_segmentations},
      $parms->{num_slices},
      $parms->{rows},
      $parms->{cols},
      $parms->{patient_id},
      $parms->{study_instance_uid},
      $parms->{series_instance_uid},
      $parms->{sop_instance_uid},
      $parms->{frame_of_reference_uid},
      $parms->{pixel_offset}
    );
  }
  ### end - Make sure file has a seg_bitmap_file row

  ## Check/Populate seg_bitmap_related_sops
  my $seg_bitmap_related_sops;
  Query('GetSegBitmapRelatedSops')->RunQuery(sub {
   my($row) = @_;
   my($f_id, $series, $sop) = @$row;
    $seg_bitmap_related_sops->{$f_id}->{$series}->{$sop} = 1;
  }, sub {}, $f);
  if(
    defined($seg_bitmap_related_sops->{$f}) && 
    ref($seg_bitmap_related_sops->{$f}) eq "HASH"
  ){ # Check DB against structure
    unless(
      defined($seg_obj->{ref_series}) &&
      ref($seg_obj->{ref_series}) eq "HASH"
    ){
      $back->WriteToEmail("For file $f, " .
        "referenced sop_instance appear in DB, " .
        "but not in file\n");
      $f_failed += 1;
      $f_remaining -= 1;
      next file;
    }

    # Check series, sop refs
    my @ref_errs;
    my $a = $seg_bitmap_related_sops->{$f};
    my $a_cap = "database";
    my $b = $seg_obj->{ref_series};
    my $b_cap = "file $f";
    for my $series(keys %$a){
      for my $sop (keys %{$a->{$series}}){
        unless(exists $b->{$series}->{$sop}){
          push @ref_errs, "$a_cap has ref to $sop in $series, " .
            "$b_cap doesn't";
        }
      }
    }
    for my $series(keys %$b){
      for my $sop (keys %{$b->{$series}}){
        unless(exists $a->{$series}->{$sop}){
          push @ref_errs, "$b_cap has ref to $sop in $series, " .
            "$a_cap doesn't";
        }
      }
    }
    if(@ref_errs){
      $back->WriteToEmail("Errors in referenced sops:\n");
      for my $m (@ref_errs){
        $back->WriteToEmail("   $m\n");
      }
      $f_failed += 1;
      $f_remaining -= 1;
      next file;
    }
    # end - Check series, sop refs
  } else {## Create rows in DB
    my $q = Query('InsertSegBitmapRelatedSops');
    for my $series (keys %{$seg_obj->{ref_series}}){
      for my $sop(keys %{$seg_obj->{ref_series}->{$series}}){
        $q->RunQuery(sub{}, sub {}, $f, $series, $sop);
      }
    }
  }
  ## end - Check/Populate seg_bitmap_related_sops

  ## Check/Populate seg_bitmap_segmenation
  my $segmentation;
  my @col_names = ("label", "description", "color", 
    "algorithm_type", "algorithm_name", "segmented_category",
    "segmented_type");
  my %DbStruct;
  Query('GetSegBitmapSegmentations')->RunQuery(sub  {
    my($row) = @_;
    for my $i (0 .. $#col_names){
      $DbStruct{$row->[1]}->{$col_names[$i]} = $row->[$i + 2];
    }
    $DbStruct{$row->[1]}->{seg_bitmap_file_id} = $f;
  }, sub {}, $f);
  my %FileStruct;
  for my $seg_num (keys %{$seg_obj->{segmentations}}){
    $FileStruct{$seg_num}->{seg_bitmap_file_id} = $f;
    $FileStruct{$seg_num}->{label} = 
      $seg_obj->{segmentations}->{$seg_num}->{label};
    $FileStruct{$seg_num}->{description} = 
      $seg_obj->{segmentations}->{$seg_num}->{description};
    $FileStruct{$seg_num}->{color} = 
      $seg_obj->{segmentations}->{$seg_num}->{color}->[0] .
      '\\' .
      $seg_obj->{segmentations}->{$seg_num}->{color}->[1] .
      '\\' .
      $seg_obj->{segmentations}->{$seg_num}->{color}->[2];
    $FileStruct{$seg_num}->{algorithm_type} = 
      $seg_obj->{segmentations}->{$seg_num}->{algorithm}->{type};
    $FileStruct{$seg_num}->{algorithm_name} = 
      $seg_obj->{segmentations}->{$seg_num}->{algorithm}->{name};
    $FileStruct{$seg_num}->{segmented_category} = 
      $seg_obj->{segmentations}->{$seg_num}->{segmented_property}->{category};
    $FileStruct{$seg_num}->{segmented_type} = 
      $seg_obj->{segmentations}->{$seg_num}->{segmented_property}->{type};
  }
  my $segs_in_db = keys %DbStruct;;
  if($segs_in_db > 0){## Check DB against file
    my @seg_err;
    my $a = \%DbStruct;
    my $a_cap = "database";
    my $b = \%FileStruct;
    my $b_cap = "file $f";
    aseg:
    for my $seg_no (keys %$a){
      unless(ref($a->{$seg_no}) eq "HASH"){
        push @seg_err, "$a_cap has seg_no ($seg_no} with bad content";
        next aseg;
      }
      unless(exists($b->{$seg_no}) && ref($b->{$seg_no}) eq "HASH"){
        push @seg_err, "$a_cap has segment_no $seg_no $b_cap doesn't";
        next aseg;
      }
      for my $prop (keys %{$a->{$seg_no}}){
        unless($a->{$seg_no}->{$prop} eq $b->{$seg_no}->{$prop}){
          push @seg_err, "non-matching $a_cap, $b_cap {$seg_no}" .
            "->{$prop}: ($a->{$seg_no}->{$prop} vs " .
            "$b->{$seg_no}->{$prop})";
        }
      }
    }
    bseg:
    for my $seg_no (keys %$b){
      unless(ref($b->{$seg_no}) eq "HASH"){
        push @seg_err, "$b_cap has seg_no ($seg_no} with bad content";
        next bseg;
      }
      unless(exists($a->{$seg_no}) && ref($a->{$seg_no}) eq "HASH"){
        push @seg_err, "$b_cap has segment_no $seg_no $a_cap doesn't";
        next bseg;
      }
      for my $prop (keys %{$b->{$seg_no}}){
        unless($b->{$seg_no}->{$prop} eq $a->{$seg_no}->{$prop}){
          push @seg_err, "non-matching $b_cap, $a_cap {$seg_no}" .
            "->{$prop}: ($b->{$seg_no}->{$prop} vs " .
            "$a->{$seg_no}->{$prop})";
        }
      }
    }
    my $num_seg_err = @seg_err;
    if($num_seg_err > 0){
      $back->WriteToEmail("Errors in segmentations:\n");
      for my $m (@seg_err){
        $back->WriteToEmail("   $m\n");
      }
      $f_failed += 1;
      $f_remaining -= 1;
      next file;
    }
  } else {## Create DB row
    my $q = Query('InsertSegBitmapSegmentation');
    for my $seg_no (keys %FileStruct){
      my @args;
      push @args, $f;
      push @args, $seg_no;
      for my $prop (@col_names){ push @args, $FileStruct{$seg_no}->{$prop} };
      $q->RunQuery(sub{}, sub{}, @args);
    }
  }
  ## end - Check/Populate seg_bitmap_segmenation

  ## Check/Populate seg_slice_bitmap_file
  my $slice_no = 0;
  frame:
  for my $frame (@{$seg_obj->{frame_descriptor}}){
    ## Extract compressed bitmap for slice and add to db
    my $offset = $seg_obj->{pixel_offset} + $frame->{offset_within_pixels};
    my $seg_file = $path;
    my $rows = $seg_obj->{rows};
    my $cols = $seg_obj->{cols};
    my $num_bytes = ($rows * $cols) / 8;
    my $tmp_file_path;
    {
      my $t_fhs;
      ($t_fhs, $tmp_file_path) = tempfile();
    }
    my $cmd = "ExtractSliceFromSeg.pl \"$seg_file\" $offset $num_bytes " .
      "$rows $cols \"$tmp_file_path\"";
    my($total_ones, $total_zeros, $c_bytes, $c_ratio, $num_bare);
    my @bare_points;
    open CMD, "$cmd|";
    while(my $line = <CMD>){
      chomp $line;
      if($line =~ /^total ones: (.*)$/){
        $total_ones = $1;
      }elsif($line =~ /^total zeros: (.*)$/){
        $total_zeros = $1;
      }elsif($line =~ /^bytes written: (.*)$/){
        $c_bytes = $1;
      }elsif($line =~ /^compression: (.*)$/){
        $c_ratio = $1;
      }elsif($line =~ /^Found: (\d*) bare points$/){
        $num_bare = $1;
      }elsif($line =~ /^bare point: (.*)$/){
        push @bare_points, $1;
        $num_bare += 1;
      }
    }
    close CMD;
    unless(defined $num_bare){ $num_bare = 0 }
    my $slice_file_id;
    my $slice_file_error;
    my $i_cmd = "ImportSingleFileIntoPosdaAndReturnId.pl \"$tmp_file_path\" " .
      "\"slice($slice_no) from $f\"";
    open CMD, "$i_cmd|";
    while(my $line = <CMD>){
      chomp $line;
      if($line =~ /^File id: (.*)$/){
        $slice_file_id = $1;
      }elsif($line =~ /^Error: (.*)$/){
        $slice_file_error = $1;
      }
    }
    close CMD;
    if(defined $slice_file_error){
      $back->WriteToEmail("slice file error on import to posda: $slice_file_error\n");
    }
    unless(defined($slice_file_id)){
      $back->WriteToEmail("slice file didn't import to posda\n");
      next frame;
    }
    unlink $tmp_file_path;

    ## Check/Populate seg_slice_bitmap_file
    my @cols = ( "seg_slice_bitmap_file_id", "seg_slice_bitmap_slice_no",
      "seg_bitmap_file_id", "segmentation_number", "iop", "ipp",
      "total_ones", "num_bare_points");
    my $num_cols = @cols;
    my %f_parms;
    $f_parms{seg_slice_bitmap_slice_no} = $slice_no;
    $f_parms{segmentation_number} = $frame->{referenced_segment_number};
    $f_parms{seg_slice_bitmap_file_id} = $slice_file_id;
    $f_parms{seg_bitmap_file_id} = $f;
    my $iop = $frame->{plane_orientation}->[0] . '\\' .
      $frame->{plane_orientation}->[1] . '\\' .
      $frame->{plane_orientation}->[2] . '\\' .
      $frame->{plane_orientation}->[3] . '\\' .
      $frame->{plane_orientation}->[4] . '\\' .
      $frame->{plane_orientation}->[5];
    $f_parms{iop} = $iop;
    my $ipp = $frame->{plane_position}->[0] . '\\' .
      $frame->{plane_position}->[1] . '\\' .
      $frame->{plane_position}->[2];
    $f_parms{ipp} = $ipp;
    $f_parms{total_ones} = $total_ones;
    $f_parms{num_bare_points} = $num_bare;
    my %db_struct;
    Query('GetSegSliceBitmapFileBySegBitmapFileIdAndSliceNo')->RunQuery(sub{
      my($row) = @_;
      for my $i (0 .. $#cols){
        $db_struct{$cols[$i]} = $row->[$i];
      }
    }, sub{}, $f, $slice_no);
    my $num_props = keys %db_struct;
    if($num_props > 0){## Compare db to file
      my @errs;
      my $a = \%db_struct;
      my $a_cap = "database";
      my $b = \%f_parms;
      my $b_cap = "slice_file($slice_file_id) of $f";
    for my $prop(keys %$a){
        unless($a->{$prop} eq $b->{$prop}){
          push @errs, "$a_cap and $b_cap differ in $prop: " .
            "$a->{$prop} vs $b->{prop}";
        }
      }
    for my $prop(keys %$b){
        unless($a->{$prop} eq $b->{$prop}){
          push @errs, "$b_cap and $a_cap differ in $prop: " .
            "$b->{$prop} vs $a->{prop}";
        }
      }
      if(@errs){
        $back->WriteToEmail("Errors in seg_slice_bitmap_file:\n");
        for my $m (@errs){
          $back->WriteToEmail("   $m\n");
        }
        $f_failed += 1;
        $f_remaining -= 1;
        next file;
      }
    } else {## Populate db
      my @parms;
      for my $p (@cols){
        push @parms, $f_parms{$p};
      }
      Query('InsertSegSliceBitmapFileRow')->RunQuery(sub{}, sub{},
        @parms);
    }
    ## end -Check/Populate seg_slice_bitmap_file

    ## Check/Populate seg_slice_bitmap_file_related_image
    my %db_sops;
    Query('GetSliceBitmapFileRelatedImages')->RunQuery(sub{
      my($row) = @_;
      $db_sops{$row->[0]} = 1;
    }, sub{}, $f, $slice_no);
    my $num_db_sops = keys %db_sops;
    if($num_db_sops > 0){## Compare db to file
      my $f_sops = $frame->{referenced_images};
      my @errs;
      for my $a (keys %db_sops){
      unless(exists $f_sops->{$a}){
          push @errs, "$a is in db not in file";
        }
      }
      for my $a (keys %$f_sops){
        unless(exists $db_sops{$a}){
          push @errs, "$a is in file not in db";
        }
      }
      my $num_errs = @errs;
      if($num_errs > 0){
        $back->WriteToEmail(
          "Errors in seg_slice_bitmap_file_related_image ($slice_file_id, $f):\n");
        for my $m (@errs){
          $back->WriteToEmail("   $m\n");
        }
        $f_failed += 1;
        $f_remaining -= 1;
        next file;
      }
    } else{## Populate db
      my $q = Query('InsertSliceBitmapFileRelatedSop');
      my $f_sops = $frame->{referenced_images};
      for my $sop(keys %{$f_sops}){
       $q->RunQuery(sub{}, sub{}, $f, $slice_no, $sop);
      }
    }
    
    ## Check/Populate seg_slice_bitmap_bare_points
    my %db_pts;
    Query('GetSliceBitmapFileBarePoints')->RunQuery(sub{
      my($row) = @_;
      $db_pts{$row->[0]} = 1;
    }, sub{}, $f, $slice_no);
    my %f_pts;
    for my $pt (@bare_points){
      $f_pts{$pt} = 1;
    }
    my $num_db = keys %db_pts;
    my $num_f = keys %f_pts;
    my @errs;
    if($num_db == 0 && $num_f > 0){## insert db
      my $q = Query('InsertSliceBitmapFileBarePoint');
      for my $p (keys %f_pts){
        $q->RunQuery(sub{}, sub{}, $f, $slice_no, $p);
      }
    } elsif ($num_db != $num_f){## error
      push @errs, "db has $num_db bare points and file has $num_f bare points";
    } else {#compare db to file
      for my $p (keys %db_pts){
        unless(exists $f_pts{$p}){
          push @errs, "db has bare point $p and file doesn't";
        }
      }
      for my $p (keys %f_pts){
        unless(exists $db_pts{$p}){
          push @errs, "file has bare point $p and db doesn't";
        }
      }
    }
    my $num_errs = @errs;
    if($num_errs > 0){
      $back->WriteToEmail(
        "Errors in seg_slice_bitmap_file_bare_points ($slice_file_id, $f):\n");
      for my $m (@errs){
        $back->WriteToEmail("   $m\n");
      }
      $f_failed += 1;
      $f_remaining -= 1;
      next file;
    }
    $slices_extracted += 1;
    $slice_no += 1;
    $back->SetActivityStatus("Running - fr: $f_remaining, fs: $f_succeded, "  .
      "ff: $f_failed, se: $slices_extracted");
  }
  ## Declare success for this file
  $f_succeded += 1;
  $f_remaining -= 1;
}
### End file loop
$back->Finish("Done - fr: $f_remaining, fs: $f_succeded, "  .
    "ff: $f_failed, se: $slices_extracted");
