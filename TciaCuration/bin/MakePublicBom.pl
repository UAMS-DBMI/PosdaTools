#!/usr/bin/perl -w
#$Source: /home/bbennett/pass/archive/TciaCuration/bin/MakePublicBom.pl,v $
#$Date: 2015/10/01 13:11:36 $
#$Revision: 1.1 $
#
use strict;
use Digest::MD5;
use Time::HiRes qw( time gettimeofday tv_interval );
$| = 1;
#The URI paths in the DB are:
#    my $db_root = "/usr/local/apps/ncia/CTP-server/CTP";
#    my $fs_root = "/mnt/erlbluearc/systems/cipa-images";
#/usr/local/apps/ncia/CTP-server/CTP/storage
#/usr/local/apps/ncia/CTP-server/CTP/storage-acrin
#
#These map to:
#/mnt/erlbluearc/systems/public-lss/data/storage
#/mnt/erlbluearc/systems/public-lss/data/storage-acrin
#
#
my $db_root = "/usr/local/apps/ncia/CTP-server/CTP";
my $fs_root = "/mnt/erlbluearc/systems/cipa-images";
my $t0 = [gettimeofday];
while(my $line = <STDIN>){
  chomp $line;
  my($path, $md5, $db_size, $day_time) = split(/\|/, $line);
  my $l_md5 = length($md5);
  if($l_md5 < 32){
    $md5 = ("0" x (32 - $l_md5)) . $md5;
  }
  my $file = $path;
  $file =~ s/$db_root/$fs_root/o;
  my($digest, $dev,$ino,$mode,$nlink,$uid,$gid,$rdev,$size,
     $atime,$mtime,$ctime,$blksize,$blocks, $md5_match, $size_match);
  if(-f $file){
    my $ctx = Digest::MD5->new;
    open FILE, "<$file";
    $ctx->addfile(*FILE);
    close FILE;
    $digest = $ctx->hexdigest;
    ($dev,$ino,$mode,$nlink,$uid,$gid,$rdev,$size,
       $atime,$mtime,$ctime,$blksize,$blocks)
       = stat($file);
    $md5_match = ($digest eq $md5) ? "Y" : "N";
    $size_match = ($size == $db_size) ? "Y" : "N";
  } else {
    $digest = "-" x 32;
    $md5_match = "N";
    $size_match = "N";
    $size = 0;
    $mtime = "---";
  }
  print "$file|$digest|$size|$md5_match|$size_match|$mtime\n";
}
