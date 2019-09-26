package BS::Table;

use Modern::Perl '2010';


# Generate a Bootstrap table dynamically,
# from an arrayref of hashrefs
sub from_hashes {
  my ($list_of_hashes) = @_;
  my @lines;

  push @lines, q/<table class="table">/;

  # build the header
  my $first_row = @{$list_of_hashes}[0];

  push @lines, "<tr>";
  for my $col (sort keys %$first_row) {
    push @lines, "<th>$col</th>";
  }
  push @lines, "</tr>";

  for my $row (@$list_of_hashes) {
    push @lines, "<tr>";
    for my $val (sort keys %$row) {
      push @lines, "<td>$row->{$val}</td>";
    }
    push @lines, "</tr>";
  }

  push @lines, "</table>";
  return join("\n", @lines);
}

1;
