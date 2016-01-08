#!/usr/bin/perl -w
#$Source: /home/bbennett/pass/archive/Posda/bin/CheckBOM.pl,v $
#$Date: 2014/05/20 13:31:24 $
#$Revision: 1.6 $
#
use File::Find;
use Digest::MD5;
#use Debug;
#my $dbg = sub {print @_};
my $ident = `which ident`;
if($ident eq "") { $ident = "ident.pl" } else { $ident = "ident" }
my $RootDir = $ARGV[0];
my $BOMfile = "$RootDir/BOM.html";
open BOM, "<$BOMfile" or die "couldn't open $BOMfile";
my %FilesInBom;
my $BomTitle;
while(my $line = <BOM>){
  chomp $line;
  if($line =~ /<h1>Bill of Materials<\/h1><h2>(.*)<\/h2>/){
    $BomTitle = $1;
    next;
  }
  unless(
    $line =~
     /^<tr><td>([^>]*)<\/td><td>([^<]*)<\/td><td>([^<]*)<\/td><td>([^<]*)<\/t/
  ){ next }
  my($file, $length, $rev, $digest) = ($1, $2, $3, $4);
  my $full_path = "$RootDir/$file";
  $FilesInBom{$full_path} = {
    file => $file,
    length => $length,
    rev => $rev,
    digest => $digest,
  };
}
my %FilesInRootDir;
my $finder = sub {
  my $file_name = $File::Find::name;
  if(-d $file_name) { return }
  if($file_name eq $BOMfile) { return }
  unless(-r $file_name) { die "unreadable file $file_name" }
  if(-w $file_name) { print STDERR  "Warning writable file $file_name\n" }
  unless($file_name =~ /^$RootDir\/(.*)$/){ die "file not in directory" }
  my $rel_path = $1;
  open IDENT, "$ident \"$file_name\" 2>/dev/null|";
  my $rev;
  while (my $line = <IDENT>){
    if($line =~ /Revision: (.*) \$/){
      $rev = $1;
    }
  }
  unless(defined $rev) { $rev = "-" }
  close IDENT;
  open LEN, "wc -c \"$file_name\"|";
  my $line = <LEN>;
  close LEN;
  my $length;
  if($line =~ /\s*(\d+)\s/){
    $length = $1;
  }
  my $ctx = Digest::MD5->new;
  open FILE, "<$file_name";
  $ctx->addfile(*FILE);
  my $digest = $ctx->hexdigest;
  close FILE;
  $FilesInRootDir{$file_name} = {
    file => $rel_path,
    length => $length,
    rev => $rev,
    digest => $digest,
  }
};
find({wanted => $finder, follow => 1}, $RootDir);
#print "Files in Root Dir: ";
#Debug::GenPrint($dbg, \%FilesInRootDir, 1);
#print "\nFilesInBom: ";
#Debug::GenPrint($dbg, \%FilesInBom, 1);
#print "\n";
#exit;
my @InBomNotDir;
my @InDirNotBom;
my @Diff;
for my $file (sort keys %FilesInRootDir){
  unless(exists $FilesInBom{$file}){
    push(@InDirNotBom, $file);
    next;
  }
  unless(
    $FilesInRootDir{$file}->{file} eq $FilesInBom{$file}->{file} &&
    $FilesInRootDir{$file}->{length} eq $FilesInBom{$file}->{length} &&
    $FilesInRootDir{$file}->{rev} eq $FilesInBom{$file}->{rev} &&
    $FilesInRootDir{$file}->{digest} eq $FilesInBom{$file}->{digest}
  ){
    push(@Diff, $file);
  }
}
for my $file (sort keys %FilesInBom){
  unless(exists $FilesInRootDir{$file}){
    push(@InBomNotDir, $file);
  }
}
my $error_count = 0;
print "$BomTitle\n";
if(scalar @InBomNotDir){
  $error_count += scalar @InBomNotDir;
  print "The following files are in the BOM, but not the directory:\n";
  for my $file (@InBomNotDir){
    print "\t$file\n";
  }
}
if(scalar @InDirNotBom){
  $error_count += scalar @InDirNotBom;
  print "The following files are in the directory, but not the BOM:\n";
  for my $file (@InDirNotBom){
    print "\t$file\n";
  }
}
if(scalar @Diff){
  $error_count += scalar @Diff;
  print "The following files are different in the BOM versus Directory:\n";
  for my $file (@Diff){
    print "\t$file\n";
    for my $i (keys %{$FilesInRootDir{$file}}){
      unless($FilesInRootDir{$file}->{$i} eq $FilesInBom{$file}->{$i}){
        print "\t\tDir $i: $FilesInRootDir{$file}->{$i}\n";
        print "\t\tBOM $i: $FilesInBom{$file}->{$i}\n";
      }
    }
  }
}
if($error_count == 0){
  print "No discrepencies detected\n";
}
