#! /usr/bin/perl -w
use strict;
use JSON;
package PosdaDB::Queries;
my %Queries;
my $Queries = \%Queries;
sub GetQueryInstance{
  my($class, $name) = @_;
  unless(exists $Queries{$name}) { return undef }
  my $this = {
    name => $name,
    query => $Queries{$name}->{query},
    description => $Queries{$name}->{description},
    args => $Queries{$name}->{args},
    columns => $Queries{$name}->{columns},
    schema => $Queries{$name}->{schema},
  };
  return bless $this, $class;
};
sub GetDescription{
  my($this) = @_;
  return $this->{description};
}
sub GetArgs{
  my($this) = @_;
  return $this->{args};
}
sub GetColumns{
  my($this) = @_;
  return $this->{columns};
}
sub GetQuery{
  my($this) = @_;
  return $this->{query};
}
sub GetSchema{
  my($this) = @_;
  return $this->{schema};
}
sub GetType{
  my($this) = @_;
  if($this->{query} =~ /^(\S*)\s/){ return $1 } else { return undef }
}
sub Prepare{
  my($this, $dbh) = @_;
  my $qh = $dbh->prepare($this->{query});
  unless($qh) { die "unable to prepare query: $this->{name}" }
  $this->{handle} = $qh;
}
sub Execute{
  my $this = shift(@_);
  unless($this->{handle}) { die "Execute unprepared $this->{name}" }
  unless($#_ == $#{$this->{args}}){
    my $req = $#{$this->{args}};
    my $sup = $#_;
    die "arg mismatch ($this->{name}): $sup vs $req";
  }
  return $this->{handle}->execute(@_);
}
sub Rows{
  my($this, $row_closure, $done_closure) = @_;
  unless(exists $this->{handle}){
    die "Rows ($this->{name} has not been prepared";
  }
  unless(ref($row_closure) eq "CODE") {
    die "Rows ($this->{name}) requires row closure";
  }
  unless($this->{query} =~ /^select/){
    die "Rows($this->{name}) - not a select";
  }
  while(my $h = $this->{handle}->fetchrow_hashref){
    &$row_closure($h);
  }
  if(ref($done_closure) eq "CODE"){
    &$done_closure();
  }
}
#########################
# Class methods
sub GetList{
  my($class) = @_;
  my @list = sort keys %Queries;
  return @list;
};
sub Freeze{
  my($class, $file_name) = @_;
  my $struct = { queries => $Queries };
  my $json = JSON->new();
  $json->pretty(1);
  my $fh;
  open($fh, ">$file_name") or die "can't open file for writing";
  print $fh $json->encode($struct);
  close $fh;
}
sub Clear{
  my($class, $file_name) = @_;
  $Queries = {};
}
sub Delete{
  my($class, $q_name) = @_;
  delete $Queries{$q_name};
}
sub Load{
  my($class, $file) = @_;
  my $text = "";
  my $data;
  my $cf;

  unless (open($cf, '<', $file)) {
    print STDERR "ReadJsonFile:: can not open config file: $file, Error $!.\n";
    return undef;
  }

  # load the file in, ignoring comment lines
  # NOTE: JSON does not actually allow comments, so they have to be
  # stripped out here!
  while (<$cf>) {
    chomp;
    unless ($_ =~ m/^\s*\/\//) {
      $text .= $_;
    }
  }
  close($cf);
  my $json = JSON->new();
  $json->relaxed(1);
  eval {
    $data = $json->decode($text);
  };

  if ($@) {
    print STDERR "ReadJsonFile:: bad json file: $file.\n";
    print STDERR "##########\n$@\n###########\n";
    return undef;
  }
 
  unless(exists $data->{queries} && ref($data->{queries}) eq "HASH"){
    print STDERR "No queries defined in $file\n";
    return undef;
  }
  for my $q (keys %{$data->{queries}}){
    if(exists $Queries->{$q}){
      print STDERR "Replacing $q from $file\n";
    } else {
      print STDERR "Adding $q from $file\n";
    }
    $Queries->{$q} = $data->{queries}->{$q};
  }
  return 1;
}
##########################################################
$Queries{DuplicateSOPInstanceUIDs}->{description} = <<EOF;
Return a count of duplicate SOP Instance UIDs
EOF
$Queries{DuplicateSOPInstanceUIDs}->{args} = [
  "collection", "site", "subject",
];
$Queries{DuplicateSOPInstanceUIDs}->{schema} = "posda_files";
$Queries{DuplicateSOPInstanceUIDs}->{columns} = [
  "sop_instance_uid", "first", "last", "count"
];
$Queries{DuplicateSOPInstanceUIDs}->{query} = <<EOF;
select
  sop_instance_uid, min(file_id) as first,
  max(file_id) as last, count(*)
from file_sop_common
where sop_instance_uid in (
  select distinct sop_instance_uid from (
    select distinct sop_instance_uid, count(*) from (
      select distinct file_id, sop_instance_uid 
      from
        ctp_file natural join file_sop_common
        natural join file_patient
      where project_name = ? and site_name = ? and patient_id = ?
    ) as foo natural join ctp_file
    where visibility is null
    group by sop_instance_uid order by count desc
  ) as foo where count > 1
) group by sop_instance_uid;
EOF
##########################################################
$Queries{SubjectsWithDupSops}->{description} = <<EOF;
Return a count of duplicate SOP Instance UIDs
EOF
$Queries{SubjectsWithDupSops}->{args} = [];
$Queries{SubjectsWithDupSops}->{schema} = "posda_files";
$Queries{SubjectsWithDupSops}->{columns} = [
  "collection", "site", "subj_id", "count"
];
$Queries{SubjectsWithDupSops}->{query} = <<EOF;
select
  distinct collection, site, subj_id, count(*)
from (
  select
    distinct project_name as collection,
    site_name as site, patient_id as subj_id,
    file_id
  from
    ctp_file natural join file_sop_common
    natural join file_patient
  where
    sop_instance_uid in (
      select distinct sop_instance_uid from (
        select distinct sop_instance_uid, count(*) from (
          select distinct file_id, sop_instance_uid 
          from
            ctp_file natural join file_sop_common
            natural join file_patient
          where
            visibility is null
        ) as foo group by sop_instance_uid order by count desc
      ) as foo 
      where count > 1
    )
    and visibility is null
  ) as foo
group by collection, site, subj_id
EOF
##########################################################
$Queries{SubjectsWithDupSopsByCollection}->{description} = <<EOF;
Return a count of duplicate SOP Instance UIDs
EOF
$Queries{SubjectsWithDupSopsByCollection}->{args} = [
  "collection"
];
$Queries{SubjectsWithDupSopsByCollection}->{schema} = "posda_files";
$Queries{SubjectsWithDupSopsByCollection}->{columns} = [
  "collection", "site", "subj_id", "count"
];
$Queries{SubjectsWithDupSopsByCollection}->{query} = <<EOF;
select
  distinct collection, site, subj_id, count(*)
