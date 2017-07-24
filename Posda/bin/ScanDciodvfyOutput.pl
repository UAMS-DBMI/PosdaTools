#!/usr/bin/perl -w
use strict;
my $usage = <<EOF;
ScanDciodvfyOutput.pl <file>
EOF
unless($#ARGV == 0){
  die $usage;
}
unless(-f $ARGV[0]) {
  die "$ARGV[0] is not a file\n";
}
my $dciodvfy = "/opt/dicom3tools/bin/dciodvfy";
my $cmd = "$dciodvfy \"$ARGV[0]\" 2>&1|sort -u";
open PIPE, "$cmd|";
my %UnrecognizedTags;
my %NonStandardAttributes;
my %AttributesPresentWhenConditionNotSatisfied;
my %Errors;
my %Warnings;
my %MissingForDicomDir;
my %DubiousValues;
my %MissingAttributes;
my %MayNotBePresent;
my %UnrecognizedEnumeratedValues;
my %QuestionableValues;
my %WrongExplicitVr; #{<tag>}->{<desc>}->{<actual>}->{<required>}->{reason}
my %RetiredAttribute; #{<tag>}->{<desc>}
my %AttributeSpecificWarning; #{<tag>}->{<desc>}
my %AttributeSpecificWarningWithValue; #{<tag>}->{<value>}->{<desc>}
my %UnrecognizedDefinedTerm; #{<tag>}->{<index>}->{<value>}
my %UnrecognizedPublicTag; #{<tag>}
my %BadVm; #{<tag>}->{<actual>}->{<required>}->{<module>}
my %CantBeNegative; #{<tag>}->{<value>}
my %InvalidElementLength; #{<tag>}->{<value>}->{<length>}->{<desc>}->{<reason>}
my %AttributeSpecificError; #{<tag>}->{<desc>}
my %AttributeSpecificErrorWithIndex; #{<tag>}->{<index>}->{<desc>}

