################################################################################
# A test file, for doing test things.
################################################################################

use lib 'Posda/include/';

use Modern::Perl '2010';

use Data::Dumper;
use Storable;
use JSON;

use Posda::UUID;
use Data::UUID;

use Posda::Nicknames2;


use List::Util;


my $root = '/mnt/intake1-data/tcia/storage_site';

opendir (my $dir, $root);
my @files = readdir $dir;
closedir $dir;

# remove everything that isn't pure hex
@files = grep {
  /^[0-9A-F]+$/;
} @files;

# convert hex to ascii
my @ascii_files = map {
  pack 'H*', $_;
} @files;

$/ = ' ';
chomp @ascii_files;


my %file_map;
for my $i (0..$#ascii_files) {
  $file_map{$ascii_files[$i]} = "$root/$files[$i]";
}

map {
  symlink($file_map{$_}, "links/$_");
} keys %file_map;