from (
  select
    distinct project_name as collection,
    site_name as site, patient_id as subj_id,
    file_id
  from
    ctp_file natural join file_sop_common
    natural join file_patient
  where
    sop_instance_uid in (
      select distinct sop_instance_uid from (
        select distinct sop_instance_uid, count(*) from (
          select distinct file_id, sop_instance_uid 
          from
            ctp_file natural join file_sop_common
            natural join file_patient
          where
            project_name = ? and visibility is null
        ) as foo group by sop_instance_uid order by count desc
      ) as foo 
      where count > 1
    )
    and visibility is null
  ) as foo
group by collection, site, subj_id
EOF
##########################################################
$Queries{DuplicatePixelDataByProject}->{description} = <<EOF;
Return a list of files with duplicate pixel data
EOF
$Queries{DuplicatePixelDataByProject}->{args} = [
  "collection"
];
$Queries{DuplicatePixelDataByProject}->{schema} = "posda_files";
$Queries{DuplicatePixelDataByProject}->{columns} = [
  "image_id", "file_id"
];
$Queries{DuplicatePixelDataByProject}->{query} = <<EOF;
select image_id, file_id
from file_image where image_id in (
  select image_id
  from (
    select distinct image_id, count(*)
    from (
      select distinct image_id, file_id 
      from file_image
      where file_id in (
        select
          distinct file_id 
        from ctp_file
        where project_name = ? and visibility is null
      )
    ) as foo
    group by image_id
  ) as foo
  where count > 1
)
order by image_id;
EOF
##########################################################
$Queries{DuplicatePixelDataThatMatters}->{description} = <<EOF;
Return a list of files with duplicate pixel data,
restricted to those files which have parsed DICOM data
representations in Database.
EOF
$Queries{DuplicatePixelDataThatMatters}->{args} = [
  "collection",
];
$Queries{DuplicatePixelDataThatMatters}->{columns} = [
  "image_id", "count"
];
$Queries{DuplicatePixelDataThatMatters}->{schema} = "posda_files";
$Queries{DuplicatePixelDataThatMatters}->{query} = <<EOF;
select image_id from (
  select distinct image_id, count(*)
  from (
    select distinct image_id, file_id
    from (
      select
        file_id, image_id, patient_id, study_instance_uid, 
        series_instance_uid, sop_instance_uid, modality
      from
        file_patient natural join file_series natural join 
        file_study natural join file_sop_common
        natural join file_image
      where file_id in (
        select file_id
        from (
          select image_id, file_id 
          from file_image 
          where image_id in (
            select image_id
            from (
              select distinct image_id, count(*)
              from (
                select distinct image_id, file_id
                from file_image where file_id in (
                  select distinct file_id
                  from ctp_file
                  where project_name = ? and visibility is null
                )
              ) as foo
              group by image_id
            ) as foo 
            where count > 1
          )
        ) as foo
      )
    ) as foo
  ) as foo
  group by image_id
) as foo 
where count > 1;
EOF
##########################################################
$Queries{ComplexDuplicatePixelData}->{description} = <<EOF;
Find series with duplicate pixel count of <n>
EOF
$Queries{ComplexDuplicatePixelData}->{args} = [ "count" ];
$Queries{ComplexDuplicatePixelData}->{columns} = [
  "project_name", "site_name", "patient_id", "series_instance_uid", "count"
];
$Queries{ComplexDuplicatePixelData}->{schema} = "posda_files";
$Queries{ComplexDuplicatePixelData}->{query} = <<EOF;
select 
  distinct project_name, site_name, patient_id, series_instance_uid, count(*)
from 
  ctp_file natural join file_patient natural join file_series 
where 
  file_id in (
    select 
      distinct file_id
    from
      file_image natural join image natural join unique_pixel_data
      natural join ctp_file
    where digest in (
      select
        distinct pixel_digest
      from (
        select
          distinct pixel_digest, count(*)
        from (
          select 
            distinct unique_pixel_data_id, pixel_digest, project_name,
            site_name, patient_id, count(*) 
          from (
            select
              distinct unique_pixel_data_id, file_id, project_name,
              site_name, patient_id, 
              unique_pixel_data.digest as pixel_digest 
            from
              image natural join file_image natural join 
              ctp_file natural join file_patient fq
              join unique_pixel_data using(unique_pixel_data_id)
            where visibility is null
          ) as foo 
          group by 
            unique_pixel_data_id, project_name, pixel_digest,
            site_name, patient_id
        ) as foo 
        group by pixel_digest
      ) as foo 
      where count = ?
    )
    and visibility is null
  ) 
group by project_name, site_name, patient_id, series_instance_uid
order by count desc;
EOF
##########################################################
$Queries{DupSopCountsByCSS}->{description} = <<EOF;
Counts of DuplicateSops By Collection, Site, Subject
EOF
$Queries{DupSopCountsByCSS}->{args} = [
  "collection", "site", "subject"
];
$Queries{DupSopCountsByCSS}->{columns} = [
  "sop_instance_uid", "min", "max", "count"
];
$Queries{DupSopCountsByCSS}->{schema} = "posda_files";
$Queries{DupSopCountsByCSS}->{query} = <<EOF;
select
  distinct sop_instance_uid, min, max, count
from (
  select
    distinct sop_instance_uid, min(file_id),
    max(file_id),count(*)
  from (
    select
      distinct sop_instance_uid, file_id
    from
      file_sop_common 
    where sop_instance_uid in (
      select
        distinct sop_instance_uid
      from
        file_sop_common natural join ctp_file
        natural join file_patient
      where
        project_name = ? and site_name = ? 
        and patient_id = ? and visibility is null
    )
  ) as foo natural join ctp_file
  where visibility is null
  group by sop_instance_uid
)as foo where count > 1
EOF
##########################################################
$Queries{HideEarlyFilesCSP}->{description} = <<EOF;
Hide earliest submission of a file:
  Note:    uses sequencing of file_id to determine earliest
           file, not import_time
EOF
$Queries{HideEarlyFilesCSP}->{args} = [
  "collection", "site", "subject"
];
$Queries{HideEarlyFilesCSP}->{schema} = "posda_files";
$Queries{HideEarlyFilesCSP}->{query} = <<EOF;
update ctp_file set visibility = 'hidden' where file_id in (
  select min as file_id
  from (
    select
      distinct sop_instance_uid, min, max, count
    from (
      select
        distinct sop_instance_uid, min(file_id),
        max(file_id),count(*)
      from (
        select
          distinct sop_instance_uid, file_id
        from
          file_sop_common 
        where sop_instance_uid in (
          select
            distinct sop_instance_uid
          from
            file_sop_common natural join ctp_file
            natural join file_patient
          where
            project_name = ? and site_name = ? 
            and patient_id = ? and visibility is null
        )
      ) as foo natural join ctp_file
      where visibility is null
      group by sop_instance_uid
    )as foo where count > 1
  ) as foo
);
EOF
##########################################################
$Queries{UnHideFilesCSP}->{description} = <<EOF;
UnHide all files hidden by Collection, Site, Subject
EOF
$Queries{UnHideFilesCSP}->{args} = [
  "collection", "site", "subject"
];
$Queries{UnHideFilesCSP}->{schema} = "posda_files";
$Queries{UnHideFilesCSP}->{query} = <<EOF;
update ctp_file set visibility = null where file_id in (
  select
    distinct file_id
  from
    ctp_file natural join file_patient
  where
    project_name = ? and site_name = ?
    and visibility = 'hidden' and patient_id = ?
);
EOF
##########################################################
$Queries{GetInfoForDupFilesByCollection}->{description} = <<EOF;
Get information related to duplicate files by collection
EOF
$Queries{GetInfoForDupFilesByCollection}->{args} = [ "collection" ];
$Queries{GetInfoForDupFilesByCollection}->{columns} = [
  "file_id", "image_id", "patient_id",
  "study_instance_uid", "series_instance_uid",
  "sop_instance_uid", "modality"
];
$Queries{GetInfoForDupFilesByCollection}->{schema} = "posda_files";
$Queries{GetInfoForDupFilesByCollection}->{query} = <<EOF;
select
  file_id, image_id, patient_id, study_instance_uid, series_instance_uid,
   sop_instance_uid, modality
