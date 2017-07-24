#!/usr/bin/perl -w
use strict;
use Posda::DB::PosdaFilesQueries;
use Debug;
my $dbg = sub {print @_ };
my $usage = <<EOF;
ProcessDciodvfyScan.pl <type> <uid> <scan_id>
  <type> = one_per_series | all_per_series | per_sop
  <uid> = sop_instance_uid or series_instance_uid
  <scan_id> = id of dciodvfy_scan_instance

Line Formats:

    IOD|<Iod>
    Error|UnrecognizedPublicTag|<tag>
    Error|BadValueMultiplicity|<tag>|<actual>|<required>|<module>
    Error|CantBeNegative|<tag>|<value>
    Error|InvalidElementLength|<tag>|<value>|<length>|<desc>|<reasons>
    Error|AttributeSpecificError|<tag>|<desc>
    Error|AttributeSpecificErrorWithIndex|<tag>|<index>|<desc>
    Error|AttributesPresentWhenConditionNotSatisfied|<element>|<module>
    Error|MissingAttributes|<type>|<element>|<module>
    Error|MayNotBePresent|<condition>|<element>
    Error|UnrecognizedEnumeratedValue|<value>|<element>|<index>
    Error|Uncategorized|<error>
    Warning|WrongExplicitVr|<tag>|<desc|<actual>|<req|<reason>
    Warning|RetiredAttribute|<tag>|<desc>
    Warning|AttributeSpecificWarning|<tag>|<desc>
    Warning|AttributeSpecificWarningWithValue|<tag>|<value>|<desc>
    Warning|UnrecognizedDefinedTerm|<tag>|<index>|<value>
    Warning|UnrecognizedTag|<tag>|<comment>
    Warning|NonStandardAttribute|<tag>|<desc>|<Iod>
    Warning|MissingForDicomDir|<element>
    Warning|DubiousValue|<tag>|<desc>|<value>|<err>
    Warning|QuestionableValue|<value>|<element>|<index>
    Warning|Uncategorized|<warning>
EOF
unless($#ARGV == 2){
  die $usage;
}
unless(
  $ARGV[0] eq "all_per_series" ||
  $ARGV[0] eq "one_per_series" ||
  $ARGV[0] eq "per_sop"
) {
  die "$ARGV[0] is bad type\n";
}
my $q;
if($ARGV[0] eq "one_per_series"){
  $q = PosdaDB::Queries->GetQueryInstance("OneFileInSeries");
} elsif($ARGV[0] eq "all_per_series"){
  $q = PosdaDB::Queries->GetQueryInstance("FilesInSeries");
} elsif($ARGV[0] eq "per_sop"){
  $q = PosdaDB::Queries->GetQueryInstance("OneFileFromSop");
} else {
  die "Unknown type: $ARGV[0]";
}
my $scan_id = $ARGV[2];
my @FileList;
$q->RunQuery(sub{
  my($row) = @_;
  push @FileList, $row->[0];
}, sub {}, $ARGV[1]);
my %Lines;
my @Records;
for my $file (@FileList){
  open PIPE, "ScanDciodvfyOutput.pl \"$file\"|" or die "Can't open PIPE";
  while(my $line = <PIPE>){
    chomp $line;
    $Lines{$line} = 1;
  }
}
my $look_up = PosdaDB::Queries->GetQueryInstance("LookUpTag");
my $look_up_ele = PosdaDB::Queries->GetQueryInstance("LookUpTagEle");
my $create_unit_scan = PosdaDB::Queries->GetQueryInstance(
  "CreateDciodvfyUnitScan");
my $get_unit_scan_id = PosdaDB::Queries->GetQueryInstance(
  "GetDciodvfyUnitScanId");
my $unit_scan_id;
my $num_files = @FileList;
$create_unit_scan->RunQuery(sub {}, sub {},
  $ARGV[0], $ARGV[1], undef, $num_files);
$get_unit_scan_id->RunQuery(sub {
  my($row) = @_;
  $unit_scan_id = $row->[0];
}, sub {});
for my $line (sort keys %Lines){
  #print "Line: $line\n";
  my @fields = split(/\|/, $line);
  push @Records, \@fields;
}

