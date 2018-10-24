#!/usr/bin/perl -w
#
#Copyright 2010, Bill Bennett
# Part of the Posda package
# Posda may be copied only under the terms of either the Artistic License or the
# GNU General Public License, which may be found in the Posda Distribution,
# or at http://posda.com/License.html
#
package Posda::AutoAnonymizer;
use strict;

####### Query text's ###########
my $create_anonymization = <<EOF;
insert into anonymization(run_at, run_by, run_on, source_file)
values(now(), ?, ?, ?)
EOF
my $get_anonymization_id = <<EOF;
select currval('anonymization_anonymization_id_seq') as anonymization_id
EOF
####### Query text's ###########
sub GenerateNewPseudoSeq{
  my($db, $type) = @_;
  my $q = $db->prepare(
    "SELECT pseudo_sequence FROM pseudo_type_sequence\n" .
    "WHERE pseudo_type = ? FOR UPDATE"
  );
  $q->execute($type);
  my $h = $q->fetchrow_hashref();
  $q->finish();
  if($h && ref($h) eq "HASH"){
    my $seq = $h->{pseudo_sequence};
    $seq += 1;
    $q = $db->prepare(
      "UPDATE pseudo_type_sequence SET pseudo_sequence = ?\n" .
      "where pseudo_type = ?"
    );
    $q->execute($seq, $type);
    return $seq;
  } else {
    $q = $db->prepare(
      "INSERT INTO pseudo_type_sequence(pseudo_type, pseudo_sequence)\n" .
      "VALUES (?, ?)"
    );
    $q->execute($type, 1);
    return 1;
  }
}
sub CreateAnonValue{
  my($db, $a_id, $ps_id, $text) = @_;
  my $q = $db->prepare(
    "INSERT INTO anon_value(\n" .
    "  anonymization_id, pseudo_value_id, original_value\n" .
    ") VALUES (\n" .
    "  ?, ?, ?\n" .
    ")"
  );
  $q->execute($a_id, $ps_id, $text);
}
sub CreatePseudoValue{
  my($db, $name, $value) = @_;
  my $q = $db->prepare(
    "INSERT INTO pseudo_value(pseudo_type, pseudo_value)\n" .
    "VALUES(?, ?)"
  );
  $q->execute($name, $value);
  $q = $db->prepare(
    "select currval('pseudo_value_pseudo_value_id_seq') as id"
  );
  $q->execute();
  my $h = $q->fetchrow_hashref();
  $q->finish();
  unless($h && ref($h) eq "HASH"){
    die "couldn't fetch pseudo_value_id";
  }
  return $h->{id};
}
sub FindMapping {
  my($db, $type, $orig_value) = @_;
  my $q = $db->prepare(
    "SELECT pseudo_value_id, pseudo_value\n" .
    "FROM pseudo_value NATURAL JOIN anon_value\n" .
    "WHERE pseudo_type = ? and original_value = ?"
  );
  $q->execute($type, $orig_value);
  my $h = $q->fetchrow_hashref();
  $q->finish;
  if($h && ref($h) eq "HASH" && $h->{pseudo_value_id}){
    return($h->{pseudo_value_id}, $h->{pseudo_value});
  }
  return (undef, undef);
}

