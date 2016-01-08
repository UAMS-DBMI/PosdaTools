#!/usr/bin/perl -w
#$Date: 2015/09/09 17:26:36 $
#$Revision: 1.2 $
use strict;
use Dispatch::Select;
use Dispatch::EventHandler;
use Digest::MD5;
$| = 1;
my $called = $ARGV[0];
my $calling = $ARGV[1];
my $assoc_dir = $ARGV[2];
my $cache_dir = $ARGV[3];
my $dest_dir = $ARGV[4];
my $info_file = "$assoc_dir/Session.info";
print STDERR "Called: $called\n";
print STDERR "Calling: $calling\n";
print STDERR "assoc_dir: $assoc_dir\n";
print STDERR "cache_dir: $cache_dir\n";
print STDERR "dest_dir: $dest_dir\n";
print STDERR "info_file: $info_file\n";
open FILE, "<$info_file" or die "Can't open $info_file ($!)";
my @FilesToAnalyze;
while (my $line = <FILE>){
  chomp $line;
  my @fields = split(/\|/, $line);
  if($fields[0] eq "file"){
    my $sop_class = $fields[1];
    my $sop_inst = $fields[2];
    my $xfer_stx = $fields[3];
    my $file = $fields[4];
    push(@FilesToAnalyze, {
      sop_class => $sop_class,
      sop_inst => $sop_inst,
      xfer_stx => $xfer_stx,
      file_name => $file,
    });
  }
}
{
  package Analyzer;
  my $max_in_process = 5;
  use vars qw( @ISA );
  @ISA = ( "Dispatch::EventHandler" );
  sub new{
    my($class) = @_;
    my $this = {
      start_time => time,
      FilesBeingAnalyzed => {},
      FilesAnalyzed => {},
      Status => "Starting",
      Elapsed => 0,
      InProcess => 1,
    };
    bless($this, $class);
    $this->{Analyzer} = (-x "/usr/bin/speedy") ?
      "SpeedyDicomInfoAnalyzer.pl" : "DicomInfoAnalyzer.pl";
    $this->StartProcessing;
    Dispatch::Select::Background->new($this->StatusReporter)->queue;
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
        $disp->timer(5);
        # and do it again in 5 seconds
      }
      #otherwise, stop (we're done).
    };
    return $sub;
  }
  sub ReportStatus{
    my($this) = @_;
    my $to_analyze_and_move = @FilesToAnalyze;
    my $in_process = keys %{$this->{FilesBeingAnalyzed}};
    my $processed = keys %{$this->{FilesAnalyzed}};
    my $elapsed = time - $this->{start_time};
    print "Status=$this->{Status}&queued=$to_analyze_and_move&" .
      "being_processed=$in_process&processed=$processed" .
      "&elapsed=$elapsed\n";
  }
  sub StartProcessing{
    my($this) = @_;
    my $queued = @FilesToAnalyze;
    my $in_process = keys %{$this->{FilesBeingAnalyzed}};
    while($queued > 0 && $in_process < $max_in_process){
      $this->{Status} = "Processing";
      $this->StartNextFile;
      $queued = @FilesToAnalyze;
      $in_process = keys %{$this->{FilesBeingAnalyzed}};
    }
    if($queued == 0 && $in_process == 0){
      return $this->Finished;
    }
    $this->{Status} = "Waiting";
  }
  sub StartNextFile{
    my($this) = @_;
    my $next_file = shift @FilesToAnalyze;
    my $ctx = Digest::MD5->new;
    open my $foo, "<$next_file->{file_name}" or 
      die "can't open $next_file->{file_name} for digest";
    $ctx->addfile($foo);
    close $foo;
    my $dig = $ctx->hexdigest;
    unless($dig =~ /^(.)(.).*/){
      die "BadDigest";
    }
    my $first_dir = "$cache_dir/$1";
    my $second_dir = "$cache_dir/$1/$2";
    unless(-d $first_dir) {
      unless(mkdir $first_dir) { die "Can't mkdir $first_dir ($!)" }
    }
    unless(-d $second_dir) {
      unless(mkdir $second_dir) { die "Can't mkdir $second_dir ($!)" }
    }
    my $cache_file = "$second_dir/$dig.dcminfo";
    if(-f $cache_file){
      my $analysis = Storable::retrieve $cache_file;
      my $pat_id = $analysis->{patient_id};
      $this->LinkAnalyzedFile(
        $next_file, $dest_dir, $called, $calling, $pat_id, $dig);
#      $this->InvokeAfterDelay("StartProcessing", 0);
    } else {
      my $Analyzer = (-x "/usr/bin/speedy") ?
        "SpeedyDicomInfoAnalyzer.pl" : "DicomInfoAnalyzer.pl";
      $this->{FilesBeingAnalyzed}->{$next_file->{file_name}} = $next_file;
       open my $fh, "$Analyzer \"$next_file->{file_name}\"|"
          or die "Can't open Analyzer ($!)";
        Dispatch::Select::Socket->new(
          $this->WhenAnalysisReady(
            $next_file, $dest_dir, $called, $calling, $dig),
            $fh)->Add("reader");
    }
 }
 sub LinkAnalyzedFile{
    my($this, $next_file, $dest_dir, $called, $calling, $pat_id, $dig) = @_;
    my $destination_dir = "$dest_dir/$called/$calling/$pat_id";
    unless(-e "$dest_dir/$called"){
      unless(mkdir "$dest_dir/$called"){ 
        die "Can't mkdir $dest_dir/$called";
      }
    }
    unless(-e "$dest_dir/$called/$calling"){
      unless(mkdir "$dest_dir/$called/$calling"){ 
        die "Can't mkdir $dest_dir/$called/$calling";
      }
    }
    unless(-e "$dest_dir/$called/$calling"){
      unless(mkdir "$dest_dir/$called/$calling"){ 
        die "Can't mkdir $dest_dir/$called/$calling";
      }
    }
    unless(-e "$dest_dir/$called/$calling/$pat_id"){
      unless(mkdir "$dest_dir/$called/$calling/$pat_id"){ 
        die "Can't mkdir $dest_dir/$called/$calling/$pat_id";
      }
    }
    unless(-f "$dest_dir/$called/$calling/$pat_id/$dig.dcm"){
      unless(
        link $next_file->{file_name}, 
          "$dest_dir/$called/$calling/$pat_id/$dig.dcm"
      ){
        die "Can't link $next_file->{file_name}, " .
          "$dest_dir/$called/$calling/$pat_id" .
          "/$dig.dcm ($!)";
      }
    }
  }
  sub WhenAnalysisReady{
    my($this, $next_file, $dest_dir, $called, $calling, $dig) = @_;
    my $sub = sub {
      my($disp, $sock) = @_;
      my $analysis = Storable::fd_retrieve($sock);
      my $pat_id = $analysis->{patient_id};
      $this->LinkAnalyzedFile(
        $next_file, $dest_dir, $called, $calling, $pat_id, $dig);
      $this->InvokeAfterDelay("StartProcessing", 0);
      $disp->Remove;
      $this->{FilesAnalyzed}->{$next_file->{file_name}} = $next_file;
      delete $this->{FilesBeingAnalyzed}->{$next_file->{file_name}};
      unless($dig =~ /^(.)(.).*/){
        die "BadDigest";
      }
      my $first_dir = "$cache_dir/$1";
      my $second_dir = "$cache_dir/$1/$2";
      unless(-d $first_dir) {
        unless(mkdir $first_dir) { die "Can't mkdir $first_dir ($!)" }
      }
      unless(-d $second_dir) {
        unless(mkdir $second_dir) { die "Can't mkdir $second_dir ($!)" }
      }
      my $cache_file = "$second_dir/$dig.dcminfo";
      unless(-f $cache_file) {
        Storable::store $analysis, $cache_file;
      }
    };
    return $sub;
  }
  sub Finished{
    my($this) = @_;
    $this->{Status} = "OK";
    $this->ReportStatus;
    $this->{InProcess} = 0;
    $this->{Finished} = 1;
  }
}
sub MakeAnalyzer{
  my $sub = sub {
    my($disp) = @_;
    Analyzer->new;
  };
  return $sub;
}
{
  Dispatch::Select::Background->new(MakeAnalyzer)->queue;
}
Dispatch::Select::Dispatch;
