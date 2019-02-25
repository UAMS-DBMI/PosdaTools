#!/usr/bin/perl -w
use strict;
use Posda::DB 'Query';
use Posda::Config 'Database';
my $con_str = Database('posda_files');
my $dbh = DBI->connect($con_str);
sub get_row_count{
  my($table) = @_;
  my $h = $dbh->prepare("select count(*) from $table;");
  my $count = 0;
  $h->execute;
  my $r = $h->fetchrow_hashref;
  $count = $r->{count};
  $h->finish;
  return $count;
}
my %tables;
my %schemas;
my %columns;
my %single_nat_joins;
my $get_cols = Query("ColumnsInTable");
Query("TableSizePosdaFiles")->RunQuery(sub {
  my($row) = @_;
  my($oid, $schema, $table_name, $row_estimate,
    $total_bytes, $index_bytes, $total,
    $toast_bytes, $index, $toast, $table) = @$row;
  $schemas{$schema}->{$table_name} = 1;
  $tables{$table_name} = {
    schema => $schema,
    total_bytes => $total_bytes,
    index_bytes => $index_bytes,
  };
  my $rc = get_row_count($table_name);
  $tables{$table_name}->{row_count} = $rc;
  $get_cols->RunQuery(sub {
    my($row) = @_;
    my $col = $row->[0];
    $tables{$table_name}->{columns}->{$col} = 1;
    $columns{$col}->{$table_name} = 1;
  }, sub {}, $table_name);
  print STDERR "$rc: $table_name\n";
}, sub {});
$dbh->disconnect;
for my $table (keys %tables){
  my @cols = sort keys %{$tables{$table}->{columns}};
  if(@cols > 1){
    for my $col (@cols){
      nj:
      for my $nj (keys %{$columns{$col}}){
        if($nj eq $table) { next nj }
        if($tables{$table}->{row_count} == 0) { next nj }
        if($tables{$nj}->{row_count} == 0) { next nj }
        $tables{$table}->{nj}->{$nj}->{$col} = 1;
      }
    }
  }
}
my %ColStren;
for my $schema (sort keys %schemas){
  for my $table (sort
    { $tables{$b}->{row_count} <=> $tables{$a}->{row_count} }
    keys %{$schemas{$schema}}
  ){
    my $t = $tables{$table};
    my $nj = $t->{nj};
    my @joins = sort keys %$nj;
    for my $j (0 .. $#joins){
      my $join = $joins[$j];
      my @cols = sort keys %{$nj->{$join}};
      if(@cols == 1) {
        $single_nat_joins{$cols[0]} = 1;
        $ColStren{$cols[0]} += 1;
      }
    }
  }
}
print "schema,table,num_rows,total_bytes,index_bytes,multiple natural joins,";
my @nat_join_cols = sort { $ColStren{$b} <=> $ColStren{$a} } keys %single_nat_joins;
for my $i (0 .. $#nat_join_cols){
  print "$nat_join_cols[$i]";
  unless($i == $#nat_join_cols) { print "," }
}
print "\r\n";
for my $schema (sort keys %schemas){
  for my $table (sort
    { $tables{$b}->{row_count} <=> $tables{$a}->{row_count} }
    keys %{$schemas{$schema}}
  ){
    my $t = $tables{$table};
    print "$schema,$table,$t->{row_count},$t->{total_bytes},";
    print "$t->{index_bytes},\"";
    my $nj = $t->{nj};
    my @joins = sort keys %$nj;
    my %sjoins;
    joinl:
    for my $j (0 .. $#joins){
      my $join = $joins[$j];
      my @cols = sort keys %{$nj->{$join}};
      if(@cols < 1) { next joinl }
      if(@cols == 1) { $sjoins{$cols[0]} = 1; next joinl }
      if(@cols >= 5) { next joinl }
      print "$join(";
      for my $i (0 .. $#cols){
        print($cols[$i]);
        if($i < $#cols) { print "," }
      }
      print ")";
      if($j < $#joins){ print "\n" }
    }
    print "\",";
    for my $i (0 .. $#nat_join_cols){
      my $col_name = $nat_join_cols[$i];
      if(exists $sjoins{$col_name}){ print "yes" }
      unless($i == $#nat_join_cols){ print "," }
    }
    print "\r\n";
  }
}
