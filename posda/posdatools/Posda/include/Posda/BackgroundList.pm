package Posda::BackgroundList;
# 
#
use strict;

use Posda::Config ('Config','Database');
use Posda::DB 'Query';
use parent 'Posda::PopupWindow';


sub SpecificInitialize {
  my ($self, $params) = @_;
  $self->{title} = 'Background Process Lister';
  $self->{params} = $params;
  $self->{ListMode} = "All";
  $self->{checkboxes}->{InLast} = 1;
  $self->{InLastInterval} = "12 hours";
  Dispatch::Select::Background->new(sub {
    my($disp) = @_;
    if($self->{checkboxes}->{Refresh}){
       $self->AutoRefreshDiv('WorklistContentResponse',
         'WorklistContentResponse');
    }
    $disp->timer(10);
  })->queue();
}

sub HeaderResponse{
  my($this, $http, $dyn) = @_;
  return $this->RefreshEngine($http, $dyn,'<center><h1><?dyn="title"?></h1></center>');

}

sub ContentResponse {
  my ($self, $http, $dyn) = @_;
  $http->queue("<div id=\"WorklistContentResponse\">");
  $self->WorklistContentResponse($http, $dyn);
  $http->queue("</div>");
}
sub WorklistContentResponse {
  my ($self, $http, $dyn) = @_;
  my $q_name = "GetBackgroundJobsAll";
  my @args;
  if($self->{ListMode} eq "running"){
    $q_name = "GetBackgroundJobsRunning";
  } elsif($self->{ListMode} eq "errored"){
    $q_name = "GetBackgroundJobsErrored";
  } elsif($self->{ListMode} eq "finished"){
    $q_name = "GetBackgroundJobsFinished";
  } else {
    $self->{ListMode} = "all";
  }
  if($self->{checkboxes}->{InLast}){
    $q_name = $q_name . "InLast";
    push(@args, $self->{InLastInterval});
  }
  $self->{List} = [];
#  print STDERR "##########################\n" .
#  "Query: $q_name(";
#  for my $i (0 .. $#args){
#    print STDERR "$args[$i]";
#    unless($i == $#args){ print STDERR ", " }
#  }
#  print STDERR ")\n" .
#  "##########################\n";
  Query($q_name)->RunQuery(sub{
    push(@{$self->{List}}, $_[0]);
  }, sub {}, @args);
  $http->queue("<table class=\"table table-striped\">");
  $http->queue("<tr><th>sid</th><th>wid</th>" .
    "<th>bid</th><th>aid</th><th>status</th><th>input</th>" .
    "<th>stdout</th><th>stderr</th>" .
    "<th>invoker</th><th>since</th><th>command_line</th>" .
    "<th>invoked</th><th>notify</th><th>node_hostname</th>" .
    "<th>background_queue_name</th></tr>");
  my $rows_printed = 0;
  my $num_rows = @{$self->{List}};
  for my $i (@{$self->{List}}){
    $http->queue("<tr>");
    for my $j (0 .. 4){
      unless(defined($i->[$j])) {$i->[$j] = "" }
      $http->queue("<td>$i->[$j]</td>");
    }
    $http->queue("<td>");
    if(defined $i->[5]){
      $http->queue("<a class=\"btn btn-primary\" " .
        "href=\"DownloadTextAttachment?obj_path=$self->{path}&" .
        "file_id=$i->[5]&type=Input\">$i->[5]</a>");
    }
    $http->queue("</td>");
    $http->queue("<td>");
    if(defined $i->[6]){
      $http->queue("<a class=\"btn btn-primary\" " .
        "href=\"DownloadTextAttachment?obj_path=$self->{path}&" .
        "file_id=$i->[6]&type=Stdout\">$i->[6]</a>");
    }
    $http->queue("</td>");
    $http->queue("<td>");
    if(defined $i->[7]){
      $http->queue("<a class=\"btn btn-primary\" " .
        "href=\"DownloadTextAttachment?obj_path=$self->{path}&" .
        "file_id=$i->[7]&type=Stderr\">$i->[7]</a>");
    }
    for my $j (8 .. $#{$i}){
      unless(defined($i->[$j])) {$i->[$j] = "" }
      $http->queue("<td>$i->[$j]</td>");
    }
    $http->queue("</tr>");
    $rows_printed += 1;
    if($rows_printed >= 100){ last }
  }
  $http->queue("</table>");
  if($rows_printed != $num_rows){
    $http->queue("<p>Only $rows_printed of $num_rows printed</p>");
  }
}
sub DownloadTextAttachment{
  my ($self, $http, $dyn) = @_;
  my $type = $dyn->{type};
  my $file_id = $dyn->{file_id};
  my $f_name = "$type" . "_$file_id.txt";
  my $rows;
  $http->DownloadHeader("text/csv", "$f_name");
  my $path;
  Query('GetFilePath')->RunQuery(sub{
    $path = $_[0]->[0];
  }, sub{}, $file_id);
  open FILE, "<$path";
  while(my $line = <FILE>){
    $http->queue($line);
  }
  close FILE;
}
sub SubprocessInvocationContentResponse {
  my ($self, $http, $dyn) = @_;
  $http->queue("Hello World (SubprocessInvocationContentResponse)");
}
sub BackgroundSubprocessContentResponse {
  my ($self, $http, $dyn) = @_;
  $http->queue("Hello World (BackgroundSubprocessContentResponse)");
}
sub ListAll{
  my ($self, $http, $dyn) = @_;
  $self->{ListMode} = "all";
}
sub ListRunning{
  my ($self, $http, $dyn) = @_;
  $self->{ListMode} = "running";
}
sub ListErrored{
  my ($self, $http, $dyn) = @_;
  $self->{ListMode} = "errored";
}
sub ListFinished{
  my ($self, $http, $dyn) = @_;
  $self->{ListMode} = "finished";
}
sub MenuResponse {
  my ($self, $http, $dyn) = @_;
  $http->queue($self->CheckBoxDelegate("checkboxes", "Refresh",
    $self->{checkboxes}->{Refresh} ? 1: 0,
    { op => "SetCheckbox",
      sync => "Update();" }));
  $http->queue(" Refresh<hr>");
  $self->NotSoSimpleButton($http, {
     op => "ListAll",
     caption => "All",
     sync => "Update();",
     class => ($self->{ListMode} eq "all") ?
      'btn btn_primary' : 'btn btn-default'
  });
  $http->queue("<br>");
  $self->NotSoSimpleButton($http, {
     op => "ListRunning",
     caption => "Running",
     sync => "Update();",
     class => ($self->{ListMode} eq "running") ?
      'btn btn_primary' : 'btn btn-default'
  });
  $http->queue("<br>");
  $self->NotSoSimpleButton($http, {
     op => "ListErrored",
     caption => "Errored",
     sync => "Update();",
     class => ($self->{ListMode} eq "errored") ?
      'btn btn_primary' : 'btn btn-default'
  });
  $http->queue("<br>");
  $self->NotSoSimpleButton($http, {
     op => "ListFinished",
     caption => "Finished",
     sync => "Update();",
     class => ($self->{ListMode} eq "finished") ?
      'btn btn_primary' : 'btn btn-default'
  });
  $http->queue("<br>");
  $http->queue("<hr>");
  $http->queue($self->CheckBoxDelegate("checkboxes", "InLast",
    $self->{checkboxes}->{InLast} ? 1: 0,
    { op => "SetCheckbox",
      sync => "Update();" }));
  $http->queue("In last:<br>");
  if($self->{checkboxes}->{InLast}){
    $self->BlurEntryBox($http, {
      name => "InLastInterval",
      op => "SetInLastInterval",
      id => "InLastInterval",
      value => "$self->{InLastInterval}"
    }, "Update();");
  }
}
sub SetInLastInterval{
  my ($self, $http, $dyn) = @_;
  $self->{InLastInterval} = $dyn->{value};
}
sub SetCheckbox{
  my ($self, $http, $dyn) = @_;
#  print STDERR "##################\n";
#  for my $i (keys %{$dyn}){
#    print STDERR "dyn{$i} =  $dyn->{$i}\n";
#  }
#  print STDERR "##################\n";
  my $checked = 0;
  if($dyn->{checked} eq "true"){
    $checked = 1;
  }
  $self->{$dyn->{group}}->{$dyn->{value}} = $checked;
}
sub ScriptButton {
  my ($self, $http, $dyn) = @_;
  my $parent = $self->parent;
  if($parent->can("ScriptButton")){
    $parent->ScriptButton($http, $dyn);
  }
}

1;
