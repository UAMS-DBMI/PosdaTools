package ActivityBasedCuration::Application;

use DbIf::Table;
use File::Path 'rmtree';
use Posda::DB::PosdaFilesQueries;
use Posda::DB 'Query', 'GetHandle';
use Dispatch::BinFragReader;

use Modern::Perl '2010';
use Method::Signatures::Simple;
use Storable;
use File::Basename 'basename';
use DateTime;

use Regexp::Common "URI";

use Dispatch::LineReaderWriter;

use GenericApp::Application;

use Posda::Passwords;
use Posda::Config ('Config', 'Database');
use Posda::ConfigRead;
use Posda::Inbox;
use DBI;


use Posda::DebugLog;
use Posda::UUID;
use Posda::Subprocess;
use Posda::BackgroundQuery;
use Data::Dumper;

use HTML::Entities;

use Posda::PopupImageViewer;
#use Posda::PopupCompare;
use Posda::PopupCompareFiles;
use Posda::PopupCompareFilesPath;
use Posda::FileViewerChooser;

use DbIf::PopupHelp;
use Posda::QueryLog;

use Text::Markdown 'markdown';

use Debug;
my $dbg = sub {print STDERR @_ };

use vars '@ISA';
@ISA = ("GenericApp::Application");

func titlize($string) {
  join(' ', map {ucfirst} split('_', $string));
}



sub SpecificInitialize {
  my($self, $session) = @_;

  $self->{inbox} = Posda::Inbox->new($self->get_user);
  $self->{QueryFilterDisplay} = 1;
  $self->{AllArgs} = {};
  for my $a (@{PosdaDB::Queries->GetAllArgs()}) {
    $self->{AllArgs}->{$a} = 1;
  }
  $self->{MenuByMode} = {
    Default => [
      {
        caption => 'Inbox',
        op => 'SetMode',
        mode => 'Inbox',
        sync => 'Update();',
      },
      {
        caption => "Upload",
        op => 'SetMode',
        mode => 'Upload',
        sync => 'Update();'
      },
      {
        caption => "Activity",
        op => 'SetMode',
        mode => 'Activities',
        sync => 'Update();'
      },
      {
        caption => "Download",
        op => 'SetMode',
        mode => 'DownloadTar',
        sync => 'Update();'
      },
      {
        caption => "ShowBackground",
        op => 'SetMode',
        mode => 'ShowBackground',
        sync => 'Update();'
      },
      {
        caption => "Files",
        op => 'SetMode',
        mode => 'Files',
        sync => 'Update();'
      },
      {
        caption => "Tables",
        op => 'SetMode',
        mode => 'Tables',
        sync => 'Update();'
      },
    ],

    NewQuery => [
      {
        caption => "Cancel",
        op => 'SetMode',
        mode => 'ListQueries',
        sync => 'Update();'
      },
      {
        caption => "Save",
        op => 'SetMode',
        mode => 'SaveQuery',
        sync => 'Update();'
      },
    ],
  };


  $self->{Mode} = "Activities";
  $self->{Sequence} = 0;
  my $dbif_dir = "$self->{Environment}->{UserInfoDir}/DbIf";
  unless(-d $dbif_dir){
    unless(mkdir $dbif_dir) {
      die "Can't mkdir $dbif_dir";
    }
  }
  my $user_dir = "$dbif_dir/" . $self->get_user;
  unless(-d $user_dir){
    unless(mkdir $user_dir) {
      die "Can't mkdir $user_dir";
    }
  }

  my $temp_dir = "$self->{Environment}->{LoginTemp}/$self->{session}";
  unless(-d $temp_dir) { die "$temp_dir doesn't exist" }
  $self->{TempDir} = $temp_dir;
  $self->{UploadCount} = 0;

  $self->{BindingCache} = $self->RetrieveBindingCacheFromDb;

  # Build the command list from database
  my $commands = {};
  map {
    my ($name, $cmdline, $type, $input_line, $tags) = @$_;

    $commands->{$name} = { cmdline => $cmdline,
                           parms => [$cmdline =~ /<([^<>]+)>/g],
                           operation_name => $name              };
    if (defined $input_line) {
      $commands->{$name}->{pipe_parms} = $input_line;
    }
    $commands->{$name}->{type} = $type;
  } sort @{PosdaDB::Queries->GetOperations()};

  $self->{Commands} = $commands;


  $self->BackgroundMonitorForEmail;
}
sub StoreBindingCacheInDb{
  my($self) = @_;
  my $bc = $self->RetrieveBindingCacheFromDb;
  for my $k (keys %{$self->{BindingCache}}){
    unless(exists $bc->{$k}){
      $self->CreateBindingCacheInfoForKeyInDb($k);
      next;
    }
    if($self->{BindingCache}->{$k} ne $bc->{$k}){
      $self->UpdateBindingValueInDb($k);
    }
  }
}
sub RetrieveBindingCacheFromDb{
  my($self) = @_;
  my $bc;
  Query("GetUsersBoundVariables")->RunQuery(sub {
    my($row) = @_;
    my($user, $variable, $binding) = @$row;
    $bc->{$variable} = $binding;
  }, sub {}, $self->get_user);
  return $bc;
}
sub CreateBindingCacheInfoForKeyInDb{
  my($self, $key) = @_;
  my $user = $self->get_user;
  my $value = $self->{BindingCache}->{$key};
  Query("InsertUserBoundVariable")->RunQuery(sub{
  }, sub{}, $user, $key, $value);
}
sub UpdateBindingValueInDb{
  my($self, $key) = @_;
  my $user = $self->get_user;
  my $value = $self->{BindingCache}->{$key};
  Query("UpdateUserBoundVariable")->RunQuery(sub{
  },sub{}, $value, $user, $key);
}

sub BackgroundMonitorForEmail {
  my($self) = @_;
  #TODO: make this display unread if there are unread,
  #      or undismissed if if there are no unread
  #      or none if there are no unread AND no undismissed
  Dispatch::Select::Background->new(func($disp) {
    my $count = $self->{inbox}->UnreadCount;

    my $last_count = 0;
    if (defined $self->{MenuByMode}->{Default}->[0]->{count}) {
      $last_count = $self->{MenuByMode}->{Default}->[0]->{count};
    }

    if ($count > 0 && $count != $last_count) {
      $self->{MenuByMode}->{Default}->[0]->{class} = 'btn btn-danger';
      $self->{MenuByMode}->{Default}->[0]->{caption} = "Inbox ($count)";
      $self->{MenuByMode}->{Default}->[0]->{count} = $count;
      $self->AutoRefresh;
    }

    if ($count == 0 && $count != $last_count) {
      $self->{MenuByMode}->{Default}->[0]->{class} = 'btn btn-default';
      $self->{MenuByMode}->{Default}->[0]->{caption} = "Inbox";
      $self->{MenuByMode}->{Default}->[0]->{count} = $count;
      $self->AutoRefresh;
    }

    $disp->timer(10);
  })->queue();
}
sub Inbox {
  my($self, $http, $dyn) = @_;
  my $unread_items = $self->{inbox}->AllUndismissedItems;
  my $user = $self->get_user;

  # list items
  $http->queue(qq{
    <h2>Message Inbox for $user</h2>
    <table class="table">
      <tr>
        <th>Message ID</th>
        <th>Operation</th>
        <th>Status</th>
        <th>Created Date</th>
      </tr>
  });

  for my $item (@$unread_items) {
    $http->queue(qq{
        <tr>
          <td>
    });

    $self->NotSoSimpleButton($http, {
      caption => $item->{user_inbox_content_id},
      op => "DisplayInboxItem",
      sync => 'Update();',
      message_id => $item->{user_inbox_content_id}
    });

    $http->queue(qq{
          </td>
          <td>$item->{operation_name}</td>
          <td>$item->{current_status}</td>
          <td>$item->{date_entered}</td>
        </tr>
    });
  }
  $http->queue(qq{
    </table>
  });
}

sub DisplayInboxItem {
  my($self, $http, $dyn) = @_;
  DEBUG "Setting selected Inbox Item to: $dyn->{message_id}";

  $self->{SelectedInboxItem} = $dyn->{message_id};
  $self->{Mode} = "InboxItem";
}

sub DeleteAndDismiss {
  my($self, $http, $dyn) = @_;
  print STDERR "deleting inbox_item: $self->{SelectedInboxItem}\n" .
    "rm -rf $dyn->{path}\n";
  $self->{inbox}->SetDismissed($self->{SelectedInboxItem});
  rmtree($dyn->{path});
  $self->{Mode} = "Inbox";
}

sub DismissInboxItemButtonClick {
  my($self, $http, $dyn) = @_;
  my $message_id = $dyn->{message_id};
  $self->{inbox}->SetDismissed($message_id);
  $self->{Mode} = "Inbox";
}

sub FileInboxItemButtonClick {
  my($self, $http, $dyn) = @_;
  my $message_id = $dyn->{message_id};
  my $q = Query('InsertActivityInboxContent');
  $q->RunQuery(sub {}, sub{}, $self->{ActivitySelected}, $message_id);
  $self->{inbox}->SetDismissed($message_id);
  $self->{Mode} = "Inbox";
}

sub ForwardInboxItemButtonClick {
  my($self, $http, $dyn) = @_;
  say STDERR "ForwardInboxItemButtonClick called";

  my $message_id = $dyn->{message_id};


  $self->{_ForwardInboxButtonClicked} = 1;
}

sub DrawForwardForm {
  my($self, $http, $dyn) = @_;
  if (not defined $self->{_UsernameCache}) {
    $self->{_UsernameCache} = $self->{inbox}->GetAllUsernames;
  }
  my @all_users = map {
    $_->{user_name}
  } @{$self->{_UsernameCache}};

#  say STDERR Dumper(\@all_users);

  if (not defined $self->{_ForwardInboxButtonClicked}) {
    $self->NotSoSimpleButtonButton($http, {
      caption => "Forward this message",
      op => "ForwardInboxItemButtonClick",
    });
  } else {
    $http->queue(qq{
      <p>
      <div class="form-group" style="width: 200px">
    });
    $self->SimpleJQueryForm($http, {
        id => 'forwardform',
        op => 'ForwardFormSubmitButtonClicked',
        class => 'alert alert-info form',
    });
    $http->queue(qq{
      <p>Forward this message to:</p>
      <p>
    });

    $self->SimpleDropdownListFromArray($http, {
        name => "username",
    }, \@all_users);

    $http->queue(qq{
      </p>
      <p><button type="submit" class="btn btn-primary">Do it</button></p>
      </form>
      </div>
      </p>
    });
  }
}

sub ForwardFormSubmitButtonClicked{
  my($self, $http, $dyn) = @_;
  my $forward_to_user = $dyn->{username};
  my $message_id = $self->{SelectedInboxItem};

  $self->{inbox}->Forward($message_id, $forward_to_user);
  delete $self->{_ForwardInboxButtonClicked};
}

sub InboxItem {
  my($self, $http, $dyn) = @_;
  my $message_id = $self->{SelectedInboxItem};
  my $msg_details = $self->{inbox}->ItemDetails($message_id);
  my $file_content = $self->{inbox}->ReportContent($msg_details->{file_id});

  # Turn any URLs into actual links
  $file_content =~    s( ($RE{URI}{HTTP}) )
                (<a href="$1">$1</a>)gx  ;

  my $date_dismissed;
  if (defined $msg_details->{date_dismissed}) {
    $date_dismissed = $msg_details->{date_dismissed};
  } else {
    $date_dismissed = '';
  }

  $http->queue(qq{
    <table class="table">
      <tr>
        <th>Status</th>
        <th>Date Entered</th>
        <th>Date Dismissed</th>
      </tr>
      <tr>
        <td>$msg_details->{current_status}</td>
        <td>$msg_details->{date_entered}</td>
        <td>$date_dismissed</td>
      </tr>
    </table>
    <pre>$file_content</pre>
  });


  if (not defined $msg_details->{date_dismissed}) {
    $self->SelfConfirmingButton($http, {
      uniq_id => 'dismiss_button',
      caption => 'Dismiss this message',
      op => 'DismissInboxItemButtonClick',
      message_id => $message_id
    });
  }

  if (not defined $msg_details->{date_dismissed}) {
    $self->SelfConfirmingButton($http, {
      uniq_id => 'file_button',
      caption => 'File this message',
      op => 'FileInboxItemButtonClick',
      message_id => $message_id
    });
  }

  $self->DrawForwardForm($http, $dyn);
  # $self->SelfConfirmingButton($http, {
  #   uniq_id => 'forward_button',
  #   caption => 'Forward this message',
  #   op => 'ForwardInboxItemButtonClick',
  #   message_id => $message_id
  # });

  my $recent_operations = $self->{inbox}->RecentOperations($message_id);
  $http->queue(qq{
    <h4>Recent operations on this message</h4>
    <table class="table">
      <tr>
        <th>What</th>
        <th>When</th>
        <th>Who</th>
        <th>How</th>
      </tr>
  });
  for my $op (@$recent_operations) {
    $http->queue(qq{
      <tr>
        <td>$op->{operation_type}</td>
        <td>$op->{when_occurred}</td>
        <td>$op->{invoking_user}</td>
        <td>$op->{how_invoked}</td>
      </tr>
    });
  }
  $http->queue(qq{
    </table>
  });

  # Only mark as read if it wasn't already marked as read
  # Bill asked for this to be modified to always mark as read, upon reading
  # TODO: This should actually be modified such that it changes
  # the status to read only if the current status is a "non-read" status.
  # ie, in the future we may have a 'forwarded' status, this would
  # be considered a 'read' status and SetRead() should not change the
  # status (though it should still log a read event to the operations
  # table)
  # if ($msg_details->{current_status} ne 'read') {
  $self->{inbox}->SetRead($message_id);
  # }

}


sub MakeMenuByMode{
  my($self, $mode) = @_;
  # Make the menu item to be used by MakeMenu inside
  # MenuResponse. Basically: There is a default set
  # of menu entires, and for some modes, additional entries
  # are appended on.

  my $default_menu = $self->{MenuByMode}->{Default};
  my $mode_menu = $self->{MenuByMode}->{$mode};

  my @final_menu;

  if (not defined $mode_menu) {
    @final_menu = @$default_menu;
  } else {
    @final_menu = (@$default_menu, { type => 'hr' }, @$mode_menu);
  }


  return \@final_menu;
}
sub MenuResponse {
  my($self, $http, $dyn) = @_;
  my $menu = $self->MakeMenuByMode($self->{Mode});
  $self->MakeMenu($http, $dyn, $menu);
  # $self->DrawRoles($http, $dyn);
}

sub SetMode{
  my($self, $http, $dyn) = @_;
  $self->{Mode} = $dyn->{mode};
}

sub ScriptButton {
  my($self, $http, $dyn) = @_;
  my $inbox_item = $self->{SelectedInboxItem};
  if($self->can("$dyn->{op}")){
    my $op = $dyn->{op};
    return $self->$op($http, $dyn);
  }
  print STDERR "Script button - Unknown op: $dyn->{op}\n";
}

sub DownloadSpecifiedFileById {
  my($self, $http, $dyn) = @_;
  my $shortname = $dyn->{targ_name};
  my $file_id = $dyn->{file_id};
  my $mime_type = $dyn->{mime_type};
print STDERR "DownloadSpecifiedFileById(" .
  "$file_id, \"$shortname\", \"$mime_type\")";
for my $i (keys %$dyn){
  print STDERR "dyn{$i} = \"$dyn->{$i}\"\n";
}
  my $filename;
  Query('GetFilePath')->RunQuery(sub{
    my($row) = @_;
    $filename = $row->[0];
  }, sub {}, $file_id);

  my $fh;
  if(open $fh, $filename) {
    $http->DownloadHeader($mime_type, $shortname);
    Dispatch::Select::Socket->new(
      $self->SendFile($http),
    $fh)->Add("reader");
  } else {
    print STDERR "Can't open file $filename\n";
  }

}
sub HeaderResponseTest{
  my($self, $http, $dyn) = @_;
  $http->queue("Test");
}

sub ContentResponse {
  my($self, $http, $dyn) = @_;
  # TODO: DrawHistory would preferrably be above the title on the page
  if($self->{Mode} eq "ScriptButton"){
    return($self->ScriptButtonResponse($http, $dyn));
  }
  unless ($self->{Mode} =~ /Inbox/) {
    $http->queue(qq{
      <div style="display: flex; flex-direction: row; align-items: flex-end; margin-bottom: 5px">
    });
    $http->queue(qq{</div>});
  }

  if ($self->can($self->{Mode})) {
    my $meth = $self->{Mode};
    $self->$meth($http, $dyn);
  } else {
    $http->queue("Unknown mode: $self->{Mode}");
  }
}

sub GetLoadedTables() {
  my($self) = @_;
  my @tables;
  for my $in(0 .. $#{$self->{LoadedTables}}){
    my $i = $self->{LoadedTables}->[$in];
    my $type = $i->{type};
    my $type_disp;
    my $num_rows;
    my $name;
    if($type eq "FromCsv") {
      $type_disp = "From CSV Upload";
      $num_rows = @{$i->{rows}} - 1;
      $name = $i->{basename};
    } elsif ($type eq "FromQuery"){
      $type_disp = "From DB Query";
      $num_rows = @{$i->{rows}};
      $name = "$i->{query}->{schema}:$i->{query}->{name}(";
      for my $bi (0 .. $#{$i->{query}->{bindings}}){
        my $b = $i->{query}->{bindings}->[$bi];
        $name .= "\"$b\"";
        unless($bi == $#{$i->{query}->{bindings}}){
          $name .= ", ";
        }
      }
      $name .= ")";
    }
    push @tables, $name;
  }

  return @tables;
}


sub OpenTableLevelPopup{
  my($self, $http, $dyn) = @_;
print STDERR "In OpenTableLevelPopup\n";
  my $table;
  my $parms;
  if($self->{Mode} eq "Activities"){
    $table = $self->{ForegroundQueries}->{$self->{NewQueryToDisplay}};
    $parms = { table => $table, button => $dyn->{cap_},
      filter_mode => $self->{FilterSelection}->{$self->{NewQueryToDisplay}}};
  } else {
    $table = $self->{LoadedTables}->[$self->{SelectedTable}];
    $parms = { table => $table, button => $dyn->{cap_}};
  }

  my $unique_val = "$parms";

  my $class = $dyn->{class_};
  $self->OpenPopup($class, "${class}_FullTable$unique_val", $parms);
}

my $table_free_seq = 0;
sub OpenTableFreePopup {
  my($self, $http, $dyn) = @_;
print STDERR "In OpenTableFreePopup\n";
  my $parms = { button => $dyn->{cap_}};
  for my $i (keys %{$dyn}){
    unless(
      $i eq "cap_" || $i eq "class_" ||
      $i eq "obj_path" || $i eq "op" || $i eq "ts"
    ){
      $parms->{$i} = $dyn->{$i};
    }
  }
  $table_free_seq += 1;
  my $unique_val = "seq_$table_free_seq";

  my $class = $dyn->{class_};
  $self->OpenPopup($class, "${class}_FullTable_$unique_val", $parms);
}

