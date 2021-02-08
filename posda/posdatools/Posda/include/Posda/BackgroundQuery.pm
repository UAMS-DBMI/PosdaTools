package Posda::BackgroundQuery;
# 
#

use Posda::Config ('Config','Database');
use Posda::DB 'Query';
use File::Temp 'tempfile';
use Posda::File::Import 'insert_file';

use File::Slurp;
use Text::Markdown 'markdown';
use Regexp::Common "URI";
use Redis;
use constant REDIS_HOST => 'redis:6379';

my $redis = undef;
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




use parent 'Posda::PopupWindow';


sub SpecificInitialize {
  my ($self, $params) = @_;
  $self->{title} = 'Background Query';
  $self->{query} = PosdaDB::Queries->GetQueryInstance($params->{query_name});
  #$self->{SavedQueriesDir} = "$params->{SavedQueries}";
  $self->{user} = $params->{user};
  $self->{BindingCache} = $params->{BindingCache};
  $self->{params} = $params;
  $self->{mode} = "Initial";
}

sub HeaderResponse{
  my($this, $http, $dyn) = @_;
  return $this->RefreshEngine($http, $dyn,'<center><h1><?dyn="title"?></h1></center>');

}

sub ContentResponse {
  my ($self, $http, $dyn) = @_;
  if($self->{mode} eq "Initial"){
    return $self->InitialContentResponse($http, $dyn);
  } elsif($self->{mode} eq "queued"){
    return $self->Queued($http, $dyn);
  }
  $self->UnknownMode($http, $dyn);
}
sub InitialContentResponse {
  my ($self, $http, $dyn) = @_;
  $http->queue("<h2>Run Background Query</h2>");
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
	$http->queue("<tr><td>Script args:</td></tr>");
	$self->{Param}->{query_name} = $self->{query}->{name};
	$self->{Param}->{activity_id} = $self->{params}->{current_settings}->{activity_id};
	$self->{Param}->{notify} = $self->{user};
	for my $arg ("query_name", "activity_id", "notify"){
          $self->RefreshEngine($http, $dyn, qq{
            <tr>
              <th style="width:5%">$arg</th>
              <td>
                <?dyn="LinkedDelegateEntryBox" linked="Param" index="$arg"?>
              </td>
            </tr>
          });
	}
	$http->queue("<tr><td>Query args:</td></tr>");
        for my $arg (@{$self->{query}->{args}}){
          # preload the Input if arg is in cache
          if (not defined $self->{Input}->{$arg}){
            if(defined $self->{params}->{current_settings}->{$arg}){
              $self->{Input}->{$arg} = $self->{params}->{current_settings}->{$arg};
            } elsif (defined $self->{BindingCache}->{$arg}){
              $self->{Input}->{$arg} = $self->{BindingCache}->{$arg};
            }
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
            caption => "Query in Background",
            op => "RunQueryInBackground",
            sync => "Update();",
            class => "btn btn-primary",
        });
        $http->queue('</p>');
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
sub CreateBindingCacheInfoForKeyInDb {
  my ($self, $key) = @_;
  my $user = $self->get_user;
  my $value = $self->{BindingCache}->{$key};
  Query("InsertUserBoundVariable")->RunQuery(sub{
  }, sub{}, $user, $key, $value);
}
sub UpdateBindingValueInDb {
  my ($self, $key) = @_;
  my $user = $self->get_user;
  my $value = $self->{BindingCache}->{$key};
  Query("UpdateUserBoundVariable")->RunQuery(sub{
  },sub{}, $value, $user, $key);
}
sub RunQueryInBackground{
  my ($self, $http, $dyn) = @_;
  my @args;
  for my $name (@{$self->{query}->{args}}){
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
  #create spreadsheet
  my ($fh,$tempfilename) = tempfile();
  print $fh "arg,Operation,$self->{query}->{name},$self->{Param}->{notify}\n";
  print $fh "$args[0],RunQueryInBackground,$self->{query}->{name},$self->{Param}->{notify}\n";
  for my $i (1 .. $#args){
    print $fh "$args[$i]\n";
  }
  close $fh;

  #call API to import
  my $input_spreadsheet_file_id;
  my $resp = Posda::File::Import::insert_file($tempfilename);
  if ($resp->is_error){
      die $resp->error;
  }else{
    $input_spreadsheet_file_id =  $resp->file_id;
  }
  unlink $tempfilename;
  #create subprocess_invocation row
  my $new_id = Query("CreateSubprocessInvocationButton")
    ->FetchOneHash($input_spreadsheet_file_id, 'background',
      "RunQueryInBackground.pl <?bkgrnd_id?> \"$self->{Param}->{activity_id}\" " .
      "$self->{query}->{name} $self->{Param}->{notify}",
      undef,
      $self->{params}->{user}, 'RunQueryInBackground'
    )->{subprocess_invocation_id};
  unless($new_id) {
    die "Couldn't create row in subprocess_invocation";
  }

  #create input_file
  ($fh,$tempfilename) = tempfile();
  for my $i (0 .. $#args){
    print $fh "$args[$i]\n";
  }
  close $fh;

  #call API to import
  my $worker_input_file_id;
  $resp = Posda::File::Import::insert_file($tempfilename);
  if ($resp->is_error){
      die $resp->error;
  }else{
    $worker_input_file_id =  $resp->file_id;
  }
  unlink $tempfilename;

  # add to the work table for worker nodes
  my $work_id = Query("CreateNewWork")
                ->FetchOneHash($new_id,$worker_input_file_id)
                ->{work_id};


  ConnectToRedis();
  unless($redis){
    die "Couldn't connect to redis";
  }
  $redis->lpush('work_queue_0', $work_id);
  QuitRedis();
  
  $self->{mode} = "queued";
  $self->{work_id} = $work_id;
}
sub WaitingContentResponse {
  my ($self, $http, $dyn) = @_;
  $http->queue("Waiting");
}
sub Queued {
  my ($self, $http, $dyn) = @_;
  $http->queue("Queued: $self->{work_id}");
}
sub ResultsAreIn {
  my ($self, $http, $dyn) = @_;
  $http->queue("Unknown mode: $self->{mode}");
}

sub MenuResponse {
  my ($self, $http, $dyn) = @_;
}
sub ScriptButton {
  my ($self, $http, $dyn) = @_;
  my $parent = $self->parent;
  if($parent->can("ScriptButton")){
    $parent->ScriptButton($http, $dyn);
  }
}
sub DrawWidgetFromTo {
  my ($self, $http, $dyn) = @_;
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

1;
