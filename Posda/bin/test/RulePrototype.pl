#!/usr/bin/perl -w
#$Source: /home/bbennett/pass/archive/Posda/bin/test/RulePrototype.pl,v $
#$Date: 2013/05/17 15:13:03 $
#$Revision: 1.1 $
#
#Copyright 2013, Bill Bennett
# Part of the Posda package
# Posda may be copied only under the terms of either the Artistic License or the
# GNU General Public License, which may be found in the Posda Distribution,
# or at http://posda.com/License.html
#

use strict;
use Posda::Try;
use Cwd;
use Debug;
my $dbg = sub { print STDERR @_ };
my @rules = (
  {
    for_match => "(3006,0080)[<0>](3006,0084)",
    invoke => {
      no_match => "(3006,0020)[<0>](3006,0022)",
      value => "<v>",
      invoke => 
        "element (3006,0080[<i0>](3006,0084): undefined roi number (<v>)",
    },
  },
  {
    for_match => "(3006,0039)[<0>](3006,0040)[<1>](3006,0016)[0](0008,1155)",
    invoke => {
      no_match => "(3006,0010)[<0>](3006,0012)[<1>]" .
                  "(3006,0014)[<2>](3006,0016)[<3>](0008,1155)",
      value => "<v>",
      invoke => 
        "element (3006,0039)[<i0>](3006,0040)[<i1>](3006,0016): \n" .
        "\treference to image (<v>)\n" .
        "\tnot found in referenced frame of reference sequence",
    },
  },
  {
    for_match => "(3006,0039)[<0>](3006,0084)",
    invoke => {
      no_match => "(3006,0020)[<0>](3006,0022)",
      value => "<v>",
      invoke => 
        "element (3006,0039[<i0>](3006,0084): undefined roi number (<v>)",
    },
  },
  {
    for_match => "(3006,0039)[<0>](3006,0040)[<1>](3006,0042)",
    value => "CLOSED_PLANAR",
    invoke => {
      no_match => 
        "(3006,0039)[<i0>](3006,0040)[<i1>](3006,0016)[0](0008,1155)",
      invoke => 
        "CLOSED_PLANAR contour which doesn't reference an image\n" .
        "\tat (3006,0039)[<i0>](3006,0040)[<i1>](3006,0042)",
    },
  },
);
my $rules_json = <<EOF;
[
  {
    "for_match": "(3006,0080)[<0>](3006,0084)",
    "invoke": {
      "no_match": "(3006,0020)[<0>](3006,0022)",
      "value": "<v>",
      "invoke": 
        "element (3006,0080[<i0>](3006,0084): undefined roi number (<v>)"
    }
  },
  {
    "for_match": "(3006,0039)[<0>](3006,0040)[<1>](3006,0016)[0](0008,1155)",
    "invoke": {
      "no_match": 
        "(3006,0010)[<0>](3006,0012)[<1>]" +
        "(3006,0014)[<2>](3006,0016)[<3>](0008,1155)",
      "value": "<v>",
      "invoke": 
        "element (3006,0039)[<i0>](3006,0040)[<i1>](3006,0016): \n" +
        "\treference to image (<v>)\n" +
        "\tnot found in referenced frame of reference sequence"
    }
  }
]
EOF
my $rules_property_list = <<EOF;
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple Computer//DTD PLIST 1.0//EN"
  "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
  <dict>
    <key>for_match</key>
    <string>(3006,0080)[&lt;0&gt;](3006,0084)</string>
    <key>invoke</key>
    <dict>
      <key>no_match</key>
      <string>(3006,0020)[&lt;0&gt;](3006,0022)</string>
      <key>value</key>
      <string>&lt;v&gt;</string>
      <key>invoke</key>
      <string>element (3006,0080[&lt;i0&gt;](3006,0084):
         undefined roi number (&lt;v&gt;)</string>
    </dict>
  </dict>
  <dict>
    <key>for_match</key>
    <string>(3006,0039)[&lt;0&gt;](3006,0040)[&lt;1&gt;](3006,0016)[0](0008,1155)</string>
    <key>invoke</key>
    <dict>
      <key>no_match</key>
      <string>(3006,0010)[&lt;0&gt;](3006,0012)[&lt;1&gt;](3006,0014)[&lt;2&gt;](3006,0016)[&lt;3&gt;](0008,1155)</string>
      <key>value</key>
      <string>&lt;v&gt;</string>
      <key>invoke</key>
      <string>"element (3006,0039)[<i0>](3006,0040)[<i1>](3006,0016):
         reference to image (<v>)
         not found in referenced frame of reference sequence"</string>
    </dict>
  </dict>
</plist>
EOF
my $rules_lisp = <<EOF;
(quote 
  (
    (for_match "(3006,0080)[<0>](3006,0084)"
      (invoke (no_match "(3006,0020)[<0>](3006,0022)"
        (value "<v>")
        (invoke 
          "element (3006,0080)[<i0>](3006,0084): undefined roi number (<v>)"
        )
      )
    )
    (for_match "(3006,0039)[<0>](3006,0040)[<1>](3006,0016)[0](0008,1155)"
      (value "<v>")
      (invoke
         "element (3006,0039)[<i0>](3006,0040)[<i1>](3006,0016): \n\treference to image (<v>)\n\tnot found in referenced frame of reference sequence"
      )
    )
  )
)
EOF
my $file = $ARGV[0];
unless($file =~ /^\//) { $file = getcwd ."/$file" }
my $try = Posda::Try->new($file);
unless(exists $try->{dataset}) { die "$file is not a dataset" }
my $ds = $try->{dataset};
for my $rule (@rules){
  invoke($rule, $ds, [], undef);
}
sub invoke{
  my($rule, $ds) = @_;
  if($rule->{for_match}){
    my $ml;
    if(exists $rule->{value}){
      $ml = $ds->Search($rule->{for_match}, $rule->{value});
    } else {
      $ml = $ds->Search($rule->{for_match});
    }
    match:
    for my $m (@$ml){
      if($rule->{invoke}){
        unless(ref($rule->{invoke})){
          print "$rule->{invoke}\n";
          next match;
        }
        if(ref($rule->{invoke}) eq "HASH"){
          my $nr = {};
          my $sub_pat = {};
          for my $i (0 .. $#{$m}){
            $sub_pat->{"<$i>"} = $i;
          }
          my $get_sig = $ds->Substitute($rule->{for_match}, $m, $sub_pat);
          my $value = $ds->Get($get_sig);
          for my $k (keys %{$rule->{invoke}}){
            my $str = $rule->{invoke}->{$k};
            $str =~ s/<v>/$value/g;
            for my $j (0 .. $#{$m}){
              $str =~ s/<i$j>/$m->[$j]/eg;
            }
            $nr->{$k} = $str;
          }
          invoke($nr, $ds);
          next match;
        }
        my $type = ref($rule);
        print STDERR "Error: Can't handle $type rules\n";
      } else {
        print STDERR "Error: no invoke clause for rule:\n";
        for my $j (keys %$rule){
          print STDERR "\t$j: $rule->{$j}\n";
        }
        return;
      }
    }
  } elsif($rule->{no_match}){
    my $ml;
    if(exists $rule->{value}){
      $ml = $ds->Search($rule->{no_match}, $rule->{value});
    } else {
      $ml = $ds->Search($rule->{no_match});
    }
    if($ml && ref($ml) eq "ARRAY" && $#{$ml} >= 0 ) {
      #print STDERR "$rule->{no_match} $rule->{value} is OK\n";
      return;
    }
    if($rule->{invoke}){
      unless(ref($rule->{invoke})){
        print "$rule->{invoke}\n";
        return;
      }
    } else {
      print STDERR "Error: no invoke clause for rule:\n";
      for my $j (keys %$rule){
        print STDERR "\t$j: $rule->{$j}\n";
      }
      return;
    }
  }
}
