#!/usr/bin/perl -w
use strict;
use Posda::DB::PosdaFilesQueries;
use Posda::Dataset;
use Dispatch::EventHandler;
use Dispatch::LineReader;
my $usage = <<EOF;
PhiSimpleSeriesScan.pl  <series_instance_uid> <query_name>
  series_instance_uid  - series_instance_uid
  query_name           - name of query for files in series


The query must have one parameter (series_instance_uid)
and must return a list of files.
Queries which fill the bill:
  FilesInSeries
  IntakeFilesInSeries
  PublicFilesInSeries
This script contains the horrible kludge for Public and Intake
mapping the file path which is invoked by the name of the
query matching either Intake or public.
EOF
unless($#ARGV == 1){ die $usage }
my($series_inst, $search_files) = @ARGV;
my @FilesToScan;
my $get_files = PosdaDB::Queries->GetQueryInstance($search_files);
my $trans = sub { return $_[0] };
if($search_files =~ /Intake/){
  $trans = sub {
    my($path) = @_;
    if($path =~ /^(\/mnt)\/sdd1\/(.*)$/){
      my $root = $1;
      my $rel = $2;
      my $mapped = "$root/intake1-data/$rel";
      unless(-f $mapped) {
        print STDERR "not found: $mapped\n";
        return undef;
      }
      return $mapped;
    } else {
      print STDERR "bad file $path";
      return undef;
    }
  };
} elsif($search_files =~ /Public/){
  $trans = sub {
    my($path) = @_;
    if($path =~ /^\/usr\/local\/apps\/ncia\/CTP-server\/CTP\/(.*)$/){
      my $rel = $1;
      my $mapped = "/mnt/public-nfs/$rel";
      unless(-f $mapped) {
        print STDERR "not found: $mapped\n";
        return undef;
      }
      return $mapped;
    } else {
      # this is likely a path from the new NBIA DICOM Submit API,
      # which means no mapping is necessary.
      return $path;
    }
  };
}
$get_files->RunQuery(sub {
  my($row) = @_;
  my $file = $row->[0];
  my $path = &$trans($file);
  push @FilesToScan, $path;
#  print "File: $file\n";
}, sub {}, $series_inst);
#######################################

{
  package PhiSearchEngine;
  use vars qw( @ISA );
  @ISA = ( "Dispatch::EventHandler" );
  sub new{
    my($class, $list) = @_;
    my $this = {
      file_list => $list,
    };
    bless $this, $class;
    $this->StartProcessing;
    return $this;
  }
  sub StartProcessing{
    my($this) = @_;
    delete $this->{request_pending};
    my $num_files_waiting = @{$this->{file_list}};
    my $num_files_in_process = keys %{$this->{in_process}};
    while($num_files_waiting > 0 && $num_files_in_process < 10){
      my $next = shift @{$this->{file_list}};
      $this->{in_process}->{$next} = 1;
      Dispatch::LineReader->new_cmd("FindUniqueWords.pl \"$next\"",
        $this->HandleLine($next),
        $this->FileComplete($next)
      );
      $num_files_waiting = @{$this->{file_list}};
      $num_files_in_process = keys %{$this->{in_process}};
    }
    if($num_files_waiting == 0 && $num_files_in_process == 0){
      $this->StopProcessing;
    }
  }
  sub HandleLine{
    my($this, $file) = @_;
    my $sub = sub {
      my $line = shift;
      chomp $line;
      my ($word, $tag, $vr) = split (/\|/, $line);
      my ($pat, $indices) = Posda::Dataset->MakeMatchPat($tag);
      $this->{Results}->{$vr}->{$word}->{$pat} = 1;
    };
    return $sub;
  }
  sub FileComplete{
    my($this, $file) = @_;
    my $sub = sub {
      delete $this->{in_process}->{$file};
      if(exists($this->{request_pending})) { return }
      $this->{request_pending} = 1;
      $this->InvokeAfterDelay("StartProcessing", 0);
    };
    return $sub;
  }
  sub StopProcessing{
    my($this) = @_;
    for my $vr (keys %{$this->{Results}}){
      my $res = $this->{Results}->{$vr};
      for my $word (keys %$res){
        my $res1 = $res->{$word};
        for my $pat (keys %$res1){
          print "$pat|$vr|$word\n";
        }
      }
    }
  }
}
sub MakeStarter{
  my $start = sub {
    my($bk) = @_;
      PhiSearchEngine->new(\@FilesToScan);
    };
  return $start;
}
{
  Dispatch::Select::Background->new(MakeStarter())->queue;
}
Dispatch::Select::Dispatch();
