#!/usr/bin/perl -w
#Source:  $
#$Date: 2013/10/10 20:42:10 $
#$Revision: 1.3 $
#
#Copyright 2010, Bill Bennett
# Part of the Posda package
# Posda may be copied only under the terms of either the Artistic License or the
# GNU General Public License, which may be found in the Posda Distribution,
# or at http://posda.com/License.html
#
use strict;
use Posda::Try;
use Text::Diff;
use Debug;
package Posda::HttpApp::HtmlFileDiff;
sub new{
  my($class, $from_file, $to_file) = @_;
  my $this = {
    from_text => $from_file,
    to_text => $to_file,
  };
  my @diffs;
  my $diff = Text::Diff::diff(
    $from_file, $to_file, {OUTPUT => \@diffs, CONTEXT => 0});
  $this->{status} = "Success";
  $this->{diffs} = \@diffs;
  my $parsed_diffs;
  my $line_no;
  my $count;
  my $added_lines = [];
  my $diff_count = scalar @diffs;
  if($diff_count == 0) {
    #print "No diffs\n";
    $this->{parsed_diffs} = {};
    $this->{NoChanges} = 1;
    return bless $this, $class;
  }
  unless(((($diff_count - 2)) % 3) == 0){
    print STDERR "I'm misunderstanding this format diff_count = $diff_count\n";
    return bless $this, $class;
  }
  my $num_entries = ($diff_count - 3) / 3;
  for my $i (0 .. $num_entries){
    my @spec = split(/\s+/,$diffs[1 + ($i * 3) ]);
    my($line_no, $lc);
    if($spec[1] =~ /^-([\d]+)$/){
      $line_no = $1;
      $lc = 1;
    } elsif($spec[1] =~ /^-([\d]+),([\d]+)$/){
      $line_no = $1;
      $lc = $2;
    } else {
      die "I can't understand $spec[1] in $diffs[1 + ($i * 3) ]";
    }
    my @changes = split(/\n/,$diffs[2 + ($i * 3)]);
    my @nc;
    for my $change (@changes){
      if($change =~ /^\+(.*)$/){
        push @nc, $1;
      }
    }
    $parsed_diffs->{$line_no} = {
      count => $lc,
      changes => \@nc,
    };
  }
  $this->{parsed_diff} = $parsed_diffs;
  return bless $this, $class;
}
sub render_raw{
  my($this, $HTTP) = @_;
  $HTTP->queue("<pre>");
  for my $line (@{$this->{diffs}}){
    $HTTP->queue($line);
  }
  $HTTP->queue("</pre>");
}
sub render_parsed{
  my($this, $HTTP) = @_;
  my $queuer = Debug::MakeQueuer($HTTP);
  $HTTP->queue("<pre>");
  Debug::GenPrint($queuer, $this->{parsed_diff}, 1);
  $HTTP->queue("</pre>");
}
sub render_obj_links{
  my($this, $ref, $http, $dyn) = @_;
  my @key_list = sort { $a <=> $b } keys %{$this->{parsed_diff}};
  if($#key_list < 0){
    $http->queue("&lt;No differences found&gt;");
    return;
  }
  for my $i (0 .. $#key_list){
    my $line_no = $key_list[$i];
#    $http->queue("<a href=\"$ref#line$line_no\">" .
    $http->queue("<a href=\"#line$line_no\">" .
      "line $line_no</a>");
    unless($i == $#key_list){
      $http->queue(", ");
    }
  }
}
sub render_links{
  my($this, $ref, $target, $HTTP, $DISP, $SESS, $DYNPARM) = @_;
  my @key_list = sort { $a <=> $b } keys %{$this->{parsed_diff}};
  for my $i (0 .. $#key_list){
    my $line_no = $key_list[$i];
    $HTTP->ExpandText("<?dynamic name=\"expanders/MakeLink\" " .
      "link=\"$ref#line$line_no\" " .
      "target=\"$target\" " .
      "text=\"line $line_no\"?>",
      $DISP, $SESS, $DYNPARM);
    unless($i == $#key_list){
      $HTTP->queue(", ");
    }
  }
}
sub render_text_diff {
  my($this, $HTTP, $html) = @_;
  my $from = $this->{from_text};
  my $line_no = 0;
  $HTTP->queue("<pre>");
  my $skip_count = 0;
  open FILE, "<$from" or die "can't open $from";
  my $item;
  line:
  while(my $line = <FILE>){
    $line_no += 1;
    unless($html){
      $line =~ s/</&lt;/g;
      $line =~ s/>/&gt;/g;
    }
    if($skip_count > 0){
      $skip_count -= 1; 
      $HTTP->queue("<strike>$line</strike>");
      if($skip_count == 0){
        for my $i (@{$item->{changes}}){
          $HTTP->queue("<b>$i\n</b>");
        }
      }
      next line;
    }
    if(exists $this->{parsed_diff}->{$line_no}){
      $HTTP->queue("<a name=\"line$line_no\"></a>");
      $item = $this->{parsed_diff}->{$line_no};
      $skip_count = $item->{count};
      if($skip_count > 0){
        $skip_count -= 1; 
        $HTTP->queue("<strike>$line</strike>");
      } else {
        $HTTP->queue("$line");
      }
      if($skip_count == 0){
        for my $i (@{$item->{changes}}){
          unless($html){
            $i =~ s/</&lt;/g;
            $i =~ s/>/&gt;/g;
          }
          $HTTP->queue("<b>$i\n</b>");
        }
      }
      next line;
    }
    $HTTP->queue($line);
  }
  $HTTP->queue("</pre>");
}
1;
