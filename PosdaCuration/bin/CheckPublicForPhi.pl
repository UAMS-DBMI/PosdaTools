#!/usr/bin/perl -w
#$Source: /home/bbennett/pass/archive/PosdaCuration/bin/CheckPublicForPhi.pl,v $
#$Date: 2016/01/26 19:48:19 $
#$Revision: 1.1 $
#
use strict;
use Storable qw( store_fd );
use PipeChildren;
use Dispatch::Select;
use Dispatch::EventHandler;
use Dispatch::LineReader;
use Posda::FileCollectionAnalysis;
use Posda::FileInfoManager;
use Posda::Dataset;
use Digest::MD5;
use Cwd;
use Debug;
my $dbg = sub {print STDERR @_};
$| = 1;

use vars qw( $Dir $A_Dir $InfoFile 
  $BuildInfoFile $Start %Results );
my $usage =
    "Usage:\n" .
    "PhiSearch.pl <Dir> <A_Dir>";
unless($#ARGV == 1){
  print STDERR $usage;
  print "Error: must have 2 args\n";
  exit;
}
$Start = time;
$Dir = $ARGV[0];
$A_Dir = $ARGV[1];
my $pwd = cwd;
unless($Dir =~ /^\//) { $Dir = "$pwd/$Dir" }
unless($A_Dir =~ /^\//) { $A_Dir = "$pwd/$A_Dir" }
unless(-d $Dir) { 
  print STDERR $usage;
  print "Error: Directory to Analyze ($Dir) doesn't exist\n";
  exit;
}
unless(-d $A_Dir) { 
  print STDERR $usage;
  print "Error: Results Directory($A_Dir) doesn't exist\n";
  exit;
}
#my $ctx = Digest::MD5->new;
#$ctx->add($Dir);
#my $dig = $ctx->hexdigest;
$InfoFile = "$A_Dir/PhiCheck.info";
$BuildInfoFile = "$A_Dir/.PhiCheck.info";
if(-f $InfoFile || -f $BuildInfoFile){
  print STDERR "Info file $InfoFile (or $BuildInfoFile) already exists\n";
  print "Error: Info file $InfoFile (or $BuildInfoFile) already exists\n";
  exit;
}
{
  package PhiSearchEngine;
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
    $this->{WaitingFindUniqueValues} = {};
    $this->{ProcessedFiles} = {};
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
      my $num_waiting = keys %{$this->{FilesBeingSearched}};
      if($num_waiting >= 10) { return }
      if(
        $in_queue == 0 && $num_waiting == 0 &&
        !exists($this->{Finder})
      ){
        return $this->DirectoryProcessingDone;
      }
      if($in_queue > 0){
        my $file = shift(@{$this->{found_files}});
        $this->{FilesBeingSearched}->{$file} = 1;
        Dispatch::LineReader->new_cmd("FindUniqueWords.pl \"$file\"",
          $this->HandleLine($file),
          $this->FileProcessed($file)
        );
        $this->KickFileProcessor;
      }
    };
    return $sub;
  }
  sub HandleLine{
    my($this, $file) = @_;
    my $sub = sub {
      my $line = shift;
      chomp $line;
      my ($word, $tag, $vr) = split (/\|/, $line);
      unless($vr =~ /^[A-Z][A-Z]$/){
        print STDERR  "FindUniqueWords.pl $file";
      }
#      if($vr eq "DS") { return }
#      if($vr eq "IS") { return }
      my ($pat, $indices) = Posda::Dataset->MakeMatchPat($tag);
#      if(defined($indices) && ref($indices) eq "ARRAY" && $#{$indices} >= 0){
#        unless( defined $main::Results{$vr}->{$word}->{$pat}->{$file}){
#          $main::Results{$vr}->{$word}->{$pat}->{$file} = [];
#        }
#        push(
#          @{$main::Results{$vr}->{$word}->{$pat}->{$file}}, $indices);
#      } else {
        $main::Results{$vr}->{$word}->{$pat}->{$file} = 1;
#      }
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
      $this->{ProcessedFiles}->{$file} = 1;
      delete $this->{FilesBeingSearched}->{$file};
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
      results => \%main::Results,
    };
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
    my $in_process = keys %{$this->{FilesBeingSearched}};
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
      PhiSearchEngine->new;
    };
  return $start;
}
{
  Dispatch::Select::Background->new(MakeStarter())->queue;
}
Dispatch::Select::Dispatch();
