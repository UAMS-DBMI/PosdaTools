#!/usr/bin/perl -w
use strict;
use Posda::DB::PosdaFilesQueries;
use Posda::Try;
use Posda::UUID;
my $usage = <<EOF;
BulkHashStructUids.pl <dir> <uid_root> <notify>
or
BulkHashStructUids.pl -h

Expects a list of SOP Instance UID's on STDIN
EOF
unless($#ARGV == 2) { die $usage}
my $dir = $ARGV[0];
my $root = $ARGV[1];
my $notify = $ARGV[2];
my @patterns = (
"(3006,0010)[<0>](0020,0052)",
"(3006,0010)[<0>](3006,0012)[<1>](0008,1155)",
"(3006,0010)[<0>](3006,0012)[<1>](3006,0014)[<2>](0020,000e)",
"(3006,0010)[<0>](3006,0012)[<1>](3006,0014)[<2>](3006,0016)[<3>](0008,1155)",
"(3006,0020)[<0>](3006,0024)",
"(3006,0039)[<0>](3006,0040)[<1>](3006,0016)[<2>](0008,1155)");
my @Files;
my $q = PosdaDB::Queries->GetQueryInstance("FirstFileForSopPosda");
line:
while(my $line = <STDIN>){
  chomp $line;
  my($path, $modality);
  $q->RunQuery(sub {
      my($row) = @_;
      ($path, $modality) = @$row;
    }, sub {},
    $line
  );
  unless($modality eq "RTSTRUCT") { next line };
  push(@Files, $path);
}
my $num_files = @Files;
print "$num_files queued for conversion\n";
fork and exit;
close STDOUT;
close STDIN;
open EMAIL, "|mail -s \"Posda Job Complete\" $notify" or die
  "can't open pipe ($!) to mail $notify";
print EMAIL "Hashing File list in following files.\n";
file:
for my $file (@Files){
  my $try = Posda::Try->new($file);
  unless(defined $try->{dataset}){
    print STDERR "Couldn't parse $file\n";
    next file;
  }
  my $ds = $try->{dataset};
  my $sop_inst = $ds->Get("(0008,0018)");
  my $modality = $ds->Get("(0008,0060)");
  my $new_file = "$dir/$modality" . "_$sop_inst.dcm";
  my $sub_count;
  tag:
  for my $Tag(@patterns){
    my $m = $ds->Search($Tag);
    unless(
      defined($m) && ref($m) eq "ARRAY"
    ) {
#      print EMAIL "No tags matching \"$Tag\" found in\n$file\n\n";
      next tag;
    }
    subst:
    for my $s (@$m){
      my $subst = $Tag;
      for my $in (0 .. $#{$s}){
#        print EMAIL "Subst (before): $subst\n";
        my $sub = "<$in>";
        my $repl = $s->[$in];
        $subst =~ s/$sub/$repl/;
#        print EMAIL "Subst (after): $subst\n";
      }
      my $uid = $ds->Get($subst);
      unless(defined $uid){
#        print EMAIL "$Tag($subst) has no value in\n$file\n\n";
        next subst;
      }
      if($uid =~ /^$root.*$/){
#        print EMAIL "Not hashing previously hashed uid in " .
#          "$Tag($subst) in\n$file\n\n";
        next subst;
      } else {
        my $old = $uid;
        my $ctx = Digest::MD5->new;
        $ctx->add($old);
        my $dig = $ctx->digest;
        my $new_value = "$root." . Posda::UUID::FromDigest($dig);
        $ds->Insert($subst, $new_value);
        $sub_count += 1;
#        print EMAIL "$Tag($subst):\n$uid => $new_value in\n$file\n\n";
      }
    }
  }
  if($sub_count < 1){
    print EMAIL "No substitutions, new file not written\n";
  } else {
    print EMAIL "Write new file: $new_file\n";
    $ds->WritePart10($new_file, $try->{xfr_stx}, "POSDA", undef, undef);
  }
}
