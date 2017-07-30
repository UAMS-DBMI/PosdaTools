#!/usr/bin/perl -w
use strict;
use Posda::DB::PosdaFilesQueries;
#use HexDump;
my $driver_query = PosdaDB::Queries->GetQueryInstance("FindDuplicatedPixelDigests");
my $check_query = PosdaDB::Queries->GetQueryInstance("SeeIfDigestIsAlreadyKnownDistinguished");
my $get_pix_desc = PosdaDB::Queries->GetQueryInstance("GetPixelDescriptorByDigest");
my $insert_distinguished =
  PosdaDB::Queries->GetQueryInstance("InsertDistinguishedDigest");
my $insert_distinguished_value =
  PosdaDB::Queries->GetQueryInstance("InsertDistinguishedValue");
my @digests;
my %NumDups;
$driver_query->RunQuery(
  sub {
    my($row) = @_;
    push(@digests, $row->[0]);
    $NumDups{$row->[0]} = $row->[1];
  }, sub {}
);
dig:
for my $dig (@digests){
  my $count;
  $check_query->RunQuery(
    sub {
      my($row) = @_;
      $count = $row->[0];
    }, sub {}, $dig
  );
  if($count == 1) {
    print "$dig is already known distinguished\n";
    next dig;
  }
  my %query_desc;
  $get_pix_desc->RunQuery(
    sub {
      my($row) = @_;
      $query_desc{samples_per_pixel} = $row->[0];
      $query_desc{number_of_frames} = $row->[1];
      $query_desc{pixel_rows} = $row->[2];
      $query_desc{pixel_columns} = $row->[3];
      $query_desc{bits_stored} = $row->[4];
      $query_desc{bits_allocated} = $row->[5];
      $query_desc{high_bit} = $row->[6];
      $query_desc{file_offset} = $row->[7];
      $query_desc{path} = $row->[8];
      unless(defined $query_desc{number_of_frames}){
        $query_desc{number_of_frames} = 1;
      }
    }, sub {}, $dig
  );
  if(defined $query_desc{path}){
    ## cases to handle:
    ##   1- 16 bits allocated, 12 bits stored, high bit 11,
    ##      frames null or 1, samples per pixel 1
    ##      : word length: 16
    ##      : mask: 0x0fff
    ##      : pixel length = pixel_rows * pixel_columns * 2
    ##   2- 16 bits allocated, 16 bits stored, high bit 15,
    ##      frames null or 1, samples per pixel 1
    ##      : word length: 16
    ##      : mask: 0xffff
    ##      : pixel length = pixel_rows * pixel_columns * 2
    ##   3- 16 bits allocated 8 bits stored, high bit 15,
    ##      frames null, samples per pixel 1
    ##      : word length: 16
    ##      : mask: 0xff00
    ##      : pixel length = pixel_rows * pixel_columns * 2
    ##   4- 16 bits allocated, 16 bits stored, high bit 15,
    ##      frames > 1, samples per pixel 1
    ##      : word length: 16
    ##      : mask: 0xffff
    ##      : pixel length = pixel_rows * pixel_columns * num_frames * 2
    ##   5- 8 bits allocated, 8 bits stored, high bit 7,
    ##      frames null or 1, samples per pixel 1
    ##      : word length: 8
    ##      : mask: 0xff
    ##      : pixel length = pixel_rows * pixel_columns
    ##   6- 8 bits allocated, 8 bits stored, high bit 7,
    ##      frames null or 1, samples per pixel 3
    ##      : word length: 8
    ##      : mask: 0xff
    ##      : pixel length = pixel_rows * pixel_columns * 3
    ##   7- 32 bits allocated, 32 bits stored, high bit 31,
    ##      frames > 1, samples per pixel 1
    my($word_len, $mask, $pix_len);
    my $seek_whence = $query_desc{file_offset};
    my $file_path = $query_desc{path};
    if($query_desc{bits_allocated} == 16){
      # 1 - 4
      if($query_desc{number_of_frames} == 1){
        # 1 - 3
        if($query_desc{bits_stored} == 12){
          # 1 (maybe)
          # someday, verify all params
          $word_len = 16;
          $mask = 0xfff;
          $pix_len = $query_desc{pixel_rows} * $query_desc{pixel_columns} * 2;
        } elsif($query_desc{bits_stored} == 16){
          # 2 (maybe)
          # someday, verify all params
          $word_len = 16;
          $mask = 0xffff;
          $pix_len = $query_desc{pixel_rows} * $query_desc{pixel_columns} * 2;
        } elsif($query_desc{bits_stored} == 8){
          # 3 (maybe)
          # someday, verify all params
          print "$dig: 3\n";
          $word_len = 16;
          $mask = 0xff00;
          $pix_len = $query_desc{pixel_rows} * $query_desc{pixel_columns} * 2;
        } else {
          print STDERR "digest $dig has unhandled bits_stored: " .
            "$query_desc{bits_stored}\n" .
            "\tfor bits_allocated = $query_desc{bits_allocated}\n";
          next dig;
        }
      } else {
        # 4 (maybe)
        # someday, verify all params
        $word_len = 16;
        $mask = 0xffff;
        $pix_len = $query_desc{pixel_rows} * $query_desc{pixel_columns} * 2
          * $query_desc{number_of_frames};
      }
    } elsif($query_desc{bits_allocated} == 8){
      # 5, 6
      if($query_desc{samples_per_pixel} == 1){
        # 5 (maybe)
        # someday, verify all params
        $word_len = 8;
        $mask = 0xff;
        $pix_len = $query_desc{pixel_rows} * $query_desc{pixel_columns};
      } else {
        # 6 (maybe)
        # someday, verify all params
        $word_len = 8;
        $mask = 0xff;
        $pix_len = $query_desc{pixel_rows} * $query_desc{pixel_columns} * 3;
      }
    } elsif($query_desc{bits_allocated} == 32){
      # 7 (maybe)
      # someday, verify all params
      $word_len = 32;
      $mask = 0xffffffff;
      $pix_len = $query_desc{pixel_rows} * $query_desc{pixel_columns} * 4
        * $query_desc{num_number_of_frames};
    } else {
      print STDERR "digest $dig has unhandled bits_allocated: " .
        "$query_desc{bits_allocated}\n";
      next dig;
    }
    open FILE, "<$file_path" or die "Can't open $file_path ($!)";
    my $buff;
    seek FILE, $seek_whence, 0;
    my $len_read = read (FILE, $buff, $pix_len);
    unless($len_read == $pix_len){
      die "Wrong # bytes read ($len_read vs $pix_len)";
    }
    my @pixels;
    my $unpacker;
    if($word_len == 16){
      $unpacker = "S$pix_len";
      $unpacker = "W$pix_len";
    } elsif($word_len == 8){
      $unpacker = "C$pix_len";
    } elsif($word_len == 32){
      $unpacker = "L$pix_len";
    } else {
      die "unknown pix_len: $word_len";
    }
    @pixels = unpack $unpacker, $buff;
    my $u_pix_len = @pixels;
    my %Values;
    for my $i (0 .. $#pixels){
      my $v = $pixels[$i];
#      print "pix: $v ";
      $v  = $v & $mask;
#      print "masked: $v\n";
      if(exists $Values{$v}){
        $Values{$v} += 1;
      } else {
        $Values{$v} = 1;
      }
    }
    my $num_values = keys %Values;
    if ($num_values ==  1){
      print "#########\n";
      print "$dig ($NumDups{$dig}):\n";
      print "\tpath: $file_path\n" .
        "\twhence: $seek_whence\n" .
        "\tlength: $pix_len\n" .
        "\tpix_len: $word_len\n" .
        "\tmask: $mask\n" .
        "\trows: $query_desc{pixel_rows}\n" .
        "\tcols: $query_desc{pixel_columns}\n" .
        "\tbits: $query_desc{bits_allocated}\n" .
        "\tstore: $query_desc{bits_stored}\n" .
        "\thigh: $query_desc{high_bit}\n" .
        "\tsamp: $query_desc{samples_per_pixel}\n" .
        "\tframes: $query_desc{number_of_frames}\n";
      print "$num_values distinct values found\n";
      for my $i (sort { $Values{$a} <=> $Values{$b} } keys %Values){
        print "\t$i: $Values{$i}\n";
      }
      $insert_distinguished->RunQuery(
        sub{}, sub {},
        $dig,
        "blank image",
        $query_desc{samples_per_pixel},
        $query_desc{number_of_frames},
        $query_desc{pixel_rows},
        $query_desc{pixel_columns},
        $query_desc{bits_stored},
        $query_desc{bits_allocated},
        $query_desc{high_bit},
        $mask,
        1
      );
      my $the_value = [keys %Values]->[0];
      $insert_distinguished_value->RunQuery(
        sub{}, sub {},
        $dig, $the_value, $Values{$the_value}
      );
    } elsif(
      $num_values <= 3 && $query_desc{samples_per_pixel} == 3
    ) {
      my @values = keys %Values;
      if(
        $Values{$values[0]} == $Values{$values[0]} &&
        $Values{$values[1]} == $Values{$values[2]}
      ){
        print "#########\n";
        print "$dig ($NumDups{$dig}):\n";
        print "\tpath: $file_path\n" .
          "\twhence: $seek_whence\n" .
          "\tlength: $pix_len\n" .
          "\tpix_len: $word_len\n" .
          "\tmask: $mask\n" .
          "\trows: $query_desc{pixel_rows}\n" .
          "\tcols: $query_desc{pixel_columns}\n" .
          "\tbits: $query_desc{bits_allocated}\n" .
          "\tstore: $query_desc{bits_stored}\n" .
          "\thigh: $query_desc{high_bit}\n" .
          "\tsamp: $query_desc{samples_per_pixel}\n" .
          "\tframes: $query_desc{number_of_frames}\n";
        print "$num_values distinct values found\n";
        for my $i (sort { $Values{$a} <=> $Values{$b} } keys %Values){
          print "\t$i: $Values{$i}\n";
        }
        $insert_distinguished->RunQuery(
          sub{}, sub {},
          $dig,
          "blank image",
          $query_desc{samples_per_pixel},
          $query_desc{number_of_frames},
          $query_desc{pixel_rows},
          $query_desc{pixel_columns},
          $query_desc{bits_stored},
          $query_desc{bits_allocated},
          $query_desc{high_bit},
          $mask,
          3
        );
        for my $the_value (@values){
          $insert_distinguished_value->RunQuery(
            sub{}, sub {},
            $dig, $the_value, $Values{$the_value}
          );
        }
      } else {
        print "****************\n";
        print "Values: $values[0] ($Values{$values[0]}), " .
          "$values[1] ($Values{$values[1]}), " .
          "$values[2] ($Values{$values[2]})\n";
      }
    } else {
      print "$dig ($NumDups{$dig}): not distinguished ($num_values)\n";
      if($num_values <= 10){
        my @values = keys %Values;
        for my $i (sort {$Values{$a} <=> $Values{$b} } @values){
          print "\tvalue: $i ($Values{$i})\n";
        }
      }
    }
  }
}
