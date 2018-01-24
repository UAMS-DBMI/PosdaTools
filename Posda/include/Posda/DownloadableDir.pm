package Posda::DownloadableDir;


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

func make($path) {
  my $uuid = get_uuid();

  my $dbh = DBI->connect(Database('posda_files'));
  my $sth = $dbh->prepare(qq{
    insert into downloadable_dir 
    (security_hash, creation_date, path)
    values (?, now(), ?)
    returning downloadable_dir_id
  });

  $sth->execute($uuid, $path);

  my $rows = $sth->fetchrow_arrayref;
  $sth->finish();
  my $dl_dir_id = $rows->[0];

  $dbh->disconnect();

  return "$URL/dir/$dl_dir_id/$uuid";
}

1;
