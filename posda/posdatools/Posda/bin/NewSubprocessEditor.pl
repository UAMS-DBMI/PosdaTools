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
use Posda::PrivateDispositions;
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
   uid_root_transform => {
     from => <from_uid_root>,
     to  => <to_uid_root>
   },
   edits => [
     <edit_spec>,
     ...
   ],
 };

  where:
  <uid_substitutions> is optional.
  <uid_root_transform> is optional.

  <edit_spec> = {
    op => <operation>,
    tag => <tag>,
    tag_mode => "exact|pattern|leaf|item|group_pattern|private_group",
    arg1 => <arg1 of op>,
    arg2 => <arg2 of op>
  };

  <tag> is either an exact tag e.g:
    (0010,0010)
    (0013,"CTP",50)
    (0054,0016)[0](0018,1078)
  or a tag pattern (which specifes a number of matching tags), e.g:
    (0054,0016)[<0>](0018,1078)
  or a "leaf" tag (which specifies any "leaf" occurance of a tag), e.g:
    (0018,1078) 
  or an item in a multi-valued tag, e.g:
    (0008,0008)[7]
  or a group_pattern, e.g:
    60xx
    50xx
  or a private_group, e.g:
    0013

  <tag_mode> specifies the type of tag. If the tag specified is a pattern,
  and <tag_mode> is not "pattern", then this program will crash because of
  an uncaught exception in Posda::Dataset.  Generally the parent program 
  should insure this doesn't happen.
  Also, specifying a item in a multi-valued tag for a tag which is not a
  multi-valued tag can cause problems.  The parent program can only give
  you so much help here.  Caveat usor.

  <op> specifies the operation to be performed on the tag or tags identified
  by <tag> and <tag_mode>
  <arg1> and <arg2> are the arguments of these operands:
    shift_date(number_of_days) - shift a date by an integer number of days.
                                 to shift backwards supply negative integer.
    shift_date_by_year(number_of_years) - shift a date by an integer number of years.
                                 to shift backwards supply negative integer.
    delete_tag() - Delete the tag
    set_tag(value) - Set the value of a tag unconditionally.
                     Even if not present.
    substitute(existing_value, new_value) - Set the value of the tag only if
                                            its current value matches
                                            existing_value
    string_replace(old_text, new_text) - replace any occurance of <old_text>
                                         with <new_text> in the string value
                                         of the tag.
    empty_tag() - Empty the tag (set it to empty value).
                  Even if tag is not present.
    hash_unhashed_uid(uid_root) - hash the value of the tag unless the current
                                  value of the tag is either empty, or matches
                                  the supplied uid_root
    date_difference(ref_tag, date) - Replace value in tag with number of days
                                     from date to date in ref_tag. 
                                     negative if date in ref_tag preceeds date
                                     positive if date preceeds date in ref_tag
                                     i.e. date is "from", ref_tag_date is "to"
                                     difference is "to - from"
                                     Typically, date is "date of diagnosis" and
                                     tag is (0008,0020) (Study Date).
                                     If there is an error computing difference,
                                     value of tag is replaced with error message,
                                     which may be verbose
   copy_from_tag(from_tag) - Copy the value in from_tag to tag
   delete_matching_group() - tag_mode must be 'group_pattern', tag specifies pattern
                             deletes all of the groups matching the pattern
   move_owner_block(owner, block) - tag_mode must be private_group, tag specifies 
                                    block owner (e.g. "CTP").  Moves owners tags to
                                    specified allocated block (moving other tags
                                    as necessary). This operation is to simulate
                                    CTP's behaviour (blindly putting data in block 10,
                                    regardless of what is already there).

   Order of processing:
   1) if uid_substitutions is present, perform uid_substitutions.  Even if the
      tag doesn't have a VR of UI, if it has a value which matches a <from_uid>
      change it to <to_uid>.
   2) if uid_root_transform is present, perform uid_substitutions.  Even if the
      tag doesn't have a VR of UI, if it has a value which matches a <from_uid>
      change it to <to_uid>.
   3) Then perform operations in order specified.  The same tag may be edited
      multiple times.  The last edit wins.  Caveat usor.

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
#print STDERR "Edits: ";
#Debug::GenPrint($dbg, $edits, 1);
#print STDERR "\n#######################\n";
unless(exists $edits->{from_file}){ Error("No from_file in edits") }
unless(-f $edits->{from_file}){ Error("file not found: $edits->{from_file}") }
$results->{from_file} = $edits->{from_file};
my $map_uids = sub {
  my($ele, $sig) = @_;
#  if($ele->{vr} eq "UI"){
    if($ele->{type} eq "text"){
      if($ele->{value} && ref($ele->{value}) eq "ARRAY"){
        for my $i (0 .. $#{$ele->{value}}){
          my $from = $ele->{value}->[$i];
          if(exists($edits->{uid_subsitutions}->{$from})){
            my $to = $edits->{uid_substitutions}->{$from};
            $ele->{value}->[$i] = $to;
          }
        }
      } elsif($ele->{value}){
         my $from = $ele->{value};
        if(exists $edits->{uid_substitutions}->{$from}){
          my $to = $edits->{uid_substitutions}->{$ele->{value}};
          $ele->{value} = $to;
        }
      } else {
      }
    }
#  }
};
my $transform_uids = sub {
  my($ele, $sig) = @_;
#  if($ele->{vr} eq "UI"){
    if($ele->{type} eq "text"){
      if($ele->{value} && ref($ele->{value}) eq "ARRAY"){
        for my $i (0 .. $#{$ele->{value}}){
          my $from = $ele->{value}->[$i];
          if($from =~ /^$edits->{uid_root_transform}->{from}(.*)$/){
            my $remain = $1;
            my $to = "$edits->{uid_root_transform}->{to}$remain";
            $ele->{value}->[$i] = $to;;
          }
        }
      } elsif($ele->{value}){
        my $from = $ele->{value};
        if($from =~ /^$edits->{uid_root_transform}->{from}(.*)$/){
          my $remain = $1;
          my $to = "$edits->{uid_root_transform}->{to}$remain";
          $ele->{value} = $to;
        }
      } else {
      }
    }
#  }
};
my $try = Posda::Try->new($edits->{from_file});
unless(exists $try->{dataset}) {
  Error("file $edits->{from_file} didn't parse", $try);
}
my $ds = $try->{dataset};
if(exists $edits->{uid_substitutions}){
  my $num_subs = keys %{$edits->{uid_substitutions}};
  if($num_subs >= 0){
    $ds->MapPvt($map_uids);
  }
} 
if(exists $edits->{uid_root_transform}){
print STDERR "Found uid_root_transform\n";
  $ds->MapPvt($transform_uids);
} 

