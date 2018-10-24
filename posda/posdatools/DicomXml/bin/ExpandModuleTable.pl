#!/usr/bin/perl -w 
#
#Copyright 2014, Bill Bennett
# Part of the Posda package
# Posda may be copied only under the terms of either the Artistic License or the
# GNU General Public License, which may be found in the Posda Distribution,
# or at http://posda.com/License.html
#
use strict;
use Socket;
use XML::Parser;
use Storable qw( fd_retrieve retrieve store_fd);
use Cwd;
use Debug;
my $dbg = sub { print STDERR @_ };
my $c_dbg = sub { print @_ };
unless($#ARGV == -1) {
  die "usage: ExpandModuleTable.pl\n" .
    "   no arguments - receives params from STDIN as Storable Obj:\n" .
    "     \$args = {\n" .
    "       doc => <document>,\n" .
    "       index => <xml_id_of_module_table>,\n" .
    "       tagstack => [],   #  Nesting of tags\n" .
    "                   # note: if not present, set to []\n" .
    "       lasttag => <tag>,\n" .
    "                   # note: if not present, set to undef\n" .
    "       depth => <n>,   #  Nesting of include\n" .
    "                   # note: if not present, set to -1\n" .
    "       mod_tables => [ <mod_table>, ...], # Nested module/macro tables\n" .
    "                   # note: if not present, set to [ <index> ]\n" .
    "     }\n" .
    "  Returns its result on STDOUT as Storable Obj:\n" .
    "    \$value = {\n" .
    "      tagstack => [],   #  Nesting of tags\n" .
    "      depth => <n>,   #  Nesting of last tag\n" .
    "      errors => [ <str>, ... ],   #  Error messages\n" .
    "      lasttag => <tag>,\n" .
    "      tags => [\n" .
    "        {\n" .
    "          elements => {\n" .
    "            <tag> => {\n" .
    "              desc => <description>\n" .
    "              name => <element_name>\n" .
    "              mod_tables => [<mod_table>, ...],\n" .
    "              req => <req>,\n" .
    "              usage => <usage>,\n" .
    "            }\n" .
    "          }\n" .
    "        }, ...\n" .
    "      ]\n" .
    "    };\n";
}
my $args = fd_retrieve(\*STDIN);
################################
#uncommment to log entries
#if(exists $args->{mod_tables}){
#  for my $i (0 .. $#{$args->{mod_tables}}){
#print STDERR "$args->{mod_tables}->[$i]:";
#  }
#}
#print STDERR "$args->{index}>>>>>>>>>>>>>\n";
#print STDERR "ExpandModuleTable.pl:\n";
#if(defined $args->{depth}){
#  print STDERR "  depth: $args->{depth}\n";
#} else {
#  print STDERR "  depth: <undef>\n";
#}
#if(defined $args->{lasttag}){
#  print STDERR "  lasttag: $args->{lasttag}\n";
#} else {
#  print STDERR "  lasttag: <undef>\n";
#}
#if(
#  exists $args->{tagstack} &&
#  ref($args->{tagstack}) eq "ARRAY" &&
#  $#{$args->{tagstack}} >= 0
#){
#  print STDERR "  tagstack: ";
#  for my $i (0 .. $#{$args->{tagstack}}){
#    print STDERR $args->{tagstack}->[$i];
#    unless($i == $#{$args->{tagstack}}){
#      print STDERR "[<$i>]";
#    }
#  }
#  print STDERR "\n";
#}
#################################
##uncomment for further logging
##if(
##  exists $args->{mod_tables} &&
##  ref($args->{mod_tables}) eq "ARRAY" &&
##  $#{$args->{mod_tables}} >= 0
##){
##  print STDERR "  mod_tables: ";
##  for my $i (0 .. $#{$args->{mod_tables}}){
##    print STDERR $args->{mod_tables}->[$i];
##    unless($i == $#{$args->{mod_tables}}){
##      print STDERR ":";
##    }
##  }
##  print STDERR "\n";
##}
#################################
my $doc = retrieve($args->{doc});
my $struct = $doc->{index}->{$args->{index}};

my @TagStack;
if(exists $args->{tagstack}){ @TagStack = @{$args->{tagstack}} }
my $Depth = -1;
if(exists $args->{depth}){ $Depth = $args->{depth} }
my @Errors;
my @ModTables;
if(exists $args->{mod_tables}){ @ModTables = @{$args->{mod_tables}} }
push @ModTables, $args->{index};
my %Tags;
my $LastTag;
if(exists $args->{lasttag}) { $LastTag = $args->{lasttag} }