sub OpenDynamicPopup {
  my($self, $http, $dyn) = @_;
for my $i (keys %{$dyn}){
  print STDERR "dyn{$i}: $dyn->{$i}\n";
}
  my $table;
  if($self->{Mode} eq "Activities") {
    $table = $self->{ForegroundQueries}->{$self->{NewQueryToDisplay}};
  } else {
    $table = $self->{LoadedTables}->[$self->{SelectedTable}];
  }
  if(!exists $table->{type}){
    my $cols = $table->{query}->{columns};
    my $rows;
    if($self->{FilterSelection}->{$self->{NewQueryToDisplay}} eq "unfiltered"){
     $rows = $table->{rows};
    } else {
     $rows = $table->{filtered_rows};
    }
    my $row = $rows->[$dyn->{row}];

    # build hash for popup constructor
    my $h = {};
    for my $i (0 .. $#{$row}) {
      $h->{$cols->[$i]} = $row->[$i];
    }
    $h->{button} = $dyn->{cap_};

    my $unique_val = "$h";

    my $class = $dyn->{class_};
    my $row_id = $dyn->{row};

    $self->OpenPopup($class, "${class}_Row$row_id$unique_val", $h);
  } elsif($table->{type} eq "FromQuery"){
    my $cols = $table->{query}->{columns};
    my $rows = $table->{rows};
    my $row = $rows->[$dyn->{row}];

    # build hash for popup constructor
    my $h = {};
    for my $i (0 .. $#{$row}) {
      $h->{$cols->[$i]} = $row->[$i];
    }
    $h->{button} = $dyn->{cap_};

    my $unique_val = "$h";

    my $class = $dyn->{class_};
    my $row_id = $dyn->{row};

    $self->OpenPopup($class, "${class}_Row$row_id$unique_val", $h);
  } elsif ($table->{type} eq 'FromCsv') {

    my $file = $table->{file};
    my $rows = $table->{rows};
    my $row = $rows->[$dyn->{row}];
    my $cols = $rows->[0]; # column names in first row

    # build hash for popup constructor
    my $h = {};
    for my $i (0 .. $#{$row}) {
      $h->{$cols->[$i]} = $row->[$i];
    }
    my $unique_val = "$h";

    my $class = $dyn->{class_};
    my $row_id = $dyn->{row};

    $self->OpenPopup($class, "${class}_Row$row_id$unique_val", $h);
  }
}

sub OpenPopup {
  my($self, $class, $name, $params) = @_;
#    say STDERR "OpenDynamicPopup, executing $class using params:";
#    print STDERR Dumper($params);
  print STDERR "################\nOpenPopup\nclass: $class\n";
  print STDERR "name: $name\n################\n";


  if ($class eq 'choose') {
    $class = Posda::FileViewerChooser::choose($params->{file_id});
    delete $params->{spreadsheet_file_id};
  } elsif ($class eq 'choose_from'){
    $params->{file_id} = $params->{from_file_id};
    $class = Posda::FileViewerChooser::choose($params->{file_id});
  } elsif ($class eq 'choose_to'){
    $params->{file_id} = $params->{to_file_id};
    $class = Posda::FileViewerChooser::choose($params->{file_id});
  } elsif ($class eq 'choose_spreadsheet'){
    $params->{file_id} = $params->{spreadsheet_file_id};
    $class = Posda::FileViewerChooser::choose($params->{file_id});
  }
  unless(defined $class){ return }

  # if Quince, do it differently:
  if ($class eq 'Quince') {
    $self->OpenQuince($name, $params);
    return;
  }

  eval "require $class";
  if($@){
    print STDERR "Class failed to compile\n\t$@\n";
    return;
  }

  my $child_path = $self->child_path($name);
  my $child_obj = $class->new($self->{session},
                              $child_path, $params);
  $self->StartJsChildWindow($child_obj);
}

sub OpenQuince {
  my($self, $name, $params) = @_;
  my $external_hostname = Config('external_hostname');
  my $quince_url = "http://$external_hostname/viewer";
  my $mode;
  my $val;

  if (defined $params->{file_id}) {
    $mode = 'file';
    $val = $params->{file_id};
  } elsif (defined $params->{series_instance_uid}) {
    $mode = 'series';
    $val = $params->{series_instance_uid};
  }

  my $cmd = "rt('$name', '$quince_url/$mode/$val', 600, 800, 0);";
  $self->QueueJsCmd($cmd);
}

sub DrawSpreadsheetOperationList {
  my($self, $http, $dyn, $selected_tags) = @_;
  my @q_list = @{PosdaDB::Queries->GetOperationsWithTags($selected_tags)};
  $http->queue(qq{
    <div class="panel panel-info">
      <div class="panel-heading">
        Spreadsheet Operations associated with the selected tags
      </div>

        <table class="table">
          <tr>
            <th>Name</th>
            <th>Command Line</th>
            <th>Input Format</th>
            <th>Help</th>
          </tr>
  });
  $self->{spreadsheet_op_list} = {};
  for my $row (@q_list) {
    my ($name, $cmdline, $op_type, $input_fmt, $tags) = @$row;
    $self->{spreadsheet_op_list}->{$name} = $row;

    if (not defined $input_fmt) {
      $input_fmt = '';
    }

    # Escape html codes
    $name = encode_entities($name);
    $cmdline = encode_entities($cmdline);
    $op_type = encode_entities($op_type);
    $input_fmt = encode_entities($input_fmt);

    $self->RefreshEngine($http, $dyn, qq{
      <tr>
        <td>$name</td>
        <td>$cmdline</td>
        <td>$input_fmt</td>
        <td><?dyn="NotSoSimpleButton" op="OpHelp" caption="H" cmd="$name" sync="Update();"?></td>
      </tr>
    });

  }
  $http->queue(qq{
        </table>
    </div>
  });
}

method OpHelp($http, $dyn) {

  my $details = $self->{spreadsheet_op_list}->{$dyn->{cmd}};


  my $child_path = $self->child_path("PopupHelp_$dyn->{cmd}");
  my $child_obj = DbIf::PopupHelp->new($self->{session},
                                              $child_path, $details);
  $self->StartJsChildWindow($child_obj);
}
method OpenBackgroundQuery($http, $dyn){

  my $details = {
    query_name => $dyn->{query_name},
    user => $self->get_user,
    #SavedQueriesDir => $self->{SavedQueriesDir},
    BindingCache => $self->{BindingCache},
  };

  my $child_path = $self->child_path("BackgroundQuery_$dyn->{query_name}");
  my $child_obj = Posda::BackgroundQuery->new($self->{session},
                                              $child_path, $details);
  $self->StartJsChildWindow($child_obj);
}


###
# Delegated methods
###

method DeleteHashKeyList($http, $dyn) {
  DEBUG Dumper($dyn);
  my $type = $dyn->{type};
  my $index = $dyn->{index};

  splice @{$self->{query}->{$type}}, $index, 1;
}
method AddToHashKeyList($http, $dyn) {
  push @{$self->{query}->{tags}}, $dyn->{value};
}

method AddToEditList($http, $dyn) {
  my $source = $dyn->{extra};
  my $value = $dyn->{value};

  DEBUG "Adding '$value' to $source";

  push @{$self->{query}->{$source}}, $value;
}


# do we really need to handle this with a post?
method TextAreaChanged($http, $dyn){
  DEBUG Dumper($dyn);
  # Read the POST data (this method needs to be POSTed to!)
  my $buff;
  my $c = read $http->{socket}, $buff, $http->{header}->{content_length};

  $self->{query}->{$dyn->{id}} = $buff;
  DEBUG $buff;
}


method DrawWidgetFromTo($http, $dyn) {
  $self->RefreshEngine($http, $dyn, qq{
    <tr>
      <th style="width:5%">quick options</th>
      <td>
        <?dyn="NotSoSimpleButtonButton" op="SetWidgetFromTo" val="today" caption="Today" class="btn btn-warning"?>
        <?dyn="NotSoSimpleButtonButton" op="SetWidgetFromTo" val="yesterday" caption="Yesterday" class="btn btn-warning"?>
        <?dyn="NotSoSimpleButtonButton" op="SetWidgetFromTo" val="lastweek" caption="Last 7 Days" class="btn btn-warning"?>
        <?dyn="NotSoSimpleButtonButton" op="SetWidgetFromTo" val="lastmonth" caption="Last 30 Days" class="btn btn-warning"?>
      </td>
    </tr>
  });
}
method SetWidgetFromTo($http, $dyn) {
  my $val = $dyn->{val};
  if ($val eq "today") {
    my $today = DateTime->now(time_zone=>'local')->date;
    my $tomorrow = DateTime->now(time_zone=>'local')->add(days => 1)->date;
    $self->{Input}->{from} = $today;
    $self->{Input}->{to} = $tomorrow;
  }
  if ($val eq "yesterday") {
    my $today = DateTime->now(time_zone=>'local')->date;
    my $yesterday = DateTime->now(time_zone=>'local')->subtract(days => 1)->date;
    $self->{Input}->{from} = $yesterday;
    $self->{Input}->{to} = $today;
  }
  if ($val eq "lastweek") {
    my $tomorrow = DateTime->now(time_zone=>'local')->add(days => 1)->date;
    my $lastweek = DateTime->now(time_zone=>'local')->subtract(weeks => 1)->date;
    $self->{Input}->{from} = $lastweek;
    $self->{Input}->{to} = $tomorrow;
  }
  if ($val eq "lastmonth") {
    my $tomorrow = DateTime->now(time_zone=>'local')->add(days => 1)->date;
    my $lastmonth = DateTime->now(time_zone=>'local')->subtract(months => 1)->date;
    $self->{Input}->{from} = $lastmonth;
    $self->{Input}->{to} = $tomorrow;
  }
}


method DeleteQuery($http,$dyn){
  $self->{Mode} = "DeleteQueryPending";
  $self->{QueryPendingDelete} = $dyn->{query_name};
}
method DeleteQueryPending($http, $dyn){
  $self->RefreshEngine($http, $dyn, qq{
    <p>
      Do you want to delete query named $self->{QueryPendingDelete}?
    </p>

    <?dyn="NotSoSimpleButton" op="ReallyDeleteQuery" caption="Yes, Delete it" sync="Update();"?>
    <?dyn="NotSoSimpleButton" op="CancelDeleteQuery" caption="No, don't delete" sync="Update();"?>
  });
}
method ReallyDeleteQuery($http, $dyn){
 PosdaDB::Queries::Delete($self->{QueryPendingDelete});
 delete $self->{QueryPendingDelete};
 $self->{Mode} = "ListQueries";
}
method CancelDeleteQuery($http, $dyn){
 delete $self->{QueryPendingDelete};
 $self->{Mode} = "ListQueries";
}

method GetBindings() {
  my $bc = $self->{BindingCache};

  my @bindings;
  for my $i (@{$self->{query}->{args}}){
    if(exists $bc->{$i}){
      if($bc->{$i} ne $self->{Input}->{$i}){
        $self->{BindingCache}->{$i} = $self->{Input}->{$i};
        $self->UpdateBindingValueInDb($i);
      }
    } else {
      $self->{BindingCache}->{$i} = $self->{Input}->{$i};
      $self->CreateBindingCacheInfoForKeyInDb($i);
    }
    push(@bindings, $self->{Input}->{$i});
  }

  # Save the cache to disk
#  store $bc, "$self->{SavedQueriesDir}/bindingcache.pinfo";

  return \@bindings;
}


method UpdateInsertCompleted($query, $struct){
  unless(exists $self->{CompletedUpdatesAndInserts}){
    $self->{CompletedUpdatesAndInserts} = [] }
  push(@{$self->{CompletedUpdatesAndInserts}}, {
    query => $query,
    results => $struct,
  });
  my $index = $#{$self->{CompletedUpdatesAndInserts}};
  if($self->{Mode} eq "QueryWait"){
    $self->{SelectedUpdateInsert} = $index;
    $self->{Mode} = "UpdateInsertStatus";
  }
}

method CreateTableFromQuery($query, $struct, $start_at) {
  # create LoadedTable array
  unless(exists $self->{LoadedTables}) { $self->{LoadedTables} = [] }

  # This code creates a copy of the query, but without
  # the dbh (database handle). There was some problem with
  # using storable's freeze if the handle existed. We don't
  # just delete the handle, in case the query needs to be re-used later.
  #
  # I am not sure why we drop the columns and then recreate them?
  my $new_q = {};
  for my $i (keys %$query){
    unless($i eq 'columns'
        or $i eq 'dbh' # if the handle is included it will fail to Freeze
    ){
      $new_q->{$i} = $query->{$i};
    }
  }
  my @cols = @{$query->{columns}};
  $new_q->{columns} = \@cols;

  my $new_table = DbIf::Table::from_query($new_q, $struct, $start_at);
  push(@{$self->{LoadedTables}}, $new_table);
}

method SelectNewestTable() {
  my $index = $#{$self->{LoadedTables}};
  if($self->{Mode} eq "QueryWait"){
    $self->SelectTable({}, { index => $index });
  }
}

method CreateAndSelectTableFromQuery($query, $struct, $start_at){
  $self->CreateTableFromQuery($query, $struct, $start_at);
  $self->SelectNewestTable();
}

method DownloadPreparedReport($http, $dyn) {
  my $filename = $dyn->{filename};
  my $shortname = $dyn->{shortname};

  DEBUG $filename;

  my $fh;
  if(open $fh, $filename) {
    $http->DownloadHeader("text/csv", $shortname);
    Dispatch::Select::Socket->new(
      $self->SendFile($http),
    $fh)->Add("reader");
  }

}

sub WaitHttpReady{
  my($this, $disp, $buff, $http) = @_;
  my $sub = sub {
    my($event) = @_;
    #print STDERR "UnThrottling tar\n";
    $http->queue($buff);
    $disp->Add("reader");
  };
  return $sub;
}
sub SendFile{
  my($this, $http) = @_;
  my $sub = sub {
    my($disp, $sock) = @_;
    my $buff;
    my $count = sysread($sock, $buff, 10240);
    if($count <= 0){
      $disp->Remove;
      return;
    }
    if($http->ready_out){
      $http->queue($buff);
    } else {
      $disp->Remove("reader");
      my $event = Dispatch::Select::Event->new(
        Dispatch::Select::Background->new(
          $this->WaitHttpReady($disp, $buff, $http)));
      $http->wait_output($event);
    }
  };
  return $sub;
}

method DownloadTableAsCsv($http, $dyn){
  my $table = $self->{LoadedTables}->[$dyn->{table}];
  my $q_name;

  if($table->{type} eq "FromQuery"){
    $q_name = "$table->{query}->{name}.csv";
  } elsif ($table->{type} eq "FromCsv") {
    $q_name = $table->{basename};
  } else {
    die "What kind of table is this?!";
  }

  $http->DownloadHeader("text/csv", "$q_name");
  my $cmd = "PerlStructToCsv.pl";
  Dispatch::BinFragReader->new_serialized_cmd(
    $cmd,
    $table,
    func($frag) {
      $http->queue("$frag");
    },
    func() {
      # do nothing, on purpose
    }
  );
}

method StoreQuery($query, $filename) {
  # my $new_q = {};
  # for my $i (keys %$query){
  #   unless($i eq 'columns'
  #       or $i eq 'dbh' # if the handle is included it will fail to Freeze
  #   ){
  #     $new_q->{$i} = $query->{$i};
  #   }
  # }
  DEBUG "Storing query to: $filename";
  delete $query->{dbh};
  store $query, $filename;
}
method SaveTableAsReport($http, $dyn){
  my $table = $self->{LoadedTables}->[$self->{SelectedTable}];
  my $dir = $self->{PreparedReportsDir};
  my $public = $dyn->{public};
  if (defined $public) {
    DEBUG "Saving to public!";
    $dir = $self->{PreparedReportsCommonDir};
  }
  my $filename = $dyn->{saveName};

  if($table->{type} eq "FromQuery"){
    $self->StoreQuery($table->{query},
     "$dir/$filename.query");
  }

  # TODO: need to find a valid non-conflicting filename here

  my $file = "$dir/$filename";
  DEBUG "Saving to: $file";

  open my $fh, ">$file" or die "Can't open $file for writing ($!)";
  my $cmd = "PerlStructToCsv.pl";
  Dispatch::BinFragReader->new_serialized_cmd(
    $cmd,
    $table,
    func($frag) {
      print $fh $frag;
    },
    func() {
      close $fh;
      $self->QueueJsCmd("alert('Report saved!');");
    }
  );
}

method SetUseAsArg($http, $dyn) {
  $self->{Mode} = 'UseAsArg';
  $self->{UseAsArgOps} = $dyn;
}
method UseAsArg($http, $dyn) {
  my $arg_name = $self->{UseAsArgOps}->{arg};
  my $value = $self->{UseAsArgOps}->{value};
  $http->queue(qq{
    <h2>Execute new query using selected argument value</h2>

    <div class="row">
      <div class="col-md-4">
        <div class="panel panel-default">
          <div class="panel-heading">Selected argument type</div>
          <div class="panel-body">
            $arg_name
          </div>
        </div>
      </div>
      <div class="col-md-8">
        <div class="panel panel-default">
          <div class="panel-heading">Selected argument value</div>
          <div class="panel-body">
            $value
          </div>
        </div>
      </div>
    </div>

    <p class="alert alert-info">The following queries can be executed with
    this as an input:</p>
  });

  if(exists $self->{BindingCache}->{$arg_name}){
    unless($self->{BindingCache}->{$arg_name} eq $value){
      $self->{BindingCache}->{$arg_name} = $value;
      $self->UpdateBindingValueInDb($arg_name);
    }
  } else {
    $self->{BindingCache}->{$arg_name} = $value;
    $self->CreateBindingCacheInfoForKeyInDb($arg_name);
  }

  # present a list of the possible queries here
  my $queries = PosdaDB::Queries->GetQuerysWithArg($arg_name);
  my $menu = [];
  $http->queue(qq{
    <div class="list-group">
  });
  for my $q (@$queries) {
    my ($name, $desc) = @$q;
    $http->queue(qq{
      <a class="list-group-item" href="#"
        onClick="javascript:PosdaGetRemoteMethod('SetActiveQuery', 'query_name=$name', function () {Update();});"
      >
        <h4 class="list-group-item-heading">$name</h4>
        <p class="list-group-item-text">$desc</p>
      </a>
    });
    # $self->NotSoSimpleButton($http, {
    #   caption => "$name",
    #   op => "SetActiveQuery",
    #   query_name => "$name",
    #   title => $desc,
    #   sync => 'Update();'
    # });
  }
  $http->queue(qq{
    </div>
  });
}

method InsertSaveReportModal($http, $name, $table) {
  $http->queue(qq{
    <button type="button" class="btn btn-default"
            data-toggle="modal" data-target="#saveReportModal">
      Save as Report
    </button>

    <div class="modal" id="saveReportModal" tabindex="-1"
         role="dialog" aria-labelledby="myModalLabel">
      <div class="modal-dialog" role="document">
        <div class="modal-content">
          <div class="modal-header">
            <h4 class="modal-title">Save as Report</h4>
          </div>
          <div class="modal-body">
          <form id="saveAsReportForm">
            <div class="form-group">
              <label for="saveName">Save as</label>
              <input type="input" class="form-control"
                     id="saveName" name="saveName"
                     value="$name">
            </div>
            <div class="checkbox">
              <label>
                <input type="checkbox" name="public"> Save as a Public Report
              </label>
            </div>
          </form>
          </div>
          <div class="modal-footer">
            <button type="button" class="btn btn-default"
                    data-dismiss="modal">Cancel</button>
            <button type="button" class="btn btn-primary"
                    onClick="javascript:PosdaGetRemoteMethod('SaveTableAsReport', \$('#saveAsReportForm').serialize(), function () {Update();});"
                    data-dismiss="modal"
            >Save</button>
          </div>
        </div>
      </div>
    </div>

  });

}

