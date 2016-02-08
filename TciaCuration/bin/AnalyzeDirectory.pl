#!/usr/bin/perl -w
#
use strict;
use Storable qw( store_fd );
use PipeChildren;
use Dispatch::Select;
use Dispatch::EventHandler;
use Dispatch::LineReader;
use Posda::FileCollectionAnalysis;
use Posda::FileInfoManager;
use Digest::MD5;
use Cwd;
use Debug;
my $dbg = sub {print STDERR @_};
$| = 1;

use vars qw( $FileManager $Dir $C_Dir $A_Dir $InfoFile $BuildInfoFile $Start );
my $usage =
    "Usage:\n" .
    "AnalyzeDirectory.pl <Dir> <C_dir> <A_Dir>";
unless($#ARGV == 2){
  print STDERR $usage;
  print "Error: must have 3 args\n";
  exit;
}
$Start = time;
$Dir = $ARGV[0];
$C_Dir = $ARGV[1];
$A_Dir = $ARGV[2];
my $pwd = cwd;
unless($Dir =~ /^\//) { $Dir = "$pwd/$Dir" }
unless($C_Dir =~ /^\//) { $C_Dir = "$pwd/$C_Dir" }
unless($A_Dir =~ /^\//) { $A_Dir = "$pwd/$A_Dir" }
unless(-d $Dir) { 
  print STDERR $usage;
  print "Error: Directory to Analyze ($Dir) doesn't exist\n";
  exit;
}
unless(-d $C_Dir) { 
  print STDERR $usage;
  print "Error: Cache Directory ($C_Dir) doesn't exist\n";
  exit;
}
unless(-d $A_Dir) { 
  print STDERR $usage;
  print "Error: Results Directory($A_Dir) doesn't exist\n";
  exit;
}
my $ctx = Digest::MD5->new;
$ctx->add($Dir);
my $dig = $ctx->hexdigest;
$InfoFile = "$A_Dir/$dig.info";
$BuildInfoFile = "$A_Dir/.$dig.info";
if(-f $InfoFile || -f $BuildInfoFile){
  print STDERR "Info file $InfoFile (or $BuildInfoFile) already exists\n";
  print "Error: Info file $InfoFile (or $BuildInfoFile) already exists\n";
  exit;
}
{
  package AnalysisEngine;
  use vars qw( @ISA );
  @ISA = ( "Dispatch::EventHandler" );
  sub new{
    my($class) = @_;
    my $this = {};
    bless $this, $class;
    $this->StartProcessing;
    return $this;
  }
  sub StartProcessing{
    my($this) = @_;
    $this->{num_found_files} = 0;
    $this->{found_files} = [];
    $this->{WaitingOnFileManager} = {};
    $this->{ProcessedFiles} = {};
    $this->{FileCollectionAnalysis} = Posda::FileCollectionAnalysis->new;
    $this->{Finder} = 
      Dispatch::LineReader->new_cmd("find \"$main::Dir\"",
         $this->FindLine, $this->EndFind);
    $this->{FileProcessor} = Dispatch::Select::Background->new(
      $this->FileProcessor);
    Dispatch::Select::Background->new($this->PrintProcessingStatus)->timer(2);
  }
  sub FindLine{
    my($this) = @_;
    my $sub = sub {
      my($line) = @_;
      chomp $line;
      unless(-f $line) { return };
      if(@{$this->{found_files}} > 300){
        $this->{Finder}->pause;
      }
      push(@{$this->{found_files}}, $line);
      $this->{num_found_files} += 1;
      $this->KickFileProcessor;
    };
    return $sub;
  }
  sub EndFind{
    my($this) = @_;
    my $sub = sub {
      delete $this->{Finder};
      $this->KickFileProcessor;
    };
    return $sub;
  }
  sub KickFileProcessor{
    my($this) = @_;
    if(defined $this->{FileProcessor}) {
      unless($this->{FileProcessorQueued}){
        $this->{FileProcessorQueued} = 1;
        $this->{FileProcessor}->queue;
      }
    }
  }
  sub FileProcessor{
    my($this) = @_;
    my $sub = sub{
      my($disp) = @_;
      delete $this->{FileProcessorQueued};
      my $in_queue = @{$this->{found_files}};
      my $num_waiting = keys %{$this->{WaitingOnFileManager}};
      if($num_waiting >= 50) { return }
      if(
        $in_queue == 0 && $num_waiting == 0 &&
        !exists($this->{Finder})
      ){
        return $this->DirectoryProcessingDone;
      }
      if($in_queue > 0){
        my $file = shift(@{$this->{found_files}});
        if($main::FileManager->QueueFile($file, 1, $this->FileProcessed($file))){
          $this->{WaitingOnFileManager}->{$file} = 1;
        } else {
          my $info = $main::FileManager->DicomInfo($file);
          if(defined $info) {
            $this->{FileCollectionAnalysis}->Analyze($file, $info);
          }
        }
        $this->KickFileProcessor;
      }
    };
    return $sub;
  }
  sub FileProcessed{
    my($this, $file) = @_;
    my $sub = sub {
      if(
        exists($this->{Finder}) && 
        $this->{Finder}->paused &&
        @{$this->{found_files}} < 100
      ){
        $this->{Finder}->resume;
      }
      my $info = $main::FileManager->DicomInfo($file);
      if(defined $info){
        $this->{FileCollectionAnalysis}->Analyze($file, $info);
      }
      $this->{ProcessedFiles}->{$file} = 1;
      delete $this->{WaitingOnFileManager}->{$file};
      $this->KickFileProcessor;
    };
    return $sub;
  }
  sub DirectoryProcessingDone{
    my($this) = @_;
    delete $this->{FileProcessor};
    my $dir_data = {
      dir => $main::Dir,
      prepared_at => time,
      files => {},
    };
    for my $i (keys %{$this->{ProcessedFiles}}){
      $dir_data->{files}->{$i} = 
        $main::FileManager->{ManagedFiles}->{by_file}->{$i};
    }
    $this->{FileCollectionAnalysis}->ConsistencyErrors;
    $dir_data->{FileCollectionAnalysis} = $this->{FileCollectionAnalysis};
    if(-f $main::InfoFile || -f $main::BuildInfoFile){
      print STDERR "Info file $main::InfoFile (or $main::BuildInfoFile) " .
        "already exists\n";
      print "Error: Info file $main::InfoFile (or $main::BuildInfoFile) " .
        "already exists\n";
      exit;
    }
    open my $fh, ">$main::BuildInfoFile" 
      or die "Can't open $main::BuildInfoFile";
    Storable::store_fd $dir_data, $fh;
    close $fh;
    unless(link $main::BuildInfoFile, $main::InfoFile) {
      print STDERR "Couldn't link $main::InfoFile to $main::BuildInfoFile\n";
      print "Error: Couldn't link $main::InfoFile to $main::BuildInfoFile\n";
      exit;
    }
    unless(unlink($main::BuildInfoFile) == 1){
      print STDERR "Couldn't link $main::InfoFile to $main::BuildInfoFile\n";
      print "Error: Couldn't link $main::InfoFile to $main::BuildInfoFile\n";
      exit;
    }
    $this->{Completed} = "OK";
    $this->StatusPrinter;
    $this->{StopUpdatingStatus} = 1;
  }
  sub PrintProcessingStatus{
    my($this) = @_;
    my $sub = sub {
      my($disp) = @_;
      if(exists $this->{StopUpdatingStatus}) { return }
      $this->StatusPrinter;
      $disp->timer(2);
    };
    return $sub;
  }
  sub StatusPrinter{
    my($this) = @_;
    my $elapsed = time - $main::Start;
    my @stati;
    if(exists $this->{Finder}){ push @stati, "Finder=running" }
    if(exists($this->{Completed})){ 
      push @stati, "Completion=$this->{Completed}";
    }
    push @stati, "total_found=$this->{num_found_files}";
    my $in_queue = @{$this->{found_files}};
    my $in_process = keys %{$this->{WaitingOnFileManager}};
    my $processed = keys %{$this->{ProcessedFiles}};
    push @stati, "in_queue=$in_queue";
    push @stati, "in_process=$in_process";
    push @stati, "processed=$processed";
    push @stati, "elapsed=$elapsed";
    print "Status: ";
    for my $i (0 .. $#stati){
      my $s = $stati[$i];
      print "$s";
      unless($i == $#stati) { print "&" }
    }
    print "\n";
  }
}
sub MakeStarter{
  my $start = sub {
    my($bk) = @_;
      $FileManager = Posda::FileInfoManager->new(
        ( -x "/usr/bin/speedy" ) ?
          "SpeedyDicomInfoAnalyzer.pl" : "DicomInfoAnalyzer.pl",
        "/mnt/erlbluearc/projects/bbennett/test/cache",
        10
      );
      AnalysisEngine->new;
    };
  return $start;
}
{
  Dispatch::Select::Background->new(MakeStarter())->queue;
}
Dispatch::Select::Dispatch();