sub Done{
#################################
#uncomment to log returns
#print STDERR "<<<<<<<<<<<<< $args->{index}";
#if(exists $args->{mod_tables}){
#  for my $i (0 .. $#{$args->{mod_tables}}){
#    print STDERR ":$args->{mod_tables}->[$#{$args->{mod_tables}} - $i]";
#  }
#}
#print STDERR "\n";
#print STDERR "  depth: $Depth\n";
#print STDERR "  lasttag: $LastTag\n";
#print STDERR "  tagstack: ";
#for my $i (0 .. $#TagStack){
#  print STDERR $TagStack[$i];
#  unless($i == $#TagStack){
#    print STDERR "[<$i>]";
#  }
#}
#print STDERR "\n";
#################################
  my $foo = {
    errors => \@Errors,
    tagstack => \@TagStack,
    depth => $Depth,
    lasttag => $LastTag,
    tags => \%Tags,
  };
  #print "Results: ";
  #Debug::GenPrint($c_dbg, $foo, 1, 8);
  #print "\n";
  store_fd ($foo, \*STDOUT);
  
}

unless($struct && ref($struct) eq "HASH"){
  push @Errors, "Can't find \"$args->{index} in $args->{doc}";
  Done;
}
unless(defined $struct->{el} && $struct->{el} eq "table") {
  push @Errors, "$args->{index} is not a table in $args->{doc}";
  Done;
}
my $pass1_result;
for my $i (@{$struct->{content}}){
  if(ref($i) eq "HASH"){
    if($i->{el} eq "caption"){
      my $caption = "";
      for my $j (@{$i->{content}}){
        $caption .= $j;
      }
      $caption =~ s/^\s*//;
      $caption =~ s/\s*$//;
      $pass1_result->{caption} = $caption;
    } elsif($i->{el} eq "thead"){
      my $rows = SemanticParseRows($i->{content}, "thead");
      if($#{$rows} != 0){
        print STDERR "thead doesn't have a single row\n";
        print STDERR "thead: ";
        Debug::GenPrint($dbg, $i, 1);
        print "\n";
      }
      $pass1_result->{thead} = $rows;
    } elsif($i->{el} eq "tbody"){
      my $rows = SemanticParseRows($i->{content}, "tbody");
      $pass1_result->{tbody} = $rows;
    } else {
    }
#    print "$i->{el}: ";
#    Debug::GenPrint($dbg, $i->{content}, 1);
#    print "\n";
  } else {
    unless($i =~ /^\s*$/s){
      print STDERR "text content in <table>: \"$i\"\n";
    }
  }
}
for my $row (@{$pass1_result->{tbody}}){
  my $tag = $row->[1];
  my $is_tag = !ref($tag) && $tag =~ /^\(....,....\)$/;
  if(!$is_tag) {
#################################
#uncomment for debug
#print STDERR "Not a tag: ";
#Debug::GenPrint($dbg, $row, 1);
#print STDERR "\n";
#################################
    if(
      ref($row->[0]) eq "ARRAY" &&
      $row->[0]->[0] =~ /^(>*)Include\s*$/
    ){
      my $depth = $Depth;
      if($1) {
#################################
#print STDERR "\$1: $1, Depth: $Depth, $row->[0]->[0] ($LastTag)\n";
#################################
        $depth = $depth + length($1)
      };
      if($depth > $#TagStack) {
#################################
#uncomment for debug
#if($LastTag eq ""){
#  die "LastTag is null";
#}
##print STDERR "Pushing Tagstack for $row->[0]->[0] ($LastTag, $args->{index})\n";
#################################
        push @TagStack, $LastTag;
      } elsif($depth < $#TagStack) { pop @TagStack }
        my $tab_id = $row->[0]->[1]->{attrs}->{linkend};

      ############# These tables cause problems ##########
      if($tab_id eq "table_8.8-1") {
        my $tables = "";
        for my $i (0 .. $#ModTables){
          $tables .= $ModTables[$i];
          unless($i == $#ModTables){ $tables .= ":" }
        }
        if(defined $LastTag){
          $tables .= " after $LastTag";
        }
        push @Errors, "Can't handle $tab_id (in $tables)";
        next;
      }
      if($tab_id eq "table_C.8.25.14-5"){    
        my $tables = "";
        for my $i (0 .. $#ModTables){
          $tables .= $ModTables[$i];
          unless($i == $#ModTables){ $tables .= ":" }
        }
        if(defined $LastTag){
          $tables .= " after $LastTag";
        }
        push @Errors, "Can't handle $tab_id (in $tables)";
        next;
      }
      if($tab_id eq $args->{index}){
        my $tables = "";
        for my $i (0 .. $#ModTables){
          $tables .= $ModTables[$i];
          unless($i == $#ModTables){ $tables .= ":" }
        }
        if(defined $LastTag){
          $tables .= " after $LastTag";
        }
        push @Errors, "Recursive inclusion of $tab_id (in $tables)";
        next;
      }
      ####################################################
      my $cmd = "ExpandModuleTable.pl";
      my $nargs = {
        doc => $args->{doc},
        index => $tab_id,
        tagstack => \@TagStack,
        depth => $depth,
        mod_tables => \@ModTables,
      };
################################
#uncomment for logging
#    print STDERR "Command: $cmd\n";
################################
      my($child, $child_pid) = ReadWriteChild($cmd);
      store_fd($nargs, $child);
      my $insert = fd_retrieve($child);
      unless(defined $LastTag){ $LastTag = $insert->{lasttag} }
################################
#uncomment to log recursive returns
#if(
#  exists $insert->{tagstack} &&
#  ref($insert->{tagstack}) eq "ARRAY" &&
#  $#{$insert->{tagstack}} >= 0
#){
#  print STDERR "  (returned) tagstack: ";
#  for my $i (0 .. $#{$insert->{tagstack}}){
#    print STDERR $insert->{tagstack}->[$i];
#    unless($i == $#{$insert->{tagstack}}){
#      print STDERR "[<$i>]";
#    }
#  }
#  print STDERR "\n";
#  print STDERR "   tagstack: ";
#  for my $i (0 .. $#TagStack){
#    print STDERR $TagStack[$i];
#    unless($i == $#TagStack){
#      print STDERR "[<$i>]";
#    }
#  }
#  print STDERR "\n";
#}
################################
      close $child;
      waitpid $child_pid, 0;
      for my $i (keys %{$insert->{tags}}){
        $Tags{$i} = $insert->{tags}->{$i};
      }
      for my $i (@{$insert->{errors}}){
        push @Errors, $i;
      }
    } else {
      if($row->[0] =~ /^(>*)(Any Attribute.*)$/){
        my $depth = $Depth;
        if($1){ $depth += length($1) }
        my $new_name = $2;
        ##############  Insert General Tag here ###################
        my $ttag = "";
        for my $i (0 .. $#TagStack){
         $ttag = $ttag . "$TagStack[$i]" . "[<$i>]";
        }
        if($depth > $#TagStack){
          unless($depth == $#TagStack + 1) {
            die "Indent increases by too much";
          }
          $ttag = $ttag .  "$LastTag";
        }
        $ttag .= "[0](gggg,eeee)";
        $Tags{$ttag} = {
          name => $new_name,
          req => $row->[1],
          desc => $row->[2],
          mod_tables => \@ModTables,
        };
        next;
      }
      die "no tag; no include";
    }
  } else {
    my $tag_name = $row->[0];
    $tag_name =~ /^(>*)([^>].*)$/;
    my $depth = $Depth;
    my $indent = $1;
    $tag_name = $2;
################################
#uncomment to print each processed tag
#print STDERR "Processing tag $indent$tag\n";
################################
    if($indent) { $depth = $depth + length($indent)  };
    if($depth > $#TagStack) {
################################
#uncomment to do extra nesting testing
#if(($depth - $#TagStack) > 1){
#  die "depth increases too much";
#}
#if($LastTag eq ""){
#  die "LastTag is null $args->{index}";
#}
################################
      push @TagStack, $LastTag;
    } elsif($depth < $#TagStack) {
      while($#TagStack > $depth){ pop @TagStack }
    }
    $LastTag = $tag;
    my $full_tag = "";
    for my $i (0 .. $#TagStack){
      $full_tag = $full_tag . "$TagStack[$i]" . "[<$i>]";
    }
    $full_tag = "$full_tag$tag";
    $full_tag =~ tr/A-F/a-f/;
    $Tags{$full_tag} = {
      name => $tag_name,
      req => $row->[2],
      desc => $row->[3],
      mod_tables => \@ModTables,
    };
  }
}
Done;
sub SemanticParseRows{
  my($c, $tag) = @_; my @result; for my $i (@$c){ unless(ref($i)){
      unless($i =~ /^\s*$/){
        print STDERR "text content in <$tag>: \"$i\"\n";
      }
      next;
    }
    unless(ref($i) eq "HASH") {
      my $badref = ref($i);
      die "Bad ref ($badref) in <$tag>\n";
    }
    unless($i->{el} eq "tr"){
      print STDERR "Bad element type $i->{el} in <$tag>\n";
      next;
    }
    push(@result, SemanticParseColumns($i->{content}));
  }
  return \@result;
}
sub SemanticParseColumns{
  my($c) = @_;
  my @result;
  for my $i (@$c){
    unless(ref($i)){
      unless($i =~ /^\s*$/){
        print STDERR "text content in <tr>: \"$i\"\n";
      }
      next;
    }
    unless(ref($i) eq "HASH") {
      my $badref = ref($i);
      die "Bad ref ($badref) in <tr>\n";
    }
    unless($i->{el} eq "th" || $i->{el} eq "td"){
      print STDERR "Bad element type $i->{el} in <tr>\n";
      next;
    }
    push(@result, SemanticParseCell($i->{content}));
  }
  return \@result;
}
sub SemanticParseCell{
  my($c) = @_;
  my @result;
  my $reduced = EliminateIndentation($c);;
  for my $i (@$reduced){
    my $r = SemanticParseCellItem($i);
    if($r){
      push(@result, $r);
    }
  }
  if($#result == 0) { return $result[0] }
  return \@result;
}
sub SemanticParseCellItem{
  my($h) = @_;
  unless(ref $h){
    unless(defined $h) {
      print STDERR "Undefined Cell Item\n";
      return undef;
    }
    if($h =~ /^\s*$/s) {
      print STDERR "Whitespace Cell Item\n";
      return undef;
    }
    return $h;
  }
  if($h->{el} eq "para") {
    return SemanticParsePara($h->{content});
  } elsif($h->{el} eq "variablelist"){
    return SemanticParseVl($h->{content});
  }
  return $h;
}
sub SemanticParsePara{
  my($c) = @_;
  unless(defined $c) { return undef }
  unless(ref($c) eq "ARRAY"){
    die "para content has ref other than ARRAY";
  }
  if($#{$c} == 0) { return SemanticParseParaItem($c->[0]) }
  my $d = EliminateIndentation($c);
  my @r;
  for my $i (@$d){
    my $pi = SemanticParseParaItem($i);
    if(defined($pi) && ref($pi) eq "ARRAY"){
      for my $j (@$pi) { push @r, $j }
    } elsif(defined $pi) { push @r, $pi }
  }
  if($#r < 0) { return undef }
  if($#r == 0) { return $r[0] }
  return \@r;
}
sub SemanticParseParaItem{
  my($i) = @_;
  unless(ref $i) { return $i }
  if(ref($i) eq "HASH"){
    if($i->{el} eq "emphasis"){
      my $ret = $i->{content};
      unless(defined $ret) { return undef }
      unless(ref($ret)) { return $ret }
      if(ref($ret) eq "ARRAY" && $#{$ret} == 0){ return $ret->[0] }
      return $ret;
    }
  }
  return $i;
}
sub SemanticParseVl{
  my($c) = @_;
  my $d = EliminateIndentation($c);
  my $var_list = { list => [], type => "variablelist" };
  for my $i (@$d) {
    unless(ref($i)) { die "text in varlist" }
    unless(ref($i) eq "HASH") { die "non HASH in varlist" }
    if($i->{el} eq "title"){
      $var_list->{title} = SemanticParseCell($i->{content});
    }
    if($i->{el} eq "varlistentry"){
      push(@{$var_list->{list}}, SemanticParseVarListEntry($i->{content}));
    }
  }
  return $var_list;
}
sub SemanticParseVarListEntry{
  my($i) = @_;
  unless(ref($i) && ref($i) eq "ARRAY") { die "VarListEntry has no content" }
  my $r = EliminateIndentation($i);
  unless($#{$r} == 1) { 
    die "VarListEntry should have two elements "
  }
  my $ent = [
    $r->[0]->{content}->[0],
    SemanticParseListItem($r->[1]->{content}),
  ];
  return $ent;
}
sub SemanticParseListItem{
  my($c) = @_;
  my $r = EliminateIndentation($c);
  if($#{$r} > 0) { die "ListItem has more than one element" }
  if($#{$r} < 0) { die "ListItem has no element" }
  return SemanticParsePara($r->[0]->{content});
}
sub EliminateIndentation{
  my($list) = @_;
  my @new_list;
  for my $i (@$list){
    unless(ref($i)){
      if($i =~ /^\s*$/s) { next }
    }
    push(@new_list, $i);
  }
  return \@new_list;
}
sub ReadWriteChild{
  my($cmd) = @_;
  my($child, $parent, $oldfh);
  socketpair($parent, $child, AF_UNIX, SOCK_STREAM, PF_UNSPEC) or
   die ("socketpair: $!");
  $oldfh = select($parent); $| = 1; select($oldfh);
  $oldfh = select($child); $| = 1; select($oldfh);
  my $child_pid = fork;
  unless(defined $child_pid) {
    die("couldn't fork: $!");
  }
  if($child_pid == 0){
    close $child;
    # these dies are not methods because they are in the child:
    unless(open STDIN, "<&", $parent){die "Redirect of STDIN failed: $!"}
    unless(open STDOUT, ">&", $parent){die "Redirect of STDOUT failed: $!"}
    exec $cmd;
    die "exec failed: $!";
  } else {
#    my $flags = fcntl($child, F_GETFL, 0);
#    $flags = fcntl($child, F_SETFL, $flags | O_NONBLOCK);
    close $parent;
  }
  return $child, $child_pid;
}
