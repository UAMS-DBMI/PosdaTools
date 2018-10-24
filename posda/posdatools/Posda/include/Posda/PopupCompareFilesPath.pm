package Posda::PopupCompareFilesPath;

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


method new($class: $session, $path, $params) {
  # TODO: handle case where params are not given
  my $from_filename = $params->{from_file};
  my $to_filename = $params->{to_file};

  # get the list of files with this SOP

  my $jsroot =
    $main::HTTP_APP_CONFIG->{config}->{Environment}->{JavascriptRoot};
  my $login_temp =
    $main::HTTP_APP_CONFIG->{config}->{Environment}->{LoginTemp};

  my $self = Posda::CompareFiles->new(
    $session,  
    $path,
    "$login_temp/$session", # temp path
    $jsroot, # js root
    $from_filename,
    $from_filename,
    $to_filename,
    $to_filename,
  );
}

1;
