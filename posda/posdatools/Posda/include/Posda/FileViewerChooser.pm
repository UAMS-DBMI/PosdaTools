package Posda::FileViewerChooser;
# I choose what viewer to use for a file, based on file_id

use Modern::Perl;

use Posda::DB 'Query';

{
  package ChooserError;
  use parent 'Posda::Error';
}

our $text_class = 'Posda::PopupTextViewer';
our $dicom_class = 'Quince';


# returns a class for a popup viewer that should be
# used for viewing the given file_id
sub choose {
  my ($file_id) = @_;

  # get the mime type of the file
  my $result = Query('FileType')->FetchOneHash($file_id);
  unless(defined $result) { return undef }
  defined $result or die ChooserError->new("file not found: $file_id");

  my $type = $result->{file_type};



  defined $type or $type = '';
  if ($type =~ /text/i) {
    return $text_class;
  } else {
    return $dicom_class;
  }
}


1;
