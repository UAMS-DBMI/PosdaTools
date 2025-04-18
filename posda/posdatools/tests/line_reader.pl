################################################################################
# Test Dispatch::LineReader
################################################################################

use lib 'Posda/include/';

use Modern::Perl '2010';

use Dispatch::LineReader;
use Dispatch::Select;

use Test::Simple tests => 4;

ok(1 + 1 == 2 , 'warmup to make sure everything is sane');

my @lines;

Dispatch::LineReader->new_cmd("echo '1\n2\n3'",
  sub {
  my ($line) = @_;
    push @lines, $line;
  },
  sub {
    ok(scalar @lines, 'line reader read lines and called finish');
    ok(join('|', @lines) eq '1|2|3', 'correct lines were returned');
  });


my @second_lines;
# test a second copy just to make sure dispatch is working
Dispatch::LineReader->new_cmd("echo a single line",
  sub {
  my ($line) = @_;
    push @second_lines, $line;
  },
  sub {
    ok(scalar @second_lines == 1, 'only a single line was generated');
  });

# Start the dispatch loop
Dispatch::Select::Dispatch(); 
