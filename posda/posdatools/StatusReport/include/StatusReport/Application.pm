package StatusReport::Application;
#
# A Status Report application
#

use vars '@ISA';
@ISA = ("GenericApp::Application");

use Modern::Perl '2010';
use Method::Signatures::Simple;

use GenericApp::Application;
use StatusReport::DataProvider;

use Posda::Config 'Config';


method SpecificInitialize() {
  $self->{Mode} = "Initialized";
  StatusReport::DataProvider->new($self->{session}, 'DataProvider');
}

method MenuResponse($http, $dyn) {
  $self->ReallySimpleButton($http, {
    caption => "Refresh",
    onClick => "javascript:RefreshCharts();"
  });
}

method ContentResponse($http, $dyn) {
  $http->queue(qq{
    <h2>Status Report</h2>

    <a href="http://${\Config('external_hostname')}:19999" target="blank" class="btn btn-primary">
      System Monitor
    </a>

    <div id="chart1">
      <h3>dirs_in_receive_backlog over last 24 hours</h3>
      <div class="spinner" style="position:relative"></div>
      <svg></svg>
    </div>

    <div id="chart2">
      <h3>db_backlog over last 24 hours</h3>
      <div class="spinner" style="position:relative"></div>
      <svg></svg>
    </div>

    <div id="count_table">
      <div class="spinner" style="position:relative"></div>
      <div class="content"></div> 
    </div>
  });
}

1;
