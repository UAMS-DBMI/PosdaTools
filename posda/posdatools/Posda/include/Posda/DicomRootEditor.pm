package Posda::DicomRootEditor;
use strict;

use Dispatch::LineReader;
use Posda::PopupWindow;
use Posda::DB qw( Query );
use JSON;
use REST::Client;
use Try::Tiny;

use vars qw( @ISA );
@ISA = ("Posda::PopupWindow");
sub MakeQueuer{
  my($http) = @_;
  my $sub = sub {
    my($txt) = @_;
    $http->queue($txt);
  };
  return $sub;
}

sub SpecificInitialize {
  my ($self, $params) = @_;
  $self->{title} = "DICOM Roots Row Editor";
  $self->{MY_API_URL} = "$ENV{POSDA_INTERNAL_API_URL}/v1/dicom_roots";
  $self->{params} = $params;
  $self->{submission_id} = $params->{rootid};
  $self->{client} = REST::Client->new();
  $self->{client}->GET("$self->{MY_API_URL}/getRecord/$self->{submission_id}");
  $self->{record_data}  = decode_json($self->{client}->responseContent());

}

sub ContentResponse {
 my ($self, $http, $dyn) = @_;
 $http->queue("<h3>Requesting changes to DICOM Root record.</h3>");
 $http->queue("Site Name:   $self->{record_data}->[0]->{site_name}</br>");
 $http->queue("Site Code: $self->{record_data}->[0]->{site_code}</br>");
 $http->queue("Collection Name: $self->{record_data}->[0]->{collection_name}</br>");
 $http->queue("Collection Code: $self->{record_data}->[0]->{collection_code}</br>");
 $http->queue("Patient Id Prefix: $self->{record_data}->[0]->{patient_id_prefix}</br>");
 $http->queue("Body Part: $self->{record_data}->[0]->{body_part}</br>");
 $http->queue("Access Type: $self->{record_data}->[0]->{access_type}</br>");
 $http->queue("Baseline Date: $self->{record_data}->[0]->{baseline_date}</br>");
 $http->queue("Date Shift: $self->{record_data}->[0]->{date_shift}</br>");
}

sub MenuResponse {
  my ($self, $http, $dyn) = @_;
}
