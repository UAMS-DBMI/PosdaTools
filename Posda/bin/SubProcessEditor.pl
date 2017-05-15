#!/usr/bin/perl -w
#
#Copyright 2013, Bill Bennett
# Part of the Posda package
# Posda may be copied only under the terms of either the Artistic License or the
# GNU General Public License, which may be found in the Posda Distribution,
# or at http://posda.com/License.html
#
use strict;
use Posda::Try;
use Posda::UUID;
use Digest::MD5;
use Debug;
my $dbg = sub { print STDERR @_ };
use Storable qw( store_fd fd_retrieve );
my $help = <<EOF;
 Anonymizer meant to run as a sub-process
 Receives parameters via fd_retrive from STDIN.
 Writes results to STDOUT via store_fd
 incoming data structure:
 \$in = {
   from_file => <path to from file>,
   to_file => <path to to file>,
   uid_substitutions => {
     <from_uid> => <to_uid>,
     ...
   },
   hash_unhashed_uid => {  # replace uid with hash of existing
     <short_ele> => <uid_root>,
     ...
   },
   short_ele_substitutions => {  # substitute if ele present with value
     <short_ele> => {
       <old_value> => <new_value>,
       ...
     },
     ...
   },
   short_ele_replacements => {  # replace if ele present
     <short_ele> => <new_value>,
   },
   full_ele_substitutions => {  # substitute if ele present with value
     <full_ele> => {
       <old_value> => <new_value>,
       ...
     },
     ...
   },
   full_ele_replacements => {  # if ele exists, give it new value
     <full_ele> => <value>,
     ...
   },
   full_ele_deletes => {
     <full_ele> => 1,
     ...
   },
   full_ele_additions => {  # add/overwrite this ele/value
     <full_ele> => <value>,
     ...
   },
   leaf_delete => {
     <short_ele> => 1,
   },
 };

 <full_ele> is a full element name, e.g.:
 "(3006,0010)[0](3006,0012)[0](3006,0014)[0](3006,0016)"
 <short_ele> is an individual element name, e.g.
 "(3006,0016)"
 The short element may match multiple full elements, and is mainly used
 with substitutions.
 
 All edits are performed in the order listed.  
 All except "leaf_delete", "full_ele_deletes" and "full_ele_additions" are 
   performed in a single mapping over all elements in the dataset.
 After this mapping, "full_ele_deletes" are performed and then
   "full_ele_additions are performed.
 "leaf_deletes are accumulated during the single mapping, and performed last.


 uid_substitutions and hash_unhashed_uid are NOT compatible, and
 will cause an error (which we will not detect ...)

