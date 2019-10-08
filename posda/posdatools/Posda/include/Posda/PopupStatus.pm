package Posda::PopupStatus;
# 
#

use Modern::Perl;

use Posda::Config ('Config','Database');
use Posda::DB 'QueryAsync';

use Regexp::Common "URI";

use parent 'Posda::PopupWindow';


sub StartQuery {
  my ($self, $q_name, $args) = @_;
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
sub LoadScriptOutput {
  my ($self, $table_name) = @_;
  $self->{scripts_running}->{$table_name} = 1;
  my $sub = sub{
    my($status, $struct) = @_;
    if($status eq "Succeeded"){
      unless(exists($self->{script_results})){ $self->{script_results} = {} }
      $self->{script_results}->{$table_name} = $struct;
    } else {
      push @{$self->{Errors}}, "Couldn't load script output $table_name";
    }
    delete $self->{scripts_running};
    $self->AutoRefresh;
  };
  return $sub;
}
sub HandleRow {
  my ($self, $q_name) = @_;
  my $sub = sub {
    my($row) = @_;
    unless(exists $self->{query_results}->{$q_name}){
      $self->{query_results}->{$q_name} = [];
    }
    push(@{$self->{query_results}->{$q_name}}, $row);
    $self->AutoRefresh;
  };
  return $sub;
}
sub HandleQueryEnd {
  my ($self, $q_name) = @_;
  my $sub = sub {
    delete $self->{queries_running}->{$q_name};
  };
  $self->AutoRefresh;
  return $sub;
}

sub ContentResponse {
  my ($self, $http, $dyn) = @_;
  my @queries_running = keys %{$self->{queries_running}};
  my @scripts_running = keys %{$self->{scripts_running}};
  my @scripts_results = keys %{$self->{script_results}};
  if(@queries_running == 0 && @scripts_running == 0){
    return $self->InitializedResponse($http, $dyn);
  }
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
    $http->queue("</ul>");
  }
  if(@scripts_running){
    $http->queue("Scripts running:<ul>");
    for my $i (@scripts_running){
      $http->queue("<li>$i</li>");
    }
    $http->queue("</ul>");
  }
 
  if(@scripts_results){
    $http->queue("Scripts with results;<ul>");
    for my $i (@scripts_results){
      $http->queue("<li>$i</li>");
    }
    $http->queue("</ul>");
  }
}
1;