my $Iod;
while(my $line = <PIPE>){
  chomp $line;
  if($line =~ /^\(0x(....),0x(....)\)\s*\?\s*-\s*Warning\s*-\s*Unrecognized tag\s*-\s*(.*)$/){
    my $tag = "($1,$2)";
    my $comment = $3;
    $UnrecognizedTags{$tag}->{$comment} = 1;
  } elsif(
    $line =~ /^Error - Unrecognized enumerated value <([^>]+)>\s*for value\s*(.*)\s*of attribute\s*<([^>]+)>/
  ){
    my $value = $1;
    my $index = $2;
    my $element = $3;
    $index =~ s/^\s*//;
    $index =~ s/\s*$//;
    $UnrecognizedEnumeratedValues{$value}->{$element}->{$index} = 1;
  } elsif(
    $line =~ /^Warning - Unrecognized defined term <([^>]+)>\s*for value\s*(.*)\s*of attribute\s*<([^>]+)>/
  ){
    my $value = $1;
    my $index = $2;
    my $tag = $3;
    $index =~ s/^\s*//;
    $index =~ s/\s*$//;
    $UnrecognizedDefinedTerm{$tag}->{$index}->{$value} = 1;
  }elsif($line =~ /^\(0x(....),0x(....)\)\s*(.*)\s*- Warning -\s*(Explicit value.*dictionary); Explicit <(..)> Dictionary <(..)>\s*$/){
#(0x0009,0x10b2) SS IR Num Iterations  - Warning - Explicit value representation doesn't match data dictionary; Explicit <SL> Dictionary <SS>
    my $tag = "($1,$2)";
    my $comment = $3;
    my $reason = $4;
    my $actual = $5;
    my $required = $6;
    $WrongExplicitVr{$tag}->{$comment}->{$actual}->{$required}->{$reason} = 1;
  } elsif($line =~ 
    /^Error - Not permitted to be negative - attribute <([^>]+)> = <([^>]+)>$/
  ){
    my $tag = $1;
    my $value = $2;
    $CantBeNegative{$tag}->{$value} = 1;
  } elsif($line =~ 
    /^Warning - Retired attribute - \(0x(....),0x(....)\)\s*(.*)\s*$/
  ){
    my $tag = "($1,$2)";
    my $desc = $3;
    $RetiredAttribute{$tag}->{$desc} = 1;
  } elsif($line =~ 
    /^Error - (.*)\s*for value\s*(\d+)\s*of attribute <([^>]+)>$/
  ){
    my $desc = $1;
    my $index = $2;
    my $tag = $3;
    $index =~ s/^\s*//;
    $index =~ s/\s*$//;
    $AttributeSpecificErrorWithIndex{$tag}->{$index}->{$desc} = 1;
  } elsif(
    $line =~ /^Error -\s*(.*)\s*for value\s*(\d+)\s*(.*)\s*-\s*attribute\*<([^>]+)>\s*$/
  ){
    my $desc1 = $1;
    my $index = $2;
    my $desc2 = $3;
    my $tag = $4;
    $index =~ s/^\s*//;
    $index =~ s/\s*$//;
    my $desc = "$desc1 $desc2";
    $AttributeSpecificErrorWithIndex{$tag}->{$index}->{$desc} = 1;
  } elsif($line =~ 
    /^Error - (Pixel Aspect Ratio) (.*)\s*$/
  ){
    my $tag = $1;
    my $desc = $2;
    $AttributeSpecificError{$tag}->{$desc} = 1;
  } elsif($line =~ 
    /^Warning -\s*(.*)\s*-\s*attribute\s*<([^>]+)>\s*$/
  ){
#Coding Scheme Designator is deprecated - attribute <CodingSchemeDesignator> = <99SDM>
    my $desc = $1;
    my $tag = $2;
    $AttributeSpecificWarning{$tag}->{$desc} = 1;
  } elsif($line =~ 
    /^Warning -\s*(.*)\s*-\s*attribute\s*<([^>]+)>\s*=\s*<([^>]+)>\s*$/
  ){
    my $desc = $1;
    my $tag = $2;
    my $value = $3;
    $AttributeSpecificWarningWithValue{$tag}->{$value}->{$desc} = 1;
  } elsif($line =~ 
    /^Error - Value invalid for this VR - \(0x(....),0x(....)\)\s*(.*)\s*= <([^>]+)> - Length invalid for this VR = (\d*),\s*(expected.*)\s*$/
  ){
    my $tag = "($1,$2)";
    my $desc = $3;
    my $value = $4;
    my $len = $5;
    my $reas = $6;
    $InvalidElementLength{$tag}->{$value}->{$len}->{$desc}->{$reas} = 1;
  } elsif($line =~ 
    /^Error - (Attribute with an even.* attribute) - \(0x(....),0x(....)\)\s*\?\s*$/
  ){
    my $desc = $1;
    my $tag = "($2,$3)";
    $UnrecognizedPublicTag{$tag} = 1;
  } elsif($line =~ 
    /^Error - Bad attribute Value Multiplicity\s*(\d*)\s*\((\d*)\s*Required by Dictionary\) Element=<([^>]+)> Module=<([^>]+)>$/
  ){
    my $actual = $1;
    my $req = $2;
    my $tag = $3;
    my $module = $4;
    $BadVm{$tag}->{$actual}->{$req}->{$module} = 1;
  } elsif($line =~ 
    /^Error - Illegal negative value -\s*(.*)\s*=\s*(.*)\s*$/
  ){
    my $tag = $1;
    my $value = $2;
    $CantBeNegative{$tag}->{$value} = 1;
  } elsif($line =~ 
    /^Error - Attribute present when condition unsatisfied.*Element=<([^>]+)> Module=<([^>]+)>/
  ){
    my $element = $1;
    my $module = $2;
    $AttributesPresentWhenConditionNotSatisfied{$element}->{$module} = 1;
  } elsif(
    $line =~ /^Warning - Attribute is not present in standard DICOM IOD.*\(0x(....),0x(....)\)\s*(.*)$/
  ){
    my $tag = "($1,$2)";
    my $desc = $3;
    $desc =~ s/\s*$//;
    $NonStandardAttributes{$tag} = $desc;
  } elsif(
    $line =~ /^Error - May not be present when\s*(.*) - attribute <([^>]+)>/
  ){
    my $condition = $1;
    my $element = $2;
    $MayNotBePresent{$condition}->{$element} = 1;
  } elsif(
    $line =~ /^Error - Missing attribute\s*(.*)=<([^>]+)> Module=<([^>]+)>/
  ){
    my $type = $1;
    my $element = $2;
    my $module = $3;
    $MissingAttributes{$type}->{$element}->{$module} = 1;
  } elsif(
    $line eq "Warning - Dicom dataset contains attributes not present in standard DICOM IOD - this is a Standard Extended SOP Class"
  ){
  } elsif(
    $line =~ /^Warning - Missing attribute.*to build DICOMDIR -\s*(.*)$/
  ){
    my $attribute = $1;
    $MissingForDicomDir{$attribute} = 1;
  } elsif(
    $line =~ /^Warning - Value dubious for this VR - \(0x(....),0x(....)\)\s*(.*) = <([^>]+)> -\s*(.*)$/
  ){
    my $tag = "($1,$2)";
    my $desc = $3;
    my $value = $4;
    my $err = $5;
    $DubiousValues{$tag}->{$desc}->{$value}->{$err} = 1;
  } elsif(
    $line =~ /^Warning - Value\s*(.*)\s+for value\s*(.*)\s+of attribute <([^>]+)>$/
  ){
    my $value = $1;
    my $index = $2;
    my $element = $3;
    $index =~ s/^\s*//;
    $index =~ s/\s*$//;
    $QuestionableValues{$value}->{$element}->{$index} = 1;
  } elsif(
    $line =~ /^Warning -\s*(.*)$/
  ){
    $Warnings{$1} = 1;
  } elsif(
    $line =~ /^Error -\s*(.*)$/
  ){
    $Errors{$1} = 1;
  } elsif ($line =~ /Warning -/){
    $Warnings{$line} = 1;
  } elsif ($line =~ /Error -/){
    $Errors{$line} = 1;
  } else {
    $Iod = $line;
  }
};
print "IOD|$Iod\n";
# - $WrongExplicitVr{<tag>}->{<desc>}->{<actual>}->{<required>}->{reason}
for my $tag (keys %WrongExplicitVr){
  for my $desc (keys %{$WrongExplicitVr{$tag}}){
    for my $actual (keys %{$WrongExplicitVr{$tag}->{$desc}}){
      for my $req (keys %{$WrongExplicitVr{$tag}->{$desc}->{$actual}}){
        for my $reas (keys %{$WrongExplicitVr{$tag}->{$desc}->{$actual}->{$req}}){
          print "Warning|WrongExplicitVr|$tag|$desc|$actual|$req|$reas\n";
        }
      }
    }
  }
}
# - $RetiredAttribute{<tag>}->{<desc>}
for my $tag (keys %RetiredAttribute){
  for my $desc (keys %{$RetiredAttribute{$tag}}){
    print "Warning|RetiredAttribute|$tag|$desc\n";
  }
}
# - $AttributeSpecificWarning{<tag>}->{<desc>}
for my $tag (keys %AttributeSpecificWarning){
  for my $desc (keys %{$AttributeSpecificWarning{$tag}}){
    print "Warning|AttributeSpecificWarning|$tag|$desc\n";
  }
}
# - $AttributeSpecificWarningWithValue{<tag>}->{<value>}->{<desc>}
for my $tag (keys %AttributeSpecificWarningWithValue){
  for my $value (keys %{$AttributeSpecificWarningWithValue{$tag}}){
    for my $desc (keys %{$AttributeSpecificWarningWithValue{$tag}->{$value}}){
      print "Warning|AttributeSpecificWarningWithValue|$tag|$value|$desc\n";
    }
  }
}
# - $UnrecognizedDefinedTerm{<tag>}->{<index>}->{<value>}
for my $tag (keys %UnrecognizedDefinedTerm){
  for my $index (keys %{$UnrecognizedDefinedTerm{$tag}}){
    for my $value (keys %{$UnrecognizedDefinedTerm{$tag}->{$index}}){
      print "Warning|UnrecognizedDefinedTerm|$tag|$index|$value\n";
    }
  }
}
# - $UnrecognizedPublicTag{<tag>}
for my $tag (keys %UnrecognizedPublicTag){
  print "Error|UnrecognizedPublicTag|$tag\n";
}
# - $BadVm{<tag>}->{<actual>}->{<required>}->{<module>}
for my $tag (keys %BadVm){
  for my $actual (keys %{$BadVm{$tag}}){
    for my $required (keys %{$BadVm{$tag}->{$actual}}){
      for my $module (keys %{$BadVm{$tag}->{$actual}->{$required}}){
        print "Error|BadValueMultiplicity|$tag|$actual|$required|$module\n";
      }
    }
  }
}
# - $CantBeNegative{<tag>}->{<value>}
for my $tag (keys %CantBeNegative){
  for my $value (keys %{$CantBeNegative{$tag}}){
    print "Error|CantBeNegative|$tag|$value\n";
  }
}
# - $InvalidElementLength{<tag>}->{<value>}->{<length>}->{<desc>}->{reason}
for my $tag (keys %InvalidElementLength){
  for my $value (keys %{$InvalidElementLength{$tag}}){
    for my $length (keys %{$InvalidElementLength{$tag}->{$value}}){
      for my $desc (keys %{$InvalidElementLength{$tag}->{$value}->{$length}}){
        for my $reas (keys %{$InvalidElementLength{$tag}->{$value}->{$length}->{$desc}}){
          print "Error|InvalidElementLength|$tag|$value|$length|$desc|$reas\n";
        }
      }
    }
  }
}
# - $AttributeSpecificError{<tag>}->{<desc>}
for my $tag (keys %AttributeSpecificError){
  for my $desc (keys %{$AttributeSpecificError{$tag}}){
    print "Error|AttributeSpecificError|$tag|$desc\n";
  }
}
#  $AttributeSpecificErrorWithIndex{<tag>}->{<index>}->{<desc>}
for my $tag (keys %AttributeSpecificErrorWithIndex){
  for my $index (keys %{$AttributeSpecificErrorWithIndex{$tag}}){
    for my $desc (keys %{$AttributeSpecificErrorWithIndex{$tag}->{$index}}){
      print "Error|AttributeSpecificErrorWithIndex|$tag|$index|$desc\n";
    }
  }
}

