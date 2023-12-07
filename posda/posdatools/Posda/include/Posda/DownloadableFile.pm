package Posda::DownloadableFile;

use overload
  '""' => 'stringify';

use Modern::Perl;

use Data::UUID;
use DBI;

use Posda::Config ('Database', 'Config');

our $URL = Config('api_url');
our $ug = Data::UUID->new;

sub new {
  my ($class, $file_id, $mime_type, $valid_until) = @_;
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

sub stringify {
  my ($self) = @_;
  return $self->{link};
}

sub get_uuid {
	return lc $ug->create_str();
}

sub _get_path {
  my ($self) = @_;
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

  # This is used only for some reports (PHI) which can be 
  # processed by the Glendor tool, *if installed*
  my $rel_url = "/glendor/process?f=$path";
  $self->{glendor_link} = qq{<a href="$rel_url" target="_blank">Glendor processed</a>};
}

sub _make {
  my ($self) = @_;
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

  my $rel_url = "/papi/file/$dl_file_id/$uuid";
  # link is now a full a tag, to allow for relative links
  $self->{link} = qq{<a href="$rel_url">downloaded_file_$dl_file_id</a>};
  $self->{macrolink} = qq{<a href="$rel_url?process=1">Macro processed</a>};
  $self->{downloadable_file_id} = $dl_file_id;
  $self->{security_hash} = $uuid;
  $self->{rel_url} = $rel_url;
}

sub make {
  my ($file_id, $mime_type, $valid_until) = @_;
  return Posda::DownloadableFile->new($file_id, $mime_type, $valid_until);
}

sub make_csv {
  my ($file_id, $valid_until) = @_;
  return make($file_id, 'text/csv', $valid_until);
}

1;