from
  file_patient natural join file_series natural join file_study
  natural join file_sop_common natural join file_image
where file_id in (
  select file_id
  from (
    select image_id, file_id
    from file_image
    where image_id in (
      select image_id
      from (
        select distinct image_id, count(*)
        from (
          select distinct image_id, file_id
          from file_image
          where file_id in (
            select
              distinct file_id
              from ctp_file
              where project_name = ? and visibility is null
          )
        ) as foo
        group by image_id
      ) as foo 
      where count > 1
    )
  ) as foo
);
EOF
##########################################################
$Queries{TotalsByDateRange}->{description} = <<EOF;
Get posda totals by date range
EOF
$Queries{TotalsByDateRange}->{args} = [ "start_time", "end_time" ];
$Queries{TotalsByDateRange}->{columns} = [
  "project_name", "site_name", "num_subjects",
  "num_studies", "num_series", "total_files"
];
$Queries{TotalsByDateRange}->{schema} = "posda_files";
$Queries{TotalsByDateRange}->{query} = <<EOF;
select 
    distinct project_name, site_name, count(*) as num_subjects,
    sum(num_studies) as num_studies,
    sum(num_series) as num_series, sum(total_files) as total_files
from (
  select
    distinct project_name, site_name, patient_id, count(*) as num_studies,
    sum(num_series) as num_series, sum(total_files) as total_files
  from (
    select
       distinct project_name, site_name, patient_id, study_instance_uid, 
       count(*) as num_series, sum(num_files) as total_files
    from (
      select
        distinct project_name, site_name, patient_id, study_instance_uid, 
        series_instance_uid, count(*) as num_files 
      from (
        select
          distinct project_name, site_name, patient_id, study_instance_uid,
          series_instance_uid, sop_instance_uid 
        from
           ctp_file natural join file_study natural join
           file_series natural join file_sop_common natural join file_patient
           natural join file_import natural join import_event
        where
          visibility is null and import_time >= ? and
          import_time < ? 
      ) as foo
      group by
        project_name, site_name, patient_id, 
        study_instance_uid, series_instance_uid
    ) as foo
    group by project_name, site_name, patient_id, study_instance_uid
  ) as foo
  group by project_name, site_name, patient_id
) as foo
group by project_name, site_name
order by project_name, site_name
EOF
##########################################################
$Queries{PosdaTotals}->{description} = <<EOF;
Produce total counts for all collections currently in Posda
EOF
$Queries{PosdaTotals}->{args} = [];
$Queries{PosdaTotals}->{columns} = [
  "project_name", "site_name", "num_subjects",
  "num_studies", "num_series", "total_files", "total_sops"
];
$Queries{PosdaTotals}->{schema} = "posda_files";
$Queries{PosdaTotals}->{query} = <<EOF;
select 
    distinct project_name, site_name, count(*) as num_subjects,
    sum(num_studies) as num_studies,
    sum(num_series) as num_series, sum(total_files) as total_files,
    sum(total_sops) as total_sops
from (
  select
    distinct project_name, site_name, patient_id,
    count(*) as num_studies, sum(num_series) as num_series, 
    sum(total_files) as total_files,
    sum(total_sops) as total_sops
  from (
    select
       distinct project_name, site_name, patient_id, 
       study_instance_uid, count(*) as num_series,
       sum(num_sops) as total_sops,
       sum(num_files) as total_files
    from (
      select
        distinct project_name, site_name, patient_id,
        study_instance_uid, series_instance_uid,
        count(distinct file_id) as num_files,
        count(distinct sop_instance_uid) as num_sops
      from (
        select
          distinct project_name, site_name, patient_id,
          study_instance_uid, series_instance_uid, sop_instance_uid,
          file_id
        from
           ctp_file natural join file_study natural join
           file_series natural join file_sop_common
           natural join file_patient
        where
          visibility is null
      ) as foo
      group by
        project_name, site_name, patient_id, 
        study_instance_uid, series_instance_uid
    ) as foo
    group by project_name, site_name, patient_id, study_instance_uid
  ) as foo
  group by project_name, site_name, patient_id
) as foo
group by project_name, site_name
order by project_name, site_name
EOF
##########################################################
$Queries{PosdaTotalsHidden}->{description} = <<EOF;
Get totals of files hidden in Posda
EOF
$Queries{PosdaTotalsHidden}->{args} = [];
$Queries{PosdaTotalsHidden}->{columns} = [
  "project_name", "site_name", "num_subjects",
  "num_studies", "num_series", "total_files", "total_sops"
];
$Queries{PosdaTotalsHidden}->{schema} = "posda_files";
$Queries{PosdaTotalsHidden}->{query} = <<EOF;
select 
    distinct project_name, site_name, count(*) as num_subjects,
    sum(num_studies) as num_studies,
    sum(num_series) as num_series, sum(total_files) as total_files,
    sum(total_sops) as total_sops
from (
  select
    distinct project_name, site_name, patient_id,
    count(*) as num_studies, sum(num_series) as num_series, 
    sum(total_files) as total_files,
    sum(total_sops) as total_sops
  from (
    select
       distinct project_name, site_name, patient_id, 
       study_instance_uid, count(*) as num_series,
       sum(num_sops) as total_sops,
       sum(num_files) as total_files
    from (
      select
        distinct project_name, site_name, patient_id,
        study_instance_uid, series_instance_uid,
        count(distinct file_id) as num_files,
        count(distinct sop_instance_uid) as num_sops
      from (
        select
          distinct project_name, site_name, patient_id,
          study_instance_uid, series_instance_uid, sop_instance_uid,
          file_id
        from
           ctp_file natural join file_study natural join
           file_series natural join file_sop_common
           natural join file_patient
        where
          visibility = 'hidden'
      ) as foo
      group by
        project_name, site_name, patient_id, 
        study_instance_uid, series_instance_uid
    ) as foo
    group by project_name, site_name, patient_id, study_instance_uid
  ) as foo
  group by project_name, site_name, patient_id
) as foo
group by project_name, site_name
order by project_name, site_name
EOF
##########################################################
$Queries{PosdaTotalsWithDateRange}->{description} = <<EOF;
Get posda totals by date range
EOF
$Queries{PosdaTotalsWithDateRange}->{args} = [ "start_time", "end_time" ];
$Queries{PosdaTotalsWithDateRange}->{columns} = [
  "project_name", "site_name", "num_subjects",
  "num_studies", "num_series", "total_files"
];
$Queries{PosdaTotalsWithDateRange}->{schema} = "posda_files";
$Queries{PosdaTotalsWithDateRange}->{query} = <<EOF;
select 
    distinct project_name, site_name, count(*) as num_subjects,
    sum(num_studies) as num_studies,
    sum(num_series) as num_series, sum(total_files) as total_files
