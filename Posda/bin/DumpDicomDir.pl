#!/usr/bin/perl -w
#
#Copyright 2008, Bill Bennett
# Part of the Posda package
# Posda may be copied only under the terms of either the Artistic License or the
# GNU General Public License, which may be found in the Posda Distribution,
# or at http://posda.com/License.html
#
use Cwd;
use strict;
use Posda::DicomDir;

my $usage = "usage: $0 <file> <ID> <level>";
unless($#ARGV == 2) {die $usage}
Posda::Dataset::InitDD();

my $infile = $ARGV[0];
unless($infile =~ /^\//) {$infile = getcwd."/$infile"}
my $print_id = $ARGV[1];
my $level = $ARGV[2];
unless(defined $level){ $level = 0 }
my $dir = Posda::DicomDir->new_from_file($infile);

print "File Set ID: $dir->{fs_id}\n";
if(defined $dir->{fs_desc_id}){
  my $path = join "/", @{$dir->{fs_desc_id}};
  print "Descriptor file: $path\n";
}
dump_dir_rec($dir->{dir_items}, 0, $level);
sub dump_dir_rec{
  my($list, $cur_level, $end_level) = @_;
  my $num_recs = @$list;
  print "Has $num_recs level $cur_level records\n";
  if($cur_level == $end_level){
    return;
  }
  for my $i (0 .. $num_recs - 1){
    print "Level $cur_level, item $i ";
    my $item = $list->[$i];
    if($item->{in_use}){
       print "(ACTIVE) ";
    } else {
       print "(INACTIVE) ";
    }
    print "$item->{type}:\n";
    for my $key (sort keys %$item){
      unless(defined $item->{$key}){ next }
      if(
        $key eq "children" || $key eq "in_use" || 
        $key eq "type" || $key eq "identifier"
      ){ next }
      if($key eq "file_offset" || $key eq "length"){
        printf("$key: %04x\n", $item->{$key});
        next;
      }
      if(ref($item->{$key}) eq "ARRAY"){
        my $value = join("/", @{$item->{$key}});
        print "$key: $value\n";
      } else {
        print "$key: $item->{$key}\n";
      }
    }
    if($print_id){
      $item->{identifier}->DumpStyle4(\*STDOUT);
    }
    if(exists $item->{children}){
      dump_dir_rec($item->{children}, $cur_level + 1, $end_level);
    }
  }
}
if($#{$dir->{parse_errors}} >= 0){
  print "Errors encountered in parsing:\n";
  for my $err(@{$dir->{parse_errors}}){
    print("\t$err\n");
  }
}
