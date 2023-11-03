package Posda::File::Import;

{
  package Posda::File::Import::Response;

  use JSON 'decode_json';

  sub new_from_response {
    my ($class, $response) = @_;

    if ($response->is_success) {
      return new_from_success($class, $response->decoded_content);
    } else {
      print STDERR "API response failure: $response->decoded_content\n";
      return new_from_error($class, $response->decoded_content);
    }
  }

  sub new_from_error {
    my ($class, $response_content) = @_;
    # TODO parse the error
    my $self = {
      error => 1,
      error_message => $response_content,
    };

    return bless $self, $class;
  }

  sub new_from_success {
    my ($class, $response_content) = @_;

    my $obj = decode_json($response_content);

    my $self = {
      error => 0,
      response => $obj
    };

    return bless $self, $class;
  }

  sub is_error {
    my ($self) = @_;
    return $self->{error};
  }

  sub file_id {
    my ($self) = @_;
    return $self->{response}->{file_id};
  }

  sub message {
    my ($self) = @_;
    return $self->{error_message};
  }
}


use Modern::Perl;
use Digest::MD5;
use Posda::Config 'Config';
use Data::Dumper;
use URI;

use HTTP::Request::StreamingUpload;
use LWP::UserAgent;


my $API_URL = Config('internal_api_url');
my $API_TOKEN = Config('api_system_token');

sub digest_file {
  my ($filename) = @_;
  local $/ = undef;
  open my $fh, '<', $filename;
  binmode $fh;
  my $md5 = Digest::MD5->new->addfile($fh)->hexdigest;
  close $fh;

  return $md5;
}

sub insert_file {
  my ($filename, $comment, $import_event_id) = @_;

  # print STDERR "========= Posda::File::Import::insert_file called!\n";
  # print STDERR "API_KEY=$API_TOKEN\n";

  if (not defined $comment) {
    $comment = "Added by Perl Job";
  }

  if (not -e $filename) {
      return Posda::File::Import::Response->new_from_error(
        "$filename does not exist!"
      );
  }

  my $digest = digest_file($filename);
  my $url = URI->new($API_URL . '/v1/import/file');
  if(defined $import_event_id){
    $url->query_form(
      digest => $digest,
      localpath => $filename,
      import_event_id => $import_event_id
    );
  } else {
    $url->query_form(
      digest => $digest,
      localpath => $filename,
      comment => $comment
    );
  }

  my $req = HTTP::Request::StreamingUpload->new(
      PUT     => $url,
      path    => $filename,
      headers => HTTP::Headers->new(
          'Content-Type'   => 'application/octet-stream',
          'Content-Length' => -s $filename,
      ),
  );
  my $response = LWP::UserAgent->new->request($req);

  return Posda::File::Import::Response->new_from_response($response);
}

sub Test {
  opendir(DIR,".") or die "Cannot open dir\n";
  my @files = readdir(DIR);
  closedir(DIR);
  foreach my $file (@files) {
    if (-d $file) { next }
    say $file;
    my $import_response = insert_file $file;

    if (not $import_response->is_error) {
      say "File inserted, file_id: " . $import_response->file_id;
    } else {
      say "There was an error:";
      say $import_response->message;
    }
  }
}

sub SingleTest {
  my $file = "tags";
  my $import_response = insert_file $file;

  if (not $import_response->is_error) {
    say "File inserted, file_id: " . $import_response->file_id;
  } else {
    say "There was an error:";
    say $import_response->message;
  }

}
# Test;
# SingleTest;


1;