from (
  select
    distinct project_name, site_name, patient_id, count(*) as num_studies,
    sum(num_series) as num_series, sum(total_files) as total_files
  from (
    select
       distinct project_name, site_name, patient_id, study_instance_uid, 
       count(*) as num_series, sum(num_files) as total_files
    from (
      select
        distinct project_name, site_name, patient_id, study_instance_uid, 
        series_instance_uid, count(*) as num_files 
      from (
        select
          distinct project_name, site_name, patient_id, study_instance_uid,
          series_instance_uid, sop_instance_uid 
        from
           ctp_file natural join file_study natural join
           file_series natural join file_sop_common natural join file_patient
           natural join file_import natural join import_event
        where
          visibility is null and import_time >= ? and
          import_time < ? 
      ) as foo
      group by
        project_name, site_name, patient_id, 
        study_instance_uid, series_instance_uid
    ) as foo
    group by project_name, site_name, patient_id, study_instance_uid
  ) as foo
  group by project_name, site_name, patient_id
) as foo
group by project_name, site_name
order by project_name, site_name
EOF
##########################################################
$Queries{PosdaTotalsWithDateRangeWithHidden}->{description} = <<EOF;
Get posda totals by date range
EOF
$Queries{PosdaTotalsWithDateRangeWithHidden}->{args} = [ "start_time", "end_time" ];
$Queries{PosdaTotalsWithDateRangeWithHidden}->{columns} = [
  "project_name", "site_name", "num_subjects",
  "num_studies", "num_series", "total_files"
];
$Queries{PosdaTotalsWithDateRangeWithHidden}->{schema} = "posda_files";
$Queries{PosdaTotalsWithDateRangeWithHidden}->{query} = <<EOF;
select 
    distinct project_name, site_name, count(*) as num_subjects,
    sum(num_studies) as num_studies,
    sum(num_series) as num_series, sum(total_files) as total_files
from (
  select
    distinct project_name, site_name, patient_id, count(*) as num_studies,
    sum(num_series) as num_series, sum(total_files) as total_files
  from (
    select
       distinct project_name, site_name, patient_id, study_instance_uid, 
       count(*) as num_series, sum(num_files) as total_files
    from (
      select
        distinct project_name, site_name, patient_id, study_instance_uid, 
        series_instance_uid, count(*) as num_files 
      from (
        select
          distinct project_name, site_name, patient_id, study_instance_uid,
          series_instance_uid, sop_instance_uid 
        from
           ctp_file natural join file_study natural join
           file_series natural join file_sop_common natural join file_patient
           natural join file_import natural join import_event
        where
          import_time >= ? and
          import_time < ? 
      ) as foo
      group by
        project_name, site_name, patient_id, 
        study_instance_uid, series_instance_uid
    ) as foo
    group by project_name, site_name, patient_id, study_instance_uid
  ) as foo
  group by project_name, site_name, patient_id
) as foo
group by project_name, site_name
order by project_name, site_name
EOF
##########################################################
$Queries{PosdaTotalsWithHidden}->{description} = <<EOF;
Get total posda files including hidden
EOF
$Queries{PosdaTotalsWithHidden}->{args} = [];
$Queries{PosdaTotalsWithHidden}->{columns} = [
  "project_name", "site_name", "num_subjects",
  "num_studies", "num_series", "total_files"
];
$Queries{PosdaTotalsWithHidden}->{schema} = "posda_files";
$Queries{PosdaTotalsWithHidden}->{query} = <<EOF;
select 
    distinct project_name, site_name, count(*) as num_subjects,
    sum(num_studies) as num_studies,
    sum(num_series) as num_series, sum(total_files) as total_files
from (
  select
    distinct project_name, site_name, patient_id, count(*) as num_studies,
    sum(num_series) as num_series, sum(total_files) as total_files
  from (
    select
       distinct project_name, site_name, patient_id, study_instance_uid, 
       count(*) as num_series, sum(num_files) as total_files
    from (
      select
        distinct project_name, site_name, patient_id, study_instance_uid, 
        series_instance_uid, count(*) as num_files 
      from (
        select
          distinct project_name, site_name, patient_id, study_instance_uid,
          series_instance_uid, sop_instance_uid 
        from
           ctp_file natural join file_study natural join
           file_series natural join file_sop_common natural join file_patient
       ) as foo
       group by
         project_name, site_name, patient_id, 
         study_instance_uid, series_instance_uid
    ) as foo
    group by project_name, site_name, patient_id, study_instance_uid
  ) as foo
  group by project_name, site_name, patient_id
  order by project_name, site_name, patient_id
) as foo
group by project_name, site_name
order by project_name, site_name
EOF
##########################################################
$Queries{TotalsLike}->{description} = <<EOF;
Get Posda totals for with collection matching pattern
EOF
$Queries{TotalsLike}->{args} = [ "pattern" ];
$Queries{TotalsLike}->{columns} = [
 "project_name", "site_name", "num_subjects", "num_studies",
 "num_series", "total_files"
];
$Queries{TotalsLike}->{schema} = "posda_files";
$Queries{TotalsLike}->{query} = <<EOF;
select 
    distinct project_name, site_name, count(*) as num_subjects,
    sum(num_studies) as num_studies,
    sum(num_series) as num_series, sum(total_files) as total_files
from (
  select
    distinct project_name, site_name, patient_id, count(*) as num_studies,
    sum(num_series) as num_series, sum(total_files) as total_files
  from (
    select
       distinct project_name, site_name, patient_id, study_instance_uid, 
       count(*) as num_series, sum(num_files) as total_files
    from (
      select
        distinct project_name, site_name, patient_id, study_instance_uid, 
        series_instance_uid, count(*) as num_files 
      from (
        select
          distinct project_name, site_name, patient_id, study_instance_uid,
          series_instance_uid, sop_instance_uid 
        from
           ctp_file natural join file_study natural join
           file_series natural join file_sop_common natural join file_patient
         where
           project_name like ? and visibility is null
       ) as foo
       group by
         project_name, site_name, patient_id, 
         study_instance_uid, series_instance_uid
    ) as foo
    group by project_name, site_name, patient_id, study_instance_uid
  ) as foo
  group by project_name, site_name, patient_id
  order by project_name, site_name, patient_id
) as foo
group by project_name, site_name
order by project_name, site_name
EOF
##########################################################
$Queries{PixelInfoByImageId}->{description} = <<EOF;
Get pixel descriptors for a particular image id
EOF
$Queries{PixelInfoByImageId}->{args} = [ "image_id" ];
$Queries{PixelInfoByImageId}->{schema} = "posda_files";
$Queries{PixelInfoByImageId}->{columns} = [
 "file", "file_offset", "size", "bits_stored", "bits_allocated",
 "pixel_representation", "number_of_frames", "samples_per_pixel",
 "pixel_rows", "pixel_columns", "photometric_interpretation"
];
$Queries{PixelInfoByImageId}->{query} = <<EOF;
select
  root_path || '/' || rel_path as file, file_offset, size, 
  bits_stored, bits_allocated, pixel_representation, number_of_frames,
  samples_per_pixel, pixel_rows, pixel_columns, photometric_interpretation
