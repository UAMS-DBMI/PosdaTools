package Posda::NewerProcessPopup;
#use Modern::Perl;

use Posda::PopupWindow;
use Posda::PopupImageViewer;
use Posda::Config ('Config','Database');
use Posda::DB 'Query';
use Posda::DB::PosdaFilesQueries;
use Posda::File::Import 'insert_file';

use File::Temp 'tempfile';

use DBI;
use URI;
use HTML::Entities;
use Debug;
my $dbg = sub {print STDERR @_};

use MIME::Base64;

use Redis;
use constant REDIS_HOST => 'redis:6379';

my $redis = undef;
my $work_id;

sub ConnectToRedis {
  unless($redis) {
    $redis = Redis->new(server => REDIS_HOST);
  }
}

sub QuitRedis {
  if ($redis) {
    $redis->quit;
  }
  $redis = undef;
}

use vars qw( @ISA );
@ISA = ("Posda::PopupWindow");

my $db_handle;

#params = {
#  bindings => {
#    <variable_name> => <value>,
#    ...
#  },
#  current_settings =>{
#    activity_id => <activity_id>,
#    activity_timepoint_id => <activity_timepoint_id>,
#    notify => <notify>,
#  },
#  prior_ss_args => {
#    <variable_name> => <value>,
#  },
#  columns => {
#     <column_name>,
#      ...
#  },
#  command => {
#    can_chain => 1|0|undef,
#    command_line => <unsubstituted_command_line>,
#    operation_name => <operation_name>,
#    args => [
#      <extracted_from cmd_line>,
#      ...
#    ],
#    input_line_format => <unsubstituted_input_line_format>,
#    fields => [
#      <extracted_from_cmd_line>,
#    ],
#    operation_type => background_process|legacy,
#  },
#  notify => <curent_user>,
#  rows => [
#    {
#      <column_name> => <value>
#      ...
#    },
#    ...
#  ]
#};
#
sub SpecificInitialize{
  my($self,$params) = @_;
  $self->{title} = "Process Operation Popup";
  $self->{args} = {};
  $self->{meta_args} = {};
  $self->{params} = $params;



  for my $arg (@{$self->{params}->{command}->{args}}){
    if(exists $self->{params}->{prior_ss_args}->{$arg}){ #if prior_ss_arg, use it
      $self->{args}->{$arg}  = ["from spreadsheet", $self->{params}->{prior_ss_args}->{$arg}];
    } elsif (exists $self->{params}->{current_settings}->{$arg}){ #elsif current_setting, use it
      $self->{args}->{$arg}  = ["from current_settings",  $self->{params}->{current_settings}->{$arg}],
    } elsif (exists $self->{bindings}->{$arg}) { #elsif binding, set it
      $self->{args}->{$arg}  = ["from bindings",  $self->{params}->{bindings}->{$arg}],
    } else {
      $self->{args}->{$arg}  = ["not present",  ""],
    }
  }
  my $cmd = $self->{params}->{command}->{command_line};
  if($cmd =~ /^([^\s]*)\s/){
    $prog = $1;
    my $effective_prog;
    open FOO, "which $prog|";
    while(my $line = <FOO>){ $effective_prog .= $line };
    chomp $effective_prog;
    $self->{EffectiveProg} = $effective_prog;
  }
  $self->SetDefaultInput;
  if (exists $self->{params}->{needs_spreadsheet}){
      $self->{mode} = 'needs_spreadsheet';
  }else{
  $self->{mode} = "initial";
  }


}

sub SetDefaultInput{
  my($self) = @_;
  $self->{InputLines} = [];
  for my $row (@{$self->{params}->{rows}}){
    my $line = $self->{params}->{command}->{input_line_format};
    for my $col (@{$self->{params}->{command}->{fields}}){
      $line =~ s/<$col>/$row->{$col}/g;
    }
    push @{$self->{InputLines}}, $line;
  }
}

