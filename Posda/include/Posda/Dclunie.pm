#!/usr/bin/perl -w
#$Source: /home/bbennett/pass/archive/Posda/include/Posda/Dclunie.pm,v $
#$Date: 2012/02/07 13:41:44 $
#$Revision: 1.10 $
#
#Copyright 2009, Bill Bennett
# Part of the Posda package
# Posda may be copied only under the terms of either the Artistic License or the
# GNU General Public License, which may be found in the Posda Distribution,
# or at http://posda.com/License.html
#

package Posda::Dclunie;
use strict;
use Debug;
my $dbg = sub { print @_ };

#
#  Parse "elmdict/*.tpl" type tpl files
#
sub parse_dict_file{
  my $fn = shift;
  open FILE, "<", "$fn" or die "can't open $fn";
  my $list = shift;
  my $line_no = 0;
  while(my $line = <FILE>){
    chomp $line;
    $line_no += 1;
    if($line =~/^#/){ next }
    if($line =~ /^\s*$/) { next }
    unless($line =~ /^\((....),(....)\)(.*)$/){
      print "non-matching line: $line\n";
    }
    my %hash;
    $hash{grp} = $1;
    $hash{ele} = $2;
    $hash{file_ref} = "$fn:$line_no";
    my $remain = $3;
    unless($remain) { next }
    while($remain =~ /\s*([^\s=]+)=\"([^\"]+)\"(.*)$/){
      my $key = $1;
      my $value = $2;
      $remain = $3;
      $hash{$key} = $value;
    }
    unless($remain =~ /^\s*$/){
      die "leftover foo: $remain in line: $line\n";
    }
    push(@$list, \%hash);
  }
  return $list;
}
sub parse_dict{
  my $fh = shift;
  my @list;
  while(my $line = <$fh>){
    chomp $line;
    if($line =~/^#/){ next }
    if($line =~ /^\s*$/) { next }
    unless($line =~ /^\((....),(....)\)(.*)$/){
      print "non-matching line: $line\n";
    }
    my %hash;
    $hash{grp} = $1;
    $hash{ele} = $2;
    my $remain = $3;
    unless($remain) { next }
    while($remain =~ /\s*([^\s=]+)=\"([^\"]+)\"(.*)$/){
      my $key = $1;
      my $value = $2;
      $remain = $3;
      $hash{$key} = $value;
    }
    unless($remain =~ /^\s*$/){
      die "leftover foo: $remain in line: $line\n";
    }
    push(@list, \%hash);
  }
  return \@list;
}
sub dd_to_keywordhash {
  my $list = shift;
  my $hash;
  for my $entry (@$list){
    if(
      exists($entry->{Keyword}) 
    ){
      if(exists $hash->{$entry->{Keyword}}) {
        if(exists $entry->{Owner}){
#          print "Collision (private) for $entry->{Keyword}\n";
        } else {
          print "Collision (standard) for $entry->{Keyword}\n";
        }
      } else {
        unless(exists $entry->{Owner}){
          $hash->{$entry->{Keyword}} = $entry;
        }
      }
    }
  }
  return $hash;
}
#
#  Parse "module/*.tpl" type tpl files
#
sub parse_module_file{
  my $fn = shift;
  my $hash = shift;
  open FILE, "<", "$fn" or die "can't open $fn";
  my $prefix = [];
  my @prefix_stack;
  my $mode = "search";
  my $item_name;
  my $item = [];
  my $line_no = 0;
  my $macro_hash;
  my $module_hash;
  line:
  while(my $line = <FILE>){
    $line_no += 1;
    chomp $line;
    if($line =~ /^\s*$/) {next line}
    if($line =~ /^\s*#/) {next line}
    if($mode eq "search"){
      if($line =~/^\s*#/){
        next line;
      } elsif($line =~ /^\s*$/){
        next line;
      } elsif($line =~ /^\s*DefineMacro=\"([^\"]*)\"(.*)$/){
        $mode = "macro";
        $item_name = $1;
        my $remain = $2;
        $macro_hash = {
          attributes => parse_attributes($remain, $fn, $line_no),
          file_ref => "$fn:$line_no",
          name => $item_name,
          type => "macro",
        };
      } elsif($line =~ /^s*Module=\"([^\"]*)\"\s*$/){
        $mode = "module";
        $item_name = $1;
        my $remain = $2;
        $module_hash = {
          attributes => parse_attributes($remain, $fn, $line_no),
          file_ref => "$fn:$line_no",
          name => $item_name,
          type => "module",
        };
      }
    } elsif($mode eq "macro"){
      if($line =~ /^\s*MacroEnd/){
        $macro_hash->{items} = $item;
        $hash->{macros}->{$item_name} = $macro_hash;
        $mode = "search";
        $item = [];
        if($#{$prefix} >= 0){
          die "premature MacroEnd";
        }
      } elsif($line =~ /\s*Name=\"([^\"]*)\"(.*)$/){
        my $type = "ElementPresence";
        my $name = $1;
        my $remain = $2;
        my $hash = {
          type => $type,
          element_name => $name,
          attributes => parse_attributes($remain, $fn, $line_no),
          file_ref => "$fn:$line_no",
        };
        if($#{$prefix} >= 0){
          $hash->{prefix} = $prefix;
        }
        push(@$item, $hash);
      } elsif($line =~ /\s*Verify=\"([^\"]*)\"(.*)$/){
        my $type = "ElementVerification";
        my $name = $1;
        my $remain = $2;
        my $hash = {
          type => $type,
          element_name => $name,
          attributes => parse_attributes($remain, $fn, $line_no),
          file_ref => "$fn:$line_no",
        };
        if($#{$prefix} >= 0){
          $hash->{prefix} = $prefix;
        }
        push(@$item, $hash);
      } elsif($line =~ /\s*Sequence=\"([^\"]*)\"(.*)$/){
        my $type = "SequencePresence";
        my $name = $1;
        my $remain = $2;
        push(@prefix_stack, $prefix);
        $prefix = [@$prefix, $name];
        my $hash = {
          type => $type,
          element_name => $name,
          attributes => parse_attributes($remain, $fn, $line_no),
          file_ref => "$fn:$line_no",
        };
        push(@$item, $hash);
      } elsif($line =~ /\s*InvokeMacro=\"([^\"]*)\"(.*)$/){
        my $type = "MacroInvocation",
        my $name = $1;
        my $remain = $2;
        my $hash = {
          type => $type,
          macro_name => $name,
          attributes => parse_attributes($remain, $fn, $line_no),
          file_ref => "$fn:$line_no",
        };
        if($#{$prefix} >= 0){
          $hash->{prefix} = $prefix;
        }
        push(@$item, $hash);
      } elsif($line =~ /\s*SequenceEnd\s*$/){
        $prefix = pop(@prefix_stack);
      } else {
        print STDERR "Unparsable line ($fn: $line_no) in macro def: $line\n";
      }
    } elsif($mode eq "module"){
      if($line =~ /^\s*ModuleEnd/){
        $module_hash->{items} = $item;
        $hash->{modules}->{$item_name} = $module_hash;
        $module_hash = {};
        $mode = "search";
        $item = [];
        if($#{$prefix} >= 0){
          die "premature ModuleEnd";
        }
      } elsif($line =~ /\s*Name=\"([^\"]*)\"(.*)$/){
        my $type = "ElementPresence";
        my $name = $1;
        my $remain = $2;
        my $hash = {
          type => $type,
          element_name => $name,
          attributes => parse_attributes($remain, $fn, $line_no),
          file_ref => "$fn:$line_no",
        };
        if($#{$prefix} >= 0){
          $hash->{prefix} = $prefix;
        }
        push(@$item, $hash);
      } elsif($line =~ /\s*Verify=\"([^\"]*)\"(.*)$/){
        my $type = "ElementVerification";
        my $name = $1;
        my $remain = $2;
        my $hash = {
          type => $type,
          element_name => $name,
          attributes => parse_attributes($remain, $fn, $line_no),
          file_ref => "$fn:$line_no",
        };
        if($#{$prefix} >= 0){
          $hash->{prefix} = $prefix;
        }
        push(@$item, $hash);
      } elsif($line =~ /\s*Sequence=\"([^\"]*)\"(.*)$/){
        my $type = "SequencePresence";
        my $name = $1;
        my $remain = $2;
        my $hash = {
          type => $type,
          element_name => $name,
          attributes => parse_attributes($remain, $fn, $line_no),
          file_ref => "$fn:$line_no",
        };
        if($#{$prefix} >= 0){
          $hash->{prefix} = $prefix;
        }
        push(@prefix_stack, $prefix);
        $prefix = [@$prefix, $name];
        push(@$item, $hash);
      } elsif($line =~ /\s*InvokeMacro=\"([^\"]*)\"(.*)$/){
        my $type = "MacroInvocation",
        my $name = $1;
        my $remain = $2;
        my $hash = {
          type => $type,
          macro_name => $name,
          attributes => parse_attributes($remain, $fn, $line_no),
          file_ref => "$fn:$line_no",
        };
        if($#{$prefix} >= 0){
          $hash->{prefix} = $prefix;
        }
        push(@$item, $hash);
      } elsif($line =~ /\s*SequenceEnd\s*$/){
        $prefix = pop(@prefix_stack);
      } else {
        print STDERR "Unparsable line ($line_no) in macro def: $line\n";
      }
    }
  }
  return $hash;
}
sub parse_module{
  my $fh = shift;
  my $fn = "<unknown>";
  my $prefix = [];
  my @prefix_stack;
  my $mode = "search";
  my $item_name;
  my $item = [];
  my %Macros;
  my %Modules;
  my $line_no = 0;
  my $macro_hash;
  my $module_hash;
  line:
  while(my $line = <$fh>){
    $line_no += 1;
    chomp $line;
    if($line =~ /^\s*$/) {next line}
    if($line =~ /^\s*#/) {next line}
    if($mode eq "search"){
      if($line =~/^\s*#/){
        next line;
      } elsif($line =~ /^\s*$/){
        next line;
      } elsif($line =~ /^\s*DefineMacro=\"([^\"]*)\"(.*)$/){
        $mode = "macro";
        $item_name = $1;
        my $remain = $2;
        $macro_hash = {
          attributes => parse_attributes($remain, $fn, $line_no),
          line_no => $line_no,
        };
      } elsif($line =~ /^s*Module=\"([^\"]*)\"\s*$/){
        $mode = "module";
        $item_name = $1;
        my $remain = $2;
        $module_hash = {
          attributes => parse_attributes($remain, $fn, $line_no),
          line_no => $line_no,
        };
      }
    } elsif($mode eq "macro"){
      if($line =~ /^\s*MacroEnd/){
        $macro_hash->{items} = $item;
        $Macros{$item_name} = $macro_hash;
        $mode = "search";
        $item = [];
        if($#{$prefix} >= 0){
          die "premature MacroEnd";
        }
      } elsif($line =~ /\s*Name=\"([^\"]*)\"(.*)$/){
        my $type = "ElementPresence";
        my $name = $1;
        my $remain = $2;
        my $hash = {
          type => $type,
          element_name => $name,
          attributes => parse_attributes($remain, $fn, $line_no),
          line_no => $line_no,
        };
        if($#{$prefix} >= 0){
          $hash->{prefix} = $prefix;
        }
        push(@$item, $hash);
      } elsif($line =~ /\s*Verify=\"([^\"]*)\"(.*)$/){
        my $type = "ElementVerification";
        my $name = $1;
        my $remain = $2;
        my $hash = {
          type => $type,
          element_name => $name,
          attributes => parse_attributes($remain, $fn, $line_no),
          line_no => $line_no,
        };
        if($#{$prefix} >= 0){
          $hash->{prefix} = $prefix;
        }
        push(@$item, $hash);
      } elsif($line =~ /\s*Sequence=\"([^\"]*)\"(.*)$/){
        my $type = "SequencePresence";
        my $name = $1;
        my $remain = $2;
        push(@prefix_stack, $prefix);
        $prefix = [@$prefix, $name];
        my $hash = {
          type => $type,
          element_name => $name,
          attributes => parse_attributes($remain, $fn, $line_no),
          line_no => $line_no,
        };
        push(@$item, $hash);
      } elsif($line =~ /\s*InvokeMacro=\"([^\"]*)\"(.*)$/){
        my $type = "MacroInvocation",
        my $name = $1;
        my $remain = $2;
        my $hash = {
          type => $type,
          macro_name => $name,
          attributes => parse_attributes($remain, $fn, $line_no),
          line_no => $line_no,
        };
        if($#{$prefix} >= 0){
          $hash->{prefix} = $prefix;
        }
        push(@$item, $hash);
      } elsif($line =~ /\s*SequenceEnd\s*$/){
        $prefix = pop(@prefix_stack);
      } else {
        print "STDERR Unparsable line ($line_no) in macro def: $line\n";
      }
    } elsif($mode eq "module"){
      if($line =~ /^\s*ModuleEnd/){
        $module_hash->{items} = $item;
        $Modules{$item_name} = $module_hash;
        $module_hash = {};
        $mode = "search";
        $item = [];
        if($#{$prefix} >= 0){
          die "premature ModuleEnd";
        }
      } elsif($line =~ /\s*Name=\"([^\"]*)\"(.*)$/){
        my $type = "ElementPresence";
        my $name = $1;
        my $remain = $2;
        my $hash = {
          type => $type,
          element_name => $name,
          attributes => parse_attributes($remain, $fn, $line_no),
          line_no => $line_no,
        };
        if($#{$prefix} >= 0){
          $hash->{prefix} = $prefix;
        }
        push(@$item, $hash);
      } elsif($line =~ /\s*Verify=\"([^\"]*)\"(.*)$/){
        my $type = "ElementVerification";
        my $name = $1;
        my $remain = $2;
        my $hash = {
          type => $type,
          element_name => $name,
          attributes => parse_attributes($remain, $fn, $line_no),
          line_no => $line_no,
        };
        if($#{$prefix} >= 0){
          $hash->{prefix} = $prefix;
        }
        push(@$item, $hash);
      } elsif($line =~ /\s*Sequence=\"([^\"]*)\"(.*)$/){
        my $type = "SequencePresence";
        my $name = $1;
        my $remain = $2;
        push(@prefix_stack, $prefix);
        $prefix = [@$prefix, $name];
        my $hash = {
          type => $type,
          element_name => $name,
          attributes => parse_attributes($remain, $fn, $line_no),
          line_no => $line_no,
        };
        if($#{$prefix} >= 0){
          $hash->{prefix} = $prefix;
        }
        push(@$item, $hash);
      } elsif($line =~ /\s*InvokeMacro=\"([^\"]*)\"(.*)$/){
        my $type = "MacroInvocation",
        my $name = $1;
        my $remain = $2;
        my $hash = {
          type => $type,
          element_name => $name,
          attributes => parse_attributes($remain, $fn, $line_no),
          line_no => $line_no,
        };
        if($#{$prefix} >= 0){
          $hash->{prefix} = $prefix;
        }
        push(@$item, $hash);
      } elsif($line =~ /\s*SequenceEnd\s*$/){
        $prefix = pop(@prefix_stack);
      } else {
        print STDERR "Unparsable line ($line_no) in macro def: $line\n";
      }
    }
  }
  return { macros => \%Macros, modules => \%Modules };
}
sub parse_attributes{
  my $text = shift;
  my $remain = $text;
  my $file = shift;
  my $line_no = shift;
  my $hash = {};
  while($remain){
    if($remain =~ /^\s*([^=]*)=\"([^\"]*)\"(.*)$/){
      my $key = $1;
      my $value = $2;
      $remain = $3;
      if(exists $hash->{$key}){
        print STDERR "Duplicate key ($key)\n";
        next;
      }
      $hash->{$key} = $value;
    } elsif($remain =~ /^\s*#(.*)$/){
      $hash->{comment} = $1;
      $remain = "";
    } elsif($remain =~ /^\s*$/){
      $remain = "";
    } else {
      print STDERR "unparsable attribute part ($file: $line_no): $text\n";
      print STDERR "Remaining: $remain\n";
      $remain = "";
    }
  }
  return $hash;
}
sub get_ele_sig{
  my($dd, $prefix, $name, $index) = @_;

  unless(defined $index){$index = 0}
  my @prefix;
  if(defined $prefix && ref($prefix) eq "ARRAY" && $#{$prefix} >= 0){
    @prefix = @$prefix;
  }
  unless($#prefix >= 0){
    unless(defined $dd->{$name}->{grp} && defined $dd->{$name}->{ele}){
      die "undefined dd entry for $name";
    }
    my $ret = ("($dd->{$name}->{grp},$dd->{$name}->{ele})");
    $ret =~ tr/A-F/a-f/;
    return $ret;
  }
  my $first = shift @prefix;
  my $ret = "($dd->{$first}->{grp},$dd->{$first}->{ele})[<$index>]" .
    get_ele_sig($dd, \@prefix, $name, $index+1);
  $ret =~ tr/A-F/a-f/;
  return $ret;
}
sub get_specific_sig{
  my($dd, $ele_name) = @_;
  if($ele_name =~ /^([^\]]+)(\[[^\]]+\])(.*)$/){
    my $seq = $1;
    my $index = $2;
    my $remain = $3;
    unless(exists $dd->{$seq}) { die "unknown sequence $seq" }
    my $sig = get_ele_sig($dd, [], $seq);
    return "$sig$index" . get_specific_sig($dd, $remain);
  } else {
    unless(exists $dd->{$ele_name}) { die "unknown element_name $ele_name" }
    return get_ele_sig($dd, [], $ele_name);
  }
}
#
#  Parse "iodcomp/*.tpl" type tpl files
#
sub parse_iod_file{
  my $fn = shift;
  my $hash = shift;
  open FILE, "<", "$fn" or die "can't open $fn";
  my $line_no = 0;
  my $state = "Search";
  my $currentIE;
  my $iod_name;
  while(my $line = <FILE>){
    $line_no += 1;
    chomp $line;
    if($line =~ /^\s*#/) {next}
    if($line =~ /^\s*$/) {next}
    if($state eq "Search"){
      if($line =~ /^CompositeIOD=\"([^\"]+)\"\s*(.*)$/){
        $iod_name = $1;
        my $remain = $2;
        if(exists $hash->{$iod_name}) {
           print STDERR "redefining iod: $iod_name"
        }
        $hash->{$iod_name} = {
          name => $iod_name,
          attributes => parse_attributes($remain, $fn, $line_no),
          information_entities => {},
          file_ref => "$fn:$line_no",
        };

        $state = "InIOD";
      } else {
        die "unparsable line: \"$line\" in " .
          "state $state in parse_iod_file: $fn, line $line_no";
      }
    } elsif($state eq "InIOD"){
      if($line =~ /^\s*InformationEntity=\"([^\"]+)\"\s*$/){
        $currentIE = $1;
        $state = "InIE";
        $hash->{$iod_name}->{information_entities}->{$currentIE}->{file_ref} = 
          "$fn:$line_no";
        $hash->{$iod_name}->{information_entities}->{$currentIE}->{name} = 
          $currentIE;
      } elsif ($line =~ /^\s*CompositeIODEnd\s*$/){
        $state = "Search";
      } else {
        die "unparsable line: \"$line\" in " .
          "state $state in parse_iod_file: $fn, line $line_no";
      }
    } elsif($state eq "InIE"){
      if($line =~ /^\s*Module=\"([^\"]+)\"\s*(.*)$/){
        my $module_name = $1;
        my $remain = $2;
        $hash->{$iod_name}->{information_entities}->{$currentIE}->{modules}->{$module_name} = {
          file_ref => "$fn:$line_no",
          attributes => parse_attributes($remain, $fn, $line_no),
        };
      } elsif ($line =~ /^\s*InformationEntityEnd\s*$/){
        $state = "InIOD";
      } else{
        die "unparsable line: \"$line\" in " .
          "state $state in parse_iod_file: $fn, line $line_no";
      }
    } else {
      die "Invalid state: $state";
    }
  }
  unless($state eq "Search"){die "wrong state: $state at end of file $fn"};
}
#
#  Parse "sopcl.tpl" file
#
sub parse_sopcl_file{
  my $fn = shift;
  my %hash;
  my $line_no = 0;
  open FILE, "<", "$fn" or die "can't open $fn";
  while(my $line = <FILE>){
    $line_no += 1;
    chomp $line;
    if($line =~ /^\s*#/) { next }
    if($line =~ /^\s*$/) { next }
    if($line =~ /^\s*DirectoryRecord=\"([^\"]*)\"\s*Name=\"([^\"]*)\"(.*)$/){
      my $dir_rec = $1;
      my $name = $2;
      my $remain = $3;
      my $attrs = parse_attributes($remain, $fn, $line_no);
      unless(exists $attrs->{Type}){
        $attrs->{Type} = "Class";
      }
      $attrs->{DirectoryRecord} = $dir_rec;
      $hash{$name} = $attrs;
    } elsif($line =~ /^\s*Type=\"([^\"]*)\"\s*Name=\"([^\"]*)\"(.*)$/){
      my $type = $1;
      my $name = $2;
      my $remain = $3;
      my $attrs = parse_attributes($remain, $fn, $line_no);
      $attrs->{Type} = $type;
      $hash{$name} = $attrs;
    } elsif( $line =~ /^\s*Name=\"([^\"]*)\"(.*)$/){
      my $name = $1;
      my $remain = $2;
      my $attrs = parse_attributes($remain, $fn, $line_no);
      unless(exists $attrs->{Type}){
        $attrs->{Type} = "Class";
      }
      $hash{$name} = $attrs;
    } else {
      die "unparsable line: \"$line\" in " .
        "parse_sopcl_file: $fn, line $line_no";
    }
  }
  return \%hash;
}
#
#  Parse "transyn.tpl" file
#
sub parse_transyn_file{
  my $fn = shift;
  my %hash;
  my $line_no = 0;
  open FILE, "<", "$fn" or die "can't open $fn";
  while(my $line = <FILE>){
    chomp $line;
    $line_no += 1;
    if($line =~ /^\s*#/) { next }
    if($line =~ /^\s*$/) { next }
    if($line =~ /^\s*Name=\"([^\"]*)\"(.*)$/){
      my $name = $1;
      my $remain = $2;
      my $attrs = parse_attributes($remain);
      $hash{$name} = $attrs;
    } else {
      die "unparsable line: \"$line\" in " .
        "parse_transyn_file: $fn, line $line_no";
    }
  }
  return \%hash;
}
#
#  Parse "tagval.tpl" file
#
sub parse_tagval_file{
  my $fn = shift;
  my %hash;
  my $mode = "Search";
  my $line_no = 0;
  my $tag_name;
  my $h;
  open FILE, "<", "$fn" or die "can't open strval file: $fn";
  while(my $line = <FILE>){
    $line_no += 1;
    chomp $line;
    if($line =~ /^\s*#/) { next }
    if($line =~ /^\s*$/) { next }
    if($mode eq "Search"){
      if($line =~ /^\s*TagValues\s*=\s*\"([^\"]*)\"\s*{\s*$/){
        $tag_name = $1;
        $h = {};
        $mode = "InDef";
      } else {
        die "can't parse line: \"$line\" at line $line_no of $fn";
      }
    } elsif($mode eq "InDef"){
      if($line =~ /^\s*}\s*$/){
        $hash{$tag_name} = $h;
        $h = {};
        $mode = "Search";
      } elsif($line =~ /^\s*0x(....),0x(....) = (.*),\s*$/) {
        my $grp = $1;
        my $ele = $2;
        my $desc = $3;
        $h->{"($grp,$ele)"} = $desc;
      } elsif($line =~ /^\s*0x(....),0x(....) = (.*)\s*$/) {
        my $grp = $1;
        my $ele = $2;
        my $desc = $3;
        $h->{"($grp,$ele)"} = $desc;
      } else {
        die "can't parse line: \"$line\" at line $line_no of $fn";
      }
    } else {
      die "invalid state: $mode at line $line_no of $fn";
    }
  }
  unless($mode eq "Search") { die "invalid state: $mode at EOF in $fn" }
  return \%hash;
}
#
#  Parse "strval.tpl" file
#
sub parse_strval_file{
  my $fn = shift;
  my $hash = shift;
  open FILE, "<", "$fn" or die "can't open strval file: $fn";
  my $mode = "Search";
  my $line_no = 0;
  my $str_name;
  my $h;
  while(my $line = <FILE>){
    $line_no += 1;
    chomp $line;
    if($line =~ /^\s*#/) { next }
    if($line =~ /^\s*$/) { next }
    if($mode eq "Search"){
      if($line =~ /\s*StringValues=\"([^"]*)\"\s*{\s*$/){
        $str_name = $1;
        $h = {};
        $mode = "InDef";
      } else {
        die "Can't parse line \"$line\" at $line_no in $fn ($mode)";
      }
    } elsif ($mode eq "InDef"){
      if($line =~ /^\s*}\s*$/){
        $hash->{$str_name} = $h;
        $h = {};
        $mode = "Search";
      } elsif ($line =~ /^\s*([^\s]+),\s*$/){
        my $key = $1;
        my $value = "<undef>";
        $h->{$key} = $value;
      } elsif ($line =~ /^\s*([^\s]+)\s*$/){
        my $key = $1;
        my $value = "<undef>";
        $h->{$key} = $value;
      } elsif ($line =~ /^\s*([^\s]+)\s*= (.*),\s*$/){
        my $key = $1;
        my $value = $2;
        $h->{$key} = $value;
      } elsif ($line =~ /^\s*([^\s]+)\s*= (.*)\s*$/){
        my $key = $1;
        my $value = $2;
        $h->{$key} = $value;
      } elsif ($line =~ /^\s*(.*)\s*$/){
        my $key = $1;
        my $value = "<undef>";
        $h->{$key} = $value;
      } else {
        die "Can't parse line \"$line\" at $line_no in $fn ($mode)";
      }
    } else {
      die "invalid state: $mode at line $line_no of $fn";
    }
  }
  unless($mode eq "Search") { die "invalid state: $mode at EOF in $fn" }
}
#
#  Parse "binval.tpl" file
#
sub parse_binval_file{
  my $fn = shift;
  my %binval;
  my %bitmap;
  my $mode = "Search";
  my $line_no = 0;
  my $val_name;
  my $h;
  open FILE, "<", "$fn" or die "can't open strval file: $fn";
  while(my $line = <FILE>){
    $line_no += 1;
    chomp $line;
    if($line =~ /^\s*#/) { next }
    if($line =~ /^\s*$/) { next }
    if($mode eq "Search"){
      if($line =~ /\s*BinaryValues=\"([^"]*)\"\s*{\s*$/){
        $val_name = $1;
        $mode = "InValueDef";
      } elsif($line =~ /\s*BinaryBitMap=\"([^"]*)\"\s*{\s*$/){
        $val_name = $1;
        $mode = "InMapDef";
      } else {
        die "Can't parse line \"$line\" at $line_no in $fn ($mode)";
      }
    } elsif ($mode eq "InValueDef"){
      if($line =~ /^\s*}\s*$/){
        $mode = "Search";
      } elsif($line =~ /^\s*0x(....),\s*$/){
      } elsif($line =~ /^\s*0x(....)\s*$/){
      } elsif($line =~ /^\s*0x(....) =\s*(.*),$/){
      } else {
        die "Can't parse line \"$line\" at $line_no in $fn ($mode)";
      }
    } elsif ($mode eq "InMapDef"){
      if($line =~ /^\s*}\s*$/){
        $mode = "Search";
      } elsif($line =~ /^$/){
      } else {
        die "Can't parse line \"$line\" at $line_no in $fn ($mode)";
      }
    } else {
      die "invalid state: $mode at line $line_no of $fn";
    }
  }
  unless($mode eq "Search") { die "invalid state: $mode at EOF in $fn" }
  return { binval => \%binval, bitmap => \%bitmap };
}
#
#  Parse "condn.tpl" file
#
sub parse_condn_file{
  my $fn = shift;
  my $hash = shift;
  open FILE, "<", "$fn" or die "can't open $fn";
  my $line_no = 0;
  my $state = "Search";
  my $cond_name;
  my @stack;
  my $current_list;
  while(my $line = <FILE>){
    $line_no += 1;
    chomp $line;
    if($line =~ /^\s*$/){next}
    if($line =~ /^\s*#/){next}
    if($state eq "Search"){
      if($line =~ /^\s*Condition=\"([^\"]*)\"\s*$/){
        $cond_name = $1;
        $state = "InCond";
        $current_list = [];
      } else {
        die "can't parse condition line: \"$line\" at $fn:$line_no"
      }
    } elsif($state eq "InCond"){
      if($line =~ /^\s*ConditionEnd/){
        $state = "Search";
        $hash->{$cond_name} = $current_list;
        $cond_name = "";
        $current_list = [];
      } elsif($line =~ /\s*Element=\"([^\"]*)\"(.*)$/) {
        my $ele = $1;
        my $remain = $2;
        push(@$current_list, [$ele, parse_attributes($remain)]);
      } elsif($line =~ /\s*\(\s*$/) {
        push @stack, $current_list;
        $current_list = [];
      } elsif($line =~ /\s*\)(.*)$/) {
        my $remain = $1;
        my $intermediate = $current_list;
        $current_list = pop(@stack);
        push @$current_list, [$intermediate, parse_attributes($remain)];
      } else {
        die "can't parse condition line \"$line\" at $fn:$line_no"
      }
    } else {
      die "can't parse condition line \"$line\" at $fn:$line_no"
    }
  }
  unless($state eq "Search"){ die "invalid state: $state at end of file $fn" }
  return $hash;
}

#
#  Stuff related to expanding an IOD definition
#
sub ExpandAnElementPresence{
  my($item, $module, $mod_attrs, $macros,
     $dd, $ie, $iod, $prefix, $m_chain, $hash) = @_;
  if(exists $item->{prefix}) {$prefix = [@$prefix, @{$item->{prefix}}]}
  my $ele_def = $dd->{$item->{element_name}};
  my $ele_vm = $ele_def->{VM};
  my $vr = $ele_def->{VR};
  my $Name = $ele_def->{Name};
  my $sig = get_ele_sig($dd, $prefix, $item->{element_name});
  push(@{$hash->{elements}->{$sig}->{ElementPresence}}, {
    item => $item,
    name => $Name,
    vr => $vr,
    vm => $ele_vm,
    module => $module->{name},
    module_attrs => $mod_attrs,
    module_file_ref => $module->{file_ref},
    ie => $ie->{name},
    ie_fileref => $ie->{file_ref},
    iod => $iod->{name},
    macro_chain => $m_chain,
    iod_attrs => $iod->{attributes},
    iod_file_ref => $iod->{file_ref},
  });
}
sub ExpandAnElementVerification{
  my($item, $module, $mod_attrs, $macros,
     $dd, $ie, $iod, $prefix, $m_chain, $hash) = @_;
  if(exists $item->{prefix}) {$prefix = [@$prefix, @{$item->{prefix}}]}
  my $ele_def = $dd->{$item->{element_name}};
  my $ele_vm = $ele_def->{VM};
  my $vr = $ele_def->{VR};
  my $Name = $ele_def->{Name};
  my $sig = get_ele_sig($dd, $prefix, $item->{element_name});
  push(@{$hash->{elements}->{$sig}->{ElementVerification}}, {
    item => $item,
    name => $Name,
    vr => $vr,
    vm => $ele_vm,
    module => $module->{name},
    module_file_ref => $module->{file_ref},
    module_attrs => $mod_attrs,
    ie => $ie->{name},
    ie_fileref => $ie->{file_ref},
    iod => $iod->{name},
    macro_chain => $m_chain,
    iod_attrs => $iod->{attributes},
    iod_file_ref => $iod->{file_ref},
  });
}
sub ExpandASequencePresence{
  my($item, $module, $mod_attrs, $macros,
     $dd, $ie, $iod, $prefix, $m_chain, $hash) = @_;
  if(exists $item->{prefix}) {$prefix = [@$prefix, @{$item->{prefix}}]}
  my $ele_def = $dd->{$item->{element_name}};
  my $ele_vm = $ele_def->{VM};
  my $vr = $ele_def->{VR};
  my $Name = $ele_def->{Name};
  my $sig = get_ele_sig($dd, $prefix, $item->{element_name});
  push(@{$hash->{elements}->{$sig}->{ElementPresence}}, {
    item => $item,
    name => $Name,
    vr => $vr,
    vm => $ele_vm,
    module => $module->{name},
    module_file_ref => $module->{file_ref},
    module_attrs => $mod_attrs,
    ie => $ie->{name},
    ie_fileref => $ie->{file_ref},
    iod => $iod->{name},
    macro_chain => $m_chain,
    iod_attrs => $iod->{attributes},
    iod_file_ref => $iod->{file_ref},
  });
}
sub ExpandAMacro{
  my($m_item, $module, $mod_attrs, $macros,
     $dd, $ie, $iod, $prefix, $m_chain, $hash) = @_;
  unless(defined $mod_attrs) {$mod_attrs = {};}
  if(exists $m_item->{prefix}) {$prefix = [@$prefix, @{$m_item->{prefix}}]}
  unless(defined $macros->{$m_item->{macro_name}}){
    die "undefined macro: $m_item->{macro_name}"
  }
  my $mod_exp = $macros->{$m_item->{macro_name}};
  for my $item (@{$mod_exp->{items}}){
    if(exists $item->{macro_name}){
      for my $hist (@$m_chain){
        if($item->{macro_name} eq $hist->{macro_name}){
          print "ignoring recursive macro invocation of $item->{macro_name}\n";
          return;
        }
      }
    }
    if($item->{type} eq "ElementPresence"){
      ExpandAnElementPresence(
        $item, $module, $mod_attrs, $macros, 
        $dd, $ie, $iod, $prefix, $m_chain, $hash
      );
    } elsif($item->{type} eq "SequencePresence"){
      ExpandASequencePresence(
        $item, $module, $mod_attrs, $macros, 
        $dd, $ie, $iod, $prefix, $m_chain, $hash
      );
    } elsif($item->{type} eq "ElementVerification"){
      ExpandAnElementVerification(
        $item, $module, $mod_attrs, $macros, 
        $dd, $ie, $iod, $prefix, $m_chain, $hash
      );
    } elsif($item->{type} eq "MacroInvocation"){
      ExpandAMacro(
        $item, $module, $mod_attrs, $macros, 
        $dd, $ie, $iod, $prefix, $m_chain, $hash
      );
    } else {
      die "unknown item type $item->{type} in module $module->{name}"
    }
  }
}

sub ExpandAModule{
  my($module, $mod_attrs, $macros, $dd, 
    $ie, $iod, $prefix, $m_chain, $hash) = @_;
  for my $item (@{$module->{items}}){
    if(exists $item->{macro_name}){
      for my $hist (@$m_chain){
        if($item->{macro_name} eq $hist->{macro_name}){
          print "ignoring recursive macro invocation of $item->{macro_name}\n";
          return;
        }
      }
    }
    if($item->{type} eq "ElementPresence"){
      ExpandAnElementPresence(
        $item, $module, $mod_attrs, $macros, 
        $dd, $ie, $iod, $prefix, $m_chain, $hash
      );
    } elsif($item->{type} eq "SequencePresence"){
      ExpandASequencePresence(
        $item, $module, $mod_attrs, $macros, 
        $dd, $ie, $iod, $prefix, $m_chain, $hash
      );
    } elsif($item->{type} eq "ElementVerification"){
      ExpandAnElementVerification(
        $item, $module, $mod_attrs, $macros, 
        $dd, $ie, $iod, $prefix, $m_chain, $hash
      );
    } elsif($item->{type} eq "MacroInvocation"){
      ExpandAMacro(
        $item, $module, $mod_attrs, $macros, 
        $dd, $ie, $iod, $prefix, [$item, @$m_chain], $hash
      );
    } else {
      die "unknown item type $item->{type} in module $module->{name}"
    }
  }
}

sub ExpandAnIod {
  my($iod, $modules, $macros, $dd) = @_;
  my $hash = {};
  $hash->{attributes} = $iod->{attributes};
  $hash->{file_ref} = $iod->{file_ref};
  $hash->{name} = $iod->{name};
  for my $ie_name (keys %{$iod->{information_entities}}){
    my $ie = $iod->{information_entities}->{$ie_name};
    for my $module_name (keys %{$ie->{modules}}){
       my $module = $modules->{$module_name};
       ExpandAModule($module, $ie->{modules}->{$module_name}->{attributes},
         $macros, $dd, $ie, $iod, [], [], $hash);
    }
  }
  return $hash;
}

1;