#    Error|AttributesPresentWhenConditionNotSatisfied|<element>|<module>
my $get_e_attr_p = PosdaDB::Queries->GetQueryInstance(
  "GetDciodvfyErrorAttrPres");
#    Error|MayNotBePresent|<condition>|<element>
my $get_e_may_not = PosdaDB::Queries->GetQueryInstance(
  "GetDciodvfyErrorMayNotBePres");
#    Error|MissingAttributes|<type>|<element>|<module>
my $get_e_missing_attr = PosdaDB::Queries->GetQueryInstance(
  "GetDciodvfyErrorMissingAttr");
#    Error|UnrecognizedEnumeratedValue|<value>|<element>|<index>
my $get_e_unrecog_enum = PosdaDB::Queries->GetQueryInstance(
  "GetDciodvfyErrorUnrecogEnum");
#    Error|Uncategorized|<error>
my $get_e_uncat = PosdaDB::Queries->GetQueryInstance(
  "GetDciodvfyErrorUncat");
#    Error|UnrecognizedPublicTag|<tag>
my $get_e_unrecog_pub = PosdaDB::Queries->GetQueryInstance(
  "GetDciodvfyErrorUnrecogPub");
#    Error|BadValueMultiplicity|<tag>|<actual>|<required>|<module>
my $get_e_badvm = PosdaDB::Queries->GetQueryInstance(
  "GetDciodvfyErrorBadVm");
#    Error|CantBeNegative|<tag>|<value>
my $get_e_cant_be_neg = PosdaDB::Queries->GetQueryInstance(
  "GetDciodvfyErrorCantBeNegative");
#    Error|InvalidElementLength|<tag>|<value>|<length>|<desc>|<reasons>
my $get_e_invalid_ele_len = PosdaDB::Queries->GetQueryInstance(
  "GetDciodvfyErrorInvalidEleLen");
#    Error|AttributeSpecificError|<tag>|<desc>
my $get_e_attr_spec = PosdaDB::Queries->GetQueryInstance(
  "GetDciodvfyErrorAttrSpec");
#    Error|AttributeSpecificErrorWithIndex|<tag>|<index>|<desc>
my $get_e_attr_spec_index = PosdaDB::Queries->GetQueryInstance(
  "GetDciodvfyErrorAttrSpecWithIndex");

#    Warning|DubiousValue|<tag>|<desc>|<value>|<err>
my $get_w_dubious = PosdaDB::Queries->GetQueryInstance(
  "GetDciodvfyWarningDubious");
#    Warning|MissingForDicomDir|<element>
my $get_w_missing_dir = PosdaDB::Queries->GetQueryInstance(
  "GetDciodvfyWarningMissingDicomDir");
#    Warning|NonStandardAttribute|<tag>|<desc>|<Iod>
my $get_w_non_std = PosdaDB::Queries->GetQueryInstance(
  "GetDciodvfyWarningNonStd");
#    Warning|QuestionableValue|<value>|<element>|<index>
my $get_w_ques = PosdaDB::Queries->GetQueryInstance(
  "GetDciodvfyWarningQuestionable");
#    Warning|Uncategorized|<warning>
my $get_w_uncat = PosdaDB::Queries->GetQueryInstance(
  "GetDciodvfyWarningUncat");
#    Warning|UnrecognizedTag|<tag>|<comment>
my $get_w_unrecog_tag = PosdaDB::Queries->GetQueryInstance(
  "GetDciodvfyWarningUnrecogTag");
#    Warning|WrongExplicitVr|<tag>|<desc|<actual>|<req|<reason>
my $get_w_wrong_exp_vr = PosdaDB::Queries->GetQueryInstance(
  "GetDciodvfyWarningWrongExpVr");
#    Warning|RetiredAttribute|<tag>|<desc>
my $get_w_retired_attr = PosdaDB::Queries->GetQueryInstance(
  "GetDciodvfyWarningRetiredAttr");
#    Warning|AttributeSpecificWarning|<tag>|<desc>
my $get_w_attr_spec = PosdaDB::Queries->GetQueryInstance(
  "GetDciodvfyWarningAttrSpec");
