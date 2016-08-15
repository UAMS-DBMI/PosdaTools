package DbIf::Application;
#
# A User Admin application
#

use Posda::DB::PosdaFilesQueries;
use vars '@ISA';
@ISA = ("GenericApp::Application");

use Modern::Perl '2010';
use Method::Signatures::Simple;
use Storable 'dclone';

use GenericApp::Application;

use Posda::Passwords;
use Posda::Config 'Config';

use Posda::DebugLog 'on';
use Data::Dumper;


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
    ],
  };
  $self->{Mode} = "ListQueries";
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
}


method MenuResponse($http, $dyn) {
  if(exists $self->{MenuByMode}->{$self->{Mode}}){
    for my $m (@{$self->{MenuByMode}->{$self->{Mode}}}){
      $self->NotSoSimpleButton($http, $m);
      $http->queue("<br/>");
    }
  } else {
    $self->NotSoSimpleButtonButton($http, {
      caption => 'Reset',
      op => 'SetMode',
      mode => 'ListQueries',
      sync => 'Update();'
    });
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
method ListQueries($http, $dyn){
  my @q_list = PosdaDB::Queries->GetList;
  $self->RefreshEngine($http, $dyn, "<table><tr><th>" .
    "Queries</th><th></th><th><tr>");
  for my $i (@q_list){
    $self->RefreshEngine($http, $dyn,
      "<tr><td>$i</td><td>" .
      '<?dyn="NotSoSimpleButton" op="SetActiveQuery" ' .
      'caption="Set Active" ' .
      'query_name="' . $i . '" sync="Update();"?></td><td>' .
      '<?dyn="NotSoSimpleButton" op="DeleteQuery" caption="Delete" ' .
      'query_name="' . $i . '" sync="Update();"?></td></tr>');
  }
  $self->RefreshEngine($http, $dyn, "</table>")
}
method NewQuery($http, $dyn){
  $http->queue("New Queries Mode");
}
method SetActiveQuery($http, $dyn){
  $self->{Mode} = "ActiveQuery";
  $self->{Query} = $dyn->{query_name};
  delete $self->{QueryResults};
  delete $self->{Input};
  $self->{query} = PosdaDB::Queries->GetQueryInstance($dyn->{query_name});
}
method ActiveQuery($http, $dyn){
  $self->RefreshEngine($http, $dyn, "<table border>");
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
      special => "pre-formatted"
    },
    query => {
      caption=> "Query Text",
      struct => "text",
      special => "pre-formatted"
    },
    schema => {
      caption=> "Schema",
      struct => "text",
      special => "pre-formatted"
    },
    name => {
      caption=> "Query Name",
      struct => "text",
      special => "pre-formatted"
    },
  };
  for my $i ("name", "schema", "description", "columns", "args", "query"){
    my $d = $descrip->{$i};
    $self->RefreshEngine($http, $dyn, '<tr><td align="right" valign="top">' .
      '<pre>' .
      $d->{caption} . '</pre></td><td align="left" valign = "top">'
    );
    if($d->{struct} eq "text"){
      if($d->{special} eq "pre-formatted"){
         $self->RefreshEngine($http, $dyn, "<pre>$self->{query}->{$i}</pre>")
      } else {
         $self->RefreshEngine($http, $dyn, "<pre>$self->{query}->{$i}</pre>")
      }
    }
    if($d->{struct} eq "array"){
      if($d->{special} eq "pre-formatted-list"){
        $self->RefreshEngine($http, $dyn, "<pre>");
        for my $j (@{$self->{query}->{$i}}){
          $self->RefreshEngine($http, $dyn, "$j\n");
        }
        $self->RefreshEngine($http, $dyn, "</pre>");
      } elsif($d->{special} eq "form"){
        $self->RefreshEngine($http, $dyn, "<table>");
        for my $arg (@{$self->{query}->{args}}){
          $self->RefreshEngine($http, $dyn, '<tr><td align="right" ' .
            'valign="top"><pre>' . $arg . '</pre></td>' .
            '<td align="left" valign="top">');
          $self->RefreshEngine($http, $dyn,
            '<?dyn="LinkedDelegateEntryBox" linked="Input" ' .
            "index=\"$arg\"?>");
          $self->RefreshEngine($http, $dyn, '</td><tr>');
        }
        $self->RefreshEngine($http, $dyn, '</table>' .
          '<?dyn="NotSoSimpleButton" caption="Query Database" ' .
          'op="MakeQuery" sync="Update();"?>');
      }
    }
    $self->RefreshEngine("</td></tr>");
  }
  $self->RefreshEngine($http, $dyn, '</table>');
}
method DeleteQuery($http, $dyn){
 PosdaDB::Queries->Delete($dyn->{query_name});
}
method MakeQuery($http, $dyn){
  my $query = {};
  for my $i (keys %{$self->{query}}){
    $query->{$i} = $self->{query}->{$i};
  }
  my @bindings;
  for my $i (@{$self->{query}->{args}}){
    push(@bindings, $self->{Input}->{$i});
  }
  $query->{bindings} = \@bindings;
  $self->{Mode} = "QueryWait";
  $self->SerializedSubProcess($query, "SubProcessQuery.pl", $self->QueryEnd);
}
method QueryEnd{
  my $sub = sub {
    my($status, $struct) = @_;
    $self->AutoRefresh;
    if($status = "Succeeded" && $struct->{Status} eq "OK"){
      $self->{Mode} = "QuerySuccessful";
      if(exists $struct->{NumRows}){
          $self->{NumRows} = $struct->{NumRows}
      } elsif(exists $struct->{Rows}){
        $self->{Rows} = $struct->{Rows};
      } else {
        $self->{Mode} = "QueryFailed";
        $self->{QueryReturnedInfo} = $struct;
      }
    }
  };
  return $sub;
}
method QuerySuccessful($http, $dyn){
  if($self->{query}->{query} =~ /^select/){
    $self->RefreshEngine($http, $dyn, "<table border><tr>");
    for my $i (@{$self->{query}->{columns}}){
      $self->RefreshEngine($http, $dyn, "<th><pre>$i</pre></th>");
    }
    $self->RefreshEngine($http, $dyn, '</tr>');
    for my $r (@{$self->{Rows}}){
      $self->RefreshEngine($http, $dyn, '<tr>');
      for my $v (@$r){
        unless(defined($v)){ $v = "&lt;undef&gt;" }
        $self->RefreshEngine($http, $dyn, "<td><pre>$v</pre></td>");
      }
      $self->RefreshEngine($http, $dyn, '</tr>');
    }
  }
  $self->RefreshEngine($http, $dyn, "</table>");
}
#############################
my $f_form = '
<form action="<?dyn="StoreFileUri"?>"
enctype="multipart/form-data" method="POST">
<p>
Please specify a file, or a set of files:<br>
<input type="file" name="datafile" size="40">
</p>
<div>
<input type="submit" value="Send">
</div>
</form>';
method Upload($http, $dyn){
  $self->RefreshEngine($http, $dyn, $f_form);
}
method StoreFileUri($http, $dyn){
  $http->queue("StoreFile?obj_path=$self->{path}");
}
method StoreFile($http, $dyn){
  $http->queue("<pre>");
  for my $k (keys %$dyn){
    $http->queue("dyn{$k} = $dyn->{$k}\n");
  }
  for my $k (keys %$http){
    $http->queue("http{$k} = $http->{$k}\n");
  }
  $http->queue("<a href=\"Refresh?obj_path=$self->{path}\">Go back</a>");
}
1;
