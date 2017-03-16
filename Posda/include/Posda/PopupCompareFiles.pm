package Posda::PopupCompareFiles;

# 
# This is a Posda::PopupWindow wrapper around
# Posda::CompareFiles. It allows you to compare two files
# given their file_ids (inputs are from_file, to_file).
#

use Modern::Perl;
use Method::Signatures::Simple;

use Posda::Config ('Config','Database');

use Posda::CompareFiles;

use Data::Dumper;

# use vars qw( @ISA );
# @ISA = ("Posda::PopupWindow");

my $db_handle;

func get_filename($file_id) {
  # TODO: Add error handling
  my $qh = $db_handle->prepare(qq{
    select root_path || '/' || rel_path
    from file_sop_common 
    natural join file_location
    natural join file_storage_root
    where file_id = ?;
  });

  $qh->execute($file_id);
  my $rows = $qh->fetchall_arrayref();

  return $rows->[0]->[0];
}

method new($class: $session, $path, $params) {
  # TODO: handle case where params are not given
  my $from_file_id = $params->{from_file};
  my $to_file_id = $params->{to_file};

  # get the list of files with this SOP
  $db_handle = DBI->connect(Database('posda_files'));

  my $from_filename = get_filename($from_file_id);
  my $to_filename = get_filename($to_file_id);

  $db_handle->disconnect();

  my $jsroot =
    $main::HTTP_APP_CONFIG->{config}->{Environment}->{JavascriptRoot};
  my $login_temp =
    $main::HTTP_APP_CONFIG->{config}->{Environment}->{LoginTemp};

  my $self = Posda::CompareFiles->new(
    $session,  
    $path,
    "$login_temp/$session", # temp path
    $jsroot, # js root
    $from_file_id,
    $from_filename,
    $to_file_id,
    $to_filename,
  );
}

1;
