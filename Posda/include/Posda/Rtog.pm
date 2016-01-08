#$Source: /home/bbennett/pass/archive/Posda/include/Posda/Rtog.pm,v $
#$Date: 2012/02/07 13:41:44 $
#$Revision: 1.3 $
#
#Copyright 2008, Bill Bennett
# Part of the Posda package
# Posda may be copied only under the terms of either the Artistic License or the
# GNU General Public License, which may be found in the Posda Distribution,
# or at http://posda.com/License.html
#
use strict;
package Posda::Rtog;

{
  package Posda::Rtog::FilesetDesc;
  sub NewFromFileSet{
    my($class, $base_file, $image_dir, $tar_file_id) = @_;
    unless(-d $image_dir) { die "$image_dir is not a directory" };
    open DIRFILE, "<", "$image_dir/${base_file}0000" or 
      die "Can't find RTOG directory (${base_file}0000) file " .
          "in dir $image_dir";
    my $this = {
      base_file => $base_file,
      storage_root => $image_dir,
      tar_file_id => $tar_file_id,
    };
    my $currecord;
    while(my $line = <DIRFILE>){
      $line =~ s/\r//g;
      $line =~ s/\0//g;
      chomp $line;
#      print "line: $line\n";
      if($line =~ /^\s*$/) {next}
      unless($line =~ /^\s*(.*)\s*:=\s*(.*)\s*$/){
        print "non matching: '$line'\n";
        return undef;
#          next;
      }
      my $key = $1;
      my $value = $2;
      $key =~ s/\s//g;
      $key =~ s/#/number/g;
      $key =~ tr/a-z/A-Z/;
#      print "$key = $value\n";
      if($key eq "IMAGENUMBER"){
        if(defined $currecord){
          push(@{$this->{records}}, $currecord);
        }
        $currecord = {
           IMAGENUMBER => $value,
        };
      } else {
        if(defined $currecord){
          $currecord->{$key} = $value;
        } else {
          $this->{$key} = $value;
        }
      }
    }
    push(@{$this->{records}}, $currecord);
    return bless $this, $class;
  }
  sub InstantiateFileSet{
    my($this, $db) = @_;
    my $q = $db->prepare(
    "insert into rtog_fileset(rtog_tar_file_id, rtog_base_file) values (?, ?)"
    );
    $q->execute($this->{tar_file_id}, $this->{base_file});
    $q = $db->prepare(
      "select currval('rtog_fileset_rtog_fileset_id_seq') as id");
    $q->execute();
    my $h = $q->fetchrow_hashref();
    $q->finish();
    unless($h && ref($h) eq "HASH") { die "can't get fileset_id" }
    my $id = $h->{id};
    $this->{fileset_id} = $id;
    {
      my $from_file = "$this->{base_file}0000";
      unless(-f $from_file) {
        die "directory file disappeared";
      }
      my $to_dir = "$this->{storage_root}/$id";
      unless(-d $to_dir) { `mkdir $to_dir` }
      unless(-d $to_dir) { die "mkdir apparently failed" }
      my $to_file = "$to_dir/0000.dir";
      `cp \"$from_file\" \"$to_file\"`;
      my $q = $db->prepare(
        "insert into rtog_dir_file(rtog_fileset_id, rd_path)\n" .
        "values (?, ?)"
      );
      $q->execute($id, $to_file);
    }
    for my $i (keys %$this){
      if(ref($this->{$i}) eq "ARRAY"){
        unless($i eq "records") { die "key \"$i\" is ARRAY" }
        next;
      }
      $q = $db->prepare(
        "insert into rtog_fileset_attr(\n" .
        "  rtog_fileset_id, fs_key, fs_value\n" .
        ") values (?, ?, ?)");
      $q->execute($id, $i, $this->{$i});
    }
    my $rec_num = 0;
    image:
    for my $r (@{$this->{records}}){
      $rec_num += 1;
      unless($r->{IMAGENUMBER} eq $rec_num){
        print STDERR 
          "nonmatching image_number: $rec_num vs $r->{IMAGENUMBER}\n";
        $rec_num = $r->{IMAGENUMBER};
      }
      $q = $db->prepare(
        "insert into rtog_image(\n" .
        "  rtog_fileset_id, image_number\n" .
        ")values(?, ?)"
      );
      $q->execute($id, $rec_num);
      for my $i (keys %$r){
        $q = $db->prepare(
          "insert into rtog_image_attr(\n" .
          "  rtog_fileset_id, image_number, im_key, im_value\n" . 
          ") values (?, ?, ?, ?)"
        );
        $q->execute($id, $rec_num, $i, $r->{$i});
      }
      my $from_file = sprintf("$this->{base_file}%04d", $rec_num);
      unless(-f $from_file) {
        print STDERR "non_existent image_file: $from_file\n";
        next image;
      }
      my $to_dir = "$this->{storage_root}/$id";
      unless(-d $to_dir) { `mkdir $to_dir` }
      unless(-d $to_dir) { die "mkdir apparently failed" }
      my $to_file = "$to_dir/$rec_num.img";
      `cp \"$from_file\" \"$to_file\"`;
      $q = $db->prepare(
        "insert into rtog_image_file(\n " .
        "  rtog_fileset_id, image_number, im_path\n" .
        ") values (?, ?, ?)"
      );
      $q->execute($id, $rec_num, $to_file);
    }
  }
}
{
  package Posda::Rtog;
  sub NewFromDir{
    my($class, $dir) = @_;
    my $base_file;
    opendir DIR, "$dir" or die "can't opendir $dir";
    my $rf;
    my $this = {};
    while(my $file = readdir(DIR)){
      if($file =~ /^(.*)(\d\d\d\d)$/){
        my $b_file = $1;
        my $index = $2;
        unless(defined $base_file){ $base_file = $b_file }
        if ($base_file ne $b_file) {
          die "Two potential basefiles:\n" .
            "\t\"${base_file}0000\" and\n" .
            "\t\"$file\"";
        }
        if($index == 0){
          $rf = 
            Posda::Rtog::FilesetDesc->NewFromFileSet("$base_file", $dir, 0);
        } else {
          my $i = $index + 0;
          $this->{image_file}->{$i} = "$dir/$file";
        }
      }
    }
    unless($rf) { die "didn't find or parse basefile" }
    for my $i (keys %$rf){
      unless($i eq "records"){
        $this->{fileset_attr}->{$i} = $rf->{$i};
      }
    }
    for my $r (@{$rf->{records}}){
      my $fi = $r->{IMAGENUMBER};
      $this->{image_attr}->{$fi} = $r;
    }
    $this->{dir_path} = "";
    return bless $this, $class;
  }
  sub NewFromId{
    my($class, $db, $id) = @_;
    my $q = $db->prepare(
      "select rd_path as dir_path from rtog_dir_file where rtog_fileset_id = ?"
    );
    $q->execute($id);
    my $h = $q->fetchrow_hashref();
    $q->finish();
    unless($h && ref($h) eq "HASH") { die "couldn't get a dir file for id: $id" }
    my $dir_path = $q->{dir_path};
    $q = $db->prepare(
      "select fs_key as key, fs_value as value from rtog_fileset_attr\n" .
      "where rtog_fileset_id = ?"
    );
    my %fileset_attr;
    $q->execute($id);
    while (my $h = $q->fetchrow_hashref()){
      $fileset_attr{$h->{key}} = $h->{value};
    }
    my %image_attr;
    $q = $db->prepare(
      "select image_number, im_key as key, im_value as value\n" .
      "from rtog_image_attr\n" .
      "where rtog_fileset_id = ?"
    );
    $q->execute($id);
    while (my $h = $q->fetchrow_hashref()){
      $image_attr{$h->{image_number}}->{$h->{key}} = $h->{value};
    }
    my %image_files;
    $q = $db->prepare(
      "select image_number, im_path as file_path\n" .
      "from rtog_image_file\n" .
      "where rtog_fileset_id = ?"
    );
    $q->execute($id);
    while(my $h = $q->fetchrow_hashref()){
      $image_files{$h->{image_number}} = $h->{file_path};
    }
    my $this = {
      dir_path => $dir_path,
      fileset_attr => \%fileset_attr,
      image_attr => \%image_attr,
      image_file => \%image_files,
    };
    for my $i (sort { $a <=> $b } keys %image_attr){
      unless(exists ($image_files{$i})){ die "image %i has no file" }
    }
    return bless $this, $class;
  }
}
1;