sub ContentResponse {
  my($self, $http, $dyn) = @_;
  if($self->{mode} eq "initial"){
  $self->RefreshEngine($http, $dyn,
    '<div style="display: flex; flex-direction: column; align-items: flex-beginning; margin-bottom: 5px">' .
    '<div id="div_ProcessSummary">' .
    '<?dyn="DrawProcessSummary"?>' .
    '</div>' .
    '<div id="div_ParameterForm">' .
    '<?dyn="DrawParameterForm"?>' .
    '</div>' .
    '<div id="div_RenderedCommandLine">' .
    '<?dyn="DrawRenderedCommandLine"?>' .
    '</div>' .
    '<div id="div_RenderedInputData">' .
    '<?dyn="DrawRenderedInputData"?>' .
    '</div>' .
    '</div>');
  } elsif($self->{mode} eq "waiting"){
    $self->WaitingForResponse($http, $dyn);
  } elsif($self->{mode} eq "response_available"){
    $self->SubProcessResponded($http, $dyn);
  # } elsif($self->{mode} eq "needs_spreadsheet"){
  #   $self->RefreshEngine($http, $dyn,
  #     '<div style="display: flex; flex-direction: column; align-items: flex-beginning; margin-bottom: 5px">' .
  #     '<div id="div_ProcessSummary">' .
  #     '<?dyn="DrawProcessSummary"?>' .
  #     '</div>' .
  #     '<div>' .
  #     '<h3>This operation requires a spreadsheet as input</h3>' .
  #     '<div style="display: flex; flex-direction: column; align-items: flex-beginning;' .
  #     '  margin-left: 10px; margin-bottom: 5px"> ' .
  #     '<div id="load_form"> ' .
  #     ' <form action="<?dyn="StoreFileUri"?>" ' .
  #     ' enctype="multipart/form-data" method="POST" class="dropzone"> ' .
  #     ' </form> ' .
  #     ' </div> ' .
  #     '<div id="file_report"> ' .
  #     '<?dyn="Files"?> ' .
  #     '</div>' .
  #     '</div>' .
  #     '</div>' .
  #     '<div id="div_RenderedCommandLine">' .
  #     '<?dyn="DrawRenderedCommandLine"?>' .
  #     '</div>' .
  #     '<div id="div_RenderedInputData">' .
  #     '<?dyn="DrawRenderedInputData"?>' .
  #     '</div>' .
  #     '</div>');
  }
   else {
    $http->queue("Unknown mode: $self->{mode}");
  }
}

sub DrawProcessSummary{
  my($self, $http, $dyn) = @_;
  $http->queue("Operation: $self->{params}->{command}->{operation_name}<br>");
  my $cmd = $self->{params}->{command}->{command_line};
  my $encoded_command = encode_entities($cmd);
  $http->queue("Command: $encoded_command<br>");
  my $inp = $self->{params}->{command}->{input_line_format};
  my $encoded_inp = encode_entities($inp);
  if ($encoded_inp){
    $http->queue("Input line format: $encoded_inp");
  }
  my $warn = Query("IsThisOperationOutdated")
               ->FetchOneHash($self->{params}->{command}->{operation_name})
               ->{outdated};
  if ($warn){
    $http->queue("<br><strong>**This operation is outdated. Speak to an administrator.**</strong><br>");
  }
}

sub DrawParameterForm{
  my($self, $http, $dyn) = @_;
  $http->queue("<hr>Parameters:<ul>");
  for my $p (sort keys %{$self->{args}}){
    $http->queue("<li>$p : ");
    $self->NewEntryBox($http, {
      name => "Arg_$p",
      op => "SetArg",
      index => $p,
      value => $self->{args}->{$p}->[1],
      id => "ent_arg_$p",
    }, "UpdateDiv('div_RenderedCommandLine', 'DrawRenderedCommandLine')");
    $http->queue("</li>");
  }
  $http->queue("</ul>");
}

sub SetArg{
  my($self, $http, $dyn) = @_;
#print STDERR "In SetArg:\n";
#for my $i (keys %$dyn){
#  print STDERR "  dyn{$i} = '$dyn->{$i}'\n";
#}
  if($self->{args}->{$dyn->{index}}->[1] ne $dyn->{value}){
    $self->{args}->{$dyn->{index}} = ["entered", $dyn->{value}];
  }
}

sub DrawRenderedCommandLine{
  my($self, $http, $dyn) = @_;
  my $expanded_command = $self->{params}->{command}->{command_line};
  for my $p (keys %{$self->{args}}){
    $expanded_command =~ s/<$p>/$self->{args}->{$p}->[1]/;
  }
  $self->{ExpandedCommand} = $expanded_command;
  my $encoded_command = encode_entities($self->{ExpandedCommand});
  if($self->{EffectiveProg} ne ""){
    $http->queue("<hr>Expanded Command:<pre>$encoded_command</pre>");
  } else {
    $http->queue("<hr>Expanded Command (not found):<pre>$encoded_command</pre>");
  }
}

