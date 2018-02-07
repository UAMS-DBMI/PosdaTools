package Posda::DownloadableFile;

use overload
  '""' => 'stringify';

use Modern::Perl;
use Method::Signatures::Simple;

use Data::UUID;
use DBI;

use Posda::Config ('Database', 'Config');

our $URL = Config('api_url');
our $ug = Data::UUID->new;

method new($class: $file_id, $mime_type, $valid_until) {
  my $self = {
    file_id => $file_id,
    mime_type => $mime_type,
    valid_until => $valid_until
  };
  bless $self, $class;

  $self->_make;
  $self->_get_path;

  return $self;
}

method stringify() {
  return $self->{link};
}

func get_uuid() {
	return lc $ug->create_str();
}

method _get_path() {
  my $dbh = DBI->connect(Database('posda_files'));
  my $sth = $dbh->prepare(qq{
    select root_path || '/' || rel_path as path
    from file_location
    natural join file_storage_root
    where file_id = ?
  });

  $sth->execute($self->{file_id});

  my $rows = $sth->fetchrow_arrayref;
  $sth->finish();
  my $path = $rows->[0];

  $dbh->disconnect();

  $self->{path} = $path;
}

method _make() {
  my $uuid = get_uuid();

  my $dbh = DBI->connect(Database('posda_files'));
  my $sth = $dbh->prepare(qq{
    insert into downloadable_file 
    (file_id, mime_type, valid_until, security_hash)
    values (?, ?, ?, ?)
    returning downloadable_file_id
  });

  $sth->execute($self->{file_id},
                $self->{mime_type},
                $self->{valid_until},
                $uuid);

  my $rows = $sth->fetchrow_arrayref;
  $sth->finish();
  my $dl_file_id = $rows->[0];

  $dbh->disconnect();

  $self->{link} = "$URL/file/$dl_file_id/$uuid";
  $self->{downloadable_file_id} = $dl_file_id;
  $self->{security_hash} = $uuid;
}

func make($file_id, $mime_type, $valid_until) {
  return Posda::DownloadableFile->new($file_id, $mime_type, $valid_until);
}

func make_csv($file_id, $valid_until) {
  return make($file_id, 'text/csv', $valid_until);
}

1;
