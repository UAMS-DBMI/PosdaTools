#!/usr/bin/perl -w 
#
#Copyright 2008, Bill Bennett
# Part of the Posda package
# Posda may be copied only under the terms of either the Artistic License or the
# GNU General Public License, which may be found in the Posda Distribution,
# or at http://posda.com/License.html
#
use strict;
package Posda::Dvtk;
sub parse_define_system{
  my($this, $fh) = @_;
  while(my $line = <$fh>){
    chomp $line;
    $line =~ s/\r//g;
    if($line =~ /^\s*\"DICOM\"\s+\"3.0\"\s*$/){ next }
    if($line =~ /^\s*ENDDEFINE\s*$/) {
      my $value = {
        protocol => "DICOM",
        version => "3.0",
      };
      return $value;
    }
    die "Unknown SYSTEM line: '$line'\n";
  }
}
sub parse_define_object{
  my($this, $fh) = @_;
  my($module, $module_req, $mod_cond);
  while(my $line = <$fh>){
    chomp $line;
    $line =~ s/\r//g;
    if($line =~ /^\s*$/) { next }
    if($line =~ /^\s*#/) { next }
    if($line =~/^\s*ENDDEFINE\s*$/){
      return
    } elsif($line =~ /\s*SOPCLASS\s*\"([^\"]+)\"\s*\s\"([^\"]+)\"\s*$/){
      my $SopUID = $1;
      my $SopName = $2;
      $this->{SopClassUid} = $SopUID;
      $this->{SopClassName} = $SopName;
    } elsif($line =~ /\s*MODULE\s*"([^\"]+)\"\s*(\S*)\s*$/){
      $module = $1;
      $module_req = $2;
      $mod_cond = undef;
    } elsif($line =~ /\s*MODULE\s*"([^\"]+)\"\s*(\S*)\s*:\s*\"([^\"]+)\"\s*$/){
      $module = $1;
      $module_req = $2;
      $mod_cond = $3;
    } elsif($line =~ /\s*MODULE\s*"([^\"]+)\"\s*(\S*)\s*:\s*(.*)\s*$/){
      $module = $1;
      $module_req = $2;
      $mod_cond = $3;
    } elsif($line =~ /\s*INCLUDEMACRO\s*"([^\"]+)\"\s*$/){
      my $m_name = $1;
      push(@{$this->{includes}}, $m_name);
    } elsif($line =~ /\s*INCLUDEMACRO\s*"([^\"]+)\"\s*:\s*(.*)\s*$/){
      my $m_name = $1;
      push(@{$this->{includes}}, $m_name);
    } elsif(
      $line =~
        /^\s*\(0x(....)(....),(.*),(.*),(.*)\)\s*\"([^\"]+)\"\s*:\s*(.*)$/
    ){
      my $grp = $1;
      my $ele = $2;
      my $type = $3,
      my $vr = $4;
      my $vm = $5;
      my $name = $6;
      my $condition = $7;
      $this->{elements}->{"($grp,$ele)"} = {
        type => $type,
        vr => $vr,
        vm => $vm,
        name => $name,
        condition => $condition,
        module => {
          name => $module,
          req => $module_req,
        },
      };
    } elsif(
      $line =~
        /^\s*\(0x(....)(....),(.*),(.*),(.*)\)\s*\"([^\"]+)\"\s*$/
    ){
      my $grp = $1;
      my $ele = $2;
      my $type = $3,
      my $vr = $4;
      my $vm = $5;
      my $name = $6;
      $this->{elements}->{"($grp,$ele)"} = {
        type => $type,
        vr => $vr,
        vm => $vm,
        name => $name,
        module => {
          name => $module,
          req => $module_req,
        },
      };
    } elsif(
      $line =~
        /^\s*\(0x(....)(....),(.*),(.*),(.*),([DE]L?),([^\),]*)$/
    ){
      my $grp = $1;
      my $ele = $2;
      my $type = $3;
      my $vr = $4;
      my $vm = $5;
      my $et = $6;
      my $en = $7;
      $this->{elements}->{"($grp,$ele)"} = {
        type => $type,
        vr => $vr,
        vm => $vm,
        module => {
          name => $module,
          req => $module_req,
        },
        enumeration_type => "$et",
      };
      my($net, $values, $remain) = read_value_line($fh, "$et,$en", $vm);
      $this->{elements}->{"($grp,$ele)"}->{enumeration_type} = $net;
      $this->{elements}->{"($grp,$ele)"}->{values} = $values;
      if($remain =~ /\s*"([^"]+)"\s*:\s*(.*)\s*$/){
        $this->{elements}->{"($grp,$ele)"}->{name} = $1;
        $this->{elements}->{"($grp,$ele)"}->{condition} = $2;
      } elsif($remain =~ /\s*"([^"]+)"\s*$/){
        $this->{elements}->{"($grp,$ele)"}->{name} = $1;
      } else {
        $this->{elements}->{"($grp,$ele)"}->{error_foo} = 
          "Whattiz";
      }
      #print "values: $values\nremain: $remain\n*********\n";
    } elsif(
      $line =~
        /^\s*\(0x(....)(....),(.*),(.*),(.*),([DE]L?),([^\)]*)\)\s*(.*)\s*$/
    ){
      my $grp = $1;
      my $ele = $2;
      my $type = $3;
      my $vr = $4;
      my $vm = $5;
      my $et = $6;
      my $values = $7;
      my $remain = $8;
      $this->{elements}->{"($grp,$ele)"} = {
        type => $type,
        vr => $vr,
        vm => $vm,
        module => {
          name => $module,
          req => $module_req,
        },
        enumeration_type => "$et",
        values => $values,
        remain123 => $remain,
      };
      #print "values: $values\nremain: $remain\n*********\n";
    } elsif(
      $line =~
        /^\s*\(0x(....)(....),(.*),(.*),(.*),([DE]L?),([^\),]*)$/
    ){
      my $grp = $1;
      my $ele = $2;
      my $type = $3;
      my $vr = $4;
      my $vm = $5;
      my $et = $6;
      my $en = $7;
      $this->{elements}->{"($grp,$ele)"} = {
        type => $type,
        type => $type,
        vr => $vr,
        vm => $vm,
        module => {
          name => $module,
          req => $module_req,
        },
        enumeration_type => "$et",
      };
      my($net, $values, $remain) = read_value_line($fh, "$et,$en", $vm);
      $this->{elements}->{"($grp,$ele)"}->{enumeration_type} = $net;
      $this->{elements}->{"($grp,$ele)"}->{values} = $values;
      if($remain =~ /\s*"([^"]+)"\s*:\s*"([^"]+)\s*$/){
        $this->{elements}->{"($grp,$ele)"}->{name} = $1;
        $this->{elements}->{"($grp,$ele)"}->{condition} = $1;
      } elsif($remain =~ /\s*"([^"]+)"\s*$/){
        $this->{elements}->{"($grp,$ele)"}->{name} = $1;
      }
      $this->{elements}->{"($grp,$ele)"}->{remain} = $remain;
    } elsif(
      $line =~
        /^\s*\(0x(....)(....),(.*),(.*),(.*),([DE]L?),([^\)]*)\)\s*(.*)\s*$/
    ){
      my $grp = $1;
      my $ele = $2;
      my $type = $3;
      my $vr = $4;
      my $vm = $5;
      my $et = $6;
      my $values = $7;
      my $remain = $7;
      $this->{elements}->{"($grp,$ele)"} = {
        type => $type,
        vr => $vr,
        vm => $vm,
        module => {
          name => $module,
          req => $module_req,
        },
        enumeration_type => "$et",
        values123 => $values,
        remain123 => $remain,
      };
      #print "values: $values\nremain: $remain\n*********\n";
    } elsif( 
      $line =~ /^\s*\(0x(....)(....),(.*),SQ,([^,]+),$/
    ){
      my $grp = $1;
      my $ele = $2;
      my $type = $3;
      my $vr = "SQ";
      my $vm = 1;
      $this->{elements}->{"($grp,$ele)"} = {
        type => $type,
        vr => $vr,
        vm => $vm,
      };
      parse_sq_content(
        $this->{elements}->{"($grp,$ele)"}, $module, $module_req, $fh, 0);
    } else {
      die "unmatched line (parse): \"$line\"";
    }
  }
}
sub parse_values{
  my($this, $fh) = @_;
  while(my $line = <$fh>){
    chomp $line;
    $line =~ s/\r//g;
    if($line =~ /^\s*$/) { next }
    if($line =~ /^\s*#/) { next }
    if($line =~ /^\s*\|\s*\"([^\"]*)\"\s*$/){
      my $ev = $1;
      push(@{$this->{enum_values}}, $ev);
    } elsif(
      $line =~ /^\s*\|\s*(\S*)\s*$/
    ){
      my $ev = $1;
      push(@{$this->{enum_values}}, $ev);
    } elsif(
      $line =~ /^\s*\|\s*\"([^\"]*)\"\)\s*\"([^\"]*)\"\s*:\s*(.*)$/
    ){
      my $ev = $1;
      my $name = $2;
      my $cond = $3;
      push(@{$this->{enum_values}}, $ev);
      $this->{name} = $name;
      $this->{condition} = $cond;
      return;
    } elsif(
      $line =~ /^\s*\|\s*(\S*)\s*\)\s*\"([^\"]*)\"\s*:\s*(.*)$/
    ){
      my $ev = $1;
      my $name = $2;
      my $cond = $3;
      push(@{$this->{enum_values}}, $ev);
      $this->{name} = $name;
      $this->{condition} = $cond;
      return;
    } elsif(
      $line =~ /^\s*\|\s*\"([^\"]*)\"\)\s*\"([^\"]*)\"\s*$/
    ){
      my $ev = $1;
      my $name = $2;
      push(@{$this->{enum_values}}, $ev);
      $this->{name} = $name;
      return;
    } elsif(
      $line =~ /^\s*\|\s*(\S*)\s*\)\s*\"([^\"]*)\"\s*$/
    ){
      my $ev = $1;
      my $name = $2;
      push(@{$this->{enum_values}}, $ev);
      $this->{name} = $name;
      return;
    } else {
      die "unmatched line (parse_values): $line";
    }
  }
  die "EOF when scanning values";
}
sub parse_sq_content{
  my($this, $module, $module_req, $fh, $level) = @_;
  while(my $line = <$fh>){
    chomp $line;
    $line =~ s/\r//g;
    if($line =~ /^\s*$/) { next }
    if($line =~ /^\s*#/) { next }
    if($line =~ /^[\s>]*\)(.*)$/){
      my $remain  = $1;
      return;
    } elsif(
      $line =~
        /^[\s>]*\(0x(....)(....),(.*),(.*),(.*)\)\s*\"([^\"]+)\"\s*:\s*(.*)$/
    ){
      my $grp = $1;
      my $ele = $2;
      my $type = $3,
      my $vr = $4;
      my $vm = $5;
      my $name = $6;
      my $condition = $7;
      $this->{elements}->{"($grp,$ele)"} = {
        type => $type,
        vr => $vr,
        vm => $vm,
        name => $name,
        condition => $condition,
        module => {
          name => $module,
          req => $module_req,
        },
      };
    } elsif(
      $line =~
        /^[\s>]*\(0x(....)(....),(.*),(.*),(.*)\)\s*\"([^\"]+)\"\s*$/
    ){
      my $grp = $1;
      my $ele = $2;
      my $type = $3,
      my $vr = $4;
      my $vm = $5;
      my $name = $6;
      $this->{elements}->{"($grp,$ele)"} = {
        type => $type,
        vr => $vr,
        vm => $vm,
        name => $name,
        module => {
          name => $module,
          req => $module_req,
        },
      };
    } elsif(
      $line =~
        /^[\s>]*\(0x(....)(....),(.*),(.*),(.*),([DE]L?),([^\),]*)$/
    ){
      my $grp = $1;
      my $ele = $2;
      my $type = $3;
      my $vr = $4;
      my $vm = $5;
      my $et = $6;
      my $en = $7;
      $this->{elements}->{"($grp,$ele)"} = {
        type => $type,
        vr => $vr,
        vm => $vm,
        module => {
          name => $module,
          req => $module_req,
        },
        enumeration_type => "$et",
      };
      my($net, $values, $remain) = read_value_line($fh, "$et,$en", $vm);
      $this->{elements}->{"($grp,$ele)"}->{enumeration_type} = $net;
      $this->{elements}->{"($grp,$ele)"}->{values} = $values;
      $this->{elements}->{"($grp,$ele)"}->{remain} = $remain;
      if($remain =~ /\s*"([^"]+)"\s*:\s*"([^"]+)\s*$/){
        $this->{elements}->{"($grp,$ele)"}->{name} = $1;
        $this->{elements}->{"($grp,$ele)"}->{condition} = $1;
      } elsif($remain =~ /\s*"([^"]+)"\s*$/){
        $this->{elements}->{"($grp,$ele)"}->{name} = $1;
      }
      #print "values: $values\nremain: $remain\n*********\n";
    } elsif(
      $line =~
        /^[\s>]*\(0x(....)(....),(.*),(.*),(.*),([DE]L?),([^\)]*)\)\s*(.*)\s*$/
    ){
      my $grp = $1;
      my $ele = $2;
      my $type = $3;
      my $vr = $4;
      my $vm = $5;
      my $et = $6;
      my $values = $7;
      my $remain = $7;
      $this->{elements}->{"($grp,$ele)"} = {
        type => $type,
        type => $type,
        vr => $vr,
        vm => $vm,
        module => {
          name => $module,
          req => $module_req,
        },
        values => $values,
        remain => $remain,
        enumeration_type => "$et",
      };
      #print "values: $values\nremain: $remain\n*********\n";
    } elsif(
      $line =~ /^[\s>]*\(0x(....)(....),(.*),SQ,([^,]+),$/
    ){
      my $grp = $1;
      my $ele = $2;
      my $type = $3;
      my $vr = "SQ";
      my $vm = 1;
      $this->{elements}->{"($grp,$ele)"} = {
        type => $type,
        vr => $vr,
        vm => $vm,
      };
      parse_sq_content(
        $this->{elements}->{"($grp,$ele)"}, $module, $module_req, $fh, $level+1);
    } elsif($line =~ /^[\s>]*INCLUDEMACRO\s*"([^\"]+)\"\s*$/){
      my $m_name = $1;
      push(@{$this->{includes}}, $m_name);
    } elsif($line =~ /\s*INCLUDEMACRO\s*"([^\"]+)\"\s*:\s*(.*)\s*$/){
      my $m_name = $1;
      push(@{$this->{includes}}, $m_name);
    } else {
      die "unmatched line (parse sequence): \"$line\"";
    }
  }
}
sub parse_define_meta{
  my($this, $fh) = @_;
  while(my $line = <$fh>){
    chomp $line;
    $line =~ s/\r//g;
    if($line =~ /^\s*$/) { next }
    if($line =~ /^\s*#/) { next }
    if($line =~ /\s*SOPCLASS\s*\"([^\"]+)\"\s*\"([^\"]+)\"\s*$/){
      my $Uid = $1;
      my $name = $2;
      $this->{SOPS}->{$name} = $Uid;
    } elsif($line =~ /\s*ENDDEFINE\s*$/){
      return;
    } else {
      die "unmatched line (parse define meta): \"$line\"";
    }
  }
}
sub parser{
  my($this, $fh) = @_;
  line:
  while(my $line = <$fh>){
    chomp $line;
    $line =~ s/\r//g;
    if($line =~ /^\s*$/) { next }
    if($line =~ /^\s*#/) { next }
    if($line =~ /^\s*DEFINE\s+SYSTEM(.*)/){
      my $remain = $1;
      unless($remain =~ /\s*\"DICOM\"\s*\"3.0\"/){ die $remain }
      $this->{system} = parse_define_system($this, $fh);
      next line;
    } elsif ($line =~ /^\s*DEFINE\s*(\S*)\s*\"([^"]+)\"\s*$/){
      my $obj_type = $1;
      my $obj_desc = $2;
      unless(exists($this->{$obj_type})){
        $this->{$obj_type} = {};
      }
      unless(exists($this->{$obj_type}->{$obj_desc})){
        $this->{$obj_type}->{$obj_desc} = {};
      }
      parse_define_object($this->{$obj_type}->{$obj_desc}, $fh);
      next;
    } elsif ($line =~ /^\s*DEFINE\s*(\S*)\s*$/){
      my $obj_type = $1;
      unless(exists $this->{$obj_type}){
        $this->{$obj_type} = {};
      }
      parse_define_object($this->{$obj_type}, $fh);
      next;
    } elsif (
      $line =~ /^\s*DEFINE\s*METASOPCLASS\s*\"([^"]+)\"\s*"([^\"]+)\"\s*$/
    ){
      my $Uid = $1;
      my $name = $2;
      unless(exists $this->{METASOPCLASS}){
        $this->{METASOPCLASS} = {};
      }
      $this->{METASOPCLASS}->{$name} = {
        UID => $Uid,
      };
      parse_define_meta($this->{METASOPCLASS}->{$name}, $fh);
    } else {
      die "Yikes!: $line";
    }
  }
}
sub read_value_line{
  my($fh, $remain, $vm) = @_;
  while(my $line = <$fh>){
    chomp $line;
    $line =~ s/\r//g;
    if($line =~ /^\s*$/) { next }
    if($line =~ /^\s*#/) { next }
    if($line =~ /^\s*([^\)]+)\s*\)(.*)$/){
      $remain .= $1;
      my $excess = $2;
      my($et, $values) = parse_value_line($remain, $vm);
      return $et, $values, $excess;
    }
    $line =~ s/^\s*//;
    $line =~ s/\s*$//;
    $remain .= $line;
  }  
  die "no end to value line";
}
sub parse_value_line{
  my($line, $vm) = @_;
  my $remaining = $line;
  my($et, $v);
  my($etc, $vc);
  while($remaining){
    if($remaining =~ /^\s*([EDL]+),(.*)$/){
      my $m = $1;
      $remaining = $2;
      if(defined($etc)) {push @$et, $etc}
      if(defined($vc)) {push @$v, $vc}
      $etc = $m;
      $vc = [];
    } elsif($remaining =~ /^\s*("[^"]*")\s*\|(.*)$/){
      $remaining = $2;
      my $value = $1;
      push @$vc, $value;
    } elsif($remaining =~ /^\s*("[^"]*"),\s*(.*)$/){
      $remaining = $2;
      my $value = $1;
      push @$vc, $value;
    } elsif($remaining =~ /^\s*([^\|]*)\s*\|(.*)$/){
      $remaining = $2;
      my $value = $1;
      push @$vc, $value;
    } elsif($remaining =~ /^\s*(\S*),\s*(.*)$/){
      $remaining = $2;
      my $value = $1;
      push @$vc, $value;
    } elsif($remaining =~ /^\s*("[^"]*")\s*$/){
      $remaining = "";
      my $value = $1;
      push @$vc, $value;
    } elsif($remaining =~ /^\s*([^"]*)\s*$/){
      $remaining = "";
      my $value = $1;
      push @$vc, $value;
    } else {
      print "Unmatched pattern \"$remaining\"\n";
    }
  }
  push(@$et, $etc);
  push(@$v, $vc);
  if($vm eq "1"){
    unless($#{$et} == 0){
      die "multiple specs for value with VR of 1";
    }
    return ($et->[0], $v->[0]);
  }
  return($et, $v);
}
sub new{
  my($class, $file) = @_;
  open FILE, "<", "$file" or die "can't open $file\n";
  my $this = {};
  parser($this, \*FILE);
  close FILE;
  return bless $this, $class;
}
sub ProcessElements{
  my($elements, $above) = @_;
  my $hash;
  for my $ele (keys %$elements){
  }
}
1;
