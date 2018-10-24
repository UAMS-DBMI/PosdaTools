#!/usr/bin/perl -w
#
use strict;
use Storable qw( store_fd fd_retrieve );
use Dispatch::Dicom::Assoc;
use Posda::Command;
use Debug;
use IO::Handle;
use HexDump;
my $dbg = sub { print @_ };
my $usage = <<EOF;
ExtractMessageInfo.pl <dir>
 or
ExtractMessageInfo.pl -h

Expects to find the following files in the directory:
  pdu_analysis
  trace_from_data
  trace_to_data

Transaction data:
\$results => {
  messages => {
    <message_id> => {
      <command> => {
        pdv_list =>[
          { offset => <offset>, length => <length> },
            ...
        ],
        parsed => <cmd>,
        dataset => {# if dataset exists
          pdv_list =>[
            { offset => <offset>, length => <length> },
            ...
          ],
          trace_file => <file_name>,
        },
        trace_file => <file_name>,
      },
      responses => [
        {
          pdv_list =>[
            { offset => <offset>, length => <length> },
            ...
          ],
          parsed => <cmd>,
          dataset => {# if dataset exists
            pdv_list =>[
              { offset => <offset>, length => <length> },
              ...
            ],
            ds_file => <file_name>,
            trace_file => <file_name>,
          },
          trace_file => <file_name>,
        },
        ...
      ]
    },
  },
  errors => [
  ],
};

Message data stored in file
  message_info
in <dir>
Dicom files created in <dir> for each dataset of form
  dataset_<index>.dcm
