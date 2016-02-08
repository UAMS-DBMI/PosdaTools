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

use vars qw( $FileManager $DB $Collection $Site $RootDir $Dir $C_Dir $A_Dir 
  $InfoFile $BuildInfoFile $Start $Subj );
my $usage =
    "Usage:\n" .
    "ExtractAndAnalyzeFromDb.pl <db> <collection> <site> <subj> " .
    "<R_dir> <C_dir> <A_dir>\n";
unless($#ARGV == 6){
  print STDERR $usage;
  print "Error: must have 7 args\n";
  exit;
}
$Start = time;
$DB = $ARGV[0];
$Collection = $ARGV[1];
$Site = $ARGV[2];
$Subj = $ARGV[3];
$RootDir = $ARGV[4];
$Dir = "$RootDir/$Collection/$Site/$Subj";
$C_Dir = $ARGV[5];
$A_Dir = $ARGV[6];
my $pwd = cwd;
unless($Dir =~ /^\//) { $Dir = "$pwd/$Dir" }
unless($C_Dir =~ /^\//) { $C_Dir = "$pwd/$C_Dir" }
unless($A_Dir =~ /^\//) { $A_Dir = "$pwd/$A_Dir" }
unless(-d $RootDir) { 
  print STDERR $usage;
  print "Error: Extraction Root ($RootDir) doesn't exist\n";
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
if(-d $Dir) {
  print STDERR $usage;
  print "Error: Extraction Directory($Dir) already exists\n";
  exit;
}
unless(-d "$RootDir/$Collection"){
  unless((mkdir "$RootDir/$Collection") == 1){
    my $message = "Can't mkdir $RootDir/$Collection ($!)\n";
    print STDERR $message;
    print "Error: $message\n";
    exit;
  }
}
unless(-d "$RootDir/$Collection/$Site"){
  unless((mkdir "$RootDir/$Collection/$Site") == 1){
    my $message = "Can't mkdir $RootDir/$Collection/$Site ($!)\n";
    print STDERR $message;
    print "Error: $message\n";
    exit;
  }
}
unless(-d "$Dir"){
  unless((mkdir "$Dir") == 1){
    my $message = "Can't mkdir $Dir ($!)\n";
    print STDERR $message;
    print "Error: $message\n";
    exit;
  }
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
  package ExtractionEngine;;
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
    $this->{Status} = "QueryInProgress";
    $this->{Studies} = {};
    $this->{QueryReader} = Dispatch::LineReader->new_cmd(
      "ExtractAllCollectionSubj.pl $main::DB \"$main::Collection\" " .
      "\"$main::Site\" \"$main::Subj\"",
      $this->QueryLine,
      $this->EndQuery
    );
    Dispatch::Select::Background->new($this->PrintProcessingStatus)->timer(2);
  }
  sub QueryLine{
    my($this) = @_;
    my $sub = sub {
      my($line) = @_;
      my($modality, $series_pk, $series_uid, $series_desc, $visibility,
        $study_pk, $study_uid, $study_desc, $body_part, $file, $md5, $ts,
        $sz, $image_pk_id, $pid, $sop_inst) =
        split(/\|/, $line);
      $this->{QueryResults}->{studies}->{$study_pk}->{uid} = $study_uid;
      $this->{QueryResults}->{studies}->{$study_pk}->{pid} = $pid;
      my $studies = $this->{QueryResults}->{studies};
      $studies->{$study_pk}->{desc} = $study_desc;
      $studies->{$study_pk}->{series}->{$series_pk}->{uid} = $series_uid;
      my $series = $studies->{$study_pk}->{series}->{$series_pk};
      $series->{body_part} = $body_part;
      $series->{modality} = $modality;
      $series->{desc} = $series_desc;
      $series->{files}->{$image_pk_id} = {
        file => $file,
        visibility => $visibility,
        md5 => $md5,
        curation_timestamp => $ts,
        file_size => $sz,
        sop_instance_uid => $sop_inst,
      };
    };
    return $sub;
  }
  sub EndQuery{
    my($this) = @_;
    my $sub = sub {
      delete $this->{QueryReader};
      $this->{Status} = "ExtractionInProgress";
      $this->StartExtraction;
    };
    return $sub;
  }
  sub StartExtraction{
    my($this) = @_;
    $this->{ExtractList} = [];
    $this->{SelectingDirectory} = $main::Dir;
    for my $s (keys %{$this->{QueryResults}->{studies}}){
      for my $e (keys %{$this->{QueryResults}->{studies}->{$s}->{series}}){
        my $series = $this->{QueryResults}->{studies}->{$s}->{series}->{$e};
        for my $i (keys %{$series->{files}}){
          my $file = $series->{files}->{$i};
          my $to_file = $file->{file};
          my $from_file = "$main::Dir/" .
            "$series->{modality}_$file->{sop_instance_uid}.dcm";
          push @{$this->{ExtractList}}, {
            target => $to_file,
            linked_file => $from_file,
          };
        }
      }
    }
    Dispatch::Select::Background->new($this->ExtractDirectory)->queue;
  }
  sub ExtractDirectory{
    my($this) = @_;
    my $sub = sub {
      my($disp) = @_;
      my $file = shift @{$this->{ExtractList}};
      unless(defined $file) { return $this->ExtractionComplete }
      unless(symlink $file->{target}, $file->{linked_file}){
        die "Unable to link $file->{linked_file} to $file->{target} ($!)";
        return;
      }
      $disp->queue;
    };
    return $sub;
  }
  sub ExtractionComplete{
    my($this) = @_;
    $this->{Status} = "AnalysisInProgress";
    $this->DoAnalysis;
  }
  sub DoAnalysis{
    my($this) = @_;
    $this->{AnalysisErrors} = [];
    $this->{AnalysisReader} = Dispatch::LineReader->new_cmd(
      "AnalyzeDirectory.pl \"$main::Dir\" \"$main::C_Dir\" \"$main::A_Dir\"",
      $this->AnalysisLine,
      $this->EndAnalysis
    );
  }
  sub AnalysisLine{
    my($this) = @_;
    my $sub = sub {
      my($line) = @_;
      chomp $line;
      if($line =~ /^Status: (.*)$/){
        $this->{AnalysisStatus} = $1;
      } elsif($line =~ /^Error: (.*)$/){
        push(@{$this->{AnalysisErrors}}, $1);
      } else {
        push(@{$this->{AnalysisErrors}}, "Unrecognizable Line: $line");
      }
    };
    return $sub;
  }
  sub EndAnalysis{
    my($this) = @_;
    my $sub = sub {
      delete $this->{AnalysisReader};
      $this->{Status} = "AnalysisComplete";
      $this->StatusPrinter;
      $this->{StopUpdatingStatus} = 1; 
    };
    return $sub;
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
    if($this->{Status} eq "AnalysisComplete"){
      push(@stati, "state=AnalysisComplete");
      if(exists $this->{AnalysisStatus}){
        push @stati, $this->{AnalysisStatus};
      }
    }elsif($this->{Status} eq "AnalysisInProgress"){
      push(@stati, "state=AnalysisInProgress");
      if(exists $this->{AnalysisStatus}){
        push @stati, $this->{AnalysisStatus};
      }
    } elsif($this->{Status} eq "QueryInProgress"){
      push(@stati, "state=QueryInProgress");
    } elsif($this->{Status} eq "ExtractionInProgress"){
      push(@stati, "state=ExtractionInProgress");
    } else {
      push(@stati, "state=Unknown");
    }
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
      ExtractionEngine->new;
    };
  return $start;
}
{
  Dispatch::Select::Background->new(MakeStarter())->queue;
}
Dispatch::Select::Dispatch();