my $DeleteThese = {
  "Institution Address" => 1,
};
my $MapThese = {
#  "Accession Number" => sub {
#    my($db, $map, $id) = @_;
#    my($ps_id, $ps_value) = FindMapping($db, 'accession_no', $map->{from});
#    unless($ps_id) {
#      $ps_value = GenerateNewPseudoSeq($db, 'accession_number');
#      $ps_id = CreatePseudoValue($db, 'accession_number', $ps_value)
#      CreateAnonValue($db, $id, $ps_id, $map->{from});
#    }
#    $map->{to} = $ps_value;
#    return $map;
#  },
  "Institution Name" => sub{
    my($db, $map, $id) = @_;
    my($ps_id, $ps_value) = FindMapping($db, 'institution_name', $map->{from});
    unless($ps_id) {
      my $seq = GenerateNewPseudoSeq($db, 'institution_name');
      $ps_value = "Anon Institution $seq";
      $ps_id = CreatePseudoValue($db, 'institution_name', $ps_value);
      CreateAnonValue($db, $id, $ps_id, $map->{from});
    }
    $map->{to} = $ps_value;
    return $map;
  },
  "Institutional Department Name" => sub{
    my($db, $map, $id) = @_;
    my($ps_id, $ps_value) = FindMapping($db, 'dept_name', $map->{from});
    unless($ps_id) {
      my $seq = GenerateNewPseudoSeq($db, 'dept_name');
      $ps_value = "Anon Dept $seq";
      $ps_id = CreatePseudoValue($db, 'dept_name', $ps_value);
      CreateAnonValue($db, $id, $ps_id, $map->{from});
    }
    $map->{to} = $ps_value;
    return $map;
  },
  "Referring Physician's Name" => sub{
    my($db, $map, $id) = @_;
    my($ps_id, $ps_value) = FindMapping($db, 'ref_phy', $map->{from});
    unless($ps_id) {
      my $seq = GenerateNewPseudoSeq($db, 'ref_phy');
      $ps_value = "AnonPhy^Referring_$seq";
      $ps_id = CreatePseudoValue($db, 'ref_phy', $ps_value);
      CreateAnonValue($db, $id, $ps_id, $map->{from});
    }
    $map->{to} = $ps_value;
    return $map;
  },
  "Physician of Record" => sub{
    my($db, $map, $id) = @_;
    my($ps_id, $ps_value) = FindMapping($db, 'rec_phy', $map->{from});
    unless($ps_id) {
      my $seq = GenerateNewPseudoSeq($db, 'rec_phy');
      $ps_value = "AnonPhy^Record_$seq";
      $ps_id = CreatePseudoValue($db, 'rec_phy', $ps_value);
      CreateAnonValue($db, $id, $ps_id, $map->{from});
    }
    $map->{to} = $ps_value;
    return $map;
  },
  "Performing Physician's Name" => sub{
    my($db, $map, $id) = @_;
    my($ps_id, $ps_value) = FindMapping($db, 'per_phy', $map->{from});
    unless($ps_id) {
      my $seq = GenerateNewPseudoSeq($db, 'per_phy');
      $ps_value = "AnonPhy^Performing_$seq";
      $ps_id = CreatePseudoValue($db, 'per_phy', $ps_value);
      CreateAnonValue($db, $id, $ps_id, $map->{from});
    }
    $map->{to} = $ps_value;
    return $map;
  },
  "Name of Physician(s) Reading Study" => sub{
    my($db, $map, $id) = @_;
    my($ps_id, $ps_value) = FindMapping($db, 'reading_phy', $map->{from});
    unless($ps_id) {
      my $seq = GenerateNewPseudoSeq($db, 'reading_phy');
      $ps_value = "AnonPhy^Reading_$seq";
      $ps_id = CreatePseudoValue($db, 'reading_phy', $ps_value);
      CreateAnonValue($db, $id, $ps_id, $map->{from});
    }
    $map->{to} = $ps_value;
    return $map;
  },
  "Station Name" => sub{
    my($db, $map, $id) = @_;
    my($ps_id, $ps_value) = FindMapping($db, 'station', $map->{from});
    unless($ps_id) {
      my $seq = GenerateNewPseudoSeq($db, 'station');
      $ps_value = "Station_$seq";
      $ps_id = CreatePseudoValue($db, 'station', $ps_value);
      CreateAnonValue($db, $id, $ps_id, $map->{from});
    }
    $map->{to} = $ps_value;
    return $map;
  },
  "Operator's Name" => sub{
    my($db, $map, $id) = @_;
    my($ps_id, $ps_value) = FindMapping($db, 'operator', $map->{from});
    unless($ps_id) {
      my $seq = GenerateNewPseudoSeq($db, 'operator');
      $ps_value = "Anonymous^Operator_$seq";
      $ps_id = CreatePseudoValue($db, 'operator', $ps_value);
      CreateAnonValue($db, $id, $ps_id, $map->{from});
    }
    $map->{to} = $ps_value;
    return $map;
  },
  "Patient's Name" => sub{
    my($db, $map, $id) = @_;
    my($ps_id, $ps_value) = FindMapping($db, 'patient_name', $map->{from});
    unless($ps_id) {
      my $seq = GenerateNewPseudoSeq($db, 'patient_name');
      $ps_value = "Anonymous^Patient_$seq";
      $ps_id = CreatePseudoValue($db, 'patient_name', $ps_value);
      CreateAnonValue($db, $id, $ps_id, $map->{from});
    }
    $map->{to} = $ps_value;
    return $map;
  },
  "Patient's ID" => sub{
    my($db, $map, $id) = @_;
    my($ps_id, $ps_value) = FindMapping($db, 'patient_id', $map->{from});
    unless($ps_id) {
      my $seq = GenerateNewPseudoSeq($db, 'patient_id');
      $ps_value = "PID_$seq";
      $ps_id = CreatePseudoValue($db, 'patient_id', $ps_value);
      CreateAnonValue($db, $id, $ps_id, $map->{from});
    }
    $map->{to} = $ps_value;
    return $map;
  },
  "Other Patient's ID's" => sub{
    my($db, $map, $id) = @_;
    my($ps_id, $ps_value) = FindMapping($db, 'patient_id', $map->{from});
    unless($ps_id) {
      my $seq = GenerateNewPseudoSeq($db, 'patient_id');
      $ps_value = "PID_$seq";
      $ps_id = CreatePseudoValue($db, 'patient_id', $ps_value);
      CreateAnonValue($db, $id, $ps_id, $map->{from});
    }
    $map->{to} = $ps_value;
    return $map;
  },
  "Device Serial Number" => sub{
    my($db, $map, $id) = @_;
    my($ps_id, $ps_value) = FindMapping($db, 'serial_no', $map->{from});
    unless($ps_id) {
      my $seq = GenerateNewPseudoSeq($db, 'serial_no');
      $ps_value = "SN_$seq";
      $ps_id = CreatePseudoValue($db, 'serial_no', $ps_value);
      CreateAnonValue($db, $id, $ps_id, $map->{from});
    }
    $map->{to} = $ps_value;
    return $map;
  },
  "Study ID" => sub{
    my($db, $map, $id) = @_;
    my($ps_id, $ps_value) = FindMapping($db, 'study_id', $map->{from});
    unless($ps_id) {
      my $seq = GenerateNewPseudoSeq($db, 'study_id');
      $ps_value = "STUDY_$seq";
      $ps_id = CreatePseudoValue($db, 'study_id', $ps_value);
      CreateAnonValue($db, $id, $ps_id, $map->{from});
    }
    $map->{to} = $ps_value;
    return $map;
  },
  "Performed Procedure Step ID" => sub{
    my($db, $map, $id) = @_;
    my($ps_id, $ps_value) = FindMapping($db, 'ps_id', $map->{from});
    unless($ps_id) {
      my $seq = GenerateNewPseudoSeq($db, 'ps_id');
      $ps_value = "PSID_$seq";
      $ps_id = CreatePseudoValue($db, 'ps_id', $ps_value);
      CreateAnonValue($db, $id, $ps_id, $map->{from});
    }
    $map->{to} = $ps_value;
    return $map;
  },
  "Reviewer Name" => sub{
    my($db, $map, $id) = @_;
    my($ps_id, $ps_value) = FindMapping($db, 'reviewer', $map->{from});
    unless($ps_id) {
      my $seq = GenerateNewPseudoSeq($db, 'reviewer');
      $ps_value = "ANONYMOUS^Reviewer_$seq";
      $ps_id = CreatePseudoValue($db, 'reviewer', $ps_value);
      CreateAnonValue($db, $id, $ps_id, $map->{from});
    }
    $map->{to} = $ps_value;
    return $map;
  },
};
my $PreserveThese = {
  "Study Description" => 1,
  "Series Description" => 1,
  "Institutional Department Name" => 1,
  "Admitting Diagnoses Description" => 1,
  "Derivation Description" => 1,
  "Patient's Sex" => 1,
  "Patient's Age" => 1,
  "Patient's Size" => 1,
  "Patient's Weight" => 1,
  "Ethnic Group" => 1,
  "Patient Comments" => 1,
  "Protocol Name" => 1,
  "Image Comments" => 1,
  "Structure Set Label" => 1,
  "Structure Set Name" => 1,
  "Roi Interpreter" => 1,
  "Rt Plan Label" => 1,
  "Rt Plan Name" => 1,
};