EOF
if($ARGV[0] eq "-h"){
  print $usage;
  exit;
}
my $dir = $ARGV[0];
my $messages = {};
my $result= {};
sub PdvHandler{
  my($file_name) = @_;
  my $state = "CmdSearch";
  my $pdvs_to_assemble = [];
  my $command;
  my $is_response;
  my $has_dataset;
  my $message_id;
  my $response_command;
  my $pc_ids = {};
  my $sub = sub {
    my($pdv) = @_;
    unless(defined($pdv)) {
      unless($state eq "CmdSearch"){
        die "$file_name: Left in state $state";
      }
    }
    if($state eq "CmdSearch" or $state eq "InCmd"){
      if($state eq "CmdSearch"){
        unless($pdv->{is_command}){
          die "$file_name: non command pdv encountered in state CmdSearch";
        }
        $state = "InCmd";
      }
      push(@$pdvs_to_assemble, {
        offset => $pdv->{pdv_data_offset},
        length => $pdv->{pdv_data_length},
      });
      if(exists $pdv->{pc_id}){
        $pc_ids->{$pdv->{pc_id}} = 1;
      } else {
        print STDERR "No presentation context for pdv\n";
      }
      if($pdv->{is_final}){
        my $message = ConstructCommand($file_name, $pdvs_to_assemble);
        my $parsed = Posda::Command->new($message);
        ($command, $message_id, $is_response, $has_dataset) = 
          $parsed->BasicCommandInfo;
        if($has_dataset){
          $state = "DsSearch";
        } else {
          $state = "CmdSearch";
        }
        if($is_response){
          $response_command = {
            pdv_list => $pdvs_to_assemble,
            parsed => $parsed,
            trace_file => $file_name,
          };
          if(scalar(keys %{$pc_ids}) == 1){
            $response_command->{pc_id} = [ keys %{$pc_ids} ]->[0];
          } elsif(scalar(keys %{$pc_ids}) > 1){
            $response_command->{pc_id} = [ keys %{$pc_ids} ];
          } else {
            print STDERR "No presentation context for command\n";
          }
          $pc_ids = {};
          push(@{$messages->{$message_id}->{responses}}, $response_command);
        } else {
          if(exists $messages->{$message_id}->{$command}){
            push(@{$result->{errors}},
              "Two $command messages with id $message_id");
          }
          $messages->{$message_id}
            ->{$command}->{pdv_list} = $pdvs_to_assemble;
          $messages->{$message_id}
            ->{$command}->{parsed} = $parsed; 
          $messages->{$message_id}->{$command}->{trace_file} = $file_name;
          if(scalar(keys %{$pc_ids}) == 1){
            $messages->{$message_id}->{$command}->{pc_id} = 
              [ keys %{$pc_ids} ]->[0];
          } elsif(scalar(keys %{$pc_ids}) > 1){
            $messages->{$message_id}->{$command}->{pc_id} = 
              [ keys %{$pc_ids} ];
          } else {
            print STDERR "No presentation context for command\n";
          }
          $pc_ids = {};
        }
        $pdvs_to_assemble = [];
      }
    } elsif ($state eq "DsSearch" or $state eq "InDs"){
      if($state eq "DsSearch"){
        if($pdv->{is_command}){
          die "$file_name: command pdv encountered in state DsSearch";
        }
        $state = "InDs";
      }
      if(exists $pdv->{pc_id}){
        $pc_ids->{$pdv->{pc_id}} = 1;
      } else {
        print STDERR "No presentation context for pdv\n";
      }
      push(@$pdvs_to_assemble, {
        offset => $pdv->{pdv_data_offset},
        length => $pdv->{pdv_data_length},
      });
      if($pdv->{is_final}){
        my $ds_file_name = ConstructDataset($file_name, $pdvs_to_assemble);
        $state = "CmdSearch";
        my $dataset = {
          pdv_list => $pdvs_to_assemble,
          ds_file => $ds_file_name,
          trace_file => $file_name,
        };
        if(scalar(keys %{$pc_ids}) == 1){
          $dataset->{pc_id} = [ keys %{$pc_ids} ]->[0];
        } elsif(scalar(keys %{$pc_ids}) > 1){
          $dataset->{pc_id} = [ keys %{$pc_ids} ];
        } else {
          print STDERR "No presentation context for dataset\n";
        }
        $pc_ids = {};
        if($is_response){
          $response_command->{dataset} = $dataset;
        } else {
          $messages->{$message_id}
            ->{$command}->{dataset} = $dataset;
        }
        $pdvs_to_assemble = [];
      }
    } else {
      die "Unknown state";
    }
  };
  return $sub;
}
sub ConstructCommand{
  my($file, $pdv_list) = @_;
  my $data = "";
  open READ, "<$file" or die "can't open $file";
  for my $block (@$pdv_list){
    seek READ, $block->{offset}, 0 or die "Can't seek";
    my $count = read(READ, $data, $block->{length}, length($data));
    unless($count == $block->{length}){
      die "read $count vs $block->{length}";
    }
  }
  close READ;
  return $data;
}
my $file_seq = 0;
sub ConstructDataset{
  my($file, $pdv_list) = @_;
  $file_seq += 1;
  my $ds_file_name = "$dir/dataset_$file_seq.dcm";
  open TO_FILE, ">$ds_file_name" or die "can't open $ds_file_name";
  open FROM, "<$file";
  my $data;
  for my $i (@{$pdv_list}){
    seek FROM, $i->{offset}, 0 or die "Can't seek";
    my $count = read(FROM, $data, $i->{length});
    unless($count == $i->{length}){
      die "read $count vs $i->{length}";
    }
    print TO_FILE $data;
  }
  close FROM;
  close TO_FILE;
  return $ds_file_name;
}
my $pdu_analysis;
sub Done{
  my $fh;
  unless(open $fh, ">$dir/message_info"){
    print "Error: Unable to open $dir/message_info\n";
    exit;
  }
  store_fd $messages, $fh;
  close $fh;
  print "OK\n";
  exit;
}
unless(-f "$dir/trace_from_data") {
  print "Error: $dir/trace_from_data\n";
  exit;
}
unless(-f "$dir/trace_to_data") {
  print "Error: $dir/trace_from_data\n";
  exit;
}
unless(open PDU, "<$dir/pdu_analysis") {
  print "Error: Unable to open $dir/pdu_analysis\n";
  exit;
}
eval { $pdu_analysis = fd_retrieve(\*PDU) };
if($@){
  print "Error: Unable to retrieve $dir/pdu_analysis: $@\n";
}
my $pdv_handler = PdvHandler("$dir/trace_from_data");
my $pdu;
for $pdu (@{$pdu_analysis->{from_pdu}}){
  unless($pdu->{pdu_type} eq "P-DATA-TF") { next }
  for my $pdv (@{$pdu->{pdv_list}}){
    &{$pdv_handler}($pdv);
  }
}
$pdv_handler = PdvHandler("$dir/trace_to_data");
for $pdu (@{$pdu_analysis->{to_pdu}}){
  unless($pdu->{pdu_type} eq "P-DATA-TF") { next }
  for my $pdv (@{$pdu->{pdv_list}}){
    &{$pdv_handler}($pdv);
  }
}
$result->{messages} = $messages;
Done();
