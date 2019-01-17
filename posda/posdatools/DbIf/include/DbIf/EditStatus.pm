package DbIf::EditStatus;
# 
#

use Modern::Perl;
use Method::Signatures::Simple;

use Posda::Config ('Config','Database');
use Posda::DB 'QueryAsync';

use Regexp::Common "URI";

use parent 'Posda::PopupWindow';


method SpecificInitialize($params) {
  $self->{title} = 'Edit Status';
  $self->{count} = 0;
  $self->StartTimer;
  $self->{params} = $params;
  $self->{subprocess_invocation_id} = $params->{id};
  $self->StartQuery(
    "ActivityStuffMoreBySubprocessInvocationId",
    [$self->{subprocess_invocation_id}]);
  $self->StartQuery(
    "GetEditStatusByEditId",
    [$self->{subprocess_invocation_id}]);
  $self->StartQuery(
    "ToFilesFilesImportedByEditId",
    [$self->{subprocess_invocation_id}]);
  $self->SemiSerializedSubProcess(
    "FindRunningBackgroundSubprocesses.pl|CsvStreamToPerlStruct.pl",
    $self->LoadScriptOutput("running_subproceses"));
}
method StartQuery($q_name, $args){
  my $q = QueryAsync($q_name);
  my $cols = $q->{columns};
  my $q_args = $q->{args};
  unless ($#{$args} == $#{$q_args}){
    push(@{$self->{Errors}}, "Arg count mismatch: $q_name");
    return;
  }
  $self->{queries_running}->{$q_name} = 1;
  $q->RunQuery(
    $self->HandleRow($q_name),
    $self->HandleQueryEnd($q_name),
    @$args);
}
method LoadScriptOutput($table_name){
  my $sub = sub{
    my($status, $struct) = @_;
    if($status eq "Succeeded"){
      $self->{$table_name} = $struct;
    } else {
      push @{$self->{Errors}}, "Couldn't load script output $table_name";
    }
  };
  return $sub;
}
method HandleRow($q_name){
  my $sub = sub {
    my($row) = @_;
    unless(exists $self->{query_results}->{$q_name}){
      $self->{query_results}->{$q_name} = [];
    }
    push(@{$self->{query_results}->{$q_name}}, $row);
  };
  return $sub;
}
method HandleQueryEnd($q_name){
  my $sub = sub {
    delete $self->{queries_running}->{$q_name};
  };
  return $sub;
}

method ContentResponse($http, $dyn) {
  my @queries_running = keys %{$self->{queries_running}};
  if(@queries_running > 0){
    $http->queue("Queries running:<ul>");
    for my $i (@queries_running){
      $http->queue("<li>$i");
      if(exists($self->{query_results}->{$i})){
        my $num_rows = @{$self->{query_results}->{$i}};
        $http->queue(" ($num_rows rows)");
      }
      $http->queue("</li>");
    }
    $http->queue("</ul>");
    return;
  }
  my @queries_with_results = keys %{$self->{query_results}};
  if(@queries_with_results > 0){
    $http->queue("Queries with results:<ul>");
    for my $i (@queries_with_results){
      $http->queue("<li>$i");
      if(exists($self->{query_results}->{$i})){
        my $num_rows = @{$self->{query_results}->{$i}};
        $http->queue(" ($num_rows rows)");
      }
      $http->queue("</li>");
    }
  }
  $http->queue("More to come");
}
method StartTimer{
  $self->{backgrounder} = Dispatch::Select::Background->new($self->TimeIncrementor);
  $self->{backgrounder}->timer(10);
  
}
method TimeIncrementor{
  my $sub = sub{
    unless(exists $self->{backgrounder}) { return }
    $self->{count} += 10;
    $self->{backgrounder}->timer(10);
    $self->AutoRefresh;
  }
}

method MenuResponse($http, $dyn) {
  $http->queue("<small>run time: $self->{count}</small>");
}
method ScriptButton($http, $dyn){
  my $parent = $self->parent;
  if($parent->can("ScriptButton")){
    $parent->ScriptButton($http, $dyn);
  }
}

1;
