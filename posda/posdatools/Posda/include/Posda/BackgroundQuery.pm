package Posda::BackgroundQuery;
# 
#

use Modern::Perl;
use Method::Signatures::Simple;

use Posda::Config ('Config','Database');
use Posda::DB 'Query';

use File::Slurp;
use Text::Markdown 'markdown';
use Regexp::Common "URI";

use parent 'Posda::PopupWindow';


method SpecificInitialize($params) {
  $self->{title} = 'Background Query';
  $self->{query} = PosdaDB::Queries->GetQueryInstance($params->{query_name});
  $self->{SavedQueriesDir} = "$params->{SavedQueries}";
  $self->{user} = $params->{user};
  $self->{BindingCache} = $params->{BindingCache};
  $self->{mode} = "Initial";
}

sub HeaderResponse{
  my($this, $http, $dyn) = @_;
  return $this->RefreshEngine($http, $dyn,'<center><h1><?dyn="title"?></h1></center>');

}

method ContentResponse($http, $dyn){
  if($self->{mode} eq "Initial"){
    return $self->InitialContentResponse($http, $dyn);
  } elsif($self->{mode} eq "waiting"){
    return $self->ResultsAreIn($http, $dyn);
  }
  $self->ResultsAreIn($http, $dyn);
}
method InitialContentResponse($http, $dyn) {
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
	$self->{Param}->{notify} = $self->{user};
	for my $arg ("query_name", "notify"){
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
method RunQueryInBackground($http, $dyn){
  my $cmd = "RunQueryInBackground.pl <?invoc_id>? \"$self->{query}->{name}\" $self->{Param}->{notify}";
  my $subprocess_invocation_id = PosdaDB::Queries::invoke_subprocess(
    1, 0, undef, undef, "RunQueryInBackground",
    $cmd, $self->get_user, "RunQueryInBackground");
  my $real_cmd = "RunQueryInBackground.pl $subprocess_invocation_id \"$self->{query}->{name}\" $self->{Param}->{notify}";
  my @args;
  for my $name (@{$self->{query}->{args}}){
    push @args, $self->{Input}->{$name};
  }
  $self->{ForRunning} = [$cmd, $real_cmd, \@args];
  Dispatch::LineReaderWriter->write_and_read_all(
    $self->{ForRunning}->[1],
    $self->{ForRunning}->[2],
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

  $self->{mode} = "waiting";
}
method WaitingContentResponse($http, $dyn){
  $http->queue("Waiting");
}
method ResultsAreIn($http, $dyn){
  $http->queue("results:<pre>");
  if(exists $self->{Results} && ref($self->{Results}) eq "ARRAY"){
    for my $line (@{$self->{Results}}){
      $http->queue("$line\n");
    }
  }
  $http->queue("</pre>");
}

method MenuResponse($http, $dyn) {
}
method ScriptButton($http, $dyn){
  my $parent = $self->parent;
  if($parent->can("ScriptButton")){
    $parent->ScriptButton($http, $dyn);
  }
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

1;