sub new {
  my($class, $db, $run_by, $run_on, $orig_file, $fh) = @_;
  my @maps;
  my $seq = 1;
  my $q = $db->prepare($create_anonymization);
  $q->execute(
    $run_by, $run_on, $orig_file
  );
  my $anonymization_id;
  $q = $db->prepare($get_anonymization_id);
  $q->execute();
  my $h = $q->fetchrow_hashref();
  $q->finish();
  $anonymization_id = $h->{anonymization_id};
  while (my $rec = <$fh>){
    chomp $rec;
    my @fields = split (/\|/, $rec);
    if($fields[0] eq "map"){
      unless($fields[3] =~ /\s*\"([^\"]*)\" => \"([^\"]*)\"/){
        print "Non Matching line: $rec\n";
        next;
      }
      my $from = $1; my $to = $2;
      push(@maps, {
        type => $fields[0],
        sig => $fields[1],
        name => $fields[2],
        from => $from,
        to => $to,
      });
    } elsif($fields[0] eq "date_map"){
      unless($fields[1] =~ /\s*\"([^\"]*)\"\s*=>\s*\"([^\"]*)\"/){
        print "Non matching line: $rec\n";
        next;
      }
      my $from = $1; my $to = $2;
      push(@maps, {
        type => $fields[0],
        from => $from,
        to => $to,
      });
    }
  }
  my @filtered_maps;
  my $NewAccessionNumber;
  my $NewAccessionID;
  for my $i (@maps){
    if(
      $i->{type} eq "map" &&
      $i->{name} ne "Accession Number" &&
      $i->{from} eq ""
    ){ next };
    if($i->{type} eq "map" && $i->{name} eq "Accession Number"){
      unless(defined $NewAccessionNumber){
        $NewAccessionNumber = GenerateNewPseudoSeq($db, 'accession_number');
        $NewAccessionID = CreatePseudoValue($db, 'accession_number',
          $NewAccessionNumber);
      }
      CreateAnonValue($db, $anonymization_id, $NewAccessionID, $i->{from});
      $i->{to} = $NewAccessionNumber;
      push(@filtered_maps, $i);
      next;
    }
    if($i->{type} eq "map" && exists $PreserveThese->{$i->{name}}) { next }
    if($i->{type} eq "map" && exists $DeleteThese->{$i->{name}}){
      push(@filtered_maps, {
        type => "delete",
        sig => $i->{sig},
        name => $i->{name},
      });
      next;
    }
    if($i->{type} eq "map" && exists $MapThese->{$i->{name}}){
      push(@filtered_maps,
        &{$MapThese->{$i->{name}}}($db, $i, $anonymization_id)
      );
    }
    if($i->{type} eq "date_map"){
      if($i->{from} eq "") { next }
      push(@filtered_maps, MapADate($db, $i, $anonymization_id));
    }
  }
  my $this = {
    id => $anonymization_id,
    map => \@filtered_maps,
  };
  return bless($this, $class);
}