# - $UnrecognizedTags{$tag}->{$comment} - 1;
for my $tag (keys %UnrecognizedTags){
  for my $comment(keys %{$UnrecognizedTags{$tag}}){
    print "Warning|UnrecognizedTag|$tag|$comment\n";
  }
}
# - $NonStandardAttributes{$tag} = $desc;
for my $tag(keys %NonStandardAttributes){
  print "Warning|NonStandardAttribute|$tag|$NonStandardAttributes{$tag}|$Iod\n";
}
# - $AttributesPresentWhenConditionNotSatisfied{$element}->{$module} = 1;
for my $element (keys %AttributesPresentWhenConditionNotSatisfied){
  for my $module (
    keys %{$AttributesPresentWhenConditionNotSatisfied{$element}}
  ){
    print "Error|AttributesPresentWhenConditionNotSatisfied|$element|$module\n";
  }
}
# - $MissingForDicomDir{$attribute};
for my $element(keys %MissingForDicomDir){
  print "Warning|MissingForDicomDir|$element\n";
}
# - $DubiousValues{$tag}->{$desc}->{$value}->{$err};
for my $tag (keys %DubiousValues){
  for my $desc (keys %{$DubiousValues{$tag}}){
    for my $value (keys %{$DubiousValues{$tag}->{$desc}}){
      for my $err (keys %{$DubiousValues{$tag}->{$desc}->{$value}}){
        print "Warning|DubiousValue|$tag|$desc|$value|$err\n";
      }
    }
  }
}
# - $MissingAttributes{$type}->{$element}->{$module};
for my $type (keys %MissingAttributes){
  for my $element (keys %{$MissingAttributes{$type}}){
    for my $module (keys %{$MissingAttributes{$type}->{$element}}){
      print "Error|MissingAttributes|$type|$element|$module\n";
    }
  }
}
# - $MayNotBePresent{$conditon}->{$element} = 1;
for my $condition (keys %MayNotBePresent){
  for my $element (keys %{$MayNotBePresent{$condition}}){
    print "Error|MayNotBePresent|$condition|$element\n";
  }
}
# - $UnrecognizedEnumeratedValues{$value}->{$element}->{$index} = 1;
for my $value (keys %UnrecognizedEnumeratedValues){
  for my $element (keys %{$UnrecognizedEnumeratedValues{$value}}){
    for my $index (keys %{$UnrecognizedEnumeratedValues{$value}->{$element}}){
      print "Error|UnrecognizedEnumeratedValue|$value|$element|$index\n";
    }
  }
}
# - $QuestionableValues{$value}->{$element}->{$index};
for my $value (keys %QuestionableValues){
  for my $element (keys %{$QuestionableValues{$value}}){
    for my $index (keys %{$QuestionableValues{$value}->{$element}}){
      print "Warning|QuestionableValue|$value|$element|$index\n";
    }
  }
}
# - $Errors{$error} = 1;
for my $error (keys %Errors){
  print "Error|Uncategorized|$error\n";
}
#$Warnings{$warning} = 1;
for my $warning (keys %Warnings){
  print "Warning|Uncategorized|$warning\n";
}