from
  image natural join unique_pixel_data natural join pixel_location
  natural join file_location natural join file_storage_root
where image_id = ?
EOF
##########################################################
$Queries{PixelInfoByFileId}->{description} = <<EOF;
Get pixel descriptors for a particular image id
EOF
$Queries{PixelInfoByFileId}->{args} = [ "image_id" ];
$Queries{PixelInfoByFileId}->{schema} = "posda_files";
$Queries{PixelInfoByFileId}->{columns} = [
 "file", "file_offset", "size", "bits_stored", "bits_allocated",
 "pixel_representation", "number_of_frames", "samples_per_pixel",
 "pixel_rows", "pixel_columns", "photometric_interpretation"
];
$Queries{PixelInfoByFileId}->{query} = <<EOF;
select
  root_path || '/' || rel_path as file, file_offset, size, 
  bits_stored, bits_allocated, pixel_representation, number_of_frames,
  samples_per_pixel, pixel_rows, pixel_columns, photometric_interpretation
from
  file_image f natural join image natural join unique_pixel_data
  join pixel_location pl using(unique_pixel_data_id), 
  file_location fl natural join file_storage_root
where
  f.file_id = ? and pl.file_id = fl.file_id
  and f.file_id = pl.file_id
EOF
##########################################################
$Queries{PixelInfoBySeries}->{description} = <<EOF;
Get pixel descriptors for all files in a series
EOF
$Queries{PixelInfoBySeries}->{args} = [ "series_instance_uid" ];
$Queries{PixelInfoBySeries}->{schema} = "posda_files";
$Queries{PixelInfoBySeries}->{columns} = [
 "file_id", "file", "file_offset", "size", "bits_stored", "bits_allocated",
 "pixel_representation", "number_of_frames", "samples_per_pixel",
 "pixel_rows", "pixel_columns", "photometric_interpretation", 
 "planar_configuration", "modality"
];
$Queries{PixelInfoBySeries}->{query} = <<EOF;
select
  f.file_id as file_id, root_path || '/' || rel_path as file,
  file_offset, size, modality,
  bits_stored, bits_allocated, pixel_representation, number_of_frames,
  samples_per_pixel, pixel_rows, pixel_columns, photometric_interpretation,
  planar_configuration
from
  file_image f natural join image natural join unique_pixel_data
  natural join file_series
  join pixel_location pl using(unique_pixel_data_id), 
  file_location fl natural join file_storage_root
where
  pl.file_id = fl.file_id
  and f.file_id = pl.file_id
  and f.file_id in (
  select distinct file_id
  from file_series natural join ctp_file
  where series_instance_uid = ? and visibility is null
)
EOF
##########################################################
$Queries{AllPixelInfo}->{description} = <<EOF;
Get pixel descriptors for all files
EOF
$Queries{AllPixelInfo}->{args} = [  ];
$Queries{AllPixelInfo}->{schema} = "posda_files";
$Queries{AllPixelInfo}->{columns} = [
 "file_id", "file", "file_offset", "size", "bits_stored", "bits_allocated",
 "pixel_representation", "number_of_frames", "samples_per_pixel",
 "pixel_rows", "pixel_columns", "photometric_interpretation", "modality"
];
$Queries{AllPixelInfo}->{query} = <<EOF;
select
  f.file_id as file_id, root_path || '/' || rel_path as file,
  file_offset, size, modality,
  bits_stored, bits_allocated, pixel_representation, number_of_frames,
  samples_per_pixel, pixel_rows, pixel_columns, photometric_interpretation
from
  file_image f natural join image natural join unique_pixel_data
  natural join file_series
  join pixel_location pl using(unique_pixel_data_id), 
  file_location fl natural join file_storage_root
where
  pl.file_id = fl.file_id
  and f.file_id = pl.file_id
  and f.file_id in (
  select distinct file_id
  from ctp_file
  where visibility is null
)
EOF
##########################################################
$Queries{AllPixelInfoByBitDepth}->{description} = <<EOF;
Get pixel descriptors for all files
EOF
$Queries{AllPixelInfoByBitDepth}->{args} = [ "bits_allocated" ];
$Queries{AllPixelInfoByBitDepth}->{schema} = "posda_files";
$Queries{AllPixelInfoByBitDepth}->{columns} = [
 "file_id", "file", "file_offset", "size", "bits_stored", "bits_allocated",
 "pixel_representation", "number_of_frames", "samples_per_pixel",
 "pixel_rows", "pixel_columns", "photometric_interpretation", "modality"
];
$Queries{AllPixelInfoByBitDepth}->{query} = <<EOF;
select
  f.file_id as file_id, root_path || '/' || rel_path as file,
  file_offset, size, modality,
  bits_stored, bits_allocated, pixel_representation, number_of_frames,
  samples_per_pixel, pixel_rows, pixel_columns, photometric_interpretation
from
  file_image f natural join image natural join unique_pixel_data
  natural join file_series
  join pixel_location pl using(unique_pixel_data_id), 
  file_location fl natural join file_storage_root
where
  pl.file_id = fl.file_id
  and f.file_id = pl.file_id
  and f.file_id in (
  select distinct file_id
  from
    ctp_file natural join file_image natural join image
  where visibility is null and bits_allocated = ?
)
EOF
##########################################################
$Queries{AllPixelInfoByPhotometricInterp}->{description} = <<EOF;
Get pixel descriptors for all files
EOF
$Queries{AllPixelInfoByPhotometricInterp}->{args} = [ "bits_allocated" ];
$Queries{AllPixelInfoByPhotometricInterp}->{schema} = "posda_files";
$Queries{AllPixelInfoByPhotometricInterp}->{columns} = [
 "file_id", "file", "file_offset", "size", "bits_stored", "bits_allocated",
 "pixel_representation", "number_of_frames", "samples_per_pixel",
 "pixel_rows", "pixel_columns", "photometric_interpretation", "modality"
];
$Queries{AllPixelInfoByPhotometricInterp}->{query} = <<EOF;
select
  f.file_id as file_id, root_path || '/' || rel_path as file,
  file_offset, size, modality,
  bits_stored, bits_allocated, pixel_representation, number_of_frames,
  samples_per_pixel, pixel_rows, pixel_columns, photometric_interpretation
from
  file_image f natural join image natural join unique_pixel_data
  natural join file_series
  join pixel_location pl using(unique_pixel_data_id), 
  file_location fl natural join file_storage_root
where
  pl.file_id = fl.file_id
  and f.file_id = pl.file_id
  and f.file_id in (
  select distinct file_id
  from
    ctp_file natural join file_image natural join image
  where visibility is null and photometric_interpretation = ?
)
EOF
##########################################################
$Queries{AllPixelInfoByModality}->{description} = <<EOF;
Get pixel descriptors for all files
EOF
$Queries{AllPixelInfoByModality}->{args} = [ "bits_allocated" ];
$Queries{AllPixelInfoByModality}->{schema} = "posda_files";
$Queries{AllPixelInfoByModality}->{columns} = [
 "file_id", "file", "file_offset", "size", "bits_stored", "bits_allocated",
 "pixel_representation", "number_of_frames", "samples_per_pixel",
 "pixel_rows", "pixel_columns", "photometric_interpretation", "modality"
];
$Queries{AllPixelInfoByModality}->{query} = <<EOF;
select
  f.file_id as file_id, root_path || '/' || rel_path as file,
  file_offset, size, modality,
  bits_stored, bits_allocated, pixel_representation, number_of_frames,
  samples_per_pixel, pixel_rows, pixel_columns, photometric_interpretation