sub get_background_buttons {
  my ($tags) = @_;

  my $buttons = Query('GetBackgroundButtonsByTag');

  my $results = $buttons->FetchResults($tags);

  return $results;
}

func get_popup_hash($query_name) {
    my $popups = PosdaDB::Queries->GetPopupsForQuery($query_name);
    # Process popups into a usable hash
    my $popup_hash = {};
    map {
      my ($id, $query, $class, $col, $is_full_table, $name) = @$_;
      if ($is_full_table) {
        unless(exists $popup_hash->{table_level_popup}){
          $popup_hash->{table_level_popup} = [];
        }
        push @{$popup_hash->{table_level_popup}}, {class => $class, name => $name};
      } else {
        if (defined $col) {
          $popup_hash->{$col} = {class => $class, name => $name};
        } else {
          $popup_hash->{row_level_popup} = {class => $class, name => $name};
        }
      }
    } @$popups;
    return $popup_hash;
}

method DrawFilterableFieldHeading($http, $column_name, $column_number) {
  $http->queue(qq{<th>$column_name});
  $self->DebouncedEntryBox($http, {
      uniq_id => $column_name,
      op => 'Test1Change'
  });
  $http->queue(qq{</th>});

}

method Test1Change($http, $dyn) {
  say STDERR Dumper($dyn);

  # Test applying a filter to the current table
  # TODO: Perhaps make a table object which can have
  # a filter method? would need to update this in a few places, I think?

  my $table = $self->{LoadedTables}->[$self->{SelectedTable}];
  my $col = $dyn->{uniq_id};
  my $val = $dyn->{value};

  $table->add_filter($col, $val);

  $self->AutoRefresh;
}

method TableSelected($http, $dyn){
  my $table = $self->{LoadedTables}->[$self->{SelectedTable}];
  if($table->{type} eq "FromQuery"){
    my $query = $table->{query};
    my $rows = $table->{rows};
    my $num_rows = @$rows;
    my $at = $table->{at};

    my $popup_hash = get_popup_hash($query->{name});
    my $chained_queries = PosdaDB::Queries->GetChainedQueries($query->{name});

    $self->RefreshEngine($http, $dyn, qq{
      <div>
      <h3>Table from query: $query->{name}</h3>
      <p>
        <a class="btn btn-primary"
           href="DownloadTableAsCsv?obj_path=$self->{path}&table=$self->{SelectedTable}">
           Download
        </a>
      });
    $self->InsertSaveReportModal($http, "$query->{name}.csv");
    $self->NotSoSimpleButton($http, {
      caption => "Return to Query",
      op => "SetActiveQuery",
      query_name => $query->{name},
      sync => 'Update();'
    });
    my $desc_html = markdown($query->{description});
    $http->queue(qq{
      </p>

      <div class="panel panel-default">
        <div class="panel-heading">Description</div>
        <div class="panel-body">
          $desc_html
        </div>
      </div>

      <p>Schema: $query->{schema}</p>
    });

    my $numb = @{$query->{bindings}};
    if($numb > 0){
      $http->queue('Bindings:<ul>');
      for my $i (0 .. $#{$query->{bindings}}){
        $http->queue("<li>$query->{args}->[$i]: " .
          "$query->{bindings}->[$i]</li>");
      }
      $http->queue('</ul>');
    }
    $http->queue("Rows: $num_rows<hr>");
    #
    if (defined $popup_hash->{table_level_popup}) {
#      my $tlp = $popup_hash->{table_level_popup};
      $http->queue("<p>");
      for my $tlp (@{$popup_hash->{table_level_popup}}){
        $self->NotSoSimpleButton($http, {
            caption => "$tlp->{name}",
            op => "OpenTableLevelPopup",
            class_ => "$tlp->{class}",
            cap_ => "$tlp->{name}",
            sync => 'Update();'
        });
      }
      $http->queue("</p>");
    }
    $http->queue(qq{
      <table class="table table-striped">
        <tr>
    });
    my $col_num = 0;
    for my $i (@{$query->{columns}}){
      $self->DrawFilterableFieldHeading($http, $i, $col_num);
      $col_num += 1;
    }
    if ($#{$chained_queries} > -1) {
      $http->queue("<th>Chained</th>");
    }
    $http->queue('</tr>');

    my $col_pos = 0;
    for my $row_index (0 .. $#{$rows}) {
      my $r = $rows->[$row_index];
      $http->queue('<tr>');
      for my $v (@$r){
        unless(defined($v)){ $v = "<undef>" }
        my $v_esc = $v;
        $v_esc =~ s/</&lt;/g;
        $v_esc =~ s/>/&gt;/g;
        my $cn = $query->{columns}->[$col_pos++];
        $http->queue("<td>");
        if (defined $self->{AllArgs}->{$cn}) {
          $self->NotSoSimpleButton($http, {
              class => "",
              caption => "$v_esc",
              op => "SetUseAsArg",
              value => $v_esc,
              arg => $cn,
              element => 'a',
              title => 'Click to use this value as an input to another query',
              sync => 'Update();'
          });
        } else {
          $http->queue($v_esc);
        }
        if (defined $popup_hash->{$cn}) {
          my $popup_details = $popup_hash->{$cn};
          $self->NotSoSimpleButton($http, {
              caption => "$popup_details->{name}",
              op => "OpenDynamicPopup",
              row => "$row_index",
              class_ => "$popup_details->{class}",
              cap_ => "$popup_details->{name}",
              sync => 'Update();'
          });
        }

        $http->queue("</td>");
      }
      $col_pos = 0;
      if (defined $popup_hash->{row_level_popup}) {
        my $popup_details = $popup_hash->{row_level_popup};

        $http->queue('<td>');
        $self->NotSoSimpleButton($http, {
            caption => "$popup_details->{name}",
            op => "OpenDynamicPopup",
            row => "$row_index",
            class_ => "$popup_details->{class}",
            cap_ => "$popup_details->{name}",
            sync => 'Update();'
        });
        $http->queue('</td>');
      }
      if (defined $chained_queries) {
        for my $q (@$chained_queries) {
          $http->queue('<td>');
          $self->NotSoSimpleButton($http, {
              caption => "$q->{caption}",
              op => "OpenChainedQuery",
              row => "$row_index",
              chained_query_id => "$q->{chained_query_id}",
              to_query => "$q->{to_query}",
              sync => 'Update();'
          });
          $http->queue('</td>');
        }
      }
      $http->queue('</tr>');
    }
    $self->RefreshEngine($http, $dyn, "</table></div>");
  } elsif($table->{type} eq "FromCsv"){
    my $file = $table->{file};
    my $rows = $table->{rows};
    my $num_rows = @$rows - 0;
    my $at = $table->{at};

    my $popup_hash = get_popup_hash(basename($file));

    $self->RefreshEngine($http, $dyn, qq{
      <div style="background-color: white">
      Table from CSV file: $file
      <a class="btn btn-sm btn-primary"
         href="DownloadTableAsCsv?obj_path=$self->{path}&table=$self->{SelectedTable}">Download</a>
     });
    $self->InsertSaveReportModal($http, basename($file));
    $http->queue(qq{
      <br>
    });
    $http->queue(qq{
      File_id: $table->{posda_file_id}<br>
      Spreadsheet_uploaded_id: $table->{spreadsheet_uploaded_id}<br>
    });
    $http->queue("Rows: $num_rows<br>Results:<hr>");
    $http->queue(qq{
      <table class="table table-striped">
        <tr>
    });
    for my $i (@{$table->{columns}}){
      $http->queue("<th>$i</th>");
    }
    $http->queue('</tr>');

    for my $ri (0 .. $#{$rows}){
      my $r = $rows->[$ri];
      $http->queue('<tr>');
      my $col_idx = 0;
      for my $v (@$r){
        my $cn = $rows->[0]->[$col_idx++];
        unless(defined($v)){ $v = "<undef>" }
        my $v_esc = $v;
        $v_esc =~ s/</&lt;/g;
        $v_esc =~ s/>/&gt;/g;
        $http->queue("<td>$v_esc");

        if (defined $popup_hash->{$cn}) {
          my $popup_details = $popup_hash->{$cn};
          $self->NotSoSimpleButton($http, {
              caption => "$popup_details->{name}",
              op => "OpenDynamicPopup",
              row => "$ri",
              class_ => "$popup_details->{class}",
              sync => 'Update();'
          });
        }
        $http->queue("</td>");
      }
      if (defined $popup_hash->{row_level_popup}) {
        my $popup_details = $popup_hash->{row_level_popup};

        $http->queue('<td>');
        $self->NotSoSimpleButton($http, {
            caption => "$popup_details->{name}",
            op => "OpenDynamicPopup",
            row => "$ri",
            class_ => "$popup_details->{class}",
            sync => 'Update();'
        });
        $http->queue('</td>');
      }
      $http->queue('</tr>');
    }
    $self->RefreshEngine($http, $dyn, "</table></div>");
  }
}

method OpenChainedQuery($http, $dyn) {
  my $id = $dyn->{chained_query_id};
  my $query_name = $dyn->{to_query};

  my $details = PosdaDB::Queries->GetChainedQueryDetails($id);

  # get the row as a hash?
  my $h = {};
  my $table = $self->{LoadedTables}->[$self->{SelectedTable}];
  if($table->{type} eq "FromQuery"){
    my $cols = $table->{query}->{columns};
    my $rows = $table->{rows};
    my $row = $rows->[$dyn->{row}];

    # build hash for popup constructor
    for my $i (0 .. $#{$row}) {
      $h->{$cols->[$i]} = $row->[$i];
    }

  } elsif ($table->{type} eq 'FromCsv') {

    my $file = $table->{file};
    my $rows = $table->{rows};
    my $row = $rows->[$dyn->{row}];
    my $cols = $rows->[0]; # column names in first row

    # build hash for popup constructor
    for my $i (0 .. $#{$row}) {
      $h->{$cols->[$i]} = $row->[$i];
    }
  }

  # DEBUG Dumper($h);
  # $h now holds the values of the row as a hash
  for my $param (@$details) {
    if(exists $self->{BindingCache}->{$param->{to_parameter_name}}){
      unless(
        $self->{BindingCache}->{$param->{to_parameter_name}} eq
        $h->{$param->{from_column_name}}
      ){
        $self->{BindingCache}->{$param->{to_parameter_name}} =
          $h->{$param->{from_column_name}};
        $self->UpdateBindingValueInDb($param->{to_parameter_name});
      }
    } else {
      $self->{BindingCache}->{$param->{to_parameter_name}} =
        $h->{$param->{from_column_name}};
      $self->CreateBindingCacheInfoForKeyInDb($param->{to_parameter_name});
    }
  }
  $self->SetActiveQuery($http, {
    query_name => "$query_name",
  });
}


method UpdateInsertStatus($http, $dyn){
  my $index = $self->{SelectedUpdateInsert};
  my $update_struct = $self->{CompletedUpdatesAndInserts}->[$index];

  my $result_count = $update_struct->{results}->[0];
  my $query_name = $update_struct->{query}->{name};

  $http->queue(qq{
    <p class="alert alert-success">
      UPDATE or INSERT query succeeded: $query_name.
      $result_count rows were affected.
    </p>
  });
}
method UpdatesInserts($http, $dyn){
}
#############################
#Here Bill is putting in the "Activities" Page assortment
method Activities($http, $dyn){
  unless(defined $self->{ActivitySelected}){ $self->{ActivitySelected} = "<none>" }
  if($self->{ActivitySelected} ne "<none>"){
    return $self->NewActivitiesPage($http, $dyn);
  }
  $self->RefreshActivities;
  $self->RefreshEngine($http, $dyn, qq{
    <h2>Activities</h2>
  });
  $http->queue(qq{
    <div style="display: flex; flex-direction: row; align-items: flex-end; margin-bottom: 5px">
  });
  $self->RenderActivityDropDown($http, $dyn);
  unless(defined $self->{ActivityFilter}) { $self->{ActivityFilter} = "" }
  $http->queue("&nbsp;Filter:&nbsp;");
  $self->BlurEntryBox($http, {
    name => "Filter",
    op => "SetActivityFilter",
    value => "$self->{ActivityFilter}"
  }, "Update();");
  $http->queue(qq{</div><hr>});
  $self->RenderNewActivityForm($http, $dyn);
}
method SetActivityFilter($http, $dyn){
  $self->{ActivityFilter} = $dyn->{value};
}

method RenderNewActivityForm($http, $dyn) {
  $http->queue(qq{
    <h3>Insert a new activity</h3>
    <div class="col-md-4">
      <div class="form-group">
        <label>Short description</label>
        <input class="form-control" id="newActivity" value="">
      </div>
  });
  $self->SubmitValueButton($http, {
      caption => 'Save',
      element_id => 'newActivity',
      op => 'newActivity',
      class => 'btn btn-primary',
      #extra => $extra
  });

  $http->queue(qq{
    </div>
  });
}
method RenderActivityDropDown($http, $dyn){
  unless(defined $self->{ActivitySelected}){
    $self->{ActivitySelected} = "<none>";
  }
  my @activity_list;
  push @activity_list, ["<none>", "----- No Activity Selected ----"];
#  my @sorted_ids = $self->SortedActivityIds($self->{Activities});
  my @sorted_ids = sort {$a <=> $b} keys %{$self->{Activities}};
  sorted_id:
  for my $i (@sorted_ids){
    if($self->{ActivityFilter}){
      unless($self->{Activities}->{$i}->{desc} =~ /$self->{ActivityFilter}/){ next sorted_id }
    }
    push @activity_list, [$i , "$i: $self->{Activities}->{$i}->{desc}" .
      " ($self->{Activities}->{$i}->{user})"];
  }
  $self->SelectByValue($http, {
    op => 'SetActivity',
  });
  for my $i (@activity_list){
    $http->queue("{<option value=\"$i->[0]\"");
    if($i->[0] eq $self->{ActivitySelected}){
      $http->queue(" selected")
    }
    $http->queue(">$i->[1]</option>");
  }
  $http->queue(qq{
    </select>
  });
}

method SetActivity($http, $dyn){
  $self->{ActivitySelected} = $dyn->{value};
  $self->{BindingCache}->{activity_id} = $dyn->{value};
  my $activity_name = $self->{Activities}->{$dyn->{value}}->{desc};
  if($activity_name ne ""){
    $self->{title} = "Activity Based Curation (<small>$dyn->{value}: $activity_name</small>)";
    $self->AutoRefreshOne;
  } else {
    $self->{title} = "Activity Based Curation (<small>no activity</small>)";
    $self->AutoRefreshOne;
  }
#  $self->AutoRefresh;
}

method newActivity($http, $dyn){
  my $desc = $dyn->{value};
  if($desc =~/^\s*$/){ return }
  my $user = $self->get_user;
  print STDERR "In new activity $user: $desc\n";
  my $q = Query('CreateActivity');
  $q->RunQuery(sub {}, sub {}, $desc, $user);
}
method SortedActivityIds($h){
  return sort {
    if(
      $h->{$a}->{user} eq $self->get_user &&
      $h->{$b}->{user} ne $self->get_user
    ){ return 1 }
    elsif(
      $h->{$b}->{user} eq $self->get_user &&
      $h->{$a}->{user} ne $self->get_user
    ){ return -1 }
    elsif(
      $h->{$a}->{user} eq $self->get_user
    ){
      if(
       defined($h->{$a}->{closed}) &&
       $h->{$b}->{closed}
      ){ return -1 }
      elsif(
       defined($h->{$b}->{closed}) &&
       $h->{$a}->{closed}
      ){ return 1 }
      return $h->{$a}->{opened} cmp $h->{$b}->{opened}
    } elsif(
      $h->{$a}->{user} ne $h->{$b}->{user}
    ){
      return $h->{$a}->{user} cmp $h->{$b}->{user}
    }
    if(
     defined($h->{$a}->{closed}) &&
     $h->{$b}->{closed}
    ){ return -1 }
    elsif(
     defined($h->{$b}->{closed}) &&
     $h->{$a}->{closed}
    ){ return 1 }
    return $h->{$a}->{opened} cmp $h->{$b}->{opened}
  } keys %$h;
}
method RefreshActivities{
  my $q = Query('GetOpenActivitiesThirdParty');
  my %Activities;
  $self->{Activities} = {};
  $q->RunQuery(sub {
    my($row) = @_;
    my($act_id, $b_desc, $created, $who, $closed, $tp_url) = @$row;
    $Activities{$act_id} = {
      user => $who,
      closed => $closed,
      opened => $created,
      desc => $b_desc,
      third_party_analysis_url => $tp_url,
    };
  }, sub {});
  $self->{Activities} = \%Activities;
}
#############################
# New Activities Page
method NewActivitiesPage($http, $dyn){
  $http->queue(qq{
    <div style="display: flex; flex-direction: row; align-items: flex-end; margin-bottom: 5px">
  });
  $self->DrawActivitySelected($http, $dyn);
  $self->DrawClearActivityButton($http, $dyn);
  $http->queue("&nbsp;&nbsp;Mode:&nbsp;");
  $self->DrawActivityModeSelector($http, $dyn);
  $http->queue("<div id=\"activitytaskstatus\" width=200><ul>");
  $self->DrawActivityTaskStatus($http, $dyn);
  $http->queue("</div>");
  $http->queue(qq{</div><hr>});
  my $method = $self->{ActivityModes}->{$self->{ActivityModeSelected}};
  if($self->can($method)){
    $self->$method($http, $dyn);
  } else {
    $http->queue("method \"$method\" is not yet defined\n");
  }
}
method DrawActivitySelected($http, $dyn){
  my $activity = $self->{Activities}->{$self->{ActivitySelected}};
  $http->queue("<div id=\"selected_activity\">");
  $http->queue("Activity $self->{ActivitySelected}: ");
  $http->queue("$activity->{desc}<br>");
  $http->queue("Is third party: ");
  $http->queue("Yes ");
  my $yes = $self->RadioButtonSync("IsThirdParty", "yes",
    "SetThirdPartyStatus",
    (defined($activity->{third_party_analysis_url}) ? 1 : 0),
    "&control=NewActivityTimeline","Update();");
  $http->queue($yes);
  $http->queue(" No ");
  my $no = $self->RadioButtonSync("IsThirdParty","no",
    "SetThirdPartyStatus",
    (defined($activity->{third_party_analysis_url}) ? 0 : 1),
    "&control=NewActivityTimeline","Update();");
  $http->queue($no);
  if(defined($activity->{third_party_analysis_url})){
    $http->queue("<br>third party analysis url:<br>");
    $self->BlurEntryBox($http, {
      name => "ThirdPartyUrl",
      op => "SetThirdPartyUrl",
      value => "$activity->{third_party_analysis_url}"
    }, "Update();");
  }
  $http->queue("</div>");
}

sub SetThirdPartyStatus{
  my($self, $http, $dyn) = @_;
  my $yn = $dyn->{value};
  my $activity = $self->{Activities}->{$self->{ActivitySelected}};
  if($yn eq "no"){
    $activity->{third_party_analysis_url} = undef;
    $self->SyncActivity;
  }
  if($yn eq "yes"){
    unless(defined $activity->{third_party_analysis_url}){
      $activity->{third_party_analysis_url} = "enter url";
    }
  }
}

