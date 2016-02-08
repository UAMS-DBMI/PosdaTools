#!/usr/bin/perl -w
#
use strict;
package Posda::HttpApp::TextDiff;
use Text::Diff;
use vars qw( @ISA );
@ISA = ( "Posda::HttpObj" );
my $content = <<EOF;
<p><small>View Differences at: 
<?dyn="DiffLinks"?></small></p>
<hr>
<?dyn="ShowDiffs"?>
</hr>
EOF
my $no_changes_content = <<EOF;
<p><small>No Differences</small></p>
<hr>
<?dyn="ShowDiffs"?>
</hr>
EOF
sub new {
  my($class, $sess, $path, $from, $to) = @_;
  my $this = Posda::HttpObj->new($sess, $path);
  $this->{from} = $from;
  $this->{to} = $to;
  bless $this, $class;
  return $this;
}
sub Content{
  my($this, $http, $dyn) = @_;
  unless($this->{parsed_diff}){ $this->InitDiffs() }
  unless(exists $this->{RenderedDiffs}){
    $this->{RenderedDiffs} = [];
    $this->RenderDiffs();
  }
  my $template = $content;
  if($this->{NoChanges}){
    $template = $no_changes_content;
  }
  $this->RefreshEngine($http, $dyn, $template);
}
sub DiffLinks{
  my($this, $http, $dyn) = @_;
  my @key_list = sort { $a <=> $b } keys %{$this->{parsed_diff}};
  for my $i (0 .. $#key_list){
    my $line_no = $key_list[$i];
    $http->queue("<a href=\"#line$line_no\">line $line_no</a>");
    unless($i == $#key_list){
      $http->queue(", ");
    }
  }
}
sub ShowDiffs{
  my($this, $http, $dyn) = @_;
  for my $i (@{$this->{RenderedDiffs}}){
    $http->queue($i);
 }
}
sub RenderDiffs{
  my($this) = @_;
  my $line_no = 0;
  push(@{$this->{RenderedDiffs}}, "<pre>");
  my $skip_count = 0;
  my $item;
  line:
  for my $l (@{$this->{from_dump}}){
    my $line = $l;
    chomp $line;
    $line_no += 1;
    $line =~ s/</&lt;/g;
    $line =~ s/>/&gt;/g;
    chomp $line;
    if($skip_count > 0){
      $skip_count -= 1;
      push(@{$this->{RenderedDiffs}}, "<strike>$line\n</strike>");
      if($skip_count == 0){
        for my $i (@{$item->{changes}}){
          chomp $i;
          $i =~ s/</&lt;/g;
          $i =~ s/>/&gt;/g;
          push(@{$this->{RenderedDiffs}}, "<b>$i\n</b>");
        }
      }
      next line;
    }
    if(exists $this->{parsed_diff}->{$line_no}){
      push(@{$this->{RenderedDiffs}}, "<a name=\"line$line_no\"></a>");
      $item = $this->{parsed_diff}->{$line_no};
      $skip_count = $item->{count};
      if($skip_count > 0){
        $skip_count -= 1;
        push(@{$this->{RenderedDiffs}}, "<strike>$line\n</strike>");
      }
      if($skip_count == 0){
        for my $i (@{$item->{changes}}){
          chomp $i;
          $i =~ s/</&lt;/g;
          $i =~ s/>/&gt;/g;
          push(@{$this->{RenderedDiffs}}, "<b>$i\n</b>");
        }
      }
      next line;
    }
    push(@{$this->{RenderedDiffs}},"$line\n");
  }
  push(@{$this->{RenderedDiffs}}, "</pre>");
}
sub InitDiffs{
  my($this) = @_;
  unless($this->{from_dump}){
    my @from;
    for my $i (split(/\n/, $this->{from})){
      push @from, "$i\n";
    }
    $this->{from_dump} = \@from;
  }
  unless($this->{to_dump}){
    my @to;
    for my $i (split(/\n/, $this->{to})){
      push @to, "$i\n";
    }
    $this->{to_dump} = \@to;
  }
  my @diffs;
  my $diffs = Text::Diff::diff($this->{from_dump}, $this->{to_dump},
    { OUTPUT => \@diffs, CONTEXT => 0});
  $this->{text_diff_output} = \@diffs;
  my $parsed_diffs;
  my $line_no;
  my $count;
  my $added_lines = [];
  my $diff_count = scalar @diffs;
  if($diff_count == 0) {
    #print "No diffs\n";
    $this->{parsed_diffs} = {};
    $this->{NoChanges} = 1;
    return;
  }
  unless(((($diff_count - 2)) % 3) == 0){
    print STDERR "I'm misunderstanding this format diff_count = $diff_count\n";
    return;
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
}
1;
