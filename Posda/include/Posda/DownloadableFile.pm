package Posda::DownloadableFile;


use Modern::Perl;
use Method::Signatures::Simple;

use Data::UUID;
use DBI;

use Posda::Config ('Database', 'Config');

our $URL = Config('api_url');
our $ug = Data::UUID->new;

func get_uuid() {
	return lc $ug->create_str();
}

func make($file_id, $mime_type, $valid_until) {
  my $uuid = get_uuid();

  my $dbh = DBI->connect(Database('posda_files'));
  my $sth = $dbh->prepare(qq{
    insert into downloadable_file 
    (file_id, mime_type, valid_until, security_hash)
    values (?, ?, ?, ?)
    returning downloadable_file_id
  });

  $sth->execute($file_id, $mime_type, $valid_until, $uuid);

  my $rows = $sth->fetchrow_arrayref;
  $sth->finish();
  my $dl_file_id = $rows->[0];

  $dbh->disconnect();

  return "$URL/file/$dl_file_id/$uuid";
}

func make_csv($file_id, $valid_until) {
  return make($file_id, 'text/csv', $valid_until);
}

1;
