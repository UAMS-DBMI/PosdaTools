#!/usr/bin/perl -w
use strict;
use Posda::DB 'Query';
use Posda::Try;
use Encode;

my $usage = <<EOF;
EOF

my $q = Query('GetFilesWithNoSeriesInfoByCollection');
my $collection = $ARGV[0];
my @files;
$q->RunQuery(sub{
  my($row) = @_;
  push(@files, $row);
}, sub {}, $collection);

file:
for my $i (@files){
  my $file_id = $i->[0];
  my $path = $i->[1];
  my $try = Posda::Try->new($path);
  unless(exists $try->{dataset}) {
    print "File $path didn't parse\n";
    next file;
  }
  my $hist = {};
  my $errors = [];
  Series($try->{dataset}, $file_id, $hist, $errors);
  if($#{$errors} >= 0){
    print STDERR "Errors for file_id ($file_id):\n";
    for my $e (@$errors){
      print "\t$e\n";
    }
  }
}

sub GetAttrs{
  my($ds, $parms, $mod, $errors) = @_;
  my %ret;
  for my $key (keys %$parms){
    my $value = $ds->ExtractElementBySig($parms->{$key});
    if(exists $mod->{$key}){
      my $dispatch = {
        Date => sub {
          my($text, $id) = @_;
          unless(defined $text) { return undef };
          if($text eq "<undef> ") { return undef };
          if(
            $text &&
            $text =~ /^(....)(..)(..)$/
          ){
            my $y = $1; my $m = $2; my $d = $3;
            if($y eq "    "){
              push(@$errors, "Bad date \"$text\" in $id");
              return undef;
            }
            if($y eq "????"){
              push(@$errors, "Bad date \"$text\" in $id");
              return undef;
            }
            if($m =~ /^ (\d)$/){
              $m = "0".$1;
            }
            if($d =~ /^ (\d)$/){
              $d = "0".$1;
            }
            unless($y >0 && $m > 0 && $m < 13 && $d > 0 && $d < 32 ){
              push(@$errors, "Bad date \"$text\" in $id");
              return undef;
            }
            $text = sprintf("%04d/%02d/%02d", $y, $m, $d);
            return $text;
          } else {
            push(@$errors, "Bad date \"$text\" in $id");
            return undef;
          }
        },
        Timetag => sub {
          my($time, $id) = @_;
          unless(defined $time) { return undef };
          if(
            $time &&
            $time =~ /^(\d\d)(\d\d)(\d\d)$/
          ){
            $time = "$1:$2:$3";
            return $time;
          } elsif (
            $time &&
            $time =~ /^(\d\d)(\d\d)(\d\d)\.(\d+)$/
          ){
            $time = "$1:$2:$3.$4";
            return $time;
          } else {
            push(@$errors, "Bad time \"$time\" in $id");
            return undef;
          }
        },
        MultiText => sub {
          my($text, $id) = @_;
          if(ref($text) eq "ARRAY"){
            $text = join("\\", @$text);
          }
          return $text;
        },
        InternationalMultiText => sub {
          my($text, $id) = @_;
          if(ref($text) eq "ARRAY"){
            $text = join("\\", @$text);
          }
          return $text;
        },
        UndefIfNotNumber => sub {
          my($text, $id) = @_;
          unless(defined $text){ return undef }
          unless($text =~ /^\s*[+-]?[0-9]+\s*$/){
            push(@$errors, "Bad number \"$text\" in $id");
            return undef;
          }
          return $text;
        },
        Integer => sub {
          my($text, $id) = @_;
          unless(defined $text) { return undef }
          my $int = int($text);
          unless($int == $text){
            push @$errors, "Error making $text an integer\n";
          }
          return $int;
        },
        International => sub {
          my($text, $id) = @_;
          unless(defined $text) { return undef }
          return encode('utf8', $text);
        },
      };
      if(exists $dispatch->{$mod->{$key}}){
         $value = &{$dispatch->{$mod->{$key}}}($value, $key);
      }
    }
    $ret{$key} = $value;
  }
  return \%ret;
}
sub Series{
  my($ds, $file_id, $hist, $errors) = @_;
  my $series_parms = {
    modality => "(0008,0060)",
    series_instance_uid => "(0020,000e)",
    series_number => "(0020,0011)",
    laterality => "(0020,0060)",
    series_date => "(0008,0021)",
    series_time => "(0008,0031)",
    performing_phys => "(0008,1050)",
    protocol_name => "(0018,1030)",
    series_description => "(0008,103e)",
    operators_name => "(0008,1070)",
    body_part_examined => "(0018,0015)",
    patient_position => "(0018,5100)",
    smallest_pixel_value => "(0028,0108)",
    largest_pixel_value => "(0028,0109)",
    performed_procedure_step_id => "(0040,0253)",
    performed_procedure_start_date => "(0040,0244)",
    performed_procedure_start_time => "(0040,0245)",
    performed_procedure_desc => "(0040,0254)",
    performed_procedure_comments => "(0040,0280)",
  };
  my $ModList = {
    series_number => "UndefIfNotNumber",
    series_date => "Date",
    series_time => "Timetag",
    performing_phys => "InternationalMultiText",
    operators_name => "InternationalMultiText",
    smallest_pixel_value => "UndefIfNotNumber",
    largest_pixel_value => "UndefIfNotNumber",
    performed_procedure_start_date => "Date",
    performed_procedure_start_time => "Timetag",
    series_description => "International",
    performed_procedure_desc => "International",
    performed_procedure_comments => "International",
  };
  my $parms = GetAttrs($ds, $series_parms, $ModList, $errors);
  my $ins_series = Query('ImportIntoFileSeries');
  unless(defined($parms->{series_instance_uid})){
    push(@$errors, "Series instance UID undefined");
    return;
  }
  return $ins_series->RunQuery(sub {}, sub {},
    $file_id,
    $parms->{modality},
    $parms->{series_instance_uid},
    $parms->{series_number},
    $parms->{laterality},
    $parms->{series_date},
    $parms->{series_time},
    $parms->{performing_phys},
    $parms->{protocol_name},
    $parms->{series_description},
    $parms->{operators_name},
    $parms->{body_part_examined},
    $parms->{patient_position},
    $parms->{smallest_pixel_value},
    $parms->{largest_pixel_value},
    $parms->{performed_procedure_step_id},
    $parms->{performed_procedure_start_date},
    $parms->{performed_procedure_start_time},
    $parms->{performed_procedure_desc},
    $parms->{performed_procedure_comments},
  );
}

