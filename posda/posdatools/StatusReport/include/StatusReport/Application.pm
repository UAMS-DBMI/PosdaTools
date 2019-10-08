package StatusReport::Application;
#
# A Status Report application
#

use vars '@ISA';
@ISA = ("GenericApp::Application");

use Modern::Perl '2010';

use GenericApp::Application;
use StatusReport::DataProvider;

use Posda::Config 'Config';


sub SpecificInitialize {
  my ($self) = @_;
  $self->{Mode} = "Initialized";
  StatusReport::DataProvider->new($self->{session}, 'DataProvider');
}

sub MenuResponse {
  my ($self, $http, $dyn) = @_;
  $self->ReallySimpleButton($http, {
    caption => "Refresh",
    onClick => "javascript:RefreshCharts();"
  });
}

sub ContentResponse {
  my ($self, $http, $dyn) = @_;
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