my @effective_edits;
for my $edit(@{$edits->{edits}}){
  my $op = $edit->{op};
  my $tag = $edit->{tag};
  my $tag_mode = $edit->{tag_mode};
  my $arg1 = $edit->{arg1};
  my $arg2 = $edit->{arg2};
  if($tag_mode eq "exact" || $tag_mode eq "item"){
    push(@effective_edits, [$tag, $op, $arg1, $arg2]);
#    if($tag_mode eq "item"){
#      print STDERR "Item edit: [$tag, $op, $arg1, $arg2]\n";
#    }
  }elsif($tag_mode eq "pattern"){
    my $list = $ds->Search($tag);
    if(defined($list) && ref($list) eq "ARRAY" && $#{$list} >= 0){
      for my $m (@$list){
        my $tag_inst = $ds->DefaultSubstitute($tag, $m);
        push(@effective_edits, [$tag_inst, $op, $arg1, $arg2]);
      }
    }
  }elsif($tag_mode eq "leaf"){
    my @tags;
    $ds->MapPvt(SearchLeaf($tag, \@tags));
    for my $tag_inst (@tags){
      push(@effective_edits, [$tag_inst, $op, $arg1, $arg2]);
    }
  }elsif($tag_mode eq "group_pattern"){
    unless($op eq "delete_matching_group"){
      die "tag_mode of group_pattern with op $op";
    }
    unless($tag eq "60xx" || $tag eq "50xx"){
      print STDERR "delete matching group: $tag\n";
    }
    push(@effective_edits, [$tag, $op, $arg1, $arg2]);
  }elsif($tag_mode eq "private_group"){
    unless($tag =~ /^[\da-f][\da-f][\da-f][13579bdf]$/){
      die "tag_mode of private_group with group $tag";
    }
    unless($op eq "move_owner_block"){
      die "tag_mode of private_group with op $op";
    }
    push(@effective_edits, [$tag, $op, $arg1, $arg2]);
  }
}
for my $e (@effective_edits){
  my($etag, $eop, $earg1, $earg2) = @$e;
  if($eop eq "shift_date"){
    my $value = $ds->Get($etag);
    if(ref($value) eq "ARRAY"){
      for my $i (0 .. $#{$value}){
        my $val = $value->[$i];
        if(defined $val ){
          my $shifter = Posda::PrivateDispositions->new(
            undef, $earg1, undef, undef);
          my $new_value;
          eval {
            $new_value = $shifter->ShiftDate($value);
          };
          if($@){
            print STDERR "Error ($@) shifting date: $val\n" .
              "not changed\n";;
          } else {
            $value->[$i] = $val
          }
        }
      }
    } else {
      if(defined $value ){
        my $shifter = Posda::PrivateDispositions->new(
          undef, $earg1, undef, undef);
        my $new_value;
        eval {
          $new_value = $shifter->ShiftDate($value);
        };
        if($@){
          print STDERR "Error ($@) shifting date: $value\n" .
            "not changed\n";;
        } else {
          $ds->Insert($etag, $new_value);
        }
      }
    }
  }elsif($eop eq "shift_date_by_year"){
    my $value = $ds->Get($etag);
    if(defined $value){
      if($value =~ /^(\d\d\d\d)(.*)/){
        my $year = $1;
        my $rem = $2;
        $year += $earg1;
        my $new_date = sprintf("%4d",$year) . $rem;
        $ds->Insert($etag, $new_date);
      }
    }
  }elsif($eop eq "copy_date_from_tag_to_dt"){
    my $value = $ds->Get($etag);
    my $sub_date = $ds->Get($earg1);
    if($value =~/^........(.*)$/){
      my $remain = $1;
      if(length($sub_date) == 8){
        my $new_value = "$sub_date$remain";
        $ds->Insert($etag, $new_value);
      }
    }
  }elsif($eop eq "copy_from_tag"){
    my $value = $ds->Get($earg1);
    $ds->Insert($etag, $value);
  }elsif($eop eq "delete_tag"){
    $ds->Delete($etag);
  }elsif($eop eq "set_tag"){
    $ds->Insert($etag, $earg1);
  }elsif($eop eq "substitute"){
    my $value = $ds->Get($etag);
    if($value eq $earg1){
      $ds->Insert($etag, $earg2);
    }
  }elsif($eop eq "string_replace"){
    my $value = $ds->Get($etag);
    my $value1 = $value;
    $value1 =~ s/$earg1/$earg2/g;
    if($value ne $value1){
      $ds->Insert($etag, $value1);
    }
  }elsif($eop eq "empty_tag"){
    $ds->Insert($etag, "");
  }elsif($eop eq "short_hash"){
    my $value = $ds->Get($etag);
    my $ctx = Digest::MD5->new;
    $ctx->add($value);
    my $dig = $ctx->hexdigest;
    my $len = length($value);
    my $new_str = substr($dig, 0, $len);
    $ds->Insert($etag, $new_str);
  }elsif($eop eq "hash_unhashed_uid"){
    my $value = $ds->Get($etag);
    unless($value =~ /^$earg1.*$/){
      my $ctx = Digest::MD5->new;
      $ctx->add($value);
      my $dig = $ctx->digest;
      my $new_uid = "$earg1." . Posda::UUID::FromDigest($dig);
      $ds->Insert($etag, $new_uid);
    }
  }elsif($eop eq "date_difference"){
    my $val;
    my $date_in_tag = $ds->Get($earg1);
    my $date = $earg2;
    eval {
      $val = Posda::PrivateDispositions->DiffDate(
        $date, $date_in_tag);
    };
    if($@){
      $val = "error in computation: $@";
    }
    $ds->Insert($etag, $val);
  }elsif($eop eq "delete_matching_group"){
    for my $gr (keys %{$ds}){
      my $group = sprintf("%4x", $gr);
      if($etag eq '60xx' && $group =~ /^60..$/){
        delete $ds->{$gr};
      }
      if($etag eq '50xx' && $group =~ /^50..$/){
        delete $ds->{$gr};
      }
    }
  }elsif($eop eq "move_owner_block"){
    my $gr = hex($etag);
    my $owner = $earg1;
    my $bl = hex($earg2);
    $ds->MapToConvertPvt;
    if(exists $ds->{$gr}){
      my $private_map = $ds->{$gr}->{private_map};
      my $r_private_map = $ds->{$gr}->{r_private_map};
      unless($r_private_map->{$owner} == $bl){
        my $cur_blk = $r_private_map->{$owner};
        if(exists $private_map->{$bl}){
          my $to_move_own = $private_map->{$bl};
	  $private_map->{$cur_blk} = $to_move_own;
          $r_private_map->{$to_move_own} = $cur_blk;
        }
        $private_map->{$bl} = $owner;
        $r_private_map->{$owner} = $bl;
        # So differences show up
        $ds->Insert('(0013,"Posda",01)', "private tag blocks reallocated");
      }
    }
    $ds->MapToConvertPvtBack;
  }elsif($eop eq "annotate_img"){
    my $pix_desc = $ds->GetEle("(7fe0,0010)");
    unless(
      defined($pix_desc) &&
      ref($pix_desc) eq "HASH" &&
      defined ($pix_desc->{file_pos}) &&
      defined ($pix_desc->{ele_len_in_file})
    ){
      print STDERR "No pixel data to annotate\n";
    } else {
      my $rows = $ds->Get("(0028,0010)");
      my $cols = $ds->Get("(0028,0011)");
      my $bits_allocated = $ds->Get("(0028,0100)");
      my $bits_stored = $ds->Get("(0028,0101)");
      my $high_bit = $ds->Get("(0028,0102)");
      my $photometric_interpretation = $ds->Get("(0028,0004)");
      my $pixel_representation = $ds->Get("(0028,0103)");
      my $cmd = "annotate_img.py \"$edits->{from_file}\" \"$pix_desc->{file_pos}\" " .
#        "\"$pix_desc->{ele_len_in_file}\" " .
        "\"$rows\" \"$cols\" \"$bits_allocated\" \"$bits_stored\" \"$high_bit\" " .
        "\"$photometric_interpretation\" \"$pixel_representation\" '$earg1'";
print STDERR "###################\nCommand:\n$cmd\n###############\n";
      my $pix = do {
        local $/;
        open my $fh, "$cmd|" or die "Can't open pipe from ($cmd): $!";
        <$fh>
      };
      $ds->Insert("(7fe0,0010)", $pix);
    }
  }else{
  }
}
my $xfr_stx = $try->{xfr_stx};
if($xfr_stx eq "1.2.840.10008.1.2.2"){
  print STDERR "converting file from big to little endian transfer syntax\n";
  $xfr_stx = "1.2.840.10008.1.2.1";
}
eval {
  $ds->WritePart10($edits->{to_file}, $xfr_stx, "POSDA", undef, undef);
};
if($@){
  print STDERR "Can't write $edits->{to_file} ($@)\n";
  Error("Can't write $edits->{to_file}", $@);
}
$results->{to_file} = $edits->{to_file};
$results->{Status} = "OK";
store_fd($results, \*STDOUT);
exit;
sub SearchLeaf{
  my($leaf_tag, $tag_list) = @_;
  my $sub = sub {
    my($ele, $sig) = @_;
    my $pat = $leaf_tag;
    $pat =~ s/\(/\\(/g;
    $pat =~ s/\)/\\)/g;
    if($sig =~ /$pat$/){
      push(@$tag_list, $sig);
    } else {
    }
  };
  return $sub;
}
