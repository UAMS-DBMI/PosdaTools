#!/usr/bin/perl -w
#$Source: /home/bbennett/pass/archive/Posda/include/Posda/Validator.pm,v $
#$Date: 2010/05/11 17:13:20 $
#$Revision: 1.3 $
#
#Copyright 2009, Bill Bennett
# Part of the Posda package
# Posda may be copied only under the terms of either the Artistic License or the
# GNU General Public License, which may be found in the Posda Distribution,
# or at http://posda.com/License.html
#

package Posda::Validator;
use strict;
use Debug;
use Posda::Dclunie;
my $dbg = sub { print @_ };

sub new {
  my $class = shift;
  my $this;
  my $dd_dir = "$ENV{POSDA_TPL}/elmdict";
  my $mod_dir = "$ENV{POSDA_TPL}/module";
  my $iod_dir = "$ENV{POSDA_TPL}/iodcomp";
  my $list = [];
  opendir DD, $dd_dir or die "can't opendir $dd_dir";
  while(my $file = readdir DD){
    if($file =~ /\.tpl$/){
      Posda::Dclunie::parse_dict_file("$dd_dir/$file", $list);
    }
  }
  closedir DD;
  $this->{dd} = Posda::Dclunie::dd_to_keywordhash($list);
  my $mod = {};
  opendir MOD, $mod_dir or die "can't opendir $mod_dir";
  while(my $file = readdir MOD){
    if($file =~ /\.tpl$/){
      Posda::Dclunie::parse_module_file("$mod_dir/$file", $mod);
    }
  }
  closedir MOD;
  $this->{macros} = $mod->{macros};
  $this->{modules} = $mod->{modules};
  $this->{iods} = {};
  opendir IOD, $iod_dir or die "can't opendir $iod_dir";
  while(my $file = readdir IOD){
    if($file =~ /\.tpl$/){
      Posda::Dclunie::parse_iod_file("$iod_dir/$file", $this->{iods});
    }
  }
  $this->{condn} = {};
  Posda::Dclunie::parse_condn_file("$ENV{POSDA_TPL}/condn.tpl", $this->{condn});
  $this->{strval} = {};
  opendir STRD, "$ENV{POSDA_TPL}/strval" or 
    die "can't opendir $ENV{POSDA_TPL}/strval";
  while(my $file = readdir STRD){
    if($file =~ /\.tpl$/){
      Posda::Dclunie::parse_strval_file("$ENV{POSDA_TPL}/strval/$file", 
        $this->{strval});
    }
  }
  $this->{sopcl} = Posda::Dclunie::parse_sopcl_file(
    "$ENV{POSDA_TPL}/sopcl.tpl");
  for my $sop_name (keys %{$this->{sopcl}}){
    my $uid = $this->{sopcl}->{$sop_name}->{Uid};
    $this->{sopcl_uid}->{$uid} = $sop_name;
  }
  $this->{tagval} = Posda::Dclunie::parse_tagval_file(
    "$ENV{POSDA_TPL}/tagval.tpl");
  $this->{transyn} = Posda::Dclunie::parse_transyn_file(
    "$ENV{POSDA_TPL}/transyn.tpl");

  return bless $this, $class;
}

sub ExpandAnIod {
  my($this, $iod) = @_;
  my $exp = Posda::Dclunie::ExpandAnIod(
    $iod, $this->{modules}, $this->{macros}, $this->{dd});
  return $exp;
}

