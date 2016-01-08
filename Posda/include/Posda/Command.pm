#$Source: /home/bbennett/pass/archive/Posda/include/Posda/Command.pm,v $
#$Date: 2014/02/14 21:00:31 $
#$Revision: 1.12 $
#
#Copyright 2008, Bill Bennett
# Part of the Posda package
# Posda may be copied only under the terms of either the Artistic License or the
# GNU General Public License, which may be found in the Posda Distribution,
# or at http://posda.com/License.html
#
use strict;
package Posda::Command;
use Posda::CmdDict;

sub new_blank{
  my($class) = @_;
  my $this = {};
  return (bless($this, $class));
}
sub new{
  my($class, $data) = @_;
  my $this = {
  };
  my $remaining = $data;
  while($remaining){
    my($grp, $ele, $len, $remain) = unpack("vvVa*", $remaining);
    my $value;
    if($len >= 0){
      ($value, $remaining) = unpack("a${len}a*", $remain);
    }
    my $sig = sprintf("(%04x,%04x)", $grp, $ele);
    if(exists $Posda::CmdDict::Dict->{$sig}){
      if($Posda::CmdDict::Dict->{$sig}->{type} eq "ulong"){
        my @values = unpack("V*", $value);
        if($#values > 0){
          $value = \@values;
        } else {
          $value = $values[0];
        }
      } elsif ($Posda::CmdDict::Dict->{$sig}->{type} eq "ushort"){
        my @values = unpack("v*", $value);
        if($#values > 0){
          $value = \@values;
        } else {
          $value = $values[0];
        }
      } else {
        if($Posda::CmdDict::Dict->{$sig}->{vr} eq "UI"){
          $value =~ s/\0+$//;
        } else {
          $value =~ s/\s+$//;
        }
      }
    }
    $this->{$sig} = $value;
  }
  return bless $this, $class;
};
sub BasicCommandInfo{
  my($this) = @_;
  my $is_response = $this->{"(0000,0100)"} & 0x8000;
  my $message_id;
  if($is_response){
    $message_id = $this->{"(0000,0120)"};
  } else {
    $message_id = $this->{"(0000,0110)"};
  }
  my $has_dataset = $this->{"(0000,0800)"} == 0x0101 ? 0 : 1;
  my $cmd_code = $this->{"(0000,0100)"} & 0x0fff;
  my $command;
  if($cmd_code == 0x1){
    $command = "STORE";
  } elsif($cmd_code == 0x10){
    $command = "GET";
  } elsif($cmd_code == 0x20){
    $command = "FIND";
  } elsif($cmd_code == 0x21){
    $command = "MOVE";
  } elsif($cmd_code == 0x30){
    $command = "ECHO";
  } elsif($cmd_code == 0x100){
    $command = "N_EVENT_REPORT";
  } elsif($cmd_code == 0x110){
    $command = "N_GET";
  } elsif($cmd_code == 0x120){
    $command = "N_SET";
  } elsif($cmd_code == 0x130){
    $command = "N_ACTION";
  } elsif($cmd_code == 0x140){
    $command = "N_CREATE";
  } elsif($cmd_code == 0x150){
    $command = "N_DELETE";
  } elsif($cmd_code == 0x0fff){
    $command = "CANCEL";
  } else{
    $command = "UNKNOWN";
  }
  return($command, $message_id, $is_response, $has_dataset);
}
sub DumpLines{
  my($this) = @_;
  my @lines;
  key:
  for my $key(sort keys %$this){
    unless(exists $Posda::CmdDict::Dict->{$key}) {
      print STDERR "Element $key not found in DICOM command dict\n";
      next key;
    }
    my $desc = $Posda::CmdDict::Dict->{$key}->{name};
    my $vr = $Posda::CmdDict::Dict->{$key}->{vr};
    my $type = $Posda::CmdDict::Dict->{$key}->{type};
    push(@lines, [$key, $desc, $vr, $type, $this->{$key}]);
  }
  return \@lines;
}
sub new_store_cmd{
  my($class, $sop_cl, $sop_inst) = @_;
  my $cmd = {
    "(0000,0002)" => $sop_cl,
    "(0000,0100)" => 1,
    "(0000,0700)" => 0,
    "(0000,0800)" => 0,
    "(0000,1000)" => $sop_inst,
  };
  return bless $cmd, $class;
};
sub new_store_response{
  my($this, $status) = @_;
  my $resp = {
    "(0000,0100)" => 0x8001,
    "(0000,0800)" => 0x0101,
    "(0000,0120)" => $this->{"(0000,0110)"},
    "(0000,0900)" => $status,
    "(0000,0002)" => $this->{"(0000,0002)"},
    "(0000,1000)" => $this->{"(0000,1000)"},
  };
  return bless $resp, ref($this);
}
sub new_verif_command{
  my($class, $status) = @_;
  my $resp = {
    "(0000,0100)" => 0x30,
    "(0000,0800)" => 0x0101,
    "(0000,0002)" => '1.2.840.10008.1.1',
  };
  return bless $resp, $class;
}
sub new_verif_response{
  my($this, $status) = @_;
  my $resp = {
    "(0000,0100)" => 0x8030,
    "(0000,0800)" => 0x0101,
    "(0000,0120)" => $this->{"(0000,0110)"},
    "(0000,0002)" => $this->{"(0000,0002)"},
    "(0000,0900)" => $status,
  };
  return bless $resp, ref($this);
}
sub new_find_command{
  my($class, $sop, $prio) = @_;
  my $cmd = {
   "(0000,0002)" => $sop,
   "(0000,0100)" => 0x20,
   "(0000,0700)" => $prio,
   "(0000,0800)" => 1,
 };
 return bless $cmd, $class;
}
sub render{
  my($this) = @_;
  my $body = "";
my @log;
  for my $i (sort keys %$this){
    my $value = $this->{$i};
    unless(exists $Posda::CmdDict::Dict->{$i}){
      die "unknown element in cmd $i";
    }
    unless($i =~ /\((....),(....)\)/){ die "invalid tag: $i" }
    my $grp = hex($1);
    my $ele = hex($2);
    my $type = $Posda::CmdDict::Dict->{$i}->{type};
    my $length;
my $dbg_value;
    if($type eq "text"){
      $length = length($value);
      if($length & 1){
        if($Posda::CmdDict::Dict->{$i}->{vr} eq "UI"){
          $value .= "\0";
        } else {
          $value .= " ";
        }
      }
$dbg_value = $value;
    } elsif ($type eq "ushort"){
      if(ref($value) eq "ARRAY"){
$dbg_value = join("\\", @$value);
        $value = pack("v*", @$value);
      } else {
$dbg_value = $value;
        $value = pack("v", $value);
      }
    } elsif ($type eq "ulong"){
      if(ref($value) eq "ARRAY"){
$dbg_value = join("\\", @$value);
        $value = pack("V*", @$value);
      } else {
$dbg_value = $value;
        $value = pack("V", $value);
      }
    } else {
    }
    $length = length($value);
    $body .= pack("vvV", $grp, $ele, $length) . $value;
push(@log,  sprintf("Command element (%04x,%04x): \"%s\"\n", $grp, $ele, $dbg_value));
  }
  my $len = length($body);
  my $head = pack("vvVV", 0, 0, 4, $len);
  my $resp = $head . $body;
#print "###################\nRendered a command:\n";
#print "Command element (0000,0000): $len\n";
#for my $i (@log){
#print $i;
#}
#print "######################\n";
  return $resp;
}
sub Debug{
  my($this) = @_;
  for my $i (sort keys %$this){
    print "Command{$i} = $this->{$i}\n";
  }
}

sub DESTROY {
  #print "Destroyed Posda::Command\n";
};
1;
