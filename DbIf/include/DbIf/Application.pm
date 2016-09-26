package DbIf::Application;
#
# A User Admin application
#

use Posda::DB::PosdaFilesQueries;
use Dispatch::BinFragReader;

use Modern::Perl '2010';
use Method::Signatures::Simple;
use Storable 'dclone';

use Dispatch::LineReaderWriter;

use GenericApp::Application;

use Posda::Passwords;
use Posda::Config 'Config';

use Posda::DebugLog 'on';
use Data::Dumper;

use Debug;
my $dbg = sub {print STDERR @_ };

use vars '@ISA';
@ISA = ("GenericApp::Application");

method SpecificInitialize() {
  ### change this to initialize from config
  $self->{MenuByMode} = {
    ListQueries => [
      {
        caption => "New",
        op => 'SetMode',
        mode => 'NewQuery',
        sync => 'Update();'
      },
      {
        caption => "Freeze",
        op => 'SetMode',
        mode => 'Freeze',
        sync => 'Update();'
      },
      {
        caption => "Load",
        op => 'SetMode',
        mode => 'Load',
        sync => 'Update();'
      },
      {
        caption => "Merge",
        op => 'SetMode',
        mode => 'Merge',
        sync => 'Update();'
      },
      {
        caption => "Clear",
        op => 'SetMode',
        mode => 'Clear',
        sync => 'Update();'
      },
      {
        caption => "Upload",
        op => 'SetMode',
        mode => 'Upload',
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
    ActiveQuery => [
      {
        caption => "List",
        op => 'SetMode',
        mode => 'ListQueries',
        sync => 'Update();'
      },
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
    ],
    QuerySuccessful => [
      {
        caption => "List",
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
    Files => [
      {
        caption => "List",
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
    TableSelected => [
      {
        caption => "List",
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
  };
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
  my $temp_dir = "$self->{Environment}->{LoginTemp}/$self->{session}";
  unless(-d $temp_dir) { die "$temp_dir doesn't exist" }
  $self->{TempDir} = $temp_dir;
  $self->{UploadCount} = 0;
  $self->{DbLookUp} = $self->{Environment}->{DbSpec};


  # Build the command list from config file
  my $command_list = $self->{Environment}->{Commands};
  my $commands = {};
  map {
    my $line = $command_list->{$_};
    my $cmdline = $line;
    my $pipe_parms;

    if ($line =~ /(.*)\|(.*)/) { # is it a pipe command?
      $cmdline = $2;
      $pipe_parms = $1;
    }

    $commands->{$_} = { cmdline => $cmdline,
                        parms => [$cmdline =~ /<([^<>]+)>/g] };
    if (defined $pipe_parms) {
      $commands->{$_}->{pipe_parms} = $pipe_parms;
    }
  } keys %$command_list;

  $self->{Commands} = $commands;

}


method MenuResponse($http, $dyn) {
  if(exists $self->{MenuByMode}->{$self->{Mode}}){
    $self->MakeMenu($http, $dyn, $self->{MenuByMode}->{$self->{Mode}});
  } else {
    $self->MakeMenu($http, $dyn, [
      {
        caption => 'Reset',
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
    ]
  );
 }
}
method SetMode($http, $dyn){
  $self->{Mode} = $dyn->{mode};
}

method ContentResponse($http, $dyn) {
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
method TagSelection($http, $dyn){
  my $tags = PosdaDB::Queries->GetAllTags;
  $self->SelectMethodByValue($http, {
    method => "SetTagsFilter",
    sync => "Update();"
  });
  
  unless($self->{TagsFilterDisplay}) {
    $self->{TagsFilterDisplay} = $tag_mode_list->[0];
  }
  unless(defined $self->{TagsState} && ref($self->{TagsState}) eq "HASH"){
    $self->{TagsState} = {};
    for my $t (keys %$tags){
      $self->{TagsState}->{$t} = "false";
    }
  }
  for my $i ((sort keys %$tag_modes), keys %$tag_ops){
    $http->queue("<option value=\"$i\"" .
      ($self->{TagsFilterDisplay} eq $i ?
        " selected" : "") .
      ">$i</option>");
  }
  $http->queue("</select>");
  for my $t (sort keys %$tags){
    $http->queue($self->CheckBox("tags", $t, "CheckBoxChange",
      $self->{TagsState}->{$t} eq "true", "Update();"));
    $http->queue(" $t     ");
  }
}
method CheckBoxChange($http, $dyn){
  $self->AutoRefresh;
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
method TagTest($query_tags, $all_tags){
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
  my @q_list = PosdaDB::Queries->GetList;
  my $tags = PosdaDB::Queries->GetAllTags;
  
  $self->RefreshEngine($http, $dyn, qq{
    <table class="table table-striped table-condensed">
    <tr>
      <th colspan=2>Queries  <?dyn="TagSelection"?></th>
      <th></th>
    <tr>
  });
  for my $i (@q_list){
    unless($self->TagTest(PosdaDB::Queries->GetTags($i), $tags)){ next }
    $self->RefreshEngine($http, $dyn, qq{
      <tr>
        <td>$i</td>
        <td>
          <?dyn="NotSoSimpleButton" op="SetActiveQuery" caption="Set Active" query_name="$i" sync="Update();"?>
          <?dyn="NotSoSimpleButton" op="DeleteQuery" caption="Delete" query_name="$i" sync="Update();" class="btn btn-info"?>
          <?dyn="NotSoSimpleButton" op="SetEditQuery" caption="Edit" query_name="$i" sync="Update();" class="btn btn-info"?>
          <?dyn="NotSoSimpleButton" op="CloneQuery" caption="Clone" query_name="$i" sync="Update();" class="btn btn-info"?>
        </td>
      </tr>
    });
  }
  $self->RefreshEngine($http, $dyn, "</table>")
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
      struct => "hash key list",
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
      $self->RefreshEngine($http, $dyn, 
        '<?dyn="DelegateEntryBox" ' .
        'op="AddTextField" ' .
        "value=\"$self->{query}->{$i}\" ". 
        "index=\"$i\"" .
        'sync="Update();"' .
        '?>');
    }
    if($d->{struct} eq "array"){
      $http->queue(qq{
        <table class="table table-condensed">
      });
      for my $j (@{$self->{query}->{$i}}){
        $self->RefreshEngine($http, $dyn, "<tr><td>$j</td><td>" .
          '<?dyn="NotSoSimpleButton" ' .
          'op="DeleteFromEditList" ' .
          'caption="del" ' .
          'name="'. $i .'" ' .
          'value="' . $j . '"?></td><td>' .
          '<?dyn="NotSoSimpleButton" ' .
          'op="MoveEditListElementUp" ' .
          'caption="up" ' .
          'name="'. $i .'" ' .
          'value="' . $j . '"?></td><td>');
        $self->RefreshEngine($http, $dyn, "</tr>");
      }
      $self->RefreshEngine($http, $dyn, "<tr><td>");
      $self->RefreshEngine($http, $dyn, 
        '<?dyn="DelegateEntryBox" ' .
        'op="AddToEditList" ' .
        'value="" '. 
        "index=\"$i\"" .
        'sync="Update();"' .
        '?>');
      $self->RefreshEngine($http, $dyn, "</table>");
    } elsif($d->{struct} eq "hash key list"){
      my @keys = sort keys %{$self->{query}->{tags}};
      for my $k (0 .. $#keys){
        $http->queue("$keys[$k] ");
        $self->NotSoSimpleButton($http, {
          caption => "del",
          op => "DeleteHashKeyList",
          type => $i,
          index => $k,
          value => $keys[$k],
          sync => "Update();"
        });
        $http->queue(",&nbsp;&nbsp;&nbsp;");
#        unless($k == $#keys){ $http->queue(", ") }
      }
      $self->DelegateEntryBox($http, {
        op => "AddToHashKeyList",
        index => $i,
        sync => "Update();"
      });
    } elsif($d->{struct} eq "textarea"){
        $self->DelegateTextArea($http, {
          id => "$i",
          op => "TextAreaChanged",
          value => $self->{query}->{$i},
          rows => $d->{rows},
          cols => $d->{cols},
          sync => "Update();",
      });
    }
    $self->RefreshEngine("</td></tr>");
  }
  $self->RefreshEngine($http, $dyn, '</table>');
}
method TextAreaChanged($http, $dyn){
  print STDERR "###################\nIn TextAreaChanged\n";
  for my $i (keys %$dyn){
    print STDERR "dyn{$i}: $dyn->{$i}\n";
  }
  for my $i (keys %$http){
    print STDERR "http{$i}: $http->{$i}\n";
  }
  for my $i (keys %{$http->{header}}){
    print STDERR "http{header}->{$i}: $http->{header}->{$i}\n";
  }
  my $buff;
  my $c = read $http->{socket}, $buff, $http->{header}->{content_length};
  print STDERR "Read $c bytes:\n";
  print STDERR "$buff#################\n";
}
method SetActiveQuery($http, $dyn){
  $self->{Mode} = "ActiveQuery";
  $self->{Query} = $dyn->{query_name};
  delete $self->{QueryResults};
  delete $self->{Input};
  $self->{query} = PosdaDB::Queries->GetQueryInstance($dyn->{query_name});
}
method ActiveQuery($http, $dyn){
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
      special => "",
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
    my $d = $descrip->{$i};
    $http->queue(qq{
      <tr>
        <td align="right" valign="top">
          <strong>$d->{caption}</strong>
        </td>
        <td align="left" valign = "top">
    });
    if($d->{struct} eq "text"){
      if(
        defined($d->{special}) &&
        $d->{special} eq "pre-formatted"
      ){
         $self->RefreshEngine($http, $dyn, "<pre><code class=\"sql\">$self->{query}->{$i}</code></pre>")
      } else {
         $self->RefreshEngine($http, $dyn, "$self->{query}->{$i}")
      }
    }
    if($d->{struct} eq "array"){
      if($d->{special} eq "pre-formatted-list"){

        $http->queue(qq{
          <table class="table table-condensed">
        });
        for my $j (@{$self->{query}->{$i}}){
          $self->RefreshEngine($http, $dyn, "<tr><td>$j</td></tr>");
        }
        $self->RefreshEngine($http, $dyn, "</table>");

      } elsif($d->{special} eq "form"){
        $self->RefreshEngine($http, $dyn, "<table class=\"table\">");
        for my $arg (@{$self->{query}->{args}}){
          $self->RefreshEngine($http, $dyn, qq{
            <tr>
              <th style="width:5%">$arg</th>
              <td>
                <?dyn="LinkedDelegateEntryBox" linked="Input" index="$arg"?>
              </td>
            </tr>
          });
        }
        $http->queue('</table>');
        $self->NotSoSimpleButton($http,
          { caption => "Query Database",
            op => "MakeQuery",
            sync => "Update();",
            class => "btn btn-primary" });
      }
    } elsif($d->{struct} eq "hash key list"){
      my @keys = sort keys %{$self->{query}->{tags}};
      for my $k (0 .. $#keys){
        $http->queue($keys[$k]);
        unless($k == $#keys){ $http->queue(", ") }
      }
    }
    $self->RefreshEngine("</td></tr>");
  }
  $self->RefreshEngine($http, $dyn, '</table>');
}
method DeleteQuery($http,$dyn){
  $self->{Mode} = "DeleteQueryPending";
  $self->{QueryPendingDelete} = $dyn->{query_name};
}
method DeleteQueryPending($http, $dyn){
  $self->RefreshEngine($http, $dyn, 
    "Do you want to delete query named $self->{QueryPendingDelete}?<br>" .
    '<?dyn="NotSoSimpleButton" op="ReallyDeleteQuery" ' .
    'caption="Yes, Delete it" ' .
    'sync="Update();"?><?dyn="NotSoSimpleButton" ' .
    'op="CancelDeleteQuery" caption="No, don' . "'" . 't delete" ' .
    'sync="Update();"?>');
}
method ReallyDeleteQuery($http, $dyn){
 PosdaDB::Queries->Delete($self->{QueryPendingDelete});
 delete $self->{QueryPendingDelete};
 $self->{Mode} = "ListQueries";
}
method CancelDeleteQuery($http, $dyn){
 delete $self->{QueryPendingDelete};
 $self->{Mode} = "ListQueries";
}
method MakeQuery($http, $dyn){
  my $query = {};
  for my $i (keys %{$self->{query}}){
    $query->{$i} = $self->{query}->{$i};
  }
  for my $i (keys %{$self->{DbLookUp}->{$query->{schema}}}){
    $query->{$i} = $self->{DbLookUp}->{$query->{schema}}->{$i};
  }
  my @bindings;
  for my $i (@{$self->{query}->{args}}){
    push(@bindings, $self->{Input}->{$i});
  }
  $query->{bindings} = \@bindings;
  $self->{Mode} = "QueryWait";
  $self->SerializedSubProcess($query, "SubProcessQuery.pl",
    $self->QueryEnd($query));
}

method QueryWait($http, $dyn) {
  $http->queue(qq{
    <div class="alert alert-info">
      Executing query...
      <div class="spinner" style="display:inline-block;margin-left:30px"></div>
    </div>
  });
}

method QueryEnd($query) {
  my $start_time = time;
  my $sub = sub {
    my($status, $struct) = @_;
    if($self->{Mode} eq "QueryWait"){
      $self->AutoRefresh;
    }
    if($status = "Succeeded" && $struct->{Status} eq "OK"){
      if($query->{query} =~ /^select/ && exists $struct->{Rows}){
        return $self->CreateAndSelectTableFromQuery($query, $struct,
          $start_time);
      } elsif(exists $struct->{NumRows}){
        return $self->UpdateInsertCompleted($query, $struct);
      }
    } else {
      if($self->{Mode} eq "QueryWait"){
        $self->{Mode} = "QueryFailed";
      }
      unless(exists $self->{FailedQueries}){ $self->{FailedQueries} = [] }
      push @{$self->{FailedQueries}}, {
        query => $query,
        result => $struct
      };
    }
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
    $self->{Mode} eq "UpdateInsertStatus";
  }
}
method CreateAndSelectTableFromQuery($query, $struct, $start_at){
  unless(exists $self->{LoadedTables}) { $self->{LoadedTables} = [] }
  my $new_entry = {
    type => "FromQuery",
    at => $start_at,
    duration => time - $start_at,
    rows => $struct->{Rows},
  };
  my $new_q = {
  };
  for my $i (keys %$query){
    unless($i eq "columns"){ $new_q->{$i} = $query->{$i} }
  }
  my @cols = @{$query->{columns}};
  $new_q->{columns} = \@cols;
  $new_entry->{query} = $new_q;
  push(@{$self->{LoadedTables}}, $new_entry);
  my $index = $#{$self->{LoadedTables}};
  if($self->{Mode} eq "QueryWait"){
    $self->{Mode} = "TableSelected";
    $self->{SelectedTable} = $index;
  }
}
method DownloadTableAsCsv($http, $dyn){
  my $table = $self->{LoadedTables}->[$dyn->{table}];
  my $q_name = $table->{query}->{name};
  $http->DownloadHeader("text/csv", "$q_name.csv");
  my $cmd = "PerlStructToCsv.pl";
  Dispatch::BinFragReader->new_serialized_cmd($cmd,
    $table, $self->CsvFragment($http, $dyn), $self->CsvComplete);
}
method CsvFragment($http, $dyn){
  my $sub = sub {
    my($frag) = @_;
    $http->queue("$frag");
  };
  return $sub;
}
method CsvComplete{
  my $sub = sub {
  };
  return $sub;
}
method TableSelected($http, $dyn){
  my $table = $self->{LoadedTables}->[$self->{SelectedTable}];
  if($table->{type} eq "FromQuery"){
    my $query = $table->{query};
    my $rows = $table->{rows};
    my $num_rows = @$rows;
    my $at = $table->{at};
    $self->RefreshEngine($http, $dyn,
      '<div style="background-color: white">' .
      "Table from query: $query->{name}  " .
      '<a class="btn btn-sm btn-primary" ' .
      'href="DownloadTableAsCsv?obj_path=' . $self->{path} . '&table=' .
      $self->{SelectedTable} . 
      '\">download</a>' .
      '<br>' .
      "Description: <pre>$query->{description}</pre>" .
      "Schema: $query->{schema}<br>"
    );
    my $numb = @{$query->{bindings}};
    if($numb > 0){
      $http->queue('Bindings:<ul>');
      for my $i (0 .. $#{$query->{bindings}}){
        $http->queue("<li>$query->{args}->[$i]: " .
          "$query->{bindings}->[$i]</li>");
      }
      $http->queue('</ul>');
    }
    $http->queue("Rows: $num_rows<br>Results:<hr>");
    $http->queue(qq{
      <table class="table table-striped">
        <tr>
    });
    for my $i (@{$query->{columns}}){
      $http->queue("<th>$i</th>");
    }
    $http->queue('</tr>');
  
    for my $r (@$rows){
      $http->queue('<tr>');
      for my $v (@$r){
        unless(defined($v)){ $v = "<undef>" }
        my $v_esc = $v;
        $v_esc =~ s/</&lt;/g;
        $v_esc =~ s/>/&gt;/g;
        $http->queue("<td>$v_esc</td>");
      }
      $http->queue('</tr>');
    }
    $self->RefreshEngine($http, $dyn, "</table></div>");
  } elsif($table->{type} eq "FromCsv"){
    my $file = $table->{file};
    my $rows = $table->{rows};
    my $num_rows = @$rows - 1;
    my $at = $table->{at};
    $http->queue('<div style="background-color: white">' .
      "Table from CSV file: $file   " .
      '<a class="btn btn-sm btn-primary" ' .
      'href="DownloadTableAsCsv?obj_path=' . $self->{path} . '&table=' .
      $self->{SelectedTable} . 
      '\">download</a>' .
      '<br>'
    );
    $http->queue("Rows: $num_rows<br>Results:<hr>");
    $http->queue(qq{
      <table class="table table-striped">
        <tr>
    });
    for my $i (@{$rows->[0]}){
      $http->queue("<th>$i</th>");
    }
    $http->queue('</tr>');
  
    for my $ri (1 .. $#{$rows}){
      my $r = $rows->[$ri];
      $http->queue('<tr>');
      for my $v (@$r){
        unless(defined($v)){ $v = "<undef>" }
        my $v_esc = $v;
        $v_esc =~ s/</&lt;/g;
        $v_esc =~ s/>/&gt;/g;
        $http->queue("<td>$v_esc</td>");
      }
      $http->queue('</tr>');
    }
    $self->RefreshEngine($http, $dyn, "</table></div>");
  }
}
method UpdateInsertStatus($http, $dyn){
}
method UpdatesInserts($http, $dyn){
}
#############################
my $f_form = '
<form action="<?dyn="StoreFileUri"?>"
enctype="multipart/form-data" method="POST" class="dropzone">
</form>';
method Upload($http, $dyn){
  $self->RefreshEngine($http, $dyn, $f_form);
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
    if ($hash->{'mime-type'} eq 'text/csv') {
      $self->LoadCSVIntoTable_NoMode($hash->{'Output file'});
    }
    $self->InvokeAfterDelay("ServeUploadQueue", 0);
  };
  return $sub;
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
    }
    $self->RefreshEngine($http, $dyn, '</p></td></tr>');
  }
  $self->RefreshEngine($http, $dyn, '</table>');
}
method LoadCsvIntoTable($http, $dyn){
  $self->{Mode} = "LoadCsvIntoTable";
  my $file = $self->{UploadedFiles}->[$dyn->{index}]->{"Output file"};
  my $cmd = "CsvToPerlStruct.pl \"$file\"";
  $self->SemiSerializedSubProcess($cmd, $self->CsvLoaded($file));
}
method LoadCSVIntoTable_NoMode($file) {
  my $cmd = "CsvToPerlStruct.pl \"$file\"";
  $self->SemiSerializedSubProcess($cmd, $self->CsvLoaded($file));
}

method CsvLoaded($file){
  my $sub = sub {
    my($status, $struct) = @_;
    if($status eq "Succeeded"){
      if($struct->{status} eq "OK"){
        unless(
          exists $self->{LoadedTables} &&
          ref($self->{LoadedTables}) eq "ARRAY"
        ){ $self->{LoadedTables} = [] }
        push(@{$self->{LoadedTables}}, {
          type => "FromCsv",
          file => $file,
          at => time,
          rows => $struct->{rows},
        });
      } else {
      }
    } else {
    }
  };
  return $sub;
}
method Tables($http, $dyn){
  unless(exists $self->{LoadedTables}) { $self->{LoadedTables} = [] }
  my $num_tables = @{$self->{LoadedTables}};
  if($num_tables == 0){
    return $self->RefreshEngine($http, $dyn, "No tables have been loaded");
  }
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
    my $num_rows;
    my $name;
    if($type eq "FromCsv") {
      $type_disp = "From CSV Upload";
      $num_rows = @{$i->{rows}} - 1;
      my $fn = $i->{file};
      if($fn =~ /\/([^\/]+)$/){
        $name = $1;
      } else {
        $name = $fn;
      }
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
    $self->RefreshEngine($http, $dyn,
      "<tr><td><p>$type</p></td><td><p>$num_rows</p></td>" .
      "<td><p>$name</p></td><td><p>");
    $self->NotSoSimpleButton($http, {
        caption => "Select",
        op => "SelectTable",
        index => $in,
        sync => "Update();",
    });
    my $can_nickname = 0;
    my $can_command = 0;
    my $cols;
    if($type eq "FromCsv"){ $cols = $i->{rows}->[0] }
    elsif($type eq "FromQuery"){ $cols = $i->{query}->{columns} }
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
    my $index_of_parm = $colmap->{$parm};
    my $new_value = $row->[$index_of_parm];

    $final =~ s/<$parm>/$new_value/g;
  } @{$command->{parms}};

  return $final;
}

method ExecuteCommand($http, $dyn) {
  my $table = $self->{LoadedTables}->[$dyn->{index}];

  # generate a map of column name to col index
  my $colmap = {};
  map {
    my $item = $table->{rows}->[0]->[$_];
    $colmap->{$item} = $_;
  } (0 .. $#{$table->{rows}->[0]});

  # Test for pipe edge case
  my $first_row_op = $table->{rows}->[1]->[$colmap->{Operation}];
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
      shift @$col1; # kill the first element

      $cols->{$col_name} = $col1;
    }

    # now generate the cmdline like normal
    my $final_cmd = apply_command($op, $colmap, $table->{rows}->[1]);

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
  my $cmd = $self->{PlannedPipeOperation};
  my $stdin = $self->{PlannedOperations};

  Dispatch::LineReaderWriter->write_and_read_all(
    $cmd,
    $stdin,
    func($return) {
      $self->{Results} = $return;
      $self->{Mode} = 'ResultsAreIn';
      $self->AutoRefresh;
      say "ResultsAreIn!";
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

  $http->queue(qq{
    <p>The command to be executed:</p>
    <pre>$self->{PlannedPipeOperation}</pre>

    <p>The vlaues to be fed on standard input:</p>
    <table class="table">
      <tr>
        <th>Input</th>
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
  $self->{Mode} = "TableSelected";
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
    description => ""
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
    description => ""
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
    description => ""
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