sub StoreMapping{
  my($this, $db) = @_;
  my $sort_order = 1;
  for my $i (@{$this->{map}}){
    if ($i->{type} eq "map"){
      my $q = $db->prepare(
        "INSERT INTO anon_mapping(\n" .
        "  anonymization_id,\n" .
        "  am_sort_order,\n" .
        "  am_type,\n" .
        "  am_sig,\n" .
        "  am_name,\n" .
        "  am_from,\n" .
        "  am_to\n" .
        ") VALUES (\n" .
        "  ?, ?, ?, ?, ?, ?, ?\n" .
        ")" 
      );
      $q->execute(
        $this->{id},
        $sort_order,
        $i->{type},
        $i->{sig},
        $i->{name},
        $i->{from}, 
        $i->{to}
      );
      $sort_order += 1;
    } elsif ($i->{type} eq "delete"){
      my $q = $db->prepare(
        "INSERT INTO anon_mapping(\n" .
        "  anonymization_id,\n" .
        "  am_sort_order,\n" .
        "  am_type,\n" .
        "  am_sig,\n" .
        "  am_name\n" .
        ") VALUES (\n" .
        "  ?, ?, ?, ?, ?\n" .
        ")" 
      );
      $q->execute(
        $this->{id},
        $sort_order,
        $i->{type},
        $i->{sig},
        $i->{name}
      );
      $sort_order += 1;
    } elsif ($i->{type} eq "date_map"){
      my $q = $db->prepare(
        "INSERT INTO anon_mapping(\n" .
        "  anonymization_id,\n" .
        "  am_sort_order,\n" .
        "  am_type,\n" .
        "  am_from,\n" .
        "  am_to\n" .
        ") VALUES (\n" .
        "  ?, ?, ?, ?, ?\n" .
        ")" 
      );
      $q->execute(
        $this->{id},
        $sort_order,
        $i->{type},
        $i->{from},
        $i->{to}
      );
      $sort_order += 1;
    } else {
      die "bad type: $i->{type}";
    }
  }
}

