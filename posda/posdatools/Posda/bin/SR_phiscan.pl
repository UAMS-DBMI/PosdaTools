#!/usr/bin/perl -w
#
#Copyright 2008, Bill Bennett
# Part of the Posda package
# Posda may be copied only under the terms of either the Artistic License or the
# GNU General Public License, which may be found in the Posda Distribution,
# or at http://posda.com/License.html
#
use strict;
use Cwd;
use Posda::SrSemanticParse;
use Posda::DB 'Query';
use Posda::BackgroundProcess;

my $usage = <<EOF;
SR_phiscan.pl <bkgrnd_id> <activity_id> <notify>
or
SR_phiscan.pl -h

EOF
$| = 1;
if($#ARGV == 0 && $ARGV[0] eq "-h"){
  print "$usage\n";
  exit;
}
unless($#ARGV == 2){
  die "$usage\n";
}
my ($invoc_id, $act_id, $notify) = @ARGV;

print "All processing in background\n";
my $background = Posda::BackgroundProcess->new($invoc_id, $notify, $act_id);
$background->Daemonize;

my $ActTpId;
my %Files;
my $mySeriesId;
my %Paths;
my $seriesId;
my $filepath;
my $file_id;
my $q = Query('SeriesForFile');
my $q2 = Query('FilesInSeriesWithPath');

$background->WriteToEmail("Starting SR PHI scan: \n");
sub GetPaths{
  my($content) = @_;
  for my $i (@{$content}){
    if(exists $i->{value}){

      $Paths{$i->{semantic_path}}->{$i->{value}} = 1;
    } elsif(exists $i->{image_ref}){
      $Paths{$i->{semantic_path}}->{$i->{image_ref}} = 1;
    } else {
      $Paths{$i->{semantic_path}}->{"<none>"} = 1;
    }
    if(exists $i->{content}){
      GetPaths($i->{content});
    }
  }
}

my $create_scan = PosdaDB::Queries->GetQueryInstance("SRCreateScanInstance");
my $create_path = PosdaDB::Queries->GetQueryInstance("SRCreatePathSeen");
my $get_value = PosdaDB::Queries->GetQueryInstance("GetSimpleValueSeen");
my $create_value = PosdaDB::Queries->GetQueryInstance("CreateSimpleValueSeen");
my $get_path = PosdaDB::Queries->GetQueryInstance("SRGetPathSeen");
my $get_value_id=
  PosdaDB::Queries->GetQueryInstance("GetSimpleValueSeenId");
my $create_occurance =
  PosdaDB::Queries->GetQueryInstance("SRCreatePathValueOccurance");



Query('LatestActivityTimepointsForActivity')->RunQuery(sub{
  my($row) = @_;
  my($activity_id, $activity_created,
    $activity_description, $activity_timepoint_id,
    $timepoint_created, $comment, $creating_user) = @$row;
  $ActTpId = $activity_timepoint_id;
}, sub {}, $act_id);
$background->SetActivityStatus("Found timepoint ($ActTpId) for " .  "activity: $act_id");
Query('FileIdsByActivityTimepointId')->RunQuery(sub {
  my($row) = @_;
  $Files{$row->[0]} = 1;
}, sub {}, $ActTpId);

my $scan_id;
$create_scan->RunQuery(sub {
    my($row) = @_;
    $scan_id = $row->[0];
  }, sub{}, $act_id);

  $background->WriteToEmail("Scan ($scan_id)\n");
  $background->WriteToEmail("Creating SR PHI Report report\n");

for  $file_id(keys %Files){

    # get the series ID
    $q->RunQuery(sub {
      my($row) = @_;
      $seriesId = $row->[0];}
    , sub {}, $file_id);
    # get the filepaths
    $q2->RunQuery(sub {
      my($row) = @_;
      $filepath = $row->[0];}
    , sub {}, $seriesId);

    #get the Unique Simplified SR Paths and Values
    my $infile = $filepath;

    my $max_len1 = $ARGV[1];
    my $max_len2 = $ARGV[2];
    unless(defined $max_len1) {$max_len1 = 64}
    unless(defined $max_len2) {$max_len2 = 300}

    Posda::Dataset::InitDD();
    my $dd = $Posda::Dataset::DD;

    my $ParsedSR = Posda::SrSemanticParse->new($infile);

    my $content = $ParsedSR->{content};
    GetPaths $content;
    # for my $path(sort keys %Paths){
    #   for my $v (sort keys %{$Paths{$path}}){
    #     #print "$path|$v\n";
    #     #if($path =~ /^(.*) \(.*\)$/){ $path = $1 }
    #     $path =~ s/\s\([^)]+\)//g;
    #     $v =~ s/\s\([^)]+\)//g;
    #     print "$path|$v\n";
    #   }
    # }

    #while(my $line = <SUBP>){

    #loop through the path value pairs
    for my $path(sort keys %Paths){
      my $pathS = $path;
      $pathS =~ s/\s\([^)]+\)//g;
      my $path_id;

      #for every path, see if it is a new unique path
      $get_path->RunQuery(sub {
        my($row) = @_;
        $path_id = $row->[0];
      }, sub {}, $pathS);
      unless(defined $path_id){
        #if so store it
        $create_path->RunQuery(sub {
          my($row) = @_;
          $path_id = $row->[0];
        }, sub {},
          $pathS);
      }
      for my $v (sort keys %{$Paths{$path}}){

        #for every value, see if it is a new unique value
        my $value_id;
        my $vS = $v;
        $vS =~ s/\s\([^)]+\)//g;

        $get_value->RunQuery(sub {
          my($row) = @_;
          $value_id = $row->[0];
        }, sub {}, $vS);
        #if so store it
        unless(defined $value_id){
          $create_value->RunQuery(sub {}, sub {},
            $vS);
          $get_value_id->RunQuery(sub {
            my($row) = @_;
            $value_id = $row->[0];
          }, sub {} );
        }

        #associate this path and value
        $create_occurance->RunQuery(sub {}, sub {},
          $path_id, $value_id, $seriesId, $scan_id)
      }
    }
    my $rpt3 = $background->CreateReport("Edit Skeleton");
    $rpt3->print("path,q_value,edit_description," .
      "p_op,q_arg1,q_arg2,Operation,activity_id,scan_id,notify,sep_char\r\n");
    $rpt3->print(",,,,,,,,,ProposeEditsTp,$act_id,$scan_id,$notify,\"%\"\r\n");
    $background->PrepareBackgroundReportBasedOnQuery("CreateSRReport", "SR PHI Report", %Paths.length, $scan_id);
    $background->Finish;
  };
