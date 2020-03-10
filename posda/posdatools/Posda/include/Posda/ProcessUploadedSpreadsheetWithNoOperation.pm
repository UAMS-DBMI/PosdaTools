package Posda::ProcessUploadedSpreadsheetWithNoOperation;

use Posda::PopupWindow;
use Posda::PopupImageViewer;
use Posda::Config ('Config','Database');
use Posda::DB 'Query';
use Posda::NewerProcessPopup;

use DBI;
use URI;
use HTML::Entities;
use Debug;
my $dbg = sub {print STDERR @_};

use MIME::Base64;


use vars qw( @ISA );
@ISA = ("Posda::PopupWindow");

my $db_handle;

#params = {
#  "bindings" => {
#    <name> => <value>,
#    ...
#  },
#  "cols" => [
#    <col_name>,
#    ...
#  ],
#  "current_settings" => {
#    <name> => <value>,
#    ...
#  },
#  "input_file_id" => "8977",
#  "rows" => [
#    {
#      "Operation" => "MakeDownloadableDirectoryFromSpreadsheet",
#      "activity_id" => "235",
#      "notify" => "bbennett",
#      "stored_file_name" => "/nas/public/posda/storage/52/5f/f6/525ff67128bdbf13a8b024f14b62aa42",
#      "sub_dir" => "Barrow_2",
#      "uploaded_file_name" => "C:/DBMI/Submitting Sites/GBM-DSC-MRI-DRO-Barrow/from Nate dropbox Oct 2019 correction and beginning/Bo=15T\Dicom_001-TE1-TR1-FA1-Bo1-CAds1.dcm"
#    },
#    {
#      "Operation" => "",
#      "activity_id" => "",
#      "notify" => "",
#      "stored_file_name" => "/nas/public/posda/storage/14/54/5b/14545be7d5d06e9b7fc842a41db36a22",
#      "sub_dir" => "",
#};
#
sub SpecificInitialize{
  my($self,$params) = @_;
  $self->{title} = "Process Operation Popup";
  $self->{args} = {};
  $self->{meta_args} = {};
  $self->{Operations} = $params->{Operations};
  delete $params->{Operations};
  $self->{params} = $params;
  $self->{mode} = "initial";
}

sub SetDefaultInputAndArgs{
  my($self) = @_;
  for my $arg (@{$self->{params}->{command}->{args}}){
    if(exists $self->{params}->{prior_ss_args}->{$arg}){ #if prior_ss_arg, use it 
      $self->{args}->{$arg}  = ["from spreadsheet", $self->{params}->{prior_ss_args}->{$arg}];
    } elsif (exists $self->{params}->{current_settings}->{$arg}){ #elsif current_setting, use it
      $self->{args}->{$arg}  = ["from current_settings",  $self->{params}->{current_settings}->{$arg}],
    } elsif (exists $self->{bindings}->{$arg}) { #elsif binding, set it
      $self->{args}->{$arg}  = ["from bindings",  $self->{params}->{bindings}->{$arg}],
    } else {
      $self->{args}->{$arg}  = ["not present",  ""],
    }
  }
  $self->{InputLines} = [];
  for my $row (@{$self->{params}->{rows}}){
    my $line = $self->{params}->{command}->{input_line_format};
    for my $col (@{$self->{params}->{command}->{fields}}){
      $line =~ s/<$col>/$row->{$col}/g;
    }
    push @{$self->{InputLines}}, $line;
  }
}

sub ChooseOperation{
  my($this, $http, $dyn) = @_;
  my $op = $dyn->{chosen};
  $this->{params}->{command} = ActivityBasedCuration::Application->GetOperationDescription($op);
  $this->{params}->{command}->{create_file_from_rows} = 1;
  delete $this->{params}->{command}->{input_file_id};
  delete $this->{Operations};
  delete $this->{args};
  delete $this->{meta_args};
  delete $this->{mode};
  bless $this, "Posda::NewerProcessPopup";
  $this->SpecificInitialize($this->{params});
}

