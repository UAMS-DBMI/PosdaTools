#!/usr/bin/perl -w
use strict;
use Posda::Try;
my $usage = <<EOF;
Dump4dEnhancedMrFields.pl [-c]

  -c specifes that the dumps are to be sorted by Concatenation Frame Offset Number

expects a list of files on STDIN

Reads all of the files specified on STDIN and dumps the following fields:
  ["(0008,0018)", "(UI, 1)", "SOP Instance UID"],
  ["(0020,9162)", "(US, 1)", "In-concatenation Number"],
  ["(0020,9228)", "(UL, 1)", "Concatenation Frame Offset Number"],
  ["(5200,9230)[0](0020,9111)[0](0018,9074)", "(DT, 1)", "Frame Acquisition DateTime"],
  ["(5200,9230)[0](0020,9111)[0](0020,9057)", "(UL, 1)", "In-Stack Position Number"],
  ["(5200,9230)[0](0020,9111)[0](0020,9128)", "(UL, 1)", "Temporal Position Index"],
  ["(5200,9230)[0](0020,9111)[0](0020,9157)", "(UL, 3)", "Dimension Index Values"],
  ["(5200,9230)[0](0020,9113)[0](0020,0032)", "(DS, 3)", "Image Position (Patient)"],
  ["(5200,9230)[0](2005,"Philips MR Imaging DD 005",0f)[0](0008,0018)", "(UI, 1)", "SOP Instance UID"],
  ["(5200,9230)[0](2005,"Philips MR Imaging DD 005",0f)[0](0008,0033)", "(TM, 1)", "Content Time"],
  ["(5200,9230)[0](2005,"Philips MR Imaging DD 005",0f)[0](0020,0013)", "(IS, 1)", "Instance Number"],
  ["(5200,9230)[0](2005,"Philips MR Imaging DD 005",0f)[0](0020,0032)", "(DS, 3)", "Image Position (Patient)"],
  ["(5200,9230)[0](2005,"Philips MR Imaging DD 005",0f)[0](2001,"Philips Imaging DD 001",0a)", "(IS, 1)", "Slice Number MR"],
  ["(5200,9230)[0](2005,"Philips MR Imaging DD 005",0f)[0](2005,"Philips MR Imaging DD 001",0b)", "(FL, 1)", "?"],
  ["(5200,9230)[0](2005,"Philips MR Imaging DD 005",0f)[0](2005,"Philips MR Imaging DD 001",a0)", "(FL, 1)", "?"],
  ["(7fe0,0010)", "(OW, 1)", "Pixel Data"],
EOF

my $fields = [
  ["(0008,0018)", "(UI, 1)", "SOP Instance UID"],
  ["(0020,9162)", "(US, 1)", "In-concatenation Number"],
  ["(0020,9228)", "(UL, 1)", "Concatenation Frame Offset Number"],
  ["(5200,9230)[0](0020,9111)[0](0018,9074)", "(DT, 1)", "Frame Acquisition DateTime"],
  ["(5200,9230)[0](0020,9111)[0](0020,9057)", "(UL, 1)", "In-Stack Position Number"],
  ["(5200,9230)[0](0020,9111)[0](0020,9128)", "(UL, 1)", "Temporal Position Index"],
  ["(5200,9230)[0](0020,9111)[0](0020,9157)", "(UL, 3)", "Dimension Index Values"],
  ["(5200,9230)[0](0020,9113)[0](0020,0032)", "(DS, 3)", "Image Position (Patient)"],
  ["(5200,9230)[0](2005,\"Philips MR Imaging DD 005\",0f)[0](0008,0018)", "(UI, 1)", "SOP Instance UID"],
  ["(5200,9230)[0](2005,\"Philips MR Imaging DD 005\",0f)[0](0008,0033)", "(TM, 1)", "Content Time"],
  ["(5200,9230)[0](2005,\"Philips MR Imaging DD 005\",0f)[0](0020,0013)", "(IS, 1)", "Instance Number"],
  ["(5200,9230)[0](2005,\"Philips MR Imaging DD 005\",0f)[0](0020,0032)", "(DS, 3)", "Image Position (Patient)"],
  ["(5200,9230)[0](2005,\"Philips MR Imaging DD 005\",0f)[0](2001,\"Philips Imaging DD 001\",0a)", "(IS, 1)", "Slice Number MR"],
  ["(5200,9230)[0](2005,\"Philips MR Imaging DD 005\",0f)[0](2005,\"Philips MR Imaging DD 001\",0b)", "(FL, 1)", "?"],
  ["(5200,9230)[0](2005,\"Philips MR Imaging DD 005\",0f)[0](2005,\"Philips MR Imaging DD 001\",a0)", "(FL, 1)", "?"],
  ["(7fe0,0010)", "(OW, 1)", "Pixel Data"],
];
my $sort_by_cont;
my @dumps;
if($ARGV[0] eq "-c"){
  $sort_by_cont = 1;
}
if($ARGV[0] eq "-h"){
  die $usage;
}
my @files;
while(my $line = <STDIN>){
  chomp $line;
  push @files, $line;
}
my @Reports;
file:
for my $f (@files){
  my $try = Posda::Try->new($f);
  unless(exists $try->{dataset}){
    print STDERR "file: $f didn't parse\n";
    next file;
  }
  my @report;
  push @report, $f;
  my $c_index;
  for my $e (@$fields){
    my @sub_r = @$e;
    my $v = $try->{dataset}->Get($sub_r[0]);
    unless($sub_r[0] eq "(7fe0,0010)"){
      push @sub_r, $v;
    }
    if($sub_r[0] eq "(0020,9228)"){
      $c_index = $v;
    }
    push @report, \@sub_r;
  }
  if($sort_by_cont){
    unless(defined $c_index){
      die "Sorting by concat and file ($f) has non concat";
    }
    $Reports[$c_index] = \@report;
  } else {
    push @Reports, \@report;
  }
}
for my $Rpt (@Reports){
  print "-----------------------------\n" .
    "$Rpt->[0]\n";
  for my $i (1 .. $#{$Rpt}){
    if(ref($Rpt->[$i]) eq "ARRAY"){
      my $s = $Rpt->[$i];
      for my $j (0 .. $#{$s} - 1){
        print "$s->[$j]:";
      }
      unless($s->[0] eq "(7fe0,0010)"){
        if(ref($s->[$#{$s}]) eq "ARRAY"){
          for my $j (0 .. $#{$s->[$#{$s}]}){
            print $s->[$#{$s}]->[$j];
            unless($j == $#{$s->[$#{$s}]}){
              print "\\";
            }
          }
        } else {
          print "$s->[$#{$s}]";
        }
      }
    } else {
      print "Yikes (not an array)!";
    }
    print "\n";
  }
}
