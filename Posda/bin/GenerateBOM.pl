#!/usr/bin/perl -w
#
use File::Find;
use Digest::MD5;
my $RootDir = $ARGV[0];
my $NameVersion = $ARGV[1];
my $Marker = 
"<html><head>\n" .
"<title>Bill of Materials</title>\n" .
"</head>" .
"<body>\n" .
"<?--\n" .
"#\$" . "Source:  \$\n" .
"#\$" . "Date:  \$\n" .
"#\$" . "Revision:  \$\n" .
"##########&lt;Content Below is Generated - Do not edit&gt;################\n" .
"-->\n" .
"<h1>Bill of Materials</h1>" .
"<h2>$NameVersion</h2>" .
"<table border=1 width=100%> <tr>\n" .
"<th>File</th><th>Size</th><th>version</th><th>Digest</th></tr>\n";
my $BOMfile = "$RootDir/BOM.html";
if(-f $BOMfile){
  die "Sorry, I won't overwrite existing BOMfile $BOMfile";
}
open BOM, ">$BOMfile" or die "couldn't open $BOMfile";
print BOM $Marker;
my @file_list;
my $finder = sub {
  my $file_name = $File::Find::name;
  if(-d $file_name) { return }
  if($file_name eq $BOMfile) { return }
  unless(-r $file_name) { die "unreadable file $file_name" }
  if(-w $file_name) { print STDERR "Warning: writable file $file_name\n" }
  unless($file_name =~ /^$RootDir\/(.*)$/){ die "file not in directory" }
  my $rel_path = $1;
  push(@file_list, $rel_path);
};
find({wanted => $finder, follow => 1}, $RootDir);
for my $file (sort @file_list){
  my $full_path = "$RootDir/$file";
  my $rev;
  open IDENT, "ident \"$full_path\" 2>/dev/null|";
  while (my $line = <IDENT>){
    if($line =~ /Revision: (.*) \$/){
      $rev = $1;
    }
  }
  unless(defined $rev) { $rev = "-" }
  close IDENT;
  open LEN, "wc -c \"$full_path\"|";
  my $line = <LEN>;
  close LEN;
  my $length;
  if($line =~ /\s*(\d+)\s/){
    $length = $1;
  }
  my $ctx = Digest::MD5->new;
  open FILE, "<$full_path";
  $ctx->addfile(*FILE);
  my $digest = $ctx->hexdigest;
  close FILE;
  print BOM "<tr>";
  print BOM "<td>$file</td>";
  print BOM "<td>$length</td>";
  print BOM "<td>$rev</td>";
  print BOM "<td>$digest</td>";
  print BOM "</tr>\n";
}
print BOM "</table></body></html>\n";
