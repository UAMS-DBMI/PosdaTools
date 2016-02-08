#!/usr/bin/perl -w
#
#Copyright 2012, Bill Bennett and Erik Strom
# Part of the Posda package
# Posda may be copied only under the terms of either the Artistic License or the
# GNU General Public License, which may be found in the Posda Distribution,
# or at http://posda.com/License.html
#
use strict;
use File::Find;
use File::Path qw(make_path);
use Cwd;
my $hdr_html = <<EOF;
<! --
-->
EOF
my $hdr_c = <<EOF;
 */
EOF
my $hdr_perl = <<EOF;
#!/usr/bin/perl -w
EOF
my $hdr_sh = <<EOF;
#!/usr/sh
EOF
my $hdr_json = <<EOF;
EOF
my $usage = "$0 <source_dir> <destination_dir>";
unless($#ARGV == 1) { die "$usage\n" }
my $source_dir = $ARGV[0];
my $destination_dir = $ARGV[1];
my $cwd = getcwd;
my @rel_paths;
my %rel_dirs;
unless($source_dir =~ /^\//) { $source_dir = "$cwd/$source_dir" }
unless(-d $source_dir) { die "$source_dir is not a directory" }
unless($destination_dir =~ /^\//) 
  { $destination_dir = "$cwd/$destination_dir" }
unless(-d $destination_dir) { die "$destination_dir is not a directory" }
my $finder = sub {
  my $cur_file = $File::Find::name;
  unless(-f $cur_file && -w $cur_file) { return }
  unless($cur_file =~ /\/([^\/]+)$/) { die "WTF?" }
  my $file_part = $1;
  if($file_part =~ /^\./) { return }
  unless($cur_file =~ /^$source_dir\/(.*)$/){
    print "Funny full path to file: $cur_file\n";
    return;
  }
  my $rel_path = $1;
  push(@rel_paths, $rel_path);
};
find($finder, $source_dir);
## create rel_dirs 
for my $rel (@rel_paths) {
  unless($rel =~ /^(.*)\/([^\/]+)$/) {
    next;
  }
  my $dir = $1;
  my $file = $2;
  $rel_dirs{$dir} = 1;
}
for my $dir (keys %rel_dirs){
  my $destination_dir_path = "$destination_dir/$dir";
  unless(-e $destination_dir_path){
    make_path($destination_dir_path, { mode => 0771 });
  }
}
## Now generate the new source file
for my $i (@rel_paths){
  my $source = "$source_dir/$i";
  my $destination = "$destination_dir/$i";
  if (-e $destination) { next }
  unless ($i =~ m/^(.*)\.([^\.]+)$/) { next; }
  my $base_file = $1;
  my $file_type = $2;
  my $sccsid_chk1 = `grep -P '\\\$Source.*\\\$' "$source"`;
  my $sccsid_chk2 = `grep -P '\\\$Date.*\\\$' "$source"`;
  my $sccsid_chk3 = `grep -P '\\\$Revision.*\\\$' "$source"`;
  #print "file: $source, file_type: $file_type.\n";
  my $append_text = "";
  if ($file_type =~ m/html?/i) {
    $append_text = $hdr_html;
  } elsif ($file_type =~ m/js$/i) {
    $append_text = $hdr_c;
  } elsif ($file_type =~ m/php$/i) {
    $append_text = $hdr_html;
  } elsif ($file_type =~ m/css$/i) {
    $append_text = $hdr_c;
  } elsif ($file_type =~ m/p[m|l]$/i) {
    $append_text = $hdr_perl;
  } elsif ($file_type =~ m/sh$/i) {
    $append_text = $hdr_sh;
  } elsif ($file_type =~ m/ico$/i) {
    $append_text = "";
  } elsif ($file_type =~ m/jpg$/i) {
    $append_text = "";
  } elsif ($file_type =~ m/swf$/i) {
    $append_text = "";
  } elsif ($file_type =~ m/swc$/i) {
    $append_text = "";
  } elsif ($file_type =~ m/gz$/i) {
    $append_text = "";
    next;
  } elsif ($file_type =~ m/tar$/i) {
    $append_text = "";
    next;
  } elsif ($file_type =~ m/png$/i) {
    $append_text = "";
  } elsif ($file_type =~ m/json$/i) {
    $append_text = $hdr_json;
  }
  # print "\tsccsid_chk1: $sccsid_chk1.\n";
  # print "\tsccsid_chk2: $sccsid_chk2.\n";
  # print "\tsccsid_chk3: $sccsid_chk3.\n";
  #print "\tappend_text: $append_text.\n";
  if ($append_text ne ""  &&
      ($sccsid_chk1 eq ""  ||  
       $sccsid_chk1 eq ""  || 
       $sccsid_chk1 eq ""  )) { 
    open FILE, '>', $destination;
    print FILE $append_text . "\n";
    close FILE;
  }
  `cat "$source" >> "$destination" ; chmod +w "$destination"`;
}