#    Warning|AttributeSpecificWarningWithValue|<tag>|<value>|<desc>
my $get_w_attr_spec_with_value = PosdaDB::Queries->GetQueryInstance(
  "GetDciodvfyWarningAttrSpecWithValue");
#    Warning|UnrecognizedDefinedTerm|<tag>|<index>|<value>
my $get_w_unrecog_dt = PosdaDB::Queries->GetQueryInstance(
  "GetDciodvfyWarningUnrecognizedDT");

my $create_error = PosdaDB::Queries->GetQueryInstance(
  "CreateDciodvfyError");
my $get_error_id = PosdaDB::Queries->GetQueryInstance(
  "GetDciodvfyErrorId");
my $create_warning = PosdaDB::Queries->GetQueryInstance(
  "CreateDciodvfyWarning");
my $get_warning_id = PosdaDB::Queries->GetQueryInstance(
  "GetDciodvfyWarningId");

my $create_unit_scan_error = PosdaDB::Queries->GetQueryInstance(
  "CreateDciodvfyUnitScanError");
my $create_unit_scan_warning = PosdaDB::Queries->GetQueryInstance(
  "CreateDciodvfyUnitScanWarning");

my $start_xact = PosdaDB::Queries->GetQueryInstance(
  "StartTransaction");
my $stop_xact = PosdaDB::Queries->GetQueryInstance(
  "StopTransaction");
my $lock_errors = PosdaDB::Queries->GetQueryInstance(
  "LockErrors");
my $lock_warnings = PosdaDB::Queries->GetQueryInstance(
  "LockWarnings");

