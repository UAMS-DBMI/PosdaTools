#!/usr/bin/perl -w
use strict;
use Posda::DB 'Query';
use Posda::Try;
use Encode;

my $usage = <<EOF;
EOF

my $q = Query('GetFilesWithNoStudyInfoByCollection');
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
  Study($try->{dataset}, $file_id, $hist, $errors);
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
sub Study{
  my($ds, $file_id, $hist, $errors) = @_;
  my $study_parms = {
    study_instance_uid => "(0020,000d)",
    study_date => "(0008,0020)",
    study_time => "(0008,0030)",
    referring_phy_name => "(0008,0090)",
    study_id => "(0020,0010)",
    accession_number => "(0008,0050)",
    study_description => "(0008,1030)",
    phys_of_record => "(0008,1048)",
    phys_reading => "(0008,1060)",
    admitting_diag => "(0008,1080)",
  };
  my $ModList = {
    study_date => "Date",
    study_time => "Timetag",
    referring_phy_name => "International",
    study_description => "International",
    phys_of_record => "InternationalMultiText",
    phys_reading => "InternationalMultiText",
    admitting_diag => "InternationalMultiText",
  };
  my $parms = GetAttrs($ds, $study_parms, $ModList, $errors);
  my $ins_study = Query('ImportIntoFileStudy');
  return $ins_study->RunQuery(sub{}, sub{},
    $file_id,
    $parms->{study_instance_uid},
    $parms->{study_date},
    $parms->{study_time},
    $parms->{referring_phy_name},
    $parms->{study_id},
    $parms->{accession_number},
    $parms->{study_description},
    $parms->{phys_of_record},
    $parms->{phys_reading},
    $parms->{admitting_diag},
  );
}


