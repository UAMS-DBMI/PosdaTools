package ActivityBasedCuration::Application;

use DbIf::Table;
use File::Path 'rmtree';
use Posda::DB::PosdaFilesQueries;
use Posda::DB 'Query', 'GetHandle';
use Dispatch::BinFragReader;
use ActivityBasedCuration::ButtonDefinition;
use ActivityBasedCuration::WorkflowDefinition;

use Modern::Perl '2010';
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

use ActivityBasedCuration::PopupHelp;
use Posda::QueryLog;

use Text::Markdown 'markdown';

use Debug;
my $dbg = sub {print STDERR @_ };
my $selected_option;

use vars '@ISA';
@ISA = ("GenericApp::Application");

sub titlize {
  my ($string) = @_;
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
  $self->{QueryChaining} = \%ActivityBasedCuration::ButtonDefinition::QueryChaining;
  $self->{QueryChainingDetails} = \%ActivityBasedCuration::ButtonDefinition::QueryChainingDetails;
  $self->{QueryChainingByQuery} = \%ActivityBasedCuration::ButtonDefinition::QueryChainingByQuery;
  $self->{QueryToProcessingButton} = \%ActivityBasedCuration::ButtonDefinition::QueryToProcessingButton;
  $self->{QueryChainColumnButtons} = \%ActivityBasedCuration::ButtonDefinition::QueryChainColumnButtons;
  $self->{QueryButtonsByQueryColumn} =
     \%ActivityBasedCuration::ButtonDefinition::QueryButtonsByQueryColumn;
  $self->{QueryButtonsByQueryPatColumn} =
     \%ActivityBasedCuration::ButtonDefinition::QueryButtonsByQueryPatColumn;
  $self->{WorkflowQueries} = \%ActivityBasedCuration::WorkflowDefinition::WorkflowQueries;
  $self->{MenuByMode} = {
    Default => [
      {
        caption => "Activity",
        op => 'SetMode',
        mode => 'Activities',
        sync => 'Update();'
      },
      {
        caption => "Workflow",
        op => 'SetMode',
        mode => 'ActivityOperations',
        sync => 'Update();'
      },
      {
        caption => "Queries",
        op => 'SetMode',
        mode => 'Queries',
        sync => 'Update();'
      },
      {
        caption => 'Inbox',
        op => 'SetMode',
        mode => 'Inbox',
        sync => 'Update();',
      },
      # {
      #   caption => "QueryEngines",
      #   op => 'SetMode',
      #   mode => 'QueryEngines',
      #   sync => "Update();",
      # },
      {
        caption => "Upload",
        op => 'SetMode',
        mode => 'Upload',
        sync => 'Update();'
      },
      {
        caption => "Upload To Event",
        op => 'LaunchUploadToEventWindow',
        sync => 'Update();',
      },
    ],
    DefaultTail => [
      {
        type => "hr"
      },
      {
        caption => "Download",
        op => 'SetMode',
        mode => 'DownloadTar',
        sync => 'Update();'
      },
#      {
#        caption => "ShowBackground",
#        op => 'SetMode',
#        mode => 'ShowBackground',
#        sync => 'Update();'
#      },
      {
        caption => "Show Background",
        op => 'LaunchBackground',
        mode => 'ShowBackground',
        sync => 'Update();'
      },
      {
        caption => "Verbose Activity Report",
        op => 'setForegroundQuery',
        id => 'query_menu_setForegroundQuery1',
        mode => 'Queries',
        sync => 'Update();',
        query_name => 'VerboseActivityReport'
      },
            {
        caption => "Timepoint File Report",
        op => 'setForegroundQuery',
        id => 'query_menu_setForegroundQuery4',
        mode => 'Queries',
        sync => 'Update();',
        query_name => 'AllFilesInActivityTimepointReport'
      },
      {
        caption => "Visual Reviews",
        op => 'setForegroundQuery',
        id => 'query_menu_setForegroundQuery2',
        mode => 'Queries',
        sync => 'Update();',
        query_name => 'GetVisualReviewByActivityId'
      },
      {
        caption => "Public Collection Counts",
        op => 'setForegroundQuery',
        id => 'query_menu_setForegroundQuery3',
        mode => 'Queries',
        sync => 'Update();',
        query_name => 'PublicCollectionCounts'
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
    my ($name, $cmdline, $type, $input_line, $tags, $can_chain) = @$_;

    if (not defined $input_line) {
      $input_line = "";
    }

    $commands->{$name} = { cmdline => $cmdline,
                           parms => [$cmdline =~ /<([^<>]+)>/g],
                           pipe_parmlist => [$input_line =~ /<([^<>]+)>/g],
                           operation_name => $name,
                           can_chain => $can_chain,
                         };
    if (defined $input_line and $input_line ne "") {
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
  Dispatch::Select::Background->new(sub {
  my ($disp) = @_;
    my $count = $self->{inbox}->UnreadCount;

    my $last_count = 0;
    if (defined $self->{MenuByMode}->{Default}->[3]->{count}) {
      $last_count = $self->{MenuByMode}->{Default}->[3]->{count};
    }

    if ($count > 0 && $count != $last_count) {
      $self->{MenuByMode}->{Default}->[3]->{class} = 'btn btn-danger';
      $self->{MenuByMode}->{Default}->[3]->{caption} = "Inbox ($count)";
      $self->{MenuByMode}->{Default}->[3]->{count} = $count;
      $self->AutoRefresh;
    }

    if ($count == 0 && $count != $last_count) {
      $self->{MenuByMode}->{Default}->[3]->{class} = 'btn btn-default';
      $self->{MenuByMode}->{Default}->[3]->{caption} = "Inbox";
      $self->{MenuByMode}->{Default}->[3]->{count} = $count;
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
    $self->NotSoSimpleButton($http, {
      caption => "Forward this message",
      op => "ForwardInboxItemButtonClick",
      sync => "Update();",
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
  $file_content =~    s( ($RE{URI}{HTTP}{-scheme => qr<https?>}) )
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

  $self->DrawForwardForm($http, $dyn);
  # $self->SelfConfirmingButton($http, {
  #   uniq_id => 'forward_button',
  #   caption => 'Forward this message',
  #   op => 'ForwardInboxItemButtonClick',
  #   message_id => $message_id
  # });

  if (not defined $msg_details->{date_dismissed} and $self->{inbox}->IsItFiled($message_id) == 0 ) {
    $self->SelfConfirmingButton($http, {
      uniq_id => 'file_button',
      caption => 'File this message',
      op => 'FileInboxItemButtonClick',
      message_id => $message_id
    });
  }elsif ($self->{inbox}->IsItFiled($message_id) == 1){
    $http->queue(qq{
      <p class="alert alert-success">This message has already been filed.</p>
    });
  }

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

#print STDERR "#####################\nMode: $mode\n#####################\n";
  my $default_menu = $self->{MenuByMode}->{Default};
  my $mode_menu = $self->{MenuByMode}->{$mode};
  my $default_men_tail = $self->{MenuByMode}->{DefaultTail};

  my @final_menu;

  if (!defined($mode_menu)) {
    @final_menu = @$default_menu;
  } else {
    @final_menu = (@$default_menu, { type => 'hr' }, @$mode_menu);
  }
  if(
    (defined($self->{ActivityModeSelected}) &&
      ($self->{ActivityModes}->{$self->{ActivityModeSelected}} eq "Queries"
    ) || $self->{Mode} eq "Queries")  &&
    exists $self->{NewQueryToDisplay}
  ){
    my $q_info = $self->{ForegroundQueries}->{$self->{NewQueryToDisplay}};
    my $query_menu;
    if(
      $q_info->{status} eq "done" || $q_info->{status} eq "ended" ||
      $q_info->{status} eq "paused"
    ){
      $query_menu = $self->QueryDisplayMenu;
    } else {
      $query_menu = $self->QueryDisplayMenuRunning;
    }
    push @final_menu, {type => 'hr'}, @$query_menu;
    my $SFQ = $self->{ForegroundQueries}->{$self->{NewQueryToDisplay}};
    my $q_name = $SFQ->{query}->{name};
    if(exists $self->{QueryMenuTableBasedButtons}->{$q_name}){
      push @final_menu, {type => 'hr'};
      for my $q_desc (@{$self->{QueryMenuTableBasedButtons}->{$q_name}}){
        push @final_menu, {
          caption => $q_desc->{caption},
          id => "btn_popup_$q_name" . "_$q_desc->{name}",
          op => $q_desc->{operation},
          "class_" => $q_desc->{obj_class},
          "cap_" => "$q_desc->{spreadsheet_operation}",
          _btn_id => "btn_popup_$q_name" . "_$q_desc->{name}",
        }
      }
    }
  }
  @final_menu = (@final_menu, @$default_men_tail);
  return \@final_menu;
}
sub QueryDisplayMenuRunning{
  my($this) = @_;
  my $ret = [
    {
      caption => "Unselect",
      op => 'UnselectForegroundQuery',
      id => 'query_menu_Unselect',
      #mode => 'ListQueries',
      sync => 'Update();'
    },
    {
      caption => "Cancel",
      op => 'CancelCurrentForegroundQuery',
      id => 'query_menu_CancelCurrentForegroundQuery',
      #mode => 'SaveQuery',
      sync => 'Update();'
    },
  ];
  return $ret;
}
sub QueryDisplayMenu{
  my($this) = @_;
  my $edit;
  if(exists $this->{EditFilter}){
    $edit = {
      caption => "Set Filter",
      op => 'SetFilter',
      id => 'query_menu_SetFilter',
      #mode => 'SaveQuery',
      sync => 'Update();'
    };
  } else {
    $edit = {
      caption => "Edit Filter",
      op => 'SetEditFilter',
      id => 'query_menu_EditFilter',
      #mode => 'SaveQuery',
      sync => 'Update();'
    };
  }
  my $ret = [
    {
      caption => "Unselect",
      op => 'UnselectForegroundQuery',
      id => 'query_menu_Unselect',
      #mode => 'ListQueries',
      sync => 'Update();'
    },
    $edit,
    {
      caption => "Clear Filter",
      op => 'ClearFilter',
      id => 'query_menu_ClearFilter',
      #mode => 'SaveQuery',
      sync => 'Update();'
    },
    {
      caption => "Dismiss",
      op => 'DismissCurrentForegroundQuery',
      id => 'query_menu_DismissCurrentForegroundQuery',
      #mode => 'SaveQuery',
      sync => 'Update();'
    },
    {
      caption => "Refresh",
      op => 'RefreshCurrentForegroundQuery',
      id => 'query_menu_RefreshCurrentForegroundQuery',
      #mode => 'SaveQuery',
      sync => 'Update();'
    },
    {
      caption => "Rerun",
      op => 'RerunCurrentForegroundQuery',
      id => 'query_menu_RerunCurrentForegroundQuery',
      #mode => 'SaveQuery',
      sync => 'Update();'
    },
    {
      type => "download",
      caption => "Download",
      op => 'DownloadCurrentForegroundQuery',
      id => 'query_menu_DownloadCurrentForegroundQuery',
      #mode => 'SaveQuery',
      sync => 'Update();'
    },
    {
      caption => "Chain",
      op => 'ChainQueryToSpreadsheet',
      id => 'query_menu_ChainToSpreadsheet',
      #mode => 'SaveQuery',
      sync => 'Update();'
    },
  ];
  return $ret;
}
sub MenuResponse {
  my($self, $http, $dyn) = @_;
  my $menu = $self->MakeMenuByMode($self->{Mode});
  $dyn->{id} = "div-main-menu";
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

  if ($self->can($self->{Mode})) {
    my $meth = $self->{Mode};
    $self->$meth($http, $dyn);
  } else {
    $http->queue("Unknown mode: $self->{Mode}");
  }
}
##############################################################f
##  Query Engine Stuff (beginning);
my $QueryEnginesSync = "UpdateDivs(" .
      "[['engine_selection_div', 'QE_esd_content']," .
      " ['available_cols_div', 'QE_acd_content'], " .
      " ['selected_cols_div', 'QE_scd_content'], " .
      " ['available_aggregates_div', 'QE_aad_content'], " .
      " ['selected_aggregates_div', 'QE_sad_content'], " .
      " ['available_where_div', 'QE_awd_content'], " .
      " ['selected_where_div', 'QE_swd_content'], " .
      " ['query_params_div', 'QE_qpd_content'], " .
      " ['query_and_results_div', 'QE_qrd_content'], " .
      "]);";
my $query_engine_content = "<div id=\"engine_selection_div\">" .
  "</div><div id=\"available_cols_div\">" .
  "</div><div id=\"selected_cols_div\">" .
  "</div><div id=\"available_aggregates_div\">" .
  "</div><div id=\"selected_aggregates_div\">" .
  "</div><div id=\"available_where_div\">" .
  "</div><div id=\"selected_where_div\">" .
  "</div><div id=\"query_params_div\">" .
  "</div><div id=\"query_and_results_div\">" .
  "</div>";
sub QueryEngines {
  my($self, $http, $dyn) = @_;
  unless(exists $self->{QueryEnginesData}){
    $self->{QueryEnginesData} = {
      Config => $main::HTTP_APP_CONFIG->{config}->{QueryEngines},
      SelectedEngine => "none",
     EngineStates => {
      },
    };
  }
  $http->queue("$query_engine_content");
  $self->QueueJsCmd($QueryEnginesSync);
}
sub QE_esd_content{
  my($self, $http, $dyn) = @_;
  $http->queue("Select query engine:&nbsp;&nbsp;&nbsp;");
  $self->SelectDelegateByValue($http, {
    op => 'SetQueryEngine',
    id => "QueryEngineSelector",
    sync => $QueryEnginesSync,
  });
  my @qe;
  push @qe, "none";
  for my $k (keys %{$self->{QueryEnginesData}->{Config}}){
    push @qe, $k;
  }
  for my $k (@qe){
    $http->queue("<option value=\"$k\"");
    if($k eq $self->{QueryEnginesData}->{SelectedEngine}){
      $http->queue(" selected")
    }
    $http->queue(">$k</option>");
  }
  $http->queue(qq{
    </select>
  });
}
sub SetQueryEngine{
  my($self, $http, $dyn) = @_;
  $self->{QueryEnginesData}->{SelectedEngine} = $dyn->{value};
  if($dyn->{value} eq "none"){return}
  unless(exists $self->{QueryEnginesData}->{EngineStates}->{$dyn->{value}}){
    $self->InitializeQueryEngineState($dyn->{value});
  }
}
sub InitializeQueryEngineState{
  my($self, $qe) = @_;
  my $qe_spec = $self->{QueryEnginesData}->{Config}->{$qe};
  my %qe_state;
  for my $k(keys %{$qe_spec->{selectable_columns}}){
    $qe_state{selectable_columns}->{$k} = 1;
  }
  for my $k(keys %{$qe_spec->{aggregates}}){
    $qe_state{aggregates}->{$k} = 1;
  }
  $qe_state{query_state} = "building";
  $self->{QueryEnginesData}->{EngineStates}->{$qe} = \%qe_state;
}
#<input type="button" id="<gen>" class="btn btn-default"
# onclick="javascript:PosdaGetRemoteMethod('QE_select_acd',
# '<var>=<value>', $QueryEnginesSync" value="<caption>">
sub QE_acd_content{
  my($self, $http, $dyn) = @_;
  my $qed = $self->{QueryEnginesData};
  if($qed->{SelectedEngine} eq "none"){ return }
  my $qes = $qed->{EngineStates}->{$qed->{SelectedEngine}};
  if($qes->{query_state} eq "running"){
    return;
  }
  my $conf = $qed->{Config}->{$qed->{SelectedEngine}};
  $http->queue("Available columns: &nbsp;");
  select_c:
  for my $acd (keys %{$qes->{selectable_columns}}){
    if(exists $qes->{selected_columns}->{index}->{$acd}){ next select_c }
    my $sc_desc = $conf->{selectable_columns}->{$acd};
    my $tag = $sc_desc->{tag};
    $self->{Sequence} += 1;
    my $button = "<input type=\"button\" id=\"QE_sc_$self->{Sequence}\" ";
    $button .= "class=\"btn btn-default\" ";
    $button .= "onclick=\"javascript:PosdaGetRemoteMethod('QE_select_acd',";
    $button .= "'acd_name=$acd',";
    $button .= "function() { $QueryEnginesSync })\" value=\"$tag\">";
    $http->queue("$button&nbsp;");
  }
  #$http->queue("available_cols_div");
}
sub QE_select_acd{
  my($self, $http, $dyn) = @_;
  my $qed = $self->{QueryEnginesData};
  my $qe_name = $qed->{SelectedEngine};
  my $qe_state = $qed->{EngineStates}->{$qe_name};
  my $acd_name = $dyn->{acd_name};
  unless(exists $qe_state->{selected_columns}->{list}){
    $qe_state->{selected_columns}->{list} = [];
  }
  push @{$qe_state->{selected_columns}->{list}}, $acd_name;
  $qe_state->{selected_columns}->{index} = {};
  for my $i (0 .. $#{$qe_state->{selected_columns}->{list}}){
    my $an = $qe_state->{selected_columns}->{list}->[$i];
    $qe_state->{selected_columns}->{index}->{$an} = $i;
  }
}
sub QE_scd_content{
  my($self, $http, $dyn) = @_;
  my $qed = $self->{QueryEnginesData};
  if($qed->{SelectedEngine} eq "none"){ return }
  my $qes = $qed->{EngineStates}->{$qed->{SelectedEngine}};
  if($qes->{query_state} eq "running"){
    return;
  }
  my $conf = $qed->{Config}->{$qed->{SelectedEngine}};
  $http->queue("Selected columns: &nbsp;");
  for my $scd (@{$qes->{selected_columns}->{list}}){
    my $sc_desc = $conf->{selectable_columns}->{$scd};
    my $tag = $sc_desc->{tag};
    $self->{Sequence} += 1;
    my $button = "<input type=\"button\" id=\"QE_sc_$self->{Sequence}\" ";
    $button .= "class=\"btn btn-default\" ";
    $button .= "onclick=\"javascript:PosdaGetRemoteMethod('QE_unselect_scd',";
    $button .= "'scd_name=$scd',";
    $button .= "function() { $QueryEnginesSync })\" value=\"$tag\">";
    $http->queue("$button&nbsp;");
  }
}
sub QE_unselect_scd{
  my($self, $http, $dyn) = @_;
  my $scd_name = $dyn->{scd_name};
  my $qed = $self->{QueryEnginesData};
  my $qe_name = $qed->{SelectedEngine};
  my $qe_state = $qed->{EngineStates}->{$qe_name};
  my $list = $qe_state->{selected_columns}->{list};
  my @new_list;
  for my $scd (@$list){
    unless($scd eq $scd_name) { push @new_list, $scd };
  }
  $qe_state->{selected_columns}->{list} = \@new_list;
  $qe_state->{selected_columns}->{index} = {};
  for my $i (0 .. $#{$qe_state->{selected_columns}->{list}}){
    my $an = $qe_state->{selected_columns}->{list}->[$i];
    $qe_state->{selected_columns}->{index}->{$an} = $i;
  }
}
sub QE_aad_content{
  my($self, $http, $dyn) = @_;
  my $qed = $self->{QueryEnginesData};
  if($qed->{SelectedEngine} eq "none"){ return }
  my $qes = $qed->{EngineStates}->{$qed->{SelectedEngine}};
  if($qes->{query_state} eq "running"){
    return;
  }
  my $conf = $qed->{Config}->{$qed->{SelectedEngine}};
  $http->queue("Available aggregates: &nbsp;");
  select_c:
  for my $acd (keys %{$qes->{aggregates}}){
    if(exists $qes->{selected_aggregates}->{index}->{$acd}){ next select_c }
    my $sc_desc = $conf->{aggregates}->{$acd};
#    my $tag = $sc_desc->{tag};
    $self->{Sequence} += 1;
    my $button = "<input type=\"button\" id=\"QE_sc_$self->{Sequence}\" ";
    $button .= "class=\"btn btn-default\" ";
    $button .= "onclick=\"javascript:PosdaGetRemoteMethod('QE_select_agg',";
    $button .= "'agg_name=$acd',";
    $button .= "function() { $QueryEnginesSync })\" value=\"$acd\">";
    $http->queue("$button&nbsp;");
  }
}
sub QE_select_agg{
  my($self, $http, $dyn) = @_;
  my $agg = $dyn->{agg_name};
  my $qed = $self->{QueryEnginesData};
  my $qe_name = $qed->{SelectedEngine};
  my $qe_state = $qed->{EngineStates}->{$qe_name};
  unless(exists $qe_state->{selected_aggregates}->{list}){
    $qe_state->{selected_aggregates}->{list} = [];
  }
  push @{$qe_state->{selected_aggregates}->{list}}, $agg;
  $qe_state->{selected_aggregates}->{index} = {};
  for my $i (0 .. $#{$qe_state->{selected_aggregates}->{list}}){
    my $an = $qe_state->{selected_aggregates}->{list}->[$i];
    $qe_state->{selected_aggregates}->{index}->{$an} = $i;
  }
 
}
sub QE_sad_content{
  my($self, $http, $dyn) = @_;
  my $qed = $self->{QueryEnginesData};
  if($qed->{SelectedEngine} eq "none"){ return }
  my $qes = $qed->{EngineStates}->{$qed->{SelectedEngine}};
  if($qes->{query_state} eq "running"){
    return;
  }
  my $conf = $qed->{Config}->{$qed->{SelectedEngine}};
  $http->queue("Selected aggregates: &nbsp;");
  for my $sag (@{$qes->{selected_aggregates}->{list}}){
#    my $sc_desc = $conf->{selectable_aggregates}->{$sag};
#    my $tag = $sc_desc->{tag};
    $self->{Sequence} += 1;
    my $button = "<input type=\"button\" id=\"QE_sag_$self->{Sequence}\" ";
    $button .= "class=\"btn btn-default\" ";
    $button .= "onclick=\"javascript:PosdaGetRemoteMethod('QE_unselect_sag',";
    $button .= "'sag_name=$sag',";
    $button .= "function() { $QueryEnginesSync })\" value=\"$sag\">";
    $http->queue("$button&nbsp;");
  }
}
sub QE_unselect_sag{
  my($self, $http, $dyn) = @_;
  my $sag_name = $dyn->{sag_name};
  my $qed = $self->{QueryEnginesData};
  my $qe_name = $qed->{SelectedEngine};
  my $qe_state = $qed->{EngineStates}->{$qe_name};
  my $list = $qe_state->{selected_aggregates}->{list};
  my @new_list;
  for my $scd (@$list){
    unless($scd eq $sag_name) { push @new_list, $scd };
  }
  $qe_state->{selected_aggregates}->{list} = \@new_list;
  $qe_state->{selected_aggregates}->{index} = {};
  for my $i (0 .. $#{$qe_state->{selected_aggregates}->{list}}){
    my $an = $qe_state->{selected_aggregates}->{list}->[$i];
    $qe_state->{selected_aggregates}->{index}->{$an} = $i;
  }
}
sub QE_awd_content{
  my($self, $http, $dyn) = @_;
  my $qed = $self->{QueryEnginesData};
  my $qe_name = $qed->{SelectedEngine};
  my $qe_state = $qed->{EngineStates}->{$qe_name};
  if($qe_state->{query_state} eq "running"){
    return;
  }
  my $qe_conf = $qed->{Config}->{$qe_name};
  unless(exists $qe_state->{WhereConfig}->{state}){
    $qe_state->{WhereConfig}->{state} = "idle";
  }
  if($qe_state->{WhereConfig}->{state} eq "idle"){
    $self->{Sequence} += 1;
    my $button = "<input type=\"button\" id=\"QE_wb_$self->{Sequence}\" ";
    $button .= "class=\"btn btn-default\" ";
    $button .= "onclick=\"javascript:PosdaGetRemoteMethod" .
      "('QE_StartAddingWhere',";
    $button .= "'function=QE_StartAddingWhere',";
    $button .= "function() { $QueryEnginesSync })\" value=\"Add Where\">";
    $http->queue("$button&nbsp;");
    $qe_state->{WhereConfig}->{SelectedOperation} = "none";
  } elsif ($qe_state->{WhereConfig}->{state} eq "first select"){
    $http->queue("Select operation:&nbsp;&nbsp;&nbsp;");
    $self->SelectDelegateByValue($http, {
      op => 'QE_set_where_op',
      id => "QE_set_where_op",
      sync => $QueryEnginesSync,
      width => 50,
    });
    my @ops;
    push @ops, "none";
    for my $k (keys %{$qe_conf->{wheres}}){
      push @ops, $k;
    }
    unless(exists $qe_state->{WhereConfig}->{SelectedOperation}){
      $qe_state->{WhereConfig}->{SelectedOperation} = "none";
    }
    for my $k (@ops){
      $http->queue("<option value=\"$k\"");
      if($k eq $qe_state->{WhereConfig}->{SelectedOperation}){
        $http->queue(" selected")
      }
      $http->queue(">$k</option>");
    }
    $http->queue(qq{
      </select>
    });
  } elsif ($qe_state->{WhereConfig}->{state} eq "second select"){
    my $sel_op = $qe_state->{WhereConfig}->{SelectedOperation};
    $http->queue("Selected operation: " .
      "$sel_op&nbsp;&nbsp;");
    $http->queue("Select column:&nbsp;&nbsp;");
    $self->SelectDelegateByValue($http, {
      op => 'QE_set_where_col',
      id => "QE_set_where_col",
      sync => $QueryEnginesSync,
      width => 50,
    });
    my @cols;
    push @cols, "none";
    unless(exists $qe_state->{WhereConfig}->{SelectedColumn}){
      $qe_state->{WhereConfig}->{SelectedColumn} = "none";
    }
    my $col_sel = $qe_state->{WhereConfig}->{SelectedColumn};
    for my $k (keys %{$qe_conf->{wheres}->{$sel_op}->{columns}}){
      push @cols, $k;
    }
    for my $k (@cols){
      $http->queue("<option value=\"$k\"");
      if($k eq $col_sel){
        $http->queue(" selected")
      }
      $http->queue(">$k</option>");
    }
    $http->queue(qq{
      </select>
    });
    #$http->queue("available_where_div_second_select");
  } else {
    die "unknown WhereConfig state";
  }
#  $http->queue("available_where_div");
}
sub QE_set_where_col{
  my($self, $http, $dyn) = @_;
  my $qed = $self->{QueryEnginesData};
  my $qe_name = $qed->{SelectedEngine};
  my $qe_state = $qed->{EngineStates}->{$qe_name};
  my $qew_state = $qe_state->{WhereConfig};
  my $qe_conf = $qed->{Config}->{$qe_name};
  my $sel_col = $dyn->{value};
  my $where_name = $sel_col . " $qew_state->{SelectedOperation}";
  unless(exists $qew_state->{selected_wheres}){
    $qew_state->{selected_wheres} = {
      index => {},
      list => [],
    };
  }
  if(exists $qew_state->{selected_wheres}->{index}->{$sel_col}){
    return;
  }
  push @{$qew_state->{selected_wheres}->{list}}, $where_name;
  for my $i (0 .. $#{$qew_state->{selected_wheres}->{list}}){
    my $v = $qew_state->{selected_wheres}->{list}->[$i];
    $qew_state->{selected_wheres}->{index}->{$v} = $i;
  }
  $qew_state->{state} = "idle";
}
sub QE_set_where_op{
  my($self, $http, $dyn) = @_;
  my $qed = $self->{QueryEnginesData};
  my $qe_name = $qed->{SelectedEngine};
  my $qe_state = $qed->{EngineStates}->{$qe_name};
  my $sel_op = $dyn->{value};
  $qe_state->{WhereConfig}->{SelectedOperation} = $sel_op;
  $qe_state->{WhereConfig}->{state} = "second select";
}
sub QE_StartAddingWhere{
  my($self, $http, $dyn) = @_;
  my $qed = $self->{QueryEnginesData};
  my $qe_name = $qed->{SelectedEngine};
  my $qe_state = $qed->{EngineStates}->{$qe_name};
  $qe_state->{WhereConfig}->{state} = "first select";
}
sub QE_swd_content{
  my($self, $http, $dyn) = @_;
  my $qed = $self->{QueryEnginesData};
  if($qed->{SelectedEngine} eq "none"){ return }
  my $qes = $qed->{EngineStates}->{$qed->{SelectedEngine}};
  if($qes->{query_state} eq "running"){
    return;
  }
  my $qews = $qed->{EngineStates}->{$qed->{SelectedEngine}}->{WhereConfig};
  my $conf = $qed->{Config}->{$qed->{SelectedEngine}};
  $http->queue("Selected where clauses: &nbsp;");
  for my $where (@{$qews->{selected_wheres}->{list}}){
    $self->{Sequence} += 1;
    my $button = "<input type=\"button\" id=\"QE_sc_$self->{Sequence}\" ";
    $button .= "class=\"btn btn-default\" ";
    $button .= "onclick=\"javascript:PosdaGetRemoteMethod('QE_unselect_where',";
    $button .= "'where_name=$where',";
    $button .= "function() { $QueryEnginesSync })\" value=\"$where\">";
    $http->queue("$button&nbsp;");
  }
}
sub QE_unselect_where{
  my($self, $http, $dyn) = @_;
  my $qed = $self->{QueryEnginesData};
  my $qe_name = $qed->{SelectedEngine};
  my $qe_state = $qed->{EngineStates}->{$qe_name};
  my $qew_state = $qed->{EngineStates}->{$qed->{SelectedEngine}}->{WhereConfig};
  my $where = $dyn->{where_name};
print STDERR "########################\n";
print STDERR "Deleting where $where\n";
  my @new_wheres;
  where:
  for my $w (@{$qew_state->{selected_wheres}->{list}}){
    if($w eq $where) { next where }
    push @new_wheres, $w;
  }
  $qew_state->{selected_wheres}->{index} = {};
my $num_new = @new_wheres;
my $num_old = @{$qew_state->{selected_wheres}->{list}};
print STDERR "Num old: $num_old\nNum new: $num_new\n";
  $qew_state->{selected_wheres}->{list} = \@new_wheres;
  for my $i (0 .. $#{$qew_state->{selected_wheres}->{list}}){
    my $v = $qew_state->{selected_wheres}->{list}->[$i];
    $qew_state->{selected_wheres}->{index}->{$v} = $i;
  }
  for my $i (keys %{$qew_state->{where_selector_values}}){
    unless(exists $qew_state->{selected_wheres}->{index}->{$i}){
print STDERR "Deleted $i from where_selector_values\n";
      delete $qew_state->{where_selector_values}->{$i};
    }
  }
print STDERR "########################\n";
}

sub QE_qpd_content{
  my($self, $http, $dyn) = @_;
  my $qed = $self->{QueryEnginesData};
  my $qe_name = $qed->{SelectedEngine};
  if($qe_name eq "none") {
    $http->queue("no query engine selected");
    return;
  }
  my $qe_state = $qed->{EngineStates}->{$qe_name};
  if($qe_state->{query_state} eq "running"){
    return;
  }
  my $qe_conf = $qed->{Config}->{$qe_name};
  my $dr_conf = $qe_conf->{date_range_entry_boxes};
  for my $eb (@{$dr_conf->{list}}){
    my $fr_v = $self->QE_GetFromDateRange($qe_state);
    my $dyn = {
      name => $eb->{dyn}->{name},
      size => $eb->{dyn}->{size},
      length => $eb->{dyn}->{length},
      op => $eb->{dyn}->{op},
    };
    my $gm = $eb->{dyn}->{value_fetch};
    my $value = $self->$gm($qe_state);
    $dyn->{init_value} = $value;
    $http->queue("$eb->{name}:&nbsp;&nbsp;");
    $self->LinkedDelegateEntryBox($http, $dyn,
    "function() { $QueryEnginesSync }");
    $http->queue("<br>");
  }
  my $qew_state = $qe_state->{WhereConfig};
  if(
    exists($qew_state->{selected_wheres}->{list}) &&
    ref($qew_state->{selected_wheres}->{list}) eq "ARRAY" &&
    $#{$qew_state->{selected_wheres}->{list}} >= 0
  ){
    print STDERR "Building selection boxes\n";
    for my $wh (@{$qew_state->{selected_wheres}->{list}}){
      my $init_value;
      if(exists $qew_state->{where_selector_values}->{$wh}){
        $init_value = $qew_state->{where_selector_values}->{$wh};
      }
      unless(defined $init_value) { $init_value = "none" }
      $http->queue("$wh:&nbsp;&nbsp;");
      my $dyn = {
        name => $wh,
        size => 64,
        length => 64,
        op => "QE_set_where_value",
        init_value => $init_value,
        index => $wh,
      };
      $self->LinkedDelegateEntryBox($http, $dyn,
        "function() { $QueryEnginesSync }");
      $http->queue("<br>");
    }
  } else {
  }
}
sub QE_set_where_value{
  my($self, $http, $dyn) = @_;
  my $qed = $self->{QueryEnginesData};
  my $qe_name = $qed->{SelectedEngine};
  my $qe_state = $qed->{EngineStates}->{$qe_name};
  my $qe_conf = $qed->{Config}->{$qe_name};
  my $qew_state = $qe_state->{WhereConfig};
  my $index = $dyn->{index};
  my $value = $dyn->{value};
  if($index =~ /like$/){
    $qew_state->{where_selector_values}->{$index} = "$value";
  } else {
    $qew_state->{where_selector_values}->{$index} = $value;
  }
}
sub QE_SetDateRangeFrom{
  my($self, $http, $dyn) = @_;
  my $qed = $self->{QueryEnginesData};
  my $qe_name = $qed->{SelectedEngine};
  if($qe_name eq "none") {
    return;
  }
  my $qe_state = $qed->{EngineStates}->{$qe_name};
  my $value = $dyn->{value};
  $qe_state->{DateRangeSelections}->{from} = $value;
}
sub QE_SetDateRangeTo{
  my($self, $http, $dyn) = @_;
  my $qed = $self->{QueryEnginesData};
  my $qe_name = $qed->{SelectedEngine};
  if($qe_name eq "none") {
    return;
  }
  my $qe_state = $qed->{EngineStates}->{$qe_name};
  my $value = $dyn->{value};
  $qe_state->{DateRangeSelections}->{to} = $value;
}
sub QE_GetFromDateRange{
  my($self, $qe_state) = @_;
  unless(exists ($qe_state->{DateRangeSelections})){
    $qe_state->{DateRangeSelections} = {
       from => "none",
       to => "none",
    };
  }
  return $qe_state->{DateRangeSelections}->{from};
}
sub QE_GetToDateRange{
  my($self, $qe_state) = @_;
  unless(exists ($qe_state->{DateRangeSelections})){
    $qe_state->{DateRangeSelections} = {
       from => "none",
       to => "none",
    };
  }
  return $qe_state->{DateRangeSelections}->{to};
}
sub QE_qrd_content{
  my($self, $http, $dyn) = @_;
  my $qed = $self->{QueryEnginesData};
  my $qe_name = $qed->{SelectedEngine};
  if($qe_name eq "none") {
    $http->queue("no query engine selected");
    return;
  }
  my $qe_state = $qed->{EngineStates}->{$qe_name};
  my $qe_conf = $qed->{Config}->{$qe_name};
  my $qew_state = $qe_state->{WhereConfig};
  unless(exists $qe_state->{query_state}){
   $qe_state->{query_state} = "building";
  }
  if($qe_state->{query_state} eq "building"){
    return $self->QE_qrd_content_building($http, $dyn);
  } elsif ($qe_state->{query_state} eq "running"){
    return $self->QE_qrd_content_running($http, $dyn);
  } else {
    die "Bad query_state";
  }
}
sub QE_qrd_content_building{
  my($self, $http, $dyn) = @_;
  #$http->queue("query_and_results_div");
  my $button = "<input type=\"button\" id=\"QE_sc_$self->{Sequence}\" ";
  $button .= "class=\"btn btn-default\" ";
  $button .= "onclick=\"javascript:PosdaGetRemoteMethod('QE_run_query',";
  $button .= "'where_name=QE_run_query',";
  $button .= "function() { $QueryEnginesSync })\" value=\"QE_run_query\">";
  $http->queue("$button<br>");
  my $qed = $self->{QueryEnginesData};
  my $qe_name = $qed->{SelectedEngine};
  if($qe_name eq "none") {
    $http->queue("no query engine selected");
    return;
  }
  my $qe_state = $qed->{EngineStates}->{$qe_name};
  my $qe_conf = $qed->{Config}->{$qe_name};
  my $qew_state = $qe_state->{WhereConfig};
  unless(exists $qe_state->{query_state}){
   $qe_state->{query_state} = "building";
  }
  if($qe_state->{query_state} eq "building"){
    unless(exists($qe_state->{selected_columns}->{list})) {
      $http->queue("no selected columns");
      return;
    }
    my @selected_cols = @{$qe_state->{selected_columns}->{list}};
    unless(exists $qe_state->{selected_aggregates}){
      $qe_state->{selected_aggregates} = {
         index => {},
         list => [],
      };
    }
    my @selected_aggregates = @{$qe_state->{selected_aggregates}->{list}};
    my $select_clause = "";
    my $group_by = "";
    selected_col:
    for my $i (0 .. $#selected_cols){
      my $name = $selected_cols[$i];
      my $cnf = $qe_conf->{selectable_columns}->{$name};
      $select_clause .= "  $cnf->{code}";
      if($#selected_aggregates >= 0){
	$group_by .= "  $cnf->{group}";
      }
      if($i < $#selected_cols){
	$select_clause .= ",\n";
	unless($group_by eq ""){
	  $group_by .= ",\n";
	}
	next selected_col;
      }
    }
    my $agg_sel = "";
    if($#selected_aggregates >= 0){
      if($select_clause ne ""){
        $select_clause .= ",\n";
      }
      for my $i (0 .. $#selected_aggregates){
        my $name = $selected_aggregates[$i];
        my $cnf = $qe_conf->{aggregates}->{$name};
        my $code = $cnf->{code};
        $agg_sel .= "  $code";
        unless($i == $#selected_aggregates){
          $agg_sel .= ",\n";
        }
      }
    }
    my $where_clauses = "";
    if($#{$qew_state->{selected_wheres}->{list}} >= 0){
      for my $i (0 .. $#{$qew_state->{selected_wheres}->{list}}){
        my $where = $qew_state->{selected_wheres}->{list}->[$i];
        my($col, $op) = split(" ", $where);
        if($op eq "equals"){
          $where_clauses .= "    $col = ?"
        } elsif ($op eq "like"){
          $where_clauses .= "    $col ilike ?"
        } else {
          print STDERR "Only handling equals and like right now";
        }
        unless($i == $#{$qew_state->{selected_wheres}->{list}}){
          $where_clauses .= " and\n";
        }
      }
    }
    $qe_state->{building_query} = {
      selected_cols => \@selected_cols,
      selected_aggregates => \@selected_aggregates,
      select_clause => $select_clause,
      group_by => $group_by,
      agg_selection => $agg_sel,
      where_clauses => $where_clauses
    };
    if(defined $agg_sel){
      $select_clause = $select_clause . $agg_sel;
    }
    $qe_state->{building_query}->{from} = $qe_conf->{from_clause};
    my $query = "select\n" . "$select_clause\n" . 
      "from\n" . "$qe_conf->{from_clause}\n" .
      "where\n $qe_conf->{date_range_where}\n";
    if($where_clauses ne ""){
      $query .= "  and (\n$where_clauses\n  )\n";
    }
    if($group_by ne ""){
      $query .=  "group by\n$group_by\n";
    }
    $http->queue("<pre>$query</pre>");
    $qe_state->{full_query} = $query;
  } else {
    die "Query State changed";
  }
}
sub QE_qrd_content_running{
  my($self, $http, $dyn) = @_;
  my $button = "<input type=\"button\" id=\"QE_sc_$self->{Sequence}\" ";
  $button .= "class=\"btn btn-default\" ";
  $button .= "onclick=\"javascript:PosdaGetRemoteMethod('QE_clear_query',";
  $button .= "'where_name=QE_run_query',";
  $button .= "function() { $QueryEnginesSync })\" value=\"QE_clear_query\">";
  $http->queue("$button<br>");
  my $qed = $self->{QueryEnginesData};
  my $qe_name = $qed->{SelectedEngine};
  my $qe_state = $qed->{EngineStates}->{$qe_name};
  my $qe_conf = $qed->{Config}->{$qe_name};
  my $qew_state = $qe_state->{WhereConfig};
  my $qr = $qe_state->{running_query};
  $http->queue("<table class=\"table table-striped table-condensed\"><tr>");
  for my $i (@{$qr->{col_headers}}){
    $http->queue("<th>$i</th>");
  }
  $http->queue("</tr>");
  for my $row (@{$qr->{results}}){
    $http->queue("<tr>");
    for my $h (@{$qr->{col_headers}}){
      $http->queue("<td>$row->{$h}</td>");
    }
    $http->queue("</tr>");
  }
  $http->queue("</table>");
}
sub QE_clear_query{
  my($self, $http, $dyn) = @_;
  my $qed = $self->{QueryEnginesData};
  my $qe_name = $qed->{SelectedEngine};
  my $qe_state = $qed->{EngineStates}->{$qe_name};
  delete $qe_state->{running_query};
  $qe_state->{query_state} = 'building';
}
sub QE_run_query{
  my($self, $http, $dyn) = @_;
open FOO, "psql -l|";
#my @psqldashl;
#while(my $line = <FOO>){
##  push @psqldashl, $line;
#}
  my $qed = $self->{QueryEnginesData};
  my $qe_name = $qed->{SelectedEngine};
  my $qe_state = $qed->{EngineStates}->{$qe_name};
#$qe_state->{psqldashl} = \@psqldashl;
  my $qe_conf = $qed->{Config}->{$qe_name};
  my $qew_state = $qe_state->{WhereConfig};
  my %RunningQuery;
  my @col_headers;
  for my $c (@{$qe_state->{selected_columns}->{list}}){
    push @col_headers, $qe_conf->{selectable_columns}->{$c}->{col_head};
  }
  for my $a (@{$qe_state->{selected_aggregates}->{list}}){
    push @col_headers, $qe_conf->{aggregates}->{$a}->{col_head};
  }
  my @bind_values;
  push @bind_values, $qe_state->{DateRangeSelections}->{from};
  push @bind_values, $qe_state->{DateRangeSelections}->{to};
  for my $bc (@{$qew_state->{selected_wheres}->{list}}){
    my $sel_value;
    if($bc =~ /like$/){
      push(@bind_values, "%$qew_state->{where_selector_values}->{$bc}%");
    } else {
      push(@bind_values, $qew_state->{where_selector_values}->{$bc});
    }
  }
  $qe_state->{running_query} = {
    col_headers => \@col_headers,
    bind_values => \@bind_values,
  };
  my $db_handle = DBI->connect(Database('posda_files'));

  my $q = $db_handle->prepare($qe_state->{full_query});
  print STDERR "prepare returned: $q\n";
  my $n = $q->execute(@{$qe_state->{running_query}->{bind_values}});
  print STDERR "execute returned $n\n";
  my @results;
  while(my $hash = $q->fetchrow_hashref()){
    push @results, $hash;
  }
  $qe_state->{running_query}->{results} = \@results;
  $qe_state->{query_state} = "running";
}
##  Query Engine Stuff (end)
##############################################################f

my $table_free_seq = 0;
sub OpenTableFreePopup{
  my($self, $http, $dyn) = @_;
  $dyn->{operation} = $dyn->{cap_};
  $self->{debug_dyn} = $dyn;
  if($dyn->{"class_"} eq "Posda::NewerProcessPopup"){
    return $self->InvokeNewOperation($http, $dyn);
  }
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

sub OpenPopup {
  my($self, $class, $name, $params) = @_;
  # say STDERR "OpenDynamicPopup, executing $class using params:";
  # print STDERR Dumper($params);
  # print STDERR "################\nOpenPopup\nclass: $class\n";
  # print STDERR "name: $name\n################\n";


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

sub OpenNewTableLevelPopup{
  my($self, $http, $dyn) = @_;
  my $params;
  my $tb_id = $self->{NewQueryToDisplay};
  my $query = $self->{ForegroundQueries}->{$tb_id};
  $params = {
     bindings => $self->{BindingCache},
  };
  my $invocation = {
    type => "QueryMenuTableBasedButton",
    button_id => $dyn->{_btn_id},
    Operation => $dyn->{cap_},,
    query_caption => $query->{caption},
    when_query_invoked => $query->{when},
    who_invoked_query => $query->{who},
  };
  $params->{invocation} = $invocation;
  $params->{current_settings}->{notify} = $self->get_user;
  if(defined $self->{ActivitySelected}){
    $params->{current_settings}->{activity_id} = $self->{ActivitySelected};
    Query("LatestActivityTimepointForActivity")->RunQuery(sub{
      my($row) = @_;
      $params->{current_settings}->{activity_timepoint_id} = $row->[0];
    }, sub {}, $self->{ActivitySelected});
  }
  if($self->{FilterSelection}->{$tb_id} eq "filtered"){
    $invocation->{is_filtered} = 1;
    $invocation->{filter_caption} = $self->TextRenderQueryFilter($query->{filter});
    $invocation->{num_filtered_rows} = @{$query->{filtered_rows}};
  } else {
    $invocation->{rows} = @{$query->{rows}};
  }
  $params->{current_settings}->{notify} = $self->get_user;
  if(defined $self->{ActivitySelected}){
    $params->{current_settings}->{activity_id} = $self->{ActivitySelected};
    Query("LatestActivityTimepointForActivity")->RunQuery(sub{
      my($row) = @_;
      $params->{current_settings}->{activity_timepoint_id} = $row->[0];
    }, sub {}, $self->{ActivitySelected});
  }
  my $filter_sel = $self->{FilterSelection}->{$tb_id};
  my $rows_array;
  if($filter_sel eq "filtered"){
    $rows_array = $self->{ForegroundQueries}->{$tb_id}->{filtered_rows};
  } else {
    $rows_array = $self->{ForegroundQueries}->{$tb_id}->{rows};
  }
  $params->{cols} = $self->{ForegroundQueries}->{$tb_id}->{query}->{columns};
  my @rows;
  for my $r (@{$rows_array}){
    my $hash;
    for my $i (0 .. $#{$params->{cols}}){
      $hash->{$params->{cols}->[$i]} = $r->[$i];
    }
    push @rows, $hash;
  }
  $params->{rows}= \@rows;
  my $command =
    $self->GetOperationDescription($invocation->{Operation});
  if(defined $command){
    $params->{command} = $command;
  } else {
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

    my $child_path = $self->child_path($name);
    my $child_obj = $class->new($self->{session},
                              $child_path, $params);
    $self->StartJsChildWindow($child_obj);
    return;
  }

  my $class = "Posda::NewerProcessPopup";
  eval "require $class";
  if($@){
    print STDERR "Class Posda::NewerProcessPopup failed to compile\n\t$@\n";
    return;
  }
  unless(exists $self->{sequence_no}){$self->{sequence_no} = 0}
  my $name = "TableLevelPopup_$self->{sequence_no}";
  $self->{sequence_no} += 1;

  my $child_path = $self->child_path($name);
  my $child_obj = $class->new($self->{session},
                              $child_path, $params);
  $self->StartJsChildWindow($child_obj);
}

sub ChainQueryToSpreadsheet{
  my($self, $http, $dyn)  = @_;
  my $params;
  my $tb_id = $self->{NewQueryToDisplay};
  my $query = $self->{ForegroundQueries}->{$tb_id};
  $params = {
     bindings => $self->{BindingCache},
  };
  my $invocation = {
    type => "QueryMenuTableBasedButton",
    button_id => $dyn->{_btn_id},
    Operation => $dyn->{cap_},,
    query_caption => $query->{caption},
    when_query_invoked => $query->{when},
    who_invoked_query => $query->{who},
  };
  $params->{invocation} = $invocation;
  if($self->{FilterSelection}->{$tb_id} eq "filtered"){
    $invocation->{is_filtered} = 1;
    $invocation->{filter_caption} = $self->TextRenderQueryFilter($query->{filter});
    $invocation->{num_filtered_rows} = @{$query->{filtered_rows}};
  } else {
    $invocation->{rows} = @{$query->{rows}};
  }
  $params->{current_settings}->{notify} = $self->get_user;
  if(defined $self->{ActivitySelected}){
    $params->{current_settings}->{activity_id} = $self->{ActivitySelected};
    Query("LatestActivityTimepointForActivity")->RunQuery(sub{
      my($row) = @_;
      $params->{current_settings}->{activity_timepoint_id} = $row->[0];
    }, sub {}, $self->{ActivitySelected});
  }
  my $filter_sel = $self->{FilterSelection}->{$tb_id};
  my $rows_array;
  if($filter_sel eq "filtered"){
    $rows_array = $self->{ForegroundQueries}->{$tb_id}->{filtered_rows};
  } else {
    $rows_array = $self->{ForegroundQueries}->{$tb_id}->{rows};
  }
  $params->{cols} = $self->{ForegroundQueries}->{$tb_id}->{query}->{columns};
  my @rows;
  for my $r (@{$rows_array}){
    my $hash;
    for my $i (0 .. $#{$params->{cols}}){
      $hash->{$params->{cols}->[$i]} = $r->[$i];
    }
    push @rows, $hash;
  }
  $params->{rows}= \@rows;
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

  my $child_path = $self->child_path($name);
  my $child_obj = $class->new($self->{session},
                            $child_path, $params);
  $self->StartJsChildWindow($child_obj);
}




sub OpHelp {
  my ($self, $http, $dyn) = @_;
  for my $i (keys %$dyn){
    print STDERR "dyn{$i} = $dyn->{$i}\n";
  }
  return;

  my $details = $self->{Commands}->{$dyn->{cmd}};


  my $child_path = $self->child_path("PopupHelp_$dyn->{cmd}");
  my $child_obj = ActivityBasedCuration::PopupHelp->new($self->{session},
                                              $child_path, $details);
  $self->StartJsChildWindow($child_obj);
}
sub OpenBackgroundQuery {
  my ($self, $http, $dyn) = @_;

  my $details = {
    query_name => $dyn->{query_name},
    user => $self->get_user,
    #SavedQueriesDir => $self->{SavedQueriesDir},
    BindingCache => $self->{BindingCache},
  };
  $details->{current_settings} = { notify => $self->get_user };
  if(defined($self->{ActivitySelected}) && $self->{ActivitySelected}){
    $details->{current_settings}->{activity_id} = $self->{ActivitySelected};
    Query("LatestActivityTimepointForActivity")->RunQuery(sub{
      my($row) = @_;
      $details->{current_settings}->{activity_timepoint_id} = $row->[0];
    }, sub {}, $self->{ActivitySelected});
  }

  my $child_path = $self->child_path("BackgroundQuery_$dyn->{query_name}");
  my $child_obj = Posda::BackgroundQuery->new($self->{session},
                                              $child_path, $details);
  $self->StartJsChildWindow($child_obj);
}


###
# Delegated methods
###

sub DeleteHashKeyList {
  my ($self, $http, $dyn) = @_;
  my $type = $dyn->{type};
  my $index = $dyn->{index};

  splice @{$self->{query}->{$type}}, $index, 1;
}
sub AddToHashKeyList {
  my ($self, $http, $dyn) = @_;
  push @{$self->{query}->{tags}}, $dyn->{value};
}

sub AddToEditList {
  my ($self, $http, $dyn) = @_;
  my $source = $dyn->{extra};
  my $value = $dyn->{value};


  push @{$self->{query}->{$source}}, $value;
}


# do we really need to handle this with a post?
sub TextAreaChanged {
  my ($self, $http, $dyn) = @_;
  # Read the POST data (this method needs to be POSTed to!)
  my $buff;
  my $c = read $http->{socket}, $buff, $http->{header}->{content_length};

  $self->{query}->{$dyn->{id}} = $buff;
}


sub DrawWidgetFromTo {
  my ($self, $http, $dyn) = @_;
  $self->RefreshEngine($http, $dyn, qq{
    <tr>
      <th style="width:5%">quick options</th>
      <td>
        <?dyn="NotSoSimpleButton" op="SetWidgetFromTo" val="today" caption="Today" class="btn btn-warning" sync="Update();"?>
        <?dyn="NotSoSimpleButton" op="SetWidgetFromTo" val="yesterday" caption="Yesterday" class="btn btn-warning" sync="Update();"?>
        <?dyn="NotSoSimpleButton" op="SetWidgetFromTo" val="lastweek" caption="Last 7 Days" class="btn btn-warning" sync="Update();"?>
        <?dyn="NotSoSimpleButton" op="SetWidgetFromTo" val="lastmonth" caption="Last 30 Days" class="btn btn-warning" sync="Update();"?>
      </td>
    </tr>
  });
}
sub SetWidgetFromTo {
  my ($self, $http, $dyn) = @_;
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



sub GetBindings {
  my ($self) = @_;
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


sub UpdateInsertCompleted {
  my ($self, $query, $struct) = @_;
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

#sub CreateTableFromQuery {
#  my ($self, $query, $struct, $start_at) = @_;
#  # create LoadedTable array
#  unless(exists $self->{LoadedTables}) { $self->{LoadedTables} = [] }
#
#  # This code creates a copy of the query, but without
#  # the dbh (database handle). There was some problem with
#  # using storable's freeze if the handle existed. We don't
#  # just delete the handle, in case the query needs to be re-used later.
#  #
#  # I am not sure why we drop the columns and then recreate them?
#  my $new_q = {};
#  for my $i (keys %$query){
#    unless($i eq 'columns'
#        or $i eq 'dbh' # if the handle is included it will fail to Freeze
#    ){
#      $new_q->{$i} = $query->{$i};
#    }
#  }
#  my @cols = @{$query->{columns}};
#  $new_q->{columns} = \@cols;
#
#  my $new_table = DbIf::Table::from_query($new_q, $struct, $start_at);
#  push(@{$self->{LoadedTables}}, $new_table);
#}

sub SelectNewestTable {
  my ($self) = @_;
  my $index = $#{$self->{LoadedTables}};
  if($self->{Mode} eq "QueryWait"){
    $self->SelectTable({}, { index => $index });
  }
}

sub CreateAndSelectTableFromQuery {
  my ($self, $query, $struct, $start_at) = @_;
  $self->CreateTableFromQuery($query, $struct, $start_at);
  $self->SelectNewestTable();
}

sub DownloadPreparedReport {
  my ($self, $http, $dyn) = @_;
  my $filename = $dyn->{filename};
  my $shortname = $dyn->{shortname};


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

sub DownloadTableAsCsv {
  my ($self, $http, $dyn) = @_;
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
    sub {
  my ($frag) = @_;
      $http->queue("$frag");
    },
    sub {
      # do nothing, on purpose
    }
  );
}

sub StoreQuery {
  my ($self, $query, $filename) = @_;
  # my $new_q = {};
  # for my $i (keys %$query){
  #   unless($i eq 'columns'
  #       or $i eq 'dbh' # if the handle is included it will fail to Freeze
  #   ){
  #     $new_q->{$i} = $query->{$i};
  #   }
  # }
  delete $query->{dbh};
  store $query, $filename;
}
sub SaveTableAsReport {
  my ($self, $http, $dyn) = @_;
  my $table = $self->{LoadedTables}->[$self->{SelectedTable}];
  my $dir = $self->{PreparedReportsDir};
  my $public = $dyn->{public};
  if (defined $public) {
    $dir = $self->{PreparedReportsCommonDir};
  }
  my $filename = $dyn->{saveName};

  if($table->{type} eq "FromQuery"){
    $self->StoreQuery($table->{query},
     "$dir/$filename.query");
  }

  # TODO: need to find a valid non-conflicting filename here

  my $file = "$dir/$filename";

  open my $fh, ">$file" or die "Can't open $file for writing ($!)";
  my $cmd = "PerlStructToCsv.pl";
  Dispatch::BinFragReader->new_serialized_cmd(
    $cmd,
    $table,
    sub {
  my ($frag) = @_;
      print $fh $frag;
    },
    sub {
      close $fh;
      $self->QueueJsCmd("alert('Report saved!');");
    }
  );
}

sub SetUseAsArg {
  my ($self, $http, $dyn) = @_;
  $self->{Mode} = 'UseAsArg';
  $self->{UseAsArgOps} = $dyn;
}
sub UseAsArg {
  my ($self, $http, $dyn) = @_;
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

sub InsertSaveReportModal {
  my ($self, $http, $name, $table) = @_;
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

sub get_popup_hash_new{
  my($self, $query_name) = @_;
  my %popup_hash;
  my %grps;
  for my $k (keys %{$self->{QueryButtonsByQueryPatColumn}}){
    if(sql_match($k, $query_name)){
      for my $i (keys %{$self->{QueryButtonsByQueryPatColumn}->{$k}}){
        $grps{$i} = $self->{QueryButtonsByQueryPatColumn}->{$k}->{$i};
      }
    }
  }
  for my $i (keys %{$self->{QueryButtonsByQueryColumn}->{$query_name}}){
    $grps{$i} = $self->{QueryButtonsByQueryColumn}->{$query_name}->{$i};
  }
  for my $i (keys %grps){
    $popup_hash{$i} = $self->{QueryChainColumnButtons}->{$grps{$i}};
  }
  return \%popup_hash
}

sub sql_match{
  my($pat, $val) = @_;
  if($pat eq '%') { return 1 }
  die ("sql_match not fully implemented");
}

sub get_popup_hash{
    my($query_name) = @_;
#die "get_popup_hash is obsolete";
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

sub DrawFilterableFieldHeading {
  my ($self, $http, $column_name, $column_number) = @_;
  $http->queue(qq{<th>$column_name});
  $self->DebouncedEntryBox($http, {
      uniq_id => $column_name,
      op => 'Test1Change'
  });
  $http->queue(qq{</th>});

}

sub Test1Change {
  my ($self, $http, $dyn) = @_;
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

sub TableSelected {
  my ($self, $http, $dyn) = @_;
  my $table = $self->{LoadedTables}->[$self->{SelectedTable}];
  if($table->{type} eq "FromQuery"){
    my $query = $table->{query};
    my $rows = $table->{rows};
    my $num_rows = @$rows;
    my $at = $table->{at};

    my $popup_hash = get_popup_hash($query->{name});
#    my $chained_queries = PosdaDB::Queries->GetChainedQueries($query->{name});
#$self->{chained_queries} = $chained_queries;
    my @chained_queries;
    for my $i (keys %{$self->{QueryChaining}}){
      my $r = $self->{QueryChaining}->{$i};
      if($r->{from_query} eq $query->{name}){
        push @chained_queries, $r;
      }
    }

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
    if ($#chained_queries > -1) {
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
      if ($#chained_queries >= 0) {
        for my $q (@chained_queries) {
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

sub BuildDicomDefacedSeries{
  my($self, $http, $dyn) = @_;
  my $hash = $self->{NewQueryToDisplay};
  my $cur_query = $self->{ForegroundQueries}->{$hash};
  my $si_id = $cur_query->{args}->[0];
  my $rows = $cur_query->{filtered_rows};
  my $params = {
    activity_id => $self->{ActivitySelected},
    user => $self->get_user,
    tmp_dir => $self->{TempDir},
    rows => $rows
  };
  my $class = "Posda::BuildDicomDefaced";
  eval "require $class";
  if($@){
    print STDERR "Class failed to compile\n\t$@\n";
    return;
  }

  unless(exists $self->{sequence_no}){$self->{sequence_no} = 0}
  my $name = "buid_dicom_defaced$self->{sequence_no}";
  $self->{sequence_no} += 1;
  my $child_path = $self->child_path($name);
  my $child_obj = $class->new($self->{session},
                              $child_path, $params);
  $self->StartJsChildWindow($child_obj);
}

sub AnalyzeSeriesVisualizations{
  my($self, $http, $dyn) = @_;
  my $hash = $self->{NewQueryToDisplay};
  my $cur_query = $self->{ForegroundQueries}->{$hash};
  my $si_id = $cur_query->{args}->[0];
  my $rows = $cur_query->{filtered_rows};
  my $params = {
    activity_id => $self->{ActivitySelected},
    user => $self->get_user,
    tmp_dir => $self->{TempDir},
    rows => $rows
  };
  my $class = "Posda::AnalyzeSeriesVisualizations";
  eval "require $class";
  if($@){
    print STDERR "Class failed to compile\n\t$@\n";
    return;
  }

  unless(exists $self->{sequence_no}){$self->{sequence_no} = 0}
  my $name = "buid_dicom_defaced$self->{sequence_no}";
  $self->{sequence_no} += 1;
  my $child_path = $self->child_path($name);
  my $child_obj = $class->new($self->{session},
                              $child_path, $params);
  $self->StartJsChildWindow($child_obj);
}

sub LaunchNoFaceReport{
  my($self, $http, $dyn) = @_;
  my $hash = $self->{NewQueryToDisplay};
  my $cur_query = $self->{ForegroundQueries}->{$hash};
  my $si_id = $cur_query->{args}->[0];
  my $params = {
    activity_id => $self->{ActivitySelected},
    user => $self->get_user,
    tmp_dir => $self->{TempDir},
    subprocess_invocation_id => $si_id,
  };
  my $class = "Posda::NiftiNoFacesReport";
  eval "require $class";
  if($@){
    print STDERR "Class failed to compile\n\t$@\n";
    return;
  }

  unless(exists $self->{sequence_no}){$self->{sequence_no} = 0}
  my $name = "nifti_no_face_$self->{sequence_no}";
  $self->{sequence_no} += 1;
  my $child_path = $self->child_path($name);
  my $child_obj = $class->new($self->{session},
                              $child_path, $params);
  $self->StartJsChildWindow($child_obj);
}

sub LaunchNiftiProjectionViewer{
  my($self, $http, $dyn) = @_;
  my $hash = $self->{NewQueryToDisplay};
  my $cur_query = $self->{ForegroundQueries}->{$hash};
  my $scan_id = $cur_query->{args}->[0];
  my $params = {
    activity_id => $self->{ActivitySelected},
    user => $self->get_user,
    tmp_dir => $self->{TempDir},
  };
  my $class = "Posda::ImageDisplayer::NiftiProjections";
  eval "require $class";
  if($@){
    print STDERR "Class failed to compile\n\t$@\n";
    return;
  }

  unless(exists $self->{sequence_no}){$self->{sequence_no} = 0}
  my $name = "nifti_scope_$self->{sequence_no}";
  $self->{sequence_no} += 1;
  my $child_path = $self->child_path($name);
  my $child_obj = $class->new($self->{session},
                              $child_path, $params);
  $self->StartJsChildWindow($child_obj);
}

sub LaunchKaleidoscope{
  my($self, $http, $dyn) = @_;
  my $hash = $self->{NewQueryToDisplay};
  my $cur_query = $self->{ForegroundQueries}->{$hash};
  my $scan_id = $cur_query->{args}->[0];
print STDERR
"###########################\n".
"In Launch Kaleidoscope\n";
for my $i (keys %$dyn){
print STDERR "dyn{$i} = $dyn->{$i}\n";
}
print STDERR
"###########################\n";
  my $params = {
    vis_review_id => $scan_id,
    user => $self->get_user,
    tmp_dir => $self->{TempDir},
  };
  my $class = "Posda::ImageDisplayer::Kaleidoscope";
  eval "require $class";
  if($@){
    print STDERR "Class failed to compile\n\t$@\n";
    return;
  }

  unless(exists $self->{sequence_no}){$self->{sequence_no} = 0}
  my $name = "$self->{name}" . "_k_scope_$self->{sequence_no}";
  $self->{sequence_no} += 1;
  my $child_path = $self->child_path($name);
  my $child_obj = $class->new($self->{session},
                              $child_path, $params);
  $self->StartJsChildWindow($child_obj);
}


sub OpenChainedQuery {
  my ($self, $http, $dyn) = @_;
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


sub UpdateInsertStatus {
  my ($self, $http, $dyn) = @_;
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
sub UpdatesInserts {
  my ($self, $http, $dyn) = @_;
}
#############################
#Here Bill is putting in the "Activities" Page assortment
sub Activities {
  my ($self, $http, $dyn) = @_;
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
    id => "ActivityFilterEntryBox",
    value => "$self->{ActivityFilter}"
  }, "Update();");
  $http->queue(qq{</div><hr>});
  $self->RenderNewActivityForm($http, $dyn);
}
sub SetActivityFilter {
  my ($self, $http, $dyn) = @_;
  $self->{ActivityFilter} = $dyn->{value};
}

sub RenderNewActivityForm {
  my ($self, $http, $dyn) = @_;
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
      id => 'SaveNewActivity',
      #extra => $extra
  });

  $http->queue(qq{
    </div>
  });
}
sub RenderActivityDropDown {
  my ($self, $http, $dyn) = @_;
  unless(defined $self->{ActivitySelected}){
    $self->{ActivitySelected} = "<none>";
  }
  my @activity_list;
  push @activity_list, ["<none>", "----- No Activity Selected ----"];
#  my @sorted_ids = $self->SortedActivityIds($self->{Activities});
  my @sorted_ids = sort {$b <=> $a} keys %{$self->{Activities}};
  sorted_id:
  for my $i (@sorted_ids){
    if($self->{ActivityFilter}){
      $self->{ActDesc} = uc $self->{Activities}->{$i}->{desc};
      $self->{ActFilter} = uc $self->{ActivityFilter};
      unless($self->{ActDesc} =~ /$self->{ActFilter}/){ next sorted_id }
    }
    push @activity_list, [$i , "$i: $self->{Activities}->{$i}->{desc}" .
      " ($self->{Activities}->{$i}->{user})"];
  }
  $self->SelectDelegateByValue($http, {
    op => 'SetActivity',
    id => "SelectActivityDropDown",
    sync => "UpdateDivs([['header', 'BigTitle'],['content', 'ContentResponse']]);",
  });
  for my $i (@activity_list){
    $http->queue("<option value=\"$i->[0]\"");
    if($i->[0] eq $self->{ActivitySelected}){
      $http->queue(" selected")
    }
    $http->queue(">$i->[1]</option>");
  }
  $http->queue(qq{
    </select>
  });
}


sub BigTitle {
  my ($self, $http, $dyn) = @_;
  $http->queue("<center><H1>");
  $self->title($http, $dyn);;
  $http->queue("</H1></center>");
}

sub SetActivity {
  my ($self, $http, $dyn) = @_;
  $self->{ActivitySelected} = $dyn->{value};
  $self->{BindingCache}->{activity_id} = $dyn->{value};
  my $activity_name = $self->{Activities}->{$dyn->{value}}->{desc};
  if($activity_name ne ""){
    $self->{title} = "Activity Based Curation (<small>$dyn->{value}: $activity_name</small>)";
    #$self->AutoRefreshDiv('header','BigTitle');
  } else {
    $self->{title} = "Activity Based Curation (<small>no activity</small>)";
    #$self->AutoRefreshDiv('header','BigTitle');
    #$self->AutoRefreshOne;
  }
#  $self->AutoRefresh;
}

sub newActivity {
  my ($self, $http, $dyn) = @_;
  my $desc = $dyn->{value};
  if($desc =~/^\s*$/){ return }
  my $user = $self->get_user;
#  print STDERR "In new activity $user: $desc\n";
  my $q = Query('CreateActivity');
  $q->RunQuery(sub {}, sub {}, $desc, $user);
}
sub SortedActivityIds {
  my ($self, $h) = @_;
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
sub RefreshActivities {
  my ($self) = @_;
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
sub NewActivitiesPage{
  my($self, $http, $dyn) = @_;
  $http->queue(qq{
    <div style="display: flex; flex-direction: row; align-items: flex-end; margin-bottom: 5px">
  });
  $self->DrawActivitySelected($http, $dyn);
  $self->DrawClearActivityButton($http, $dyn);
  $http->queue("&nbsp;&nbsp;");
#  $self->DrawActivityModeSelector($http, $dyn);
  $http->queue("<div id=\"activitytaskstatus\" width=200>");
  $self->DrawActivityTaskStatus($http, $dyn);
  $http->queue("</div>");
  $http->queue(qq{</div><hr>});
#  my $method = $self->{ActivityModes}->{$self->{ActivityModeSelected}};
  my $method = "ShowActivityTimeline";
  if($self->can($method)){
    $http->queue("<div id=\"div_$method\">");
    $self->$method($http, $dyn);
    $http->queue("</div>");
  } else {
    $http->queue("method \"$method\" is not yet defined\n");
  }
}
sub DrawActivitySelected{
  my($self, $http, $dyn) = @_;
  my $activity = $self->{Activities}->{$self->{ActivitySelected}};
  $http->queue("<div id=\"selected_activity\">");
  $http->queue("Activity $self->{ActivitySelected}: ");
  $http->queue("$activity->{desc}<br>");
  $http->queue("Is third party: ");
  $http->queue("Yes ");
  my $yes = $self->RadioButtonSync("IsThirdParty", "yes",
    "SetThirdPartyStatus",
    (defined($activity->{third_party_analysis_url}) ? 1 : 0),
    "&control=NewActivityTimeline","Update();", "IsThirdPartyYes");
  $http->queue($yes);
  $http->queue(" No ");
  my $no = $self->RadioButtonSync("IsThirdParty","no",
    "SetThirdPartyStatus",
    (defined($activity->{third_party_analysis_url}) ? 0 : 1),
    "&control=NewActivityTimeline","Update();", "IsThirdPartyNo");
  $http->queue($no);
  if(defined($activity->{third_party_analysis_url})){
    $http->queue("<br>third party analysis url:<br>");
    $self->BlurEntryBox($http, {
      name => "ThirdPartyUrl",
      op => "SetThirdPartyUrl",
      id => "ThirdPartyEntry",
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

sub DrawClearActivityButton{
  my($self, $http, $dyn) = @_;
  $self->NotSoSimpleButton($http, {
    op => "ClearActivity",
    id => "ClearCurrentActivity",
    caption => "Choose Another Activity",
    sync => "UpdateDivs([['header', 'BigTitle'],['content', 'ContentResponse']]);",
  });
}
sub ClearActivity{
  my($self, $http, $dyn) = @_;
  $self->SetActivity("<none>");
#  $self->{ActivitySelected} = "<none>";
}
sub DrawActivityModeSelector{
  my($self, $http, $dyn) = @_;
  unless(defined $self->{ActivityModeSelected}){
    $self->{ActivityModeSelected} = 0;
  }
  my @activity_mode_list = (
    [0, "ShowActivityTimeline"],
    [1, "ActivityOperations"],
  );
  my @sorted_ids = $self->SortedActivityIds($self->{Activities});
  for my $i (@activity_mode_list){
    $self->{ActivityModes}->{$i->[0]} = $i->[1];
  }
  $http->queue("<div width=100>");
  $self->SelectByValue($http, {
    id => 'SetActivityMode',
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
sub DrawActivityTaskStatus{
  my($self, $http, $dyn) = @_;
  my @backgrounders;
  $self->{Backgrounders} = [];
  Query('GetActivityTaskStatus')->RunQuery(sub {
    my($row) = @_;
    push(@backgrounders, $row);
  }, sub {}, $self->{ActivitySelected});
  if($#backgrounders >= 0){
    $self->{Backgrounders} = \@backgrounders;
    $http->queue("<ul>");
    for my $i (@backgrounders){
      $http->queue("<li>$i->[0]: $i->[1] - $i->[4]");
      $self->NotSoSimpleButton($http, {
        op => "DismissActivityTaskStatus",
        id => "DismissActivityTaskStatus_$i->[0]",
        caption => "dismiss",
        subprocess_invocation_id => $i->[0],
        sync => "UpdateDiv('activitytaskstatus', 'DrawActivityTaskStatus');",
      });
      $http->queue("</li>");
    }
    $http->queue("</ul>");
    $self->InvokeAfterDelay("AutoRefreshActivityTaskStatus", 3);
#    $self->AutoRefresh();
  }
}
sub AutoRefreshActivityTaskStatus{
  my($self) = @_;
  if($self->{Mode} eq "Activities"){
    $self->AutoRefreshDiv("activitytaskstatus", "DrawActivityTaskStatus");
  }
}
sub DismissActivityTaskStatus{
  my($self, $http, $dyn) = @_;
  my $sub_id = $dyn->{subprocess_invocation_id};
  my $act_id = $self->{ActivitySelected};
  my $user = $self->get_user;
  Query('DismissActivityTaskStatus')->RunQuery(sub{}, sub{},
    $user, $act_id, $sub_id);
}
sub SetActivityMode{
  my($self, $http, $dyn) = @_;
  $self->{ActivityModeSelected} = $dyn->{value};
  $self->AutoRefresh;
}
sub ShowActivityTimeline{
  my($self, $http, $dyn) = @_;
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
    id => "btnCompareTimepoints",
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
        "&control=NewActivityTimeline","Update();", "fromActivityTimepoint_$tp");
      $http->queue($url);
    }
    $http->queue("</td>");
    $http->queue("<td>");
    if($tp){
      my $url = $self->RadioButtonSync("to",$tp,
        "ProcessRadioButton",
        (defined($self->{NewActivityTimeline}->{to}) && $self->{NewActivityTimeline}->{to} == $tp) ? 1 : 0,
        "&control=NewActivityTimeline","Update();", "toActivityTimepoint_$tp");
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
      id => "tl_show_email_$sub_id",
      caption => "email",
      file_id => $i->[6],
#      sync => "Update();",
    });
    $self->NotSoSimpleButton($http, {
      op => "ShowResponse",
      caption => "resp",
      id => "tl_show_resp_$sub_id",
      sub_id => $i->[7],
#      sync => "Update();",
    });
    if(defined $spreadsheet_file_id){
      $self->NotSoSimpleButton($http, {
        op => "ShowInput",
        id => "tl_show_input_$sub_id",
        caption => "input",
        file_id => $i->[9],
#        sync => "Update();",
      });
   }
    $http->queue("</td>");
    $http->queue("<td>$i->[0]</td>");
    $http->queue("<td>$i->[8]</td>");
    $http->queue("</tr>");
    $next_event = shift(@time_line_cp);
  }
  $http->queue("</table>");
}
sub ShowEmail{
  my($self, $http, $dyn) = @_;
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
sub ShowResponse{
  my($self, $http, $dyn) = @_;
  my $class = 'ActivityBasedCuration::ShowSubprocessLines';
  eval "require $class";
  my $params = {
    activity_id => $self->{ActivitySelected},
    sub_id =>  $dyn->{sub_id},
  };
  unless(exists $self->{sequence_no}){$self->{sequence_no} = 0}
  if($@){
    print STDERR "ActivityBasedCuration::ShowSubprocessLines failed to compile\n\t$@\n";
    return;
  }
  my $name = "ShowSubprocessResponse$self->{sequence_no}";
  $self->{sequence_no}++;

  my $child_path = $self->child_path($name);
  my $child_obj = $class->new($self->{session},
                              $child_path, $params);
  $self->StartJsChildWindow($child_obj);
}
sub ShowInput{
  my($self, $http, $dyn) = @_;
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
sub ProcessRadioButton{
  my($self, $http, $dyn) = @_;
  my $value = $dyn->{value};
  my $control = $dyn->{control};
  my $group = $dyn->{group};
  my $checked = $dyn->{checked};
  $self->{$control}->{$group} = $value;
}
sub CountOverlappingEvents{
  my($self, $event, $event_list) = @_;
  my $count = 0;
  for my $i (@$event_list){
    if(
      ($i->[3] ge $event->[3] && $i->[3] le $event->[4]) ||
      ($i->[4] ge $event->[3] && $i->[4] le $event->[4])
    ){ $count += 1; }
  }
  return $count;
}
sub CompareTimepoints{
  my($self, $http, $dyn) = @_;
  my $class = "Posda::NewerProcessPopup";
  eval "require $class";
  my $params = {
    command => $self->GetOperationDescription("CompareTimepoints"),
    current_settings => {
      button => "CompareTimepoints",
      from_timepoint_id => $self->{NewActivityTimeline}->{from},
      to_timepoint_id => $self->{NewActivityTimeline}->{to},
      activity_id => $self->{ActivitySelected},
      notify => $self->get_user
    }
  };
  unless(exists $self->{sequence_no}){$self->{sequence_no} = 0}
  if($@){
    print STDERR "Posda::NewerProcessPopup failed to compile\n\t$@\n";
    return;
  }
  my $name = "CompareTimepoint_$self->{sequence_no}";
  $self->{sequence_no}++;

  my $child_path = $self->child_path($name);
  my $child_obj = $class->new($self->{session},
                              $child_path, $params);
  $self->StartJsChildWindow($child_obj);
}


#ACTIVITY OPERATION WOOO
sub ActivityOperations{
  my($self, $http, $dyn) = @_;
  my @buttons;
  my $el_table = \@ActivityBasedCuration::WorkflowDefinition::ActivityCategories;
  my $selected_option = "1_associate";

  $http->queue('<div id="div_ActivityOperations">');
  for my $i (@$el_table){
    #$http->queue(Dumper($el_table));
    $http->queue("<div id=\"category_$i->{id}\">");
    $http->queue("<button onclick=\"ChangeSelection('sub_$i->{id}')\" class=\"btn btn-default  btn-lg btn-block\"  > $i->{name}  </button>");
    $http->queue('</div>');

    $http->queue("<div id=\"sub_$i->{id}\" class=\"subdiv\" style=\"display: none;\">");
    $http->queue("<blockquote><p>$i->{description}</p>");
    if ($i->{note}){
      $http->queue("<p> <mark>Note: $i->{note}</mark></p>");
    }
    if (exists $i->{operations}){
    $http->queue("<p> Possible Operations: </p>");
      $http->queue('<ul>');
      for my $j (@{$i->{operations}}){
        $http->queue("<li>");
        $self->NotSoSimpleButton($http, {
          op => "InvokeNewOperation",
          id => "btn_activity_op_$j->{action}",
          caption => $j->{caption},
          operation => $j->{action},
          special => $j->{special},
          sync => "Update();",
        });
        $http->queue("</li>");
      }
      $http->queue("</ul>");
    }
    if (exists $i->{queries}){
    $http->queue("<p> Possible Queries: </p>");
      $http->queue('<ul>');
      for my $j (@{$i->{queries}}){
        $http->queue("<li>");
        $self->NotSoSimpleButton($http, {
          op => "$j->{operation}",
          id => "btn_activity_qg$j->{query_list_name}",
          caption => $j->{caption},
          query_list_name => $j->{query_list_name},
          sync => "Update();",
        });
        $http->queue("</li>");
      }
      $http->queue("</ul>");
    }
    $http->queue('</blockquote></div>');
  }
}

sub LaunchUploadToEventWindow{
  my($self, $http, $dyn) = @_;
  my $params = {};
  $params->{user} = $self->get_user;
  $params->{TempDir} = $self->{LoginTempDir};
  my $class = "Posda::UploadToEvent";
  eval "require $class";
  if($@){
    print STDERR "$class failed to compile\n\t$@\n";
    return;
  }
  unless(exists $self->{sequence_no}){$self->{sequence_no} = 0}
  my $name = "Background_list_$self->{sequence_no}";
  $self->{sequence_no}++;
  $params->{upload_comment_string} = $self->{session} . "_" .
    $self->{sequence_no} . "_upload_event";

  my $child_path = $self->child_path($name);
  my $child_obj = $class->new($self->{session},
                            $child_path, $params);
  $self->StartJsChildWindow($child_obj);
  return;
}

sub LaunchBackground{
  my($self, $http, $dyn) = @_;
  my $params = {};
  $params->{user} = $self->get_user;
  my $class = "Posda::BackgroundList";
  eval "require $class";
  if($@){
    print STDERR "$class failed to compile\n\t$@\n";
    return;
  }
  unless(exists $self->{sequence_no}){$self->{sequence_no} = 0}
  my $name = "Background_list_$self->{sequence_no}";
  $self->{sequence_no}++;

  my $child_path = $self->child_path($name);
  my $child_obj = $class->new($self->{session},
                            $child_path, $params);
  $self->StartJsChildWindow($child_obj);
  return;
}

sub InvokeNewOperation{
  my($self, $http, $dyn) = @_;
  my $params;
  my $operation = $dyn->{operation};
  my $special = $dyn->{special};
  $params = {
     bindings => $self->{BindingCache},
  };
  my $invocation = {
    type => "WorkflowButton",
    Operation => $dyn->{operation},
    caption => $dyn->{caption}
  };
  $params->{invocation} = $invocation;
  $params->{current_settings}->{notify} = $self->get_user;
  if(defined $self->{ActivitySelected}){
    $params->{current_settings}->{activity_id} = $self->{ActivitySelected};
    Query("LatestActivityTimepointForActivity")->RunQuery(sub{
      my($row) = @_;
      $params->{current_settings}->{activity_timepoint_id} = $row->[0];
    }, sub {}, $self->{ActivitySelected});
  }

  #used for the accept/reject edits buttons that appear in emails
  if(defined $dyn->{subprocess_invoc_id}){
   $params->{prior_ss_args}->{subprocess_invoc_id} = $dyn->{subprocess_invoc_id};
  }
  if(defined $dyn->{activity_id}){
   $params->{prior_ss_args}->{activity_id} = $dyn->{activity_id};
  }

  my $command =
    $self->GetOperationDescription($invocation->{Operation});

  unless(defined $command){
    die "Command is not defined for $invocation->{Operation}";
  }
  if(defined $command){
    $params->{command} = $command;
  } else {
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

    my $child_path = $self->child_path($name);
    my $child_obj = $class->new($self->{session},
                              $child_path, $params);
    $self->StartJsChildWindow($child_obj);
    return;
  }
  if ($special eq "spreadsheetRequest"){
      $params->{special} =  $special;
      $params->{Temp_dir} =  "$self->{Environment}->{LoginTemp}/$self->{session}";
  }

  my $class = "Posda::NewerProcessPopup";
  eval "require $class";
  if($@){
    print STDERR "Class Posda::NewerProcessPopup failed to compile\n\t$@\n";
    return;
  }
  unless(exists $self->{sequence_no}){$self->{sequence_no} = 0}
  my $name = "TableLevelPopup_$self->{sequence_no}";
  $self->{sequence_no} += 1;

  my $child_path = $self->child_path($name);
  my $child_obj = $class->new($self->{session},
                              $child_path, $params);
  $self->StartJsChildWindow($child_obj);
}
sub InvokeOperation {
  my ($self, $http, $dyn) = @_;
#  my $class = "Posda::NewerProcessPopup";
  my $class = $dyn->{class_};
  unless(defined $class){
    $class = "Posda::NewerProcessPopup";
  }
  eval "require $class";
  #print STDERR Dumper($dyn);
  #Button Popularity'
  #Query('IncreaseButtonPopularity')->RunQuery(sub{}, sub{},$dyn->{operation});
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
sub NewerProcessPopupFromRow{
  my ($self, $http, $dyn) = @_;
  my $SFQ = $self->{ForegroundQueries}->{$self->{NewQueryToDisplay}};
  my $params;
  $params = {
     bindings => $self->{BindingCache},
  };
  my $invocation = {
    type => "InvokeOperationRow",
    Operation => $dyn->{operation},
    caption => $dyn->{caption},
  };
  $params->{invocation} = $invocation;
  $params->{current_settings}->{notify} = $self->get_user;
  if(defined $self->{ActivitySelected}){
    $params->{current_settings}->{activity_id} = $self->{ActivitySelected};
    Query("LatestActivityTimepointForActivity")->RunQuery(sub{
      my($row) = @_;
      $params->{current_settings}->{activity_timepoint_id} = $row->[0];
    }, sub {}, $self->{ActivitySelected});
  }
  # get params from row as prior_ss_args
  my $cols = $SFQ->{query}->{columns};
  my $rows = $SFQ->{rows};
  my $row = $rows->[$dyn->{row}];
  for my $ci (0 .. $#{$cols}){
    my $cn = $cols->[$ci];
    my $v = $row->[$ci];
    $params->{prior_ss_args}->{$cn} = $v;
  }

  my $command =
    $self->GetOperationDescription($invocation->{Operation});

  unless(defined $command){
    die "Command is not defined for $invocation->{Operation}";
  }
  if(defined $command){
    $params->{command} = $command;
  } else {
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

    my $child_path = $self->child_path($name);
    my $child_obj = $class->new($self->{session},
                              $child_path, $params);
    $self->StartJsChildWindow($child_obj);
    return;
  }

  my $class = "Posda::NewerProcessPopup";
  eval "require $class";
  if($@){
    print STDERR "Class Posda::NewerProcessPopup failed to compile\n\t$@\n";
    return;
  }
  unless(exists $self->{sequence_no}){$self->{sequence_no} = 0}
  my $name = "TableLevelPopup_$self->{sequence_no}";
  $self->{sequence_no} += 1;

  my $child_path = $self->child_path($name);
  my $child_obj = $class->new($self->{session},
                              $child_path, $params);
  $self->StartJsChildWindow($child_obj);
}
sub InvokeOperationRow {
  my ($self, $http, $dyn) = @_;
print STDERR "############In InvokeOperationRow\n";
#  my $class = "Posda::NewerProcessPopup";
  my $class = $dyn->{class_};
  if($class eq "Posda::NewerProcessPopup"){
    return $self->NewerProcessPopupFromRow($http, $dyn);
  }

  unless(defined $class){
    $class = "Posda::NewerProcessPopup";
  }
print STDERR "###########class: $class\n";
  if($class eq "Quince") { $class = "ActivityBasedCuration::Quince" }
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
  # if PathologyViewer, do it differently:
  if ($class eq 'PathologyViewerLauncher') {
    my $name = 'Kohlrabi';
    $self->openKohlrabi($name, $params);
    return;
  }
  # if Mirabelle, do it differently, too
  if ($class =~ /^Mirabelle/) {
    $self->openMirabelle($class, $params);
    return;
  }
  eval "require $class";
  if($@){
    print STDERR "$class failed to compile\n\t$@\n";
    return;
  }

  unless(exists $self->{sequence_no}){$self->{sequence_no} = 0}
  my $name = "StartBackground_$self->{sequence_no}";
  $self->{sequence_no}++;

  my $child_path = $self->child_path($name);
  my $child_obj = $class->new($self->{session},
                              $child_path, $params);
  $self->StartJsChildWindow($child_obj);
}
sub NewQueryWait {
  my ($self, $http, $dyn) = @_;
  $http->queue("Waiting for query: $self->{WaitingForQueryCompletion}");
}

sub openKohlrabi{
    my ($self, $name, $params) = @_;
    my $external_hostname = Config('external_hostname');
    my $prot = "http:";
    if(exists($ENV{POSDA_SECURE_ONLY}) && $ENV{POSDA_SECURE_ONLY}){
      $prot = "https:";
    }
    my $kohlrabi_url = "$prot//$external_hostname/kohlrabi";
    my $val;

    if (defined $params->{pathology_visual_review_instance_id}) {
      $val = $params->{pathology_visual_review_instance_id};

    my $cmd = "rt('$name', '$kohlrabi_url/$val', 700, 1000, 0);";
    $self->QueueJsCmd($cmd);
  }
}
sub openMirabelle{
    my ($self, $class, $params) = @_;

    my $external_hostname = Config('external_hostname');

    # NOTE currently Mirabelle must always be https. 
    # TODO you must make sure this is configured right!
    my $prot = "https:";

    # my $prot = "http:";
    # if(exists($ENV{POSDA_SECURE_ONLY}) && $ENV{POSDA_SECURE_ONLY}){
    #   $prot = "https:";
    # }
    
    my $base_url = "$prot//$external_hostname/mira";

    my $extra_url;
    if ($class eq 'MirabelleMaskIEC') {
      $extra_url = 'mask/iec/' . $params->{image_equivalence_class_id};
    }
    if ($class eq 'MirabelleReviewIEC') {
      $extra_url = 'review/iec/' . $params->{image_equivalence_class_id};
    }
    if ($class eq 'MirabelleMaskVR') {
      $extra_url = 'mask/vr/' . $params->{visual_review_instance_id};
    }

    $self->QueueJsCmd(
      "rt('Mirabelle', '$base_url/$extra_url', 700, 1000, 0);"
    );
}

sub Queries{
  my($self, $http, $dyn) = @_;
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
      <div style="display: flex; flex-direction: row; align-items: flex-end; margin-bottom: 5px"
        id="div_QuerySearchHead">
    });
    $self->DrawQueryListTypeSelector($http, $dyn);
    $self->DrawQuerySearchForm($http, $dyn);
    $http->queue(qq{</div><hr>});
  }
  $http->queue(qq{
    <div id="div_QuerySearchListOrResults">
  });
  $self->DrawQueryListOrResults($http, $dyn);
  $http->queue('</div>');
}
sub DrawCurrentForegroundQueriesSelector {
  my ($self, $http, $dyn) = @_;
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
sub SetCurrentForegroundSelection {
  my ($self, $http, $dyn) = @_;
  $self->{SelectFromCurrentForeground} = 1;
}
sub SelectFromCurrentForeground{
  my($self, $http, $dyn) = @_;
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
    id => "btn_DeleteAllForegroundQuery",
    caption => "dismiss/delete all",
    sync => "Update();",
  });
  $http->queue("</th></tr>");
  my %status_counts;
  for my $k (
    sort {
      $self->{ForegroundQueries}->{$a}->{invoked_id} <=>
      $self->{ForegroundQueries}->{$b}->{invoked_id}
    }
    keys %{$self->{ForegroundQueries}}
  ){
    my $e = $self->{ForegroundQueries}->{$k};
    $status_counts{$e->{status}} += 1;
    my $id = $e->{invoked_id};
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
      id => "btn_SelectCurrentQuery_$id",
      caption => "select",
      index => $k,
      sync => "Update();",
    });
    if(
      $e->{status} eq "done" ||
      $e->{status} eq "error" ||
      $e->{status} eq "ended" ||
      $e->{status} eq "aborted"
    ){
      $self->NotSoSimpleButton($http, {
        op => "DeleteCurrentForegroundQuery",
        id => "btn_DeleteCurrentQuery_$id",
        caption => "dismiss",
        index => $k,
        sync => "Update();",
      });
    }
    if($e->{status} eq "running"){
      $self->NotSoSimpleButton($http, {
        op => "PauseRunningQuery",
        id => "btn_PauseCurrentQuery_$id",
        caption => "pause",
        index => $k,
        sync => "Update();",
      });
      $self->NotSoSimpleButton($http, {
        op => "AbortRunningQuery",
        id => "btn_AbortQuery_$id",
        caption => "abort",
        index => $k,
        sync => "Update();",
      });
    } elsif ($e->{status} eq "paused"){
      $self->NotSoSimpleButton($http, {
        op => "UnPauseRunningQuery",
        id => "btn_ResumeCurrentQuery_$id",
        caption => "resume",
        index => $k,
        sync => "Update();",
      });
      $self->NotSoSimpleButton($http, {
        op => "EndPausedQuery",
        id => "btn_EndPausedQuery_$id",
        caption => "end",
        index => $k,
        sync => "Update();",
      });
    } elsif ($e->{status} eq "done"){
      $self->NotSoSimpleButton($http, {
        op => "RefreshQuery",
        id => "btn_RefreshQuery_$id",
        caption => "refresh",
        index => $k,
        sync => "Update();",
      });
      $self->NotSoSimpleButton($http, {
        op => "RerunQuery",
        id => "btn_RerunQuery_$id",
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
  unless(defined $status_counts{running}){ $status_counts{running} = 0 }
  if($status_counts{running} > 0){
    $self->AutoRefreshDiv('div_QuerySearchListOrResults','DrawQueryListOrResults');
  }
}
sub EndPausedQuery{
  my($self, $http, $dyn) = @_;
  my $index = $dyn->{index};
  my $q = $self->{ForegroundQueries}->{$index};
  unless($q->{status} eq "paused"){
    print STDERR "Can only end paused queries\n";
    return;
  }
  my $th = $q->{query}->{BottomHalfFh};
  $th->Abort;
  $q->{status} = "ended";
}
sub AbortRunningQuery{
  my($self, $http, $dyn) = @_;
  my $index = $dyn->{index};
  my $q = $self->{ForegroundQueries}->{$index};
  unless($q->{status} eq "running"){
    print STDERR "Can only abort running queries\n";
    return;
  }
  my $th = $q->{query}->{BottomHalfFh};
  $th->Abort;
  $q->{status} = "aborted";
  $q->{completion_msg} = "Aborted at user request";
}
sub DeleteAllForegroundQuery{
  my($self, $http, $dyn) = @_;
  for my $i (keys %{$self->{ForegroundQueries}}){
    my $e = $self->{ForegroundQueries}->{$i};
    if(
      $e->{status} eq "done" ||
      $e->{status} eq "ended" ||
      $e->{status} eq "error" ||
      $e->{status} eq "aborted"
    ){
       delete $self->{ForegroundQueries}->{$i};
    }
  }
  my $num = keys %{$self->{ForegroundQueries}};
  print STDERR "####################\nNum: $num\n";
  if($num == 0){
    delete $self->{SelectFromCurrentForeground};
    $self->{NewActivityQueriesType}->{query_type} = "recent";
  }
}
sub DeleteCurrentForegroundQuery{
  my($self, $http, $dyn) = @_;
  my $k = $dyn->{index};
  delete $self->{ForegroundQueries}->{$k};
  my $num_queries = keys %{$self->{ForegroundQueries}};
  if($num_queries == 0){
    delete $self->{SelectFromCurrentForeground};
    $self->{NewActivityQueriesType}->{query_type} = "recent";
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
  $url = $self->RadioButtonSync("query_type","recent",
    "ProcessRadioButton",
    (defined($self->{NewActivityQueriesType}) && $self->{NewActivityQueriesType}->{query_type} eq "recent") ? 1 : 0,
    "&control=NewActivityQueriesType","Update();");
  $http->queue("$url - recent&nbsp;&nbsp;");

  $url = $self->RadioButtonSync("query_type","search",
    "ProcessRadioButton",
    (defined($self->{NewActivityQueriesType}) && $self->{NewActivityQueriesType}->{query_type} eq "search") ? 1 : 0,
    "&control=NewActivityQueriesType","Update();");
  $http->queue("$url - search&nbsp;&nbsp;");
  $url = $self->RadioButtonSync("query_type","workflow",
    "ProcessRadioButton",
    (defined($self->{NewActivityQueriesType}) && $self->{NewActivityQueriesType}->{query_type} eq "workflow") ? 1 : 0,
    "&control=NewActivityQueriesType","Update();");
  $http->queue("$url - workflow");
  $http->queue("</div>");
}
sub DrawQuerySearchForm{
  my($self, $http, $dyn) = @_;
  if(
    (defined $self->{NewActivityQueriesType}) &&
    $self->{NewActivityQueriesType}->{query_type} eq "search"
  ){
    $http->queue('<div width=100 style="margin-left: 10px">');
    $http->queue("&nbsp;Args containing:&nbsp; ");
    $self->NewEntryBox($http, {
      name => "NewArgList",
      op => "SetNewArgList",
      value => "$self->{NewArgListText}"
    },"UpdateDiv('div_QuerySearchListOrResults', 'DrawQueryListOrResults')");
    $http->queue("</div>");
    $http->queue('<div width=100 style="margin-left: 10px">');
    $http->queue("&nbsp;Columns containing:&nbsp; ");
    $self->NewEntryBox($http, {
      name => "NewColList",
      op => "SetNewColList",
      value => "$self->{NewColListText}"
    },"UpdateDiv('div_QuerySearchListOrResults', 'DrawQueryListOrResults')");
    $http->queue("</div>");
    $http->queue('<div width=100 style="margin-left: 10px">');
    $http->queue("&nbsp;Query matching:&nbsp; ");
    $self->NewEntryBox($http, {
      name => "NewTableMatchList",
      op => "SetNewTableMatchList",
      value => "$self->{NewTableMatchListText}"
    },"UpdateDiv('div_QuerySearchListOrResults', 'DrawQueryListOrResults')");
    $http->queue("</div>");
    $http->queue('<div width=100 style="margin-left: 10px">');
    $http->queue("&nbsp;Name matching:&nbsp; ");
    $self->NewEntryBox($http, {
      name => "NewNameMatchList",
      op => "SetNewNameMatchList",
      value => "$self->{NewNameMatchListText}"
    },"UpdateDiv('div_QuerySearchListOrResults', 'DrawQueryListOrResults')");
    $http->queue("</div>");
#    $http->queue('<div width=100 style="margin-left: 10px">');
#    $http->queue("<br>");
#    $self->NotSoSimpleButton($http, {
#      op => "SearchQueries",
#      caption => "search",
#      sync => "Update();",
#    });
#    $http->queue("</div>");
    $http->queue('<div width=100 style="margin-left: 10px">');
    $http->queue("<br>");
    $self->NotSoSimpleButton($http, {
      op => "ClearQueries",
      caption => "clear",
      sync => "Update();",
    });
    $http->queue("</div>");
  } elsif(
    (defined $self->{NewActivityQueriesType}) &&
    $self->{NewActivityQueriesType}->{query_type} eq "workflow"
  ){
    $http->queue('<div width=100 style="margin-left: 10px">');
    $self->SelectDelegateByValue($http, {
      op => 'SetWorkflowMode',
      id => "SelectWorkflowMode",
      sync => "UpdateDiv('div_QuerySearchListOrResults', 'DrawQueryListOrResults');Update();",
    });

    unless(defined($self->{WorkflowSelected})){ $self->{WorkflowSelected} = "<none>" }
    for my $i ("<none>", sort keys %{$self->{WorkflowQueries}}){
      $http->queue("<option value=\"$i\"");
      if($i eq $self->{WorkflowSelected}){
        $http->queue(" selected")
      }
      if($i eq "<none>"){
        $http->queue(">Select Workflow Group</option>");
      } else {
        $http->queue(">$self->{WorkflowQueries}->{$i}->[0]</option>");
      }
    }
    $http->queue(qq{
      </select>
    });
    $http->queue("</div>");
  }
}
sub SetWorkflowMode{
  my($self, $http, $dyn) = @_;
  $self->{WorkflowSelected} = $dyn->{value};
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
  $self->SearchQueries;
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
  $self->SearchQueries;
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
  $self->SearchQueries;
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
  $self->SearchQueries;
}
sub DrawQueryListOrResults{
  my($self, $http, $dyn) = @_;
  if((defined $self->{NewActivityQueriesType}) &&
    $self->{NewActivityQueriesType}->{query_type} eq "search"
  ){
    $self->DrawQueryListOrResultsSearch($http, $dyn);
  } elsif((defined $self->{NewActivityQueriesType}) &&
    $self->{NewActivityQueriesType}->{query_type} eq "active"
  ){
    if(exists $self->{SelectedNewQuery}){
      $self->DrawQueryListOrResultsSearch($http, $dyn);
    } else {
      $self->SelectFromCurrentForeground($http, $dyn);
    }
#    $self->DrawQueryListOrResultsSearch($http, $dyn);
  } elsif((defined $self->{NewActivityQueriesType}) &&
    $self->{NewActivityQueriesType}->{query_type} eq "workflow"
  ){
    if(exists $self->{SelectedNewQuery}){
      $self->DrawQueryListOrResultsSearch($http, $dyn);
    } else {
      $self->SelectFromCurrentWorkflow($http, $dyn);
    }
  } else {
    $self->DrawQueryListOrResultsRecent($http, $dyn);
  }
}
sub SelectQueryGroup{
  my($self, $http, $dyn) = @_;
  my $query_list_name = $dyn->{query_list_name};
  $self->{Mode} = "Queries";
  $self->{WorkflowSelected} = $query_list_name;
  $self->{NewActivityQueriesType}->{query_type} = "workflow";
  delete $self->{NewQueryToDisplay};
}
sub SelectFromCurrentWorkflow{
  my($self, $http, $dyn) = @_;
  unless(defined($self->{WorkflowSelected}) && $self->{WorkflowSelected} ne "<none>"){
    $http->queue("Please Select a Workflow");
    return;
  }
  $http->queue(qq{
    <div style="display: flex; flex-direction: column; align-items: flex-beginning; margin-bottom: 5px">
  });
  my @query_list = @{$self->{WorkflowQueries}->{$self->{WorkflowSelected}}->[1]};
  workflow_query:
  for my $i (@query_list){
    my $qn = $i->{query};
    my $qd;
    unless(exists $self->{NewQueriesByName}->{$qn}){
      eval  { $qd = PosdaDB::Queries->GetQueryInstance($qn) };
      if($@) {
        $http->queue("<pre>$@</pre>");
        next workflow_query;
      }
      $self->{NewQueriesByName}->{$qn} = $qd;
    }
  }
  $http->queue('<table class="table table-striped table-condensed" id="tbl_QueryListRecent">');
  $http->queue("<caption>$self->{WorkflowQueries}->{$self->{WorkflowSelected}}->[0]</caption>");
  $http->queue("<tr><th>name</th><th>params</th><th>columns returned</th>" .
    "<th>make query</th></tr>");
  for my $ii (@query_list){
    my $cap  = $ii->{caption};
    my $query_name = $ii->{query};
    $http->queue("<tr>");
    my $q = $self->{NewQueriesByName}->{$query_name};
    $http->queue("<td>$query_name</td>");
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
      id => "btn_foreground_$query_name ",
      caption => "foreground",
      query_name => $query_name ,
      sync => "Update();",
    });
    $self->NotSoSimpleButton($http, {
      op => "OpenBackgroundQuery",
      id => "btn_background_$query_name",
      caption => "background",
      query_name => $query_name,
      sync => "Update();",
    });
    $http->queue("</td>");
    $http->queue("</tr>");
  }
  $http->queue('</table>');
  $http->queue("</div>");
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
  $self->{Input} = {};
}
sub OpenNewChainedQuery{
  my($self, $http, $dyn) = @_;
  my $SFQ = $self->{ForegroundQueries}->{$self->{NewQueryToDisplay}};
  my $id = $dyn->{chained_query_id};
  my $query_name = $dyn->{to_query};

#  my $details = PosdaDB::Queries->GetChainedQueryDetails($id);
  my $details = $self->{QueryChainingDetails}->{$id};
$self->{querychaindetailsid} = $id;
$self->{querychaindetails} = $details;
# $self->{Details} = $details;

  # get the row as a hash?
  my $h = {};

  my $cols = $SFQ->{query}->{columns};
  my $rows = $SFQ->{rows};
  my $row = $rows->[$dyn->{row}];

  # build hash for popup constructor
  for my $i (0 .. $#{$row}) {
    $h->{$cols->[$i]} = $row->[$i];
  }


  # $h now holds the values of the row as a hash
  for my $param (@$details) {
    for my $from_column_name (keys %$param){
      my $to_parameter_name = $param->{$from_column_name};
      if(exists $self->{BindingCache}->{$to_parameter_name}){
        unless(
          $self->{BindingCache}->{$to_parameter_name} eq
          $h->{$from_column_name}
        ){
          $self->{BindingCache}->{$to_parameter_name} =
            $h->{$from_column_name};
          delete $self->{Input}->{$to_parameter_name};
          $self->UpdateBindingValueInDb($to_parameter_name);
        }
      } else {
        $self->{BindingCache}->{$to_parameter_name} =
          $h->{$from_column_name};
        delete $self->{Input}->{$to_parameter_name};
        $self->CreateBindingCacheInfoForKeyInDb($to_parameter_name);
      }
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

sub setForegroundQuery(){
  my($self, $http, $dyn) = @_;
  $self->{Mode} = $dyn->{mode};
  $self->{NewQueryToDisplay} = $dyn->{index};
  $self->{Input} = {};  # clear previous input values
  my $q_pack = $self->{ForegroundQueries}->{$self->{NewQueryToDisplay}};
  delete $self->{NewQueryToDisplay};
  $self->{SelectedNewQuery} = $dyn->{query_name};
}

sub DrawNewQuery{
  my($self, $http, $dyn) = @_;
#  $http->queue("NewQuery goes here ($self->{SelectedNewQuery})");
  my $q_name = $self->{SelectedNewQuery};
  my $query;
#  if(
#    exists($self->{NewQueryListSearch}) &&
#    ref($self->{NewQueryListSearch}) eq "HASH" &&
#    exists($self->{NewQueryListSearch}->{$q_name})
#  ){
#    $query = $self->{NewQueryListSearch}->{$q_name};
#  } elsif (
#    exists($self->{NewQueriesByName}) &&
#    ref($self->{NewQueriesByName}) eq "HASH" &&
#    exists($self->{NewQueriesByName}->{$q_name})
#  ){
#    $query = $self->{NewQueriesByName}->{$q_name};
#  } else {
#    warn "Query name '$q_name' not found at " . __LINE__ . "\n";
#  }
  $query = PosdaDB::Queries->GetQueryInstance($q_name);

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
    if(
      $arg eq "activity_id" &&
      not defined $self->{Input}->{$arg} &&
      defined $self->{ActivitySelected}
    ){
      $self->{Input}->{$arg} = $self->{ActivitySelected};
    } elsif (
      $arg eq "activity_timepoint_id" &&
      not defined $self->{Input}->{$arg} &&
      defined $self->{ActivitySelected}
    ){
      Query("LatestActivityTimepointForActivity")->RunQuery(sub{
        my($row) = @_;
        $self->{Input}->{$arg} = $row->[0];
      }, sub {}, $self->{ActivitySelected});
    } elsif (
      $arg eq "notify" &&
      not defined $self->{Input}->{$arg}
    ){
      $self->{Input}->{$arg} = $self->get_user;
    } elsif (
      defined $self->{BindingCache}->{$arg} and
      not defined $self->{Input}->{$arg}
    ){
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

sub MakeNewQuery {
  my ($self, $http, $dyn) = @_;
  my $query_name = $self->{SelectedNewQuery};
  my $query = Query($query_name);
#  if($self->{NewActivityQueriesType}->{query_type} eq "search"){
#    $query = $self->{NewQueryListSearch}->{$self->{SelectedNewQuery}};
#  } else {
#    $query = $self->{NewQueriesByName}->{$self->{SelectedNewQuery}};
#  }
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
    sub {
  my ($row) = @_;
      push @{$q_pack->{rows}}, $row;
    },
    sub {
  my ($msg) = @_;
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
  #$self->{NewQueryToDisplay} = $guid;
  #$self->{WaitingForQueryCompletion} = $msg;
  my $q_pack = $self->{ForegroundQueries}->{$guid};
  $query->RunQuery(
    sub {
  my ($row) = @_;
      push @{$q_pack->{rows}}, $row;
    },
    sub {
  my ($msg) = @_;
      if($msg =~ /^RESULT:(.*)$/s){
        $q_pack->{status} = "done";
        $q_pack->{completion_msg} = $1;
        Posda::QueryLog::query_finished($invoked_id, $#{$q_pack->{rows}} + 1);
      } elsif($msg =~ /^ERROR:(.*)$/s){
        $q_pack->{status} = "error";
        $q_pack->{completion_msg} = $1;
      }
      if(defined($self->{NewQueryToDisplay}) && $self->{NewQueryToDisplay} == $guid){
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
sub NewQueryPageUp {
  my ($self, $http, $dyn) = @_;
  my $SFQ = $self->{ForegroundQueries}->{$self->{NewQueryToDisplay}};
  my $new_start = $SFQ->{first_row} + $SFQ->{rows_to_show};
  if($new_start + $SFQ->{rows_to_show} > @{$SFQ->{rows}}){
    $new_start = @{$SFQ->{rows}} - $SFQ->{rows_to_show};
    if($new_start < 0) { $new_start = 0 }
  }
  $SFQ->{first_row} = $new_start;
}
sub NewQueryPageDown {
  my ($self, $http, $dyn) = @_;
  my $SFQ = $self->{ForegroundQueries}->{$self->{NewQueryToDisplay}};
  my $new_start = $SFQ->{first_row} - $SFQ->{rows_to_show};
  if($new_start < 0){
    $new_start = 0;
  }
  $SFQ->{first_row} = $new_start;
}
sub SetFirstRow {
  my ($self, $http, $dyn) = @_;
  my $SFQ = $self->{ForegroundQueries}->{$self->{NewQueryToDisplay}};
  my $value = $dyn->{value};
  my $max = @{$SFQ->{rows}} - $SFQ->{rows_to_show};
  if($value < 0) { $value = 0 }
  if($value > $max) { $value = $max }
  $SFQ->{first_row} = $value;
}
sub SetRowsToShow {
  my ($self, $http, $dyn) = @_;
  my $SFQ = $self->{ForegroundQueries}->{$self->{NewQueryToDisplay}};
  my $value = $dyn->{value};
  $SFQ->{rows_to_show} = $value;
}
sub FilterQueryRows {
  my ($self, $sfq) = @_;
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
      #unless($r->[$name_to_i{$k}] =~ /$sfq->{filter}->{$k}/){
      #  next row;
      #}
      $self->{ColValue} = uc $r->[$name_to_i{$k}];
      $self->{ColFilter} = uc $sfq->{filter}->{$k};
      unless($self->{ColValue} =~ /$self->{ColFilter}/){
        next row;
      }

    }
    push @filtered_rows, $r;
  }
  return \@filtered_rows;
}
sub SetEditFilter {
  my ($self, $http, $queue) = @_;
  my $SFQ = $self->{ForegroundQueries}->{$self->{NewQueryToDisplay}};
  if(defined $SFQ->{filter}){
    $self->{FilterArgs} = $SFQ->{filter};
  } else {
    $self->{FilterArgs} = {};
  }
  $self->{EditFilter} = 1;
}
sub DownloadCurrentForegroundQuery{
  my($self, $http, $dyn) = @_;
  my $q = $self->{NewQueryToDisplay};
  if($self->{FilterSelection}->{$q} eq "unfiltered"){
    return $self->DownloadUnfilteredTable($http, $dyn);
  } else {
    return $self->DownloadFilteredTable($http, $dyn);
  }
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
  if($SFQ->{status} eq 'done' || $SFQ->{status} eq "ended" || $SFQ->{status} eq "paused"){
    return $self->DisplayFinishedSelectedForegroundQuery($http, $dyn);
  }
  if($SFQ->{status} eq "error" || $SFQ->{status} eq "aborted"){
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
  my $popup_hash = $self->get_popup_hash_new($q_name);
  if(exists $self->{QueryToProcessingButton}->{$q_name}){
    $self->{QueryMenuTableBasedButtons}->{$q_name} =
      $self->{QueryToProcessingButton}->{$q_name};
  }
  my @chained_queries;
  for my $i (keys %{$self->{QueryChaining}}){
    my $r = $self->{QueryChaining}->{$i};
    if($r->{from_query} eq $q_name){
      push @chained_queries, $r;
    }
  }
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
    <div style="display: flex; flex-direction: column; align-items: flex-beginning; margin-bottom: 5px"
    id='div_QueryRespHead'>});
  $http->queue(qq{
    <div style="display: flex; flex-direction: row; align-items: flex-end; margin-left: 10px">
  });
  $http->queue(qq{ <div width=100 style="margin-bottom: 10px;margin-left: 10px"> });
  $http->queue("<em><b>");
  if($SFQ->{status} ne "done"){ $http->queue("Partial ($SFQ->{status}) ") }
  else { $http->queue("Full ") }
  $http->queue("Results for:</b></em>&nbsp;&nbsp;$SFQ->{caption}&nbsp;&nbsp;&nbsp;");
  $http->queue("</div>");
  my $index = $self->{NewQueryToDisplay};
  unless(exists $self->{FilterSelection}->{$index}){
    $self->{FilterSelection}->{$index} = "unfiltered";
  }
  my $url_1 = $self->RadioButtonSync("$index","unfiltered",
    "ProcessRadioButton",
    (defined($self->{FilterSelection}) && $self->{FilterSelection}->{$index} eq "unfiltered") ? 1 : 0,
    "&control=FilterSelection","Update();");
  my $url_2 = $self->RadioButtonSync($index,"filtered",
    "ProcessRadioButton",
    (defined($self->{FilterSelection}) && $self->{FilterSelection}->{$index} eq "filtered") ? 1 : 0,
    "&control=FilterSelection","Update();");
  $http->queue(qq{ <div width=100 style="margin-bottom: 10px;margin-left: 10px"> });
  $http->queue("$url_1 Unfiltered rows: $num_rows");
  $http->queue("</div>");
  $http->queue(qq{ <div width=100 style="margin-bottom: 10px;margin-left: 10px"> });
  $http->queue("$url_2 Filtered rows: $filtered_rows");
  $http->queue("</div>");
  $http->queue(qq{ <div width=300 style="margin-bottom: 10px;margin-left: 10px"><pre> });
  unless(exists $SFQ->{filter}){
    $http->queue("No filter currently defined</pre>");
  } else {
    $self->RenderCurrentQueryFilter($http, $dyn);
  }
  $http->queue("</div>");
  $http->queue("</div>");

  $http->queue(qq{
    <div style="display: flex; flex-direction: row; align-items: flex-end; margin-left: 10px">
  });
  my $rows = keys @{$SFQ->{rows}};
  my $first_row = $SFQ->{first_row};
  $http->queue('First row: ');
  $self->ClasslessBlurEntryBox($http, {
    name => "FirstRow",
    size => 5,
    op => "SetFirstRow",
    value => $first_row,
  }, "Update();");
  $http->queue('Show: ');
  $self->ClasslessBlurEntryBox($http, {
    name => "RowsToShow",
    size => 5,
    op => "SetRowsToShow",
    value => $SFQ->{rows_to_show},
  }, "Update();");
  $self->NotSoSimpleButton($http, {
    op => "NewQueryPageUp",
    caption => "pg-dn",
    sync => "Update();",
    class => "btn btn-primary",
  });
  $self->NotSoSimpleButton($http, {
    op => "NewQueryPageDown",
    caption => "pg-up",
    sync => "Update();",
    class => "btn btn-primary",
  });
  $http->queue("</div>");
  if(exists($self->{EditFilter})){
    $self->DrawEditFilterForm($http, $dyn, $SFQ);
  }
  $http->queue("</div>");
  $http->queue(qq{
    <div style="display: flex; flex-direction: row; align-items: flex-end; margin-left: 10px"
    id="div_QueryResults">
  });

  $http->queue('<table class="table table-striped table-condensed">');
  $http->queue("<tr>");
  if($#chained_queries > -1){
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
$self->{chained_queries} = \@chained_queries;
    if($#chained_queries > -1){
      $http->queue("<td>");
	for my $q (@chained_queries) {
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
          my $t = $row->[$j];
          if(ref($row->[$j]) eq "ARRAY"){
            $t = "{";
            for my $ii (0 .. $#{$row->[$j]}){
              $t .= "$row->[$j]->[$ii]";
              unless($ii == $#{$row->[$j]}){
                $t .= ",";
              }
            }
            $t .= "}";
          }
          $t =~ s/</&lt;/g;
          $t =~ s/>/&gt;/g;
	  $http->queue($t);
	  if (defined $popup_hash->{$cn} && ref($popup_hash->{$cn}) eq "HASH") {
	    my $popup_details = $popup_hash->{$cn};
            #### surpress warnings ---
            unless(defined $popup_details->{caption}){
              $popup_details->{caption} = "";
            }
            unless(defined $popup_details->{obj}){
              $popup_details->{obj} = "";
            }
            unless(defined $popup_details->{operation}){
              $popup_details->{operation} = "";
            }
            #### end surpress warnings ---
#xyzzy --- Here to work on column buttons
	    $self->NotSoSimpleButton($http, {
		caption => "$popup_details->{caption}",
		op => "InvokeOperationRow",
		row => "$i",
		class_ => "$popup_details->{obj}",
		operation => "$popup_details->{operation}",
                column => $cn,
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
sub RenderCurrentQueryFilter {
  my ($self, $http, $dyn) = @_;
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
sub TextRenderQueryFilter{
  my($this, $q_filter) = @_;
  my $SFQ = $this->{ForegroundQueries}->{$this->{NewQueryToDisplay}};
  my $resp = "QueryFilter:\n";
  for my $k (keys %{$SFQ->{filter}}){
    if(defined $SFQ->{filter}->{$k} && $SFQ->{filter}->{$k} ne ""){
      $resp .= "   $k contains \"$SFQ->{filter}->{$k}\"<br>";
    } else {
      delete $SFQ->{filter}->{$k};
    }
  }
  return $resp;
}
sub DrawEditFilterForm {
  my ($self, $http, $dyn, $SFQ) = @_;
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
  $http->queue("</div>");
}

sub SetFilter {
  my ($self, $http, $dyn) = @_;
  my $SFQ = $self->{ForegroundQueries}->{$self->{NewQueryToDisplay}};
  if((keys %{$self->{FilterArgs}}) > 0){
    $SFQ->{filter} = $self->{FilterArgs};
  }
  delete $self->{EditFilter};
  delete $self->{FilterArgs};
}
sub SetFilterArgs {
  my ($self, $http, $dyn) = @_;
  $self->{FilterArgs}->{$dyn->{index}} = $dyn->{value};
}
sub ClearFilter {
  my ($self, $http, $dyn) = @_;
  my $SFQ = $self->{ForegroundQueries}->{$self->{NewQueryToDisplay}};
  delete $self->{EditFilter};
  delete $self->{FilterArgs};
  delete $SFQ->{filter};
}

sub PauseRunningQuery{
  my($self, $http, $dyn) = @_;
  my $index = $dyn->{index};
  my $e = $self->{ForegroundQueries}->{$index};
  unless($e->{status} eq "running"){
    print STDERR "can't pause a query that isn't running\n";
    return;
  }
  my $p = $e->{query}->{BottomHalfFh};
  if($p->pause){
    $e->{status} = "paused";
  } else {
    $e->{status} = "error";
    $e->{completion_msg} = "connection died: pause";
  }
}

sub UnPauseRunningQuery{
  my($self, $http, $dyn) = @_;
  my $index = $dyn->{index};
  my $e = $self->{ForegroundQueries}->{$index};
  my $p = $e->{query}->{BottomHalfFh};
  unless($e->{status} eq "paused"){
    print STDERR "can't resume a query that isn't paused\n";
    return;
  }
  if($p->resume){
    $e->{status} = "running";
  } else {
    $e->{status} = "error";
    $e->{completion_msg} = "connection died: resume";
  }
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
sub DrawNewQueryResults {
  my ($self, $http, $dyn) = @_;
  $http->queue("NewQueryResults goes here");
}
sub DrawQueryListSearch {
  my ($self, $http, $dyn) = @_;
  my @MostFrequentSelects = sort {$a cmp $b } keys %{$self->{NewQueryListSearch}};
  my $num_queries = @MostFrequentSelects;
  $http->queue('<table class="table table-striped table-condensed" id="tbl_QueryListSearch">');
  $http->queue("<caption>Searched queries ($num_queries rows)");
  $http->queue("</div>");
  $http->queue('<div width=100 style="margin-left: 10px">');
  $http->queue($self->{QuerySearchWhereClause});
  $http->queue("</div>");
  $http->queue("</caption>");
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
      id => "btn_foreground_$i",
      caption => "foreground",
      query_name => $i,
      sync => "Update();",
    });
    $self->NotSoSimpleButton($http, {
      op => "OpenBackgroundQuery",
      id => "btn_background_$i",
      caption => "background",
      query_name => $i,
      sync => "Update();",
    });
    $http->queue("</td>");
    $http->queue("</tr>");
  }
  $http->queue('</table>');
}
sub DrawQueryListOrResultsRecent {
  my ($self, $http, $dyn) = @_;
  if(exists($self->{NewQueryResults})){
    $self->DrawQueryResults($http, $dyn);
  } else {
    $self->DrawQueryListOrSelectedQueryRecent($http, $dyn);
  }
}
sub DrawQueryListOrSelectedQueryRecent {
  my ($self, $http, $dyn) = @_;
  if(exists $self->{SelectedNewQuery}){
    $self->DrawNewQuery($http, $dyn);
  } else {
    $self->DrawQueryListRecent($http, $dyn);
  }
}
sub DrawQueryListRecent {
  my ($self, $http, $dyn) = @_;
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
  $http->queue('<table class="table table-striped table-condensed" id="tbl_QueryListRecent">');
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
      id => "btn_foreground_$i",
      caption => "foreground",
      query_name => $i,
      sync => "Update();",
    });
    $self->NotSoSimpleButton($http, {
      op => "OpenBackgroundQuery",
      id => "btn_background_$i",
      caption => "background",
      query_name => $i,
      sync => "Update();",
    });
    $http->queue("</td>");
    $http->queue("</tr>");
  }
  $http->queue('</table>');
  $http->queue('<table class="table table-striped table-condensed" id="tbl_QueryMostCommon">');
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
      id => "btn_foreground_$i",
      caption => "foreground",
      query_name => $i,
      sync => "Update();",
    });
    $self->NotSoSimpleButton($http, {
      op => "OpenBackgroundQuery",
      id => "btn_background_$i",
      caption => "background",
      query_name => $i,
      sync => "Update();",
    });
    $http->queue("</td>");
    $http->queue("</tr>");
  }
  $http->queue('</table>');
}

#############################
#Here Bill is putting in the "ShowBackground"
sub ShowBackground {
  my ($self, $http, $dyn) = @_;
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
sub LoadScriptOutput {
  my ($self, $table_name) = @_;
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
sub DownloadTar {
  my ($self, $http, $dyn) = @_;
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
sub SetSelectedDownloadSubdir {
  my ($self, $http, $dyn) = @_;
  $self->{SelectedDownloadSubdir} = $dyn->{value};
}
sub DownloadTarOfThisDirectory {
  my ($self, $http, $dyn) = @_;
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
sub DeleteThisDirectory {
  my ($self, $http, $dyn) = @_;
  rmtree($self->{DownloadTar});
}

#############################
sub Upload{
  my($self, $http, $dyn) = @_;
  $self->RefreshEngine($http, $dyn, qq{
  <div style="display: flex; flex-direction: column; align-items: flex-beginning;
    margin-left: 10px; margin-bottom: 5px">
  <div id="load_form">
  <form action="<?dyn="StoreFileUri"?>"
    enctype="multipart/form-data" method="POST" class="dropzone">
  </form>
  </div>
  <div id="file_report">
  <?dyn="Files"?>
  </div>
  </div>
  });
  $self->InvokeAfterDelay("RefreshFileDiv", 0);
}
sub RefreshFileDiv{
  my($this) = @_;
  $this->AutoRefreshDiv('file_report','Files');
};
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
  my $class = 'Posda::NewerProcessPopup';
  eval "require $class";
  if($@){
    print STDERR "$class failed to compile\n\t$@\n";
    return;
  }
  unless(exists $self->{sequence_no}){$self->{sequence_no} = 0}
  my $name = "Loaded_Spreadsheet_$self->{sequence_no}";
  $self->{sequence_no}++;

  my $child_path = $self->child_path($name);
  my $child_obj = $class->new($self->{session},
                              $child_path, $params);
  $self->StartJsChildWindow($child_obj);
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

#sub LoadCsvIntoTable {
#  my ($self, $http, $dyn) = @_;
#  $self->{Mode} = "LoadCsvIntoTable";
#  my $file = $self->{UploadedFiles}->[$dyn->{index}]->{"Output file"};
#
#  $self->LoadCSVIntoTable_NoMode($file);
#}
#sub LoadCSVIntoTable_NoMode {
#  my ($self, $file) = @_;
#  my $cmd = "CsvToPerlStruct.pl \"$file\"";
#  $self->SemiSerializedSubProcess($cmd, $self->CsvLoaded($file));
#}


#sub CsvLoaded {
#  my ($self, $file) = @_;
#  my $sub = sub {
#    my($status, $struct) = @_;
#    if($status eq "Succeeded"){
#      if($struct->{status} eq "OK"){
#        unless(
#          # create LoadedTables array
#          exists $self->{LoadedTables} &&
#          ref($self->{LoadedTables}) eq "ARRAY"
#        ){ $self->{LoadedTables} = [] }
#
#        ## Get the basename of the file
#        #my $basename;
#        #my $fn = $file;
#        #if($fn =~ /\/([^\/]+)$/){
#        #  $basename = $1;
#        #} else {
#        #  $basename = $fn;
#        #}
#
#        ## test if there is a query file to load
#        #my $queryfile = "$file.query";
#        #my $query;
#
#        ## if $queryfile exists, load it
#        #if (-e $queryfile) {
#        #  $query = retrieve $queryfile;
#        #}
#
#        #if (defined $query) {
#        #  $new_table_entry->{query} = $query;
#        #  $new_table_entry->{type} = "FromQuery";
#        #  #delete the first row, as it is query headers
#        #  delete $new_table_entry->{rows}->[0];
#        #}
#
#        my $new_table_entry = DbIf::Table::from_csv($file, $struct, time);
#
#        # import the new file into posda
#        Dispatch::LineReaderWriter->write_and_read_all(
#          "ImportSingleFileIntoPosdaAndReturnId.pl \"$file\" \"DbIf file upload\"",
#          [""],
#          sub {
#  my ($return) = @_;
#            for my $i (@$return) {
#              if ($i =~ /File id: (.*)/) {
#                $new_table_entry->{posda_file_id} = $1;
#                # record upload event
#                my $upload_id = PosdaDB::Queries::record_spreadsheet_upload(
#                  0, $self->get_user, $1, $#{$new_table_entry->{rows}});
#                $new_table_entry->{spreadsheet_uploaded_id} = $upload_id;
#              } else {
#                say STDERR "Error inserting file into posda! $i";
#              }
#            }
#          }
#        );
#
#        push(@{$self->{LoadedTables}}, $new_table_entry);
#      } else {
#      }
#    } else {
#    }
#  };
#  return $sub;
#}

sub Reports {
  my ($self, $http, $dyn) = @_;
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

sub LoadPreparedReport {
  my ($self, $http, $dyn) = @_;
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
  $self->SemiSerializedSubProcess($cmd, sub {
    &$final_callback(@_);
    my $index = $#{$self->{LoadedTables}};
    $self->{SelectedTable} = $index;
    $self->{Mode} = "TableSelected";
    $self->AutoRefresh;
  });

  $self->{Mode} = "QueryWait";
}

sub Tables {
  my ($self, $http, $dyn) = @_;
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

#sub ExecuteCommand {
#  my ($self, $http, $dyn) = @_;
#  $self->{SelectedTable} = $dyn->{index};
#  my $table = $self->{LoadedTables}->[$dyn->{index}];
#
#  # TODO: rethink this, with new DbIf::Table this might
#  # be easier!
#
#  # generate a map of column name to col index
#  my $colmap = {};
#  map {
#    my $item = $table->{columns}->[$_];
#    $colmap->{$item} = $_;
#  } (0 .. $#{$table->{columns}});
#
#  # Test for pipe edge case
#  my $first_row_op = $table->{rows}->[0]->[$colmap->{Operation}];
#  if (defined $self->{Commands}->{$first_row_op}->{pipe_parms}) {
#    my $op = $self->{Commands}->{$first_row_op};
#
#    say "First row is a Pipeop!";
#
#    # get list of columns that are "column vars"
#    my @column_vars = $op->{pipe_parms} =~ /<([^<>]+)>/g;
#
#    # transform column_var columns into lists
#    my $cols = {};
#    for my $col_name (@column_vars) {
#      my $col_idx = $colmap->{$col_name};
#
#      my $col1 = [];
#      for my $row (@{$table->{rows}}) {
#        push @$col1, $row->[$col_idx];
#      }
#
#      $cols->{$col_name} = $col1;
#    }
#    my $parm_map;
#    for my $i (@{$op->{parms}}){
#      unless(exists $colmap->{$i}) { next }
#      my $index_of_parm = $colmap->{$i};
#      my $new_value = $table->{rows}->[0]->[$index_of_parm];;
#      $parm_map->{$i} = $new_value;
#    }
#    # now generate the cmdline like normal
#    my $final_cmd = apply_command($op, $colmap, $table->{rows}->[0]);
#
#    my @planned_operations;
#    my $first_col_name = [keys %{$cols}]->[0];
#    for my $i (0..$#{$cols->{$first_col_name}}) {
#      my $pipe_parm_format = $op->{pipe_parms};
#      for my $p (keys %$parm_map){
#        my $v = $parm_map->{$p};
#        unless(defined $v) { next }
#        $pipe_parm_format =~ s/<$p>/$v/g;
#      }
#      for my $var (@column_vars) {
#        my $v = $cols->{$var}->[$i];
#        $pipe_parm_format =~ s/<$var>/$v/g;
#      }
#      push @planned_operations, $pipe_parm_format;
#    }
#
#    $self->{PlannedOperations} = \@planned_operations;
#    $self->{PlannedPipeOperation} = $final_cmd;
#    $self->{PlannedPipeOp} = $op;
#    $self->{Mode} = 'PipeOperationsSummary';
#    return;
#  }
#
#  # generate summary of commands to be run
#  my @operations = map {
#    my $op = $_->[$colmap->{Operation}];
#    apply_command($self->{Commands}->{$op}, $colmap, $_);
#  } @{$table->{rows}};
#
#  # remove any that failed
#  $self->{PlannedOperations} = [grep { defined $_ } @operations];
#
#  $self->{Mode} = 'OperationsSummary';
#}

#sub ExecutePlannedOperations {
#  my ($self, $http, $dyn) = @_;
#  $self->{TotalPlannedOperations} = scalar @{$self->{PlannedOperations}};
#  $self->UpdateWaitingOnOps($http, $dyn);
#
#  $self->ExecuteNextOperation();
#}
sub UpdateWaitingOnOps {
  my ($self, $http, $dyn) = @_;
  my $total = $self->{TotalPlannedOperations};
  my $left = scalar @{$self->{PlannedOperations}};

  $self->{RemainingOpCount} = $left;

  $self->{Mode} = 'WaitingOnOperation';
  $self->AutoRefresh();
}

sub ExecuteNextOperation {
  my ($self) = @_;
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
    sub {
  my ($line) = @_;
      # save into output buffer
      push @{$self->{Results}}, $line;
    },
    sub {
      # queue the next one?
      say "finished op: $op";
      $self->UpdateWaitingOnOps();
      $self->ExecuteNextOperation();
    }
  );

}

sub ExecutePlannedPipeOperations {
  my ($self, $http, $dyn) = @_;
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
    sub {
  my ($return, $pid) = @_;
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

sub WaitingOnOperation {
  my ($self, $http, $dyn) = @_;
  $http->queue("<p>Waiting on operations to finish...</p>");
  my $total = $self->{TotalPlannedOperations};
  my $left = $self->{RemainingOpCount};
  if (defined $total and defined $left) {
    $http->queue("<p>Left: $left of: $total</p>");
  }
}

sub ResultsAreIn {
  my ($self, $http, $dyn) = @_;
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

sub SaveResultsAsCsv {
  my ($self, $http, $dyn) = @_;
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

sub PipeOperationsSummary {
  my ($self, $http, $dyn) = @_;
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

sub OperationsSummary {
  my ($self, $http, $dyn) = @_;
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

sub SelectTable {
  my ($self, $http, $dyn) = @_;
  $self->{SelectedTable} = $dyn->{index};
  # push new table onto the history stack
  $self->PushToHistory($dyn->{index});
  $self->DebouncedEntryBox_ResetAll;
  $self->{LoadedTables}->[$dyn->{index}]->clear_filters;
  $self->{Mode} = "TableSelected";
}
sub PushToHistory {
  my ($self, $index) = @_;
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
