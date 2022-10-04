package Posda::OHIF;

use strict;
use 5.30.0;
use experimental 'signatures';

use Posda::Config 'Config';

sub OpenSeriesButton($series_instance_uid) {
  my $external_hostname = Config('external_hostname');
  my $external_api_url = Config('api_url');
  my $config_url = "$external_api_url/v1/series/$series_instance_uid/ohif";
  my $url = "http://$external_hostname/ohif/viewer?url=$config_url";

  return qq{
    <a href="$url"
       class="btn btn-default"
    >
      Open in OHIF
    </a>
  };
}


1;
