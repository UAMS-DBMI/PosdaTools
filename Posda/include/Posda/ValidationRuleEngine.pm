#!/usr/bin/perl -w
#
#Copyright 2013, Bill Bennett
# Part of the Posda package
# Posda may be copied only under the terms of either the Artistic License or the
# GNU General Public License, which may be found in the Posda Distribution,
# or at http://posda.com/License.html
#
use strict;
package Posda::ValidationRuleEngine;
use Debug;
my $dbg = sub {print STDERR @_ };
sub invoke{
  my($rule, $ds) = @_;
  if(ref($rule) eq "HASH"){
    if($rule->{pattern}){
#print STDERR "Searching for pattern: $rule->{pattern}\n";
      my $ml;
      if(defined $rule->{value}){
        $ml = $ds->Search($rule->{pattern}, $rule->{value});
      } else {
        $ml = $ds->Search($rule->{pattern});
      }
#print STDERR "Pattern: $rule->{pattern}\n";
#if($ml && ref($ml) eq "ARRAY") {
#  my $num_matches = scalar @{$ml};
#  print STDERR "$num_matches matches\n";
#} else { print STDERR "No matches\n" }
      if($ml && ref($ml) eq "ARRAY" && $#{$ml} >= 0 ) {
        # matches found
#print STDERR "match found $rule->{pattern}\n";
        if(exists($rule->{constraint}) && $rule->{constraint} eq "unique"){
#print STDERR "Unique Constraint\n";
          #check uniqueness
          my %value_map;
          for my $m (@$ml){
            my $sub_pat = {};
            for my $i (0 .. $#{$m}){
              $sub_pat->{"<$i>"} = $i;
            }
            my $get_sig = $ds->Substitute($rule->{pattern}, $m, $sub_pat);
            my $value = $ds->Get($get_sig);
            $value_map{$value}->{$get_sig} = 1;
          }
          my $violations = "";
          for my $v (sort keys %value_map){
            my @sigs = sort keys %{$value_map{$v}};
            if($#sigs > 0){
              $violations .= "\tValue \"$v\" in:\n";
              for my $i (0 .. $#sigs){
                $violations .= "\t\telement $sigs[$i]";
                unless($i == $#sigs) { $violations .= "\n" }
              }
            }
          }
          if($violations ne ""){
            my $rpt = $rule->{violation};
            $rpt =~ s/<v>/$violations/g;
            invoke($rpt, $ds);
          }
        } elsif(
           exists($rule->{constraint}) &&
           $rule->{constraint} eq "only_zero_unless_changing"
        ){
#############################################
#print STDERR "Zero unless changing Constraint $rule->{pattern}\n";
          my @violations;
          for my $m (@$ml){
            my %map = ( "<0>" => 0);
            my $get_sig = $ds->Substitute($rule->{pattern}, $m, \%map);
            my $cp = $ds->Get($get_sig);
            element:
            for my $ele (@{$rule->{elements}}){
              ####  place for results of the $item_i loop (for $ele)
              my %value_map;             #value_map{value}->{index} = 1
              my $zero_value_exists = 0;
              my $num_items = 0;         #number of items in sequence
              my $num_occurances = 0;    #number of items with ele
              my $present_no_value_count = 0;
              ####   
              item:
              for my $item_i (0 .. $#{$cp}){
                $num_items += 1;
                my $item_sig = $get_sig . "[" .$item_i. "]";
                unless(exists $cp->[$item_i]) {
                  push(@violations, "$item_sig doesn't exist");
                  next item;
                }
                unless(defined $cp->[$item_i]) {
                  push(@violations, "$item_sig is undefined");
                  next item;
                }
                unless(ref($cp->[$item_i]) eq "Posda::Dataset") {
                  push(@violations, "$item_sig is not a Dicom Dataset");
                  next item;
                }
                my $fetch_ele = $ele;
                my $v = $cp->[$item_i]->Get($fetch_ele);
                my $d = $cp->[$item_i]->GetEle($fetch_ele);
                if(defined $d) {
                  $num_occurances += 1;
                  if($item_i == 0){ $zero_value_exists = 1 }
                  my $v1 = $cp->[$item_i]->ValueDigest($fetch_ele, $v);
                  $value_map{$v1}->{$item_i} = 1;
                  if(ref($v) eq "ARRAY" && $#{$v} < 0) { $v = undef }
                  unless(defined $v){
                     $present_no_value_count += 1;
                  }
                }
              }
              ### Crunch results and flag violations
              unless($zero_value_exists){
                if($num_occurances > 0){
                  push(@violations, 
                    "$ele doesn't appear in item 0, but " .
                    "occurs in $num_occurances other items");
                } else {
                  push(@violations, 
                    "$ele doesn't appear in any items");
                }
                next element;
              }
              if($present_no_value_count > 0){
                push(@violations, 
                  "$ele is present with no value in $present_no_value_count " .
                  "(of $num_items) items");
              }
              if($num_occurances == 0) { next element }
              if($num_occurances < $num_items && $num_occurances > 1) {
                push(@violations, 
                  "$ele appears in $num_occurances (of $num_items) items");
              }
              my $num_distinct_values = scalar keys %value_map;
              if($num_distinct_values <= 1 && $num_occurances > 1){
                push(@violations, 
                  "$ele appears in $num_occurances (of $num_items) items" .
                  ", but has only $num_distinct_values distinct " .
                  "value");
              }
              ###
            }
            if(scalar(@violations) > 0){
              print STDERR "$rule->{violations}\n";
              for my $i (@violations) {
                print STDERR "\t$i\n";
              }
            }
          }
#############################################
        } elsif (exists $rule->{invoke_each_match}){
#print STDERR "Invoke each match\n";
          # invoke new rule for each match
          for my $m (@$ml){
            my $sub_pat = {};
            for my $i (0 .. $#{$m}){
              $sub_pat->{"<$i>"} = $i;
            }
            my $get_sig = $ds->Substitute($rule->{pattern}, $m, $sub_pat);
            my $value = $ds->Get($get_sig);
            my $st = make_symbol_table($m, $value);
            my $nr = new_rule($rule->{invoke_each_match}, $st);
            invoke($nr, $ds);
          }
        } elsif(exists $rule->{eval_each_match}){
#print STDERR "Eval each match\n";
          # invoke new rule for each match
          # eval expresson for each match
          for my $m (@$ml){
            my $sub_pat = {};
            for my $i (0 .. $#{$m}){
              $sub_pat->{"<$i>"} = $i;
            }
            my $get_sig = $ds->Substitute($rule->{pattern}, $m, $sub_pat);
            my $value = $ds->Get($get_sig);
            my $st = make_symbol_table($m, $value);
            my $v = eval_expr($rule->{eval_each_match}, $ds, $st, $get_sig);
          }
        } elsif(exists $rule->{invoke}){
#print STDERR "Just invoke\n";
          # invoke rule without substitutions
#print STDERR "Invoking rule based on $rule->{pattern}\n";
          invoke($rule->{invoke}, $ds);
        } else {
#print STDERR "no handler $rule->{pattern}\n";
          #matches, no handler found (do nothing, no_match handler)
        }
      } else {
        # no matches found
        if(exists $rule->{invoke_no_match}){
          invoke($rule->{invoke_no_match}, $ds);
        }
      }
    } else {
      my $text = "";
      for my $i (keys %$rule){
        $text = "\n\t$i => $rule->{$i}";
      }
      die "Malformed Rule (no pattern):$text";
    }
  } elsif (ref($rule) eq "ARRAY"){
    # rule is expression
    if($rule->[0] eq "list"){
      # rule is expression
      my $count = $#{$rule};
      for my $i (1 .. $#{$rule}){
        invoke($rule->[$i], $ds);
      }
    } else { print STDERR "unknown rule type: $rule->[0]\n" };
  } else {
    print STDERR "$rule\n";
  }
}
sub make_symbol_table{
  my($m, $v) = @_;
  my %st;
  $st{"<v>"} = $v;
  for my $i (0 .. $#{$m}){
    my $key = "<i$i>";
    my $value = $m->[$i];
    $st{$key} = $value;
  }
  return \%st;
}
sub new_rule{
  my($rule, $st) = @_;
  if(ref($rule) eq "HASH"){
    my $nr = {};
    for my $k (keys %$rule){
      my $str = expr_sub($rule->{$k}, $st);
      $nr->{$k} = $str;
    }
    return $nr;
  } elsif (ref($rule) eq "ARRAY"){
    my @nr;
    for my $i (@$rule){
      push(@nr, new_rule($i, $st));
    }
    return \@nr;
  }
  return $rule;
}
sub eval_expr{
  my($expr, $ds, $st, $root) = @_;
  if(ref($expr) eq "ARRAY"){
    if($expr->[0] eq "prog_sub"){
      expr:
      for my $i (1 .. $#{$expr}){
        my $new_expr = expr_sub($expr->[$i], $st);
        eval {eval_expr($new_expr, $ds, $st, $root)};
        if($@){
          my $str = $@;
          chomp $str;
          print STDERR "Expression error triggered by\n" .
            "\telement  $root\n" .
            "$str\n";
          return 0;
        }
      }
      return 1;
    } elsif($expr->[0] eq "get_unique_index"){
      my $ml = $ds->Search($expr->[1], $expr->[2]);
      unless($#{$ml} == 0){
        if($#{$ml} < 0){
          die "\tget_unique_index: no index for \n" .
            "\t$expr->[1]\n\tvalue: $expr->[2]\n";
        }
        die "\tget_unique_index: non_unique index for \n" .
          "\t$expr->[1]\n\tvalue: $expr->[2]\n";
      }
      return $ml->[0];
    } elsif($expr->[0] eq "set"){
      my $kb = $expr->[1];
      my $value = eval_expr($expr->[2], $ds, $st, $root);
      if(ref($value) eq "ARRAY"){
        for my $i (0 .. $#$value){
          my $key = $kb . $i;
          $st->{"<$key>"} = $value->[$i];
        }
      } else {
        $st->{"<$kb>"} = $value;
      }
      return undef;
    } elsif($expr->[0] eq "get_value"){
      my $value = $ds->Get($expr->[1]);
      return $value;
    } elsif($expr->[0] eq "unless"){
      unless(eval_expr($expr->[1], $ds, $st, $root)){
        return eval_expr($expr->[2], $ds, $st, $root);
      }
      return undef;
    } elsif($expr->[0] eq "and"){
      for my $i (1 .. $#{$expr}){
        unless(eval_expr($expr->[$i], $ds, $st, $root)){ return 0 }
      }
      return 1;
    } elsif($expr->[0] eq "or"){
      for my $i (1 .. $#{$expr}){
        if(eval_expr($expr->[$i], $ds, $st, $root)){ return 1 }
      }
      return 0;
    } elsif($expr->[0] eq "notnull"){
      if($expr->[1] eq ""){
        return undef;
      } else {
        return 1;
      }
    } elsif($expr->[0] eq "eq"){
      if($expr->[1] eq $expr->[2]){
        return 1;
      } else {
        return undef;
      }
    } elsif($expr->[0] eq "invoke"){
      return invoke($expr->[1], $ds);
    } else {
      die "unknown expr type: $expr->[0]";
    }
  } else {
    # expression is not an array
    return $expr;
  }
}
sub expr_sub{
  my($expr, $st) = @_;
  unless(ref($expr)){
    my $new = $expr;
    for my $i (keys %$st){
      $new =~ s/$i/$st->{$i}/eg;
    }
    return $new;
  }
  if(ref($expr) eq "ARRAY"){
    my @new;
    for my $i (@$expr){
      push(@new, expr_sub($i, $st));
    }
    return \@new;
  }
  return $expr;
}
1;