sub DrawRenderedInputData{
  my($self, $http, $dyn) = @_;

  if (defined $self->{params}->{special}){
    my $temp_dir =   $self->{params}->{Temp_dir};
     unless(-d $temp_dir) { die "$temp_dir doesn't exist" }
    $self->{TempDir} = $temp_dir;
    $self->{UploadCount} = 0;
    $self->RefreshEngine($http, $dyn,
      '<div style="display: flex; flex-direction: column; align-items: flex-beginning; margin-bottom: 5px">' .
        "<h3>This Process Requires a Spreadsheet</h3><p> Upload a spreadsheet matching the above input format.</p>" .
          '<div style="display: flex; flex-direction: column; align-items: flex-beginning;' .
            'margin-left: 10px; margin-bottom: 5px">' .
            '<div id="load_form">' .
                '<form action="<?dyn="StoreFileUri"?>" ' .
                  'enctype="multipart/form-data" method="POST" class="dropzone">' .
                '</form> '.
                '<div id="file_report">'.
                  '<?dyn="Files"?>'.
                '</div>'.
            '</div>'.
          '</div>'.
      '</div>'
    );
    my %qualified_ops;
    my %is_col;
    for my $col (@{$self->{params}->{cols}}){
      $is_col{$col} = 1;
    }
    operation:
    for my $op (sort keys %{$self->{Operations}}){
      my $info = $self->{Operations}->{$op};
      unless(defined $info->{pipe_parms} && $info->{pipe_parms}) { next operation }
      my $num_hits = 0;
      for my $req_col (@{$info->{pipe_parmlist}}){
        unless($is_col{$req_col}) {  next operation }
        $num_hits += 1;
      }
      if($num_hits > 0){
        $qualified_ops{$op} = $num_hits;
      }
    }
    $self->{qualified_ops} = \%qualified_ops;
    for my $op (
      sort
      { $qualified_ops{$b} <=> $qualified_ops{$a} || $a cmp $b }
      keys %qualified_ops
    ){
      my $info = $self->{Operations}->{$op};
      $http->queue("<tr><td>$op</td>");
      my $encoded_command = encode_entities($info->{cmdline});
      $http->queue("<td>$encoded_command</td>");
      my $encoded_input = encode_entities($info->{pipe_parms});
      $http->queue("<td>$encoded_input</td>");
      $http->queue("<td>$qualified_ops{$op}</td>");
      $http->queue("<td>");
      $self->DelegateButton($http, {
         op => "ChooseOperation",
         id => "ChooseOperation_$op",
         caption => "Choose",
         chosen => "$op",
         sync => 'Update();',
      });
      $self->NotSoSimpleButton($http, {
        op => "OpHelp",
        caption => "Help",
        cmd => $op,
        sync => "Update();",
      });
      $http->queue("</td>");
      $http->queue("</tr>");
    }
    $http->queue("</table></div></div>");

  }else{
    my $num_lines = @{$self->{InputLines}};
    $http->queue("<hr>$num_lines lines to supply as input:\n<pre>");
    if($num_lines < 20){
      for my $line (@{$self->{InputLines}}){
        $http->queue("$line\n");
      }
    } else {
      my $lines = @{$self->{InputLines}};
      for my $i (0 .. 9){
        $http->queue("$self->{InputLines}->[$i]\n");
      }
      $http->queue("... (only first and last 10 lines shown)\n");
      for my $i ($lines - 10 .. $lines - 1){
        $http->queue("$self->{InputLines}->[$i]\n");
      }
    }
    $http->queue("</pre>");
  }
}

sub Cancel{
  my($self, $http, $dyn) = @_;
  $http->queue("OK");
}


sub MenuResponse{
  my($self, $http, $dyn) = @_;
  $http->queue(
    '<div style="display: flex; flex-direction: column; align-items: flex-beginning; margin-bottom: 5px">');
  if($self->{mode} eq "initial"){
    if($self->{EffectiveProg} ne ""){
      $self->DelegateButton($http, {
        op => "StartSubprocess",
        caption => "Start",
        sync => "Update();",
        css_class => "btn btn-success",
      });
    } else {
      $http->queue("Program not found");
    }
    $self->DelegateButton($http, {
      op => "Cancel",
      caption => "Cancel",
      sync => "CloseThisWindow();",
    });
    $self->NotSoSimpleButton($http, {
      op => "OpHelp",
      caption => "Help",
      cmd => $self->{params}->{command}->{operation_name},
      sync => "Update();",
    });
  } elsif($self->{mode} eq "waiting") {
    $http->queue("waiting");
  } elsif($self->{mode} eq "response_available") {
    $self->DelegateButton($http, {
      op => "Done",
      caption => "Cancel",
      sync => "CloseThisWindow();",
    });
  } else {
    $http->queue("Unknown mode: $self->{mode}");
  }
  $http->queue("</div>");
}

