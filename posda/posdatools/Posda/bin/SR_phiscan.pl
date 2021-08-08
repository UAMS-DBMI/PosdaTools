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

my $act_id = $ARGV[0];

my $usage = "Usage: $0 <$act_id>";
unless ($#ARGV >= 0) {die $usage;}



my $ActTpId;
my %Files;
my $mySeriesId;
my %Paths;
my $seriesId;
my $filepath;
my $file_id;
my $q = Query('SeriesForFile');
my $q2 = Query('FilesInSeriesWithPath');






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
#$background->SetActivityStatus("Found timepoint ($ActTpId) for " .  "activity: $act_id");
Query('FileIdsByActivityTimepointId')->RunQuery(sub {
  my($row) = @_;
  $Files{$row->[0]} = 1;
}, sub {}, $ActTpId);

my $scan_id;
$create_scan->RunQuery(sub {
    my($row) = @_;
    $scan_id = $row->[0];
  }, sub{}, $act_id);



for  $file_id(keys %Files){


    $q->RunQuery(sub {
      my($row) = @_;
      $seriesId = $row->[0];}
    , sub {}, $file_id);
    $q2->RunQuery(sub {
      my($row) = @_;
      $filepath = $row->[0];}
    , sub {}, $seriesId);

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
    for my $path(sort keys %Paths){
      my $tag_id;
      my $path_id;
      my $vr;

      $get_path->RunQuery(sub {
        my($row) = @_;
        $path_id = $row->[0];
      }, sub {}, $path, $vr);
      unless(defined $path_id){
        $create_path->RunQuery(sub {
          my($row) = @_;
          $path_id = $row->[0];
        }, sub {},
          $path, $vr);
      }
      my $value_id;
      my $v = $Paths{$path};
      $get_value->RunQuery(sub {
        my($row) = @_;
        $value_id = $row->[0];
      }, sub {}, $v);
      unless(defined $value_id){
        $create_value->RunQuery(sub {}, sub {},
          $v);
        $get_value_id->RunQuery(sub {
          my($row) = @_;
          $value_id = $row->[0];
        }, sub {} );
      }
      $create_occurance->RunQuery(sub {}, sub {},
        $path_id, $value_id, $seriesId, $scan_id)
    }
  };
