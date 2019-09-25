package Posda::Passwords;

use Modern::Perl '2010';
use Digest::SHA 'sha256_base64';

sub make_salt {
  my ($len) = @_;
  if (not defined $len) {
    $len = 8;  # default length
  }
  my @chars = ('.', '/', 0..9, 'A'..'Z', 'a'..'z');
  my $result;

  while ($len--) {
    $result .= $chars[rand @chars];
  }

  return $result;
}

sub encode {
  my ($password) = @_;
  my $salt = make_salt();
  return _encode($salt, $password);
}

sub _encode {
  my ($salt, $password) = @_;
  return "$salt," . sha256_base64($salt . $password);
}

sub is_valid {
  my ($enc_password, $candidate_password) = @_;
  my ($salt, $text) = split(',', $enc_password);

  my $new_text = _encode($salt, $candidate_password);

  if ($enc_password eq $new_text) {
    return 1;
  } else {
    return 0;
  }
}

1;