from
  file_image f natural join image natural join unique_pixel_data
  natural join file_series
  join pixel_location pl using(unique_pixel_data_id), 
  file_location fl natural join file_storage_root
where
  pl.file_id = fl.file_id
  and f.file_id = pl.file_id
  and f.file_id in (
  select distinct file_id
  from
    ctp_file natural join file_series 
  where visibility is null and modality = ?
)
EOF
##########################################################
$Queries{SeriesNickname}->{description} = <<EOF;
Get a nickname, etc for a particular series uid
EOF
$Queries{SeriesNickname}->{args} = [ "series_instance_uid" ];
$Queries{SeriesNickname}->{schema} = "posda_nicknames";
$Queries{SeriesNickname}->{columns} = [
 "project_name", "site_name", "subj_id", "series_nickname"
];
$Queries{SeriesNickname}->{query} = <<EOF;
select
  project_name, site_name, subj_id, series_nickname
from
  series_nickname
where
  series_instance_uid = ?
EOF
##########################################################
$Queries{StudyNickname}->{description} = <<EOF;
Get a nickname, etc for a particular study uid
EOF
$Queries{StudyNickname}->{args} = [ "study_instance_uid" ];
$Queries{StudyNickname}->{schema} = "posda_nicknames";
$Queries{StudyNickname}->{columns} = [
 "project_name", "site_name", "subj_id", "study_nickname"
];
$Queries{StudyNickname}->{query} = <<EOF;
select
  project_name, site_name, subj_id, study_nickname
from
  study_nickname
where
  study_instance_uid = ?
EOF
##########################################################
$Queries{SopNickname}->{description} = <<EOF;
Get a nickname, etc for a particular SOP Instance  uid
EOF
$Queries{SopNickname}->{args} = [ "sop_instance_uid" ];
$Queries{SopNickname}->{schema} = "posda_nicknames";
$Queries{SopNickname}->{columns} = [
 "project_name", "site_name", "subj_id", "sop_nickname",
 "modality", "has_modality_conflict"
];
$Queries{SopNickname}->{query} = <<EOF;
select
  project_name, site_name, subj_id, sop_nickname, modality,
  has_modality_conflict
from
  sop_nickname
where
  sop_instance_uid = ?
EOF
##########################################################
$Queries{GetSlopeIntercept}->{description} = <<EOF;
Get a Slope, Intercept for a particular file 
EOF
$Queries{GetSlopeIntercept}->{args} = [ "file_id" ];
$Queries{GetSlopeIntercept}->{schema} = "posda_files";
$Queries{GetSlopeIntercept}->{columns} = [
 "slope", "intercept", "si_units",
];
$Queries{GetSlopeIntercept}->{query} = <<EOF;
select
  slope, intercept, si_units
from
  file_slope_intercept natural join slope_intercept
where
  file_id = ?
EOF
##########################################################
$Queries{GetWinLev}->{description} = <<EOF;
Get a Window, Level(s) for a particular file 
EOF
$Queries{GetWinLev}->{args} = [ "file_id" ];
$Queries{GetWinLev}->{schema} = "posda_files";
$Queries{GetWinLev}->{columns} = [
 "window_width", "window_center", "win_lev_desc", "wl_index"
];
$Queries{GetWinLev}->{query} = <<EOF;
select
  window_width, window_center, win_lev_desc, wl_index
from
  file_win_lev natural join window_level
where
  file_id = ?
order by wl_index desc;
EOF
##########################################################
$Queries{DistinctSopsInSeries}->{description} = <<EOF;
Get Distinct SOPs in Series
EOF
$Queries{DistinctSopsInSeries}->{args} = [ "series_instance_uid" ];
$Queries{DistinctSopsInSeries}->{schema} = "posda_files";
$Queries{DistinctSopsInSeries}->{columns} = [
 "sop_instance_uid",
];
$Queries{DistinctSopsInSeries}->{query} = <<EOF;
select
  distinct sop_instance_uid
from
  file_series natural join file_sop_common
where
  series_instance_uid = ?
EOF
##########################################################
$Queries{DistinctUnhiddenFilesInSeries}->{description} = <<EOF;
Get Distinct Unhidden Files in Series
EOF
$Queries{DistinctUnhiddenFilesInSeries}->{args} = [ "series_instance_uid" ];
$Queries{DistinctUnhiddenFilesInSeries}->{tags} = {
  posda_files => 1,
  file_ids => 1,
  by_series_instance_uid => 1,
};
$Queries{DistinctUnhiddenFilesInSeries}->{schema} = "posda_files";
$Queries{DistinctUnhiddenFilesInSeries}->{columns} = [
 "file_id",
];
$Queries{DistinctUnhiddenFilesInSeries}->{query} = <<EOF;
select
  distinct file_id
from
  file_series natural join file_sop_common natural join ctp_file
where
  series_instance_uid = ? and visibility is null
EOF
##########################################################
$Queries{ImageIdByFileId}->{description} = <<EOF;
Get image_id for file_id 
EOF
$Queries{ImageIdByFileId}->{args} = [ "file_id" ];
$Queries{ImageIdByFileId}->{tags} = {
  posda_files => 1,
  image_id => 1,
  by_file_id => 1,
};
$Queries{ImageIdByFileId}->{schema} = "posda_files";
$Queries{ImageIdByFileId}->{columns} = [
 "file_id", "image_id",
];
$Queries{ImageIdByFileId}->{query} = <<EOF;
select
  distinct file_id, image_id
from
  file_image
where
  file_id = ?
EOF
##########################################################
$Queries{PixelDataIdByFileId}->{description} = <<EOF;
Get unique_pixel_data_id for file_id 
EOF
$Queries{PixelDataIdByFileId}->{args} = [ "file_id" ];
$Queries{PixelDataIdByFileId}->{tags} = {
  posda_files => 1,
  pixel_data_id => 1,
  by_file_id => 1,
};
$Queries{PixelDataIdByFileId}->{schema} = "posda_files";
$Queries{PixelDataIdByFileId}->{columns} = [
 "file_id", "image_id", "unique_pixel_data_id"
];
$Queries{PixelDataIdByFileId}->{query} = <<EOF;
select
  distinct file_id, image_id, unique_pixel_data_id
from
  file_image natural join image
where
  file_id = ?
EOF
##########################################################
$Queries{PixelDataIdByFileIdWithOtherFileId}->{description} = <<EOF;
Get unique_pixel_data_id for file_id 
EOF
$Queries{PixelDataIdByFileIdWithOtherFileId}->{args} =
  [ "file_id" ];
