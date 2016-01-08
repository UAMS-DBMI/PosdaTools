#!/usr/bin/perl -w
#$Source: /home/bbennett/pass/archive/Posda/bin/test/MakeStatic.pl,v $
#$Date: 2011/05/12 17:44:34 $
#$Revision: 1.4 $
#
#Copyright 2010, Bill Bennett
# Part of the Posda package
# Posda may be copied only under the terms of either the Artistic License or the
# GNU General Public License, which may be found in the Posda Distribution,
# or at http://posda.com/License.html
#
use File::Find;
use strict;
unless($#ARGV == 0){ die "usage: $0 <dir>" }
my $ExtToMime = {
  "doc" => "application/msword",
  "gif" => "image/gif",
  "htm" => "text/html",
  "html" => "text/html",
  "jpg" => "image/jpeg",
  "mpg" => "video/mpeg",
  "png" => "image/png",
  "ppt" => "application/ppt",
  "qt" => "video/quicktime",
  "rtf" => "application/rtf",
  "tif" => "image/tiff",
  "txt" => "text/plain",
  "wav" => "audio/x-wav",
  "xls" => "application/msexcel",
  "js" => "application/x-javascript",
  "css" => "text/css",
  "ico" => "image/icon",
};
my $dir = $ARGV[0];
sub finder{
  my $full_path = $File::Find::name;
  unless(-f $full_path) { return }
  unless($full_path =~ /$dir(\/.*)$/){
    print STDERR "funny path: $full_path\n";
    return;
  }
  my $rel_path = $1;
  unless($rel_path =~ /\.([^\.]+)$/){
    print STDERR "Couldn't find extension in $rel_path (ignoring)\n";
    return;
  }
  my $ext = $1;
  my $mt = $ExtToMime->{$ext};
  unless(defined $mt) {
    print STDERR "no mime conversion for $ext\n";
    return;
  }
  if($mt =~ /^text/){
    print "if(defined \$Static{\"$rel_path\"}){\n";
    print "  print STDERR \"Redefining $rel_path\\n\"\n";
    print "}\n"; 
    print "\$Static{\"$rel_path\"} = <<'EOF';\n";
    open FILE, "<$full_path" or die "Can't open $full_path";
    while(my $line = <FILE>){print $line}
    close FILE;
    print "\nEOF\n";
  } else {
    my $content;
    open FILE, "<$full_path";
    seek FILE, 0, 2;
    my $length = tell FILE;
    seek FILE, 0, 0;
    my $len = read(FILE, $content, $length);
    unless($len == $length){
      print STDERR "read wrong length: $len vs $length for $rel_path\n";
      return;
    }
    print "if(defined \$Static{\"$rel_path\"}){\n";
    print "  print STDERR \"Redefining $rel_path\\n\"\n";
    print "}\n"; 
    print "{\n";
    print "  my \$foo = <<'EOF';\n";
    my $foo = pack("u*", $content);
    print $foo;
    print "EOF\n";
    print "  \$Static{\"$rel_path\"} = unpack('u', \$foo);\n";
    print "}\n";
  }
};

my $header = <<'EOF';
#!/usr/bin/perl -w
#$Source: /home/bbennett/pass/archive/Posda/bin/test/MakeStatic.pl,v $
#$Date: 2011/05/12 17:44:34 $
#$Revision: 1.4 $
#

#########################Static Content#########################
EOF
my $trailer = <<'EOF';
#####################End Static Content#########################
1;
EOF
print $header;
find({wanted => \&finder}, $dir);
print $trailer;
