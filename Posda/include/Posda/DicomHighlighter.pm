#!/usr/bin/perl -w
#$Source: /home/bbennett/pass/archive/Posda/include/Posda/DicomHighlighter.pm,v $
#$Date: 2013/10/07 02:39:57 $
#$Revision: 1.1 $
#
use strict;
package Posda::DicomHighlighter;
sub Highlighter{
  my($this, $new_sig, $old_sig, $out) = @_;
  if($new_sig eq "") { return $out }
  unless(defined $out) {
    $out = "<font color=\"pink\">";
  }
  if($new_sig =~ /^\((....),(....)\)(.*)$/){
    my $new_grp = $1;
    my $new_ele = $2;
    my $new_remain = $3;
    if($old_sig =~ /^\((....),(....)\)(.*)$/){
      my $old_grp = $1;
      my $old_ele = $2;
      my $old_remain = $3;
      if($old_grp ne $new_grp) {
        if($out){
          return ("$out</font>($new_grp,$new_ele)$new_remain");
        } else {
          return ("($new_grp,$new_ele)$new_remain");
        }
      }
      if($old_ele ne $new_ele){
        return ("$out($new_grp,</font>$new_ele)$new_remain");
      }
      $out .= "($new_grp,$new_ele)";
      return $this->Highlighter($new_remain, $old_remain, $out)
    } else {
      if($out){
        return ("$out</font>($new_grp,$new_ele)$new_remain");
      } else {
        return ("($new_grp,$new_ele)$new_remain");
      }
    }
  }elsif($new_sig =~ /^\[([^\]]+)\](.*)$/){
    my $new_index = $1;
    my $new_remain = $2;
    if($old_sig =~ /^\[([^\]]+)\](.*)$/){
      my $old_index = $1;
      my $old_remain = $2;
      if($old_index ne $new_index){
        if($out){
          return ("$out</font>[$new_index]$new_remain");
        } else {
          return ("[$new_index]$new_remain");
        }
      }
      $out .= "[$new_index]";
      return $this->Highlighter($new_remain, $old_remain, $out);
    } else {
      #return $this->Highlighter($new_remain, $old_remain, $out);
      if($out){
        return ("$out</font>[$new_index]$new_remain");
      } else {
        return ("[$new_index]$new_remain");
      }
    }
  }elsif($new_sig =~ /^\((....),\"([^\"]+)\",(..)\)(.*)$/){
    my $new_grp = $1;
    my $new_own = $2;
    my $new_ele = $3;
    my $new_remain = $4;
    if($old_sig =~ /^\((....),\"([^\"]+)\",(..)\)(.*)$/){
      my $old_grp = $1;
      my $old_own = $2;
      my $old_ele = $3;
      my $old_remain = $4;
      if($new_grp ne $old_grp){
        return ("$out</font>($new_grp,\"$new_own\",$new_ele)$new_remain");
      }
      if($new_own ne $old_own){
        return ("$out($new_grp</font>,\"$new_own\",$new_ele)$new_remain");
      }
      if($new_ele ne $old_ele){
        return ("$out($new_grp,\"$new_own\",</font>$new_ele)$new_remain");
      }
      $out .= "($new_grp,\"$new_own\",$new_ele)";
      return $this->Highlighter($new_remain, $old_remain, $out);
    } else {
      if($out){
        return ("$out</font>($new_grp,\"$new_own\",$new_ele)$new_remain");
      } else {
        return ("($new_grp,\"$new_own\",$new_ele)$new_remain");
      }
    }
  }
}
1;