EOF
if($#ARGV == 0 && ($ARGV[0] eq "-h")){
  print $help;
  exit;
}
my $results = {};
sub Error{
  my($message, $addl) = @_;
print STDERR "#################\n" .
  "Error: $message\n" .
  "#################\n";
  $results->{Status} = "Error";
  $results->{message} = $message;
  if($addl){ $results->{additional_info} = $addl }
  store_fd($results, \*STDOUT);
  exit;
}
my $buff;
#my $count = sysread(STDIN, $buff, 65535);
#unless(defined $count) { print STDERR "Child read error: $!\n" }
#print STDERR "read $count bytes\n";
#exit;
my $edits = fd_retrieve(\*STDIN);
unless(exists $edits->{from_file}){ Error("No from_file in edits") }
unless(-f $edits->{from_file}){ Error("file not found: $edits->{from_file}") }
$results->{from_file} = $edits->{from_file};
my @leaf_deletes;
my $edit_function = sub {
  my($ele, $sig) = @_;
  # uid_substitutions
  if($ele->{VR} eq "UI"){
    if($ele->{value} && ref($ele->{value}) eq "ARRAY"){
      for my $i (0 .. $#{$ele->{value}}){
        if(exists($edits->{uid_subsitutions}->{$ele->{value}->[$i]})){
          my $from = $ele->{value}->[$i];
          my $to = $edits->{uid_substitutions}->{$ele->{value}->[$i]};
          $ele->{value}->[$i] = $to;
          $results->{uid_substitutions} += 1;
        }
      }
    } elsif($ele->{value}){
      if(exists $edits->{uid_substitutions}->{$ele->{value}}){
        my $from = $ele->{value};
        my $to = $edits->{uid_substitutions}->{$ele->{value}};
        $ele->{value} = $to;
        $results->{uid_substitutions} += 1;
      }
    } else {
      print STDERR "element $sig has VR of UI and is undefined:\n";
      print STDERR "\t$edits->{from_file}\n";
    }
  }
  my $short;
  my $long;
  if($sig =~ /^(.*)(\(....,....\))$/){
    $short = $2;
    $long = $1;
  } elsif($sig =~ /^(.*)(\(....,\"[^\"]+\",..\))/){
    $short = $2;
    $long = $1;
  }
  if(defined $short){
  # leaf_delete
    if(exists $edits->{leaf_delete}->{$short}){
      if($long){
        push(@leaf_deletes, $sig);
      }
    }
  # hash_unhashed_uid
    if(exists $edits->{hash_unhashed_uid}->{$short}){
#      if(exists $edits->{uid_substitutions}){
#        die "Error: both uid_substitutions and hash_unhashed_uid present";
#      }
      my $uid = $ele->{value};
      my $root = $edits->{hash_unhashed_uid}->{$short};
      if($uid =~ /^$root.*$/){
        print STDERR "Not hashing previously hashed uid\n";
      } else {
        my $old = $ele->{value};
        my $ctx = Digest::MD5->new;
        $ctx->add($old);
        my $dig = $ctx->digest;
        $ele->{value} = "$root." . Posda::UUID::FromDigest($dig);
        $results->{hash_unhashed_uid} += 1;
      }
      my $to = $edits->{short_ele_substitutions}->{$short};
    }
  }
  # short_ele_substitutions
  if(defined $short){
    if(exists $edits->{short_ele_substitutions}->{$short}){
      my $from = $ele->{value};
      my $to = $edits->{short_ele_substitutions}->{$short};
      $ele->{value} = $edits->{short_ele_substitutions}->{$short};
      $results->{short_ele_substitutions} += 1;
    }
  }
  # full_ele_substitutions
  for my $s (keys %{$edits->{full_ele_substitutions}}){
    if($sig eq $s){
      if($ele->{value} eq $s){
        $ele->{value} = $edits->{full_ele_substitutions}->{$s};
        $results->{short_ele_substitutions} += 1;
      }
    }
  }
  # short_ele_replacements
  for my $s (keys %{$edits->{short_ele_replacements}}){
    if($short eq $s){
      $ele->{value} = $edits->{short_ele_replacements}->{$s};
      $results->{short_ele_replacements} += 1;
    }
  }
  # full_ele_replacements
  for my $s (keys %{$edits->{full_ele_replacements}}){
    if($sig eq $s){
      $ele->{value} = $edits->{full_ele_replacements}->{$s};
      $results->{full_ele_replacements} += 1;
    }
  }
};
my $try = Posda::Try->new($edits->{from_file});
unless(exists $try->{dataset}) { 
  Error("file $edits->{from_file} didn't parse", $try);
}
my $ds = $try->{dataset};
$ds->MapPvt($edit_function);
# full_ele_deletes
for my $s (keys %{$edits->{full_ele_deletes}}){
  $ds->Delete($s);
  $results->{full_ele_deletes} += 1;
}
# full_ele_additions
for my $s (keys %{$edits->{full_ele_additions}}){
  $ds->Insert($s, $edits->{full_ele_additions}->{$s});
  $results->{full_ele_additions} += 1;
}
# leaf_deletes
for my $s (@leaf_deletes){
  $ds->Delete($s);
  $results->{leaf_deletes} += 1;
}
eval {
  $ds->WritePart10($edits->{to_file}, $try->{xfr_stx}, "POSDA", undef, undef);
};
if($@){
  print STDERR "Can't write $edits->{to_file} ($@)\n";
  Error("Can't write $edits->{to_file}", $@);
}
$results->{to_file} = $edits->{to_file};
$results->{Status} = "OK";
store_fd($results, \*STDOUT);