sub RenderMapping{
  my($this, $fh) = @_;
  for my $i (@{$this->{map}}){
    if ($i->{type} eq "map"){
      print $fh 
        "$i->{type}|$i->{sig}|$i->{name}| \"$i->{from}\" => \"$i->{to}\"\n";
    } elsif ($i->{type} eq "delete"){
      print $fh 
        "$i->{type}|$i->{sig}|$i->{name}\n";
    } elsif ($i->{type} eq "date_map"){
      print $fh 
        "$i->{type}| \"$i->{from}\" => \"$i->{to}\"\n";
    } else {
      die "bad type: $i->{type}";
    }
  }
}
sub MapADate{
  my($db, $map, $id) = @_;
  my $md = {
    "01" => 31,
    "02" => 28,
    "03" => 31,
    "04" => 30,
    "05" => 31,
    "06" => 30,
    "07" => 31,
    "08" => 31,
    "09" => 30,
    "10" => 31,
    "11" => 30,
    "12" => 31,
  };
  my $from = $map->{from};
  unless($map->{from} =~ /^(\d\d\d\d)(\d\d)(\d\d)$/) {
    print STDERR "Encountered bad date: $map->{from}\n";
    return $map;
  }
  my $y = $1; my $m = $2, my $d = $3;
  unless(exists $md->{$m}) {
    print STDERR "Encountered bad date: $map->{from}\n";
    return $map;
  }
  if($d > $md->{$m} && $m ne "02" && $d != 29) {
    print STDERR "Encountered bad date: $map->{from}\n";
    return $map;
  }
  my $m_days = $md->{$m};
  my $rand;
  while(($rand = int(rand(21)) - 10) == 0) {};
  $d += $rand;
  if($d < 1){
    $m -= 1;
    if($m < 1 ) { $m = 12; $y -= 1 }
    $d = $md->{sprintf("%02d", $m)} + $d;
  } elsif ($d > $md->{$m}){
    $d = $d - $md->{$m};
    $m += 1;
    if($m > 12) { $m = 1; $y += 1 }
  }
  $map->{to} = sprintf("%04d%02d%02d", $y, $m, $d);
  my $q = $db->prepare(
    "INSERT INTO anonymized_date(\n" .
    "  anonymization_id, old_date, new_date\n" .
    ") VALUES (\n" .
    "  ?, ?, ?\n" .
    ")"
  );
  $q->execute($id, $map->{from}, $map->{to});
  return $map;
}

1;
