#!/usr/bin/perl -w
use strict;
my $tag_start = '(0029,"MITRA_MARKUP 1.0",';
my $tag = 0x1c;
while($tag <= 0xff){
  my $new_sig = sprintf("$tag_start%02x)", $tag);
  my $name = sprintf("Markup - %02x", $tag);
  $tag += 1;
  print "insert into element_signature(\n" .
   "  element_signature, is_private, vr,\n" .
   "  private_disposition, name_chain\n" .
   ") values (\n" .
   "  '$new_sig', true, 'OB',\n" .
   "  'd', '$name');\n";
}
