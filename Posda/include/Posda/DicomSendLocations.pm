package Posda::DicomSendLocations;

use Modern::Perl '2010';
use Method::Signatures::Simple;

use Env;
use JSON;

our $cache;

func get() {
  if (not defined $cache) {
    $cache = _load();
  }

  return $cache;
}

func _load() {
  local $/;
  open( my $fh, '<', $ENV{POSDA_DICOM_SEND_CONFIG});
  my $json_text = <$fh>;
  my $data = decode_json($json_text);

  return $data;
}

1;
