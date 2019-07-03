#!/usr/bin/perl -w
use Posda::DB 'Query', 'GetHandle';
my $operation_names = [
    "CreateActivityTimepointFromImportName",
    "CreateActivityTimepointFromCollectionSite",
    "VisualReviewFromTimepoint",
    "PhiReviewFromTimepoint",
    "ConsistencyFromTimePoint",
    "LinkRtFromTimepoint",
    "CheckStructLinkagesTp",
    "PhiPublicScanTp",
    "SummarizeStructLinkage",
    "BackgroundDciodvfyTp",
    "CondensedActivityTimepointReport",
    "AnalyzeSeriesDuplicates",
    "FilesInTpNotInPublic",
    "CompareSopsInTpToPublic",
    "AnalyzeSeriesDuplicatesForTimepoint",
    "CompareSopsTpPosdaPublic",
    "BackgroundPrivateDispositionsTp",
    "BackgroundPrivateDispositionsTpBaseline",
    "CompareSopsTpPosdaPublicLike",
    "UpdateActivityTimepoint",
    "InitialAnonymizerCommandsTp",
];
my $q = Query("GetSpreadsheetOperationByName");
for my $n (@$operation_names){
  $q->RunQuery(sub {
    my($row) = @_;
    my $operation_name = $row->[0];
    my $command_line = $row->[1];
    my $operation_type = $row->[2];
    my $input_line_format = $row->[3];
    my $tags = $row->[4];
    my $can_chain = $row->[5];
    print "    $operation_name => {\n";
    print "      command_line => '$command_line',\n";
    print "      operation_type => '$operation_type',\n";
    if(defined $input_line_format){
      print "      input_line_format => '$input_line_format',\n";
    } else {
      print "      input_line_format => undef,\n";
    }
    if(defined $tags && ref($tags) eq "ARRAY"){
      print "      tags => [\n";
      for my $i (0 .. $#{$tags}){
        my $tag = $tags->[$i];
        print "        \"$tag\"";
        unless($i == $#{$tags}){print ","}
        print "\n";
      }
      print "      ],\n";
    } else {
      print "      tags => undef\n";
    }
    if(defined $can_chain){
      print "      can_chain => '$can_chain'\n";
    } else {
      print "      can_chain => undef\n";
    }
    print "    },\n";
  }, sub {}, $n);
}
