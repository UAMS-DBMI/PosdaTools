#!/usr/bin/perl -w
#
use strict;
use Storable;
use PosdaCuration::ExtractionManagerIf;
use Debug;
my $dbg = sub { print STDERR @_ };
my $usage = "PerformPluginEdits.pl <root> <collection> <site> <session> <user> <plugin_name> <port> <cache_dir>\n";
unless($#ARGV == 7) { die $usage }
my $pid = $0;
my $root = $ARGV[0];
my $col = $ARGV[1];
my $site = $ARGV[2];
my $session = $ARGV[3];
my $user = $ARGV[4];
my $plugin = $ARGV[5];
my $port = $ARGV[6];
my $cache_dir = $ARGV[7];
my $root_dir = "$root/$col/$site";
unless(-d $root_dir) { die "root_dir is not a directory" };
opendir ROOT, $root_dir or die "Can't opendir $root_dir";
my @subjs;
while (my $subj = readdir(ROOT)){
  if($subj =~ /^\./) {next}
  unless(-d "$root_dir/$subj") { next }
  push(@subjs, $subj);
}
closedir ROOT;
my $ExIf = PosdaCuration::ExtractionManagerIf->new(
  $port, $user, $session, $pid, 0
);
subj:
for my $subj (sort @subjs){
  unless(-d "$root_dir/$subj" && -f "$root_dir/$subj/rev_hist.pinfo"){
    next subj;
  }
  my $rev_hist = Storable::retrieve("$root_dir/$subj/rev_hist.pinfo");
  my $current_rev = $rev_hist->{CurrentRev};
  my $old_info_dir = "$root_dir/$subj/revisions/$current_rev";
  my $source_dir = "$old_info_dir/files";
  unless(-d $old_info_dir && -f "$old_info_dir/dicom.pinfo"){
    next subj;
  }
  my $file_info = Storable::retrieve("$old_info_dir/dicom.pinfo");
#  print "Locking $col, $site, $subj, $plugin\n";
  my $lines = $ExIf->LockForEdit($col, $site, $subj, $plugin);
  my %resp;
  for my $line (@$lines){
    if($line =~ /(.*):\s*(.*)$/){
      my $k = $1; my $v = $2;
      $resp{$k} = $v;
    }
  }
  if(exists($resp{Locked}) && $resp{Locked} eq "OK"){  
    my $trans_id = $resp{Id};
#    print "Locked $col, $site, $subj\n";
#    for my $k (sort keys %resp){
#      print "\t$k: $resp{$k}\n";
#    }
    my $new_info_dir = $resp{"Revision Dir"};
    my $dest_dir = $resp{"Destination File Directory"};
    ######  Calculate edits (to be replaced by plugin)
    # What we have:
    #   $file_info = from dicom.pinfo (has full list of source files)
    #   $old_info_dir = The 'from' revision dir
    #   $new_info_dir = The 'to' revision dir
    #   $source_dir = Where files come from
    #   $dest_dir = Where new files go
    #   $cache_dir = Where to cache DICOM info for new files (by digest) 
    #   Walk through files, see if they need to be edited, and if so,
    #   build FileEdits here
    my %FilesToLink;
    my %Edits;
    file:
    for my $file (keys %{$file_info->{FilesToDigest}}){
      my $dig = $file_info->{FilesToDigest}->{$file};
      my $f_info = $file_info->{FilesByDigest}->{$dig};
      if($f_info->{modality} ne "RTSTRUCT") {
        $FilesToLink{$file} = $dig;
        next file;
      }
      my $cmd = "FixForRtStructWithPixelOrFor.pl $file";
      open FILE_INFO, "$cmd|" or next file;
      my $edits = Storable::fd_retrieve(\*FILE_INFO);
      close FILE_INFO;
      unless(
        exists($edits->{$file}) &&
        exists($edits->{$file}->{delete})
      ) {
        $FilesToLink{$file} = $dig;
        next file;
      }
      unless($file =~ /^$source_dir\/(.*)$/){
        print STDERR "WTF?  file ($file) isn't in dir ($source_dir)\n";
        next file;
      }
      my $dest_file = "$dest_dir/$1";
      $Edits{$file} = {
         from_file => $file,
         to_file => $dest_file,
      };
      for my $ele (keys %{$edits->{$file}->{delete}}){
         $Edits{$file}->{full_ele_deletes}->{$ele} = 1;
      }
    }
    if(keys %Edits > 0){
      my $CreationInfo = {
        cache_dir => $cache_dir,
        destination => $dest_dir,
        files_to_link => \%FilesToLink,
        info_dir => $new_info_dir,
        operation => "EditAndAnalyze",
        parallelism => "3",
        FileEdits => \%Edits,
        source => $source_dir
      };
      #print STDERR "Creation Info: ";
      #Debug::GenPrint($dbg, $CreationInfo, 1);
      #print STDERR "\n";
      Storable::store($CreationInfo, "$new_info_dir/creation.pinfo");
      #
      ######  Here's where the edits are to be applied
      my $lines = $ExIf->ApplyEdits($trans_id, $plugin,
        "$new_info_dir/creation.pinfo");
      print "Applied edit to $col, $site, $subj:\n";
#      for my $line (@$lines){
#        print "\t$line\n";
#      }
    } else {
      ######  No edits to apply - Unlock
      my $lines = $ExIf->ReleaseLockWithNoEdit($trans_id);
      print "No edits for $col, $site, $subj\n";
#      for my $line (@$lines){
#        print "\t$line\n";
#      }
    }
  } else {
    print STDERR "Error locking $col, $site, $subj:\n" .
      "\t$resp{Error}\n";
  }
}