sub SetThirdPartyUrl{
  my($self, $http, $dyn) = @_;
  my $url = $dyn->{value};
  if($url eq "") { $url = undef }
  my $activity = $self->{Activities}->{$self->{ActivitySelected}};
  $activity->{third_party_analysis_url} = $url;
  $self->SyncActivity;
}

sub SyncActivity{
  my($self) = @_;
  my $activity = $self->{Activities}->{$self->{ActivitySelected}};
  Query('SetActivityThirdPartyUrl')->RunQuery(sub{}, sub {},
    $activity->{third_party_analysis_url}, $self->{ActivitySelected});
}

method DrawClearActivityButton($http, $dyn){
  $self->NotSoSimpleButton($http, {
    op => "ClearActivity",
    caption => "Choose Another Activity",
    sync => "Update();",
  });
}
method ClearActivity($http, $dyn){
  $self->{ActivitySelected} = "<none>";
}
method DrawActivityModeSelector($http, $dyn){
  unless(defined $self->{ActivityModeSelected}){
    $self->{ActivityModeSelected} = 0;
  }
  my @activity_mode_list = (
    [0, "ShowActivityTimeline"],
    [1, "ActivityOperations"],
    [2, "Queries"],
  );
  my @sorted_ids = $self->SortedActivityIds($self->{Activities});
  for my $i (@activity_mode_list){
    $self->{ActivityModes}->{$i->[0]} = $i->[1];
  }
  $http->queue("<div width=100>");
  $self->SelectByValue($http, {
    op => 'SetActivityMode',
    width => '100',
  });
  for my $i (@activity_mode_list){
    $http->queue("<option value=\"$i->[0]\"");
    if($i->[0] eq $self->{ActivityModeSelected}){
      $http->queue(" selected")
    }
    $http->queue(">$i->[1]</option>");
  }

  $http->queue(qq{
    </select> </div>
  });
}
method DrawActivityTaskStatus($http, $dyn){
  my @backgrounders;
  $self->{Backgrounders} = [];
  Query('GetActivityTaskStatus')->RunQuery(sub {
    my($row) = @_;
    push(@backgrounders, $row);
  }, sub {}, $self->{ActivitySelected});
  if($#backgrounders >= 0){
    $self->{Backgrounders} = \@backgrounders;
    for my $i (@backgrounders){
      $http->queue("<li>$i->[0]: $i->[1] - $i->[4]");
      $self->NotSoSimpleButton($http, {
        op => "DismissActivityTaskStatus",
        caption => "dismiss",
        subprocess_invocation_id => $i->[0],
        sync => "Update();",
      });
      $http->queue("</li>");
    }
    $http->queue("</ul>");
    $self->InvokeAfterDelay("AutoRefreshActivityTaskStatus", 1);
#    $self->AutoRefresh();
  }
}
method DismissActivityTaskStatus($http, $dyn){
  my $sub_id = $dyn->{subprocess_invocation_id};
  my $act_id = $self->{ActivitySelected};
  my $user = $self->get_user;
  Query('DismissActivityTaskStatus')->RunQuery(sub{}, sub{},
    $user, $act_id, $sub_id);
}
method SetActivityMode($http, $dyn){
  $self->{ActivityModeSelected} = $dyn->{value};
  $self->AutoRefresh;
}
method ShowActivityTimeline($http, $dyn){
  my @time_line;
  Query('InboxContentByActivityIdWithCompletion')->RunQuery(sub{
    my($row) = @_;
    push @time_line, $row;
  }, sub {}, $self->{ActivitySelected});
  my @time_points;
  Query('ActivityTimepointsForActivityWithFileCount')->RunQuery(sub{
    my($row) = @_;
    push @time_points, $row;
  }, sub {}, $self->{ActivitySelected});
  $self->{NewActivityTimeline}->{timeline} = \@time_line;
  $self->{NewActivityTimeline}->{timepoints} = \@time_points;
  $http->queue("<table class=\"table table-striped table-condensed\">");
  $http->queue("<tr><th rowspan=2>id</th>" .
    "<th rowspan=2>operation</th>" .
    "<th rowspan=2>start</th>" .
    "<th rowspan=2>duration</th>" .
    "<th rowspan=2>ol</th>" .
    "<th>tp</th>" .
    "<th colspan=2>");
  $self->NotSoSimpleButton($http, {
    op => "CompareTimepoints",
    caption => "cmp",
    sync => "Update();",
  });
  $http->queue("</th>" .
    "<th>tp</th>" .
    "<th rowspan=2>view</th>" .
    "<th rowspan=2>user</th>" .
    "<th rowspan=2>command</th>" ,
    "</tr>");
  $http->queue("<tr><th>id</th><th>fr</th><th>to</th><th>files</th></tr>");
  my @time_line_cp = @time_line;
  my @time_points_cp = @time_points;
  my $next_event = shift(@time_line_cp);
  my $next_tp = shift(@time_points_cp);
  while(defined($next_event)){
    my $i = $next_event;
    my($user_name, $id, $operation_name, $when, $ended,
      $duration, $file_id, $sub_id, $command_line,
      $spreadsheet_file_id) = @$next_event;
    my($tp,$tp_files);
    if((defined $next_tp->[4]) &&
      $next_tp->[4] ge $when && $next_tp->[4] le $ended){
      $tp = $next_tp->[3];
      $tp_files = $next_tp->[7];
      $next_tp = shift(@time_points_cp);
    } else {
      $tp = undef;
      $tp_files = undef;
    }
    $http->queue("<tr>");
    $http->queue("<td>$sub_id</td>");
    my($hrs_min_etc, $sec);
    $http->queue("<td>$operation_name</td>");
    my $start_t = substr($when, 0, 22);
    $http->queue("<td>$start_t</td>");
    my $dur = $duration;
    if($dur =~ /(.*:)(\d+\.\d+)$/){
      $dur = $1 . sprintf("%02.2f", $2);
    }
    $http->queue("<td>$dur</td>");
    $http->queue("<td>");
    $http->queue($self->CountOverlappingEvents($next_event, \@time_line_cp));
    $http->queue("</td>");
    $http->queue("<td>");
    if(defined $tp) {
      $http->queue("$tp");
    }
    $http->queue("</td>");
    $http->queue("<td>");
    if($tp){
      my $url = $self->RadioButtonSync("from",$tp,
        "ProcessRadioButton",
        (defined($self->{NewActivityTimeline}->{from}) && $self->{NewActivityTimeline}->{from} == $tp) ? 1 : 0,
        "&control=NewActivityTimeline","Update();");
      $http->queue($url);
    }
    $http->queue("</td>");
    $http->queue("<td>");
    if($tp){
      my $url = $self->RadioButtonSync("to",$tp,
        "ProcessRadioButton",
        (defined($self->{NewActivityTimeline}->{to}) && $self->{NewActivityTimeline}->{to} == $tp) ? 1 : 0,
        "&control=NewActivityTimeline","Update();");
      $http->queue($url);
    }
    $http->queue("</td>");
    $http->queue("<td>");
    if(defined $tp_files) {
      $http->queue("$tp_files");
    }
    $http->queue("</td>");
    $http->queue("<td>");
    $self->NotSoSimpleButton($http, {
      op => "ShowEmail",
      caption => "email",
      file_id => $i->[6],
      sync => "Update();",
    });
    $self->NotSoSimpleButton($http, {
      op => "ShowResponse",
      caption => "resp",
      sub_id => $i->[7],
      sync => "Update();",
    });
    if(defined $spreadsheet_file_id){
      $self->NotSoSimpleButton($http, {
        op => "ShowInput",
        caption => "input",
        file_id => $i->[9],
        sync => "Update();",
      });
   }
    $http->queue("</td>");
    $http->queue("<td>$i->[0]");
    $http->queue("<td>$i->[8]");
    $http->queue("</tr>");
    $next_event = shift(@time_line_cp);
  }
  $http->queue("</table>");
}
method ShowEmail($http, $dyn){
  my $class = 'Posda::PopupTextViewer';
  eval "require $class";
  my $params = {
    activity_id => $self->{ActivitySelected},
    file_id =>  $dyn->{file_id},
  };
  unless(exists $self->{sequence_no}){$self->{sequence_no} = 0}
  if($@){
    print STDERR "Posda::TestProcessPopup failed to compile\n\t$@\n";
    return;
  }
  my $name = "ShowEmail_$self->{sequence_no}";
  $self->{sequence_no}++;

  my $child_path = $self->child_path($name);
  my $child_obj = $class->new($self->{session},
                              $child_path, $params);
  $self->StartJsChildWindow($child_obj);
}
method ShowResponse($http, $dyn){
  my $class = 'DbIf::ShowSubprocessLines';
  eval "require $class";
  my $params = {
    activity_id => $self->{ActivitySelected},
    sub_id =>  $dyn->{sub_id},
  };
  unless(exists $self->{sequence_no}){$self->{sequence_no} = 0}
  if($@){
    print STDERR "DbIf::ShowSubprocessLines failed to compile\n\t$@\n";
    return;
  }
  my $name = "ShowSubprocessResponse$self->{sequence_no}";
  $self->{sequence_no}++;

  my $child_path = $self->child_path($name);
  my $child_obj = $class->new($self->{session},
                              $child_path, $params);
  $self->StartJsChildWindow($child_obj);
}
method ShowInput($http, $dyn){
  my $class = 'Posda::PopupTextViewer';
  eval "require $class";
  my $params = {
    activity_id => $self->{ActivitySelected},
    file_id =>  $dyn->{file_id},
  };
  unless(exists $self->{sequence_no}){$self->{sequence_no} = 0}
  if($@){
    print STDERR "Posda::TestProcessPopup failed to compile\n\t$@\n";
    return;
  }
  my $name = "ShowInput_$self->{sequence_no}";
  $self->{sequence_no}++;

  my $child_path = $self->child_path($name);
  my $child_obj = $class->new($self->{session},
                              $child_path, $params);
  $self->StartJsChildWindow($child_obj);
}
method ProcessRadioButton($http, $dyn){
  my $value = $dyn->{value};
  my $control = $dyn->{control};
  my $group = $dyn->{group};
  my $checked = $dyn->{checked};
  $self->{$control}->{$group} = $value;
}
method CountOverlappingEvents($event, $event_list){
  my $count = 0;
  for my $i (@$event_list){
    if(
      ($i->[3] ge $event->[3] && $i->[3] le $event->[4]) ||
      ($i->[4] ge $event->[3] && $i->[4] le $event->[4])
    ){ $count += 1; }
  }
  return $count;
}
method CompareTimepoints($http, $dyn){
  my $class = "Posda::ProcessPopup";
  eval "require $class";
  my $params = {
    button => "CompareTimepoints",
    from_timepoint_id => $self->{NewActivityTimeline}->{from},
    to_timepoint_id => $self->{NewActivityTimeline}->{to},
    activity_id => $self->{ActivitySelected}
  };
  unless(exists $self->{sequence_no}){$self->{sequence_no} = 0}
  if($@){
    print STDERR "Posda::TestProcessPopup failed to compile\n\t$@\n";
    return;
  }
  my $name = "CompareTimepoint_$self->{sequence_no}";
  $self->{sequence_no}++;

  my $child_path = $self->child_path($name);
  my $child_obj = $class->new($self->{session},
                              $child_path, $params);
  $self->StartJsChildWindow($child_obj);
}
method ActivityOperations($http, $dyn){
  my @buttons =  (
    [ "CreateActivityTimepointFromImportName", "Create Activity Timepoint from Import Name", 0, 0],
    [ "CreateActivityTimepointFromCollectionSite", "Create Activity Timepoint", 0, 1],
    [ "VisualReviewFromTimepoint", "Schedule Visual Review", 0, 2],
    [ "PhiReviewFromTimepoint", "Schedule PHI Scan", 0, 3],
    [ "ConsistencyFromTimePoint", "Check Consistency", 0, 4],
    [ "LinkRtFromTimepoint", "Link RT Data for ItcTools", 0, 5],
    [ "CheckStructLinkagesTp", "Check Structure Set Linkages", 0, 6],
    [ "MakeDownloadableDirectoryTp", "Make a Downloadable Directory", 0, 7],
    [ "PhiPublicScanTp", "Public Phi Scan Based on Current TP by Activity", 1, 0],
    [ "SuggestPatientMappings", "Suggest Patient Mapping for Timepoint", 1, 1],
    [ "BackgroundDciodvfyTp", "Run Dciodvfy for Time Point", 1, 2],
    [ "CondensedActivityTimepointReport", "Produce Condensed Activity Timepoint Report", 1, 3],
    [ "AnalyzeSeriesDuplicates", "Analyze Series With Duplicates", 1, 4],
    [ "FilesInTpNotInPublic", "Find Files in Tp, not in Public", 1, 5],
    [ "CompareSopsInTpToPublic", "Compare Corresponding SOPs in Time Point to Public", 1, 6],
    [ "BackgroundHelloWorld.pl", "Perl Hello World Background", 1, 7],
    [ "AnalyzeSeriesDuplicatesForTimepoint", "Analyze Series In Time Point with Duplicates", 2, 0],
    [ "CompareSopsTpPosdaPublic", "Compare Sops in Timepoint, Posda, and Public", 2, 1],
    [ "BackgroundPrivateDispositionsTp", "Apply Background Dispositions To Timepoint (non baseline date)", 2, 2],
    [ "BackgroundPrivateDispositionsTpBaseline", "Apply Background Dispositions To Timepoint (baseline date)", 2, 3],
    [ "CompareSopsTpPosdaPublicLike", "Compare Sops in Timepoint, Posda, and Public like Collection", 2, 4],
    [ "UpdateActivityTimepoint", "Update Activity Timepoint", 2, 5],
    [ "InitialAnonymizerCommandsTp", "Produce Initial Anonymizer For Timepoint", 2, 6],
    [ "BackgroundHelloWorld.py", "Python Hello World Background", 2, 7],
  );
  my @Cols;
  for my $i (@buttons){
    my($op, $cap, $col, $row) = @$i;
    unless(defined $Cols[$col]) {
      $Cols[$col] = [];
    }
    $Cols[$col]->[$row] = [$op, $cap];
  }
  $self->{NewActivities}->{ops} = {};
  $http->queue('<table class="table table-striped table-condensed">');
  my $c0c = @{$Cols[0]};
  my $c1c = @{$Cols[1]};
  my $c2c = @{$Cols[2]};
  while($c0c > 0 || $c1c > 0 || $c2c > 0 ){
    $http->queue("<tr>");
    if($c0c > 0){
      my $foo = shift(@{$Cols[0]});
      $c0c = @{$Cols[0]};
      my($op, $cap) = @$foo;
      $self->{NewActivities}->{ops}->{$op} = $cap;
      $http->queue("<td>");
#xyzzy
      $self->NotSoSimpleButtonPopularity($http, {
        op => "InvokeOperation",
        caption => $cap,
        operation => $op,
        sync => "Update();",
      });
      $http->queue("</td>");
    } else {
      $http->queue("<td></td>");
    }
    if($c1c > 0){
      my $foo = shift(@{$Cols[1]});
      $c1c = @{$Cols[1]};
      my($op, $cap) = @$foo;
      $self->{NewActivities}->{ops}->{$op} = $cap;
      $http->queue("<td>");
      $self->NotSoSimpleButtonPopularity($http, {
        op => "InvokeOperation",
        caption => $cap,
        operation => $op,
        sync => "Update();",
      });
      $http->queue("</td>");
    } else {
      $http->queue("<td></td>");
    }
    if($c2c > 0){
      my $foo = shift(@{$Cols[2]});
      $c2c = @{$Cols[2]};
      my($op, $cap) = @$foo;
      $self->{NewActivities}->{ops}->{$op} = $cap;
      $http->queue("<td>");
      $self->NotSoSimpleButtonPopularity($http, {
        op => "InvokeOperation",
        caption => $cap,
        operation => $op,
        sync => "Update();",
      });
      $http->queue("</td>");
    } else {
      $http->queue("<td></td>");
    }
    $http->queue("</tr>");
  }
  $http->queue("</table>");
}

