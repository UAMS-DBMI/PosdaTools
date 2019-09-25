use Modern::Perl '2010';

use autodie;

use Data::Dumper;

my $file = $ARGV[0];


# initially list only the node names

open (my $fh, '<', $file);

my @lines;
while (<$fh>) {
  if (/label.*{(.*)}/) {
    push @lines, $1;
  }
}

close($fh);

# cut off any pipe and anything after it
@lines = map {
  if (/([^\|]*)\|/) {
    $1;
  } else {
    $_;
  }
} @lines;

my @files = grep {
  /\//;
} @lines;

my @classes = grep {
  not /\//;
} @lines;

# print Dumper(\@files);
# print Dumper(\@classes);

say for @classes;