sub StartSubprocess{
  my ($self, $http, $dyn) = @_;
  my $id = $self->{table}->{query}->{invoked_id};
  my $btn_name = $self->{button_name};
  my $operation_name = $self->{params}->{command}->{operation_name};;
  my $command_line = $self->{ExpandedCommand};
  my $invoking_user = $self->get_user;
  my $spreadsheet_f_id;

  #Did this operation come from a spreasheet?
  if ($self->{params}->{invocation}->{type} eq "UploadedUnnamedSpreadsheet" || $self->{params}->{invocation}->{type} eq "UploadedNamedSpreadsheet"){

    # it came from a spreadsheet, so associate it with that one
    $spreadsheet_f_id = $self->{params}->{invocation}->{file_id};

  }else{
    # it came from a button, so we create a spreasheet to be able to rerun the process or create worker nodes

    #create spreadsheet
    my ($fh,$tempfilename) = tempfile();

    #column row
    for my $felds (@{$self->{params}->{command}->{fields}}) {
      print $fh "$felds,";
    }
    print $fh  "Operation,";
    for my $argKey (sort keys %{$self->{args}}){
      print $fh "$argKey,";
    }
    #data rows
    my $line1 = 0;
    for $datalines (@{$self->{InputLines}}) {
      print $fh "\n$datalines,";
      if ($line1 == 0){
        $line1 = 1;
        print $fh "$self->{params}->{command}->{operation_name},";
        for my $argValue (sort keys %{$self->{args}}){
          print $fh "$self->{args}->{$argValue}->[1],";
        }
      }
    }
    #data row when there are no input lines
    if ($#{$self->{InputLines}} == -1){
      print $fh "\n";
      for my $felds (@{$self->{params}->{command}->{fields}}) {
        print $fh ",";
      }
      print $fh "$self->{params}->{command}->{operation_name},";
      for my $argValue (sort keys %{$self->{args}}){
        print $fh "$self->{args}->{$argValue}->[1],";
      }
    }
    close $fh;

    #call API to import
    my $resp = Posda::File::Import::insert_file($tempfilename);
    if ($resp->is_error){
        die $resp->error;
    }else{
      $spreadsheet_f_id =  $resp->file_id;
    }
    unlink $tempfilename;
  }

  #save to spreadsheet uploaded
  my $spreadsheet_table_id = PosdaDB::Queries::record_spreadsheet_upload(1, $invoking_user, $spreadsheet_f_id, ($#{$self->{InputLines}}+1));

  #save to subprocess invocation
  my $new_id = Query("CreateSubprocessInvocationButton")
               ->FetchOneHash($id, $btn_name, $command_line, $spreadsheet_table_id,
                              $invoking_user, $operation_name)
               ->{subprocess_invocation_id};

  unless($new_id) {
    die "Couldn't create row in subprocess_invocation";
  }

  # save input file for worker nodes
  my ($fht,$tempinputdata) = tempfile();
  for $datalines (@{$self->{InputLines}}) {
    print $fht "$datalines\n";
  }
  close $fht;

  #call API to import
  my $resp = Posda::File::Import::insert_file($tempinputdata);
  if ($resp->is_error){
      die $resp->error;
  }else{
    $worker_input_file_id =  $resp->file_id;
  }
  unlink $tempinputdata;

  # add to the work table for worker nodes
  $work_id = Query("CreateNewWork")
                ->FetchOneHash($new_id,$worker_input_file_id)
                ->{work_id};


  ConnectToRedis();
  unless($redis){
    die "Couldn't connect to redis";
  }
  my $priority = Query("OperationPriority")
               ->FetchOneHash($self->{params}->{command}->{operation_name})
               ->{worker_priority};
  $redis->lpush("work_queue_$priority", $work_id);
  QuitRedis();



  my $cmd_to_invoke = $self->{ExpandedCommand};
  $cmd_to_invoke =~ s/<\?bkgrnd_id\?>/$new_id/eg;
#  print STDERR "###########################\n";
#  print STDERR "NewCommandToInvoke: $cmd_to_invoke\n";
#  print STDERR "###########################\n";
# Dispatch::LineReaderWriter->write_and_read_all(
#   $cmd_to_invoke,
#   $self->{InputLines},
#   $self->WhenCommandFinishes($new_id)
# );
#  print STDERR "Started Line reader\n";
  $self->{mode} = "waiting";
}

sub WhenCommandFinishes{
  my($self,$subprocess_invocation_id) = @_;
  my $sub = sub {
    my($results, $pid) = @_;
    $self->{Results} = $results;
    my $q = Query("AddPidToSubprocessInvocation");
    $q->RunQuery(sub{}, sub{}, $pid, $subprocess_invocation_id);
    my $q1 = Query("CreateSubprocessLine");
    my $line_no = 0;
    for my $line (@$results){
      $line_no += 1;
      $q1->RunQuery(sub {}, sub {},
        $subprocess_invocation_id,
        $line_no,
        $line
      );
    }
    $self->{mode} = "response_available";
    if($self->can("AutoRefresh")){
      $self->AutoRefresh;
    }
  };
  return $sub;
}

sub WaitingForResponse{
  my($self,$http, $dyn) = @_;
  $http->queue("<p>Successfully queued background process with worker $work_id.</p>");
  my $q = Query("GetWorkerQueueLength");
  my $qlen = $q->FetchOneHash();
  $http->queue("<p>There are $qlen->{qlength} items ahead in the worker queue.</p>");
  # my $q = Query("GetWorkerCompleteStatus");
  # my $w_info = $q->FetchOneHash($work_id);
  # $http->queue("<p>Worker $work_id's log information can be found in files: $w_info->{stdout_file_id} , $w_info->{stderr_file_id}./p>");
  $self->DelegateButton($http, {
    op => "Close",
    caption => "Close",
    sync => "CloseThisWindow();",
  });
}

sub SubProcessResponded{
  my($self,$http, $dyn) = @_;
  $http->queue("<p>Subprocess response:</p><pre>");
  for my $i (@{$self->{Results}}){
    $http->queue("$i\n");
  }
}
sub OpHelp {
  my ($self, $http, $dyn) = @_;

  my $details = [ $dyn->{cmd} ];


  my $child_path = $self->child_path("PopupHelp_$dyn->{cmd}");
  my $child_obj = ActivityBasedCuration::PopupHelp->new($self->{session},
                                              $child_path, $details);
  $self->parent->StartJsChildWindow($child_obj);
}

sub StoreFileUri {
  my ($self, $http, $dyn) = @_;
  $http->queue("StoreFile?obj_path=$self->{path}");
}

sub StoreFile {
  my ($self, $http, $dyn) = @_;
  my $method = $http->{method};
  my $content_type = $http->{header}->{content_type};
  unless($method eq "POST" && $content_type =~ /multipart/){
    print STDERR "No file posted\n";
    return;
  }
  $self->{UploadCount}++;
#  $http->ParseMultipartShouldWork("$self->{TempDir}/$self->{UploadCount}",
#    $self->UploadDone($http, $dyn));
  my $file = $http->ParseMultipart(
     "$self->{TempDir}/$self->{UploadCount}");
  &{$self->UploadDone($http, $dyn)}($file);
}

sub UploadDone {
  my ($self, $http, $dyn) = @_;
  my $sub = sub {
    my($file) = @_;
    unless(exists($self->{UploadQueue})){ $self->{UploadQueue} = [] }
    push(@{$self->{UploadQueue}}, $file);
    $self->InvokeAfterDelay("ServeUploadQueue", 0);
    $http->queue("<pre>");
    $http->queue("File uploaded into $file\n");
    for my $k (keys %$dyn){
      $http->queue("dyn{$k} = $dyn->{$k}\n");
    }
    for my $k (keys %$http){
      $http->queue("http{$k} = $http->{$k}\n");
    }
    for my $k (keys %{$http->{header}}){
      $http->queue("http{header}->{$k} = $http->{header}->{$k}\n");
    }
    $http->queue("<a href=\"Refresh?obj_path=$self->{path}\">Go back</a>");
    $http->queue("<hr><pre>");
    $self->InvokeAfterDelay("RefreshFileDiv", 0);
  };
  return $sub;
}

sub ServeUploadQueue {
  my ($self) = @_;
  unless($#{$self->{UploadQueue}} >= 0){ return }
  my $up_load_file = shift @{$self->{UploadQueue}};
  my $command = "ExtractUpload.pl \"$up_load_file\" \"$self->{TempDir}\"";
  my $hash = {};
  Dispatch::LineReader->new_cmd($command, $self->ReadConvertLine($hash),
    $self->ConvertLinesComplete($hash));
}

sub ReadConvertLine {
  my ($self, $hash) = @_;
  my $sub = sub {
    my($line) = @_;
    if($line =~ /^(.*):\s*(.*)$/){
      my $k = $1; my $v = $2;
      $hash->{$k} = $v;
    }
  };
  return $sub;
}
sub ImportFileIntoPosda {
  my ($self, $http, $dyn) = @_;
  my $index = $dyn->{index};
  my $f_info = $self->{UploadedFiles}->[$index];
  my $file = $f_info->{"Output file"};
  my $cmd = "ImportSingleFileIntoPosdaAndReturnId.pl \"$file\" " .
    "\"Importing Uploaded file into Posda\"";
  open COMMAND, "$cmd|";
  my $file_id;
  my $error;
  while(my $line = <COMMAND>){
    chomp $line;
    if($line =~ /^File id: (.*)$/){
      $f_info->{file_id} = $1;
    } elsif ($line =~ /^Error: (.*)$/) {
      $f_info->{import_error} = $1;
    }
  }
  $self->AutoRefresh;
  close COMMAND;
}
sub ConvertLinesComplete {
  my ($self, $hash) = @_;
  my $sub = sub {
    push(@{$self->{UploadedFiles}}, $hash);
    # Go ahead and load file into Posda DB
    my $file = $hash->{"Output file"};
    my $cmd = "ImportSingleFileIntoPosdaAndReturnId.pl \"$file\" " .
      "\"Importing Uploaded file into Posda\"";
    open COMMAND, "$cmd|";
    my $file_id;
    my $error;
    while(my $line = <COMMAND>){
      chomp $line;
      if($line =~ /^File id: (.*)$/){
        $hash->{file_id} = $1;
      } elsif ($line =~ /^Error: (.*)$/) {
        $hash->{import_error} = $1;
      }
    }
    close COMMAND;

    # If the file was a CSV, go ahead and load it as a table now
    unless(1){
      if (
        $hash->{'mime-type'} eq 'text/csv' ||
        $hash->{'mime-type'} eq 'application/vnd.ms-excel'
      ) {
        $self->LoadCSVIntoTable_NoMode($hash->{'Output file'});
      }
      if ($hash->{'mime-type'} =~ /zip/) {
        $self->ProcessCompressedFile($hash);
      }
    }
    $self->InvokeAfterDelay("ServeUploadQueue", 0);
  };
  return $sub;
}

sub ProcessCompressedFile {
  my ($self, $hash) = @_;
  my $mime_type = $hash->{'mime-type'};
  my $filename = $hash->{'Output file'};

  say STDERR "Processing file of type $mime_type";
  say STDERR "Filename: $filename";

  # Spawn a Subprocess to handle this operation

  my $sub = Posda::Subprocess->new("ExtractAndImportZip");
  $sub->set_commandline("ExtractAndImportZip.pl <?bkgrnd_id?> <notify> <filename>");
  $sub->set_params({
    notify => $self->get_user,
    filename => $filename
  });

  $sub->execute(sub {
  my ($ret) = @_;
      say STDERR Dumper($ret);
  });
}

sub RefreshFileDiv{
  my($this) = @_;
  $this->AutoRefreshDiv('file_report','Files');
};


sub SetFileDescription{
  my($this, $http, $dyn) = @_;
  my $index = $dyn->{index};
  my $data = $dyn->{value};
  $this->{UploadedFiles}->[$index]->{description} = $data;
}

sub UploadedFileCheckBox{
  my($this, $http, $dyn) = @_;
  my $index = $dyn->{index};
  my $checked = $dyn->{checked};
  $this->{UploadedFiles}->[$index]->{check_box} = $checked;
}

sub DismissSelectedUploads{
  my($this, $http, $dyn) = @_;
  my @Remaining;
  for my $f (@{$this->{UploadedFiles}}){
    unless($f->{check_box} eq "true"){
      push @Remaining, $f;
    }
  }
  $this->{UploadedFiles} = \@Remaining;
}

sub ChainUploadedSpreadsheet{
  my($self, $http, $dyn) = @_;
  my $index = $dyn->{index};
  my $file_id = $self->{UploadedFiles}->[$index]->{file_id};
  my $path;
  Query("FilePathByFileId")->RunQuery(sub{
    my($row) = @_;
    $path = $row->[0];
  }, sub {}, $file_id);
  my $cmd = "CsvToPerlStruct.pl \"$path\"";
  $self->SemiSerializedSubProcess($cmd, $self->ChainCsvLoaded($file_id, $index));
  $self->{WaitingOnChainCsvConversion} = 1;
}
sub ChainCsvLoaded{
  my($self, $file_id, $index) = @_;
  my $sub = sub {
    my($status, $struct) = @_;
    if($status eq "Succeeded"){
      delete $self->{WaitingOnChainCsvConversion};
      $self->{ChainedUploadedSpreadsheetAvailable} = {
        file_id => $file_id,
        index => $index,
        struct => $struct,
      };
    } else {
      $self->{ChainCsvLoadedError} = $struct;
    }
    #$self->AutoRefreshDiv('file_report','Files');
    $self->InvokeAfterDelay("RefreshFileDiv", 0);
  };
  return $sub;
}
sub ProcessConvertedUploadedSpreadsheet{
  my($self, $http, $dyn) = @_;
  my $params = {
#    input_file_id => $dyn->{file_id},
    bindings => $self->{BindingCache},
    current_settings => { notify => $self->get_user },
  };
  if(defined($self->{ActivitySelected}) && $self->{ActivitySelected}){
    $params->{current_settings}->{activity_id} = $self->{ActivitySelected};
    Query("LatestActivityTimepointForActivity")->RunQuery(sub{
      my($row) = @_;
      $params->{current_settings}->{activity_timepoint_id} = $row->[0];
    }, sub {}, $self->{ActivitySelected});
  }
  my @rows;
  my $cols = $dyn->{struct}->{rows}->[0];
  for my $i (1 .. $#{$dyn->{struct}->{rows}}){
    my $h;
    my $e = $dyn->{struct}->{rows}->[$i];
    for my $j (0 .. $#{$e}){
      $h->{$cols->[$j]} = $e->[$j];
    }
    push @rows, $h;
  }
  $params->{rows} = \@rows;
  $params->{cols} = $cols;
  if(exists $params->{rows}->[0]->{Operation}){
    my $operation =
      $self->GetOperationDescription($params->{rows}->[0]->{Operation});
    if(defined $operation){
      $params->{command} = $operation;
      return $self->ProcessConvertedUploadedNamedSpreadsheet($http, $dyn, $params);
    }
  }
  $params->{invocation} = {
    type => "UploadedUnnamedSpreadsheet",
    file_id => $dyn->{file_id},
  };
  my $class = "Posda::ProcessUploadedSpreadsheetWithNoOperation";
  eval "require $class";
  if($@){
    print STDERR "$class failed to compile\n\t$@\n";
    return;
  }
  unless(exists $self->{sequence_no}){$self->{sequence_no} = 0}
  my $name = "UploadedUnnamedSpreadsheet_$self->{sequence_no}";
  $params->{Operations} = $self->{Commands};
  $self->{sequence_no}++;


   #they uploaded the wrong spreadsheet
   my $child_path = $self->child_path($name);
   my $child_obj = $class->new($self->{session},
                               $child_path, $params);
   $self->StartJsChildWindow($child_obj);

}

sub ProcessConvertedUploadedNamedSpreadsheet{
  my($self, $http, $dyn, $params) = @_;
  my %arg_map;
  my $fr = $params->{rows}->[0];
  $params->{invocation} = {
    type => "UploadedNamedSpreadsheet",
    file_id => $dyn->{file_id},
  };
  for my $arg (@{$params->{command}->{args}}){
    if(exists($fr->{$arg}) && defined($fr->{$arg})){
      $arg_map{$arg} = $fr->{$arg};
    }
  }
  $params->{prior_ss_args} = \%arg_map;
  $self->{args} = {};
  $self->{meta_args} = {};
  $self->{params} = $params;

  for my $arg (@{$self->{params}->{command}->{args}}){
      $self->{args}->{$arg}  = ["from spreadsheet", $self->{params}->{prior_ss_args}->{$arg}];
  }
  my $cmd = $self->{params}->{command}->{command_line};
  if($cmd =~ /^([^\s]*)\s/){
    $prog = $1;
    my $effective_prog;
    open FOO, "which $prog|";
    while(my $line = <FOO>){ $effective_prog .= $line };
    chomp $effective_prog;
    $self->{EffectiveProg} = $effective_prog;
  }
  $self->SetDefaultInput;
  $self->{mode} = "initial";

  if($self->can("AutoRefresh")){
    $self->AutoRefresh;
  }
}

sub GetOperationDescription{
  my($this, $operation_name) = @_;
  my $operation;
#  print STDERR "In GetOperationDescription - $operation_name \n";
  Query('GetSpreadsheetOperationByName')->RunQuery(sub{
    my($row) = @_;
    my($operation_name, $command_line, $operation_type,
      $input_line_format, $tags, $can_chain) = @$row;
    $operation->{operation_name} = $operation_name;
    $operation->{command_line} = $command_line;
    $operation->{operation_type} = $operation_type;
    $operation->{input_line_format} = $input_line_format;
  }, sub{}, $operation_name);
  if(defined $operation){
    my($fields, $args, $meta_args) = $this->BuildFieldsAndArgs($operation);
    $operation->{fields} = $fields;
    $operation->{args} = $args;
    $operation->{meta_args} = $meta_args;
    return $operation
  }
  return undef;
}
sub BuildFieldsAndArgs{
  my($this, $operation) = @_;
  my(@fields, @args, @meta_args);
  my $remaining = $operation->{command_line};
  while($remaining =~ /[^<]*<([^>]+)>(.*)$/){
    my $arg = $1;
    $remaining = $2;
    if($arg =~ /^\?(.*)\?$/){
      my $meta_arg = $1;
      push @meta_args, $meta_arg
    } else {
      my $arg = $1;
      push @args, $arg;
    }
  }
  $remaining = $operation->{input_line_format};
  while($remaining =~ /[^<]*<([^>]+)>(.*)$/){
    my $field = $1;
    $remaining = $2;
    push @fields, $field;
  }
  return \@fields, \@args, \@meta_args;
}

sub Files{
  my($self, $http, $dyn) = @_;
  if(exists $self->{ChainCsvLoadedError}){
    print STDERR "ChainCscLoadedError: ";
    Debug::GenPrint($dbg, $self->{ChainCsvLoadedError}, 1);
    print STDERR "\n";
    delete $self->{ChainCsvLoadedError};
  }
  if(exists $self->{WaitingOnChainCsvConversion}) {
    $http->queue("Waiting on Csv Conversion");
    return;
  }
  if(exists $self->{ChainedUploadedSpreadsheetAvailable}){
    my $ndyn = $self->{ChainedUploadedSpreadsheetAvailable};
    delete $self->{ChainedUploadedSpreadsheetAvailable};
    return $self->ProcessConvertedUploadedSpreadsheet($http, $ndyn);
  }
  unless(exists $self->{UploadedFiles}) { $self->{UploadedFiles} = [] }
  my $num_files = @{$self->{UploadedFiles}};
  if($num_files == 0){
    return $self->RefreshEngine($http, $dyn, "No files have been uploaded");
  }
  $self->RefreshEngine($http, $dyn,
    '<table class="table table-striped table-condensed">' .
    '<tr><th colspan="6"><p>Files Uploaded</p></th></tr>'.
    '<tr><th><p>file_name</p></th><th><p>size</p></th><th><p>mime_type</p></th>' .
    '<th><p>description</p></th><th>' .
    '<?dyn="NotSoSimpleButton" ' .
    'caption="Dismiss" ' .
    'op="DismissSelectedUploads" ' .
    "sync=\"UpdateDiv('file_report','Files');\" " .
    'class="btn btn-primary"?>' .
    '</th><th><p>file_id</p></th></tr>');
  file:
  for my $in(0 .. $#{$self->{UploadedFiles}}){
    my $i = $self->{UploadedFiles}->[$in];
    my $path = $i->{"Output file"};
    my $file;
    if($path =~ /\/([^\/]+)$/){
      $file = $1;
    } else {
      $file = $path;
    }
    my $type = $i->{"mime-type"};
    my $size  = $i->{length};
    unless(exists $i->{file_type}){
      my $file_type = `file \"$path\"`;
      chomp $file_type;
      if($file_type =~ /^.*:(.*)$/){
        $i->{file_type} = $1;
      } else {
        $i->{file_type} = $file_type;
      }
    }
    $self->RefreshEngine($http, $dyn, '<tr>' .
      "<td><p>$file</p></td>" .
      "<td><p>$size</p></td><td><p>");

    $self->RefreshEngine($http, $dyn, $type .
      (
        ($type eq "text/csv" || $type eq "application/vnd.ms-excel") ?
          '<?dyn="NotSoSimpleButton" ' .
          'caption="chain" ' .
          'op="ChainUploadedSpreadsheet" ' .
          "index=\"$in\" " .
          "sync=\"UpdateDiv('file_report','Files');\" " .
         'class="btn btn-primary"?>'
        :
         ""
      ) .
      "</p></td><td><p>");
      unless(defined $i->{description}) {$i->{description} = $i->{file_type}}
      $self->BlurEntryBox($http, {
        name => "Filter",
        op => "SetFileDescription",
        id => "FileDescriptionEntryBox_$in",
        index => $in,
        value => "$i->{description}",
        size => 30,
      }, "");
    $self->RefreshEngine($http, $dyn, "</p></td><td><p>");
    $http->queue(
      $self->CheckBoxDelegate("group", "value",
       ($i->{check_box} eq "true") ? 1: 0,
      {
        op => "UploadedFileCheckBox",
        index => $in,
      })
    );
    $http->queue("</p></td>");
    $http->queue("<td><p>");
    $http->queue($self->{UploadedFiles}->[$in]->{file_id});
    $self->RefreshEngine($http, $dyn, '</p></td></tr>');
  }
  $self->RefreshEngine($http, $dyn,
    '<tr><td colspan="4"></td><td><p>' .
    '<?dyn="NotSoSimpleButton" ' .
    'caption="Annotation" ' .
    'op="AnnotateSelectedUploads" ' .
    "sync=\"UpdateDiv('file_report','Files');\" " .
    'class="btn btn-primary"?></p>' .
    '</td></tr>');
  $self->RefreshEngine($http, $dyn, '</table>');
}

sub AnnotateSelectedUploads{
  my($self, $http, $dyn) = @_;
#  my $class = "Posda::NewProcessPopup";
  my $class = "Posda::NewerProcessPopup";
  eval "require $class";
  if($@){
    print STDERR "$class failed to compile\n\t$@\n";
    return;
  }
  my @selected_files;
  for my $f (@{$self->{UploadedFiles}}){
    if($f->{check_box} eq "true"){
      my $name = $f->{"Output file"};
      if($name =~ /\/([^\/]+)$/){
        $name = $1;
      }
      my $nf = {
        file_id => $f->{file_id},
        mime_type => $f->{"mime-type"},
        description => $f->{description},
        file_name => $name,
      };
      push @selected_files, $nf;
    }
  }
  my $params = {
    bindings => $self->{BindingCache},
    current_settings => { notify => $self->get_user },
    rows => \@selected_files,
  };
  if(defined($self->{ActivitySelected}) && $self->{ActivitySelected}){
    $params->{current_settings}->{activity_id} = $self->{ActivitySelected};
    Query("LatestActivityTimepointForActivity")->RunQuery(sub{
      my($row) = @_;
      $params->{current_settings}->{activity_timepoint_id} = $row->[0];
    }, sub {}, $self->{ActivitySelected});
  }
  unless(exists $self->{sequence_no}){$self->{sequence_no} = 0}
  my $name = "Annotate_$self->{sequence_no}";
  $self->{sequence_no}++;

  my $child_path = $self->child_path($name);

  my $operation = {
    operation_name => "AnnotateTimeline",
    command_line => "InsertListOfAnnotatedFiles.pl <?bkgrnd_id?> \"<comment>\" <notify>",
    operation_type => "background_subprocess",
    input_line_format => "<file_id>&<file_name>&<mime_type>&<description>",
    create_file_from_rows => 1,
  };
  my($fields, $args, $meta_args) = $self->BuildFieldsAndArgs($operation);
  $operation->{fields} = $fields;
  $operation->{args} = $args;
  $operation->{meta_args} = $meta_args;
  $params->{command} = $operation;
  $params->{cols} = $params->{command}->{fields};
  my $child_obj = $class->new($self->{session},
                              $child_path, $params);
  $self->StartJsChildWindow($child_obj);
}
1;
