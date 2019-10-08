package Posda::DownloadableDir;

use overload
  '""' => 'stringify';

use Modern::Perl;

use Data::UUID;
use DBI;

use Posda::Config ('Database', 'Config');

our $URL = Config('api_url');
our $ug = Data::UUID->new;


sub new {
  my ($class, $path) = @_;
  my $self = {
    path => $path
  };
  bless $self, $class;

  $self->_make();

  return $self;
}

sub stringify {
  my ($self) = @_;
  return $self->{link};
}

sub _make {
  my ($self) = @_;
  my $uuid = get_uuid();

  my $dbh = DBI->connect(Database('posda_files'));
  my $sth = $dbh->prepare(qq{
    insert into downloadable_dir 
    (security_hash, creation_date, path)
    values (?, now(), ?)
    returning downloadable_dir_id
  });

  $sth->execute($uuid, $self->{path});

  my $rows = $sth->fetchrow_arrayref;
  $sth->finish();
  my $dl_dir_id = $rows->[0];

  $dbh->disconnect();

  $self->{link} = "$URL/dir/$dl_dir_id/$uuid";
  $self->{downloadable_dir_id} = $dl_dir_id;
  $self->{security_hash} = $uuid;
}

sub get_uuid {
	return lc $ug->create_str();
}

# Deprecated, included for backward compatability
sub make {
  my ($path) = @_;
  return Posda::DownloadableDir->new($path);
}

1;