$Queries{PixelDataIdByFileIdWithOtherFileId}->{tags} = {
  posda_files => 1,
  pixel_data_id => 1,
  duplicates => 1,
  by_file_id => 1,
};
$Queries{PixelDataIdByFileIdWithOtherFileId}->{schema} = "posda_files";
$Queries{PixelDataIdByFileIdWithOtherFileId}->{columns} = [
 "file_id", "image_id", "unique_pixel_data_id", "other_file_id"
];
$Queries{PixelDataIdByFileIdWithOtherFileId}->{query} = <<EOF;
select
  distinct f.file_id as file_id, image_id, unique_pixel_data_id, 
  l.file_id as other_file_id
from
  file_image f natural join image natural join unique_pixel_data
  join pixel_location l using(unique_pixel_data_id)
where
  f.file_id = ?
EOF
##########################################################
$Queries{DiskSpaceByCollection}->{description} = <<EOF;
Get disk space used by collection
EOF
$Queries{DiskSpaceByCollection}->{args} =
  [ "collection" ];
$Queries{DiskSpaceByCollection}->{tags} = {
  posda_files => 1,
  storage_used => 1,
  by_collecton => 1,
};
$Queries{DiskSpaceByCollection}->{schema} = "posda_files";
$Queries{DiskSpaceByCollection}->{columns} = [
 "collection", "total_bytes",
];
$Queries{DiskSpaceByCollection}->{query} = <<EOF;
select
  distinct project_name as collection, sum(size) as total_bytes
from
  ctp_file natural join file
where
  file_id in (
  select distinct file_id
  from ctp_file
  where project_name = ?
  )
group by project_name
EOF
##########################################################
$Queries{DiskSpaceByCollectionSummary}->{description} = <<EOF;
Get disk space used for all collections
EOF
$Queries{DiskSpaceByCollectionSummary}->{args} = [ ];
$Queries{DiskSpaceByCollectionSummary}->{tags} = {
  posda_files => 1,
  storage_used => 1,
  by_collecton => 1,
  summary => 1,
};
$Queries{DiskSpaceByCollectionSummary}->{schema} = "posda_files";
$Queries{DiskSpaceByCollectionSummary}->{columns} = [
 "collection", "total_bytes"
];
$Queries{DiskSpaceByCollectionSummary}->{query} = <<EOF;
select
  distinct project_name as collection, sum(size) as total_bytes
from
  ctp_file natural join file
where
  file_id in (
  select distinct file_id
  from ctp_file
  )
group by project_name
order by total_bytes
EOF
##########################################################
$Queries{TotalDiskSpace}->{description} = <<EOF;
Get total disk space used
EOF
$Queries{TotalDiskSpace}->{args} = [ ];
$Queries{TotalDiskSpace}->{tags} = {
  posda_files => 1,
  storage_used => 1,
  all => 1,
};
$Queries{TotalDiskSpace}->{schema} = "posda_files";
$Queries{TotalDiskSpace}->{columns} = [ "total_bytes" ];
$Queries{TotalDiskSpace}->{query} = <<EOF;
select
  sum(size) as total_bytes
from
  file
where
  file_id in (
  select distinct file_id
  from ctp_file
  )
EOF
##########################################################
$Queries{PixelTypesWithSlopeCT}->{description} = <<EOF;
Get distinct pixel types
EOF
$Queries{PixelTypesWithSlopeCT}->{args} = [ ];
$Queries{PixelTypes}->{tags} = {
  posda_files => 1,
  find_pixel_types => 1,
  slope_intercept => 1,
  ct => 1,
};
$Queries{PixelTypesWithSlopeCT}->{schema} = "posda_files";
$Queries{PixelTypesWithSlopeCT}->{columns} = [
  "photometric_interpretation",
  "samples_per_pixel",
  "bits_allocated",
  "bits_stored",
  "high_bit",
  "pixel_representation",
  "planar_configuration",
  "modality",
  "slope",
  "intercept",
  "count"
 ];
$Queries{PixelTypesWithSlopeCT}->{query} = <<EOF;
select
  distinct photometric_interpretation,
  samples_per_pixel,
  bits_allocated,
  bits_stored,
  high_bit,
  pixel_representation,
  planar_configuration,
  modality,
  slope,
  intercept,
  count(*)
from
  image natural join file_image natural join file_series
  natural join file_slope_intercept natural join slope_intercept
where
  modality = 'CT'
group by
  photometric_interpretation,
  samples_per_pixel,
  bits_allocated,
  bits_stored,
  high_bit,
  pixel_representation,
  planar_configuration,
  modality,
  slope,
  intercept
order by
  photometric_interpretation,
  samples_per_pixel,
  bits_allocated,
  bits_stored,
  high_bit,
  pixel_representation,
  planar_configuration,
  modality,
  slope,
  intercept
EOF
##########################################################
$Queries{PixelTypes}->{description} = <<EOF;
Get distinct pixel types
EOF
$Queries{PixelTypes}->{args} = [ ];
$Queries{PixelTypes}->{tags} = {
  posda_files => 1,
  find_pixel_types => 1,
  all => 1,
};
$Queries{PixelTypes}->{schema} = "posda_files";
$Queries{PixelTypes}->{columns} = [
  "photometric_interpretation",
  "samples_per_pixel",
  "bits_allocated",
  "bits_stored",
  "high_bit",
  "pixel_representation",
  "planar_configuration",
  "modality",
  "count"
 ];
$Queries{PixelTypes}->{query} = <<EOF;
select
  distinct photometric_interpretation,
  samples_per_pixel,
  bits_allocated,
  bits_stored,
  high_bit,
  pixel_representation,
  planar_configuration,
  modality,
  count(*)
from
  image natural join file_image natural join file_series
group by
  photometric_interpretation,
  samples_per_pixel,
  bits_allocated,
  bits_stored,
  high_bit,
  pixel_representation,
  planar_configuration,
  modality
order by
  photometric_interpretation,
  samples_per_pixel,
  bits_allocated,
  bits_stored,
  high_bit,
  pixel_representation,
  planar_configuration,
  modality
EOF
##########################################################
$Queries{PixelTypesWithGeo}->{description} = <<EOF;
Get distinct pixel types with geometry
EOF
$Queries{PixelTypesWithGeo}->{args} = [ ];
$Queries{PixelTypesWithGeo}->{tags} = {
  posda_files => 1,
  find_pixel_types => 1,
  image_geometry => 1,
};
$Queries{PixelTypesWithGeo}->{schema} = "posda_files";
$Queries{PixelTypesWithGeo}->{columns} = [
  "photometric_interpretation",
  "samples_per_pixel",
  "bits_allocated",
  "bits_stored",
  "high_bit",
  "pixel_representation",
  "planar_configuration",
  "iop"
 ];
$Queries{PixelTypesWithGeo}->{query} = <<EOF;
select
  distinct photometric_interpretation,
  samples_per_pixel,
  bits_allocated,
  bits_stored,
  high_bit,
  pixel_representation,
  planar_configuration,
  iop
from
  image natural join image_geometry
order by photometric_interpretation
EOF
##########################################################
$Queries{SeriesWithRGB}->{description} = <<EOF;
Get distinct pixel types with geometry and rgb
EOF
$Queries{SeriesWithRGB}->{args} = [ ];
$Queries{SeriesWithRGB}->{tags} = {
  posda_files => 1,
  find_series => 1,
  rgb => 1,
};
$Queries{SeriesWithRGB}->{schema} = "posda_files";
$Queries{SeriesWithRGB}->{columns} = [
  "series_instance_uid"
 ];