sub ContentResponse {
  my($self, $http, $dyn) = @_;
  if($self->{mode} eq "initial"){
  $self->RefreshEngine($http, $dyn, 
    '<div style="display: flex; flex-direction: column; align-items: flex-beginning; margin-bottom: 5px">' .
    '<h3>This Spreadsheet Has No Operation</h3><p> Choose one from table below</p>' .
    '<div id="div_Operation_List">' .
    '<table class="table table-striped table-condensed">' .
    '<caption>Available Operations</caption>' .
    '<tr><th>Operation</th><th>Command Line</th><th>Input Line Format</th><th># matches</th><th>Choose</th></tr>'
  );
  my %qualified_ops;
  my %is_col;
  for my $col (@{$self->{params}->{cols}}){
    $is_col{$col} = 1;
  }
  operation:
  for my $op (sort keys %{$self->{Operations}}){
    my $info = $self->{Operations}->{$op};
    unless(defined $info->{pipe_parms} && $info->{pipe_parms}) { next operation }
    my $num_hits = 0;
    for my $req_col (@{$info->{pipe_parmlist}}){
      unless($is_col{$req_col}) {  next operation }
      $num_hits += 1;
    }
    if($num_hits > 0){
      $qualified_ops{$op} = $num_hits;
    }
  }
  $self->{qualified_ops} = \%qualified_ops;
  for my $op (
    sort 
    { $qualified_ops{$b} <=> $qualified_ops{$a} || $a cmp $b }
    keys %qualified_ops
  ){
    my $info = $self->{Operations}->{$op};
    $http->queue("<tr><td>$op</td>");
    my $encoded_command = encode_entities($info->{cmdline});
    $http->queue("<td>$encoded_command</td>");
    my $encoded_input = encode_entities($info->{pipe_parms});
    $http->queue("<td>$encoded_input</td>");
    $http->queue("<td>$qualified_ops{$op}</td>");
    $http->queue("<td>");
    $self->DelegateButton($http, {
       op => "ChooseOperation",
       id => "ChooseOperation_$op",
       caption => "Choose",
       chosen => "$op",
       sync => 'Update();',
    });
    $self->NotSoSimpleButton($http, {
      op => "OpHelp",
      caption => "Help",
      cmd => $op,
      sync => "Update();",
    });
    $http->queue("</td>");
    $http->queue("</tr>");
  }
  $http->queue("</table></div></div>");
  } else {
    $http->queue("Unknown mode: $self->{mode}");
  }
}


sub MenuResponse{
  my($self, $http, $dyn) = @_;
  $http->queue(
    '<div style="display: flex; flex-direction: column; align-items: flex-beginning; margin-bottom: 5px">');
  if($self->{mode} eq "initial"){
    $self->DelegateButton($http, {
      op => "StartSubprocess",
      caption => "Start",
      sync => "Update();",
    });
    $self->DelegateButton($http, {
      op => "Cancel",
      caption => "Cancel",
      sync => "CloseThisWindow();",
    });
  } elsif($self->{mode} eq "waiting") {
    $http->queue("waiting");
  } elsif($self->{mode} eq "response_available") {
    $self->DelegateButton($http, {
      op => "Done",
      caption => "Cancel",
      sync => "CloseThisWindow();",
    });
  } else {
    $http->queue("Unknown mode: $self->{mode}");
  }
  $http->queue("</div>");
}

sub OpHelp {
  my ($self, $http, $dyn) = @_;

  my $details = [ $dyn->{cmd} ];


  my $child_path = $self->child_path("PopupHelp_$dyn->{cmd}");
  my $child_obj = ActivityBasedCuration::PopupHelp->new($self->{session},
                                              $child_path, $details);
  $self->parent->StartJsChildWindow($child_obj);
}


1;