method InvokeOperation($http, $dyn){
#  my $class = "Posda::ProcessPopup";
  my $class = $dyn->{class_};
  unless(defined $class){
    $class = "Posda::ProcessPopup";
  }
  eval "require $class";
  #print STDERR Dumper($dyn);
  #Button Popularity'
  Query('IncreaseButtonPopularity')->RunQuery(sub{}, sub{},$dyn->{operation});
  my $params = {
    button => $dyn->{operation},
    activity_id => $self->{ActivitySelected},
    notify => $self->get_user,
  };
  unless(exists $self->{sequence_no}){$self->{sequence_no} = 0}
  if($@){
    print STDERR "Posda::TestProcessPopup failed to compile\n\t$@\n";
    return;
  }
  my $name = "StartBackground_$self->{sequence_no}";
  $self->{sequence_no}++;

  my $child_path = $self->child_path($name);
  my $child_obj = $class->new($self->{session},
                              $child_path, $params);
  $self->StartJsChildWindow($child_obj);
}
#xyzzy
method InvokeOperationRow($http, $dyn){
#  my $class = "Posda::ProcessPopup";
  my $class = $dyn->{class_};
  unless(defined $class){
    $class = "Posda::ProcessPopup";
  }
  if($class eq "Quince") { $class = "ActivityBasedCuration::Quince" }
  eval "require $class";
  if($@){
    print STDERR "$class failed to compile\n\t$@\n";
    return;
  }
  my $table = $self->{ForegroundQueries}->{$self->{NewQueryToDisplay}};
  my $params = {
#    button => $dyn->{operation},
    button => $dyn->{cap_},
    activity_id => $self->{ActivitySelected},
    notify => $self->get_user,
  };
  my $cols = $table->{query}->{columns};
  my $rows;
  if($self->{FilterSelection}->{$self->{NewQueryToDisplay}} eq "unfiltered"){
   $rows = $table->{rows};
  } else {
   $rows = $table->{filtered_rows};
  }
  my $row = $rows->[$dyn->{row}];

  # build hash for popup constructor
  for my $i (0 .. $#{$row}) {
    $params->{$cols->[$i]} = $row->[$i];
  }

  unless(exists $self->{sequence_no}){$self->{sequence_no} = 0}
  my $name = "StartBackground_$self->{sequence_no}";
  $self->{sequence_no}++;

  my $child_path = $self->child_path($name);
  my $child_obj = $class->new($self->{session},
                              $child_path, $params);
  $self->StartJsChildWindow($child_obj);
}
method NewQueryWait($http, $dyn){
  $http->queue("Waiting for query: $self->{WaitingForQueryCompletion}");
}
method Queries($http,$dyn){
  unless(exists $self->{ForegroundQueries}){ $self->{ForegroundQueries} = {} }
  if(
    exists($self->{NewQueryToDisplay})&&
    exists($self->{ForegroundQueries}->{$self->{NewQueryToDisplay}})
  ){
    return $self->DisplaySelectedForegroundQuery($http, $dyn);
  }
  if(exists($self->{WaitingForQueryCompletion})){
    return $self->NewQueryWait($http, $dyn);
  }
#  if(exists($self->{SelectFromCurrentForeground})){
#    return $self->SelectFromCurrentForeground($http, $dyn);
#  }
  unless (exists($self->{SelectedNewQuery})){
    $http->queue(qq{
      <div style="display: flex; flex-direction: row; align-items: flex-end; margin-bottom: 5px">
    });
#    $self->DrawCurrentForegroundQueriesSelector($http, $dyn);
    $self->DrawQueryListTypeSelector($http, $dyn);
    $self->DrawQuerySearchForm($http, $dyn);
    $http->queue(qq{</div><hr>});
  }
  $self->DrawQueryListOrResults($http, $dyn);
}
method DrawCurrentForegroundQueriesSelector($http, $dyn){
  unless(exists $self->{ForegroundQueries}){ $self->{ForegroundQueries} = {} }
  my $q_count = keys %{$self->{ForegroundQueries}};
  if($q_count > 0){
    $self->NotSoSimpleButton($http, {
      op => "SetCurrentForegroundSelection",
      caption => "select from foreground",
      sync => "Update();",
    });
  }
}
method SetCurrentForegroundSelection($http, $dyn){
  $self->{SelectFromCurrentForeground} = 1;
}
method SelectFromCurrentForeground($http, $dyn){
  #$http->queue("display list of current foreground queries");
  $http->queue(qq{
    <div style="display: flex; flex-direction: column; align-items: flex-beginning; margin-bottom: 5px">
});
#  delete $self->{SelectFromCurrentForeground};
#  $self->NotSoSimpleButton($http, {
#    op => "ClearCurrentForegroundSelector",
#    caption => "clear",
#    sync => "Update();",
#  });
  $http->queue('<table class="table table-striped table-condensed">');
  $http->queue("<caption>Current Foreground Queries</caption>");
  $http->queue("<tr><th>id</th><th>query</th><th>when</th><th>state</th><th>rows</th><th>");
  $self->NotSoSimpleButton($http, {
    op => "DeleteAllForegroundQuery",
    caption => "dismiss/delete all",
    sync => "Update();",
  });
  $http->queue("</th></tr>");
  for my $k (
    sort {
      $self->{ForegroundQueries}->{$a}->{invoked_id} <=>
      $self->{ForegroundQueries}->{$b}->{invoked_id}
    }
    keys %{$self->{ForegroundQueries}}
  ){
    my $e = $self->{ForegroundQueries}->{$k};
    my $num_rows = @{$e->{rows}};
    $http->queue("<tr>");
    $http->queue("<td>$e->{invoked_id}</td>");
    $http->queue("<td>$e->{caption}</td>");
    $http->queue("<td>$e->{when}</td>");
    $http->queue("<td>$e->{status}</td>");
    $http->queue("<td>$num_rows</td>");
    $http->queue("<td>");
    $self->NotSoSimpleButton($http, {
      op => "SelectCurrentForegroundQuery",
      caption => "select",
      index => $k,
      sync => "Update();",
    });
    $self->NotSoSimpleButton($http, {
      op => "DeleteCurrentForegroundQuery",
      caption => "dismiss",
      index => $k,
      sync => "Update();",
    });
    if($e->{status} eq "running"){
      $self->NotSoSimpleButton($http, {
        op => "PauseRunningQuery",
        caption => "pause",
        index => $k,
        sync => "Update();",
      });
      $self->NotSoSimpleButton($http, {
        op => "CancelRunningQuery",
        caption => "abort",
        index => $k,
        sync => "Update();",
      });
    } elsif ($e->{status} eq "paused"){
      $self->NotSoSimpleButton($http, {
        op => "UnPauseRunningQuery",
        caption => "resume",
        index => $k,
        sync => "Update();",
      });
      $self->NotSoSimpleButton($http, {
        op => "CancelRunningQuery",
        caption => "end",
        index => $k,
        sync => "Update();",
      });
    } elsif ($e->{status} eq "done"){
      $self->NotSoSimpleButton($http, {
        op => "RefreshQuery",
        caption => "refresh",
        index => $k,
        sync => "Update();",
      });
      $self->NotSoSimpleButton($http, {
        op => "RerunQuery",
        caption => "re-run",
        index => $k,
        sync => "Update();",
      });
    }
    $http->queue("</td>");
    $http->queue("</tr>");
  }
  $http->queue("</table>");
  $http->queue("</div>");
}
sub DeleteAllForegroundQuery{
  my($self, $http, $dyn) = @_;
  for my $i (keys %{$self->{ForegroundQueries}}){
    delete $self->{ForegroundQueries}->{$i};
  }
  delete $self->{SelectFromCurrentForeground};
}
sub DeleteCurrentForegroundQuery{
  my($self, $http, $dyn) = @_;
  my $k = $dyn->{index};
  delete $self->{ForegroundQueries}->{$k};
  my $num_queries = keys %{$self->{ForegroundQueries}};
  if($num_queries == 0){
    delete $self->{SelectFromCurrentForeground};
  }
}
sub SelectCurrentForegroundQuery{
  my($self, $http, $dyn) = @_;
  my $k = $dyn->{index};
  $self->{NewQueryToDisplay} = $k;
}

sub ClearCurrentForegroundSelector{
  my($self, $http, $dyn) = @_;
  delete $self->{SelectFromCurrentForeground};
}
sub DrawQueryListTypeSelector{
  my($self, $http, $dyn) = @_;
  if (not defined $self->{NewActivityQueriesType}) {
    $self->{NewActivityQueriesType} = {};
  }
  unless(defined $self->{NewActivityQueriesType}->{query_type}){
    $self->{NewActivityQueriesType}->{query_type} = "recent";
  }
  $http->queue("<div width=100>");
  my $url = $self->RadioButtonSync("query_type","active",
    "ProcessRadioButton",
    (defined($self->{NewActivityQueriesType}) && $self->{NewActivityQueriesType}->{query_type} eq "active") ? 1 : 0,
    "&control=NewActivityQueriesType","Update();");
  my $q_count = keys %{$self->{ForegroundQueries}};
  if($q_count > 0){
    $http->queue("$url - active&nbsp;&nbsp;");
  }
  my $url = $self->RadioButtonSync("query_type","recent",
    "ProcessRadioButton",
    (defined($self->{NewActivityQueriesType}) && $self->{NewActivityQueriesType}->{query_type} eq "recent") ? 1 : 0,
    "&control=NewActivityQueriesType","Update();");
  $http->queue("$url - recent&nbsp;&nbsp;");

  $url = $self->RadioButtonSync("query_type","search",
    "ProcessRadioButton",
    (defined($self->{NewActivityQueriesType}) && $self->{NewActivityQueriesType}->{query_type} eq "search") ? 1 : 0,
    "&control=NewActivityQueriesType","Update();");
  $http->queue("$url - search");
  $http->queue("</div>");
}
sub DrawQuerySearchForm{
  my($self, $http, $dyn) = @_;
  if((defined $self->{NewActivityQueriesType}) &&
    $self->{NewActivityQueriesType}->{query_type} eq "search"){
    $http->queue('<div width=100 style="margin-left: 10px">');
    $http->queue("&nbsp;Args containing:&nbsp; ");
    $self->BlurEntryBox($http, {
      name => "NewArgList",
      op => "SetNewArgList",
      value => "$self->{NewArgListText}"
    });
    $http->queue("</div>");
    $http->queue('<div width=100 style="margin-left: 10px">');
    $http->queue("&nbsp;Columns containing:&nbsp; ");
    $self->BlurEntryBox($http, {
      name => "NewColList",
      op => "SetNewColList",
      value => "$self->{NewColListText}"
    });
    $http->queue("</div>");
    $http->queue('<div width=100 style="margin-left: 10px">');
    $http->queue("&nbsp;Query matching:&nbsp; ");
    $self->BlurEntryBox($http, {
      name => "NewTableMatchList",
      op => "SetNewTableMatchList",
      value => "$self->{NewTableMatchListText}"
    });
    $http->queue("</div>");
    $http->queue('<div width=100 style="margin-left: 10px">');
    $http->queue("&nbsp;Name matching:&nbsp; ");
    $self->BlurEntryBox($http, {
      name => "NewNameMatchList",
      op => "SetNewNameMatchList",
      value => "$self->{NewNameMatchListText}"
    });
    $http->queue("</div>");
    $http->queue('<div width=100 style="margin-left: 10px">');
    $http->queue("<br>");
    $self->NotSoSimpleButton($http, {
      op => "SearchQueries",
      caption => "search",
      sync => "Update();",
    });
    $http->queue("</div>");
    $http->queue('<div width=100 style="margin-left: 10px">');
    $http->queue("<br>");
    $self->NotSoSimpleButton($http, {
      op => "ClearQueries",
      caption => "clear",
      sync => "Update();",
    });
    $http->queue("</div>");
    $http->queue('<div width=100 style="margin-left: 10px">');
    $http->queue($self->{QuerySearchWhereClause});
    $http->queue("</div>");
  }
}
sub ClearQueries{
  my($self, $http, $dyn) = @_;
  $self->{NewArgList} = [];
  $self->{NewArgListText} = "";
  $self->{NewColList} = [];
  $self->{NewColListText} = "";
  $self->{NewTableMatchList} = [];
  $self->{NewTableMatchListText} = "";
  $self->{NewNameMatchList} = [];
  $self->{NewNameMatchListText} = "";
  return $self->SearchQueries($http, $dyn);
}
sub SearchQueries{
  my($self, $http, $dyn) = @_;
  my @clauses;
  if(exists($self->{NewArgList}) && ref($self->{NewArgList}) eq "ARRAY"){
    for my $i (@{$self->{NewArgList}}){ push @clauses, $i }
  } if(exists($self->{NewColList}) && ref($self->{NewColList}) eq "ARRAY"){
    for my $i (@{$self->{NewColList}}){ push @clauses, $i }
  }
  if(exists($self->{NewTableMatchList}) && ref($self->{NewTableMatchList}) eq "ARRAY"){
    for my $i (@{$self->{NewTableMatchList}}){ push @clauses, $i }
  }
  if(exists($self->{NewNameMatchList}) && ref($self->{NewNameMatchList}) eq "ARRAY"){
    for my $i (@{$self->{NewNameMatchList}}){ push @clauses, $i }
  }
  my $where_clause = join (' and ', @clauses);
  if($where_clause =~ /^\s*$/){
    $self->{QuerySearchWhereClause} = "";
    $self->{NewQueryListSearch} = {};
    return
  }
  $self->{QuerySearchWhereClause} = $where_clause;
  my $query_search_query = "select name from queries where $where_clause order by name";
#print STDERR "query:\n$query_search_query\n";

  $self->{HTTP_APP_CONFIG} = $main::HTTP_APP_CONFIG;
  my $db_handle = DBI->connect(Database('posda_queries'));
  my $q = $db_handle->prepare($query_search_query);
  my $h = $q->execute;
  my @query_names;
  my %SearchedQueriesByName;
  while(my $h = $q->fetchrow_hashref()){
   push @query_names, $h->{name};
   $SearchedQueriesByName{$h->{name}} = PosdaDB::Queries->GetQueryInstance($h->{name});
  }
  $self->{NewQueryListSearch} = \%SearchedQueriesByName;
}
sub SetNewArgList{
  my($self, $http, $dyn) = @_;
  $self->{NewArgListText} = $dyn->{value};
  my @a_list = split(/\s*,\s*/, $dyn->{value});
  my @clauses;
  for my $a (@a_list){
    push(@clauses, "('$a' = ANY(args))");
  }
  $self->{NewArgList} = \@clauses;
}
sub SetNewColList{
  my($self, $http, $dyn) = @_;
  $self->{NewColListText} = $dyn->{value};
  my @a_list = split(/\s*,\s*/, $dyn->{value});
  my @clauses;
  for my $a (@a_list){
    push(@clauses, "('$a' = ANY(columns))");
  }
  $self->{NewColList} = \@clauses;
}
sub SetNewTableMatchList{
  my($self, $http, $dyn) = @_;
  $self->{NewTableMatchListText} = $dyn->{value};
  my @a_list = split(/\s*,\s*/, $dyn->{value});
  my @clauses;
  for my $a (@a_list){
    push(@clauses, "(query like '%$a%')");
  }
  $self->{NewTableMatchList} = \@clauses;
}
sub SetNewNameMatchList{
  my($self, $http, $dyn) = @_;
  $self->{NewNameMatchListText} = $dyn->{value};
  my @a_list = split(/\s*,\s*/, $dyn->{value});
  my @clauses;
  for my $a (@a_list){
    push(@clauses, "(name like '%$a%')");
  }
  $self->{NewNameMatchList} = \@clauses;
}
sub DrawQueryListOrResults{
  my($self, $http, $dyn) = @_;
  if((defined $self->{NewActivityQueriesType}) &&
    $self->{NewActivityQueriesType}->{query_type} eq "search"){
    $self->DrawQueryListOrResultsSearch($http, $dyn);
  } elsif((defined $self->{NewActivityQueriesType}) &&
    $self->{NewActivityQueriesType}->{query_type} eq "active"){
    if(exists $self->{SelectedNewQuery}){
      $self->DrawQueryListOrResultsSearch($http, $dyn);
    } else {
      $self->SelectFromCurrentForeground($http, $dyn);
    }
#    $self->DrawQueryListOrResultsSearch($http, $dyn);
  } else {
    $self->DrawQueryListOrResultsRecent($http, $dyn);
  }
}
sub DrawQueryListOrResultsSearch{
  my($self, $http, $dyn) = @_;
  if(exists($self->{NewQueryResults})){
    $self->DrawNewQueryResults($http, $dyn);
  } else {
    $self->DrawQueryListOrSelectedQuerySearch($http, $dyn);
  }
}
sub DrawQueryListOrSelectedQuerySearch{
  my($self, $http, $dyn) = @_;
  if(exists $self->{SelectedNewQuery}){
    $self->DrawNewQuery($http, $dyn);
  } else {
    $self->DrawQueryListSearch($http, $dyn);
  }
}
sub RunNewQuery{
  my($self, $http, $dyn) = @_;
  $self->{SelectedNewQuery} = $dyn->{query_name};
}
sub OpenNewChainedQuery{
  my($self, $http, $dyn) = @_;
  my $SFQ = $self->{ForegroundQueries}->{$self->{NewQueryToDisplay}};
  my $id = $dyn->{chained_query_id};
  my $query_name = $dyn->{to_query};

  my $details = PosdaDB::Queries->GetChainedQueryDetails($id);
  # DEBUG Dumper($details);

  # get the row as a hash?
  my $h = {};

  my $cols = $SFQ->{query}->{columns};
  my $rows = $SFQ->{rows};
  my $row = $rows->[$dyn->{row}];

  # build hash for popup constructor
  for my $i (0 .. $#{$row}) {
    $h->{$cols->[$i]} = $row->[$i];
  }


  # DEBUG Dumper($h);
  # $h now holds the values of the row as a hash
  for my $param (@$details) {
    delete $self->{Input}->{$param->{to_parameter_name}};
    if(exists $self->{BindingCache}->{$param->{to_parameter_name}}){
      unless(
        $self->{BindingCache}->{$param->{to_parameter_name}} eq
        $h->{$param->{from_column_name}}
      ){
        $self->{BindingCache}->{$param->{to_parameter_name}} =
          $h->{$param->{from_column_name}};
        $self->UpdateBindingValueInDb($param->{to_parameter_name});
      }
    } else {
      $self->{BindingCache}->{$param->{to_parameter_name}} =
        $h->{$param->{from_column_name}};
      $self->CreateBindingCacheInfoForKeyInDb($param->{to_parameter_name});
    }
  }
  $self->{SelectedNewQuery} = $query_name;
  delete $self->{NewQueryToDisplay};
  if($self->{NewActivityQueriesType}->{query_type} eq "search"){
    $self->{NewQueryListSearch}->{$self->{SelectedNewQuery}} =
      PosdaDB::Queries->GetQueryInstance($query_name);
  } else {
    $self->{NewQueriesByName}->{$self->{SelectedNewQuery}} =
      PosdaDB::Queries->GetQueryInstance($query_name);
  }
}

sub RerunQuery{
  my($self, $http, $dyn) = @_;
  $self->{NewQueryToDisplay} = $dyn->{index};
  $self->RerunCurrentForegroundQuery($http, $dyn);;
}

sub RerunCurrentForegroundQuery{
  my($self, $http, $dyn) = @_;
  my $q_pack = $self->{ForegroundQueries}->{$self->{NewQueryToDisplay}};
  delete $self->{NewQueryToDisplay};
  $self->{SelectedNewQuery} = $q_pack->{query}->{name};
}

