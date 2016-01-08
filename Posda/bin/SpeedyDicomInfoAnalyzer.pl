#!/usr/bin/speedy -w -- -t4
#$Source: /home/bbennett/pass/archive/Posda/bin/SpeedyDicomInfoAnalyzer.pl,v $
#$Date: 2013/06/28 12:56:33 $
#$Revision: 1.3 $
#
use strict;
use Posda::Try;
use Posda::SimplerDicomAnalysis;
use VectorMath;
use Storable qw( store_fd );
use vars qw( $file $try $analysis );

$file = $ARGV[0];
$try = Posda::Try->new($file, 1000);
unless(exists $try->{dataset}) {
  my $result = {
    TypeOfResult => "NotADicomFile",
    digest => $try->{digest},
    Reason => "Didn't parse as Dicom",
    file => $file,
    parse_errors => $try->{parse_errors},
  };
  store_fd($result, \*STDOUT);
  exit;
}
if(exists $try->{meta_header}){
  my $sop_class = $try->{meta_header}->{metaheader}->{"(0002,0002)"};
  if($sop_class eq "1.2.840.10008.1.3.10"){
    my $result = {
      TypeOfResult => "DicomDir",
      digest => $try->{digest},
      Reason => "metaheader and SOP Class = 1.2.840.10008.1.3.10",
      file => $file,
      parse_errors => $try->{parse_errors},
      meta_header => $try->{meta_header},
      dataset => $try->{dataset},
    };
    store_fd($result, \*STDOUT);
    exit;
  }
} else {
  my $sop_class = $try->{dataset}->Get("(0008,0016)");
  unless(defined $sop_class){
    my $result = {
      TypeOfResult => "NotADicomFile",
      digest => $try->{digest},
      Reason => "No metaheader or SOP Class",
      file => $file,
      parse_errors => $try->{parse_errors},
    };
    store_fd($result, \*STDOUT);
    exit;
  }
}
$analysis = Posda::SimplerDicomAnalysis::Analyze($try, $file);
$analysis->{file} = $file;
$analysis->{parse_errors} = $try->{parser_warnings},
$analysis->{xfr_stx} = $try->{xfr_stx};
$analysis->{digest} = $try->{digest};
$analysis->{dataset_digest} = $try->{dataset_digest};
$analysis->{TypeOfResult} = "DicomAnalysis";
$analysis->{dataset_start_offset} = $try->{dataset_start_offset};
if($try->{has_meta_header}){
  $analysis->{has_meta_header} = 1;
  $analysis->{meta_header} = $try->{meta_header};
}
store_fd($analysis, \*STDOUT);
close STDOUT;
$file = undef;
$try = undef;
$analysis = undef;
exit 0;

