#!/usr/bin/perl -w
#
#Copyright 2013, Bill Bennett
# Part of the Posda package
# Posda may be copied only under the terms of either the Artistic License or the
# GNU General Public License, which may be found in the Posda Distribution,
# or at http://posda.com/License.html
#
use strict;
use Digest::MD5;
use Dispatch::Select;
use Dispatch::EventHandler;
use Posda::FileCollectionAnalysis;
use Storable qw( store retrieve retrieve fd_retrieve store_fd );
use Debug;
$| = 1;
my $dbg = sub { print STDERR @_ };
my $help = <<EOF;
Usage: HandleTransactionSubProcess.pl <cmd file>
or
       HandleTransactionSubProcess.pl -h
EOF
if($#ARGV == 0 && ($ARGV[0] eq "-h")){
  print $help;
  exit;
}
unless($#ARGV == 0) { die $help }
## execution skips around object and function definitions to near bottom...
{
  # Analyzer is a virtual object which is inherited by both
  #   ExtractorAnalyzer and EditorAnalyzer
  #   It handles the analysis part...
  package Analyzer;
  use vars qw( @ISA );
  @ISA = ( "Dispatch::EventHandler" );
  sub new {
    my($class, $this) = @_;
    bless $this, $class;
    $this->{Analyzer} = (-x "/usr/bin/speedy") ?
      "SpeedyDicomInfoAnalyzer.pl" : "DicomInfoAnalyzer.pl";
    $this->{InProcess} = 1;
    $this->{Status} = "Starting";
    $this->StartProcessing;
    Dispatch::Select::Background->new($this->StatusReporter)->queue;
    $this->{StartTime} = time;
    $this->{FileCollectionAnalysis} = Posda::FileCollectionAnalysis->new;
    return $this;
  }
  sub StatusReporter{
    my($this) = @_;
    my $sub = sub {
      my($disp) = @_;
      # if still InProcess,
      if($this->{InProcess}){
        # Report Status on STDOUT
        $this->ReportStatus;
        $disp->timer(2);
        # and do it again in 2 seconds
      }
      #otherwise, stop (we're done).
    };
    return $sub;
  }
#  $this->{Extracting} => Extraction in progress:
#    $this->{TotalToExtract} = total extraction requested
#    $this->{Extracted} = extracted so far
#    @{$this->{ExtractList}} = number in extract queue
#  $this->{Editing} => Edits in progress
#    $this->{TotalToEdit} = total edits requested
#    $this->{Edited} = edited so far
#    @{$this->{EditList}} = in Edit queue
#    unless(exists $this->{EditsInProgress}) { $this->{EditsInProgress} = {} }
#    my $num_in_progress = keys %{$this->{EditsInProgress}};
  sub ReportStatus{
    my($this) = @_;
    # if still InProcess,
    unless($this->{InProcess}) { return }
    # Report Status on STDOUT
    my %statii;
    my $elapsed = time - $this->{StartTime};
    $statii{Elapsed} = time - $this->{StartTime};
    if($this->{TotalToEdit}){
      $statii{TotalToEdit} = $this->{TotalToEdit};
      $statii{Edited} = $this->{Edited};
    }
    if($this->{TotalToExtract}){
      $statii{TotalToExtract} = $this->{TotalToExtract};
      $statii{Extracted} = $this->{Extracted};
    }
    if(exists $this->{Extracting}){
      $statii{QueuedForExtraction} = @{$this->{ExtractList}};
    } else {
    }
    if(exists $this->{Editing}){
      $statii{QueuedForEdit} = @{$this->{EditList}};
      $statii{BeingEdited} = keys %{$this->{EditsInProgress}};
    }
    my($b_count, $t_count) = Dispatch::Select->BackgroundCount;
    $statii{b_count} = $b_count;
    $statii{t_count} = $t_count;
    unless(exists $this->{InAnalysis}) {$this->{InAnalysis} = {} }
    $statii{BeingAnalyzed} = keys %{$this->{InAnalysis}};
    unless(exists $this->{AnalysisQueue}) {$this->{AnalysisQueue} = [] }
    $statii{QueuedForAnalysis} = @{$this->{AnalysisQueue}};
    print "Status=$this->{Status}";
    for my $i (sort keys %statii){
      print "&$i=$statii{$i}";
    }
    print "\n";
  }
  sub KickAnalysis{
    my($this) = @_;
    unless($this->{AnalysisPending}){
      $this->{AnalysisPending} = 1;
      $this->InvokeAfterDelay("NextAnalysis", 0);
    }
  }
  sub NextAnalysis{
    # analysis queue entry (hash) needs:
    #   dest_file => <path to destination file (edited or linked)>,
    #   digest => <actual digest of file>,
    # this adds:
    #   cache_file => cache_file,
    my($this) = @_;
    unless(exists $this->{InAnalysis}) {$this->{InAnalysis} = {} }
    my $in_analysis = keys %{$this->{InAnalysis}};
    unless(exists $this->{AnalysisQueue}) {$this->{AnalysisQueue} = [] }
    my $queued_for_analysis = @{$this->{AnalysisQueue}};
    while($in_analysis < $this->{parallelism} && $queued_for_analysis > 0){
      my $next = shift @{$this->{AnalysisQueue}};
      my $digest = $next->{digest};
      unless($digest =~ /^(.)(.).*/){
        die "Bad Digest";
      }
      my $first_dir = "$this->{cache_dir}/$1";
      my $second_dir = "$this->{cache_dir}/$1/$2";
      unless(-d $first_dir) {
        unless(mkdir $first_dir) { die "Can't mkdir $first_dir ($!)" }
      }
      unless(-d $second_dir) {
        unless(mkdir $second_dir) { die "Can't mkdir $second_dir ($!)" }
      }
      $next->{cache_file} = "$second_dir/$digest.dcminfo";
      if(-f $next->{cache_file}){
        $this->{InAnalysis}->{$next->{dest_file}} = $next;
        Dispatch::Select::Background->new(
          $this->RetrieveCachedAnalysis($next))->queue;
#        my $fh;
#        my $cmd = "cat \"$next->{cache_file}\"";
#        open $fh, "$cmd |" or die "can't open $cmd";
#        $this->{InAnalysis}->{$next->{dest_file}} = $next;
#        Dispatch::Select::Socket->new(
#          $this->DoAnalysis($next), $fh)->Add("reader");
      } else {
        if(exists $this->{InAnalysis}->{$next->{dest_file}}){
          print STDERR "!!!!!!!  $next->{dest_file} queued for analysis twice\n";
        }
        $this->{InAnalysis}->{$next->{dest_file}} = $next;
        open my $fh, "$this->{Analyzer} \"$next->{dest_file}\"|"
          or die "Can't open Analyzer ($!)";
        Dispatch::Select::Socket->new(
          $this->DoAnalysis($next), $fh)->Add("reader");
      }
      $in_analysis = keys %{$this->{InAnalysis}};
      $queued_for_analysis = @{$this->{AnalysisQueue}};
    }
    if($this->{AnalysisPending}) { delete $this->{AnalysisPending} }
    unless($#{$this->{AnalysisQueue}} >= 0){
      $this->CheckForCompletion;
    }
  }
  sub DoAnalysis{
    my($this, $desc) = @_;
    my $text;
    my $sub = sub {
      my($disp, $socket) = @_;
      my $analysis = Storable::fd_retrieve($socket);
      $disp->Remove;
      Storable::store($analysis, $desc->{cache_file});
      $this->ProcessFileAnalysis($desc->{dest_file}, $analysis, $desc);
      delete $this->{InAnalysis}->{$desc->{dest_file}};
      $this->KickAnalysis;
    };
    return $sub;
  }
  sub RetrieveCachedAnalysis{
    my($this, $desc) = @_;
    my $sub = sub {
      my($disp) = @_;
      my $analysis;
      eval {$analysis  = Storable::retrieve $desc->{cache_file} };
      if($@){
        print STDERR "Error($!): loading cache file $desc->{cache_file}\n" .
          "\t Deleted - attempting to recache\n";
        unlink $desc->{cache_file};
        $this->{InAnalysis}->{$desc->{dest_file}} = $desc;
        open my $fh, "$this->{Analyzer} \"$desc->{dest_file}\"|"
          or die "Can't open Analyzer ($!)";
        Dispatch::Select::Socket->new(
          $this->DoAnalysis($desc), $fh)->Add("reader");
      } else {
        $this->ProcessFileAnalysis($desc->{dest_file}, $analysis, $desc);
        delete $this->{InAnalysis}->{$desc->{dest_file}};
        $this->KickAnalysis;
      }
    };
    return $sub;
  }
  sub CheckForCompletion{
    my($this) = @_;
    my $in_analysis = keys %{$this->{InAnalysis}};
    my $queued_for_analysis =  @{$this->{AnalysisQueue}};
    my $extract_wait = 0;
    if(exists $this->{ExtractList}){
      $extract_wait += @{$this->{ExtractList}};
    }
    if(exists $this->{InExtraction}){
      $extract_wait += keys %{$this->{InExtraction}};
    }
    my $in_edit = 0;
    if(exists $this->{EditsInProgress}){
      $in_edit = keys %{$this->{EditsInProgress}};
    }
    my $edit_queue = 0; 
    if(exists $this->{EditList}){
      $edit_queue = @{$this->{EditList}};
    }
    if(
      $extract_wait == 0 &&
      $in_analysis == 0 &&
      $in_edit == 0 &&
      $edit_queue == 0 &&
      $queued_for_analysis == 0
    ){
      unless($this->{Finished}){
        $this->Finished;
      }
    }
  }
  sub ProcessFileAnalysis{
    my($this, $file, $analysis, $desc) = @_;
    $this->{FileList}->{$file} = $analysis;
    $this->{FileCollectionAnalysis}->Analyze($file, $analysis);
  }
  sub Finished{
    my($this) = @_;
    $this->{Finished} = 1;
    my $info_dir = $this->{info_dir};
    if(-d $info_dir){
      unless(defined $this->{link_info}){
        $this->{link_info} = "$info_dir/link_info.pinfo";
      }
      unless(defined $this->{consistency_info}){
        $this->{consistency_info} = "$info_dir/consistency.pinfo";
      }
      unless(defined $this->{hierarchy_info}){
        $this->{hierarchy_info} = "$info_dir/hierarchy.pinfo";
      }
      unless(defined $this->{error_info}){
        $this->{error_info} = "$info_dir/error.pinfo";
      }
      unless(defined $this->{dicom_info}){
        $this->{dicom_info} = "$info_dir/dicom.pinfo";
      }
      unless(defined $this->{raw_analysis_info}){
        $this->{raw_analysis_info} = "$info_dir/FileCollectionAnalysis.pinfo";
      }
    }
    $this->{Status} = "Ok";
    $this->ReportStatus;
    $this->{FileCollectionAnalysis}->ConsistencyErrors;
#    $this->{FileCollectionAnalysis}->ImageNumberErrors;
    $this->{FileCollectionAnalysis}->StructureSetLinkages;
    $this->{FileCollectionAnalysis}->BuildNewHierarchy;
    my $analysis_info = $this->{FileCollectionAnalysis};
    ############### debug only ###############
    Storable::store($analysis_info, $this->{raw_analysis_info});
    ##########################################
    my $error_info = $analysis_info->{errors};
    my $link_info = $this->{SourceToDest};
    my $dicom_info = {
      FilesByDigest => $analysis_info->{FilesByDigest},
      FilesToDigest => $analysis_info->{FilesToDigest},
    };
    my $hierarchy = $analysis_info->{NewHierarchy};
    my $consistency_info = {
      series_consistency => $analysis_info->{series_consistency},
      study_consistency => $analysis_info->{study_consistency},
      patient_consistency => $analysis_info->{patient_consistency},
      seuid_to_index => $analysis_info->{seuid_to_index},
      seuid_from_index => $analysis_info->{seuid_from_index},
      stuid_to_index => $analysis_info->{stuid_to_index},
      stuid_from_index => $analysis_info->{stuid_from_index},
    };
    Storable::store($consistency_info, $this->{consistency_info});
    Storable::store($hierarchy, $this->{hierarchy_info});
    if(ref($error_info) eq "ARRAY" && $#{$error_info} >= 0){
      Storable::store($error_info, $this->{error_info});
    }
    Storable::store($dicom_info, $this->{dicom_info});
    Storable::store($link_info, $this->{link_info});
    $this->{InProcess} = 0;
  }
}
{
  package NewExtractorAnalyzer;
  use vars qw( @ISA );
  @ISA = ( "Analyzer" );
    # $this->{destination} = <destination directory>;
    # $this->{info_dir} = <analysis info file>;
    # $this->{cache_dir} = <cache directory>;
    # $this->{parallelism} = <num parallel parsers>;
    # $this->{desc} = {
    #   patient_id => <patient_id>,
    #   studies => {
    #     <study_uid> => {
    #       pid => <patient_id>,
    #       desc => <study description>,
    #       uid => <study instance uid>,
    #       series => {
    #         <series_uid> => {
    #           body_part => <body_part>,
    #           desc => <series_desc>,
    #           modality => <modality>,
    #           uid => <series instance uid>,
    #           files => {
    #             <db_id> =>{
    #               sop_instance_uid => <sop_instance_uid>,
    #               file => <file_path>,
    #               file_size => <file_size>,
    #               md5 => <md5 digest>,
    #               visibility => 1 | 0,
    #             },
    #             ...
    #           },
    #         },
    #         ...
    #       },
    #     },
    #     ...
    #   },
    # };
  sub StartProcessing{
    my($this) = @_;
    $this->{Status} = "Running";
    my @list;
    my %uids;
    for my $st (keys %{$this->{desc}->{studies}}){
      my $st_info = $this->{desc}->{studies}->{$st};
      for my $se (keys %{$st_info->{series}}){
        my $se_info = $st_info->{series}->{$se};
        for my $fi (keys %{$se_info->{files}}){
          my $f_info = $se_info->{files}->{$fi};
          my $pat_id = $st_info->{pid};
          my $st_desc = $st_info->{desc};
          my $st_uid = $st_info->{uid};
          my $se_uid = $se_info->{uid};
          my $se_desc = $se_info->{desc};
          my $body_part = $se_info->{body_part};
          my $modality = $se_info->{modality};
          my $sop_inst = $f_info->{sop_instance_uid};
          my $from = $f_info->{file};
          my $from_size = $f_info->{size};
          my $f_db_dig = $f_info->{md5};
          while(length($f_db_dig) < 32) { $f_db_dig = "0" . $f_db_dig }
          push @list, {
            pat_id => $pat_id,
            study_desc => $st_desc,
            series_desc => $se_desc,
            study_uid => $st_uid,
            series_uid => $se_uid,
            body_part => $body_part,
            modality =>  $modality,
            sop_inst => $sop_inst,
            from_file => $from,
            from_db_size => $from_size,
            from_db_dig => $f_db_dig,
          };
          $uids{$sop_inst}->{$modality}->{$from} = 1;
        }
      }
    }
    for my $si (keys %uids){
      for my $m (keys %{$uids{$si}}){
        my @froms = keys %{$uids{$si}->{$m}};
        my $dest_root = $m . "_$si";
        if(@froms > 1) {
          for my $i (0 ,, $#froms){
            my $dest_file = $dest_root . "_$i.dcm";
            $this->{SourceToDest}->{$froms[$i]} = $this->{destination} .
              "/$dest_file";
          }
        } else{
          my $dest_file = "$dest_root.dcm";
          $this->{SourceToDest}->{$froms[0]} = $this->{destination} .
            "/$dest_file";
        }
      }
    }
    for my $item (@list){
      $item->{dest_file} = $this->{SourceToDest}->{$item->{from_file}};
    }
    $this->{ExtractList} = \@list;
    $this->{Extracting} = 1;
    $this->{TotalToExtract} = @list;
    $this->{Extracted} = 0;
    $this->{InExtraction} = {};
    $this->CopyNextFiles;
#    Dispatch::Select::Background->new($this->CrankList)->queue;
  }
  sub CopyNextFiles{
    my($this) = @_;
    delete $this->{CopyNextPending};
    my $ToCopy = @{$this->{ExtractList}};
    my $InExtraction = keys %{$this->{InExtraction}};
    while($ToCopy > 0 && $InExtraction < 10){
      my $extraction = shift(@{$this->{ExtractList}});
      my $from_file = $extraction->{from_file};
      my $to_file = $extraction->{dest_file};
unless($from_file) { die "HandleTransactionSubProcess.pl no from_file" }
unless($to_file) { die "HandleTransactionSubProcess.pl no to_file" }
      my $cmd = "ln \"$from_file\" \"$to_file\"";
#print STDERR "Extraction Command: $cmd\n";
      my $fh;
      if(open $fh, "$cmd|"){
        Dispatch::Select::Socket->new(
          $this->CopyDone($extraction), $fh)->Add("reader");
      } else {
        print STDERR "couldn't open $cmd - $!\n";
      }
      $this->{InExtraction}->{$from_file} = 1;
      $ToCopy = @{$this->{ExtractList}};
      $InExtraction = keys %{$this->{InExtraction}};
    }
  }
  sub CopyDone{
    my($this, $next) = @_;
    my $sub = sub {
      my($disp, $sock) = @_;
      $disp->Remove();
      my $fh;
      unless(open $fh, "<$next->{dest_file}"){
        print STDERR "can't open $next->{dest_file} for digest\n";
        push(@{$this->{errors}}, "Can't open from file: $next->{dest_file}");
        return;
      }
      my $ctx = Digest::MD5->new;
      $ctx->addfile($fh);
      close($fh);
      $next->{digest} = $ctx->hexdigest;
      unless($next->{digest} eq $next->{from_db_dig}){
        push(@{$this->{errors}}, "Digest of $next->{dest_file} " .
          "($next->{digest}) " .
          "doesn't match db on extraction ($next->{from_db_dig}");
        # keep going
      }
      delete $this->{InExtraction}->{$next->{from_file}};
      $this->{Extracted} += 1;
      push(@{$this->{AnalysisQueue}}, $next);
      $this->KickAnalysis;
      unless($this->{CopyNextPending}){
        $this->{CopyNextPending} = 1;
        $this->InvokeAfterDelay("CopyNextFiles", 0);
      }
    };
    return $sub;
  }
}
{
  package ExtractorAnalyzer;
  use vars qw( @ISA );
  @ISA = ( "Analyzer" );
    # $this->{destination} = <destination directory>;
    # $this->{info_dir} = <analysis info file>;
    # $this->{cache_dir} = <cache directory>;
    # $this->{parallelism} = <num parallel parsers>;
    # $this->{desc} = {
    #   patient_id => <patient_id>,
    #   studies => {
    #     <db_id> => {
    #       pid => <patient_id>,
    #       desc => <study description>,
    #       uid => <study instance uid>,
    #       series => {
    #         <db_id> => {
    #           body_part => <body_part>,
    #           desc => <series_desc>,
    #           modality => <modality>,
    #           uid => <series instance uid>,
    #           files => {
    #             <db_id> =>{
    #               sop_instance_uid => <sop_instance_uid>,
    #               file => <file_path>,
    #               file_size => <file_size>,
    #               curation_time_stamp => <date/time>,
    #               md5 => <md5 digest (leading zeros surpressed)>,
    #               visibility => 1 | 0,
    #             },
    #             ...
    #           },
    #         },
    #         ...
    #       },
    #     },
    #     ...
    #   },
    # };
  sub StartProcessing{
    my($this) = @_;
    $this->{Status} = "Running";
    my @list;
    my %uids;
    for my $st (keys %{$this->{desc}->{studies}}){
      my $st_info = $this->{desc}->{studies}->{$st};
      for my $se (keys %{$st_info->{series}}){
        my $se_info = $st_info->{series}->{$se};
        for my $fi (keys %{$se_info->{files}}){
          my $f_info = $se_info->{files}->{$fi};
          my $pat_id = $st_info->{pid};
          my $st_desc = $st_info->{desc};
          my $st_uid = $st_info->{uid};
          my $se_uid = $se_info->{uid};
          my $se_desc = $se_info->{desc};
          my $body_part = $se_info->{body_part};
          my $modality = $se_info->{modality};
          my $sop_inst = $f_info->{sop_instance_uid};
          my $from = $f_info->{file};
          my $from_size = $f_info->{size};
          my $f_db_dig = $f_info->{md5};
          while(length($f_db_dig) < 32) { $f_db_dig = "0" . $f_db_dig }
          push @list, {
            pat_id => $pat_id,
            study_desc => $st_desc,
            series_desc => $se_desc,
            study_uid => $st_uid,
            series_uid => $se_uid,
            body_part => $body_part,
            modality =>  $modality,
            sop_inst => $sop_inst,
            from_file => $from,
            from_db_size => $from_size,
            from_db_dig => $f_db_dig,
          };
          $uids{$sop_inst}->{$modality}->{$from} = 1;
        }
      }
    }
    for my $si (keys %uids){
      for my $m (keys %{$uids{$si}}){
        my @froms = keys %{$uids{$si}->{$m}};
        my $dest_root = $m . "_$si";
        if(@froms > 1) {
          for my $i (0 ,, $#froms){
            my $dest_file = $dest_root . "_$i.dcm";
            $this->{SourceToDest}->{$froms[$i]} = $this->{destination} .
              "/$dest_file";
          }
        } else{
          my $dest_file = "$dest_root.dcm";
          $this->{SourceToDest}->{$froms[0]} = $this->{destination} .
            "/$dest_file";
        }
      }
    }
    for my $item (@list){
      $item->{dest_file} = $this->{SourceToDest}->{$item->{from_file}};
    }
    $this->{ExtractList} = \@list;
    $this->{Extracting} = 1;
    $this->{TotalToExtract} = @list;
    $this->{Extracted} = 0;
    Dispatch::Select::Background->new($this->CrankList)->queue;
  }
  sub CrankList{
    my($this) = @_;
    my $sub = sub {
      my($disp) = @_;
      unless(@{$this->{ExtractList}} > 0) { 
        delete $this->{Extracting};
        return;
      }
      my $next = shift @{$this->{ExtractList}};
      my $fh;
      unless(open $fh, "<$next->{from_file}"){
        print STDERR "can't open $next->{from_file} for digest\n";
        push(@{$this->{errors}}, "Can't open from file: $next->{from_file}");
        return;
      }
      my $ctx = Digest::MD5->new;
      $ctx->addfile($fh);
      close($fh);
      $next->{digest} = $ctx->hexdigest;
      unless($next->{digest} eq $next->{from_db_dig}){
        push(@{$this->{errors}}, "Digest of $next->{from_file} " .
          "($next->{digest}) " .
          "doesn't match db on extraction ($next->{from_db_dig}");
        # keep going
      }
      unless(link $next->{from_file}, $next->{dest_file}){
        push(@{$this->{errors}}, "Unable to construct hard link ($!) " .
          "\"$next->{from}\" \"$next->{dest_file}\"");
        return;
      }
      $this->{Extracted} += 1;
      push(@{$this->{AnalysisQueue}}, $next);
      $this->KickAnalysis;
      $disp->queue;
    };
    return $sub;
  }
}
{
  package EditorAnalyzer;
  use vars qw( @ISA );
  @ISA = ( "Analyzer" );
    # $this->{files_to_link} = {
    #   <file_path> => <file_digest>,
    #   ...
    # };
    # $this->{info_dir} = <info directory>;
    # $this->{source} = <source directory>;
    # $this->{destination} => <destination directory>;
    # $this->{parallelism} = <num parallel edits>;
    # $this->{FileEdits} => {
    #   <from_file> => {             # file name only here
    #     from_file => <from_file>,  # full path here
    #     to_file => <to_file>,      # full_path here
    #     ... [see comments for Posda/bin/SubProcessEditor.pl]
    #   },
    #   ...
    # };
  sub StartProcessing{
    my($this) = @_;
    $this->{Status} = "Running";
    my @files_to_link;
    $this->{SourceToDest} = {};
    for my $f (keys %{$this->{files_to_link}}){
      $this->{SourceToDest}->{"$this->{source}/$f"} = "$this->{destination}/$f";
      push(@files_to_link, {
        source_file => "$this->{source}/$f",
        dest_file => "$this->{destination}/$f",
        digest => "$this->{files_to_link}->{$f}",
      });
    }
    $this->InitEdits;
    if(@files_to_link > 0){
      $this->{ExtractList} = \@files_to_link;
      $this->{Extracting} = 1;
      $this->{TotalToExtract} = @files_to_link;
      $this->{Extracted} = 0;
#      $this->{ExtractsInProgress} = {};
#      $this->NextExtraction;
      Dispatch::Select::Background->new($this->LinkFiles)->queue;
    }
    if($this->{Editing}){
      $this->NextEdit;
    }
  }
  sub NextExtraction{
    my($this) = @_;
    unless($this->{Extracting}) { return }
    my $num_to_extract = @{$this->{ExtractList}};
    my $num_extracts_in_progress = keys %{$this->{ExtractsInProgress}};
    while($num_to_extract > 0 && $num_extracts_in_progress < 20){
      my $next = shift(@{$this->{ExtractList}});
      my $from_file = $next->{source_file};
      my $to_file = $next->{dest_file};
      my $cmd = "ln \"$to_file\" \"$from_file\"";
      my $fh;
      open($fh, "$cmd|");
      $this->{ExtractsInProgress}->{$from_file} = $next;
      Dispatch::Select::Socket->new(
        $this->LinkDone($next), $fh)->Add("reader");
      $num_to_extract = @{$this->{ExtractList}};
      $num_extracts_in_progress = keys %{$this->{ExtractsInProgress}};
    }
    if($num_to_extract == 0 && $num_extracts_in_progress == 0){
      delete $this->{Extracting};
    }
    $this->KickAnalysis;
  }
  sub LinkDone{
    my($this, $next) = @_;
    my $link_count = 0;
    my $sub = sub {
      my($disp, $sock) = @_;
      my $from_file = $next->{source_file};
      my $to_file = $next->{dest_file};
      my $digest = $next->{digest};
      push(@{$this->{AnalysisQueue}}, $next);
      delete $this->{ExtractsInProgress}->{$from_file};
      $this->{Extracted} += 1;
      $link_count +=1;
      if($link_count > 100){
        $link_count = 0;
        $this->KickAnalysis;
      }
      $this->NextExtraction;
      $disp->Remove;
    };
    return $sub;
  }
  sub LinkFiles{
    my($this) = @_;
    my $link_count = 0;
    my $sub = sub {
      my($disp) = @_;
      if(@{$this->{ExtractList}} > 0){
        my $next = shift(@{$this->{ExtractList}});
        my $from_file = $next->{source_file};
        my $to_file = $next->{dest_file};
        my $digest = $next->{digest};
        unless(link $next->{source_file}, $next->{dest_file}){
          push(@{$this->{errors}}, "Unable to construct hard link ($!) " .
            "\"$next->{source_file}\" \"$next->{dest_file}\"");
          return;
        }
        push(@{$this->{AnalysisQueue}}, $next);
        $this->{Extracted} += 1;
        $link_count +=1;
        if($link_count > 100){
          $this->KickAnalysis;
        }
      } else {
        $this->KickAnalysis;
        delete $this->{Extracting};
      }
      if(exists $this->{Extracting}) { $disp->queue }
    };
    return $sub;
  }
  sub InitEdits{
    my($this) = @_;
    my @files_to_edit;
    for my $f (keys %{$this->{FileEdits}}){
      $this->{SourceToDest}->{$this->{FileEdits}->{$f}->{from_file}} =
        $this->{FileEdits}->{$f}->{to_file};
      push(@files_to_edit, $this->{FileEdits}->{$f});
    }
    if(@files_to_edit > 0){
      $this->{Editing} = 1;
      $this->{EditList} = \@files_to_edit;
    }
    $this->{TotalToEdit} = @files_to_edit;
    $this->{Edited} = 0;
  }
  sub KickEdit{
    my($this) = @_;
    unless($this->{EditPending}){
      $this->{EditPending} = 1;
      $this->InvokeAfterDelay("NextEdit", 0);
    }
  }
  sub NextEdit{
    my($this) = @_;
    delete $this->{EditPending};
    my $num_to_edit = @{$this->{EditList}};
    unless(exists $this->{EditsInProgress}) { $this->{EditsInProgress} = {} }
    my $num_in_progress = keys %{$this->{EditsInProgress}};
    while($num_to_edit > 0 && $num_in_progress < $this->{parallelism}){
#    while($num_to_edit > 0 && $num_in_progress < 3){
      my $next = shift(@{$this->{EditList}});
      my $key = $next->{from_file};
      $this->{EditsInProgress}->{$key} = $next;
      $this->SerializedSubProcess($next, "SubProcessEditor.pl",
        $this->WhenEditDone($next));
      $num_to_edit = @{$this->{EditList}};
      $num_in_progress = keys %{$this->{EditsInProgress}};
    }
    if($num_to_edit <= 0 && $num_in_progress <= 0){
      delete $this->{Editing};
    }
  }
  sub WhenEditDone{
    my($this, $next) = @_;
    my $sub = sub {
      my($status, $struct) = @_;
      my $key = $next->{from_file};
      $this->{Edited} += 1;
      delete $this->{EditsInProgress}->{$key};
      if($status eq "Succeeded" && $struct->{Status} eq "OK"){
        my $fh;
        unless(open $fh, "<$next->{to_file}"){
          print STDERR "can't open $next->{to_file} for digest\n";
          push(@{$this->{errors}}, "Can't open to file: $next->{to_file}");
          return;
        }
        my $ctx = Digest::MD5->new;
        $ctx->addfile($fh);
        close($fh);
        my $anal = {
          dest_file => $next->{to_file},
          digest => $ctx->hexdigest,
        };
        push(@{$this->{AnalysisQueue}}, $anal);
        $this->KickAnalysis;
      }
      $this->KickEdit;
    };
    return $sub;
  }
}
{
  package CopyAnalyzer;
  use vars qw( @ISA );
  @ISA = ( "Analyzer" );
    # $this->{files_to_link} = {
    #   <file_path> => <file_digest>,
    #   ...
    # };
    # $this->{info_dir} = <info directory>;
    # $this->{source} = <source directory>;
    # $this->{destination} => <destination directory>;
    # $this->{parallelism} = <num parallel edits>;
    # $this->{FileEdits} => {
    #   <from_file> => {             # file name only here
    #     from_file => <from_file>,  # full path here
    #     to_file => <to_file>,      # full_path here
    #     ... [see comments for Posda/bin/SubProcessEditor.pl]
    #   },
    #   ...
    # };
  sub StartProcessing{
    my($this) = @_;
    $this->{Status} = "Running";
    my @files_to_link;
    $this->{SourceToDest} = {};
    for my $f (keys %{$this->{files_to_link}}){
      $this->{SourceToDest}->{"$this->{source}/$f"} = "$this->{destination}/$f";
      push(@files_to_link, {
        source_file => "$this->{source}/$f",
        dest_file => "$this->{destination}/$f",
        digest => "$this->{files_to_link}->{$f}",
      });
    }
    $this->InitCopies;
    if(@files_to_link > 0){
      $this->{ExtractList} = \@files_to_link;
      $this->{Extracting} = 1;
      $this->{TotalToExtract} = @files_to_link;
      $this->{Extracted} = 0;
#      $this->{ExtractsInProgress} = {};
#      $this->NextExtraction;
      Dispatch::Select::Background->new($this->LinkFiles)->queue;
    }
    if($this->{Editing}){
      $this->NextEdit;
    }
  }
  sub NextExtraction{
    my($this) = @_;
    unless($this->{Extracting}) { return }
    my $num_to_extract = @{$this->{ExtractList}};
    my $num_extracts_in_progress = keys %{$this->{ExtractsInProgress}};
    while($num_to_extract > 0 && $num_extracts_in_progress < 20){
      my $next = shift(@{$this->{ExtractList}});
      my $from_file = $next->{source_file};
      my $to_file = $next->{dest_file};
      my $cmd = "ln \"$to_file\" \"$from_file\"";
      my $fh;
      open($fh, "$cmd|");
      $this->{ExtractsInProgress}->{$from_file} = $next;
      Dispatch::Select::Socket->new(
        $this->LinkDone($next), $fh)->Add("reader");
      $num_to_extract = @{$this->{ExtractList}};
      $num_extracts_in_progress = keys %{$this->{ExtractsInProgress}};
    }
    if($num_to_extract == 0 && $num_extracts_in_progress == 0){
      delete $this->{Extracting};
    }
    $this->KickAnalysis;
  }
  sub LinkDone{
    my($this, $next) = @_;
    my $link_count = 0;
    my $sub = sub {
      my($disp, $sock) = @_;
      my $from_file = $next->{source_file};
      my $to_file = $next->{dest_file};
      my $digest = $next->{digest};
      push(@{$this->{AnalysisQueue}}, $next);
      delete $this->{ExtractsInProgress}->{$from_file};
      $this->{Extracted} += 1;
      $link_count +=1;
      if($link_count > 100){
        $link_count = 0;
        $this->KickAnalysis;
      }
      $this->NextExtraction;
      $disp->Remove;
    };
    return $sub;
  }
  sub LinkFiles{
    my($this) = @_;
    my $link_count = 0;
    my $sub = sub {
      my($disp) = @_;
      if(@{$this->{ExtractList}} > 0){
        my $next = shift(@{$this->{ExtractList}});
        my $from_file = $next->{source_file};
        my $to_file = $next->{dest_file};
        my $digest = $next->{digest};
        unless(link $next->{source_file}, $next->{dest_file}){
          push(@{$this->{errors}}, "Unable to construct hard link ($!) " .
            "\"$next->{source_file}\" \"$next->{dest_file}\"");
          return;
        }
        push(@{$this->{AnalysisQueue}}, $next);
        $this->{Extracted} += 1;
        $link_count +=1;
        if($link_count > 100){
          $this->KickAnalysis;
        }
      } else {
        $this->KickAnalysis;
        delete $this->{Extracting};
      }
      if(exists $this->{Extracting}) { $disp->queue }
    };
    return $sub;
  }
  sub InitCopies{
    my($this) = @_;
    my @files_to_copy;
    for my $f (keys %{$this->{CopyFromOther}}){
      $this->{SourceToDest}->{$this->{FileEdits}->{$f}->{from_file}} =
        $this->{FileEdits}->{$f}->{to_file};
      push(@files_to_copy, $this->{CopyFromOther}->{$f});
    }
    if(@files_to_copy > 0){
      $this->{Editing} = 1;
      $this->{EditList} = \@files_to_copy;
    }
    $this->{TotalToEdit} = @files_to_copy;
    $this->{Edited} = 0;
  }
  sub KickCopy{
    my($this) = @_;
    unless($this->{EditPending}){
      $this->{EditPending} = 1;
      $this->InvokeAfterDelay("NextCopy", 0);
    }
  }
  sub NextCopy{
    my($this) = @_;
    delete $this->{EditPending};
    my $num_to_edit = @{$this->{EditList}};
    unless(exists $this->{EditsInProgress}) { $this->{EditsInProgress} = {} }
    my $num_in_progress = keys %{$this->{EditsInProgress}};
    while($num_to_edit > 0 && $num_in_progress < $this->{parallelism}){
      my $next = shift(@{$this->{EditList}});
      my $key = $next->{from_file};
      $this->{EditsInProgress}->{$key} = $next;
      my $cmd = "cp \"$next->{copy_from_other}\" \"$next->{to_file}\"";
print STDERR "Extraction Command: $cmd \n";
      my $fh;
      open($fh, "$cmd}=|");
      Dispatch::Select::Socket->new($this->WhenCopyDone($next), $fh);
      $num_to_edit = @{$this->{EditList}};
      $num_in_progress = keys %{$this->{EditsInProgress}};
    }
    if($num_to_edit <= 0 && $num_in_progress <= 0){
      delete $this->{Editing};
    }
  }
  sub WhenCopyDone{
    my($this, $next) = @_;
    my $sub = sub {
      my($disp, $sock) = @_;
      my $key = $next->{from_file};
      $this->{Edited} += 1;
      delete $this->{EditsInProgress}->{$key};
      my $fh;
      unless(open $fh, "<$next->{to_file}"){
        print STDERR "can't open $next->{to_file} for digest\n";
        push(@{$this->{errors}}, "Can't open to file: $next->{to_file}");
        return;
      }
      my $ctx = Digest::MD5->new;
      $ctx->addfile($fh);
      close($fh);
      my $anal = {
        dest_file => $next->{to_file},
        digest => $ctx->hexdigest,
      };
      push(@{$this->{AnalysisQueue}}, $anal);
      $this->KickAnalysis;
      $this->KickEdit;
    };
    return $sub;
  }
}
{
  package RelinkAnalyzer;
  use vars qw( @ISA );
  @ISA = ( "EditorAnalyzer" );
  # Inherits from EditorAnalyzer
  # Overrides InitEdits and NextEdit
  sub InitEdits{
    my($this) = @_;
    my @files_to_edit;
    for my $f (keys %{$this->{RelinkSS}}){
      $this->{SourceToDest}->{$this->{RelinkSS}->{$f}->{from_file}} =
        $this->{RelinkSS}->{$f}->{to_file};
      push(@files_to_edit, $this->{RelinkSS}->{$f});
    }
    if(@files_to_edit > 0){
      $this->{Editing} = 1;
      $this->{EditList} = \@files_to_edit;
    }
    $this->{TotalToEdit} = @files_to_edit;
    $this->{Edited} = 0;
  }
  sub NextEdit{
    my($this) = @_;
    delete $this->{EditPending};
    my $num_to_edit = @{$this->{EditList}};
    unless(exists $this->{EditsInProgress}) { $this->{EditsInProgress} = {} }
    my $num_in_progress = keys %{$this->{EditsInProgress}};
    while($num_to_edit > 0 && $num_in_progress < $this->{parallelism}){
#    while($num_to_edit > 0 && $num_in_progress < 3){
      my $next = shift(@{$this->{EditList}});
      my $key = $next->{from_file};
      $this->{EditsInProgress}->{$key} = $next;
      $this->SerializedSubProcess($next, "SubProcessFullRelinker.pl",
        $this->WhenEditDone($next));
      $num_to_edit = @{$this->{EditList}};
      $num_in_progress = keys %{$this->{EditsInProgress}};
    }
    if($num_to_edit <= 0 && $num_in_progress <= 0){
      delete $this->{Editing};
    }
  }
}
###  These routines create closures to queue
sub MakeExtractAndAnalyze{
  my($spec) = @_;
  my $sub = sub {
    my($disp) = @_;
    NewExtractorAnalyzer->new($spec);
  };
  return $sub;
}
sub MakeEditAndAnalyze{
  my($spec) = @_;
  my $sub = sub {
    my($disp) = @_;
    EditorAnalyzer->new($spec);
  };
  return $sub;
}
sub MakeRelinkAndAnalyze{
  my($spec) = @_;
  my $sub = sub {
    my($disp) = @_;
    RelinkAnalyzer->new($spec);
  };
  return $sub;
}
sub MakeCopyAndAnalyze{
  my($spec) = @_;
  my $sub = sub {
    my($disp) = @_;
    CopyAnalyzer->new($spec);
  };
  return $sub;
}
####

### Execution of main prog continues here
my $cmd_file = $ARGV[0];
unless(-f $cmd_file) { die "Cmd file: \"$cmd_file\" doesn't exist" }
my $spec = retrieve($cmd_file);
unless(ref($spec) eq "HASH") { die "Descriptor ($cmd_file) is not a hash" }
unless(exists $spec->{operation}) { die "Descriptor has no operation" }
{
  if($spec->{operation} eq "ExtractAndAnalyze"){
    Dispatch::Select::Background->new(MakeExtractAndAnalyze($spec))->queue;
  } elsif($spec->{operation} eq "EditAndAnalyze"){
    if(exists $spec->{FileEdits}){
      Dispatch::Select::Background->new(MakeEditAndAnalyze($spec))->queue;
    } elsif(exists $spec->{RelinkSS}){
      Dispatch::Select::Background->new(MakeRelinkAndAnalyze($spec))->queue;
    } elsif(exists $spec->{CopyFromOther}){
      Dispatch::Select::Background->new(MakeCopyAndAnalyze($spec))->queue;
    }
  } else {
    die "Unknown operation in \"$cmd_file\": $spec->{operation}"
  }
}
Dispatch::Select::Dispatch();