my $num_warnings = 0;
my $num_errors = 0;
for my $i (@Records){
  my $class = $i->[0];
  if($class eq "Error"){
    $start_xact->RunQuery(sub{}, sub{});
    $lock_errors->RunQuery(sub{}, sub{});
    my($error_type, $error_tag, $error_subtype, $error_module,
      $error_reason, $error_index, $error_value, $error_text);
    $error_type = $i->[1];
    my $error_id;
    if($error_type eq "AttributesPresentWhenConditionNotSatisfied"){
      $error_tag = $i->[2];
      $error_module = $i->[3];
      $get_e_attr_p->RunQuery(sub {
        my($row) = @_;
        $error_id = $row->[0];
      }, sub {}, ConvertTag($error_tag), $error_module);
    } elsif ($error_type eq "MayNotBePresent"){
      #   Error|MayNotBePresent|<condition>|<element>
      $error_reason = $i->[2];
      $error_tag = $i->[3];
      $get_e_may_not->RunQuery(sub {
        my($row) = @_;
        $error_id = $row->[0];
      }, sub {},  ConvertTag($error_tag), $error_reason);
    } elsif ($error_type eq "MissingAttributes"){
      #   Error|MissingAttributes|<type>|<element>|<module>
      $error_subtype = $i->[2];
      $error_tag = $i->[3];
      $error_module = $i->[4];
      $get_e_missing_attr->RunQuery(sub {
        my($row) = @_;
        $error_id = $row->[0];
      }, sub {}, $error_subtype, ConvertTag($error_tag), $error_module);
    } elsif ($error_type eq "UnrecognizedEnumeratedValue"){
      #   Error|UnrecognizedEnumeratedValue|<value>|<element>|<index>
      $error_value = $i->[2];
      $error_tag = $i->[3];
      $error_index = $i->[4];
      $error_index =~ s/^\s*//;
      $error_index =~ s/\s*$//;
      $error_value =~ s/^\s*//;
      $error_value =~ s/\s*$//;
      $error_tag =~ s/^\s*//;
      $error_tag =~ s/\s*$//;
      $get_e_unrecog_enum->RunQuery(sub {
        my($row) = @_;
        $error_id = $row->[0];
      }, sub {}, $error_value, ConvertTag($error_tag), $error_index);
    } elsif ($error_type eq "Uncategorized"){
      #   Error|Uncategorized|<error>
      $error_text = $i->[2];
      $get_e_uncat->RunQuery(sub {
        my($row) = @_;
        $error_id = $row->[0];
      }, sub {}, $error_text);
    } elsif($error_type eq "UnrecognizedPublicTag"){
      #   Error|UnrecognizedPublicTag|<tag>
      $error_tag = $i->[2];
      $get_e_unrecog_pub->RunQuery(sub {
        my($row) = @_;
        $error_id = $row->[0];
      }, sub {}, ConvertTag($error_tag));
    } elsif($error_type eq "BadValueMultiplicity"){
      #   Error|BadValueMultiplicity|<tag>|<actual>|<required>|<module>
      $error_tag = $i->[2];
      $error_value = $i->[3];
      $error_index = $i->[4];
      $error_module = $i->[5];
      $error_tag =~ s/^\s*//;
      $error_tag =~ s/\s*$//;
      $error_value =~ s/^\s*//;
      $error_value =~ s/\s*$//;
      $error_index =~ s/^\s*//;
      $error_index =~ s/\s*$//;
      $error_module =~ s/^\s*//;
      $error_module =~ s/\s*$//;
      $get_e_badvm->RunQuery(sub {
        my($row) = @_;
        $error_id = $row->[0];
      }, sub {}, ConvertTag($error_tag), $error_value, $error_index, $error_module);
    } elsif($error_type eq "CantBeNegative"){
      #   Error|CantBeNegative|<tag>|<value>
      $error_tag = $i->[2];
      $error_value = $i->[3];
      $error_tag =~ s/^\s*//;
      $error_tag =~ s/\s*$//;
      $get_e_cant_be_neg->RunQuery(sub {
        my($row) = @_;
        $error_id = $row->[0];
      }, sub {}, ConvertTag($error_tag), $error_value);
    } elsif($error_type eq "InvalidElementLength"){
      #   Error|InvalidElementLength|<tag>|<value>|<length>|<desc>|<reason>
      $error_tag = $i->[2];
      $error_value = $i->[3];
      $error_index = $i->[4];
      $error_subtype = $i->[5];
      $error_reason = $i->[6];
      $error_tag =~ s/^\s*//;
      $error_tag =~ s/\s*$//;
      $error_value =~ s/^\s*//;
      $error_value =~ s/\s*$//;
      $error_index =~ s/^\s*//;
      $error_index =~ s/\s*$//;
      $error_subtype =~ s/^\s*//;
      $error_subtype =~ s/\s*$//;
      $error_reason =~ s/^\s*//;
      $error_reason =~ s/\s*$//;
      $get_e_invalid_ele_len->RunQuery(sub {
        my($row) = @_;
        $error_id = $row->[0];
      }, sub {}, ConvertTag($error_tag), $error_value, $error_subtype, $error_reason, $error_index);
    } elsif($error_type eq "AttributeSpecificError"){
      #   Error|AttributeSpecificError|<tag>|<desc>
      $error_tag = $i->[2];
      $error_subtype = $i->[3];
      $error_tag =~ s/^\s*//;
      $error_tag =~ s/\s*$//;
      $error_subtype =~ s/^\s*//;
      $error_subtype =~ s/\s*$//;
      $get_e_attr_spec->RunQuery(sub {
        my($row) = @_;
        $error_id = $row->[0];
      }, sub {}, ConvertTag($error_tag), $error_subtype);
    } elsif($error_type eq "AttributeSpecificErrorWithIndex"){
      #   Error|AttributeSpecificErrorWithIndex|<tag>|<index>|<desc>
      $error_tag = $i->[2];
      $error_index = $i->[3];
      $error_subtype = $i->[4];
      $error_tag =~ s/^\s*//;
      $error_tag =~ s/\s*$//;
      $error_index =~ s/^\s*//;
      $error_index =~ s/\s*$//;
      $error_subtype =~ s/^\s*//;
      $error_subtype =~ s/\s*$//;
      $get_e_attr_spec_index->RunQuery(sub {
        my($row) = @_;
        $error_id = $row->[0];
      }, sub {}, ConvertTag($error_tag), $error_subtype, $error_index);
    }
    unless(defined $error_id){
      $create_error->RunQuery(sub {}, sub {},
        $error_type, ConvertTag($error_tag), $error_subtype, $error_module,
        $error_reason, $error_index, $error_value, $error_text);
      $get_error_id->RunQuery(sub {
        my($row) = @_;
        $error_id = $row->[0];
      }, sub{});
    }
    $stop_xact->RunQuery(sub{}, sub {});
    $create_unit_scan_error->RunQuery(sub {}, sub {},
      $scan_id, $unit_scan_id, $error_id);
    $num_errors += 1;
  } elsif($class eq "Warning"){
    $start_xact->RunQuery(sub{}, sub{});
    $lock_warnings->RunQuery(sub{}, sub {});
    my($warn_type, $warn_tag, $warn_desc, $warn_iod, $warn_text,
      $warn_comment, $warn_value, $warn_reason, $warn_index);
    $warn_type = $i->[1];
    my $warn_id;
    if($warn_type eq "DubiousValue"){
    #   Warning|DubiousValue|<tag>|<desc>|<value>|<err>
      $warn_tag = $i->[2];
      $warn_desc = $i->[3];
      $warn_value = $i->[4];
      $warn_reason = $i->[5];
      $warn_desc =~ s/^\s*//g;
      $warn_desc =~ s/\s*$//g;
      $get_w_dubious->RunQuery(sub{
        my($row) = @_;
        $warn_id = $row->[0];
      }, sub{}, ConvertTag($warn_tag), $warn_desc, $warn_value, $warn_reason);
    } elsif ($warn_type eq "MissingForDicomDir"){
      #   Warning|MissingForDicomDir|<element>
      $warn_tag = $i->[2];
      $get_w_missing_dir->RunQuery(sub{
        my($row) = @_;
        $warn_id = $row->[0];
      }, sub{}, ConvertTag($warn_tag));
    } elsif ($warn_type eq "NonStandardAttribute"){
      #   Warning|NonStandardAttribute|<tag>|<desc>|<Iod>
      $warn_tag = $i->[2];
      $warn_desc = $i->[3];
      $warn_iod = $i->[4];
      $warn_desc =~ s/^\s*//g;
      $warn_desc =~ s/\s*$//g;
      $get_w_non_std->RunQuery(sub{
        my($row) = @_;
        $warn_id = $row->[0];
      }, sub{}, ConvertTag($warn_tag), $warn_desc, $warn_iod);
    } elsif ($warn_type eq "QuestionableValue"){
      #   Warning|QuestionableValue|<value>|<element>|<index>
      $warn_reason = $i->[2];
      $warn_tag = $i->[3];
      $warn_index = $i->[4];
      $get_w_ques->RunQuery(sub{
        my($row) = @_;
        $warn_id = $row->[0];
      }, sub{}, $warn_reason, ConvertTag($warn_tag), $warn_index);
    } elsif ($warn_type eq "UnrecognizedTag"){
      #   Warning|UnrecognizedTag|<tag>|<comment>
      $warn_tag = $i->[2];
      $warn_comment = $i->[3];
      $get_w_unrecog_tag->RunQuery(sub{
        my($row) = @_;
        $warn_id = $row->[0];
      }, sub{}, ConvertTag($warn_tag), $warn_comment);
    } elsif ($warn_type eq "Uncategorized"){
      #   Warning|Uncategorized|<warning>
      $warn_text = $i->[2];
      $warn_text =~ s/^\s*//;
      $warn_text =~ s/\s*$//;
      $get_w_uncat->RunQuery(sub {
        my($row) = @_;
        $warn_id = $row->[0];
      }, sub{}, $warn_text);
    } elsif ($warn_type eq "WrongExplicitVr"){
      #   Warning|WrongExplicitVr|<tag>|<desc|<actual>|<req>|<reason>
      $warn_tag = $i->[2];
      $warn_desc = $i->[3];
      $warn_comment = $i->[4];
      $warn_value = $i->[5];
      $warn_reason = $i->[6];
      $warn_desc =~ s/^\s*//g;
      $warn_desc =~ s/\s*$//g;
      $get_w_wrong_exp_vr->RunQuery(sub {
        my($row) = @_;
        $warn_id = $row->[0];
      }, sub {},
        ConvertTag($warn_tag), $warn_desc, $warn_comment, $warn_value, $warn_reason);
    } elsif ($warn_type eq "RetiredAttribute"){
      #   Warning|RetiredAttribute|<tag>|<desc>
      $warn_tag = $i->[2];
      $warn_desc = $i->[3];
      $warn_tag =~ s/^\s*//g;
      $warn_tag =~ s/\s*$//g;
      $warn_desc =~ s/^\s*//g;
      $warn_desc =~ s/\s*$//g;
      $get_w_retired_attr->RunQuery(sub {
        my($row) = @_;
        $warn_id = $row->[0];
      }, sub {},
        ConvertTag($warn_tag), $warn_desc);
    } elsif ($warn_type eq "AttributeSpecificWarning"){
      #   Warning|AttributeSpecificWarning|<tag>|<desc>
      $warn_tag = $i->[2];
      $warn_desc = $i->[3];
      $warn_tag =~ s/^\s*//g;
      $warn_tag =~ s/\s*$//g;
      $warn_desc =~ s/^\s*//g;
      $warn_desc =~ s/\s*$//g;
      $get_w_attr_spec->RunQuery(sub {
        my($row) = @_;
        $warn_id = $row->[0];
      }, sub {}, ConvertTag($warn_tag), $warn_desc);
    } elsif ($warn_type eq "AttributeSpecificWarningWithValue"){
      #   Warning|AttributeSpecificWarningWithValue|<tag>|<value>|<desc>
      $warn_tag = $i->[2];
      $warn_value = $i->[3];
      $warn_desc = $i->[4];
      $warn_tag =~ s/^\s*//g;
      $warn_tag =~ s/\s*$//g;
      $warn_value =~ s/^\s*//g;
      $warn_value =~ s/\s*$//g;
      $warn_desc =~ s/^\s*//g;
      $warn_desc =~ s/\s*$//g;
      $get_w_attr_spec_with_value->RunQuery(sub{
        my($row) = @_;
        $warn_id = $row->[0];
      }, sub {}, ConvertTag($warn_tag), $warn_desc, $warn_value);
    } elsif ($warn_type eq "UnrecognizedDefinedTerm"){
      #   Warning|UnrecognizedDefinedTerm|<tag>|<index>|<value>
      $warn_tag = $i->[2];
      $warn_index = $i->[3];
      $warn_value = $i->[4];
      $warn_tag =~ s/^\s*//g;
      $warn_tag =~ s/\s*$//g;
      $warn_value =~ s/^\s*//g;
      $warn_value =~ s/\s*$//g;
      $warn_index =~ s/^\s*//g;
      $warn_index =~ s/\s*$//g;
      $get_w_unrecog_dt->RunQuery(sub {
        my($row) = @_;
        $warn_id = $row->[0];
      }, sub {}, ConvertTag($warn_tag), $warn_value, $warn_index);
    }
    unless(defined $warn_id){
      $create_warning->RunQuery(sub {}, sub {},
        $warn_type, ConvertTag($warn_tag), $warn_desc, $warn_iod,
        $warn_comment, $warn_value, $warn_reason, $warn_index, 
        $warn_text);
      $get_warning_id->RunQuery(sub {
        my($row) = @_;
        $warn_id = $row->[0];
      }, sub{});
    }
    $stop_xact->RunQuery(sub{}, sub {});
    $create_unit_scan_warning->RunQuery(sub {}, sub {},
      $scan_id, $unit_scan_id, $warn_id);
    $num_warnings += 1;
  } else {
  }
}
my $finalize_unit_scan = PosdaDB::Queries->GetQueryInstance(
  "FinalizeDciodvfyUnitScan");
$finalize_unit_scan->RunQuery(sub {}, sub {},
  $num_errors, $num_warnings, $unit_scan_id);

sub ConvertTag{
  my($tag) = @_;
  unless(defined $tag) { return $tag }
  my $string;
  my $sub = sub {
    my($row) = @_;
    my $ltag = $row->[0];
    my $name = $row->[1];
    my $keyword = $row->[2];
    my $vr = $row->[3];
    my $vm = $row->[4];
    my $is_retired = $row->[5];
    my $comments = $row->[5];
    $string = "$ltag $vr $vm $name";
  };
  if($tag =~ /^\(....,....\)$/){
    $look_up_ele->RunQuery($sub, sub {}, $tag);
  } else {
    $look_up->RunQuery($sub, sub {}, $tag, $tag);
  }
  if(defined $string) { return $string }
  return $tag;
}
