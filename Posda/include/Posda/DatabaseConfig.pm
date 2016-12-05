package Posda::DatabaseConfig;

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
  open( my $fh, '<', '/home/posda/PosdaTools/Config/databases.json');
  my $json_text = <$fh>;
  my $data = decode_json($json_text);

  return $data;
}

1;
