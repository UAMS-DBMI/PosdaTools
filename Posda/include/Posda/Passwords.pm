package Posda::Passwords;

use Modern::Perl '2015';
use Method::Signatures::Simple;
use Digest::SHA 'sha256_base64';

func make_salt($len) {
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

func encode($password) {
  my $salt = make_salt();
  return _encode($salt, $password);
}

func _encode($salt, $password) {
  return "$salt," . sha256_base64($salt . $password);
}

func is_valid($enc_password, $candidate_password) {
  my ($salt, $text) = split(',', $enc_password);

  my $new_text = _encode($salt, $candidate_password);

  if ($enc_password eq $new_text) {
    return 1;
  } else {
    return 0;
  }
}

1;
