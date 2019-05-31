package DbIf::Application;

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



method SpecificInitialize($session) {

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
        caption => 'List',
        op => 'SetMode',
        mode => 'ListQueries',
        sync => 'Update();'
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
      {
        caption => "Reports",
        op => 'SetMode',
        mode => 'Reports',
        sync => 'Update();'
      }
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

  if ($self->{user_has_permission}('superuser')) {
    $self->{MenuByMode}->{ActiveQuery} = [
      {
        caption => "Edit",
        op => 'SetMode',
        mode => 'EditQuery',
        sync => 'Update();'
      },
      {
        caption => "Clone",
        op => 'SetMode',
        mode => 'CloneQuery',
        sync => 'Update();'
      },
    ];
  }

  $self->{Mode} = "ListQueries";
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
  $self->{SavedQueriesDir} = "$user_dir/SavedQueries";
  unless(-d $self->{SavedQueriesDir}){
    unless(mkdir $self->{SavedQueriesDir}){
      die "Can't mkdir $self->{SavedQueriesDir}";
    }
  }
  $self->{PreparedReportsDir} = "$user_dir/PreparedReports";
  unless(-d $self->{PreparedReportsDir}){
    unless(mkdir $self->{PreparedReportsDir}){
      die "Can't mkdir $self->{PreparedReportsDir}";
    }
  }

  $self->{PreparedReportsCommonDir} = "$dbif_dir/PreparedReports";
  unless(-d $self->{PreparedReportsCommonDir}){
    unless(mkdir $self->{PreparedReportsCommonDir}){
      die "Can't mkdir $self->{PreparedReportsCommonDir}";
    }
  }


  my $temp_dir = "$self->{Environment}->{LoginTemp}/$self->{session}";
  unless(-d $temp_dir) { die "$temp_dir doesn't exist" }
  $self->{TempDir} = $temp_dir;
  $self->{UploadCount} = 0;
  # $self->{DbLookUp} = $self->{Environment}->{DbSpec};

  if (-e "$self->{SavedQueriesDir}/bindingcache.pinfo") {
    $self->{BindingCache} =
      retrieve("$self->{SavedQueriesDir}/bindingcache.pinfo");
    $self->StoreBindingCacheInDb;
    unlink("$self->{SavedQueriesDir}/bindingcache.pinfo");
  }
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

  $self->ConfigureTagGroups();

  $self->BackgroundMonitorForEmail;
}
method StoreBindingCacheInDb{
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
method RetrieveBindingCacheFromDb{
  my $bc;
  Query("GetUsersBoundVariables")->RunQuery(sub {
    my($row) = @_;
    my($user, $variable, $binding) = @$row;
    $bc->{$variable} = $binding;
  }, sub {}, $self->get_user);
  return $bc;
}
method CreateBindingCacheInfoForKeyInDb($key){
  my $user = $self->get_user;
  my $value = $self->{BindingCache}->{$key};
  Query("InsertUserBoundVariable")->RunQuery(sub{
  }, sub{}, $user, $key, $value);
}
method UpdateBindingValueInDb($key){
  my $user = $self->get_user;
  my $value = $self->{BindingCache}->{$key};
  Query("UpdateUserBoundVariable")->RunQuery(sub{
  },sub{}, $value, $user, $key);
}

method BackgroundMonitorForEmail() {
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
method Inbox($http, $dyn) {
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

method DisplayInboxItem($http, $dyn) {
  DEBUG "Setting selected Inbox Item to: $dyn->{message_id}";

  $self->{SelectedInboxItem} = $dyn->{message_id};
  $self->{Mode} = "InboxItem";
}

method DeleteAndDismiss($http, $dyn) {
  print STDERR "deleting inbox_item: $self->{SelectedInboxItem}\n" .
    "rm -rf $dyn->{path}\n";
  $self->{inbox}->SetDismissed($self->{SelectedInboxItem});
  rmtree($dyn->{path});
  $self->{Mode} = "Inbox";
}

method DismissInboxItemButtonClick($http, $dyn) {
  my $message_id = $dyn->{message_id};
  $self->{inbox}->SetDismissed($message_id);
  $self->{Mode} = "Inbox";
}

method FileInboxItemButtonClick($http, $dyn) {
  my $message_id = $dyn->{message_id};
  print STDERR "File Inbox Button Clicked ($message_id)\n";
  my $q = Query('InsertActivityInboxContent');
  $q->RunQuery(sub {}, sub{}, $self->{ActivitySelected}, $message_id);
  $self->{inbox}->SetDismissed($message_id);
  $self->{Mode} = "Inbox";
}

method ForwardInboxItemButtonClick($http, $dyn) {
  say STDERR "ForwardInboxItemButtonClick called";

  my $message_id = $dyn->{message_id};


  $self->{_ForwardInboxButtonClicked} = 1;
}

method DrawForwardForm($http, $dyn) {
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

method ForwardFormSubmitButtonClicked($http, $dyn) {
  my $forward_to_user = $dyn->{username};
  my $message_id = $self->{SelectedInboxItem};

  $self->{inbox}->Forward($message_id, $forward_to_user);
  delete $self->{_ForwardInboxButtonClicked};
}

method InboxItem($http, $dyn) {
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

method ConfigureTagGroups() {
  $self->{HTTP_APP_CONFIG} = $main::HTTP_APP_CONFIG;

  # Load the list of tag groups from the database
  my $db_handle = DBI->connect(Database('posda_queries'));

  my $qh = $db_handle->prepare(qq{
    select *
    from query_tag_filter
  });

  $qh->execute();
  my $rows = $qh->fetchall_arrayref();


  my %ht = map {
    $_->[0] => {map {
      $_ => 1
    } @{$_->[1]}}
  } @$rows;

  # DEBUG Dumper(\%ht);

  my $all_tag_groups = \%ht;

  $db_handle->disconnect();


  $self->{TagGroups} = {};

  for my $tag (keys %ht) {
    # if ($self->{user_has_permission}($tag)) {
      $self->{TagGroups}->{$tag} = $ht{$tag};
    # }
  }

  # titlize only after we have picked the correct ones
  # my $titlized = {};
  # for my $tag (keys %{$self->{TagGroups}}) {
  #   $titlized->{titlize($tag)} = $self->{TagGroups}->{$tag};
  # }

  # $self->{TagGroups} = $titlized;

  if ($self->{user_has_permission}('superuser')) {
    $self->{TagGroups}->{'.Unlimited'} = 1;
  }
  $self->{TagGroups}->{'.Show No Tags'} = 1;


  # just pick the first one
  $self->{SelectedTagGroup} = [sort keys %{$self->{TagGroups}}]->[0];

}

method MakeMenuByMode($mode) {
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

  my $active_tags = $self->GetActiveTagsAsList;
  my $background_buttons = get_background_buttons($active_tags);

  my @buttons_menu;

  for my $e (@$background_buttons) {
    push @buttons_menu, {
      caption => $e->[3],
      op => "OpenTableFreePopup",
      class_ =>$e->[2],
      cap_ => $e->[1],
      sync => 'Update();'
    };
  }
  if ($#buttons_menu > -1) {
    @final_menu = (@final_menu, { type => 'hr' }, @buttons_menu);
  }

  return \@final_menu;
}
method MenuResponse($http, $dyn) {
  my $menu = $self->MakeMenuByMode($self->{Mode});
  $self->MakeMenu($http, $dyn, $menu);
  # $self->DrawRoles($http, $dyn);
}

method SetMode($http, $dyn){
  $self->{Mode} = $dyn->{mode};
}

method ScriptButton($http, $dyn) {
  my $inbox_item = $self->{SelectedInboxItem};
  if($self->can("$dyn->{op}")){
    my $op = $dyn->{op};
    return $self->$op($http, $dyn);
  }
  print STDERR "Script button - Unknown op: $dyn->{op}\n";
}

method DownloadSpecifiedFileById($http, $dyn) {
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
method HeaderResponseTest($http, $dyn){
  $http->queue("Test");
}

method ContentResponse($http, $dyn) {
  # TODO: DrawHistory would preferrably be above the title on the page
  if($self->{Mode} eq "ScriptButton"){
    return($self->ScriptButtonResponse($http, $dyn));
  }
  unless ($self->{Mode} =~ /Inbox/) {
    $http->queue(qq{
      <div style="display: flex; flex-direction: row; align-items: flex-end; margin-bottom: 5px">
    });
    $self->DrawHistory($http, $dyn);
    $self->DrawRoles($http, $dyn);
    $http->queue(qq{</div>});
  }

  if ($self->can($self->{Mode})) {
    my $meth = $self->{Mode};
    $self->$meth($http, $dyn);
  } else {
    $http->queue("Unknown mode: $self->{Mode}");
  }
}
my $tag_ops = {
  "Set All Tags" => "SetAllTags",
  "Clear All Tags" => "ClearAllTags",
};
my $tag_mode_list = [
  "Queries With Any Selected Tag Set",
  "Queries With No Tags Set",
  "All Queries",
];
my $tag_modes;
for my $i (@$tag_mode_list){
  $tag_modes->{$i} = 1;
}
method SetAllTags($http, $dyn){
  for my $t (keys %{$self->{TagsState}}){
    $self->{TagsState}->{$t} = "true";
  }
}
method ClearAllTags($http, $dyn){
  for my $t (keys %{$self->{TagsState}}){
    $self->{TagsState}->{$t} = "false";
  }
}

method ToggleQueryFilter($http, $dyn) {
  $self->{QueryFilterDisplay} = not $self->{QueryFilterDisplay};
}

method SetHistorySelection($http, $dyn) {
  $self->SelectTable($http, { index => $dyn->{value} });
}
method GetLoadedTables() {
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

method DrawHistory($http, $dyn) {
  my @tables = $self->GetLoadedTables();

  $self->SelectByValue($http, {
    op => 'SetHistorySelection',
  });

  $http->queue(qq{<option value="">---History---</option>});

  for my $ti (@{$self->{TableHistory}}) {
    my $table = $tables[$ti];
    $http->queue(qq{<option value="$ti">$table</option>});
  }

  $http->queue(qq{
    </select>
    <p id="drawhistory_end"></p>
  });
}

method TagGroupSelector($http, $dyn) {
  $self->SelectByValue($http, {
    op => 'SetGroupSelector',
  });

  my $selected;
  # for my $tg (sort keys %{$self->{TagGroups}}) {
  for my $tg (@{$self->{AllowedFilters}}) {
    if ($self->{SelectedTagGroup} eq $tg) {
      $selected = q{selected="selected"};
    } else {
      $selected = '';
    }
    my $tg_name = titlize($tg);
    $http->queue(qq{<option value="$tg" $selected>$tg_name</option>});
  }

  $http->queue('</select>');
}

method SetGroupSelector($http, $dyn){
  my $value = $dyn->{value};
  $self->{SelectedTagGroup} = $value;

  my $group = $self->{TagGroups}->{$value};
#  DEBUG "Selected group: $value";
  # DEBUG Dumper($group);

}

method GetActiveTagsAsList() {
  if (not defined $self->{TagsState}) {
    return undef;
  }
  my @tags = grep {
    $self->{TagsState}->{$_} eq 'true';
  } keys %{$self->{TagsState}};

  return \@tags;
}

method TagSelection($http, $dyn){
  # (case-insenstivie alpha sort)
  my @tags = sort { "\L$a" cmp "\L$b" } keys %{$self->{TagsState}};

  if ($self->{SelectedTagGroup} eq '.Show No Tags') {
    @tags = ();
  } elsif ($self->{SelectedTagGroup} ne '.Unlimited') {
    @tags = grep { $self->{TagGroups}->{$self->{SelectedTagGroup}}->{$_} } @tags;
  }

  # break the list of tags into groups of 5
  my @chunks;
  push @chunks, [ splice @tags, 0, 5 ] while @tags;

  # $self->NotSoSimpleButton($http, {
  #   caption => "Toggle Tag List",
  #   op => "ToggleQueryFilter",
  #   sync => "Update();",
  #   class => "btn btn-warning"
  # });

  # display the list of selected filters, if requested
  # if (not $self->{QueryFilterDisplay}) {
    # get list of selected tags
    @tags = grep {
      $self->{TagsState}->{$_} eq 'true';
    } keys %{$self->{TagsState}};

    my $taglist = join(', ', @tags);

    $http->queue(qq{
      <p class="alert alert-info">
        Selected tags: <strong>$taglist</strong>
    });
    $self->NotSoSimpleButtonButton($http, {
      caption => "Clear Selection",
      op => "ClearAllSelections"
    });
    $http->queue(qq{
      </p>
    });
    # return;
  # }

  $http->queue(qq{
    <table class="table table-condensed">
  });
  for my $chunk (@chunks) {
    $http->queue(qq{<tr>});
    for my $tag (@$chunk) {
      my $pretty_tag = titlize($tag);

      my $checked = '';
      if ($self->{TagsState}->{$tag} eq 'true') {
        $checked = 'checked';
      }

      my $new_state = $checked eq 'checked'? 'false':'true';
      my $extra_class = $checked eq 'checked'? 'active':'';

      $http->queue(qq{
        <td>
          <div class="btn-group" data-toggle="buttons">
            <label class="btn btn-default $extra_class"
              onClick="javascript:PosdaGetRemoteMethod('CheckBoxChange', 'value=$tag&checked=$new_state');Update();"
            >
              <input type="checkbox" autocomplete="off" name="$tag" $checked>
              $pretty_tag
            </label>
          </div>
        </td>
      });
    }
    $http->queue(qq{</tr>});
  }
  $http->queue("</table>");
}

method ClearAllSelections($http, $dyn) {
  for my $tag (keys %{$self->{TagsState}}) {
    $self->{TagsState}->{$tag} = "false";
  }
}

method CheckBoxChange($http, $dyn){
  $self->{TagsState}->{$dyn->{value}} = $dyn->{checked};
}

method SetTagsFilter($http, $dyn){
  my $opt = $dyn->{value};
  if(exists $tag_modes->{$opt}){
    $self->{TagsFilterDisplay} = $opt;
  } elsif(exists $tag_ops->{$opt}) {
    print STDERR "Checking if self->can($opt)\n";
    my $op = $tag_ops->{$opt};
    if($self->can($op)){ $self->$op }
    else {
      print STDERR "$self->{path} can't $op\n";
    }
  }
};
method TagTest($query_tags_listref, $all_tags){
  my $query_tags = {};
  for my $qt (@$query_tags_listref) {
    $query_tags->{$qt} = 1;
  }
  my %selected_tags;
  for my $t (keys %$all_tags){
    if($self->{TagsState}->{$t} eq "true"){ $selected_tags{$t} = 1 }
  }
  my $num_selected = keys %selected_tags;
  my $num_tags = keys %$all_tags;
  my $tags_in_query = keys %$query_tags;
  my $FilterSpec = $self->{TagsFilterDisplay};
  if($FilterSpec eq "All Queries"){
    return 1;
  } elsif($FilterSpec eq "Queries With No Tags Set"){
    if($tags_in_query == 0) { return 1 } else { return 0 }
  } elsif ($FilterSpec eq "Queries With Any Selected Tag Set"){
    for my $t (keys %$query_tags){
      if(exists $selected_tags{$t}) { return 1 }
    }
    return 0;
  } elsif ($FilterSpec eq "Queries With All Selected Tags Set"){
    for my $t (keys %selected_tags){
      unless(exists $query_tags->{$t}) { return 0 }
    }
    return 1;
  } elsif ($FilterSpec eq "Queries With Only All Selected Tags Set"){
    for my $t (keys %selected_tags){
      unless(exists $query_tags->{$t}) { return 0 }
    }
    for my $t (keys %$query_tags){
      if(exists $selected_tags{$t}) { return 1 }
    }
    return 0;
  } else { return 1 }
}
method ListQueries($http, $dyn){
  my @q_list;
  # If tags are selected, return only queries with those tags

  if (not defined $self->{TagsState} or ref($self->{TagsState}) ne "HASH"){
    my $tags = PosdaDB::Queries->GetAllTags();
    $self->{TagsState} = {};
    for my $t (@$tags){
      $self->{TagsState}->{$t} = "false";
    }
  }

  # get simple list of selected tags
  my @selected_tags = grep {
    $self->{TagsState}->{$_} eq 'true';
  } keys %{$self->{TagsState}};

  if ($#selected_tags >= 0) {
    @q_list = sort @{PosdaDB::Queries->GetQueriesWithTags(\@selected_tags)};
  } elsif ($self->{SelectedTagGroup} eq '.Unlimited') {
    @q_list = sort @{PosdaDB::Queries->GetList()};
  }



  # $self->DrawRoles($http, $dyn);
  $self->DrawTabs($http, $dyn);
  $self->RefreshEngine($http, $dyn, qq{
    <p></p>
    <p>
      <?dyn="TagGroupSelector"?>
      <?dyn="TagSelection"?>
    </p>
    <table class="table table-striped table-condensed">
  });
  for my $i (@q_list){
    # unless($self->TagTest(PosdaDB::Queries->GetTags($i), $tags)){ next }
    $self->RefreshEngine($http, $dyn, qq{
      <tr>
        <td>$i</td>
        <td>
          <?dyn="NotSoSimpleButton" op="SetActiveQuery" caption="Set Active" query_name="$i" sync="Update();"?>
          <?dyn="NotSoSimpleButton" op="OpenBackgroundQuery" caption="Run in Background" query_name="$i" sync="Update();"?>
          <?dyn="DrawQueryModificationButtons" query_name="$i"?>
        </td>
      </tr>
    });
  }
  $self->RefreshEngine($http, $dyn, "</table>");
  $self->DrawSpreadsheetOperationList($http, $dyn, \@selected_tags);
}

method DrawRoles($http, $dyn) {
  my $all_roles = PosdaDB::Queries->GetRoles();
#  say STDERR Dumper($all_roles);

  my $roles = [];

  for my $role (@$all_roles) {
    if ($self->{user_has_permission}($role)) {
      push @$roles, $role;
    }
  }

  # Just pick the first one if one isn't selected
  if (not defined $self->{SelectedRole}) {
    $self->{SelectedRole} = $roles->[0];
  }

  $http->queue(qq{
    <div id="role_box" style="width: 25%">
    <label>Role:</label>
  });

  $self->SelectByValue($http, {
    op => 'SetRoleSelection',
  });

  for my $r (@$roles) {
    my $selected = '';
    if ($self->{SelectedRole} eq $r) {
      $selected = 'selected="selected"';
    }
    $http->queue(qq{<option value="$r" $selected>$r</option>});
  }

  $http->queue(qq{
    </select>
    </div>
    <p id="drawroles_end"></p>
  });
}

method SetRoleSelection($http, $dyn) {
  $self->{SelectedRole} = $dyn->{value};
}

method DrawTabs($http, $dyn) {
  my $tabs = PosdaDB::Queries->GetTabsByRole($self->{SelectedRole});

  # select the first tab as the default
  if (not defined $self->{SelectedTab}) {
    $self->SwitchToTab($http, { tab =>  $tabs->[0]->{query_tab_name} });
  }

  $http->queue(qq{
    <ul class="nav nav-tabs">
  });
  for my $tab (@{$tabs}) {
    my $tabname = titlize($tab->{query_tab_name});
    my $class = '';
    if ($self->{SelectedTab} eq $tab->{query_tab_name}) {
      $class = "active";
    }
    $http->queue(qq{ <li role="presentation" class="$class"> });

    $self->NotSoSimpleButton($http, {
      caption => $tabname,
      op => "SwitchToTab",
      tab => $tab->{query_tab_name},
      class => '',
      element => "a",
      sync => 'Update();',
      title => $tab->{query_tab_description}
    });

    $http->queue(qq{ </li> });
  }
  $http->queue(qq{ </ul> });
}

method SwitchToTab($http, $dyn) {
  DEBUG "Switching to tab: $dyn->{tab}";
  $self->{SelectedTab} = $dyn->{tab};

  my $filters = PosdaDB::Queries->GetTabFilters($dyn->{tab});
  my @allowed_filters = map { $_->{filter_name} } @$filters;
  $self->{AllowedFilters} = \@allowed_filters;
  # DEBUG Dumper(\@allowed_filters);

  # select the first one
  $self->SetGroupSelector($http, { value => $allowed_filters[0] });
}

method OpenTableLevelPopup($http, $dyn) {
print STDERR "In OpenTableFreePopup\n";
  my $table = $self->{LoadedTables}->[$self->{SelectedTable}];

  my $parms = { table => $table, button => $dyn->{cap_}};
  my $unique_val = "$parms";

  my $class = $dyn->{class_};
  $self->OpenPopup($class, "${class}_FullTable$unique_val", $parms);
}

my $table_free_seq = 0;
method OpenTableFreePopup($http, $dyn) {
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

method OpenDynamicPopup($http, $dyn) {
print STDERR "In OpenDynamicPopup\n";
for my $i (keys %{$dyn}){
  print STDERR "dyn{$i}: $dyn->{$i}\n";
}
  my $table = $self->{LoadedTables}->[$self->{SelectedTable}];
  if($table->{type} eq "FromQuery"){
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

method OpenPopup($class, $name, $params) {
#    say STDERR "OpenDynamicPopup, executing $class using params:";
#    print STDERR Dumper($params);


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

method OpenQuince($name, $params) {
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

method DrawSpreadsheetOperationList($http, $dyn, $selected_tags) {
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

method DrawQueryModificationButtons($http, $dyn) {
  if ($self->{user_has_permission}('superuser')) {
    $self->NotSoSimpleButton($http, {
      op => 'DeleteQuery',
      caption => 'Delete',
      query_name => $dyn->{query_name},
      sync => 'Update();',
      class => 'btn btn-info',
    });
    $self->NotSoSimpleButton($http, {
      op => 'SetEditQuery',
      caption => 'Edit',
      query_name => $dyn->{query_name},
      sync => 'Update();',
      class => 'btn btn-info',
    });
    $self->NotSoSimpleButton($http, {
      op => 'CloneQuery',
      caption => 'Clone',
      query_name => $dyn->{query_name},
      sync => 'Update();',
      class => 'btn btn-info',
    });
  }
}
method NewQuery($http, $dyn){
  $http->queue("New Queries Mode");
}
method SetEditQuery($http, $dyn){
  $self->{Mode} = "EditQuery";
  $self->{Query} = $dyn->{query_name};
  delete $self->{QueryResults};
  delete $self->{Input};
  $self->{LinkedTextField} = $self->{queries};
  $self->{query} = PosdaDB::Queries->GetQueryInstance($dyn->{query_name});
}

method SaveQuery($http, $dyn) {
  $self->{query}->Save();
  $http->queue(qq{
    <p class="alert alert-info">
      Query saved.
    </p>
  });
  $self->NotSoSimpleButton($http, {
    caption => "Return to query",
    op => "ResetQuery",
    sync => 'Update();'
  });
}

method CloneQuery($http, $dyn) {
  $self->{Mode} = 'RenderCloneQuery';
  $self->{clone_query} = $dyn->{query_name};
}

method RenderCloneQuery($http, $dyn) {
  $http->queue(qq{
    <h3>Clone Query: $self->{clone_query}</h3>
    <div class="col-md-4">
      <p class="alert alert-warning">
        Every query must have a unique name.
      </p>
      <div class="form-group">
        <label>Name for new query:</label>
        <input class="form-control" id="newName" value="$self->{clone_query}">
      </div>
  });
  $self->NotSoSimpleButtonButton($http, {
      caption => 'Cancel',
      op => 'SetMode',
      mode => 'ListQueries'
  });
  $self->SubmitValueButton($http, {
      caption => 'Save',
      element_id => 'newName',
      op => 'SaveCloneQuery',
      class => 'btn btn-primary',
      #extra => $extra
  });

  $http->queue(qq{
    </div>
  });
}

method SaveCloneQuery($http, $dyn) {
  my $new_name = $dyn->{value};
  my $old_name = $self->{clone_query};

  PosdaDB::Queries::Clone($old_name, $new_name);
  $self->{Mode} = 'ListQueries';
}

method SmallInputBoxWithAddButton($http, $dyn) {
  my $id = $dyn->{id};
  my $op = $dyn->{op};
  my $extra = $dyn->{extra};

  $http->queue(qq{
    <form onSubmit="return false;" class="input-group col-md-4">
      <input id="$id" type="input" class="form-control">
      <span class="input-group-btn">
  });
  $self->SubmitValueButton($http, {
      caption => 'Add',
      element_id => $id,
      op => $op,
      extra => $extra
  });
  $http->queue(qq{
      </span>
    </form>
  });
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

method DeleteFromEditList($http, $dyn) {
  my $source = $dyn->{name};
  my $value = $dyn->{value};

  DEBUG "Deleting '$value' from $source";

  my @idx = grep {
    $self->{query}->{$source}->[$_] eq $value
  } 0..$#{$self->{query}->{$source}};

  splice @{$self->{query}->{$source}}, $idx[0], 1;

}

method MoveEditListElementUp($http, $dyn) {
  my $source = $dyn->{name};
  my $value = $dyn->{value};

  # find the index of the element to move
  my @idx = grep {
    $self->{query}->{$source}->[$_] eq $value
  } 0..$#{$self->{query}->{$source}};

  my $index = $idx[0];

  if ($index < 1) {
    # can't help you!
    return;
  }

  my $new_index = $index - 1;
  my $temp_val = $self->{query}->{$source}->[$new_index];
  $self->{query}->{$source}->[$new_index] = $self->{query}->{$source}->[$index];
  $self->{query}->{$source}->[$index] = $temp_val;

}

method AddTextField($http, $dyn) {
  $self->{query}->{$dyn->{index}} = $dyn->{value};
}

### End Delegated Methods

method EditQuery($http, $dyn){
  my $descrip = {
    args => {
      caption => "Arguments",
      struct => "array",
    },
    columns =>{
      caption => "Columns Returned",
      struct => "array",
    },
    description => {
      caption=> "Description",
      struct => "textarea",
      rows => 5,
      cols => 100,
    },
    query => {
      caption=> "Query Text",
      struct => "textarea",
      rows => 30,
      cols => 100,
    },
    schema => {
      caption=> "Schema",
      struct => "text",
    },
    name => {
      caption=> "Query Name",
      struct => "text",
    },
    tags => {
      caption => "Tags",
      # struct => "hash key list",
      struct => "array",
    },
  };
  $self->RefreshEngine($http, $dyn,
    'Editing Query: ' .
    '<?dyn="NotSoSimpleButton" ' .
    'caption="Save" ' .
    'op="SetMode" ' .
    'mode="SaveQuery" ' .
    'sync="Update();" ' .
    'class="btn btn-primary"?>&nbsp;' .
    '<?dyn="NotSoSimpleButton" ' .
    'caption="Cancel" ' .
    'op="SetMode" ' .
    'mode="ListQueries" ' .
    'sync="Update();" ' .
    'class="btn btn-info"?>&nbsp;' .
    '<?dyn="NotSoSimpleButton" ' .
    'caption="Refresh" ' .
    'op="NoOp" ' .
    'sync="Update();" ' .
    'class="btn btn-info"?>'
  );
  $http->queue(q{<table class="table">});
  for my $i (
    "name", "schema", "description", "tags", "columns", "args", "query"
  ){
    my $d = $descrip->{$i};
    $http->queue(qq{
      <tr>
        <td align="right" valign="top">
          <strong>$d->{caption}</strong>
        </td>
        <td align="left" valign = "top">
    });

    if($d->{struct} eq "text"){
      unless(exists $self->{LinkedTextField}->{$i}){
        $self->{LinkedTextField}->{$i} = $self->{query}->{$i};
      }
      $self->DelegateEntryBox($http, {
          op => 'AddTextField',
          value => $self->{query}->{$i},
          index => $i,
      });
    }

    if($d->{struct} eq "array"){
      $http->queue(qq{
        <table class="table table-condensed">
      });
      for my $j (@{$self->{query}->{$i}}){
        $http->queue(qq{ <tr><td>$j</td><td> });
        $self->NotSoSimpleButton($http, {
            op => 'DeleteFromEditList',
            caption => 'del',
            name => $i,
            value => $j,
            sync => 'Update();'
        });
        $http->queue(qq{ </td><td> });
        $self->NotSoSimpleButton($http, {
            op => 'MoveEditListElementUp',
            caption => 'up',
            name => $i,
            value => $j,
            sync => 'Update();'
        });
        $http->queue(qq{ </td><td> </tr> });
      }
      $http->queue("<tr><td>");
      $http->queue("</table>");
      $self->SmallInputBoxWithAddButton($http, {
        id => "new$i",
        op => 'AddToEditList',
        extra => $i
      });
    } elsif($d->{struct} eq "hash key list"){
      # TODO: This really only works for tags, not for generic 'hash key list'!
      my @keys = sort @{$self->{query}->{tags}};
      $self->{query}->{tags} = \@keys; # Save it back so indexes make sense!

      $http->queue(qq{
        <table class="table table-condensed">
      });
      for my $k (0 .. $#keys){
        $http->queue(qq{
          <tr>
            <td>$keys[$k]</td>
            <td>
        });
        $self->NotSoSimpleButton($http, {
          caption => "del",
          class => "btn btn-danger",
          op => "DeleteHashKeyList",
          type => $i,
          index => $k,
          value => $keys[$k],
          sync => "Update();"
        });
        $http->queue(qq{
            </td>
          </tr>
        });
      }
      $http->queue(qq{
        </table>
      });
      $self->SmallInputBoxWithAddButton($http, {
        id => 'newTag',
        op => 'AddToHashKeyList',
        extra => $i
      });
    } elsif($d->{struct} eq "textarea"){
        $self->DelegateTextArea($http, {
          id => "$i",
          op => "TextAreaChanged",
          value => $self->{query}->{$i},
          rows => $d->{rows},
          cols => $d->{cols}
      });
    }
    $self->RefreshEngine("</td></tr>");
  }
  $self->RefreshEngine($http, $dyn, '</table>');
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

method SetActiveQuery($http, $dyn){
  $self->{Mode} = "ActiveQuery";
  $self->{Query} = $dyn->{query_name};
  delete $self->{QueryResults};
  delete $self->{Input};
  $self->{query} = PosdaDB::Queries->GetQueryInstance($dyn->{query_name});
}
method ActiveQuery($http, $dyn){
#  DEBUG @_;
  my $from_seen = 0;
  my $descrip = {
    args => {
      caption => "Arguments",
      struct => "array",
      special => "form"
    },
    columns =>{
      caption => "Columns Returned",
      struct => "array",
      special => "pre-formatted-list",
    },
    description => {
      caption=> "Description",
      struct => "text",
      special => "markdown",
    },
    query => {
      caption=> "Query Text",
      struct => "text",
      special => "pre-formatted"
    },
    schema => {
      caption=> "Schema",
      struct => "text",
      special => "",
    },
    name => {
      caption=> "Query Name",
      struct => "text",
      special => "",
    },
    tags => {
      caption => "Tags",
      struct => "hash key list",
    },
  };
  $http->queue(q{<table class="table">});
  for my $i (
    "name", "schema", "description", "tags", "columns", "args", "query"
  ){
    #DEBUG "i = $i";
    my $d = $descrip->{$i};
    $http->queue(qq{
      <tr>
        <td align="right" valign="top">
          <strong>$d->{caption}</strong>
        </td>
        <td align="left" valign = "top">
    });
    if($d->{struct} eq "text"){
      #DEBUG 'text';
      if( defined($d->{special}) && $d->{special} eq "pre-formatted"){
         $self->RefreshEngine($http, $dyn,
           "<pre><code class=\"sql\">$self->{query}->{$i}</code></pre>");
      } elsif (defined $d->{special} && $d->{special} eq "markdown") {
         $self->RefreshEngine($http, $dyn, markdown($self->{query}->{$i}));
      } else {
         $self->RefreshEngine($http, $dyn, "$self->{query}->{$i}");
      }
    }
    if($d->{struct} eq "array"){
      #DEBUG 'array';
      if($d->{special} eq "pre-formatted-list"){
        #DEBUG 'pre-formatted-list';

        $http->queue(qq{
          <table class="table table-condensed">
        });
        for my $j (@{$self->{query}->{$i}}){
          $self->RefreshEngine($http, $dyn, "<tr><td>$j</td></tr>");
        }
        $self->RefreshEngine($http, $dyn, "</table>");

      } elsif($d->{special} eq "form"){
        #DEBUG 'form';
        $self->RefreshEngine($http, $dyn, "<table class=\"table\">");
        for my $arg (@{$self->{query}->{args}}){
          # preload the Input if arg is in cache
          if (defined $self->{BindingCache}->{$arg} and
              not defined $self->{Input}->{$arg}) {
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
          if ($arg eq 'from') {
            $from_seen = 1;
          }
          if ($arg eq 'to' and $from_seen == 1) {
            $self->DrawWidgetFromTo($http, $dyn);
          }
        }
        $http->queue('</table>');
        $http->queue('<p>');
        $self->NotSoSimpleButton($http, {
            caption => "Query and Display Results",
            op => "MakeQuery",
            sync => "Update();",
            class => "btn btn-primary",
            then => "results"
        });
        $http->queue('</p>');
        $http->queue('<p>');
        $self->NotSoSimpleButton($http, {
            caption => "Query and Go to Tables",
            op => "MakeQuery",
            sync => "Update();",
            class => "btn btn-default",
            then => "tables"
        });
        $http->queue('</p>');
      }
    } elsif($d->{struct} eq "hash key list"){
      # TODO: This is both not a hash key list, AND it only works
      # for tags!
      $http->queue(join(', ', @{$self->{query}->{tags}}));
    }
    $self->RefreshEngine("</td></tr>");
  }
  $self->RefreshEngine($http, $dyn, '</table>');
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

method MakeQuery($http, $dyn){
  # ensure the schema is valid
  if ($self->{query}->{connect} eq 'invalid database name') {
    $self->{ErrorMessage} = 'Requested schema does not exist!';
    $self->{Mode} = 'QueryError';
    return;
  }

  my $query = {};
  my $then = $dyn->{then};

  $query->{bindings} = $self->GetBindings();
  $self->{query}->{bindings} = $query->{bindings};
  $query->{name} = $self->{Query};

  $self->{Mode} = "QueryWait";

  $self->{query}->SetAsync();

  $self->{query_rows} = [];

  my $invoked_id = Posda::QueryLog::query_invoked($self->{query}, $self->get_user);
  $self->{query}->{invoked_id} = $invoked_id;

  $self->{query}->RunQuery(
    func($row) {
      push @{$self->{query_rows}}, $row;
    },
    $self->QueryEnd($query, $then, $invoked_id),
    func($message) {
      $self->{Mode} = "QueryError";
      $self->{ErrorMessage} = $message;
      $self->AutoRefresh;
    },
    @{$query->{bindings}}
  );

}

method QueryError($http, $dyn) {
  $http->queue(qq{
    <div>
      <p class="alert alert-danger">Error executing query!</p>
      <p>Query that was executing: $self->{Query}</p>
      <pre>$self->{ErrorMessage}</pre>
    </div>
  });

  $self->NotSoSimpleButton($http, {
    caption => "Return to query",
    op => "ResetQuery",
    sync => 'Update();'
  });
}

method ResetQuery($http, $dyn) {
  $self->SetActiveQuery($http, {query_name => $self->{Query}});
}

method QueryWait($http, $dyn) {
  $http->queue(qq{
    <div class="alert alert-info">
      Executing query...
      <div class="spinner" style="display:inline-block;margin-left:30px"></div>
    </div>
  });
}

method QueryEnd($query, $then, $invoked_id) {
  my $start_time = time;
  my $sub = sub {
    if($self->{Mode} eq "QueryWait"){
      $self->AutoRefresh;
    }
    Posda::QueryLog::query_finished($invoked_id, $#{$self->{query_rows}} + 1);

    if($self->{query}->{query} =~ /^select/){
      my $struct = { Rows => $self->{query_rows} };

      if ($then eq 'results') {
        return $self->CreateAndSelectTableFromQuery($self->{query}, $struct, $start_time);
      } else {
        $self->CreateTableFromQuery($self->{query}, $struct, $start_time);
        $self->{Mode} = "Tables";
      }
    } else {
      DEBUG "UpdateInsertCompleted!\n";
      return $self->UpdateInsertCompleted($query, $self->{query_rows});
    }

    # } else {
    #   if($self->{Mode} eq "QueryWait"){
    #     $self->{Mode} = "QueryFailed";
    #   }
    #   unless(exists $self->{FailedQueries}){ $self->{FailedQueries} = [] }
    #   push @{$self->{FailedQueries}}, {
    #     query => $query,
    #     result => $struct
    #   };
    # }
  };
  return $sub;
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
  # DEBUG Dumper($details);

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
        $self->{BindingCache}->{$param}->{to_parameter_name} eq
        $h->{param}->{from_column_name}
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
    $self->{title} = "Database Interface (<small>$dyn->{value}: $activity_name</small>)";
    $self->AutoRefreshOne;
  } else {
    $self->{title} = "Database Interface (<small>no activity</small>)";
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
  my $q = Query('GetOpenActivities');
  my %Activities;
  $self->{Activities} = {};
  $q->RunQuery(sub {
    my($row) = @_;
    my($act_id, $b_desc, $created, $who, $closed) = @$row;
    $Activities{$act_id} = {
      user => $who,
      closed => $closed,
      opened => $created,
      desc => $b_desc
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
  $self->DrawActivityTaskStatus($http, $dyn);
  $http->queue(qq{</div><hr>});
  my $method = $self->{ActivityModes}->{$self->{ActivityModeSelected}};
  if($self->can($method)){
    $self->$method($http, $dyn);
  } else {
    $http->queue("method \"$method\" is not yet defined\n");
  }
}
method DrawActivitySelected($http, $dyn){
  $http->queue("Activity $self->{ActivitySelected}: ");
  $http->queue("$self->{Activities}->{$self->{ActivitySelected}}->{desc}");
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
    [1, "Inbox"],
    [2, "ActivityOperations"],
    [3, "Queries"],
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
    $http->queue("<div width=200><ul>");
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
    $http->queue("</ul></div>");
    $self->InvokeAfterDelay("AutoRefresh", 5);
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
    if($next_tp->[4] ge $when && $next_tp->[4] le $ended){
      $tp = $next_tp->[3];
      $tp_files = $next_tp->[7];
      $next_tp = shift(@time_points_cp);
    } else {
      $tp = undef;
      $tp_files = undef;
    }
    $http->queue("<tr>");
    $http->queue("<td>$id</td>");
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
    [ "PhiPublicScanTp", "Public Phi Scan Based on Current TP by Activity", 1, 0],
    [ "SummarizeStructLinkage", "Summarize Structure Set Linkages for a File", 1, 1],
    [ "BackgroundDciodvfyTp", "Run Dciodvfy for Time Point", 1, 2],
    [ "CondensedActivityTimepointReport", "Produce Condensed Activity Timepoint Report", 1, 3],
    [ "AnalyzeSeriesDuplicates", "Analyze Series With Duplicates", 1, 4],
    [ "FilesInTpNotInPublic", "Find Files in Tp, not in Public", 1, 5],
    [ "CompareSopsInTpToPublic", "Compare Corresponding SOPs in Time Point to Public", 1, 6],
    [ "AnalyzeSeriesDuplicatesForTimepoint", "Analyze Series In Time Point with Duplicates", 2, 0],
    [ "CompareSopsTpPosdaPublic", "Compare Sops in Timepoint, Posda, and Public", 2, 1],
    [ "BackgroundPrivateDispositionsTp", "Apply Background Dispositions To Timepoint (non baseline date)", 2, 2],
    [ "BackgroundPrivateDispositionsTpBaseline", "Apply Background Dispositions To Timepoint (baseline date)", 2, 3],
    [ "CompareSopsTpPosdaPublicLike", "Compare Sops in Timepoint, Posda, and Public like Collection", 2, 4],
    [ "UpdateActivityTimepoint", "Update Activity Timepoint", 2, 5],
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
      $self->NotSoSimpleButton($http, {
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
      $self->NotSoSimpleButton($http, {
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
      $self->NotSoSimpleButton($http, {
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
  my $class = "Posda::ProcessPopup";
  eval "require $class";
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
  if(exists($self->{SelectFromCurrentForeground})){
    return $self->SelectFromCurrentForeground($http, $dyn);
  }
  unless (exists($self->{SelectedNewQuery})){
    $http->queue(qq{
      <div style="display: flex; flex-direction: row; align-items: flex-end; margin-bottom: 5px">
    });
    $self->DrawCurrentForegroundQueriesSelector($http, $dyn);
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
  delete $self->{SelectFromCurrentForeground};
  $self->NotSoSimpleButton($http, {
    op => "ClearCurrentForegroundSelector",
    caption => "clear",
    sync => "Update();",
  });
  $http->queue('<table class="table table-striped table-condensed">');
  $http->queue("<caption>Current Foreground Queries</caption>");
  $http->queue("<tr><th>id</th><th>query</th><th>when</th><th>state</th><th>rows</th><th>op</th></tr>");
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
      op => "DeleteCurrentForegroundQuery",
      caption => "dismiss",
      index => $k,
      sync => "Update();",
    });
    $self->NotSoSimpleButton($http, {
      op => "SelectCurrentForegroundQuery",
      caption => "select",
      index => $k,
      sync => "Update();",
    });
    $http->queue("</td>");
    $http->queue("</tr>");
  }
  $http->queue("</table>");
  $http->queue("</div>");
}
method DeleteCurrentForegroundQuery($http, $dyn){
  my $k = $dyn->{index};
  delete $self->{ForegroundQueries}->{$k};
  my $num_queries = keys %{$self->{ForegroundQueries}};
  if($num_queries == 0){
    delete $self->{SelectFromCurrentForeground};
  }
}  
method SelectCurrentForegroundQuery($http, $dyn){
  my $k = $dyn->{index};
  $self->{NewQueryToDisplay} = $k;
}  

method ClearCurrentForegroundSelector($http, $dyn){
  delete $self->{SelectFromCurrentForeground};
}
method DrawQueryListTypeSelector($http, $dyn){
  unless(defined $self->{NewActivityQueriesType}->{query_type}){
    $self->{NewActivityQueriesType}->{query_type} = "recent";
  }
  $http->queue("<div width=100>");
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
method DrawQuerySearchForm($http, $dyn){
  if($self->{NewActivityQueriesType}->{query_type} eq "search"){
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
method ClearQueries($http, $dyn){
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
method SearchQueries($http, $dyn){
  my @clauses;
  if(exists($self->{NewArgList}) && ref($self->{NewArgList}) eq "ARRAY"){
    for my $i (@{$self->{NewArgList}}){ push @clauses, $i }
  } if(exists($self->{NewColList}) && ref($self->{NewColList}) eq "ARRAY"){ for my $i (@{$self->{NewColList}}){ push @clauses, $i }
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
method SetNewArgList($http, $dyn){
  $self->{NewArgListText} = $dyn->{value};
  my @a_list = split(/\s*,\s*/, $dyn->{value});
  my @clauses;
  for my $a (@a_list){
    push(@clauses, "('$a' = ANY(args))");
  }
  $self->{NewArgList} = \@clauses;
}
method SetNewColList($http, $dyn){
  $self->{NewColListText} = $dyn->{value};
  my @a_list = split(/\s*,\s*/, $dyn->{value});
  my @clauses;
  for my $a (@a_list){
    push(@clauses, "('$a' = ANY(columns))");
  }
  $self->{NewColList} = \@clauses;
}
method SetNewTableMatchList($http, $dyn){
  $self->{NewTableMatchListText} = $dyn->{value};
  my @a_list = split(/\s*,\s*/, $dyn->{value});
  my @clauses;
  for my $a (@a_list){
    push(@clauses, "(query like '%$a%')");
  }
  $self->{NewTableMatchList} = \@clauses;
}
method SetNewNameMatchList($http, $dyn){
  $self->{NewNameMatchListText} = $dyn->{value};
  my @a_list = split(/\s*,\s*/, $dyn->{value});
  my @clauses;
  for my $a (@a_list){
    push(@clauses, "(name like '%$a%')");
  }
  $self->{NewNameMatchList} = \@clauses;
}
method DrawQueryListOrResults($http, $dyn){
  if($self->{NewActivityQueriesType}->{query_type} eq "search"){
    $self->DrawQueryListOrResultsSearch($http, $dyn);
  } else {
    $self->DrawQueryListOrResultsRecent($http, $dyn);
  }
}
method DrawQueryListOrResultsSearch($http, $dyn){
  if(exists($self->{NewQueryResults})){
    $self->DrawNewQueryResults($http, $dyn);
  } else {
    $self->DrawQueryListOrSelectedQuerySearch($http, $dyn);
  }
}
method DrawQueryListOrSelectedQuerySearch($http, $dyn){
  if(exists $self->{SelectedNewQuery}){
    $self->DrawNewQuery($http, $dyn);
  } else {
    $self->DrawQueryListSearch($http, $dyn);
  }
}
method RunNewQuery($http, $dyn){
  $self->{SelectedNewQuery} = $dyn->{query_name};
}
method DrawNewQuery($http, $dyn){
#  $http->queue("NewQuery goes here ($self->{SelectedNewQuery})");
  my $query;
  if($self->{NewActivityQueriesType}->{query_type} eq "search"){
    $query = $self->{NewQueryListSearch}->{$self->{SelectedNewQuery}};
  } else {
    $query = $self->{NewQueriesByName}->{$self->{SelectedNewQuery}};
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
  $query->SetAsync();
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
  $self->{WaitingForQueryCompletion} = $msg;;
  my $q_pack = $self->{ForegroundQueries}->{$guid};
  $query->RunQuery(
    func($row){
      push @{$q_pack->{rows}}, $row;
    },
    func(){
      $q_pack->{status} = "done";
      Posda::QueryLog::query_finished($invoked_id, $#{$q_pack->{rows}} + 1);
      if(exists $self->{WaitingForQueryCompletion}){
        $self->{NewQueryToDisplay} = $guid;
        $self->AutoRefresh;
        delete $self->{WaitingForQueryCompletion};
      }
    },
    func($msg){
      $q_pack->{status} = "error";
      $q_pack->{error_msg} = $msg;
      if(exists $self->{WaitingForQueryCompletion}){
        $self->{NewQueryToDisplay} = $guid;
        $self->AutoRefresh;
        delete $self->{WaitingForQueryCompletion};
      }
    },
    @args);
}
sub ClearNewQuery{
  my($self, $http, $dyn) = @_;
  delete $self->{SelectedNewQuery};
}
sub DisplayNewQueryError{
  my($self, $http, $dyn, $q) = @_;
  $http->queue(qq{
    <div style="display: flex; flex-direction: column; align-items: flex-beginning; margin-bottom: 5px">
});
  $http->queue("<h1>Error</h1><pre>$q->{error_msg}</pre>");
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
  if($SFQ->{status} eq "error"){
    return $self->DisplayNewQueryError($http, $dyn, $SFQ);
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
    caption => "back",
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
  my $url = $self->RadioButtonSync($index,"filtered",
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


  $http->queue('<table class="table table-striped table-condensed">');
  $http->queue("<tr>");
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
  my $num_rows = @{$working_rows};
  my $max_row = $SFQ->{first_row} + $SFQ->{rows_to_show} - 1;
  if($max_row > $num_rows) { $max_row = $#{$working_rows} }
  for my $i ($SFQ->{first_row} .. $max_row){
    $http->queue("<tr>");
    my $row = $working_rows->[$i];
    if(ref($row) eq 'ARRAY'){
      for my $j (@$row){
        if(defined $j){
          $http->queue("<td>$j</td>");
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
  $http->queue('<caption>Most common  queries</caption>');
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
  opendir(DIR, "/nas/public/posda/cache/linked_for_download");
  while(my $dir = readdir(DIR)){
    unless(-d "/nas/public/posda/cache/linked_for_download/$dir"){
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
      -d "/nas/public/posda/cache/linked_for_download/" .
         $self->{SelectedDownloadSubdir}
    ){
      $self->{SelectedDownloadSubdir} = $dirs[0];
    }
    $self->{DownloadTar} =
      "/nas/public/posda/cache/linked_for_download/" .
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

func apply_command($command, $colmap, $row) {
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

    # now generate the cmdline like normal
    my $final_cmd = apply_command($op, $colmap, $table->{rows}->[0]);

    my @planned_operations;
    my $first_col_name = [keys %{$cols}]->[0];
    for my $i (0..$#{$cols->{$first_col_name}}) {
      my $pipe_parm_format = $op->{pipe_parms};
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

method AddNicknames($http, $dyn){
  my $table_n = $dyn->{index};
  $self->{SelectedTable} = $dyn->{index};
  my $table = $self->{LoadedTables}->[$table_n];
  my @cols;
  my $rs;
  if($table->{type} eq "FromCsv"){
    @cols = @{$table->{rows}->[0]};
    $rs = 1;
  } elsif($table->{type} eq "FromQuery"){
    @cols = @{$table->{query}->{columns}};
    $rs = 0;
  }
  my %nn_types;
  for my $ii (0 .. $#cols){
    my $i = $cols[$ii];
    if($i eq "series_instance_uid"){
      $nn_types{series_nn} = $ii;
    } elsif($i eq "study_instance_uid") {
      $nn_types{study_nn} = $ii;
    } elsif($i eq "sop_instance_uid") {
      $nn_types{sop_nn} = $ii;
    } elsif($i eq "file_id") {
      $nn_types{file_nn} = $ii;
    }
  }
  $self->{Mode} = "LookingUpNicknames";
  my $file_where;
  if(exists $nn_types{file_nn}){
print STDERR "Fetching File NN\n";
    my $col_n = $nn_types{file_nn};
    $file_where = "where file_id in (";
    for my $i ($rs .. $#{$table->{rows}}){
      $file_where .= "$table->{rows}->[$i]->[$col_n]";
      unless($i == $#{$table->{rows}}){ $file_where .= ", " }
    }
    $file_where .= ")";
    $self->NicknamesByFileId($file_where, "file_nn", $table_n);
  }
  my $sop_where;
  if(exists $nn_types{sop_nn}){
print STDERR "Fetching SOP NN\n";
    my $col_n = $nn_types{sop_nn};
    $sop_where = "where sop_instance_uid in (";
    for my $i ($rs .. $#{$table->{rows}}){
      $sop_where .= "'$table->{rows}->[$i]->[$col_n]'";
      unless($i == $#{$table->{rows}}){ $sop_where .= ", " }
    }
    $sop_where .= ")";
    $self->SeriesStudyBySop($sop_where, "sop_nn", $table_n);
  }
  my $series_where;
  if(exists $nn_types{series_nn}){
print STDERR "Fetching Series NN\n";
    my $col_n = $nn_types{series_nn};
    $series_where = "where series_instance_uid in (";
    for my $i ($rs .. $#{$table->{rows}}){
      $series_where .= "'$table->{rows}->[$i]->[$col_n]'";
      unless($i == $#{$table->{rows}}){ $series_where .= ", " }
    }
    $series_where .= ")";
    $self->StudiesBySeries($series_where, "series_nn", $table_n);
  }
  my $study_where;
  if(exists $nn_types{study_nn}){
print STDERR "Fetching Study NN\n";
    my $col_n = $nn_types{study_nn};
    $study_where = "where study_instance_uid in (";
    for my $i ($rs .. $#{$table->{rows}}){
      $study_where .= "'$table->{rows}->[$i]->[$col_n]'";
      unless($i == $#{$table->{rows}}){ $study_where .= ",\n" }
    }
    $study_where .= ")";
    $self->NicknamesByStudy(
      $study_where, "study_nn", $table_n);
  }
}
method NicknamesByStudy($study_where, $nn_type, $table_n){
print STDERR "NicknamesByStudy(study_where, $nn_type, $table_n)\n";
  my $q = {
    query => "select * from study_nickname\n" . $study_where,
    schema => "posda_nicknames",
    db_type => "postgres",
    columns => [
      "study_instance_uid", "project_name", "site_name",
      "subj_id", "study_nickname"
    ],
    args => [],
    bindings => [],
    name => "Study nickname by study_uids",
    description => "",
    connect => Database('posda_nicknames')
  };
  $self->SerializedSubProcess($q, "SubProcessQuery.pl",
    $self->StudyNnsFetchedByStudy($nn_type, $table_n));
}
method StudyNnsFetchedByStudy($nn_type, $table_n){
  my $sub = sub {
    my($status, $struct) = @_;
print STDERR "StudyNnsFetched::sub($nn_type, $table_n)\n";
    if($status eq "Succeeded" && $struct->{Status} eq "OK"){
      my %study_info;
      for my $i (@{$struct->{Rows}}){
        $study_info{$i->[0]}->{project_name} = $i->[1];
        $study_info{$i->[0]}->{site_name} = $i->[2];
        $study_info{$i->[0]}->{subj_id} = $i->[3];
        $study_info{$i->[0]}->{study_nickname} = $i->[4];
      }
      $self->RenderNicknames(\%study_info, {}, {}, {}, {}, $nn_type, $table_n);
    } else {
      $self->AutoRefresh;
      $self->{Mode} = "ERROR";
      $self->{ErrorInfo} = {
        status => $status,
        struct => $struct,
      };
    }
  };
  return $sub;
}
method NicknamesByFileId($f_where, $nn_type, $table_n){
  my $q = {
    query => "select\n" .
             "  distinct file_id, digest, sop_instance_uid, " .
             "  series_instance_uid, study_instance_uid " .
             "from\n" .
             "  file natural left join file_sop_common\n" .
             "  natural left join file_series\n" .
             "  natural left join file_study\n" .
             $f_where,
     columns => [ "file_id", "digest", "sop_instance_uid",
       "series_instance_uid", "study_instance_uid"],
     args => [ ],
     binding => [ ],
     schema => "posda_files",
     db_type => "postgres",
     name => "get_file_info",
     description => "",
     connect => Database('posda_files')
  };
  $self->SerializedSubProcess($q, "SubProcessQuery.pl",
    $self->FileIdsFetched($nn_type, $table_n));
}
method FileIdsFetched($nn_type, $table_n){
  my $sub = sub {
    my($status, $struct) = @_;
    if($status eq "Succeeded" && $struct->{Status} eq "OK"){
      my %file_ids;
      for my $i (@{$struct->{Rows}}){
        $file_ids{$i->[0]}->{digest} = $i->[1];
        $file_ids{$i->[0]}->{sop_instance_uid} = $i->[2];
        $file_ids{$i->[0]}->{series_instance_uid} = $i->[3];
        $file_ids{$i->[0]}->{study_instance_uid} = $i->[4];
      }
      my $q_t = "select\n" .
        "  project_name, site_name, subj_id, file_digest,\n" .
        "  sop_nickname_copy as sop_nickname, version_number\n" .
        "from file_nickname\n" .
        "where file_digest in (";
      for my $i (0 .. $#{$struct->{Rows}}){
        $q_t .= "'$struct->{Rows}->[$i]->[1]'";
        unless($i == $#{$struct->{Rows}}) { $q_t .= ", " }
      }
      $q_t .= ")";
      my $q = {
        query => $q_t,
        columns => ["project_name", "site_name", "subj_id",
          "sop_nickname", "version_number", "file_digest"],
        args =>[],
        bindings =>[],
        schema => "posda_nicknames",
        db_type => "postgres",
        name => "get_file_nicknames",
        description => "",
        connect => Database('posda_nicknames')
      };
      $self->SerializedSubProcess($q, "SubProcessQuery.pl",
        $self->FileNnsFetched($nn_type, \%file_ids, $table_n));
    } else {
      $self->AutoRefresh;
      $self->{Mode} = "ERROR";
      $self->{ErrorInfo} = {
        status => $status,
        struct => $struct,
      };
    }
  };
  return $sub;
}
method FileNnsFetched($nn_type, $f_info, $table_n){
  my $sub = sub {
    my($status, $struct) = @_;
    if($status eq "Succeeded" && $struct->{Status} eq "OK"){
      my %dig_info;
      for my $i (@{$struct->{rows}}){
        $dig_info{$i->[3]}->{project_name} = $i->[0];
        $dig_info{$i->[3]}->{site_name} = $i->[1];
        $dig_info{$i->[3]}->{subj_id} = $i->[2];
        $dig_info{$i->[3]}->{sop_nickname} = $i->[4];
        $dig_info{$i->[3]}->{version_number} = $i->[5];
      }
      my $sop_where = "where sop_instance_uid in (";
      my @keys = keys %$f_info;
      for my $i (0 .. $#keys){
        $sop_where .= "'$f_info->{$keys[$i]}->{sop_instance_uid}'";
        unless($i == $#keys) { $sop_where .= ",\n" }
      }
      $sop_where .= ")";
      $self->NicknamesBySop(
        $sop_where, {}, $f_info, \%dig_info, $nn_type, $table_n);
    } else {
      $self->AutoRefresh;
      $self->{Mode} = "ERROR";
      $self->{ErrorInfo} = {
        status => $status,
        struct => $struct,
      };
    }
  };
  return $sub;
}
method SeriesStudyBySop($sop_where, $nn_type, $table_n){
  my $q = {
    schema => "posda_files",
    db_type => "postgres",
    query => "select\n" .
      "  distinct series_instance_uid, study_instance_uid, sop_instance_uid\n" .
      "from\n" .
      "  file_series natural join file_study natural join file_sop_common\n" .
      $sop_where,
    columns => [
      "sop_instance_uid", "series_instance_uid", "study_instance_uid"
    ],
    args => [],
    bindings => [],
    name => "get series and study by sops",
    description => "",
    connect => Database('posda_files')
  };
  $self->SerializedSubProcess($q, "SubProcessQuery.pl",
    $self->SeriesAndStudiesFetched($sop_where, $nn_type, $table_n));
}
method SeriesAndStudiesFetched($sop_where, $nn_type, $table_n){
  my $sub = sub {
    my($status, $struct) = @_;
    if($status eq "Succeeded" && $struct->{Status} eq "OK"){
      my %sop_info;
      for my $i (@{$struct->{Rows}}){
        $sop_info{$i->[0]}->{series_instance_uid} = $i->[1];
        $sop_info{$i->[0]}->{study_instance_uid} = $i->[2];
      }
      $self->NicknamesBySop(
        $sop_where, \%sop_info, {}, {}, $nn_type, $table_n);
    } else {
      $self->AutoRefresh;
      $self->{Mode} = "ERROR";
      $self->{ErrorInfo} = {
        status => $status,
        struct => $struct,
      };
    }
  };
  return $sub;
}
method NicknamesBySop($sop_where, $sop_info, $file_info, $dig_info, $nn_type, $table_n){
  my $q = {
    query => "select\n" .
      "  project_name, site_name, subj_id, sop_nickname, sop_instance_uid\n" .
      "from sop_nickname\n" . $sop_where,
    columns => ["project_name", "site_name", "subj_id", "sop_nickname",
      "sop_instance_uid", ],
    args =>[],
    bindings =>[],
    schema => "posda_nicknames",
    db_type => "postgres",
    name => "get_sop_nicknames",
    description => "",
    connect => Database('posda_nicknames')
  };
  $self->SerializedSubProcess($q, "SubProcessQuery.pl",
    $self->SopNnsFetched($sop_where, $sop_info, $file_info, $dig_info, $nn_type, $table_n)
  );
}
method SopNnsFetched($sop_where, $sop_info, $file_info, $dig_info, $nn_type, $table_n){
  my $sub = sub {
    my($status, $struct) = @_;
    if($status eq "Succeeded" && $struct->{Status} eq "OK"){
      for my $i (@{$struct->{Rows}}){
        $sop_info->{$i->[4]}->{project_name} = $i->[0];
        $sop_info->{$i->[4]}->{site_name} = $i->[1];
        $sop_info->{$i->[4]}->{subj_id} = $i->[2];
        $sop_info->{$i->[4]}->{sop_nickname} = $i->[3];
      }
      my $q = {
        query => "select distinct series_instance_uid,\n" .
          "  study_instance_uid\n" .
          "from file_sop_common natural join file_series\n" .
          "  natural join file_study\n" .
          $sop_where,
        columns => [ "series_instance_uid", "study_instance_uid" ],
        args => [],
        bindings => [],
        schema => "posda_files",
        db_type => "postgres",
        name => "get_series_by_sops",
        description => "",
        connect => Database('posda_files')
      };
      $self->SerializedSubProcess($q, "SubProcessQuery.pl",
        $self->SeriesBySopsFetched(
          $sop_info ,$file_info, $dig_info, $nn_type, $table_n)
      );
    } else {
      $self->AutoRefresh;
      $self->{Mode} = "ERROR";
      $self->{ErrorInfo} = {
        status => $status,
        struct => $struct,
      };
    }
  };
  return $sub;
}
method SeriesBySopsFetched(
  $sop_info, $file_info, $dig_info, $nn_type, $table_n
){
  my $sub = sub {
    my($status, $struct) = @_;
    my %series_info;
    if($status eq "Succeeded" && $struct->{Status} eq "OK"){
      my $series_where = "where series_instance_uid in (";
      for my $ii (0 .. $#{$struct->{Rows}}){
        $series_info{$struct->{Rows}->[$ii]->[0]}->{study_instance_uid} =
          $struct->{Rows}->[$ii]->[1];
        my $i = $struct->{Rows}->[$ii]->[0];
        $series_where .= "'$i'";
        unless($ii == $#{$struct->{Rows}}){
          $series_where .= ", ";
        }
      }
      $series_where .= ")";
      $self->NicknamesBySeries(
        $series_where, \%series_info, $sop_info, $file_info,
        $dig_info, $nn_type, $table_n
      );
    } else {
      $self->AutoRefresh;
      $self->{Mode} = "ERROR";
      $self->{ErrorInfo} = {
        status => $status,
        struct => $struct,
      };
    }
  };
  return $sub;
}
method StudiesBySeries(
  $series_where, $nn_type, $table_n
){
print STDERR "StudiesBySeries($series_where, $nn_type, $table_n)\n";
  my $q = {
    schema => "posda_files",
    db_type => "postgres",
    query => "select\n" .
      "   distinct series_instance_uid, study_instance_uid,\n" .
      "   project_name, site_name , patient_id\n" .
      "from\n" .
      "  file_series natural join file_study\n" .
      "   natural join ctp_file natural join file_patient\n" .
      $series_where,
    columns => ["series_instance_uid", "study_instance_uid",
      "project_name", "site_name", "patient_id" ],
    args => [],
    bindings => [],
    name => "studies by series",
    description => "",
    connect => Database('posda_files')
  };
print STDERR "Calling Serialized SubProcess\n";
  $self->SerializedSubProcess($q, "SubProcessQuery.pl",
     $self->StudiesFetchedBySeries(
       $series_where, $nn_type, $table_n)
   );
}
method StudiesFetchedBySeries($series_where, $nn_type, $table_n){
  my $sub = sub {
    my($status, $struct) = @_;
    if($status eq "Succeeded" && $struct->{Status} eq "OK"){
      my %series_info;
      for my $i (@{$struct->{Rows}}){
        $series_info{$i->[0]}->{study_instance_uid} = $i->[1];
        $series_info{$i->[0]}->{project_name} = $i->[2];
        $series_info{$i->[0]}->{site_name} = $i->[3];
        $series_info{$i->[0]}->{subj_id} = $i->[4];
      }
      $self->NicknamesBySeries(
        $series_where, \%series_info, {}, {}, {}, "series_nn", $table_n
      );
    } else {
      $self->AutoRefresh;
      $self->{Mode} = "ERROR";
      $self->{ErrorInfo} = {
        status => $status,
        struct => $struct,
      };
    }
  };
  return $sub;
}
method NicknamesBySeries(
  $series_where, $series_info, $sop_info, $file_info, $dig_info, $nn_type, $table_n
){
  my $q = {
    query => "select\n" .
      "  project_name, site_name, subj_id, series_nickname,\n" .
      "  series_instance_uid\n" .
      "from series_nickname\n" . $series_where,
    columns => ["project_name", "site_name", "subj_id", "series_nickname",
      "series_instance_uid"],
    schema => "posda_nicknames",
    db_type => "postgres",
    args => [],
    bindings => [],
    name => "series nicknames",
    description => "",
    connect => Database('posda_nicknames')
  };
  $self->SerializedSubProcess($q, "SubProcessQuery.pl",
    $self->SeriesNicknamesFetched(
      $series_where, $series_info, $sop_info ,$file_info, $dig_info, $nn_type, $table_n)
  );
}
method SeriesNicknamesFetched(
  $series_where, $series_info, $sop_info, $file_info, $dig_info, $nn_type, $table_n
){
  my $sub = sub {
    my($status, $struct) = @_;
    if($status eq "Succeeded" && $struct->{Status} eq "OK"){
      for my $i (@{$struct->{Rows}}){
        $series_info->{$i->[4]}->{project_name} = $i->[0];
        $series_info->{$i->[4]}->{site_name} = $i->[1];
        $series_info->{$i->[4]}->{subj_id} = $i->[2];
        $series_info->{$i->[4]}->{series_nickname} = $i->[3];
      }
      my $q = {
        query => "select distinct study_instance_uid\n" .
          "from file_series natural join file_study\n" .
          $series_where,
        columns => [ "study_instance_uid" ],
        schema => "posda_files",
        db_type => "postgres",
        args => [],
        bindings => [],
        name => "study from series",
        description => "",
        connect => Database('posda_files')
      };
      $self->SerializedSubProcess($q, "SubProcessQuery.pl",
        $self->StudiesBySeriesFetched(
          $series_info, $sop_info ,$file_info, $dig_info, $nn_type, $table_n
        )
      );
    } else {
      $self->AutoRefresh;
      $self->{Mode} = "ERROR";
      $self->{ErrorInfo} = {
        status => $status,
        struct => $struct,
      };
    }
  };
  return $sub;
}
method StudiesBySeriesFetched(
  $series_info, $sop_info, $file_info, $dig_info, $nn_type, $table_n
){
  my $sub = sub {
    my($status, $struct) = @_;
    if($status eq "Succeeded" && $struct->{Status} eq "OK"){
      my $study_where = "where study_instance_uid in (";
      for my $ii (0 .. $#{$struct->{Rows}}){
        my $i = $struct->{Rows}->[$ii]->[0];
        $study_where .= "'$i'";
        unless($ii == $#{$struct->{Rows}}){ $study_where .= ", "}
      }
      $study_where .= ")";
      my $q = {
        schema => "posda_nicknames",
        db_type => "postgres",
        query => "select\n" .
          "  study_instance_uid, project_name, site_name,\n" .
          "  subj_id, study_nickname\n" .
          "from study_nickname\n" . $study_where,
        columns => [ "study_instance_uid", "project_name",
          "site_name", "subj_id", "study_nickname" ],
        args => [],
        bindings => [],
        connect => Database('posda_nicknames')
      };
      $self->SerializedSubProcess($q, "SubProcessQuery.pl",
        $self->StudyNnsFetched(
          $series_info, $sop_info ,$file_info, $dig_info, $nn_type, $table_n
        )
      );
    } else {
      $self->AutoRefresh;
      $self->{Mode} = "ERROR";
      $self->{ErrorInfo} = {
        status => $status,
        struct => $struct,
      };
    }
  };
  return $sub;
}
method StudyNnsFetched(
  $series_info, $sop_info, $file_info, $dig_info, $nn_type, $table_n
){
  my $sub = sub {
    my($status, $struct) = @_;
    if($status eq "Succeeded" && $struct->{Status} eq "OK"){
      my %study_info;
      for my $i (@{$struct->{Rows}}){
        $study_info{$i->[0]}->{project_name} = $i->[1];
        $study_info{$i->[0]}->{site_name} = $i->[2];
        $study_info{$i->[0]}->{subj_id} = $i->[3];
        $study_info{$i->[0]}->{study_nickname} = $i->[4];
      }
      $self->RenderNicknames(
        \%study_info, $series_info, $sop_info, $file_info, $dig_info, $nn_type, $table_n
      );
    } else {
      $self->AutoRefresh;
      $self->{Mode} = "ERROR";
      $self->{ErrorInfo} = {
        status => $status,
        struct => $struct,
      };
    }
  };
  return $sub;
}
method RenderNicknames(
  $study_info, $series_info, $sop_info, $file_info, $dig_info, $nn_type, $table_n
){
print "Render Nicknames: $nn_type, $table_n\n";
$self->{DebugNickname} = {
  study_info => $study_info,
  series_info => $series_info,
  sop_info => $sop_info,
  file_info => $file_info,
  dig_info => $dig_info,
  nn_type => $nn_type,
  table_n => $table_n
};
  if($self->{Mode} eq "LookingUpNicknames"){
    $self->AutoRefresh;
    $self->{Mode} = "TableSelected";
  }
  my $table = $self->{LoadedTables}->[$table_n];
  my $columns;
  my $first_row;
  if($table->{type} eq "FromQuery"){
    $columns = $table->{query}->{columns};
    $first_row = 0;
  }elsif($table->{type} eq "FromCsv"){
    $columns = $table->{rows}->[0];
    $first_row = 1;
  }
  if($nn_type eq "file_nn"){
    my $file_id_row;
    my $nn_row;
    for my $i (0 .. $#{$columns}){
      if($columns->[$i] eq "file_id"){
        $file_id_row = $i;
      } elsif($columns->[$i] eq "nickname"){
        $nn_row = $i;
      }
    }
    unless(defined $file_id_row) {
      print STDERR "No file_id in this table\n";
      return;
    }
    unless(defined $nn_row){
      $nn_row = $#{$columns} + 1;
      $columns->[$#{$columns} + 1] = "nickname";
    }
    for my $i ($first_row .. $#{$table->{rows}}){
      my @errors;
      my($proj, $site, $subj, $study, $series, $sop, $version);

      my $row = $table->{rows}->[$i];
      my $file_id = $row->[$file_id_row];
      my $f_info = $file_info->{$file_id};
      my $digest = $f_info->{digest};
      my $sop_instance_uid = $f_info->{sop_instance_uid};
      my $series_instance_uid = $f_info->{series_instance_uid};
      my $study_instance_uid = $f_info->{study_instance_uid};
      if(exists $dig_info->{$digest}){
        $proj = $dig_info->{$digest}->{project_name};
        $site = $dig_info->{$digest}->{site_name};
        $subj = $dig_info->{$digest}->{subj_id};
        $sop = $dig_info->{$digest}->{sop_nickname};
        $version = $dig_info->{$digest}->{version};
      }
      my $sop_nn_info = $sop_info->{$sop_instance_uid};
      $sop =$sop_nn_info->{sop_nickname};
      unless(defined($proj)){
        $proj = $sop_nn_info->{project_name};
        $site = $sop_nn_info->{site_name};
        $subj = $sop_nn_info->{subj_id};
      }
      my $series_nn_info = $series_info->{$series_instance_uid};
      unless(defined($proj)){
        $proj = $series_nn_info->{project_name};
        $site = $series_nn_info->{site_name};
        $subj = $series_nn_info->{subj_id};
      }
      $series = $series_nn_info->{series_nickname};
      my $study_nn_info = $study_info->{$study_instance_uid};
      unless(defined($proj)){
        $proj = $study_nn_info->{project_name};
        $site = $study_nn_info->{site_name};
        $subj = $study_nn_info->{subj_id};
      }
      $study = $study_nn_info->{study_nickname};
      unless(defined $proj) { $proj = "<undef>" }
      unless(defined $site) { $site = "<undef>" }
      unless(defined $subj) { $subj = "<undef>" }
      unless(defined $study) { $study = "<undef>" }
      unless(defined $series) { $series = "<undef>" }
      unless(defined $sop) { $sop = "<undef>" }
      $row->[$nn_row] = "$proj//$site//$subj//$study//$series//$sop";
      if($version) { $row->{$nn_row} .= "[$version]" }
    }
  } elsif($nn_type eq "sop_nn"){
    my $sop_instance_uid_row;
    my $nn_row;
    for my $i (0 .. $#{$columns}){
      if($columns->[$i] eq "sop_instance_uid"){
        $sop_instance_uid_row = $i;
      } elsif($columns->[$i] eq "nickname"){
        $nn_row = $i;
      }
    }
    unless(defined $sop_instance_uid_row) {
      print STDERR "No sop_instance_uid in this table\n";
      return;
    }
    unless(defined $nn_row){
      $nn_row = $#{$columns} + 1;
      $columns->[$#{$columns} + 1] = "nickname";
    }
    for my $i ($first_row .. $#{$table->{rows}}){
      my $row = $table->{rows}->[$i];
      my $sop_instance_uid = $row->[$sop_instance_uid_row];
      my @errors;
      my($proj, $site, $subj, $study, $series, $sop);
      my $sop_nn_info;
      if(exists $sop_info->{$sop_instance_uid}){
        $sop_nn_info = $sop_info->{$sop_instance_uid};
      } else {
        print STDERR "no SOP nickname data for $sop_instance_uid\n";
        return;
      }
      my $study_instance_uid = $sop_nn_info->{study_instance_uid};
      my $series_instance_uid = $sop_nn_info->{series_instance_uid};
      my $study_nn_info = $study_info->{$study_instance_uid};
      my $series_nn_info = $series_info->{$series_instance_uid};
      $proj = $study_nn_info->{project_name};
      $site = $study_nn_info->{site_name};
      $subj = $study_nn_info->{subj_id};
      my $study_nn = $study_nn_info->{study_nickname};
      my $series_nn = $series_nn_info->{series_nickname};
      my $sop_nn = $sop_nn_info->{sop_nickname};
      unless(defined $study_nn) { $study_nn = "&ltundef>" }
      unless(defined $series_nn) { $series_nn = "&ltundef>" }
      unless(defined $sop_nn) { $sop_nn = "&ltundef>" }
      $row->[$nn_row] = "$proj//$site//$subj//$study_nn//$series_nn//$sop_nn";
    }
  } elsif($nn_type eq "series_nn"){
    my $series_instance_uid_row;
    my $nn_row;
    for my $i (0 .. $#{$columns}){
      if($columns->[$i] eq "series_instance_uid"){
        $series_instance_uid_row = $i;
      } elsif($columns->[$i] eq "nickname"){
        $nn_row = $i;
      }
    }
    unless(defined $series_instance_uid_row) {
      print STDERR "No series_instance_uid in this table\n";
      return;
    }
    unless(defined $nn_row){
      $nn_row = $#{$columns} + 1;
      $columns->[$#{$columns} + 1] = "nickname";
    }
    for my $i ($first_row .. $#{$table->{rows}}){
      my $row = $table->{rows}->[$i];
      my $series_instance_uid = $row->[$series_instance_uid_row];
      my $series_nn_info = $series_info->{$series_instance_uid};
      my $study_instance_uid = $series_nn_info->{study_instance_uid};
      my $study_nn_info = $study_info->{$study_instance_uid};
      my $proj = $series_nn_info->{project_name};
      my $site = $series_nn_info->{site_name};
      my $subj = $series_nn_info->{subj_id};
      my $study = $study_nn_info->{study_nickname};
      my $series = $series_nn_info->{series_nickname};
      unless(defined($proj)){ $proj = "<undef>" }
      unless(defined($site)){ $site = "<undef>" }
      unless(defined($subj)){ $subj = "<undef>" }
      unless(defined($study)){ $study = "<undef>" }
      unless(defined($series)){ $series = "<undef>" }
      $row->[$nn_row] = "$proj//$site//$subj//$study//$series";
    }
  } elsif($nn_type eq "study_nn"){
    my $study_instance_uid_row;
    my $nn_row;
    for my $i (0 .. $#{$columns}){
      if($columns->[$i] eq "study_instance_uid"){
        $study_instance_uid_row = $i;
      } elsif($columns->[$i] eq "nickname"){
        $nn_row = $i;
      }
    }
    unless(defined $study_instance_uid_row) {
      print STDERR "No study_instance_uid in this table\n";
      return;
    }
    unless(defined $nn_row){
      $nn_row = $#{$columns} + 1;
      $columns->[$#{$columns} + 1] = "nickname";
    }
    for my $i ($first_row .. $#{$table->{rows}}){
      my $row = $table->{rows}->[$i];
      my $study_instance_uid = $row->[$study_instance_uid_row];
      my $study_nn_info = $study_info->{$study_instance_uid};
      my $proj = $study_nn_info->{project_name};
      my $site = $study_nn_info->{site_name};
      my $subj = $study_nn_info->{subj_id};
      my $study = $study_nn_info->{study_nickname};
      unless(defined($proj)){ $proj = "<undef>" }
      unless(defined($site)){ $site = "<undef>" }
      unless(defined($subj)){ $subj = "<undef>" }
      unless(defined($study)){ $study = "<undef>" }
      $row->[$nn_row] = "$proj//$site//$subj//$study";
    }
  }
}
1;
