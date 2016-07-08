package Posda::ConfigRead;

use Modern::Perl '2010';
use Method::Signatures::Simple;
use JSON;

method new($class: $dir) {
  my $self = {
    dir => $dir
  };
  bless $self, $class;

  $self->ReadJsonFiles($dir);
  return $self;
}

method ReadJsonFile($file) {
  my $text = "";
  my $data;
  my $cf;

  unless (open($cf, '<', $file)) {
    print STDERR "ReadJsonFile:: can not open config file: $file, Error $!.\n";
    return undef;
  }

  # load the file in, ignoring comment lines
  # NOTE: JSON does not actually allow comments, so they have to be 
  # stripped out here!
  while (<$cf>) { 
    chomp; 
    unless ($_ =~ m/^\s*\/\//) {
      $text .= $_;
    } 
  }
  close($cf);

  # replace environment variables in the input json text
  for my $v (%ENV) {
    if ($v =~ /^POSDA_/) {  # Only replace POSDA_ vars
      $text =~ s/$v/$ENV{$v}/g;
    }
  }

  my $json = JSON->new();
  $json->relaxed(1);

  eval {
    $data = $json->decode($text);
  };

  if ($@) {
    print STDERR "ReadJsonFile:: bad json file: $file.\n";
    print STDERR "##########\n$@\n###########\n";
    $self->{BadJson}->{$file} = $@;
    return undef;
  }
  return $data;
}

method ReadJsonFiles($dir) {
  my $dh;

  unless(opendir $dh, $dir) {
    die "can't opendir $dir";
  }

  while (my $f = readdir $dh){
    if ($f =~ /^\./) { 
      next;
    }
    unless ($f =~ /^(.*)\.json$/) { 
      next;
    }

    my $base = $1;
    unless (-f "$dir/$f") { 
      next;
    }
    $self->{config}->{$base} = $self->ReadJsonFile("$dir/$f");
  }
}

1;
