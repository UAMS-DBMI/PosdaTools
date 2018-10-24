#!/usr/bin/perl -w
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
  package Posda::FileInfoManager;
  use POSIX ":sys_wait_h";
  use Storable qw( store retrieve store_fd fd_retrieve );
  use Socket;
  use IO::Handle;
  use Debug;
  my $dbg = sub { print STDERR @_ };
  use vars qw( @ISA );
  @ISA = ( "Dispatch::EventHandler" );
  sub new {
    my($class, $analyzer, $cache_dir, $num_procs) = @_;
    unless(defined($num_procs)) { $num_procs = 3 }
    unless(defined($num_procs)) { $num_procs = 3 }
    my $this = {
      MaxAnalysisProcs => $num_procs,
      Exports => "DicomInfo",
    };
    $this->{DicomAnalyzerProgram} = $analyzer;
    bless($this, $class);
    if($cache_dir && -d $cache_dir && -w $cache_dir){
      $this->{cache_dir} = $cache_dir;
      $this->{DicomInfoDir} = "$this->{cache_dir}/dicom_info";
      unless(-d $this->{DicomInfoDir}) {
        mkdir($this->{DicomInfoDir},0775) ||
          die "Error $! on mkdir $this->{DicomInfoDir}";
      }
      $this->CreateCacheSubDirs($this->{DicomInfoDir});
    }
    $this->{ManagedFiles} = {};
    $this->{SubProcesses} = 0;
    open FOO, "which md5sum 2>/dev/null|" or
      die "Can't open \"which md5sum\" ($!)";
    my $line = <FOO>;
    if($line) {
      $this->{Md5er} = "md5sum";
      $this->{Md5Match} = '(\S+)\s';
    } else {
      close FOO;
      open FOO, "which md5 2>/dev/null|" or
        die "Can't open \"which md5\" ($!)";
      $line = <FOO>;
      if($line) {
        $this->{Md5er} = "md5";
        $this->{Md5Match} = '\s(\S+)$';
      } else {
        $this->{Md5er} = "md5.pl";
        $this->{Md5Match} = '^(\S+)$';
      }
    }
    return $this;
  }
  sub Analyzer{
    my($this, $file) = @_;
    return "$this->{DicomAnalyzerProgram} \"$file\"";
  }
  sub QueueFile{
    my($this, $file, $prio, $notifier) = @_;
    unless(-f $file){
      my $traceback = $this->TraceBack;
      die "Non existent file ($file) queued\n$traceback";
    }
    my @foo = stat $file;
    my $m_time = $foo[9];
    my $size = $foo[7];
    if(
      exists($this->{ManagedFiles}->{by_file}->{$file}) &&
      $this->{ManagedFiles}->{by_file}->{$file}->{size} == $size &&
      $this->{ManagedFiles}->{by_file}->{$file}->{m_time} == $m_time
    ) {
      $this->{ManagedFiles}->{by_file}->{$file}->{access_ts} = time;
      return 0;
    }
    if(
      exists($this->{ManagedFiles}->{by_file}->{$file})
    ){
      my $info = $this->{ManagedFiles}->{by_file}->{$file};
      $info->{HasBeenModified} = 1;
      $info->{old_m_time} = $this->{m_time};
      $info->{old_size} = $this->{size};
      $info->{m_time} = $m_time;
      $info->{size} = $size;
      print STDERR "File $file has changed!!!!!!!!\n" .
        "\tm_time: $info->{old_m_time} => $info->{m_time}\n" .
        "\tsize: $info->{old_size} => $info->{size}\n";
    }
    $this->Activate;
    if(exists $this->{MD5Queue}->{$file}){
      # This is a race - file has been queued again before MD5 completed
      unless(
        $this->{MD5Queue}->{$file}->{m_time} == $m_time &&
        $this->{MD5Queue}->{$file}->{size} == $size
      ){
        # Its a deadly race if the file has changed!
        die "poorly behaved user - file changing while processing";
      }
      if($prio < $this->{MD5Queue}->{$file}->{prio}){
        # but you might just be upping the prio...
        $this->{MD5Queue}->{$file}->{prio} = $prio;
      }
    } else {
      $this->{MD5Queue}->{$file} = {
        file => $file,
        m_time => $m_time,
        size => $size,
        prio => $prio,
      };
    }
    if($notifier){
      $this->AddNotifier($file, $notifier);
    }
    $this->CrankQueues;
  }
  sub AddNotifier{
    my($this, $file, $notifier) = @_;
    unless(exists $this->{Notifiers}->{$file}){
      $this->{Notifiers}->{$file} = [];
    }
    push(@{$this->{Notifiers}->{$file}}, $notifier);
  }
  sub NotifyFile{
    my($this, $file) = @_;
    unless(exists $this->{Notifiers}->{$file}){ return }
    my $notifiers = $this->{Notifiers}->{$file};
    delete $this->{Notifiers}->{$file};
    unless(ref($notifiers) eq "ARRAY") {return}
    while(my $not = shift @$notifiers){
       if(ref($not) eq "CODE") {
         Dispatch::Select::Background->new($not)->queue;
       }
#      &$not()
    }
  }
  sub Activate{
    my($this) = @_;
    unless($this->{IsActive}) {
      $this->{IsActive} = 1;
      $this->NotifyEvent("Activated");
    }
  }
  sub DeActivate{
    my($this) = @_;
    if($this->{IsActive}) {
      $this->{IsActive} = 0;
      $this->NotifyEvent("DeActivated");
    }
  }
  sub CrankQueues{
    my($this) = @_;
    while(
      $this->{SubProcesses} < $this->{MaxAnalysisProcs} &&
      ($this->Md5Remaining || $this->AnalysisRemaining)
    ){
      my @md5_files = sort 
        {$this->{MD5Queue}->{$a}->{prio} <=> $this->{MD5Queue}->{$b}->{prio}}
        keys %{$this->{MD5Queue}};
      my $num_md5s = scalar @md5_files;
      if($num_md5s > 0){
        my $file = shift @md5_files;
        my $info = $this->{MD5Queue}->{$file};
        delete $this->{MD5Queue}->{$file};
        if(exists $this->{MD5Handler}->{$file}){
          # race condition - file queued while being md5ed
          my $old_info = $this->{MD5Handler}->{$file};
          unless(
            $old_info->{m_time} == $info->{m_time} &&
            $old_info->{size} == $info->{size}
          ){
            # deadly race
            die "file $file changed while being md5'ed";
          }
          if($info->{prio} < $old_info->{prio}){
            $old_info->{prio} = $info->{prio};
          }
        } else {
          my $md5h = $this->MD5Line($file);
          my $md5e = $this->CreateNotifierClosure("MD5Finished", $file);
          my $reader = Dispatch::LineReader->new_cmd(
            "$this->{Md5er} \"$file\"",
            $md5h, $md5e);
          $this->{SubProcesses} += 1;
          $this->{MD5Handler}->{$file} = $info
        }
        next;
      }
      my @analyze_files = sort 
        {
          $this->{AnalyzeQueue}->{$a}->{prio} <=> 
          $this->{AnalyzeQueue}->{$b}->{prio}
        }
        keys %{$this->{AnalyzeQueue}};
      if($#analyze_files >= 0){
        my $file = shift @analyze_files;
        my $info = $this->{AnalyzeQueue}->{$file};
        delete $this->{AnalyzeQueue}->{$file};
        if(exists $this->{ManagedFiles}->{by_digest}->{$info->{digest}}){
          # already seen file with same digest...
          # add it to list of files with this digest
          $this->{ManagedFiles}->{by_digest}
            ->{$info->{digest}}->{Files}->{$file} = 1;
          # we should notify this file - its already been parsed
          $this->NotifyFile($info->{file});
          # and add this file to the "by_file" bucket
          unless(exists $this->{ManagedFiles}->{by_file}->{$file}){
            $this->{ManagedFiles}->{by_file}->{$file} = {
               access_ts => time,
               digest => $info->{digest},
               m_time => $info->{m_time},
               size => $info->{size}
            };
          }
        } else {
          my $fh = $this->GetCachedFileInfoHandle($info->{digest});
          $info->{InCache} = 1;
          unless($fh){
            $info->{InCache} = 0;
            open $fh, "-|", $this->Analyzer($file);
          }
          $this->{SubProcesses} += 1;
          Dispatch::Select::Socket->new($this->ReadAnalysis(
            $info), $fh)->Add("reader");
        }
      }
    }
    unless(
      $this->{SubProcesses} > 0 ||
      $this->Md5Remaining ||
      $this->AnalysisRemaining
     ){
      $this->DeActivate;
    }
    my $md5_remaining = $this->Md5Remaining;
    my $analysis_remaining = $this->AnalysisRemaining;
    my $sub_processes = $this->{SubProcesses};
  }
  sub ReadAnalysis{
    my($this, $info) = @_;
    my $sub = sub {
      my($disp, $socket) = @_;
      my $analysis;
      eval{
        $analysis = fd_retrieve($socket);
      };
      if($@){
        print STDERR "DICOM Analyzer process aborted ($info->{file}).\n" .
          "\tError $@\n";
      } else {
        $this->HandleAnalysis($analysis, $info);
      }
      $disp->Remove;
      $this->NotifyFile($info->{file});
      $this->{SubProcesses} -= 1;
      $this->CrankQueues;
    };
  }
  sub HandleAnalysis{
    my($this, $analysis, $info) = @_;
    my $file = $info->{file};
    my $digest = $info->{digest};
    unless(defined $analysis) { return }
    unless($analysis->{digest} eq $digest){
      die "DICOM Analyzer Race: returned digest (" .
        "$analysis->{digest}) doesn't match that requested(" .
        "$digest) for $info->{file}";
    }
    unless($info->{InCache}){
      $this->CacheAnalysis($analysis, $info);
    }
    if(
      exists($this->{ManagedFiles}->{by_file}->{$file}) &&
      $this->{ManagedFiles}->{by_file}-{$file}->{digest} ne $digest
    ){
      my $old_digest = $this->{ManagedFiles}->{by_file}->{$file}->{digest};
      print STDERR "File $file changed:\n" .
        "\told_digest: $old_digest\n" .
        "\tnew_digest: $digest\n";
      delete $this->{ManagedFiles}->{by_digest}->{$old_digest}->{Files}
        ->{$file};
    }
    $this->{ManagedFiles}->{by_file}->{$file} = {
      digest => $digest,
      m_time => $info->{m_time},
      size => $info->{size},
      access_ts => time,
    };
    if($analysis->{TypeOfResult} eq "DicomAnalysis"){
      $this->HandleDicomAnalysis($analysis, $info);
    } else {
      $this->HandleNonDicomAnalysis($analysis, $info);
    }
  }
  sub HandleDicomAnalysis{
    my($this, $analysis, $info) = @_;
### todo - move the meta-header info from the dataset digest
###        to the digest (careful: the same code handles analysis and cache)
###        needs to go into cache, but not memory
###    This is used in NewItcTools::DicomImageDisplayer
    my $digest = $info->{digest};
    my $file = $info->{file};
    delete $analysis->{file};
    delete $analysis->{digest};
    my $ds_dig = $analysis->{dataset_digest};
    my $ds_offset = $analysis->{dataset_start_offset};
    if(exists $this->{ManagedFiles}->{by_digest}->{$digest}){
      $this->{ManagedFiles}->{by_digest}->{$digest}->{Files}->{$file} = 1;
    } else {
      $this->{ManagedFiles}->{by_digest}->{$digest} = {
        Files => { $file => 1 },
        type => "Dicom",
        dataset_digest => $ds_dig,
        dataset_start_offset => $analysis->{dataset_start_offset},
        xfr_stx => $analysis->{xfr_stx},
      };
      delete $analysis->{xfr_stx};
      delete $analysis->{dataset_start_offset};
    }
    if(exists $analysis->{pix_pos}){
      $analysis->{ds_pix_offset} = $analysis->{pix_pos} - $ds_offset;
      delete $analysis->{pix_pos};
    }
    if(exists $analysis->{gfov_pos}){
      $analysis->{ds_gfov_offset} = $analysis->{gfov_pos} - $ds_offset;
      delete $analysis->{gfov_pos};
    }
    if(exists $analysis->{dvhs}){
      for my $dvh (@{$analysis->{dvhs}}){
        if(exists($dvh->{file_len}) && exists($dvh->{file_pos})){
          $dvh->{ds_len} = $dvh->{file_len};
          $dvh->{ds_offset} = $dvh->{file_pos} - $ds_offset;
          delete $dvh->{file_len};
          delete $dvh->{file_pos};
        }
      }
#      $this->{ManagedFiles}->{by_digest}->{$digest}->{dvhs_pos} = 
#        $analysis->{dvhs_pos};
#      delete $analysis->{dvhs_pos};
    }
    if(defined $ds_dig){
      if(exists $this->{ManagedFiles}->{by_dataset_digest}->{$ds_dig}){
        $this->{ManagedFiles}->{by_dataset_digest}->{$ds_dig}->{digests}
          ->{$digest} = 1;
      } else {
        $analysis->{digests}->{$digest} = 1;
        $this->{ManagedFiles}->{by_dataset_digest}->{$ds_dig} = $analysis;
      }
    } else {
      $this->{ManagedFiles}->{by_digest}->{$digest}->{type} = 
        "Dicom with no DS";
      $this->{ManagedFiles}->{by_digest}->{$digest}->{analysis} = $analysis;
    }
    if(defined $analysis->{sop_inst_uid}){
      my $si = $analysis->{sop_inst_uid};
      unless(defined $this->{ManagedFiles}->{by_sop_instance}){
        $this->{ManagedFiles}->{by_sop_instance} = {};
      }
      my $h = $this->{ManagedFiles}->{by_sop_instance};
      $h->{$si}->{digests}->{$digest} = 1;
      $h->{$si}->{dataset_digests}->{$ds_dig} = 1;
    }
  }
  sub HandleNonDicomAnalysis{
    my($this, $analysis, $info) = @_;
    my $digest = $info->{digest};
    my $file = $info->{file};
    if(exists $this->{ManagedFiles}->{by_digest}->{$digest}){
      $this->{ManagedFiles}->{by_digest}->{$digest}->{Files}->{$file} = 1;
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
  sub MD5Line{
    my($this, $file) = @_;
    my $sub = sub {
      my($line) = @_;
      if($line =~ /$this->{Md5Match}/){
        $this->{MD5Handler}->{$file}->{digest} = $1;
      }
    };
    return $sub;
  }
  sub MD5Finished{
    my($this, $file) = @_;
    unless($this->{MD5Handler}->{$file}) {
      die "Completing $file not processing"
    }
    $this->{SubProcesses} -= 1;
    my $info = $this->{MD5Handler}->{$file};
    delete $this->{MD5Handler}->{$file};
    unless($info->{digest}) {
      ####  The following code is supposed
      ####  to resolve a race condition if
      ####  a file on the MD5 queue is deleted.
      ####  Not quite sure how to test it...
      unless(-f $file) {  # file deleted
        $this->NotifyFile($file);
        return;
      }
      die "No digest at completion for $info->{file}";
    }
#    delete $info->{prio};
    if(exists $this->{ManagedFiles}->{by_digest}->{$info->{digest}}){
      $this->{ManagedFiles}->{by_digest}->{$info->{digest}}
        ->{Files}->{$info->{file}} = 1;
      $info->{access_ts} = time;
      $this->{ManagedFiles}->{by_file}->{$info->{file}} = $info;
      $this->NotifyFile($file);
    } else {
      if(
        exists($this->{AnalyzeQueue}->{$file})&&
        ref($this->{AnalyzeQueue}->{$file}) eq "HASH" &&
        defined($this->{AnalyzeQueue}->{$file}->{file})
      ){
        # race condition - queued and MD5'd while waiting for analysis
        my $old_info = $this->{AnalyzeQueue}->{$file};
        unless(
          $info->{digest} eq $old_info->{digest} &&
          $info->{m_time} eq $old_info->{m_time} &&
          $info->{size} eq $old_info->{size}
        ){
          die "deadly race - file $file changed before analysis";
        }
        if($info->{prio} < $old_info->{prio}){
          # maybe just upping priority...
          $old_info->{prio} = $info->{prio};
        }
      } else {
        $this->{AnalyzeQueue}->{$file} = $info;
      }
    } 
    return $this->CrankQueues;
  }
  sub Md5Remaining{
    my($this) = @_;
    return scalar keys %{$this->{MD5Queue}};
  }
  sub AnalysisRemaining{
    my($this) = @_;
    return scalar keys %{$this->{AnalyzeQueue}};
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
    my($this, $analysis, $info) = @_;
    my $digest = $info->{digest};
    my($one, $two) = $digest =~/^(.)(.)/;
    my $dir = "$this->{DicomInfoDir}/$one/$two";
    my $random = int rand(100000);
    my $wfn = "$dir/${random}_$digest";
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
    print STDERR "GarbageCollect called\n";
    my $start = time;
    my $changed = 0;
    my $files_deleted = 0;
    my $digests_deleted = 0;
    my $datasets_deleted = 0;
    my $sops_deleted = 0;
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
        $digests_deleted += 1;
      }
    }
    for my $file (keys %{$this->{ManagedFiles}->{by_file}}){
      unless(-f $file){
        $changed = 1;
        delete $this->{ManagedFiles}->{by_file}->{$file};
        $files_deleted += 1;
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
      my $num_digs = scalar keys %{$item->{digests}};
      if($num_digs == 0){
        $changed = 1;
        delete $this->{ManagedFiles}->{by_dataset_digest}->{$ds};
        $datasets_deleted += 1;
      }
    }
    for my $sop (keys %{$this->{ManagedFiles}->{by_sop_instance}}){
      my $item = $this->{ManagedFiles}->{by_sop_instance}->{$sop};
      for my $dig (keys %{$item->{digests}}){
        unless(exists $this->{ManagedFiles}->{by_digest}->{$dig}){
          $changed = 1;
          delete $item->{digests}->{$dig};
        }
      }
      unless(scalar(keys %{$item->{digests}}) > 0){
        delete $this->{ManagedFiles}->{by_sop_instance}->{$sop};
        $sops_deleted += 1;
      }
    }
    return $changed;
  }

  ##########################################################
  #  Performance Enhancers here
  #    QueueWithDigestEtc when you have a file which you have
  #      either already done an fstat and calculated digest, or
  #      have confidence that it hasn't changed (e.g. it has same 
  #      path, size and m_time as file in BOM).  Just check for
  #      digest and possibly DICOM analyze or read cache.
  #    IsKnownFile tells you that the file doesn't need to have
  #      its MD5 recalculated (it has the same date/time and size
  #      as a file with the same full path)
  #    LinkKnownFile creates a hard link and updates tables (since
  #      you already known MD5, etc) if the file being linked is
  #      already a known file
  #    FileDigest is used in cases where you need the file digest and
  #      you are sure the file hasn't changed. 
  #
  sub QueueFileWithDigestEtc{
    my($this, $file, $digest, $size, $m_time, $prio, $notifier) = @_;
    my $analysis_item = {
      file => $file,
      digest => $digest,
      size => $size,
      m_time => $m_time,
      prio => $prio,
    };
    if(
      exists($this->{ManagedFiles}->{by_digest}->{$digest}) &&
      exists($this->{ManagedFiles}->{by_file}->{$file})  &&
      $this->{ManagedFiles}->{by_file}->{$file}->{digest} eq $digest
    ){ 
      $this->{ManagedFiles}->{by_digest}->{$digest}->{Files}
        ->{$analysis_item->{file}} = 1;
      return 0;
    }
    if($notifier && ref($notifier) eq "CODE"){
      push(@{$this->{Notifiers}->{$file}}, $notifier);
    }
    $this->{AnalyzeQueue}->{$file} = $analysis_item;
    $this->Activate;
    $this->CrankQueues;
    return 1;
  }
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
    unless(defined $file){
      my $traceback = $this->TraceBack;
      print STDERR "FileDigest called for undef file:$traceback\n";
      return undef;
    }
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
  #  my($offset, $length) = $fm->PixelDataInfo($file_name);
  #  my($file_name, $offset, $length) = $fm->PixelInfoByDigest($digest);
  #  my($file_name, $offset, $length) = $fm->PixelInfoByDsDigest($ds_digest);
  sub PixelDataInfo{
    my($this, $fn) = @_;
    my $info = $this->DicomInfo($fn);
    unless($info) { return undef }
    my $ds_pix_offset = $info->{ds_pix_offset};
    my $pixel_length = $info->{pixel_length};
    my $digest = $this->{ManagedFiles}->{by_file}->{$fn}->{digest};
    my $ds_offset = $this->{ManagedFiles}->{by_digest}
      ->{$digest}->{dataset_start_offset};
    return ($ds_offset + $ds_pix_offset, $pixel_length);
  }
  sub PixelInfoByDigest{
    my($this, $dig) = @_;
    my @files = keys %{$this->{ManagedFiles}->{by_digest}->{$dig}->{Files}};
    for my $fn(@files){
      if(-f $fn){
        my($offset, $length) = $this->PixelDataInfo($fn);
        return ($fn, $offset, $length);
      }
    }
    return undef;
  }
  sub PixelInfoByDsDigest{
    my($this, $ds_dig) = @_;
    my @digests = keys %{$this->{ManagedFiles}
      ->{by_dataset_digest}->{$ds_dig}->{digests}};
    for my $dig (@digests){
      my($file, $offset, $length) = $this->PixelInfoByDigest($dig);
      if(defined $file){
        return ($file, $offset, $length);
      }
    }
    return undef;
  }
  sub GetDsOffset{
    my($this, $file) = @_;
    unless(exists $this->{ManagedFiles}->{by_file}->{$file}){
      print STDERR "GetDsOffset request for unmanaged file: $file\n";
      return 0;
    }
    my $dig = $this->{ManagedFiles}->{by_file}->{$file}->{digest};
    unless(exists $this->{ManagedFiles}->{by_digest}->{$dig}){
      print STDERR "GetDsOffset request for managed file: $file" .
        " has unknown digest ($dig)\n";
      return 0;
    }
    unless(
      exists
        $this->{ManagedFiles}->{by_digest}->{$dig}->{dataset_start_offset}
    ){
      print STDERR "ManagedFile ($dig) has no dataset_start_offset\n";
      return 0;
    }
    return
      $this->{ManagedFiles}->{by_digest}->{$dig}->{dataset_start_offset}
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
}
1;
