package Posda::Nicknames2Factory;
use Modern::Perl '2010';
use Method::Signatures::Simple;

use Posda::Nicknames2;
use DBI;

func get($project_name, $site_name, $subj_id) {
  Posda::Nicknames2::get($project_name, $site_name, $subj_id);
}

func clear() {
  Posda::Nicknames2::clear();
}

say STDERR "Posda::Nicknames2Factory is now deprecated. You can call the get() function directly from Posda::Nicknames2.";

1;
