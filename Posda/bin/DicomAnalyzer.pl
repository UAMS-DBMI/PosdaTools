#!/usr/bin/perl -w
#$Source: /home/bbennett/pass/archive/Posda/bin/DicomAnalyzer.pl,v $
#$Date: 2013/04/01 19:55:05 $
#$Revision: 1.1 $
#
use strict;
use Posda::Try;
use Posda::SimpleDicomAnalysis;
use VectorMath;
use Storable qw( store_fd );
# use PersistentPerl;
use vars qw( $file $contour_dir $dvh_dir $try $analysis );

# sub cleanup {
#   $file = undef;
#   $contour_dir = undef;
#   $try = undef;
#   $analysis = undef;
# }

# my $pp = PersistentPerl->new;
# $pp->register_cleanup(\&cleanup);

$file = $ARGV[0];
$contour_dir = $ARGV[1];
$dvh_dir = $ARGV[2];
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
$analysis = Posda::SimpleDicomAnalysis::Analyze($try, $file);
if(defined $contour_dir && -d $contour_dir && -w $contour_dir){
  my $command = "ExtractContours.pl \"$file\" $contour_dir";
  open my $fh, "$command|";
  while(my $line = <$fh>){
    chomp $line;
    my($ct_sop, $roi_num, $ffn) = split(/\|/, $line);
    unless(exists $analysis->{structs_by_ct}->{$ct_sop}->{$roi_num}){
      $analysis->{structs_by_ct}->{$ct_sop}->{$roi_num} = [];
    }
    push(@{$analysis->{structs_by_ct}->{$ct_sop}->{$roi_num}}, $ffn);
  }
} else {
  if(defined $contour_dir){
    push(@{$analysis->{errors}}, "Couldn't extract contours into \"$contour_dir\"" .
     " doesn't exist or not writable");
  }
}
#Posda::SimpleDicomAnalysis::ExtraAnalysis($analysis, $try);
$analysis->{file} = $file;
$analysis->{parse_errors} = $try->{parse_errors},
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
if ($analysis->{modality} eq "RTDOSE" &&
    $#{$analysis->{dvhs}} >= 0){
  my $cmd = "DvhExtractor.pl";
  $analysis->{DvhDir} = $dvh_dir;
#  print STDERR 
#    "DicomAnalyzer: Starting DvhExtractor.pl for file: $file.\n";
  unless (open CMD, "|$cmd") {
    print STDERR "DicomAnalyzer: Error $! starting cmd: $cmd.\n";
    exit 1;
  }
  store_fd($analysis, \*CMD);
  close CMD;
  # shutdown($child, 1);
}
$file = undef;
$contour_dir = undef;
$dvh_dir = undef;
$try = undef;
$analysis = undef;
# if (defined $child_pid)
#   { waitpid $child_pid, 0; }
# $child_pid = undef;
exit 0;
