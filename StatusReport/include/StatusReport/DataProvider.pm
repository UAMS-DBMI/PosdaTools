package StatusReport::DataProvider;
# 
# A package to provide data for charts in StatusReport
#

use Modern::Perl '2010';
use Method::Signatures::Simple;

use Dispatch::NamedObject;
use Dispatch::Select;

use BS::Table;
use AppController::StatusInfo;

use JSON;

use vars '@ISA';

@ISA = ("Dispatch::NamedObject");

method new($class: $sess, $path, $databases) {
  my $this = Dispatch::NamedObject->new($sess, $path);
  $this->{Databases} = $databases;

  bless $this, $class;
  return $this;
}

method RecBacklog($http, $dyn) {
  $http->TextHeader();

  AppController::StatusInfo::get_rec_backlog_async(
    $self->{Databases}->{stats}, func($results) {
    # results come back as list of hashrefs, need to convert to static list
    my $ret = [];
    for my $row (@{$results}) {
      push @$ret, $row->{max_dirs_in_backlog};
    }

    $http->queue(encode_json($ret));
  });
}

method DBBacklog($http, $dyn) {
  $http->TextHeader();

  AppController::StatusInfo::get_db_backlog_async(
    $self->{Databases}->{stats}, func($results) {
    # results come back as list of hashrefs, need to convert to static list
    my $ret = [];
    for my $row (@{$results}) {
      push @$ret, $row->{max_db_backlog};
    }

    $http->queue(encode_json($ret));
  });
}

method UploadCountTable($http, $dyn) {
  $http->TextHeader();

  AppController::StatusInfo::get_recent_uploads_async(
    $self->{Databases}->{files}, func($results) {
    $http->queue(BS::Table::from_hashes($results));
  });
}

1;