$Queries{SeriesWithRGB}->{query} = <<EOF;
select
  distinct series_instance_uid
from
  image natural join file_image
  natural join file_series
where
  photometric_interpretation = 'RGB'
EOF
##########################################################
$Queries{PixelTypesWithGeoRGB}->{description} = <<EOF;
Get distinct pixel types with geometry and rgb
EOF
$Queries{PixelTypesWithGeoRGB}->{args} = [ ];
$Queries{PixelTypesWithGeoRGB}->{tags} = {
  posda_files => 1,
  find_pixel_types => 1,
  image_geometry => 1,
  rgb => 1,
};
$Queries{PixelTypesWithGeoRGB}->{schema} = "posda_files";
$Queries{PixelTypesWithGeoRGB}->{columns} = [
  "photometric_interpretation",
  "samples_per_pixel",
  "bits_allocated",
  "bits_stored",
  "high_bit",
  "pixel_representation",
  "planar_configuration",
  "iop"
 ];
$Queries{PixelTypesWithGeoRGB}->{query} = <<EOF;
select
  distinct photometric_interpretation,
  samples_per_pixel,
  bits_allocated,
  bits_stored,
  high_bit,
  pixel_representation,
  planar_configuration,
  iop
from
  image natural join image_geometry
where
  photometric_interpretation = 'RGB'
order by photometric_interpretation
EOF
##########################################################
$Queries{PixelTypesWithNoGeo}->{description} = <<EOF;
Get pixel types with no geometry
EOF
$Queries{PixelTypesWithNoGeo}->{args} = [ ];
$Queries{PixelTypesWithNoGeo}->{schema} = "posda_files";
$Queries{PixelTypesWithNoGeo}->{tags} = {
  posda_files => 1,
  find_pixel_types => 1,
  image_geometry => 1,
};
$Queries{PixelTypesWithNoGeo}->{columns} = [
  "photometric_interpretation",
  "samples_per_pixel",
  "bits_allocated",
  "bits_stored",
  "high_bit",
  "pixel_representation",
  "planar_configuration",
 ];
$Queries{PixelTypesWithNoGeo}->{query} = <<EOF;
select
  distinct photometric_interpretation,
  samples_per_pixel,
  bits_allocated,
  bits_stored,
  high_bit,
  pixel_representation,
  planar_configuration
from
  image i where image_id not in (
    select image_id from image_geometry g where g.image_id = i.image_id
  )
order by photometric_interpretation
EOF
##########################################################
$Queries{SeriesNotLikeWithModality}->{description} = <<EOF;
Select series not matching pattern by modality
EOF
$Queries{SeriesNotLikeWithModality}->{args} = [
  "modality",
  "collection",
  "site",
  "description_not_matching",
];
$Queries{SeriesNotLikeWithModality}->{columns} = [
   "series_instance_uid",
   "series_description",
   "description",
   "count"
];
$Queries{SeriesNotLikeWithModality}->{tags} = {
  posda_files => 1,
  find_series => 1,
  pattern => 1,
};
$Queries{SeriesNotLikeWithModality}->{schema} = "posda_files";
$Queries{SeriesNotLikeWithModality}->{query} = <<EOF;
select
   distinct series_instance_uid, series_description, count(*)
from (
  select
   distinct
     file_id, series_instance_uid, series_description
  from
     ctp_file natural join file_series
  where
     modality = ? and project_name = ? and site_name = ?and 
     series_description not like ?
) as foo
group by series_instance_uid, series_description
EOF
##########################################################
$Queries{HideSeriesNotLikeWithModality}->{description} = <<EOF;
Hide series not matching pattern by modality
EOF
$Queries{HideSeriesNotLikeWithModality}->{args} = [
  "modality",
  "collection",
  "site",
  "description_not_matching",
];
$Queries{HideSeriesNotLikeWithModality}->{tags} = {
  posda_files => 1,
  update => 1,
};
$Queries{HideSeriesNotLikeWithModality}->{schema} = "posda_files";
$Queries{HideSeriesNotLikeWithModality}->{query} = <<EOF;
update ctp_file set visibility = 'hidden'
where file_id in (
  select
    file_id
  from
    file_series
  where
    series_instance_uid in (
      select
         distinct series_instance_uid
      from (
        select
         distinct
           file_id, series_instance_uid, series_description
        from
           ctp_file natural join file_series
        where
           modality = ? and project_name = ? and site_name = ?and 
           series_description not like ?
      ) as foo
    )
  )
EOF
##########################################################
$Queries{UpdateCountsDb}->{description} = <<EOF;
EOF
$Queries{UpdateCountsDb}->{tags} = {
  posda_counts => 1,
  insert => 1,
};
$Queries{UpdateCountsDb}->{args} = [
  "project_name",
  "site_name",
  "num_subjects",
  "num_studies",
  "num_series",
  "num_files",
];
$Queries{UpdateCountsDb}->{schema} = "posda_counts";
$Queries{UpdateCountsDb}->{query} = <<EOF;
insert into totals_by_collection_site(
  count_report_id,
  collection_name, site_name,
  num_subjects, num_studies, num_series, num_sops
) values (
  currval('count_report_count_report_id_seq'),
  ?, ?,
  ?, ?, ?, ?
)
EOF
##########################################################
$Queries{TestThisOne}->{description} = <<EOF;
EOF
$Queries{TestThisOne}->{args} = [
  "project_name",
  "site_name",
];
$Queries{TestThisOne}->{columns} = [
  "patient_id", "patient_import_status",
  "total_files", "min_time", "max_time",
  "num_studies", "num_series"
];
$Queries{TestThisOne}->{schema} = "posda_files";
$Queries{TestThisOne}->{query} = <<EOF;
select
  patient_id, patient_import_status,
  count(distinct file_id) as total_files,
  min(import_time) min_time, max(import_time) as max_time,
  count(distinct study_instance_uid) as num_studies,
  count(distinct series_instance_uid) as num_series
from
  ctp_file natural join file natural join
  file_import natural join import_event natural join
  file_study natural join file_series natural join file_patient
  natural join patient_import_status
where
  project_name = ? and site_name = ? and visibility is null
group by patient_id, patient_import_status
EOF
##########################################################
$Queries{ActiveQueries}->{description} = <<EOF;
EOF
$Queries{ActiveQueries}->{tags} = {
  postgres_status => 1,
};
$Queries{ActiveQueries}->{args} = [
  "db_name"
];
$Queries{ActiveQueries}->{columns} = [
  "db_name", "pid",
  "user_id", "user", "waiting",
  "since_xact_start", "since_query_start",
  "since_back_end_start", "query"
];
$Queries{ActiveQueries}->{schema} = "posda_files";
$Queries{ActiveQueries}->{query} = <<EOF;
select
  datname as db_name, pid as pid,
  usesysid as user_id, usename as user,
  waiting, now() - xact_start as since_xact_start,
  now() - query_start as since_query_start,
  now() - backend_start as since_back_end_start,
  query
from
  pg_stat_activity
where
  datname = ?
EOF
1;