sub EvaluateCondition {
  my($this, $ds, $sig, $cond_name) = @_;
  unless(exists $this->{condn}->{$cond_name}){
    print STDERR "Unknown Condition: $cond_name\n";
    return 0;
#    die "unknown condition: $cond_name"
  }
print "Evaluating conditon $cond_name: ";
Debug::GenPrint($dbg, $this->{condn}->{$cond_name}, 1);
print "\n";
  my $cond = $this->{condn}->{$cond_name};
  return EvaluateCond($this, $ds, $sig, $cond);
}
sub EvaluateCond{
  my($this, $ds, $sig, $cond) = @_;
  my $result = 0;
my $term_no = 0;
  for my $term (@$cond){
$term_no += 1;
#print "Evaluating term: $term_no\n";
    $result = EvalTerm($this, $ds, $sig, $term, $result);
#print "term $term_no = $result\n";
  }
  return $result;
}
sub EvalTerm{
  my ($this, $ds, $sig, $term, $result) = @_;
  unless(ref($term) eq "ARRAY") { die "term should be an array" }
  if(ref($term->[0]) eq "ARRAY"){
    my $new_res = EvaluateCond($this, $ds, $sig, $term->[0]);
    if(exists($term->[1]->{Modifier}) && $term->[1]->{Modifier} eq "Not"){
print "Negating $new_res as Operator\n";
      $new_res = !$new_res;
    }
    if(exists($term->[1]->{Operator}) && $term->[1]->{Operator} eq "And"){
print "Returning $new_res && $result as Operator\n";
      return $new_res && $result;
    }
    if(exists($term->[1]->{Operator}) && $term->[1]->{Operator} eq "Or"){
print "Returning $new_res || $result as Operator\n";
      return $new_res || $result;
    }
print "Returning $new_res || $result as default (no Operator)\n";
    return $new_res || $result;
  } elsif(ref($term->[0])){
    die "term is ref of something other than array";
  } else {
    my $element_name = $term->[0];
print "Element_name: $term->[0]\n";
    my $sig;
    if($element_name =~ /\[/){
      $sig = Posda::Dclunie::get_specific_sig($this->{dd}, $element_name);
    } else {
      $sig = Posda::Dclunie::get_ele_sig(
        $this->{dd},
        [],
        $element_name
      );
    }
print "Checking element $sig ($element_name)\n";
    my $new_res = 0;
    my $ele = $ds->Get($sig);
    if(exists $term->[1]->{ElementPresent}){
print "Element Present?\n";
      if(defined $ele) { $new_res = 1 }
    } elsif(exists $term->[1]->{ValuePresent}){
print "Value Present?\n";
      if($ele) { $new_res = 1 }
    } elsif(exists $term->[1]->{StringValue}){
print "StringValue =  \"$term->[1]->{StringValue}\"\n";
      if(defined($ele) && $ele eq $term->[1]->{StringValue}) { $new_res = 1 }
    } elsif(exists $term->[1]->{TagValue}){
      my $req_tagvalue;
      my $pres_high = ($ele->[0] & 0xffff0000) >> 16;
      my $pres_low = $ele->[0] & 0xffff;
      my $pres_tag = sprintf("(%04x,%04x)", $pres_low, $pres_high);
      if($term->[1]->{TagValue} =~ /^0x(....),0x(....)$/){
        my $grp = $1;
        my $element = $2;
        $req_tagvalue = "($grp,$element)";
        print "req: $req_tagvalue present: $pres_tag\n";
      } else {
        die "Tagvalue in wrong format";
      }
print "TagValue =  ";
Debug::GenPrint($dbg, $ele, 1);
print "\n";
      if($req_tagvalue eq $pres_tag){
        $new_res = 1;
      } else {
        $new_res = 0;
print "Tag $pres_tag doesn't match required tag $req_tagvalue\n";
      }
    } elsif(exists $term->[1]->{StringValueFromRootAttribute}){
      if(
        defined($ele) && $ele eq $term->[1]->{StringValueFromRootAttribute}
      ) { $new_res = 1 } else {$new_res = 0}
    } elsif(exists $term->[1]->{BinaryValue}){
      if($term->[1]->{BinaryValue} eq "> 0"){
        if($ele > 0) { $new_res = 1} else {$new_res = 0}
      } elsif($term->[1]->{BinaryValue} eq "> 1"){
        if($ele > 1) { $new_res = 1} else {$new_res = 0}
      } else {
        die "Unsupported Binary Value specification $term->[1]->{BinaryValue}";
      }
    } else {
      my $mess;
      for my $i (sort keys %{$term->[1]}) { $mess .= " $i" }
      die "didn't find comprehensible command in \"$mess\"";
    }
print "term value: $new_res\n";
    if(exists($term->[1]->{Modifier}) && $term->[1]->{Modifier} eq "Not"){
      $new_res = !$new_res;
print "negated term value: $new_res\n";
    }
    if(exists($term->[1]->{Operator}) && $term->[1]->{Operator} eq "And"){
print "return and of $new_res and $result\n";
      return $new_res && $result;
    }
print "return or of $new_res and $result\n";
    if(exists($term->[1]->{Operator}) && $term->[1]->{Operator} eq "Or"){
      return $new_res || $result;
    }
print "return or of $new_res and $result (as default with no operator)\n";
    return $new_res || $result;
  }
}
sub ValidateElementInRequiredModule{
  my($this, $p, $ds, $sig, $errors) = @_;
  if($p->{item}->{attributes}->{Type} eq "1"){
    #  Type 1 element
#print "$sig is required element\n";
    my $match = $ds->Search($sig);
    unless(
      defined($match) &&
      ref($match) eq "ARRAY" &&
      (scalar @$match) > 0
    ){
      push @$errors,  "Type 1 element $sig not present";
    }
  } elsif(
     $p->{item}->{attributes}->{Type} eq "1C" &&
     exists($p->{item}->{attributes}->{NoCondition})
  ){
    #  Type 1C Element with "NoCondition":
    my $match = $ds->Search($sig);
    unless(
      defined($match) &&
      ref($match) eq "ARRAY" &&
      (scalar @$match) > 0
    ){
      push @$errors,  "Type 1C (NoCondition)  element $sig not present";
    }
  } elsif(
    $p->{item}->{attributes}->{Type} eq "1C" &&
    exists($p->{item}->{attributes}->{Condition})
  ){
    #  Type 1C Element with "Condition":
    my $condn = $p->{item}->{attributes}->{Condition};
#        print "$sig required if $condn: \n";
    my $res = $this->EvaluateCondition(
      $ds, $sig, $condn
    );
#print "Evalutated condition: ";
    if($res) {print "true\n"} else {print "false\n"}
    if($res) {
      my $m = $ds->Search($sig);
      unless(
        defined($m) &&
        ref($m) eq "ARRAY" &&
        (scalar @$m) > 0
      ){
        push @$errors,  
          "Type 1C ($condn) element $sig not present";
      }
    }
  }
}
sub SearchElementSpecifications{
  my($this, $IodExp, $ds, $errors) = @_;
  sig:
  for my $sig (sort keys %{$IodExp->{elements}}){
  #  First check if element spec is in sequence.  If so, sequence must
  #  actually occur in dataset...
  if($sig =~ /(.*)\[[^\]]*\]\(....,....\)$/){
      my $container = $1;
      my $m = $ds->Search($container);
      unless(
        defined($m) &&
        ref($m) eq "ARRAY" &&
        (scalar @$m) > 0
      ){ next sig}
    }
    ##  it either isn't in a sequence or its in an existing sequence...
#print "Validating $sig\n";
    if($sig =~ /^\(0002/) { next sig } # ignore meta-header stuff
    for my $p (@{$IodExp->{elements}->{$sig}->{ElementPresence}}){
      if($p->{module_attrs}->{Usage} eq "M"){
        $this->ValidateElementInRequiredModule($p, $ds, $sig, $errors);
        next sig;
      }
#print "Module not required: ";
#Debug::GenPrint($dbg, $p->{module_attrs}, 1);
#print "\n";
      if(exists $p->{module_attrs}->{Condition}){
        my $res = $this->EvaluateCondition(
          $ds, $sig, $p->{module_attrs}->{Condition}
        );
        print "Condition ($p->{module_attrs}->{Condition}) evaluates to $res\n";
        if($res){
          $this->ValidateElementInRequiredModule($p, $ds, $sig, $errors);
          next sig;
        }
      }
    }
  }
}
1;
