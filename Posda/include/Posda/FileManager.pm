#!/usr/bin/perl -w
#$Source: /home/bbennett/pass/archive/Posda/include/Posda/FileManager.pm,v $
#$Date: 2013/06/21 20:05:42 $
#$Revision: 1.47 $
#
#  FileManager manages several hashs for in use DICOM files.
#  FileManager->{ManagedFiles}->
#    by_file => 
#      { <full_path_file_name> => 
#        { access_ts => , digest => }, ... }
#    by_digest => 
#      { <digest> => 
#        { dataset_digest => <hex digest>,
#          Files => { <full_path_file_name> => 1, ..},
#          dataset_start_offset => #,
#          dvhs => [ ],  (for dose files...)
#          pix_pos => #,
#          type => "Dicom",
#          xfr_stx => "...", }, ... }
#    by_dataset_digest =>
#      { <dataset_digest> => 
#        { ... Bulk of DICOM info known about this dataset... }, ... }
#    by_sop_instance => 
#      { <sop_uid> => 
#        { <digests => 
#          { <hex digest> => 1, ... } }
#        { <dataset_digests => 
#          { <hex digest> => 1, ... } } }
# 
#  So...  for a given file, use by_file to get digest,
#         then use digest with by digest to get dataset_digest,
#         then use dataset_digest to get DICOM info...
#  Or use $fm->DicomInfo($file) to get the DICOM info hash for a file.
#  Or use $fm->FileDigestInfo($file) to get the digest info hash. 
#                    
use strict;
{
  package Posda::FileManager;
  use POSIX ":sys_wait_h";
  use Storable qw( store retrieve store_fd fd_retrieve );
  use Fcntl qw(:flock);
  use Socket;
  use IO::Handle;
  use vars qw( @ISA );
  @ISA = ( "Posda::HttpObj" );
  sub new {
    my($class, $sess, $path, $workdir, $cache_dir) = @_;
    my $this = Posda::HttpObj->new($sess, $path);
    $this->{Exports}->{DicomInfo} = 1;
    $this->{workdir} = $workdir;
    if (defined $cache_dir) {
      $this->{cache_dir} = $cache_dir;
    } else {
      $this->{cache_dir} = $workdir;
    }
    if($NewDiCompiler::IsWindows) {
      if ($this->{workdir} =~ m/^([a-z]|[A-Z]):(.+)/ ) {
        $this->{workdir} = (uc $1 ) . ":" . $2;
      }
      if ($this->{cache_dir} =~ m/^([a-z]|[A-Z]):(.+)/ ) {
        $this->{cache_dir} = (uc $1 ) . ":" . $2;
      }
    }
    unless(-d $this->{workdir}){ die "$this->{workdir} is not a dir" }
    unless(-d $this->{cache_dir})
      { die "$this->{cache_dir} is not a dir" }
    # setup dicom_info cache dir...
    $this->{DicomInfoDir} = "$this->{cache_dir}/dicom_info";
    unless(-d $this->{DicomInfoDir}) {
      mkdir($this->{DicomInfoDir},0775) ||
        die "Error $! on mkdir $this->{DicomInfoDir}";
    }
    Posda::FileManager->CreateCacheSubDirs($this->{DicomInfoDir});
    # setup contour_files cache dir...
    $this->{ContourDir} = "$this->{cache_dir}/contour_files";
    unless(-d $this->{ContourDir}) {
      mkdir($this->{ContourDir},0775) ||
        die "Error $! on mkdir $this->{ContourDir}";
    }
    unless(-d $this->{ContourDir})
      { die "bad contour dir $this->{ContourDir}" }
    Posda::FileManager->CreateCacheSubDirs($this->{ContourDir});
    # setup dvh_files cache dir...
    $this->{DvhDir} = "$this->{cache_dir}/dvh_files";
    unless(-d $this->{DvhDir}) {
      mkdir($this->{DvhDir},0775) ||
        die "Error $! on mkdir $this->{DvhDir}";
    }
    unless(-d $this->{DvhDir})
      { die "bad contour dir $this->{DvhDir}" }
    Posda::FileManager->CreateCacheSubDirs($this->{DvhDir});

    $this->{home} = $this->{workdir};
    $this->{ManagedFiles} = {};
    $this->{MaxAnalysisProcs} = 3;
    if ($NewDiCompiler::IsWindows){ $this->{MaxAnalysisProcs} = 1; }
    if (defined $NewItcTools::NumProcs) {
      $this->{MaxAnalysisProcs} = $NewItcTools::NumProcs;
      # print STDERR "FileManager: # Procs: $this->{MaxAnalysisProcs}.\n";
    }
    $this->{MaxAnalysisProcs} = 3;
    bless $this, $class;
    $this->Initialize;
    return $this;
  }
  sub Initialize{
  }
  sub ForgetFiles{
    my($this, $notify) = @_;
    unless($this->{update_in_progress}){
      return($this->DoForgetFiles($notify));
    }
    $this->{ForgetFiles} = 1;
    $this->{FilesForgotten}->{$notify} = 1;
  }
  sub DoForgetFiles{
    my($this, $notify) = @_;
    $this->{ManagedFiles} = {
      by_dataset_digest => {},
      by_digest => {},
      by_file => {},
      by_sop_instance => {},
    };
    my $obj = $this->get_obj($notify);
    if($obj && ref($obj) && $obj->can("IForgot")){
      my $foo = sub {
        my($self) = @_;
        $obj->IForgot;
      };
      Dispatch::Select::Background->new($foo)->queue;
    }
  }
  sub CreateCacheSubDirs{
    my($class, $dir) = @_;
    my @dirs_needed = ('0', '1', '2', '3', '4', '5', '6', '7', '8', '9', 
                       'a', 'b', 'c', 'd', 'e', 'f');
    foreach my $lev1 (@dirs_needed) {
      unless(-d "$dir/$lev1"){
        mkdir("$dir/$lev1",0775) || die "Error $! on mkdir $dir/$lev1";
      }
      unless(-d "$dir/$lev1") 
        { die "bad contour dir, error makeing dir: $dir/$lev1" }
      foreach my $lev2 (@dirs_needed) {
        unless(-d "$dir/$lev1/$lev2"){
          mkdir("$dir/$lev1/$lev2",0775) || 
            die "Error $! on mkdir $dir/$lev1/$lev2";
        }
        unless(-d "$dir/$lev1/$lev2") 
          { die "bad contour dir, error making dir: $dir/$lev1/$lev2" }
      }
    }

  }
  sub GarbageCollect{
    my($this) = @_;
print "GarbageCollect called\n";
    my $changed = 0;
    for my $i (keys %{$this->{ManagedFiles}->{by_digest}}){
      my $item = $this->{ManagedFiles}->{by_digest}->{$i};
      for my $file (keys %{$item->{Files}}){
        unless(-f $file){ 
          $changed = 1;
          delete $item->{Files}->{$file};
        }
      }
      unless(scalar(keys %{$item->{Files}}) > 0){
        delete $this->{ManagedFiles}->{by_digest}->{$i};
      }
    }
    for my $file (keys %{$this->{ManagedFiles}->{by_file}}){
      unless(-f $file){
        $changed = 1;
        delete $this->{ManagedFiles}->{by_file}->{$file};
      }
    }
    for my $ds (keys %{$this->{ManagedFiles}->{by_dataset_digest}}){
      my $item = $this->{ManagedFiles}->{by_dataset_digest}->{$ds};
      for my $dig (keys %{$item->{digests}}){
        unless(exists $this->{ManagedFiles}->{by_digest}->{$dig}){
          $changed = 1;
          delete $item->{digests}->{$dig};
        }
      }
#      my $num_digs = scalar keys %{$item->{digests}};
#      if($num_digs == 0){
#        $changed = 1;
#        delete $this->{ManagedFiles}->{by_dataset_digest}->{$ds};
#      }
    }
#    for my $sop (keys %{$this->{ManagedFiles}->{by_sop_instance}}){
#      my $item = $this->{ManagedFiles}->{by_sop_instance}->{$sop};
#      for my $dig (keys %{$item->{digests}}){
#        unless(exists $this->{ManagedFiles}->{by_digest}->{$dig}){
#          $changed = 1;
#          delete $item->{digests}->{$dig};
#        }
#      }
#      unless(scalar(keys %{$item->{digests}}) > 0){
#        delete $this->{ManagedFiles}->{by_sop_instance}->{$sop};
#      }
#    }
    if ($changed) { $this->{ReturningManagedFilesDataGood} = 0; }
    return $changed;
  }
  sub MakeNotifier{
    my($this, $obj_name, $obj_method, $digest) = @_;
    my $foo = sub {
      my($disp) = @_;
      my $not = $this->get_obj($obj_name);
      if(defined($not) && $not->can($obj_method)){
        $not->$obj_method($digest);
      } elsif($not) {
        print STDERR "$not->{path} can't $obj_method($digest)\n";
      } else{
        print STDERR "Object named $obj_name not found for Notify\n";
      }
    };
    return $foo;
  }
  sub QueueFile{
    my($this, $digest, $file, $priority, $notify_obj, $notify_method) = @_;
    if($digest eq "") {
      print STDERR "$this->{path}->QueueFile Called with empty digest\n";
      return;
    }
    if($file eq "") {
      print STDERR "$this->{path}->QueueFile Called with empty file\n";
      return;
    }
    unless(-f $file){
      print STDERR "$this->{path}->QueueFile Called " .
        "with non-existent file: $file\n";
      return;
    }
    unless(defined $priority) { $priority = 0 }
    $this->{Priority}->{$digest} = $priority;
    if(defined $notify_obj){
      unless(defined $notify_method){
        $notify_method = "FileProcessedByFileManager";
      }
      my $closure = $this->MakeNotifier($notify_obj, $notify_method, $digest);
      unless(exists $this->{Notifiers}->{$digest}){
        $this->{Notifiers}->{$digest} = [];
      }
      push(@{$this->{Notifiers}->{$digest}}, 
        Dispatch::Select::Background->new($closure));
    }
    my $img_obj = $this->child("PixelExtractor");
    if($img_obj && $img_obj->can("abort")){ $img_obj->abort }
    my $dvh_obj = $this->child("DvhExtractor");
    if($dvh_obj && $dvh_obj->can("abort")){ $dvh_obj->abort }
    if(exists $this->{ManagedFiles}->{by_digest}->{$digest}){
      $this->{ManagedFiles}->{by_digest}->{$digest}->{Files}->{$file} = 1;
      # $this->{file_dupe_queue}->{$digest}->{$file} = 1;
      $this->{ManagedFiles}->{by_file}->{$file}->{access_ts} = time;
      my @foo = stat $file;
      my $m_time = $foo[9];
      my $size = $foo[7];
      $this->{ManagedFiles}->{by_file}->{$file}->{size} = $size;
      $this->{ManagedFiles}->{by_file}->{$file}->{m_time} = $m_time;
      $this->{ManagedFiles}->{by_file}->{$file}->{digest} = $digest;
      $this->{ReturningManagedFilesDataGood} = 0;
      if(exists $this->{Notifiers}->{$digest}){
        for my $not (@{$this->{Notifiers}->{$digest}}){
          if(defined $not && $not->can("queue")){
            $not->queue;
          }
        }
        delete $this->{Notifiers}->{$digest};
      }
      return;
    }
    if(exists $this->{file_queue}->{$digest}){
      $this->{file_dupe_queue}->{$digest}->{$file} = 1;
      return;
    }
    $this->{file_queue}->{$digest} = $file;
    if(exists($this->{update_in_progress})){ return }
    $this->{update_in_progress} = 1; 
    $this->{ReturningManagedFilesDataGood} = 0;
    $this->StartProcessingFiles;
#    Dispatch::Iterator::Iterate($this, 
#      "start", "iterate", "end_test", "finalize");
  }
  sub Busy{
    my($this) = @_;
    unless(exists($this->{update_in_progress})){ return undef }
    unless(exists $this->{file_queue}) { return "finishing" }
    my $count = scalar(keys %{$this->{file_queue}});
    my $resp = "";
    for my $file (keys %{$this->{in_process_files}}) {
      $this->{in_process_files}->{$file}->{progress} .= "."; 
      $resp .= 
      "<br>Processing: $file $this->{in_process_files}->{$file}->{progress}\n";
    }
    if ($count == 0) { return $resp; }
    return "$count files remaining to be queued.<br>" . $resp;
  }
  sub Clear{
    my($this) = @_;
    print STDERR "FileManager Clear called...\n";
    $this->{ManagedFiles} = {};
    $this->{ReturningManagedFilesDataGood} = 0;
  }
  sub StartProcessingFiles{
    my($this) = @_;
    $this->{in_process_files} = {};
    $this->CrankFileList;
  }
  sub CrankFileList{
    my($this) = @_;
    my $count_in_process = keys %{$this->{in_process_files}};
    my $count_cache_in_process = keys %{$this->{in_process_cache_files}};
    my $tot_in_process = $count_in_process + $count_cache_in_process;
    if($tot_in_process >= $this->{MaxAnalysisProcs}){ return }
    my @list = sort {fq_cmp($this,$a,$b)} keys %{$this->{file_queue}};
    my $to_do = @list;
    unless(scalar @list > 0) {
      if($tot_in_process > 0) { return }
      if($count_in_process == 0){
        $this->ProcessDupeQueue;
        delete $this->{update_in_progress};
        delete $this->{in_process_files};
        delete $this->{file_queue};
        $this->FinishNotify();
        $this->PurgePriorities;
        if ((scalar keys %{$this->{Notifier}}) > 0) {
          print STDERR 
            "FileManager::_finalize: " .
            "hash in_process_files & file_queue empty & There are " .
            (scalar keys %{$this->{Notifier}}) . 
            " Notifiers still waiting!!!!! (Bill said to call him...)\n";
          exit(-1);
        }
        $this->PurgeNotifications;
        $this->Finalize;
      }
      return;
    }
    my $digest = $list[0];
    my $file = $this->{file_queue}->{$digest};
    my $cfh = $this->GetCachedFileInfoHandle($digest);
    if($cfh) {
      delete $this->{file_queue}->{$digest};
      my $reader = Dispatch::Select::Socket->new(
                   $this->create_cache_reader($file, $digest), $cfh);
      $this->{in_process_cache_files}->{$file} = 
        { progress => "", reader => $reader} ;
      $reader->Add("reader");
      $this->CrankFileList;
      return;
    }
#    $this->{file_being_processed} = $file;
    delete $this->{file_queue}->{$digest};
    my $cmd = $this->AnalyzerCmd($file);
    my $fh = FileHandle->new("$cmd|");
    unless($fh) {
      print STDERR "failed to open $cmd| ($!)\n";
      if(-r $file) {
#        delete $this->{file_being_processed};
        $this->{file_queue}->{$digest} = $file;
      }
      return;
    }
    my $reader = Dispatch::Select::Socket->new(
                   $this->create_reader($file, $digest), $fh);
    $this->{in_process_files}->{$file} = 
      { progress => "", reader => $reader} ;
    $reader->Add("reader");
    $this->CrankFileList;
  }
  sub create_cache_reader{
    my($this, $file, $digest) = @_;
    my $sub = sub {
      my($disp, $socket) = @_;
      my $analysis;
      eval {
        $analysis = fd_retrieve($socket);
      };
      if ($@) {
        # Will need to comment out following print at some time - happens.
        # Are you sure?  Should this ever happen?
        print STDERR "DICOM Analyzer process aborted ($file).\n".
                     "  Error: $@.\n";
      } else {
        $this->handle_response($analysis, $file, $digest);
      }
      $disp->Remove;
      delete $this->{in_process_cache_files}->{$file};
      if (exists $this->{PauseIteration}) {
        $this->{PauseIteration}->post;
        delete $this->{PauseIteration};
      }
      if(exists $this->{Notifiers}->{$digest}){
        for my $not (@{$this->{Notifiers}->{$digest}}){
          if(defined $not && $not->can("queue")){
            $not->queue;
          }
        }
        delete $this->{Notifiers}->{$digest};
      }
      if(exists $this->{Priority}->{$digest}){
        delete $this->{Priority}->{$digest};
      }
      $this->CrankFileList;
    };
    return $sub;
  }
  sub create_reader{
    my($this, $file, $digest) = @_;
    my $sub = sub {
      my($disp, $socket) = @_;
      my $analysis;
      eval {
        $analysis = fd_retrieve($socket);
      };
      if ($@) {
        # Will need to comment out following print at some time - happens.
        # Are you sure?  Should this ever happen?
        print STDERR "DICOM Analyzer process aborted ($file).\n".
                     "  Error: $@.\n";
      } else {
        $this->handle_response($analysis, $file, $digest);
      }
      $disp->Remove;
      delete $this->{in_process_files}->{$file};
      if (exists $this->{PauseIteration}) {
        $this->{PauseIteration}->post;
        delete $this->{PauseIteration};
      }
      if(exists $this->{Notifiers}->{$digest}){
        for my $not (@{$this->{Notifiers}->{$digest}}){
          if(defined $not && $not->can("queue")){
            $not->queue;
          }
        }
        delete $this->{Notifiers}->{$digest};
      }
      if(exists $this->{Priority}->{$digest}){
        delete $this->{Priority}->{$digest};
      }
      $this->CrankFileList;
    };
    return $sub;
  }
  sub _add_file_to_ManagedFiles{
    my($this, $analysis, $file, $digest) = @_;
    if (exists($this->{ManagedFiles}->{by_file}->{$file})) {
      if ($this->{ManagedFiles}->{by_file}->{$file}->{digest} ne $digest){
        print STDERR "File's digest changed $file\n";
        delete $this->{ManagedFiles}->{by_digest}->{
          $this->{ManagedFiles}->{by_file}->{$file}->{digest}}
          ->{Files}->{$file};
        delete $this->{ManagedFiles}->{by_file}->{$file};
      }
    }
    $this->{ManagedFiles}->{by_file}->{$file}->{digest} = $digest;
    $this->{ManagedFiles}->{by_file}->{$file}->{access_ts} = time;
    my @foo = stat $file;
    my $m_time = $foo[9];
    my $size = $foo[7];
    $this->{ManagedFiles}->{by_file}->{$file}->{size} = $size;
    $this->{ManagedFiles}->{by_file}->{$file}->{m_time} = $m_time;
    if ($#{$analysis->{dvhs}} >= 0) {
       # ???
    }
    if(exists $this->{ManagedFiles}->{by_digest}->{$digest}){
      $this->{ManagedFiles}->{by_digest}->{$digest}->{Files}->{$file} = 1;
    } else {
      $this->{ManagedFiles}->{by_digest}->{$digest} = {
         Files => {
           $file => 1,
         },
         type => "Dicom",
         dataset_digest => $analysis->{dataset_digest},
         dataset_start_offset => $analysis->{dataset_start_offset},
         xfr_stx => $analysis->{xfr_stx},
      };
      delete $analysis->{xfr_stx};
      delete $analysis->{dataset_start_offset};
      if(exists $analysis->{pix_pos}){
        $this->{ManagedFiles}->{by_digest}->{$digest}->{pix_pos} =
          $analysis->{pix_pos};
        delete $analysis->{pix_pos};
      }
      if(exists $analysis->{gfov_pos}){
        $this->{ManagedFiles}->{by_digest}->{$digest}->{gfov_pos} =
          $analysis->{gfov_pos};
        delete $analysis->{gfov_pos};
      }
      if (exists $analysis->{dvhs}) {
        $this->{ManagedFiles}->{by_digest}->{$digest}->{dvhs} = 
          $analysis->{dvhs};
        delete $analysis->{dvhs}
      }
    }
  }
  sub handle_response{
    my($this, $analysis, $file, $digest) = @_;
    unless (defined $analysis) { return }
    if ($digest ne $analysis->{digest}) {
      die "DICOM Analyzer process error: returned digest: " .
        "$analysis->{digest} does not match requested digest: $digest.";
    }
    if ($file ne $analysis->{file}) {
#     Whoa!!  This was going off all the time and caused a crash when
#      changed to a die.  This probably means that there's a (harmless)
#      logic error in handling of dup files....
#
#      die "DICOM Analyzer process error: returned file: " .
#        "\"$analysis->{file}\" does not match requested file: \"$file\".";
    }
    $this->CacheAnalysis($analysis, $file, $digest);
    $this->{ReturningManagedFilesDataGood} = 0;
    if($analysis->{TypeOfResult} eq "DicomAnalysis"){
      my $ds_digest = $analysis->{dataset_digest};
      delete $analysis->{file};
      delete $analysis->{digest};
      $this->_add_file_to_ManagedFiles($analysis, $file, $digest);
      if (exists $this->{file_dupe_queue}->{$digest}) {
        for my $f (keys %{$this->{file_dupe_queue}->{$digest}}){
          $this->_add_file_to_ManagedFiles($analysis, $f, $digest);
        }
        delete $this->{file_dupe_queue}->{$digest}
      }
      if(defined($analysis->{dataset_digest})){
        if(
          exists(
          $this->{ManagedFiles}->{by_dataset_digest}->
            {$analysis->{dataset_digest}}
          )
        ){ 
          $this->{ManagedFiles}->{by_dataset_digest}->
            {$analysis->{dataset_digest}}->{digests}->{$digest} = 1;
        } else {
          $analysis->{digests}->{$digest} = 1;
          $this->{ManagedFiles}->{by_dataset_digest}->
            {$analysis->{dataset_digest}} = $analysis;
        }
      } else {
        $this->{ManagedFiles}->{by_digest}->{$digest}->{type} =
          "Dicom Dir ??";
      }
      if(defined $analysis->{sop_inst_uid}){
        $this->{ManagedFiles}->{by_sop_instance}->{$analysis->{sop_inst_uid}}
          ->{digests}->{$digest} = 1;
        $this->{ManagedFiles}->{by_sop_instance}->{$analysis->{sop_inst_uid}}
          ->{dataset_digests}->{$analysis->{dataset_digest}} = 1;
      }
    } else {
      if(
        exists($this->{ManagedFiles}->{by_file}->{$file}) &&
        $this->{ManagedFiles}->{by_file}->{$file}->{digest} ne $digest
      ){
        print STDERR "File's digest changed $file\n";
      } else {
        $this->{ManagedFiles}->{by_file}->{$file}->{digest} = $digest;
      }
      $this->{ManagedFiles}->{by_file}->{$file}->{access_ts} = time;
      my @foo = stat $file;
      my $m_time = $foo[9];
      my $size = $foo[7];
      $this->{ManagedFiles}->{by_file}->{$file}->{size} = $size;
      $this->{ManagedFiles}->{by_file}->{$file}->{m_time} = $m_time;
      if(exists $this->{ManagedFiles}->{by_digest}->{$digest}){
        $this->{ManagedFiles}->{by_digest}->{$digest}->{Files}->{$file} = 1;
        $this->{ManagedFiles}->{by_digest}->{$digest}->{type} = "Not Dicom";
      } else {
        $this->{ManagedFiles}->{by_digest}->{$digest} = {
          Files => {
            $file => 1,
          },
          type => "Not Dicom",
          analysis => $analysis,
        };
      }
    }
  }
  sub GetCachedFileInfoHandle{
    my($this, $digest) = @_;
    my($one, $two) = $digest =~/^(.)(.)/;
    my $dir = "$this->{DicomInfoDir}/$one/$two";
    my $ffn = "$dir/$digest.dcminfo";
    if(-f $ffn){
      open my $fh, "cat $ffn|";
      return $fh;
    }
    return undef;
  }
  sub CacheAnalysis{
    my($this, $analysis, $file, $digest) = @_;
    my($one, $two) = $digest =~/^(.)(.)/;
    my $dir = "$this->{DicomInfoDir}/$one/$two";
    my $wfn = "$dir/$this->{session}_$digest";
    my $ffn = "$dir/$digest.dcminfo";
    if(-f $ffn) { return }
    open my $fh, ">$wfn";
    unless($fh) {
      print STDERR "Can't open $wfn for writing\n";
      return;
    }
    store_fd $analysis, $fh;
    close($fh);
    unless(link $wfn, $ffn){
      print STDERR "Can't link $wfn to $ffn\n";
    }
    unlink $wfn;
  }
  sub fq_cmp {
  #  -1 if $a should appear BEFORE $b in the sorted list
  #   0 if $a and $b are equal in the sort order
  #   1 if $a should appear AFTER $b in the sorted list
    my($this, $a, $b) = @_;
    my $afn = "";
    my $bfn = "";
    if ($this->{file_queue}->{$a}  =~ m/.*\/(....).*$/)  
      { $afn = uc $1; }
    if ($this->{file_queue}->{$b}  =~ m/.*\/(....).*$/) 
      { $bfn = uc $1; }
    # print "FileManager: cmp a: $afn to b; $bfn.\n";
    if ($afn eq $bfn) { return 0; }

    if ($afn =~ m/^CT/)  { return 1; }
    if ($afn =~ m/^MR/)  { return 1; }
    if ($afn =~ m/^RI/)  { return 1; }
    if ($bfn =~ m/^CT/) { return -1; }
    if ($bfn =~ m/^MR/) { return -1; }
    if ($bfn =~ m/^RI/) { return -1; }

    if ($afn =~ m/^R.*S/)  { return -1; }
    if ($bfn =~ m/^R.*S/)  { return 1; }

    if ($afn =~ m/^SS/)  { return -1; }
    if ($bfn =~ m/^SS/)  { return 1; }
    return 0;
  }
  sub AnalyzerCmd {
    my($this, $file) = @_;
    $file =~ s/\"/\\\"/g;
    $file =~ s/\$/\\\$/g;
    return "DicomAnalyzer.pl \"$file\"";
  }
  sub Finalize {
  }
  sub PurgePriorities{
    my($this) = @_;
    delete $this->{Priority};
  }
  sub PurgeNotifications{
    my($this) = @_;
    delete $this->{Notifier};
  }
  sub QueuerFinished{
    my($this) = @_;
    # $this->ProcessDupeQueue;
    my $img_obj = $this->child("PixelExtractor");
    if($img_obj && $img_obj->can("kick_start")){ $img_obj->kick_start }
    my $dvh_obj = $this->child("DvhExtractor");
    if($dvh_obj && $dvh_obj->can("kick_start")){ $dvh_obj->kick_start }
  }
  sub ProcessDupeQueue{
    my($this) = @_;
    for my $digest(keys %{$this->{file_dupe_queue}}){
      for my $file (keys %{$this->{file_dupe_queue}->{$digest}}){
        $this->{ManagedFiles}->{by_digest}->{$digest}->{Files}->
          {$file} = 1;
        $this->{ManagedFiles}->{by_file}->{$file}->{digest} = $digest;
        $this->{ManagedFiles}->{by_file}->{$file}->{access_ts} = time;
        my @foo = stat $file;
        my $m_time = $foo[9];
        my $size = $foo[7];
        $this->{ManagedFiles}->{by_file}->{$file}->{size} = $size;
        $this->{ManagedFiles}->{by_file}->{$file}->{m_time} = $m_time;
      }
      if(exists $this->{Notifiers}->{$digest}){
        for my $not (@{$this->{Notifiers}->{$digest}}){
          if(defined $not && $not->can("queue")){
            $not->queue;
          }
        }
        delete $this->{Notifiers}->{$digest};
      }
    }
    delete $this->{file_dupe_queue};
  }
  ##########################################################
  #  Performance Enhancers here
  #    IsKnownFile tells you that the file doesn't need to have
  #      its MD5 recalculated (it has the same date/time and size
  #      as a file with the same full path)
  #    LinkKnownFile creates a hard link and updates tables (since
  #      you already known MD5, etc) if the file being linked is
  #      already a known file
  #    FileDigest is used in cases where you need the file digest and
  #      you are sure the file hasn't changed. 
  #
  sub IsKnownFile{
    my($this, $file) = @_;
    unless(exists $this->{ManagedFiles}){ return undef }
    unless (exists $this->{ManagedFiles}->{by_file}->{$file}) { return undef; }
    my @foo = stat $file;
    my $m_time = $foo[9];
    my $size = $foo[7];
    if(
      $this->{ManagedFiles}->{by_file}->{$file}->{m_time} == $m_time &&
      $this->{ManagedFiles}->{by_file}->{$file}->{size} == $size
    ){ return 1 } else { return 0 }
  }
  sub LinkKnownFile{
    my($this, $from_file, $to_file) = @_;
    unless(link $from_file, $to_file){
      print STDERR 
        "LinkKnownFile: unable to link $from_file $to_file ($!)\n";
      return undef;
    }
    if($this->IsKnownFile($from_file)){
      for my $i (keys %{$this->{ManagedFiles}->{by_file}->{$from_file}}){
        $this->{ManagedFiles}->{by_file}->{$to_file}->{$i} = 
          $this->{ManagedFiles}->{by_file}->{$from_file}->{$i};
      }
    }
    return 1;
  }
  sub FileDigest{
    # get the digest of a file if already known
    # !!!! WARNING - do not use this if file may have changed!!!!!
    my ($this, $file) = @_;
    unless (exists $this->{ManagedFiles}) {
      print STDERR "FileManager::FileDigestInfo: Invalid FM obj, " .
        "no ManagedFiles hash.\n";
      return undef;
    }
    my $mf = $this->{ManagedFiles};
    unless (exists $mf->{by_file}->{$file}) { return undef; }
    return $mf->{by_file}->{$file}->{digest};
  }
  ##########################################################
  #  Handy Dandy accessor methods start here:
  #    FileDigestInfo($file) - returns a hash (or undef)
  #    DicomInfo($file) - returns a hash (or undef)
  #    DicomInfoByFileDigest($digest) returns a hash (or undef)
  #    DicomInfoBySop($sop) - returns hash or list of hashes  (or undef)
  #    FilesBySop($sop) - returns hash or list of hashes  (or undef)
  #    FilesByDigest($dig) - returns file or list of files (or undef)
  #    FilesByDatasetDigest($ds_dig) - returns file or list of files (or undef)
  #    DigestsByDatasetDigest($ds_dig) - returns dig or list of digs (or undef)
  #
  sub FileDigestInfo{
    # get the DICOM info hash from the FileManager 
    #   ->{ManagedFiles} hash for a given file.
    my ($this, $file) = @_;
    my $file_digest = $this->FileDigest($file);
    unless (defined $file_digest) { return undef; }
    my $mf = $this->{ManagedFiles};
    unless (exists $mf->{by_digest}->{$file_digest}) { return undef; }
    return $mf->{by_digest}->{$file_digest};
  }
  sub DicomInfo{
    # get the DICOM info hash from the FileManager 
    #   ->{ManagedFiles} hash for a given file.
    my ($this, $file) = @_;
    my $mf = $this->{ManagedFiles};
    my $file_digest_info = $this->FileDigestInfo($file);
    unless (defined $file_digest_info)  { return undef; }
    my $file_ds_digest = $file_digest_info->{dataset_digest};
    unless (defined $file_ds_digest)  { return undef; }
    unless (exists $mf->{by_dataset_digest}->{$file_ds_digest}) 
       { return undef; }
    return $mf->{by_dataset_digest}->{$file_ds_digest};
  }
  sub DicomInfoByFileDigest{
    my ($this, $digest) = @_;
    my $mf = $this->{ManagedFiles};
    unless(exists $mf->{by_digest}->{$digest}) { return undef }
    unless(exists $mf->{by_digest}->{$digest}->{datset_digest}) {
      return undef
    }
    my $ds_digest = $mf->{by_digest}->{$digest}->{dataset_digest};
    unless(exists $mf->{by_dataset_digest}->{$ds_digest}) { return undef }
    return $mf->{by_dataset_digest}->{$ds_digest};
  }
  # DicomInfoBySop returns either the DICOM info hash or a list
  # of DicomInfo hashes
  sub DicomInfoBySop{
    my ($this, $sop) = @_;
    my $mf = $this->{ManagedFiles};
    unless(exists $mf->{by_sop_instance}->{$sop}) { return undef }
    my @dsds = keys %{$mf->{by_sop_instance}->{$sop}->{dataset_digests}};
    if($#dsds == 0){
      return $mf->{by_dataset_digest}->{$dsds[0]};
    } else {
       my @list = map $mf->{by_dataset_digest}->{$_}, @dsds;
       return \@list;
    }
  }
  sub FilesBySop{
    my($this, $sop) = @_;
    my $mf = $this->{ManagedFiles};
    unless(exists $mf->{by_sop_instance}->{$sop}) { return undef }
    my @digests = keys %{$mf->{by_sop_instance}->{$sop}->{digests}};
    my %Files;
    for my $i (@digests){
      my $files = $this->FilesByDigest($i);
      if(ref($files) eq "ARRAY"){
        for my $j (@$files){
          if(-f $j){
            $Files{$j} = 1;
          }
        }
      } else {
        if(-f $files){
          $Files{$files} = 1;
        }
      }
    }
    my @files = keys %Files;
    if($#files == 0){ return $files[0] } else { return \@files }
  }
  sub FilesByDigest{
    my ($this, $digest) = @_;
    my $mf = $this->{ManagedFiles};
    unless(exists $mf->{by_digest}->{$digest}) { return undef }
    my @files_to_check = keys %{$mf->{by_digest}->{$digest}->{Files}};
    my @files;
    for my $i (@files_to_check){
      if(-f $i){ push @files, $i }
    }
    if($#files == 0){ return $files[0] } else { return \@files }
  }
  sub FilesByDatasetDigest{
    my ($this, $ds_dig) = @_;
    my $mf = $this->{ManagedFiles};
    my @digests = $this->DigestsByDatasetDigest($ds_dig);
    my %Files;
    for my $i (@digests){
      my $files = $this->FilesByDigest($i);
      if(ref($files) eq "ARRAY"){
        for my $j (@$files){
          if(-f $j){
            $Files{$j} = 1;
          }
        }
      } else {
        if(-f $i){
          $Files{$i} = 1;
        }
      }
    }
    my @files = keys %Files;
    if($#files == 0){ return $files[0] } else { return \@files }
  }
  sub DigestsByDatasetDigest{
    my ($this, $ds_dig) = @_;
    my $mf = $this->{ManagedFiles};
    unless(exists $mf->{by_dataset_digest}->{$ds_dig}) { return undef }
    my @digests = keys %{$mf->{by_dataset_digest}->{$ds_dig}->{digests}};
    if($#digests == 0){ return $digests[0] } else { return \@digests }
  }
}
1;