sub DrawNewQuery{
  my($self, $http, $dyn) = @_;
#  $http->queue("NewQuery goes here ($self->{SelectedNewQuery})");
  my $q_name = $self->{SelectedNewQuery};
  my $query;
  if(
    exists($self->{NewQueryListSearch}) &&
    ref($self->{NewQueryListSearch}) eq "HASH" &&
    exists($self->{NewQueryListSearch}->{$q_name})
  ){
    $query = $self->{NewQueryListSearch}->{$q_name};
  } elsif (
    exists($self->{NewQueriesByName}) &&
    ref($self->{NewQueriesByName}) eq "HASH" &&
    exists($self->{NewQueriesByName}->{$q_name})
  ){
    $query = $self->{NewQueriesByName}->{$q_name};
  } else {
    warn "Query name '$q_name' not found at " . __LINE__ . "\n";
  }

  $http->queue(qq{
    <div style="display: flex; flex-direction: column; align-items: flex-beginning; margin-bottom: 5px">
});
  $http->queue(qq{
    <div style="display: flex; flex-direction: row; align-items: flex-end; margin-bottom: 5px">
  });
  #$http->queue('<div width=100 style="margin-right: 5pix">');
  $http->queue('<div width=100 style="margin-left: 10px">');
  $self->NotSoSimpleButton($http, {
    op => "MakeNewQuery",
    caption => "query",
    sync => "Update();",
    class => "btn btn-primary",
  });
  $http->queue('</div>');
  $http->queue('<div width=100 style="margin-left: 10px">');
  $self->NotSoSimpleButton($http, {
    op => "ClearNewQuery",
    caption => "clear",
    sync => "Update();",
    class => "btn btn-primary",
  });
  $http->queue("</div>");
  $http->queue(qq{
    <div style="display: flex; flex-direction: column; align-items: flex-beginning; margin-bottom: 5px">
});
  $http->queue('<div width=100 style="margin-left: 10px">');
  $http->queue("<strong>Query name:</strong> $self->{SelectedNewQuery}");
  $http->queue("</div>");
  $http->queue('<div width=100 style="margin-left: 10px">');
  $http->queue('<strong>Columns returned:</strong> ');
  for my $i (0 .. $#{$query->{columns}}){
    $http->queue("$query->{columns}->[$i]");
    unless($i == $#{$query->{columns}}){ $http->queue(", ") }
  }
  $http->queue("</div>");
  $http->queue("</div>");
  $http->queue("</div>");
  $http->queue("<strong>Arguments:</strong>");
  $http->queue(q{<table class="table">});
  my $from_seen = 0;
  for my $arg (@{$query->{args}}){
    # preload the Input if arg is in cache
    if (
      defined $self->{BindingCache}->{$arg} and
      not defined $self->{Input}->{$arg}
    ) {
      $self->{Input}->{$arg} = $self->{BindingCache}->{$arg};
    }
    $self->RefreshEngine($http, $dyn, qq{
       <tr>
         <th style="width:5%">$arg</th>
         <td>
           <?dyn="LinkedDelegateEntryBox" linked="Input" index="$arg"?>
         </td>
       </tr>
    });
    if ($arg eq 'from') { $from_seen = 1; }
    if ($arg eq 'to' and $from_seen == 1) {
      $self->DrawWidgetFromTo($http, $dyn);
    }
  }

  $http->queue(q{</table>});
  $http->queue(q{<hr>});
  $self->RefreshEngine($http, $dyn,
           "<pre><code class=\"sql\">$query->{query}</code></pre>");
  #$self->RefreshEngine($http, $dyn, markdown($query->{query}));
  $http->queue("</div>");
}

method MakeNewQuery($http, $dyn){
  my $query_name = $self->{SelectedNewQuery};
  my $query;
  if($self->{NewActivityQueriesType}->{query_type} eq "search"){
    $query = $self->{NewQueryListSearch}->{$self->{SelectedNewQuery}};
  } else {
    $query = $self->{NewQueriesByName}->{$self->{SelectedNewQuery}};
  }
  $query->SetNewAsync();
  my @args;
  for my $name (@{$query->{args}}){
    if(exists $self->{BindingCache}->{$name}){
      if($self->{BindingCache}->{$name} ne $self->{Input}->{$name}){
        $self->{BindingCache}->{$name} = $self->{Input}->{$name};
        $self->UpdateBindingValueInDb($name);
      }
    } else {
      $self->{BindingCache}->{$name} = $self->{Input}->{$name};
      $self->CreateBindingCacheInfoForKeyInDb($name);
    }
    push @args, $self->{Input}->{$name};
  }
  my $msg = "$query_name(";
  for my $i (0 .. $#args){
    my $arg = $args[$i];
    if($i == $#args){$msg .= "$arg"}
    else {$msg .= "$arg, "}
  }
  $msg .= ")";
  print STDERR"################\n$msg\n###############\n";
  my $guid = Posda::UUID::GetGuid;
  my $invoked_id = Posda::QueryLog::query_invoked($query, $self->get_user);
  my $when = $self->now;;
  $self->{ForegroundQueries}->{$guid} = {
    caption => $msg,
    query => $query,
    when => $when,
    who => $self->get_user,
    args => \@args,
    status => "running",
    rows => [],
    invoked_id => $invoked_id
  };
  delete $self->{SelectedNewQuery};
  $self->{NewQueryToDisplay} = $guid;
  #$self->{WaitingForQueryCompletion} = $msg;
  my $q_pack = $self->{ForegroundQueries}->{$guid};
  $query->RunQuery(
    func($row){
      push @{$q_pack->{rows}}, $row;
    },
    func($msg){
      if($msg =~ /^RESULT:(.*)$/s){
        $q_pack->{status} = "done";
        $q_pack->{completion_msg} = $1;
        Posda::QueryLog::query_finished($invoked_id, $#{$q_pack->{rows}} + 1);
      } elsif($msg =~ /^ERROR:(.*)$/s){
        $q_pack->{status} = "error";
        $q_pack->{completion_msg} = $1;
      }
      if($self->{NewQueryToDisplay} == $guid){
        $self->AutoRefresh;
      }
    },
    @args);
}
sub RefreshCurrentForegroundQuery{
  my($self, $http, $dyn) = @_;
  my $quid = $self->{NewQueryToDisplay};
  $self->RefreshQuery($http, { index => $quid });
}
sub RefreshQuery{
  my($self, $http, $dyn) = @_;
  my $guid = $dyn->{index};
  my $query = $self->{ForegroundQueries}->{$guid}->{query};
  my $invoked_id = Posda::QueryLog::query_invoked($query, $self->get_user);
  $self->{ForegroundQueries}->{$guid}->{when} = $self->now;
  $self->{ForegroundQueries}->{$guid}->{status} = "running";
  $self->{ForegroundQueries}->{$guid}->{rows} = [];

  delete $self->{SelectedNewQuery};
  $self->{NewQueryToDisplay} = $guid;
  #$self->{WaitingForQueryCompletion} = $msg;
  my $q_pack = $self->{ForegroundQueries}->{$guid};
  $query->RunQuery(
    func($row){
      push @{$q_pack->{rows}}, $row;
    },
    func($msg){
      if($msg =~ /^RESULT:(.*)$/s){
        $q_pack->{status} = "done";
        $q_pack->{completion_msg} = $1;
        Posda::QueryLog::query_finished($invoked_id, $#{$q_pack->{rows}} + 1);
      } elsif($msg =~ /^ERROR:(.*)$/s){
        $q_pack->{status} = "error";
        $q_pack->{completion_msg} = $1;
      }
      if($self->{NewQueryToDisplay} == $guid){
        $self->AutoRefresh;
      }
    },
    @{$q_pack->{args}});
}
sub ClearNewQuery{
  my($self, $http, $dyn) = @_;
  delete $self->{SelectedNewQuery};
}
sub DisplayNewQueryRunning{
  my($self, $http, $dyn, $SFQ) = @_;
  my $rows = 0;
  if(exists $SFQ->{rows} && ref($SFQ->{rows}) eq "ARRAY"){
    $rows = @{$SFQ->{rows}};
  }
  $http->queue("Running: $SFQ->{caption}, $rows rows read<br>");
  $self->AutoRefresh;
}
sub DisplayNewQueryError{
  my($self, $http, $dyn, $q) = @_;
  $http->queue(qq{
    <div style="display: flex; flex-direction: column; align-items: flex-beginning; margin-bottom: 5px">
});
  $http->queue("<h1>Error</h1><p>Query invocation: $q->{caption}</p><pre>$q->{completion_msg}</pre>");
  $http->queue("</div>");
  $self->NotSoSimpleButton($http, {
    op => "UnselectForegroundQuery",
    caption => "clear",
    sync => "Update();",
    class => "btn btn-primary",
  });
}
method NewQueryPageUp($http, $dyn){
  my $SFQ = $self->{ForegroundQueries}->{$self->{NewQueryToDisplay}};
  my $new_start = $SFQ->{first_row} + $SFQ->{rows_to_show};
  if($new_start + $SFQ->{rows_to_show} > @{$SFQ->{rows}}){
    $new_start = @{$SFQ->{rows}} - $SFQ->{rows_to_show};
    if($new_start < 0) { $new_start = 0 }
  }
  $SFQ->{first_row} = $new_start;
}
method NewQueryPageDown($http, $dyn){
  my $SFQ = $self->{ForegroundQueries}->{$self->{NewQueryToDisplay}};
  my $new_start = $SFQ->{first_row} - $SFQ->{rows_to_show};
  if($new_start < 0){
    $new_start = 0;
  }
  $SFQ->{first_row} = $new_start;
}
method SetFirstRow($http, $dyn){
  my $SFQ = $self->{ForegroundQueries}->{$self->{NewQueryToDisplay}};
  my $value = $dyn->{value};
  my $max = @{$SFQ->{rows}} - $SFQ->{rows_to_show};
  if($value < 0) { $value = 0 }
  if($value > $max) { $value = $max }
  $SFQ->{first_row} = $value;
}
method SetRowsToShow($http, $dyn){
  my $SFQ = $self->{ForegroundQueries}->{$self->{NewQueryToDisplay}};
  my $value = $dyn->{value};
  $SFQ->{rows_to_show} = $value;
}
method FilterQueryRows($sfq){
  # No filtering for now
  # return $sfq->{rows};
  my %name_to_i;
  for my $i (0 .. $#{$sfq->{query}->{columns}}){
    $name_to_i{$sfq->{query}->{columns}->[$i]} = $i;
  }
  my @filtered_rows;
  row:
  for my $r (@{$sfq->{rows}}){
    for my $k (keys %{$sfq->{filter}}){
      unless($r->[$name_to_i{$k}] =~ /$sfq->{filter}->{$k}/){
        next row;
      }
    }
    push @filtered_rows, $r;
  }
  return \@filtered_rows;
}
method SetEditFilter($http, $queue){
  my $SFQ = $self->{ForegroundQueries}->{$self->{NewQueryToDisplay}};
  if(defined $SFQ->{filter}){
    $self->{FilterArgs} = $SFQ->{filter};
  } else {
    $self->{FilterArgs} = {};
  }
  $self->{EditFilter} = 1;
}
sub DownloadUnfilteredTable{
  my($self, $http, $dyn) = @_;
  $self->DownloadTableFromNewQuery($http, $dyn, "unfiltered");
}
sub DownloadFilteredTable{
  my($self, $http, $dyn) = @_;
  $self->DownloadTableFromNewQuery($http, $dyn, "filtered");
}
sub DownloadTableFromNewQuery{
  my($self, $http, $dyn, $mode) = @_;
  my $SFQ = $self->{ForegroundQueries}->{$self->{NewQueryToDisplay}};
  my $q_name = "$SFQ->{query}->{name}.csv";
  my $rows;
  $http->DownloadHeader("text/csv", "$q_name");
  $http->queue("Metadata:\r\n");
  $http->queue("key,value\r\n");
  $http->queue("query:,\"$SFQ->{caption}\"\r\n");
  $http->queue("when:,$SFQ->{when}\r\n");
  $http->queue("by:,$SFQ->{who}\r\n");
  my $num_rows = @{$SFQ->{rows}};
  my $num_filtered_rows = @{$SFQ->{filtered_rows}};
  if(exists($SFQ->{filter})){
    $http->queue("unfiltered_rows:,$num_rows\r\n");
    $http->queue("filtered_rows:,$num_filtered_rows\r\n");
    my $text = "";
    for my $k (keys %{$SFQ->{filter}}){
      $text .= "$k contains \"$SFQ->{filter}->{$k}\";\n";
    }
    $text =~ s/"/""/g;
    $http->queue("filter:,\"$text\"\r\n");
    $http->queue("\r\n");
    if($mode eq "filtered"){
      $rows = $SFQ->{filtered_rows};
      $http->queue("Filtered Query Data:\r\n");
    } else {
      $rows = $SFQ->{rows};
      $http->queue("Unfiltered Query Data:\r\n");
    }
  } else {
    $http->queue("rows: $num_rows\r\n");
    $http->queue("\r\n");
    $http->queue("Query Data:\r\n");
    $rows = $SFQ->{rows};
  }
  for my $i(0 .. $#{$SFQ->{query}->{columns}}){
    my $col = $SFQ->{query}->{columns}->[$i];
    $http->queue("\"$col\"");
    if($i == $#{$SFQ->{query}->{columns}}){
      $http->queue("\r\n");
    } else { $http->queue(",") };
  }
  for my $i (0 .. $#{$rows}){
    my $row = $rows->[$i];
    for my $j (0 .. $#{$row}){
      my $col = $row->[$j];
      unless(defined $col) { $col = "" }
      $col =~ s/"/""/g;
      $http->queue("\"$col\"");
      if($j == $#{$row}){
        $http->queue("\r\n");
      } else { $http->queue(",") }
    }
  }
}
sub  DisplaySelectedForegroundQuery{
  my($self, $http, $dyn) = @_;
  my $SFQ = $self->{ForegroundQueries}->{$self->{NewQueryToDisplay}};
  if($SFQ->{status} eq 'done'){
    return $self->DisplayFinishedSelectedForegroundQuery($http, $dyn);
  }
  if($SFQ->{status} eq "error"){
    return $self->DisplayNewQueryError($http, $dyn, $SFQ);
  }
  if($SFQ->{status} eq "running"){
    return $self->DisplayNewQueryRunning($http, $dyn, $SFQ);
  }
}
sub  DisplayFinishedSelectedForegroundQuery{
  my($self, $http, $dyn) = @_;
  my $SFQ = $self->{ForegroundQueries}->{$self->{NewQueryToDisplay}};
  my $q_name = $SFQ->{query}->{name};
  my $popup_hash = get_popup_hash($q_name);
$self->{DebugPopupHash} = $popup_hash;
  my $chained_queries = PosdaDB::Queries->GetChainedQueries($SFQ->{query}->{name});
  unless(defined $SFQ->{first_row}) { $SFQ->{first_row} = 0 }
  unless(defined $SFQ->{rows_to_show}) { $SFQ->{rows_to_show} = 30 }
  if(defined $SFQ->{filter}){
    $SFQ->{filtered_rows} = $self->FilterQueryRows($SFQ);
  } else {
    $SFQ->{filtered_rows} = $SFQ->{rows}
  }
  my $num_rows = @{$SFQ->{rows}};
  my $filtered_rows = @{$SFQ->{filtered_rows}};
  $http->queue(qq{
    <div style="display: flex; flex-direction: column; align-items: flex-beginning; margin-bottom: 5px">
});
  $http->queue(qq{
    <div style="display: flex; flex-direction: row; align-items: flex-end; margin-left: 10px">
  });
  $http->queue(qq{ <div width=100 style="margin-bottom: 10px;margin-left: 10px"> });
  $http->queue("<em><b>Results for:</b></em>&nbsp;&nbsp;$SFQ->{caption}&nbsp;&nbsp;&nbsp;");
  $http->queue("</div>");
  $http->queue(qq{ <div width=100 style="margin-bottom: 10px;margin-left: 10px"> });
  $self->NotSoSimpleButton($http, {
    op => "UnselectForegroundQuery",
    caption => "unselect",
    sync => "Update();",
    class => "btn btn-primary",
  });
  $http->queue("</div>");
  $http->queue(qq{ <div width=100 style="margin-bottom: 10px;margin-left: 10px"> });
  $self->NotSoSimpleButton($http, {
    op => "SetEditFilter",
    caption => "edit filter",
    sync => "Update();",
    class => "btn btn-primary",
  });
  $http->queue("</div>");
  $http->queue(qq{ <div width=100 style="margin-bottom: 10px;margin-left: 10px"> });
  $self->NotSoSimpleButton($http, {
    op => "DismissCurrentForegroundQuery",
    caption => "dismiss",
    sync => "Update();",
    class => "btn btn-primary",
  });
  $http->queue("</div>");
  $http->queue(qq{ <div width=100 style="margin-bottom: 10px;margin-left: 10px"> });
  $self->NotSoSimpleButton($http, {
    op => "RefreshCurrentForegroundQuery",
    caption => "refresh",
    sync => "Update();",
    class => "btn btn-primary",
  });
  $http->queue("</div>");
  $http->queue(qq{ <div width=100 style="margin-bottom: 10px;margin-left: 10px"> });
  $self->NotSoSimpleButton($http, {
    op => "RerunCurrentForegroundQuery",
    caption => "re-run",
    sync => "Update();",
    class => "btn btn-primary",
  });
  $http->queue("</div>");
  $http->queue("</div>");

  $http->queue(qq{
    <div style="display: flex; flex-direction: row; align-items: flex-end; margin-left: 10px">
  });
  $http->queue('<table width="50%" class="table">');
  $http->queue('<tr>');
  $http->queue('<td>');
  my $index = $self->{NewQueryToDisplay};
  unless(exists $self->{FilterSelection}->{$index}){ $self->{FilterSelection}->{$index} = "unfiltered" }
  my $url = $self->RadioButtonSync("$index","unfiltered",
    "ProcessRadioButton",
    (defined($self->{FilterSelection}) && $self->{FilterSelection}->{$index} eq "unfiltered") ? 1 : 0,
    "&control=FilterSelection","Update();");
  $http->queue("$url</td>");
  $http->queue("<td>Unfiltered rows: $num_rows</td>");
  $http->queue("<td>");
  $http->queue('<a class="btn btn-primary" href="DownloadUnfilteredTable?obj_path=' .
    $self->{path} . '">download</a>');
  $http->queue("</td>");
  $http->queue("<td>");
  $self->NotSoSimpleButton($http, {
    op => "ChainFilteredTable",
    caption => "chain",
    sync => "Update();",
    class => "btn btn-primary",
  });
  $http->queue("</td>");
  my $rows = keys @{$SFQ->{rows}};
  my $first_row = $SFQ->{first_row};
  $http->queue('<td align="right">First row:</td><td align="left">');
  $self->ClasslessBlurEntryBox($http, {
    name => "FirstRow",
    size => 5,
    op => "SetFirstRow",
    value => $first_row,
  }, "Update();");
  $http->queue("</td><td>");
  $self->NotSoSimpleButton($http, {
    op => "NewQueryPageDown",
    caption => "pg-up",
    sync => "Update();",
    class => "btn btn-primary",
  });
  $http->queue("</td>");
  $http->queue('<td rowspan="2"><pre>');
  unless(exists $SFQ->{filter}){
    $http->queue("No filter currently defined\n\n\n\n</pre>");
  } else {
    $self->RenderCurrentQueryFilter($http, $dyn);
  }
  $http->queue('</pre></td>');
  $http->queue('</tr>');
  $http->queue('<tr>');
  $http->queue('<td>');
  $url = $self->RadioButtonSync($index,"filtered",
    "ProcessRadioButton",
    (defined($self->{FilterSelection}) && $self->{FilterSelection}->{$index} eq "filtered") ? 1 : 0,
    "&control=FilterSelection","Update();");
  $http->queue("$url</td>");
  $http->queue("<td>Filtered rows: $filtered_rows</td>");
  $http->queue("<td>");
  $http->queue('<a class="btn btn-primary" href="DownloadFilteredTable?obj_path=' .
    $self->{path} . '">download</a>');
  $http->queue("</td>");
  $http->queue("<td>");
  $self->NotSoSimpleButton($http, {
    op => "ChainFilteredTable",
    caption => "chain",
    sync => "Update();",
    class => "btn btn-primary",
  });
  $http->queue("</td>");
  $http->queue('<td align="right">Show:</td><td align="left">');
  $self->ClasslessBlurEntryBox($http, {
    name => "RowsToShow",
    size => 5,
    op => "SetRowsToShow",
    value => $SFQ->{rows_to_show},
  }, "Update();");
  $http->queue('</td><td>');
  $self->NotSoSimpleButton($http, {
    op => "NewQueryPageUp",
    caption => "pg-dn",
    sync => "Update();",
    class => "btn btn-primary",
  });
  $http->queue("</td>");
  $http->queue('</tr>');
  $http->queue("</table>");

  $http->queue("</div>");

  if(exists($self->{EditFilter})){
    $self->DrawEditFilterForm($http, $dyn, $SFQ);
  }

#xyzzy
  if (defined $popup_hash->{table_level_popup}) {
    $http->queue("<p>");
    for my $tlp (@{$popup_hash->{table_level_popup}}){
      $self->NotSoSimpleButton($http, {
	  caption => "$tlp->{name}",
	  op => "OpenTableLevelPopup",
	  class_ => "$tlp->{class}",
	  cap_ => "$tlp->{name}",
	  sync => 'Update();'
      });
    }
    $http->queue("</p>");
  }

  $http->queue('<table class="table table-striped table-condensed">');
  $http->queue("<tr>");
  if($#{$chained_queries} > -1){
    $http->queue("<th>chain</th>");
  }
  for my $i (@{$SFQ->{query}->{columns}}){
    $http->queue("<th>$i</th>");
  }
  $http->queue("</tr>");
  my $working_rows;
  if($self->{FilterSelection}->{$self->{NewQueryToDisplay}} eq "filtered"){
    $working_rows = $SFQ->{filtered_rows};
  } else {
    $working_rows = $SFQ->{rows};
  }
  my $num_working_rows = @{$working_rows};
  my $max_row = $SFQ->{first_row} + $SFQ->{rows_to_show} - 1;
  if($max_row > $num_working_rows) { $max_row = $#{$working_rows} }
  for my $i ($SFQ->{first_row} .. $max_row){
    $http->queue("<tr>");
    my $row = $working_rows->[$i];
    if($#{$chained_queries} > -1){
      $http->queue("<td>");
	for my $q (@$chained_queries) {
	  $self->NotSoSimpleButton($http, {
	      caption => "$q->{caption}",
	      op => "OpenNewChainedQuery",
	      row => "$i",
	      chained_query_id => "$q->{chained_query_id}",
	      to_query => "$q->{to_query}",
	      sync => 'Update();'
	  });
	}
      $http->queue("</td>");
    }
    if(ref($row) eq 'ARRAY'){
      for my $j (0 .. $#{$row}){
      my $cn = $SFQ->{query}->{columns}->[$j];
	if(defined $row->[$j]){
	  $http->queue("<td>");
	  $http->queue($row->[$j]);
	  if (defined $popup_hash->{$cn}) {
	    my $popup_details = $popup_hash->{$cn};
#xyzzy
	    $self->NotSoSimpleButton($http, {
		caption => "$popup_details->{name}",
		op => "InvokeOperationRow",
		row => "$i",
		class_ => "$popup_details->{class}",
		cap_ => "$popup_details->{name}",
		sync => 'Update();'
	    });
	  }
	  $http->queue("</td>");
	} else {
	  $http->queue("<td></td>");
	}
      }
    } else {
    }
    $http->queue("</tr>");
  }
  $http->queue("</tr>");
  $http->queue("</table>");
  $http->queue("</div>");
}
method RenderCurrentQueryFilter($http, $dyn){
  my $SFQ = $self->{ForegroundQueries}->{$self->{NewQueryToDisplay}};
  $http->queue("Query Filter:<br>");
  for my $k (keys %{$SFQ->{filter}}){
    if(defined $SFQ->{filter}->{$k} && $SFQ->{filter}->{$k} ne ""){
      $http->queue("   $k contains \"$SFQ->{filter}->{$k}\"<br>");
    } else {
      delete $SFQ->{filter}->{$k};
    }
  }
}
method DrawEditFilterForm($http, $dyn, $SFQ){
  $http->queue(qq{
    <div style="display: flex; flex-direction: row; align-items: flex-end; margin-left: 10px">
  });
  for my $i (@{$SFQ->{query}->{columns}}){
    $http->queue('<div style="display: flex; flex-direction: column; align-items: flex-beginning; ' .
    'margin-left: 10px; margin-bottom: 5px">');
    $http->queue("<p>$i</p>");
    my $name = "QueryForm_$i";
    $self->BlurEntryBox($http, {
      name => $name,
      index => $i,
      op => "SetFilterArgs",
      value => "$self->{FilterArgs}->{$i}"
    });
    $http->queue("</div>");
  }
  $http->queue('<div style="display: flex; flex-direction: column; align-items: flex-beginning; ' .
    'margin-left: 10px; margin-bottom: 5px">');
  $self->NotSoSimpleButton($http, {
    op => "SetFilter",
    caption => "set filter",
    sync => "Update();",
    class => "btn btn-primary",
  });
  $self->NotSoSimpleButton($http, {
    op => "ClearFilter",
    caption => "clear filter",
    sync => "Update();",
    class => "btn btn-primary",
  });
  $http->queue("</div>");
  $http->queue("</div>");
}

method SetFilter($http, $dyn){
  my $SFQ = $self->{ForegroundQueries}->{$self->{NewQueryToDisplay}};
  if((keys %{$self->{FilterArgs}}) > 0){
    $SFQ->{filter} = $self->{FilterArgs};
  }
  delete $self->{EditFilter};
  delete $self->{FilterArgs};
}
method SetFilterArgs($http, $dyn){
  $self->{FilterArgs}->{$dyn->{index}} = $dyn->{value};
}
method ClearFilter($http, $dyn){
  my $SFQ = $self->{ForegroundQueries}->{$self->{NewQueryToDisplay}};
  delete $self->{EditFilter};
  delete $self->{FilterArgs};
  delete $SFQ->{filter};
}
sub  UnselectForegroundQuery{
  my($self, $http, $dyn) = @_;
  delete $self->{NewQueryToDisplay};
}
sub DismissCurrentForegroundQuery{
  my($self, $http, $dyn) = @_;
  my $index = $self->{NewQueryToDisplay};
  delete $self->{NewQueryToDisplay};
  delete $self->{ForegroundQueries}->{$index};
  delete $self->{FilterSelection}->{$index};
}
method DrawNewQueryResults($http, $dyn){
  $http->queue("NewQueryResults goes here");
}
method DrawQueryListSearch($http, $dyn){
  my @MostFrequentSelects = sort {$a cmp $b } keys %{$self->{NewQueryListSearch}};
  my $num_queries = @MostFrequentSelects;
  $http->queue('<table class="table table-striped table-condensed">');
  $http->queue("<caption>Searched queries ($num_queries rows)</caption>");
  $http->queue("<tr><th>name</th><th>params</th><th>columns returned</th>" .
    "<th>make query</th></tr>");
  for my $i (@MostFrequentSelects){
    $http->queue("<tr>");
    my $q = $self->{NewQueryListSearch}->{$i};
    $http->queue("<td>$i</td>");
    $http->queue("<td>");
    my $args = $q->{args};
    for my $i (0 .. $#{$args}){
      $http->queue($args->[$i]);
      unless($i == $#{$args}){
	$http->queue(", ");
      }
    }
    $http->queue("</td>");
    $http->queue("<td>");
    my $cols = $q->{columns};
    for my $i (0 .. $#{$cols}){
      $http->queue($cols->[$i]);
      unless($i == $#{$cols}){
	$http->queue(", ");
      }
    }
    $http->queue("</td>");
    $http->queue("<td>");
    $self->NotSoSimpleButton($http, {
      op => "RunNewQuery",
      caption => "foreground",
      query_name => $i,
      sync => "Update();",
    });
    $self->NotSoSimpleButton($http, {
      op => "OpenBackgroundQuery",
      caption => "background",
      query_name => $i,
      sync => "Update();",
    });
    $http->queue("</td>");
    $http->queue("</tr>");
  }
  $http->queue('</table>');
  $http->queue('<table class="table table-striped table-condensed">');
  $http->queue('</table>')
}
method DrawQueryListOrResultsRecent($http, $dyn){
  if(exists($self->{NewQueryResults})){
    $self->DrawQueryResults($http, $dyn);
  } else {
    $self->DrawQueryListOrSelectedQueryRecent($http, $dyn);
  }
}
method DrawQueryListOrSelectedQueryRecent($http, $dyn){
  if(exists $self->{SelectedNewQuery}){
    $self->DrawNewQuery($http, $dyn);
  } else {
    $self->DrawQueryListRecent($http, $dyn);
  }
}
method DrawQueryListRecent($http, $dyn){
  my @query_list;
  Query('ListOfQueriesPerformedByUserWithLatestAndCount')->RunQuery(sub {
    my($row) = @_;
    push @query_list, $row;
  }, sub {}, $self->get_user);
  my @MostRecentSelects;
  my %NewQueriesByName;
  my @MostFrequentSelects;
  my $i = 0;
  while(1){
    if($i > $#query_list) { last }
    my $q = $query_list[$i];
    $i++;
    if($q->[1] =~ /^select/){
      push @MostRecentSelects, $q->[0];
      $NewQueriesByName{$q->[0]} = PosdaDB::Queries->GetQueryInstance($q->[0]);
    };
    if($i > 5) { last }
  }
  my @sorted_query_list = sort {$b->[3] <=> $a->[3]} @query_list;
  $i = 0;
  my $j = 0;
  while($j < 20){
    if($i > $#sorted_query_list) { last }
    my $q = $sorted_query_list[$i];
    $i++;
    unless($q->[1] =~ /^select/){ next }
    my $qn = $q->[0];
    if(exists $NewQueriesByName{$qn}) { next }
    $j++;
    push @MostFrequentSelects, $q->[0];
    $NewQueriesByName{$q->[0]} = PosdaDB::Queries->GetQueryInstance($q->[0]);
  }
  $self->{MostRecentSelects} = \@MostRecentSelects;
  $self->{MostFrequentSelects} = \@MostFrequentSelects;
  $self->{NewQueriesByName} = \%NewQueriesByName;
  $http->queue('<table class="table table-striped table-condensed">');
  $http->queue('<caption>Most recent queries</caption>');
  $http->queue("<tr><th>name</th><th>params</th><th>columns returned</th>" .
    "<th>make query</th></tr>");
  for my $i (@MostRecentSelects){
    $http->queue("<tr>");
    my $q = $NewQueriesByName{$i};
    $http->queue("<td>$i</td>");
    $http->queue("<td>");
    my $args = $q->{args};
    for my $i (0 .. $#{$args}){
      $http->queue($args->[$i]);
      unless($i == $#{$args}){
	$http->queue(", ");
      }
    }
    $http->queue("</td>");
    $http->queue("<td>");
    my $cols = $q->{columns};
    for my $i (0 .. $#{$cols}){
      $http->queue($cols->[$i]);
      unless($i == $#{$cols}){
	$http->queue(", ");
      }
    }
    $http->queue("</td>");
    $http->queue("<td>");
    $self->NotSoSimpleButton($http, {
      op => "RunNewQuery",
      caption => "foreground",
      query_name => $i,
      sync => "Update();",
    });
    $self->NotSoSimpleButton($http, {
      op => "OpenBackgroundQuery",
      caption => "background",
      query_name => $i,
      sync => "Update();",
    });
    $http->queue("</td>");
    $http->queue("</tr>");
  }
  $http->queue('</table>');
  $http->queue('<table class="table table-striped table-condensed">');
  $http->queue('<caption>Most common  queries (not in recent list)</caption>');
  $http->queue("<tr><th>name</th><th>params</th><th>columns returned</th>" .
   "<th>make query</th></tr>");
  for my $i (@MostFrequentSelects){
    $http->queue("<tr>");
    my $q = $NewQueriesByName{$i};
    $http->queue("<td>$i</td>");
    $http->queue("<td>");
    my $args = $q->{args};
    for my $i (0 .. $#{$args}){
      $http->queue($args->[$i]);
      unless($i == $#{$args}){
	$http->queue(", ");
      }
    }
    $http->queue("</td>");
    $http->queue("<td>");
    my $cols = $q->{columns};
    for my $i (0 .. $#{$cols}){
      $http->queue($cols->[$i]);
      unless($i == $#{$cols}){
	$http->queue(", ");
      }
    }
    $http->queue("</td>");
    $http->queue("<td>");
    $self->NotSoSimpleButton($http, {
      op => "RunNewQuery",
      caption => "foreground",
      query_name => $i,
      sync => "Update();",
    });
    $self->NotSoSimpleButton($http, {
      op => "OpenBackgroundQuery",
      caption => "background",
      query_name => $i,
      sync => "Update();",
    });
    $http->queue("</td>");
    $http->queue("</tr>");
  }
  $http->queue('</table>');
  $http->queue('<table class="table table-striped table-condensed">');
  $http->queue('</table>')
# }
}

#############################
#Here Bill is putting in the "ShowBackground"
method ShowBackground($http, $dyn){
 $self->SemiSerializedSubProcess(
  "FindRunningBackgroundSubprocesses.pl|CsvStreamToPerlStruct.pl",
  $self->LoadScriptOutput("running_subprocesses"));
 if(
   exists $self->{running_subprocesses} and
   ref($self->{running_subprocesses}) eq "HASH" and
   exists($self->{running_subprocesses}->{rows}) and
   ref($self->{running_subprocesses}->{rows}) eq "ARRAY"
 ){
   my $rows = $self->{running_subprocesses}->{rows};
   $http->queue('<table class="table table-striped table-condensed">');
   for my $i (0 .. $#{$rows}){
     $http->queue("<tr>");
     my $sub_id = $rows->[$i]->[0];
     for my $j (0 .. $#{$rows->[$i]}){
       if ($i == 0 ){$http->queue("<th>")
       } else {$http->queue("<td>") }
       my $c = $rows->[$i]->[$j];
       $c =~ s/<\?bkgrnd_id\?>/$sub_id/g;
       $http->queue($c);
       if ($i == 0 ){$http->queue("</th>")
       } else {$http->queue("</td>") }
     }
     $http->queue("</tr>");
    }
    $http->queue("</table>");
  } else {
    $http->queue("Running subprocesses not found");
  }
}
method LoadScriptOutput($table_name) {
  my $sub = sub{
    my($status, $struct) = @_;
    if($status eq "Succeeded"){
      $self->{$table_name} = $struct;
    } else {
      push @{$self->{Errors}}, "Couldn't load script output $table_name";
    }
    $self->AutoRefresh;
  };
  return $sub;
}
#############################
#############################
#Here Bill is putting in the "DownloadTar"
method DownloadTar($http, $dyn){
  my @dirs;
  opendir(DIR, "$ENV{POSDA_CACHE_ROOT}/linked_for_download");
  while(my $dir = readdir(DIR)){
    unless(-d "$ENV{POSDA_CACHE_ROOT}/linked_for_download/$dir"){
      next;
    }
    if($dir =~ /^\./) { next }
    push @dirs, $dir;
  }
  if(@dirs <= 0){
    $http->queue(qq{
      There are no directories ready for download<br>
    });
  } else {
    unless(
      $self->{SelectedDownloadSubdir} &&
      -d "$ENV{POSDA_CACHE_ROOT}/linked_for_download/" .
         $self->{SelectedDownloadSubdir}
    ){
      $self->{SelectedDownloadSubdir} = $dirs[0];
    }
    $self->{DownloadTar} =
      "$ENV{POSDA_CACHE_ROOT}/linked_for_download/" .
      $self->{SelectedDownloadSubdir};
    ########
    # here goes the selection
    $http->queue("Select sub directory: ");
    $self->SelectDelegateByValue($http, {
      op => "SetSelectedDownloadSubdir",
      sync => "Update();",
    });
    for my $i (@dirs){
      $http->queue("<option value=\"$i\"");
      if($i eq $self->{SelectedDownloadSubdir}){
        $http->queue(" selected");
      }
      $http->queue(">$i</option>");
    }
    $http->queue("</select><br>");
    ########
    $http->queue(qq{<br>
      Selected Directory: $self->{DownloadTar}<br>
      <a class="btn btn-primary"
         href="DownloadTarOfThisDirectory?obj_path=$self->{path}">
         Download This Directory as Tar</a>
    });
    $self->NotSoSimpleButton($http, {
      op => "DeleteThisDirectory",
      caption => "Delete This Directory",
      sync => "Update();",
    });
  }
  $self->NotSoSimpleButton($http, {
    op => "SetMode",
    mode => "ListQueries",
    caption => "Cancel",
    sync => "Update();",
  });
}
method SetSelectedDownloadSubdir($http, $dyn){
  $self->{SelectedDownloadSubdir} = $dyn->{value};
}
method DownloadTarOfThisDirectory($http, $dyn){
  my $dir = $self->{DownloadTar};
  my $fh;
  if(open $fh, "(cd $dir && tar -chf - .)|") {
    $http->DownloadHeader("application/x-tgz",
      "$self->{SelectedDownloadSubdir}.tgz");
    Dispatch::Select::Socket->new(
      $self->SendFile($http),
    $fh)->Add("reader");
  } else {
    print STDERR "Yikes: ($!) in DownloadTarOfThisDirectory\n";
  }
}
method DeleteThisDirectory($http, $dyn){
  rmtree($self->{DownloadTar});
}

#############################
method Upload($http, $dyn){
  $self->RefreshEngine($http, $dyn, qq{
  <form action="<?dyn="StoreFileUri"?>"
    enctype="multipart/form-data" method="POST" class="dropzone">
  </form>
  });
}
method StoreFileUri($http, $dyn){
  $http->queue("StoreFile?obj_path=$self->{path}");
}

method StoreFile($http, $dyn){
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

method UploadDone($http, $dyn){
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
  };
  return $sub;
}

method ServeUploadQueue() {
  unless($#{$self->{UploadQueue}} >= 0){ return }
  my $up_load_file = shift @{$self->{UploadQueue}};
  my $command = "ExtractUpload.pl \"$up_load_file\" \"$self->{TempDir}\"";
  my $hash = {};
  Dispatch::LineReader->new_cmd($command, $self->ReadConvertLine($hash),
    $self->ConvertLinesComplete($hash));
}

method ReadConvertLine($hash){
  my $sub = sub {
    my($line) = @_;
    if($line =~ /^(.*):\s*(.*)$/){
      my $k = $1; my $v = $2;
      $hash->{$k} = $v;
    }
  };
  return $sub;
}
method ConvertLinesComplete($hash){
  my $sub = sub {
    push(@{$self->{UploadedFiles}}, $hash);
    # If the file was a CSV, go ahead and load it as a table now
    if (
      $hash->{'mime-type'} eq 'text/csv' ||
      $hash->{'mime-type'} eq 'application/vnd.ms-excel'
    ) {
      $self->LoadCSVIntoTable_NoMode($hash->{'Output file'});
    }
    if ($hash->{'mime-type'} =~ /zip/) {
      DEBUG "Looks like this is a zip/gzip file!";
      $self->ProcessCompressedFile($hash);
    }
    $self->InvokeAfterDelay("ServeUploadQueue", 0);
  };
  return $sub;
}

method ProcessCompressedFile($hash) {
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

  $sub->execute(func($ret) {
      say STDERR Dumper($ret);
  });
}

method Files($http, $dyn){
  unless(exists $self->{UploadedFiles}) { $self->{UploadedFiles} = [] }
  my $num_files = @{$self->{UploadedFiles}};
  if($num_files == 0){
    return $self->RefreshEngine($http, $dyn, "No files have been uploaded");
  }
  $self->RefreshEngine($http, $dyn,
    '<table class="table table-striped table-condensed">' .
    '<tr><th colspan="5"><p>Files Uploaded</p></th></tr>'.
    '<tr><th><p>File</p></th><th><p>Size</p></th><th><p>Type</p></th>' .
    '<th><p>File Type</p></th>' .
    '<th><p>Op</p></th></tr>');
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
      "</p></td><td><p>");
    $self->RefreshEngine($http, $dyn, $i->{file_type} .
      "</p></td><td><p>");
    if($type eq "text/csv"){
      $self->NotSoSimpleButton($http, {
        caption => "Load as Table",
        op => "LoadCsvIntoTable",
        index => $in
      });
    } else {
      if(exists $self->{UploadedFiles}->[$in]->{file_id}){
        $http->queue("File id: " .
          $self->{UploadedFiles}->[$in]->{file_id});
      } else {
        $self->NotSoSimpleButton($http, {
          caption => "Save into DB",
          op => "ImportFileIntoPosda",
          index => $in
        });
      }
    }
    $self->RefreshEngine($http, $dyn, '</p></td></tr>');
  }
  $self->RefreshEngine($http, $dyn, '</table>');
}
method LoadCsvIntoTable($http, $dyn){
  $self->{Mode} = "LoadCsvIntoTable";
  my $file = $self->{UploadedFiles}->[$dyn->{index}]->{"Output file"};

  $self->LoadCSVIntoTable_NoMode($file);
}
method LoadCSVIntoTable_NoMode($file) {
  my $cmd = "CsvToPerlStruct.pl \"$file\"";
  $self->SemiSerializedSubProcess($cmd, $self->CsvLoaded($file));
}

method ImportFileIntoPosda($http, $dyn){
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

method CsvLoaded($file){
  my $sub = sub {
    my($status, $struct) = @_;
    if($status eq "Succeeded"){
      if($struct->{status} eq "OK"){
        unless(
          # create LoadedTables array
          exists $self->{LoadedTables} &&
          ref($self->{LoadedTables}) eq "ARRAY"
        ){ $self->{LoadedTables} = [] }

        ## Get the basename of the file
        #my $basename;
        #my $fn = $file;
        #if($fn =~ /\/([^\/]+)$/){
        #  $basename = $1;
        #} else {
        #  $basename = $fn;
        #}

        ## test if there is a query file to load
        #my $queryfile = "$file.query";
        #my $query;

        ## if $queryfile exists, load it
        #if (-e $queryfile) {
        #  $query = retrieve $queryfile;
        #}

        #if (defined $query) {
        #  $new_table_entry->{query} = $query;
        #  $new_table_entry->{type} = "FromQuery";
        #  #delete the first row, as it is query headers
        #  delete $new_table_entry->{rows}->[0];
        #}

        my $new_table_entry = DbIf::Table::from_csv($file, $struct, time);

        # import the new file into posda
        Dispatch::LineReaderWriter->write_and_read_all(
          "ImportSingleFileIntoPosdaAndReturnId.pl \"$file\" \"DbIf file upload\"",
          [""],
          func($return) {
            for my $i (@$return) {
              if ($i =~ /File id: (.*)/) {
                $new_table_entry->{posda_file_id} = $1;
                # record upload event
                my $upload_id = PosdaDB::Queries::record_spreadsheet_upload(
                  0, $self->get_user, $1, $#{$new_table_entry->{rows}});
                $new_table_entry->{spreadsheet_uploaded_id} = $upload_id;
              } else {
                say STDERR "Error inserting file into posda! $i";
              }
            }
          }
        );

        push(@{$self->{LoadedTables}}, $new_table_entry);
      } else {
      }
    } else {
    }
  };
  return $sub;
}

method Reports($http, $dyn) {
  # load list of reports from the dir
  my $report_dir = $self->{PreparedReportsDir};
  my $common_dir = $self->{PreparedReportsCommonDir};

  opendir(my $dh, $report_dir) or die "Can't open report dir: $report_dir";
  my @files = grep {
    /^[^\.]/ and not /\.query$/
  } readdir($dh); # ignore dots
  closedir $dh;

  opendir(my $cdh, $common_dir) or die "Can't open report dir: $common_dir";
  my @common_files = grep {
    /^[^\.]/ and not /\.query$/
  } readdir($cdh); # ignore dots
  closedir $cdh;

  $http->queue(qq{
    <h3>Common reports</h3>
    <table class="table">
    <tr>
      <th>Filename</th>
      <th>Type</th>
      <th>Bytes</th>
      <th>Download</th>
    </tr>
  });
  for my $f (sort @common_files) {
    my $filename = "$common_dir/$f";
    my $type = (-e "$filename.query")?"Query":"CSV";
    my $size = (stat($filename))[7];
    $http->queue(qq{
      <tr>
      <td>
    });
    $self->NotSoSimpleButton($http, {
        caption => "$f",
        op => "LoadPreparedReport",
        filename => $f,
        ftype => 'common',
        sync => "Update();",
        element => 'a',
        class => "",
    });
    $http->queue(qq{
        </td>
        <td>$type</td>
        <td>$size</td>
        <td>
        <a class="btn btn-primary"
           href="DownloadPreparedReport?obj_path=$self->{path}&filename=$filename&shortname=$f">
           ⬇
        </a>
      </td>
      </tr>
    });
  }
  $http->queue(qq{
    </table>
  });

  $http->queue(qq{
    <h3>Personal (user) reports</h3>
    <table class="table">
    <tr>
      <th>Filename</th>
      <th>Type</th>
      <th>Bytes</th>
    </tr>
  });
  for my $f (@files) {
    my $filename = "$report_dir/$f";
    my $type = (-e "$filename.query")?"Query":"CSV";
    my $size = (stat($filename))[7];
    $http->queue(qq{<tr><td>});
    $self->NotSoSimpleButton($http, {
        caption => "$f",
        op => "LoadPreparedReport",
        filename => $f,
        ftype => 'personal',
        sync => "Update();",
        element => 'a',
        class => "",
    });
    $http->queue(qq{
        </td>
        <td>$type</td>
        <td>$size</td>
      </tr>});
  }
  $http->queue(qq{
    </table>
  });

}

method LoadPreparedReport($http, $dyn) {
  my $dir;
  if ($dyn->{ftype} eq 'common') {
    $dir = $self->{PreparedReportsCommonDir};
  } elsif ($dyn->{ftype} eq 'personal') {
    $dir = $self->{PreparedReportsDir};
  } else {
    die "Unknown ftyp $dyn->{ftype}";
  }
  my $file = "$dir/$dyn->{filename}";

  # couldn't call existing method because we need more control
  my $cmd = "CsvToPerlStruct.pl \"$file\"";
  my $final_callback = $self->CsvLoaded($file);
  $self->SemiSerializedSubProcess($cmd, func() {
    &$final_callback(@_);
    my $index = $#{$self->{LoadedTables}};
    $self->{SelectedTable} = $index;
    $self->{Mode} = "TableSelected";
    $self->AutoRefresh;
  });

  $self->{Mode} = "QueryWait";
}

method Tables($http, $dyn){
  # created LoadedTables array
  unless(exists $self->{LoadedTables}) { $self->{LoadedTables} = [] }
  my $num_tables = @{$self->{LoadedTables}};
  if($num_tables == 0){
    return $self->RefreshEngine($http, $dyn, "No tables have been loaded");
  }
  #TODO: fix this
  $self->RefreshEngine($http, $dyn,
    '<table class="table table-striped table-condensed">' .
    '<tr><th colspan="4"><p>Tables</p></th></tr>'.
    '<tr><th><p>Type</p></th><th><p>Rows</p></th><th><p>File/Query Name</p>' .
    '</th></th>' .
    '<th><p>Op</p></th></tr>');
  file:
  for my $in(0 .. $#{$self->{LoadedTables}}){
    my $i = $self->{LoadedTables}->[$in];
    my $type = $i->{type};
    my $type_disp;
    my $num_rows = @{$i->{rows}};
    my $name;
    if($type eq "FromCsv") {
      $type_disp = "From CSV Upload";
      $name = $i->{basename};
    } elsif ($type eq "FromQuery"){
      $type_disp = "From DB Query";
      $name = "$i->{query}->{schema}:$i->{query}->{name}(";
      for my $bi (0 .. $#{$i->{query}->{bindings}}){
        my $b = $i->{query}->{bindings}->[$bi];
        $name .= "\"$b\"";
        unless($bi == $#{$i->{query}->{bindings}}){
          $name .= ", ";
        }
      }
      $name .= ")";
    }
    $self->RefreshEngine($http, $dyn,
      "<tr><td><p>$type</p></td><td><p>$num_rows</p></td>" .
      "<td><p>$name</p></td><td><p>");
    $self->NotSoSimpleButton($http, {
        caption => "Select",
        op => "SelectTable",
        index => $in,
        sync => "Update();",
    });
    $http->queue(qq{
        <a class="btn btn-primary"
           href="DownloadTableAsCsv?obj_path=$self->{path}&table=$in">
           Download
        </a>
    });
    my $can_nickname = 0;
    my $can_command = 0;
    my $cols = $i->{columns};
    for my $i (@$cols) {
      if(
        $i eq "series_instance_uid" ||
        $i eq "study_instance_uid" ||
        $i eq "sop_instance_uid" ||
        $i eq "file_id"
      ){ $can_nickname = 1 }
      if($i eq "Operation") { $can_command = 1 }
    }
    if($can_nickname){
      $self->NotSoSimpleButton($http, {
          caption => "Add Nicknames",
          op => "AddNicknames",
          index => $in,
          sync => "Update();",
      });
    }
    if($can_command){
      $self->NotSoSimpleButton($http, {
          caption => "Perform Operations",
          op => "ExecuteCommand",
          index => $in,
          sync => "Update();",
      });
    }
    $self->RefreshEngine($http, $dyn, '</p></td></tr>');
  }
  $self->RefreshEngine($http, $dyn, '</table>');
}

sub apply_command{
  my($command, $colmap, $row) = @_;
  if (not defined $command) {
    return undef
  }

  # build the final line
  my $final = $command->{cmdline};
  map {
    my $parm = $_;
    if (not $parm =~ /\?/) {
      my $index_of_parm = $colmap->{$parm};
      my $new_value = $row->[$index_of_parm];

      $final =~ s/<$parm>/$new_value/g;
    }
  } @{$command->{parms}};

  return $final;
}

method ExecuteCommand($http, $dyn) {
  $self->{SelectedTable} = $dyn->{index};
  my $table = $self->{LoadedTables}->[$dyn->{index}];

  # TODO: rethink this, with new DbIf::Table this might
  # be easier!

  # generate a map of column name to col index
  my $colmap = {};
  map {
    my $item = $table->{columns}->[$_];
    $colmap->{$item} = $_;
  } (0 .. $#{$table->{columns}});

  # Test for pipe edge case
  my $first_row_op = $table->{rows}->[0]->[$colmap->{Operation}];
  if (defined $self->{Commands}->{$first_row_op}->{pipe_parms}) {
    my $op = $self->{Commands}->{$first_row_op};

    say "First row is a Pipeop!";

    # get list of columns that are "column vars"
    my @column_vars = $op->{pipe_parms} =~ /<([^<>]+)>/g;

    # transform column_var columns into lists
    my $cols = {};
    for my $col_name (@column_vars) {
      my $col_idx = $colmap->{$col_name};

      my $col1 = [];
      for my $row (@{$table->{rows}}) {
        push @$col1, $row->[$col_idx];
      }

      $cols->{$col_name} = $col1;
    }
    my $parm_map;
    for my $i (@{$op->{parms}}){
      unless(exists $colmap->{$i}) { next }
      my $index_of_parm = $colmap->{$i};
      my $new_value = $table->{rows}->[0]->[$index_of_parm];;
      $parm_map->{$i} = $new_value; 
    }
    # now generate the cmdline like normal
    my $final_cmd = apply_command($op, $colmap, $table->{rows}->[0]);

    my @planned_operations;
    my $first_col_name = [keys %{$cols}]->[0];
    for my $i (0..$#{$cols->{$first_col_name}}) {
      my $pipe_parm_format = $op->{pipe_parms};
      for my $p (keys %$parm_map){
        my $v = $parm_map->{$p};
        unless(defined $v) { next }
        $pipe_parm_format =~ s/<$p>/$v/g;
      }
      for my $var (@column_vars) {
        my $v = $cols->{$var}->[$i];
        $pipe_parm_format =~ s/<$var>/$v/g;
      }
      push @planned_operations, $pipe_parm_format;
    }

    $self->{PlannedOperations} = \@planned_operations;
    $self->{PlannedPipeOperation} = $final_cmd;
    $self->{PlannedPipeOp} = $op;
    $self->{Mode} = 'PipeOperationsSummary';
    return;
  }

  # generate summary of commands to be run
  my @operations = map {
    my $op = $_->[$colmap->{Operation}];
    apply_command($self->{Commands}->{$op}, $colmap, $_);
  } @{$table->{rows}};

  # remove any that failed
  $self->{PlannedOperations} = [grep { defined $_ } @operations];

  $self->{Mode} = 'OperationsSummary';
}

method ExecutePlannedOperations($http, $dyn) {
  $self->{TotalPlannedOperations} = scalar @{$self->{PlannedOperations}};
  $self->UpdateWaitingOnOps($http, $dyn);

  $self->ExecuteNextOperation();
}
method UpdateWaitingOnOps($http, $dyn) {
  my $total = $self->{TotalPlannedOperations};
  my $left = scalar @{$self->{PlannedOperations}};

  $self->{RemainingOpCount} = $left;

  $self->{Mode} = 'WaitingOnOperation';
  $self->AutoRefresh();
}

method ExecuteNextOperation() {
  my $operations = $self->{PlannedOperations};

  my $op = shift @$operations;

  if (not defined $op) {
    say "No ops left, stopping the op train!";
    $self->{Mode} = 'ResultsAreIn';
    $self->AutoRefresh();
    return;
  }

  Dispatch::LineReader->new_cmd(
    $op,
    func($line) {
      # save into output buffer
      push @{$self->{Results}}, $line;
    },
    func() {
      # queue the next one?
      say "finished op: $op";
      $self->UpdateWaitingOnOps();
      $self->ExecuteNextOperation();
    }
  );

}

method ExecutePlannedPipeOperations($http, $dyn) {
  my $table = $self->{LoadedTables}->[$self->{SelectedTable}];

  my $cmd = $self->{PlannedPipeOperation};
  my $stdin = $self->{PlannedOperations};

  my $subprocess_invocation_id;

  if ($self->{PlannedPipeOp}->{type} eq 'background_process') {
    say STDERR "This is a background process! Doing the bp stuff...";


    $subprocess_invocation_id = PosdaDB::Queries::invoke_subprocess(
      1, 0, $table->{spreadsheet_uploaded_id}, undef, undef,
      $cmd, $self->get_user, $self->{PlannedPipeOp}->{operation_name});

    # set the bkgrnd_id field
    $cmd =~ s/<\?bkgrnd_id\?>/$subprocess_invocation_id/;
    $cmd =~ s/<\?spreadsheet_id\?>/$table->{spreadsheet_uploaded_id}/;
  }

  Dispatch::LineReaderWriter->write_and_read_all(
    $cmd,
    $stdin,
    func($return, $pid) {
      $self->{Results} = $return;
      $self->{Mode} = 'ResultsAreIn';
      $self->AutoRefresh;
      say "ResultsAreIn!";

      if (defined $subprocess_invocation_id) {
        # TODO: Is this really useful? the way write_and_read_all()
        # works, the subprocess should always be dead by the time
        # we get here. This is in the spec, but maybe it should be
        # modified?
        PosdaDB::Queries::set_subprocess_pid(
          $subprocess_invocation_id, $pid);
        PosdaDB::Queries::record_subprocess_lines(
          $subprocess_invocation_id, $return);
      }
    }
  );

  $self->{Mode} = 'WaitingOnOperation';
}

method WaitingOnOperation($http, $dyn) {
  $http->queue("<p>Waiting on operations to finish...</p>");
  my $total = $self->{TotalPlannedOperations};
  my $left = $self->{RemainingOpCount};
  if (defined $total and defined $left) {
    $http->queue("<p>Left: $left of: $total</p>");
  }
}

method ResultsAreIn($http, $dyn) {
  $http->queue("<p>results are in!");
  $self->NotSoSimpleButton($http, {
    caption => "Save as CSV",
    op => "SaveResultsAsCsv",
    syn => "Update();",
  });
  $http->queue("</p>");
  map {
    $http->queue("<p>$_</p>");
  } @{$self->{Results}};
}

method SaveResultsAsCsv($http, $dyn){
  my $file = "$self->{TempDir}/OpResults_$self->{Sequence}.csv";
  $self->{Sequence} += 1;
  my $length = 0;
  open my $fh, ">$file" or die "Can't open $file for writing ($!)";
  for my $line (@{$self->{Results}}){
    print $fh "$line\n";
    $length += length("$line\n");
  }
  close $fh;
  my $fdesc = {
    "Output file" => $file,
    file_type => "ASCII text",
    length => $length,
    "mime-type" => "text/csv",
  };
  push @{$self->{UploadedFiles}}, $fdesc;
}

method PipeOperationsSummary($http, $dyn) {
  # display a list of planned operations
  $http->queue(qq{
    <h3>Planned Pipe Operation</h3>
  });

  $self->NotSoSimpleButton($http, {
      caption => "Execute Planned Operations",
      op => "ExecutePlannedPipeOperations",
      sync => "Update();",
  });

  my $cmd_html = encode_entities($self->{PlannedPipeOperation});
  $http->queue(qq{
    <p>The command to be executed:</p>
    <pre>$cmd_html</pre>

    <p>The values to be fed on standard input:</p>
    <table class="table">
      <tr>
        <th>Input</th>
      </tr>
  });

  my $num_ops = @{$self->{PlannedOperations}};
  if($num_ops < 20){
    for my $op (@{$self->{PlannedOperations}}) {
      my $esc_op = $op;
      $esc_op =~ s/</&lt/g;
      $esc_op =~ s/>/&gt/g;
      if (not defined $op) { next }
      $http->queue(qq{
        <tr>
          <td>
            $esc_op
          </td>
        </tr>
      });
    }
  } else {
    for my $i (0 .. 10) {
      my $op = $self->{PlannedOperations}->[$i];
      my $esc_op = $op;
      $esc_op =~ s/</&lt/g;
      $esc_op =~ s/>/&gt/g;
      if (not defined $op) { next }
      $http->queue(qq{
        <tr>
          <td>
            $esc_op
          </td>
        </tr>
      });
    }
    $http->queue(qq{
      <tr>
        <td>
          ...
        </td>
      </tr>
    });
    for my $i ($#{$self->{PlannedOperations}} - 10 .. $#{$self->{PlannedOperations}}) {
      my $op = $self->{PlannedOperations}->[$i];
      my $esc_op = $op;
      $esc_op =~ s/</&lt/g;
      $esc_op =~ s/>/&gt/g;
      if (not defined $op) { next }
      $http->queue(qq{
        <tr>
          <td>
            $esc_op
          </td>
        </tr>
      });
    }
  }

  $http->queue(qq{
    </table>
  });

}

method OperationsSummary($http, $dyn) {
  # display a list of planned operations
  $http->queue(qq{
    <h3>Planned Operations</h3>
  });

  $self->NotSoSimpleButton($http, {
      caption => "Execute Planned Operations",
      op => "ExecutePlannedOperations",
      sync => "Update();",
  });

  $http->queue(qq{
    <table class="table">
      <tr>
        <th>Command Line</th>
      </tr>
  });

  for my $op (@{$self->{PlannedOperations}}) {
    if (not defined $op) { next }
    $http->queue(qq{
      <tr>
        <td>
          $op
        </td>
      </tr>
    });
  }

  $http->queue(qq{
    </table>
  });
}

method SelectTable($http, $dyn){
  $self->{SelectedTable} = $dyn->{index};
  # push new table onto the history stack
  $self->PushToHistory($dyn->{index});
  $self->DebouncedEntryBox_ResetAll;
  $self->{LoadedTables}->[$dyn->{index}]->clear_filters;
  $self->{Mode} = "TableSelected";
}
method PushToHistory($index) {
  DEBUG $index;
  if (not defined $self->{TableHistory}) {
    $self->{TableHistory} = [];
  }

  # if the given index is already in the list, delete it
  my @del_indexes = grep {
    $self->{TableHistory}->[$_] eq $index
  } 0 .. $#{$self->{TableHistory}};
  # this will really only ever return 1 item
  # so this for loop is safe, even though splice changes the array!
  for my $idx (@del_indexes) {
    splice(@{$self->{TableHistory}}, $idx, 1);
  }

  # then add it at the top
  unshift @{$self->{TableHistory}}, $index;
}

1;
