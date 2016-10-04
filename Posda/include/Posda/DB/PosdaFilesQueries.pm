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
    tags => $Queries{$name}->{tags},
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
  my $struct = { queries => \%Queries };
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
sub GetTags{
  my($class, $name) = @_;
  return $Queries->{$name}->{tags};
}
sub GetAllTags{
  my($class) = @_;
  my %tags;
  for my $q (keys %$Queries){
    for my $tag (keys %{$Queries->{$q}->{tags}}){
      $tags{$tag} = 1;
    }
  }
  return \%tags;
}
sub Delete{
  my($class, $q_name) = @_;
  delete $Queries->{$q_name};
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
$Queries{DuplicateSOPInstanceUIDs}->{tags} = {
  "duplicates" => 1,
};
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
$Queries{SubjectsWithDupSops}->{tags} = {
  "duplicates" => 1,
};
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
select image_id, count from (
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
$Queries{SeriesWithDuplicatePixelDataThatMatters}->{description} = <<EOF;
Return a list of files with duplicate pixel data,
restricted to those files which have parsed DICOM data
representations in Database.
EOF
$Queries{SeriesWithDuplicatePixelDataThatMatters}->{args} = [
  "collection",
];
$Queries{SeriesWithDuplicatePixelDataThatMatters}->{columns} = [
  "series_instance_uid"
];
$Queries{SeriesWithDuplicatePixelDataThatMatters}->{schema} = "posda_files";
$Queries{SeriesWithDuplicatePixelDataThatMatters}->{query} = <<EOF;
select distinct series_instance_uid
from file_series natural join file_image
where image_id in (
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
where count > 1
)
EOF
##########################################################
$Queries{ComplexDuplicatePixelData}->{description} = <<EOF;
Find series with duplicate pixel count of <n>
EOF
$Queries{ComplexDuplicatePixelData}->{args} = [ "count" ];
$Queries{ComplexDuplicatePixelData}->{tags} = {
  "pix_data_dups" => 1,
};
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
$Queries{PixDupsByCollecton}->{description} = <<EOF;
Counts of duplicate pixel data in series by Collection
EOF
$Queries{PixDupsByCollecton}->{args} = [ "collection" ];
$Queries{PixDupsByCollecton}->{tags} = {
  "pix_data_dups" => 1,
};
$Queries{PixDupsByCollecton}->{columns} = [
  "series_instance_uid", "count"
];
$Queries{PixDupsByCollecton}->{schema} = "posda_files";
$Queries{PixDupsByCollecton}->{query} = <<EOF;
select 
  distinct series_instance_uid, count(*)
from 
  ctp_file natural join file_series 
where 
  project_name = ? and visibility is null
  and file_id in (
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
      where count > 1
    )
    and visibility is null
  ) 
group by series_instance_uid
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
$Queries{PixelInfoBySopInstance}->{description} = <<EOF;
Get pixel descriptors for a particular image id
EOF
$Queries{PixelInfoBySopInstance}->{args} = [ "sop_instance_uid" ];
$Queries{PixelInfoBySopInstance}->{schema} = "posda_files";
$Queries{PixelInfoBySopInstance}->{columns} = [
 "file_id", "file", "file_offset", "size", "bits_stored", "bits_allocated",
 "pixel_representation", "number_of_frames", "samples_per_pixel",
 "pixel_rows", "pixel_columns", "photometric_interpretation",
 "planar_configuration", "modality"
];
$Queries{PixelInfoBySopInstance}->{query} = <<EOF;
select
  f.file_id, root_path || '/' || rel_path as file, file_offset, size, 
  bits_stored, bits_allocated, pixel_representation, number_of_frames,
  samples_per_pixel, pixel_rows, pixel_columns, photometric_interpretation,
  planar_configuration, modality
from
  file_image f natural join image natural join unique_pixel_data
  join pixel_location pl using(unique_pixel_data_id), 
  file_location fl natural join file_storage_root
  natural join file_series 
where
  pl.file_id = fl.file_id
  and f.file_id = pl.file_id
  and f.file_id in (
    select distinct file_id
    from file_sop_common where sop_instance_uid = ?
  )
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
$Queries{GetSlopeIntercept}->{tags} = {
  posda_files => 1,
  slope_intercept => 1,
  by_file_id => 1,
};
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
$Queries{GetWinLev}->{tags} = {
  posda_files => 1,
  window_level => 1,
  by_file_id => 1,
};
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
Get Distinct SOPs in Series with number files
Only visible filess
EOF
$Queries{DistinctSopsInSeries}->{args} = [ "series_instance_uid" ];
$Queries{DistinctSopsInSeries}->{tags} = {
  posda_files => 1,
  sops => 1,
  duplicates => 1,
  by_series_instance_uid => 1,
};
$Queries{DistinctSopsInSeries}->{schema} = "posda_files";
$Queries{DistinctSopsInSeries}->{columns} = [
 "sop_instance_uid", "count"
];
$Queries{DistinctSopsInSeries}->{query} = <<EOF;
select distinct sop_instance_uid, count(*)
from file_sop_common
where file_id in (
  select
    distinct file_id
  from
    file_series natural join ctp_file
  where
    series_instance_uid = ? and visibility is null
)
group by sop_instance_uid
order by count desc
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
  by_collection => 1,
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
  by_collection => 1,
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
  natural join ctp_file
where
  photometric_interpretation = 'RGB'
  and visibility is null
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
     modality = ? and project_name = ? and site_name = ? and 
     series_description not like ? and visibility is null
) as foo
group by series_instance_uid, series_description
EOF
##########################################################
$Queries{SeriesLike}->{description} = <<EOF;
Select series not matching pattern
EOF
$Queries{SeriesLike}->{args} = [
  "collection",
  "site",
  "description_matching",
];
$Queries{SeriesLike}->{columns} = [
   "collection",
   "site",
   "pat_id",
   "series_instance_uid",
   "series_description",
   "count"
];
$Queries{SeriesLike}->{tags} = {
  posda_files => 1,
  find_series => 1,
  pattern => 1,
};
$Queries{SeriesLike}->{schema} = "posda_files";
$Queries{SeriesLike}->{query} = <<EOF;
select
   distinct collection, site, pat_id,
   series_instance_uid, series_description, count(*)
from (
  select
   distinct
     project_name as collection, site_name as site,
     file_id, series_instance_uid, patient_id as pat_id,
     series_description
  from
     ctp_file natural join file_series natural join file_patient
  where
     project_name = ? and site_name = ? and 
     series_description like ?
) as foo
group by collection, site, pat_id, series_instance_uid, series_description
order by collection, site, pat_id
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
$Queries{DatabaseSize}->{description} = <<EOF;
Show active queries for a database
Works for PostgreSQL 9.4.5 (Current Mac)
EOF
$Queries{DatabaseSize}->{tags} = {
  postgres_status => 1,
};
$Queries{DatabaseSize}->{args} = [
];
$Queries{DatabaseSize}->{columns} = [
  "Name", "Owner", "Size"
];
$Queries{DatabaseSize}->{schema} = "posda_files";
$Queries{DatabaseSize}->{query} = <<EOF;
SELECT d.datname AS Name,  pg_catalog.pg_get_userbyid(d.datdba) AS Owner,
    CASE WHEN pg_catalog.has_database_privilege(d.datname, 'CONNECT')
        THEN pg_catalog.pg_size_pretty(pg_catalog.pg_database_size(d.datname))
        ELSE 'No Access'
    END AS SIZE
FROM pg_catalog.pg_database d
    ORDER BY
    CASE WHEN pg_catalog.has_database_privilege(d.datname, 'CONNECT')
        THEN pg_catalog.pg_database_size(d.datname)
        ELSE NULL
    END DESC -- nulls first
    LIMIT 20;
EOF
##########################################################
$Queries{ActiveQueriesOld}->{description} = <<EOF;
Show active queries for a database
Works for PostgreSQL 8.4.20 (Current Linux)
EOF
$Queries{ActiveQueriesOld}->{args} = [
  "db_name"
];
$Queries{ActiveQueriesOld}->{tags} = {
  postgres_status => 1,
};
$Queries{ActiveQueriesOld}->{columns} = [
  "db_name", "pid",
  "user_id", "user", "waiting",
  "since_xact_start", "since_query_start",
  "since_back_end_start", "current_query"
];
$Queries{ActiveQueriesOld}->{schema} = "posda_files";
$Queries{ActiveQueriesOld}->{query} = <<EOF;
select
  datname as db_name, procpid as pid,
  usesysid as user_id, usename as user,
  waiting, now() - xact_start as since_xact_start,
  now() - query_start as since_query_start,
  now() - backend_start as since_back_end_start,
  current_query
from
  pg_stat_activity
where
  datname = ?
EOF
##########################################################
$Queries{StudiesInCollectionSite}->{description} = <<EOF;
Get Studies in A Collection, Site
EOF
$Queries{StudiesInCollectionSite}->{tags} = {
  find_studies => 1,
};
$Queries{StudiesInCollectionSite}->{args} = [
  "project_name", "site_name"
];
$Queries{StudiesInCollectionSite}->{columns} = [
  "study_instance_uid",
];
$Queries{StudiesInCollectionSite}->{schema} = "posda_files";
$Queries{StudiesInCollectionSite}->{query} = <<EOF;
select
  distinct study_instance_uid
from
  file_study natural join ctp_file
where
  project_name = ? and site_name = ? and visibility is null
EOF
##########################################################
$Queries{DistinctSeriesBySubject}->{description} = <<EOF;
Get Series in A Collection, Site, Subject
EOF
$Queries{DistinctSeriesBySubject}->{tags} = {
  find_series => 1,
  by_subject => 1,
};
$Queries{DistinctSeriesBySubject}->{args} = [
  "subject_id", "project_name", "site_name"
];
$Queries{DistinctSeriesBySubject}->{columns} = [
  "series_instance_uid", "modality", "count"
];
$Queries{DistinctSeriesBySubject}->{schema} = "posda_files";
$Queries{DistinctSeriesBySubject}->{query} = <<EOF;
select distinct series_instance_uid, modality, count(*)
from (
select distinct series_instance_uid, sop_instance_uid, modality from (
select
   distinct series_instance_uid, modality, sop_instance_uid,
   file_id
 from file_series natural join file_sop_common
   natural join file_patient natural join ctp_file
where
  patient_id = ? and project_name = ? 
  and site_name = ? and visibility is null)
as foo
group by series_instance_uid, sop_instance_uid, modality)
as foo
group by series_instance_uid, modality
EOF
##########################################################
$Queries{DistinctSeriesBySubjectIntake}->{description} = <<EOF;
Get Series in A Collection, Site, Subject
EOF
$Queries{DistinctSeriesBySubjectIntake}->{tags} = {
  find_series => 1,
  by_subject => 1,
  intake => 1,
};
$Queries{DistinctSeriesBySubjectIntake}->{args} = [
  "subject_id", "project_name", "site_name"
];
$Queries{DistinctSeriesBySubjectIntake}->{columns} = [
  "series_instance_uid", "modality", "num_images"
];
$Queries{DistinctSeriesBySubjectIntake}->{schema} = "intake";
$Queries{DistinctSeriesBySubjectIntake}->{query} = <<EOF;
select
  distinct s.series_instance_uid, modality, count(*) as num_images
from
  general_image i, general_series s,
  trial_data_provenance tdp
where
  s.general_series_pk_id = i.general_series_pk_id and
  i.patient_id = ? and i.trial_dp_pk_id = tdp.trial_dp_pk_id and
  tdp.project = ? and
  tdp.dp_site_name = ?
group by series_instance_uid, modality
EOF
##########################################################
$Queries{DuplicateDownloadsBySubject}->{description} = <<EOF;
Number of files for a subject which have been downloaded more than once
EOF
$Queries{DuplicateDownloadsBySubject}->{tags} = {
  find_series => 1,
  by_subject => 1,
  duplicates => 1,
};
$Queries{DuplicateDownloadsBySubject}->{args} = [
  "subject_id", "project_name", "site_name"
];
$Queries{DuplicateDownloadsBySubject}->{columns} = [
  "count"
];
$Queries{DuplicateDownloadsBySubject}->{schema} = "posda_files";
$Queries{DuplicateDownloadsBySubject}->{query} = <<EOF;
select count(*) from (
  select
    distinct file_id, count(*)
  from file_import
  where file_id in (
    select
      distinct file_id
    from 
      file_patient natural join ctp_file
    where
      patient_id = ? and project_name = ? 
      and site_name = ? and visibility is null
  )
  group by file_id
) as foo
where count > 1
EOF
##########################################################
$Queries{DuplicateDownloadsByCollection}->{description} = <<EOF;
Number of files for a subject which have been downloaded more than once
EOF
$Queries{DuplicateDownloadsByCollection}->{tags} = {
  find_series => 1,
  by_collection => 1,
  duplicates => 1,
};
$Queries{DuplicateDownloadsByCollection}->{args} = [
  "project_name", "site_name"
];
$Queries{DuplicateDownloadsByCollection}->{columns} = [
  "series_instance_uid", "count"
];
$Queries{DuplicateDownloadsByCollection}->{schema} = "posda_files";
$Queries{DuplicateDownloadsByCollection}->{query} = <<EOF;
select distinct patient_id, series_instance_uid, count(*)
from file_series natural join file_patient
where file_id in (
  select file_id from (
    select
      distinct file_id, count(*)
    from file_import
    where file_id in (
      select
        distinct file_id
      from 
        file_patient natural join ctp_file
      where
        project_name = ? 
        and site_name = ? and visibility is null
    )
    group by file_id
  ) as foo
  where count > 1
)
group by patient_id, series_instance_uid
order by patient_id
EOF
##########################################################
$Queries{FilesInSeriesForSend}->{description} = <<EOF;
Get everything you need to negotiate a presentation_context
for all files in a series
EOF
$Queries{FilesInSeriesForSend}->{tags} = {
  find_files => 1,
  by_series => 1,
  for_send => 1,
};
$Queries{FilesInSeriesForSend}->{args} = [
  "series_instance_uid"
];
$Queries{FilesInSeriesForSend}->{columns} = [
  "file_id", "path", "xfer_syntax", "sop_class_uid", "data_set_size",
  "data_set_start", "sop_instance_uid", "digest"
];
$Queries{FilesInSeriesForSend}->{schema} = "posda_files";
$Queries{FilesInSeriesForSend}->{query} = <<EOF;
select
  distinct file_id, root_path || '/' || rel_path as path, xfer_syntax, sop_class_uid,
  data_set_size, data_set_start, sop_instance_uid, digest
from
  file_location natural join file_storage_root
  natural join dicom_file natural join ctp_file
  natural join file_sop_common natural join file_series
  natural join file_meta natural join file
where
  series_instance_uid = ? and visibility is null
EOF
##########################################################
$Queries{DupSopsReceivedBetweenDates}->{description} = <<EOF;
Series received between dates with duplicate sops
EOF
$Queries{DupSopsReceivedBetweenDates}->{tags} = {
  receive_reports => 1,
};
$Queries{DupSopsReceivedBetweenDates}->{args} = [
  "start_time", "end_time"
];
$Queries{DupSopsReceivedBetweenDates}->{columns} = [
  "project_name", "site_name", "patient_id", 
  "study_instance_uid", "series_instance_uid", "num_sops",
  "num_files", "num_uploads", "first_loaded", "last_loaded"
];
$Queries{DupSopsReceivedBetweenDates}->{schema} = "posda_files";
$Queries{DupSopsReceivedBetweenDates}->{query} = <<EOF;
select
   distinct project_name, site_name, patient_id,
   study_instance_uid, series_instance_uid, count(*) as num_sops,
   sum(num_files) as num_files, sum(num_uploads) as num_uploads,
    min(first_loaded) as first_loaded, max(last_loaded) as last_loaded
from (
  select 
    distinct project_name, site_name, patient_id,
    study_instance_uid, series_instance_uid, sop_instance_uid,
    count(*) as num_files, sum(num_uploads) as num_uploads,
    min(first_loaded) as first_loaded, max(last_loaded) as last_loaded
  from (
    select
      distinct project_name, site_name, patient_id,
        study_instance_uid, series_instance_uid, sop_instance_uid,
        file_id, count(*) as num_uploads, max(import_time) as last_loaded,
         min(import_time) as first_loaded
    from (
      select
        distinct project_name, site_name, patient_id,
        study_instance_uid, series_instance_uid, sop_instance_uid,
        file_id, import_time
      from
        ctp_file natural join file_patient natural join
        file_study natural join file_series natural join
        file_sop_common natural join file_import natural join
        import_event
      where
        visibility is null and sop_instance_uid in (
          select distinct sop_instance_uid
          from 
            file_import natural join import_event natural join file_sop_common
          where import_time > ? and import_time < ?
        )
      ) as foo
    group by
      project_name, site_name, patient_id, study_instance_uid, 
      series_instance_uid, sop_instance_uid, file_id
  )as foo
  group by 
    project_name, site_name, patient_id, study_instance_uid, 
    series_instance_uid, sop_instance_uid
) as foo
where num_uploads > 1
group by 
  project_name, site_name, patient_id, study_instance_uid, 
  series_instance_uid
EOF
##########################################################
$Queries{NewSopsReceivedBetweenDates}->{description} = <<EOF;
Series received between dates with duplicate sops
EOF
$Queries{NewSopsReceivedBetweenDates}->{tags} = {
  receive_reports => 1,
};
$Queries{NewSopsReceivedBetweenDates}->{args} = [
  "start_time", "end_time"
];
$Queries{NewSopsReceivedBetweenDates}->{columns} = [
  "project_name", "site_name", "patient_id", 
  "study_instance_uid", "series_instance_uid", "num_sops",
  "first_loaded", "last_loaded"
];
$Queries{NewSopsReceivedBetweenDates}->{schema} = "posda_files";
$Queries{NewSopsReceivedBetweenDates}->{query} = <<EOF;
select
   distinct project_name, site_name, patient_id,
   study_instance_uid, series_instance_uid, count(*) as num_sops,
   min(first_loaded) as first_loaded, max(last_loaded) as last_loaded
from (
  select 
    distinct project_name, site_name, patient_id,
    study_instance_uid, series_instance_uid, sop_instance_uid,
    count(*) as num_files, sum(num_uploads) as num_uploads,
    min(first_loaded) as first_loaded, max(last_loaded) as last_loaded
  from (
    select
      distinct project_name, site_name, patient_id,
        study_instance_uid, series_instance_uid, sop_instance_uid,
        file_id, count(*) as num_uploads, max(import_time) as last_loaded,
         min(import_time) as first_loaded
    from (
      select
        distinct project_name, site_name, patient_id,
        study_instance_uid, series_instance_uid, sop_instance_uid,
        file_id, import_time
      from
        ctp_file natural join file_patient natural join
        file_study natural join file_series natural join
        file_sop_common natural join file_import natural join
        import_event
      where
        visibility is null and sop_instance_uid in (
          select distinct sop_instance_uid
          from 
            file_import natural join import_event natural join file_sop_common
          where import_time > ? and import_time < ?
        )
      ) as foo
    group by
      project_name, site_name, patient_id, study_instance_uid, 
      series_instance_uid, sop_instance_uid, file_id
  )as foo
  group by 
    project_name, site_name, patient_id, study_instance_uid, 
    series_instance_uid, sop_instance_uid
) as foo
where num_uploads = 1
group by 
  project_name, site_name, patient_id, study_instance_uid, 
  series_instance_uid
EOF
##########################################################
$Queries{AllSopsReceivedBetweenDates}->{description} = <<EOF;
Series received between dates regardless of duplicates
EOF
$Queries{AllSopsReceivedBetweenDates}->{tags} = {
  receive_reports => 1,
};
$Queries{AllSopsReceivedBetweenDates}->{args} = [
  "start_time", "end_time"
];
$Queries{AllSopsReceivedBetweenDates}->{columns} = [
  "project_name", "site_name", "patient_id", 
  "study_instance_uid", "series_instance_uid", "num_sops",
  "first_loaded", "last_loaded"
];
$Queries{AllSopsReceivedBetweenDates}->{schema} = "posda_files";
$Queries{AllSopsReceivedBetweenDates}->{query} = <<EOF;
select
   distinct project_name, site_name, patient_id,
   study_instance_uid, series_instance_uid, count(*) as num_sops,
   min(first_loaded) as first_loaded, max(last_loaded) as last_loaded
from (
  select 
    distinct project_name, site_name, patient_id,
    study_instance_uid, series_instance_uid, sop_instance_uid,
    count(*) as num_files, sum(num_uploads) as num_uploads,
    min(first_loaded) as first_loaded, max(last_loaded) as last_loaded
  from (
    select
      distinct project_name, site_name, patient_id,
        study_instance_uid, series_instance_uid, sop_instance_uid,
        file_id, count(*) as num_uploads, max(import_time) as last_loaded,
         min(import_time) as first_loaded
    from (
      select
        distinct project_name, site_name, patient_id,
        study_instance_uid, series_instance_uid, sop_instance_uid,
        file_id, import_time
      from
        ctp_file natural join file_patient natural join
        file_study natural join file_series natural join
        file_sop_common natural join file_import natural join
        import_event
      where
        visibility is null and sop_instance_uid in (
          select distinct sop_instance_uid
          from 
            file_import natural join import_event natural join file_sop_common
          where import_time > ? and import_time < ?
        )
      ) as foo
    group by
      project_name, site_name, patient_id, study_instance_uid, 
      series_instance_uid, sop_instance_uid, file_id
  )as foo
  group by 
    project_name, site_name, patient_id, study_instance_uid, 
    series_instance_uid, sop_instance_uid
) as foo
group by 
  project_name, site_name, patient_id, study_instance_uid, 
  series_instance_uid
EOF
##########################################################
$Queries{DupSopsReceivedBetweenDatesByCollection}->{description} = <<EOF;
Series received between dates with duplicate sops
EOF
$Queries{DupSopsReceivedBetweenDatesByCollection}->{tags} = {
  receive_reports => 1,
};
$Queries{DupSopsReceivedBetweenDatesByCollection}->{args} = [
  "start_time", "end_time", "collection"
];
$Queries{DupSopsReceivedBetweenDatesByCollection}->{columns} = [
  "project_name", "site_name", "patient_id", 
  "study_instance_uid", "series_instance_uid", "num_sops",
  "num_files", "num_uploads", "first_loaded", "last_loaded"
];
$Queries{DupSopsReceivedBetweenDatesByCollection}->{schema} = "posda_files";
$Queries{DupSopsReceivedBetweenDatesByCollection}->{query} = <<EOF;
select
   distinct project_name, site_name, patient_id,
   study_instance_uid, series_instance_uid, count(*) as num_sops,
   sum(num_files) as num_files, sum(num_uploads) as num_uploads,
    min(first_loaded) as first_loaded, max(last_loaded) as last_loaded
from (
  select 
    distinct project_name, site_name, patient_id,
    study_instance_uid, series_instance_uid, sop_instance_uid,
    count(*) as num_files, sum(num_uploads) as num_uploads,
    min(first_loaded) as first_loaded, max(last_loaded) as last_loaded
  from (
    select
      distinct project_name, site_name, patient_id,
        study_instance_uid, series_instance_uid, sop_instance_uid,
        file_id, count(*) as num_uploads, max(import_time) as last_loaded,
         min(import_time) as first_loaded
    from (
      select
        distinct project_name, site_name, patient_id,
        study_instance_uid, series_instance_uid, sop_instance_uid,
        file_id, import_time
      from
        ctp_file natural join file_patient natural join
        file_study natural join file_series natural join
        file_sop_common natural join file_import natural join
        import_event
      where
        visibility is null and sop_instance_uid in (
          select distinct sop_instance_uid
          from 
            file_import natural join import_event natural join file_sop_common
             natural join ctp_file
          where import_time > ? and import_time < ?
            and project_name = ? and visibility is null
        )
      ) as foo
    group by
      project_name, site_name, patient_id, study_instance_uid, 
      series_instance_uid, sop_instance_uid, file_id
  )as foo
  group by 
    project_name, site_name, patient_id, study_instance_uid, 
    series_instance_uid, sop_instance_uid
) as foo
where num_uploads > 1
group by 
  project_name, site_name, patient_id, study_instance_uid, 
  series_instance_uid
EOF
##########################################################
$Queries{NewSopsReceivedBetweenDatesByCollection}->{description} = <<EOF;
Series received between dates with duplicate sops
EOF
$Queries{NewSopsReceivedBetweenDatesByCollection}->{tags} = {
  receive_reports => 1,
};
$Queries{NewSopsReceivedBetweenDatesByCollection}->{args} = [
  "start_time", "end_time", "collection"
];
$Queries{NewSopsReceivedBetweenDatesByCollection}->{columns} = [
  "project_name", "site_name", "patient_id", 
  "study_instance_uid", "series_instance_uid", "num_sops",
  "first_loaded", "last_loaded"
];
$Queries{NewSopsReceivedBetweenDatesByCollection}->{schema} = "posda_files";
$Queries{NewSopsReceivedBetweenDatesByCollection}->{query} = <<EOF;
select
   distinct project_name, site_name, patient_id,
   study_instance_uid, series_instance_uid, count(*) as num_sops,
   min(first_loaded) as first_loaded, max(last_loaded) as last_loaded
from (
  select 
    distinct project_name, site_name, patient_id,
    study_instance_uid, series_instance_uid, sop_instance_uid,
    count(*) as num_files, sum(num_uploads) as num_uploads,
    min(first_loaded) as first_loaded, max(last_loaded) as last_loaded
  from (
    select
      distinct project_name, site_name, patient_id,
        study_instance_uid, series_instance_uid, sop_instance_uid,
        file_id, count(*) as num_uploads, max(import_time) as last_loaded,
         min(import_time) as first_loaded
    from (
      select
        distinct project_name, site_name, patient_id,
        study_instance_uid, series_instance_uid, sop_instance_uid,
        file_id, import_time
      from
        ctp_file natural join file_patient natural join
        file_study natural join file_series natural join
        file_sop_common natural join file_import natural join
        import_event
      where
        visibility is null and sop_instance_uid in (
          select distinct sop_instance_uid
          from 
            file_import natural join import_event natural join file_sop_common
            natural join ctp_file
          where import_time > ? and import_time < ? and
            project_name = ? and visibility is null
        )
      ) as foo
    group by
      project_name, site_name, patient_id, study_instance_uid, 
      series_instance_uid, sop_instance_uid, file_id
  )as foo
  group by 
    project_name, site_name, patient_id, study_instance_uid, 
    series_instance_uid, sop_instance_uid
) as foo
where num_uploads = 1
group by 
  project_name, site_name, patient_id, study_instance_uid, 
  series_instance_uid
EOF
##########################################################
$Queries{AllSopsReceivedBetweenDatesByCollection}->{description} = <<EOF;
Series received between dates regardless of duplicates
EOF
$Queries{AllSopsReceivedBetweenDatesByCollection}->{tags} = {
  receive_reports => 1,
};
$Queries{AllSopsReceivedBetweenDatesByCollection}->{args} = [
  "start_time", "end_time", "collection"
];
$Queries{AllSopsReceivedBetweenDatesByCollection}->{columns} = [
  "project_name", "site_name", "patient_id", 
  "study_instance_uid", "series_instance_uid", "num_sops",
  "first_loaded", "last_loaded"
];
$Queries{AllSopsReceivedBetweenDatesByCollection}->{schema} = "posda_files";
$Queries{AllSopsReceivedBetweenDatesByCollection}->{query} = <<EOF;
select
   distinct project_name, site_name, patient_id,
   study_instance_uid, series_instance_uid, count(*) as num_sops,
   min(first_loaded) as first_loaded, max(last_loaded) as last_loaded
from (
  select 
    distinct project_name, site_name, patient_id,
    study_instance_uid, series_instance_uid, sop_instance_uid,
    count(*) as num_files, sum(num_uploads) as num_uploads,
    min(first_loaded) as first_loaded, max(last_loaded) as last_loaded
  from (
    select
      distinct project_name, site_name, patient_id,
        study_instance_uid, series_instance_uid, sop_instance_uid,
        file_id, count(*) as num_uploads, max(import_time) as last_loaded,
         min(import_time) as first_loaded
    from (
      select
        distinct project_name, site_name, patient_id,
        study_instance_uid, series_instance_uid, sop_instance_uid,
        file_id, import_time
      from
        ctp_file natural join file_patient natural join
        file_study natural join file_series natural join
        file_sop_common natural join file_import natural join
        import_event
      where
        visibility is null and sop_instance_uid in (
          select distinct sop_instance_uid
          from 
            file_import natural join import_event natural join file_sop_common
            natural join ctp_file
          where import_time > ? and import_time < ? and
            project_name = ? and visibility is null
        )
      ) as foo
    group by
      project_name, site_name, patient_id, study_instance_uid, 
      series_instance_uid, sop_instance_uid, file_id
  )as foo
  group by 
    project_name, site_name, patient_id, study_instance_uid, 
    series_instance_uid, sop_instance_uid
) as foo
group by 
  project_name, site_name, patient_id, study_instance_uid, 
  series_instance_uid
EOF
##########################################################
$Queries{DatesOfUploadByCollectionSite}->{description} = <<EOF;
Show me the dates with uploads for Collection from Site
EOF
$Queries{DatesOfUploadByCollectionSite}->{tags} = {
  receive_reports => 1,
};
$Queries{DatesOfUploadByCollectionSite}->{args} = [
  "collection", "site"
];
$Queries{DatesOfUploadByCollectionSite}->{columns} = [
  "date", "num_uploads"
];
$Queries{DatesOfUploadByCollectionSite}->{schema} = "posda_files";
$Queries{DatesOfUploadByCollectionSite}->{query} = <<EOF;
select distinct date_trunc as date, count(*) as num_uploads from (
 select 
  date_trunc('day', import_time),
  file_id
from file_import natural join import_event
  natural join ctp_file
where project_name = ? and site_name = ? 
) as foo
group by date
order by date
EOF
##########################################################
$Queries{DatesOfUploadByCollectionSiteVisible}->{description} = <<EOF;
Show me the dates with uploads for Collection from Site
EOF
$Queries{DatesOfUploadByCollectionSiteVisible}->{tags} = {
  receive_reports => 1,
};
$Queries{DatesOfUploadByCollectionSiteVisible}->{args} = [
  "collection", "site"
];
$Queries{DatesOfUploadByCollectionSiteVisible}->{columns} = [
  "date", "num_uploads"
];
$Queries{DatesOfUploadByCollectionSiteVisible}->{schema} = "posda_files";
$Queries{DatesOfUploadByCollectionSiteVisible}->{query} = <<EOF;
select distinct date_trunc as date, count(*) as num_uploads from (
 select 
  date_trunc('day', import_time),
  file_id
from file_import natural join import_event natural join file_sop_common
  natural join ctp_file
where project_name = ? and site_name = ? and visibility is null
) as foo
group by date
order by date
EOF
##########################################################
$Queries{DuplicateSOPInstanceUIDsGlobalWithHidden}->{description} = <<EOF;
Return a report of duplicate SOP Instance UIDs ignoring visibility
EOF
$Queries{DuplicateSOPInstanceUIDsGlobalWithHidden}->{tags} = {
  receive_reports => 1,
};
$Queries{DuplicateSOPInstanceUIDsGlobalWithHidden}->{args} = [
];
$Queries{DuplicateSOPInstanceUIDsGlobalWithHidden}->{schema} = "posda_files";
$Queries{DuplicateSOPInstanceUIDsGlobalWithHidden}->{columns} = [
  "collection", "site", "patient_id", 
  "count"
];
$Queries{DuplicateSOPInstanceUIDsGlobalWithHidden}->{query} = <<EOF;
select distinct collection, site, patient_id, count(*)
from (
select 
  distinct collection, site, patient_id, sop_instance_uid, count(*)
  as dups
from (
select
  distinct project_name as collection,
  site_name as site, patient_id,
  study_instance_uid, series_instance_uid, sop_instance_uid, file_id
from file_sop_common natural join ctp_file natural join file_patient
  natural join file_study natural join file_series
where sop_instance_uid in (
  select distinct sop_instance_uid from (
    select distinct sop_instance_uid, count(*) from (
      select distinct file_id, sop_instance_uid 
      from
        ctp_file natural join file_sop_common
        natural join file_patient
    ) as foo
    group by sop_instance_uid order by count desc
  ) as foo where count > 1
) group by project_name, site_name, patient_id, study_instance_uid, 
  series_instance_uid, sop_instance_uid, file_id
) as foo
group by collection, site, patient_id, sop_instance_uid
) as foo where dups > 1
group by collection, site, patient_id
order by collection, site, patient_id
EOF
##########################################################
$Queries{GlobalUnhiddenSOPDuplicatesSummary}->{description} = <<EOF;
Return a report of visible duplicate SOP Instance UIDs
EOF
$Queries{GlobalUnhiddenSOPDuplicatesSummary}->{tags} = {
  receive_reports => 1,
};
$Queries{GlobalUnhiddenSOPDuplicatesSummary}->{args} = [
];
$Queries{GlobalUnhiddenSOPDuplicatesSummary}->{schema} = "posda_files";
$Queries{GlobalUnhiddenSOPDuplicatesSummary}->{columns} = [
  "collection", "site", "patient_id", "study_instance_uid",
  "series_instance_uid", "sop_instance_uid", "num_dup_sops", 
  "num_uploads", "first_upload", "last_upload"
];
$Queries{GlobalUnhiddenSOPDuplicatesSummary}->{query} = <<EOF;
select 
  distinct project_name as collection, site_name as site, patient_id,
  study_instance_uid, series_instance_uid,
  sop_instance_uid, min(import_time) as first_upload, max(import_time) as
  last_upload, count(distinct file_id) as num_dup_sops,
  count(*) as num_uploads from (
select
  distinct project_name as collection,
  site_name as site, patient_id,
  study_instance_uid, series_instance_uid, sop_instance_uid, file_id
from file_sop_common natural join ctp_file natural join file_patient
  natural join file_study natural join file_series
where visibility is null and sop_instance_uid in (
  select distinct sop_instance_uid from (
    select distinct sop_instance_uid, count(*) from (
      select distinct file_id, sop_instance_uid 
      from
        ctp_file natural join file_sop_common
        natural join file_study natural join file_series
        natural join file_patient
      where visibility is null
    ) as foo
    group by sop_instance_uid order by count desc
  ) as foo where count > 1
) group by project_name, site_name, patient_id, study_instance_uid, 
  series_instance_uid, sop_instance_uid, file_id
) as foo
natural join file_sop_common natural join file_series natural join file_study
natural join ctp_file natural join file_patient natural join file_import
natural join import_event
group by project_name, site_name, patient_id,
  study_instance_uid, series_instance_uid,
  sop_instance_uid
order by project_name, site_name, patient_id
EOF
##########################################################
$Queries{DuplicateSOPInstanceUIDsGlobalWithoutHidden}->{description} = <<EOF;
Return a report of visible duplicate SOP Instance UIDs
EOF
$Queries{DuplicateSOPInstanceUIDsGlobalWithoutHidden}->{tags} = {
  receive_reports => 1,
};
$Queries{DuplicateSOPInstanceUIDsGlobalWithoutHidden}->{args} = [
];
$Queries{DuplicateSOPInstanceUIDsGlobalWithoutHidden}->{schema} = "posda_files";
$Queries{DuplicateSOPInstanceUIDsGlobalWithoutHidden}->{columns} = [
  "collection", "site", "patient_id", "study_instance_uid",
  "series_instance_uid", "sop_instance_uid", "file_id"
];
$Queries{DuplicateSOPInstanceUIDsGlobalWithoutHidden}->{query} = <<EOF;
select
  distinct project_name as collection,
  site_name as site, patient_id,
  study_instance_uid, series_instance_uid, sop_instance_uid, file_id
from file_sop_common natural join ctp_file natural join file_patient
  natural join file_study natural join file_series
where visibility is null and sop_instance_uid in (
  select distinct sop_instance_uid from (
    select distinct sop_instance_uid, count(*) from (
      select distinct file_id, sop_instance_uid 
      from
        ctp_file natural join file_sop_common
        natural join file_study natural join file_series
        natural join file_patient
      where visibility is null
    ) as foo
    group by sop_instance_uid order by count desc
  ) as foo where count > 1
) group by project_name, site_name, patient_id, study_instance_uid, 
  series_instance_uid, sop_instance_uid, file_id
EOF
##########################################################
$Queries{DuplicateSOPInstanceUIDsByCollectionWithoutHidden1}->{description} =
 <<EOF;
Return a count of visible duplicate SOP Instance UIDs
EOF
$Queries{DuplicateSOPInstanceUIDsByCollectionWithoutHidden1}->{tags} = {
  receive_reports => 1,
};
$Queries{DuplicateSOPInstanceUIDsByCollectionWithoutHidden1}->{args} = [
];
$Queries{DuplicateSOPInstanceUIDsByCollectionWithoutHidden1}->{schema} = "posda_files";
$Queries{DuplicateSOPInstanceUIDsByCollectionWithoutHidden1}->{columns} = [
  "collection", "site", "patient_id", "study_instance_uid",
  "series_instance_uid"
];
$Queries{DuplicateSOPInstanceUIDsByCollectionWithoutHidden1}->{query} = <<EOF;
select
  distinct project_name as collection,
  site_name as site, patient_id,
  study_instance_uid, series_instance_uid
from file_sop_common natural join ctp_file natural join file_patient
  natural join file_study natural join file_series
where sop_instance_uid in (
  select distinct sop_instance_uid from (
    select distinct sop_instance_uid, count(*) from (
      select distinct file_id, sop_instance_uid 
      from
        ctp_file natural join file_sop_common
        natural join file_patient
    ) as foo natural join ctp_file
    group by sop_instance_uid order by count desc
  ) as foo where count > 1
) group by project_name, site_name, patient_id, study_instance_uid, 
  series_instance_uid
EOF
##########################################################
$Queries{CountsByCollectionSite}->{description} = <<EOF;
Counts query by Collection, Site
EOF
$Queries{CountsByCollectionSite}->{tags} = {
  counts => 1,
};
$Queries{CountsByCollectionSite}->{args} = [
  "collection", "site"
];
$Queries{CountsByCollectionSite}->{schema} = "posda_files";
$Queries{CountsByCollectionSite}->{columns} = [
  "patient_id", "image_type", "modality", "study_date",
  "study_description", "series_description", "study_instance_uid",
  "series_instance_uid", "manufacturer", "manuf_model_name",
  "software_versions", "num_sops", "num_files"
];
$Queries{CountsByCollectionSite}->{query} = <<EOF;
select
  distinct
    patient_id, image_type, modality, study_date, study_description,
    series_description, study_instance_uid, series_instance_uid,
    manufacturer, manuf_model_name, software_versions,
    count(distinct sop_instance_uid) as num_sops,
    count(distinct file_id) as num_files
from
  ctp_file join file_patient using(file_id)
  join file_series using(file_id)
  join file_sop_common using(file_id)
  join file_study using(file_id)
  join file_equipment using(file_id)
  left join file_image using(file_id)
  left join image using (image_id)
where
  project_name = ? and site_name = ? and visibility is null
group by
  patient_id, image_type, modality, study_date, study_description,
  series_description, study_instance_uid, series_instance_uid,
  manufacturer, manuf_model_name, software_versions
order by
  patient_id, study_instance_uid, series_instance_uid, image_type,
  modality, study_date, study_description,
  series_description,
  manufacturer, manuf_model_name, software_versions
EOF
##########################################################
$Queries{CountsByCollectionSiteSubject}->{description} = <<EOF;
Counts query by Collection, Site, Subject
EOF
$Queries{CountsByCollectionSiteSubject}->{tags} = {
  counts => 1,
};
$Queries{CountsByCollectionSiteSubject}->{args} = [
  "collection", "site", "patient_id"
];
$Queries{CountsByCollectionSiteSubject}->{schema} = "posda_files";
$Queries{CountsByCollectionSiteSubject}->{columns} = [
  "patient_id", "image_type", "dicom_file_type", "modality", "study_date",
  "study_description", "series_description", "study_instance_uid",
  "series_instance_uid", "manufacturer", "manuf_model_name",
  "software_versions", "num_sops", "num_files"
];
$Queries{CountsByCollectionSiteSubject}->{query} = <<EOF;
select
  distinct
    patient_id, image_type, dicom_file_type, modality,
    study_date, study_description,
    series_description, study_instance_uid, series_instance_uid,
    manufacturer, manuf_model_name, software_versions,
    count(distinct sop_instance_uid) as num_sops,
    count(distinct file_id) as num_files
from
  ctp_file join file_patient using(file_id)
  join file_series using(file_id)
  join file_sop_common using(file_id)
  join dicom_file using(file_id)
  join file_study using(file_id)
  join file_equipment using(file_id)
  left join file_image using(file_id)
  left join image using (image_id)
where
  project_name = ? and site_name = ? and patient_id = ?
  and visibility is null
group by
  patient_id, image_type, dicom_file_type, modality,
  study_date, study_description,
  series_description, study_instance_uid, series_instance_uid,
  manufacturer, manuf_model_name, software_versions
order by
  patient_id, study_instance_uid, series_instance_uid, image_type,
  dicom_file_type, modality, study_date, study_description,
  series_description,
  manufacturer, manuf_model_name, software_versions
EOF
##########################################################
$Queries{SubjectCountByCollectionSite}->{description} = <<EOF;
Counts query by Collection, Site
EOF
$Queries{SubjectCountByCollectionSite}->{tags} = {
  counts => 1,
};
$Queries{SubjectCountByCollectionSite}->{args} = [
  "collection", "site"
];
$Queries{SubjectCountByCollectionSite}->{schema} = "posda_files";
$Queries{SubjectCountByCollectionSite}->{columns} = [
  "patient_id", "count"
];
$Queries{SubjectCountByCollectionSite}->{query} = <<EOF;
select
  distinct
    patient_id, count(distinct file_id)
from
  ctp_file natural join file_patient
where
  project_name = ? and site_name = ? and visibility is null
group by
  patient_id 
order by
  patient_id
EOF
##########################################################
$Queries{DuplicateFilesBySop}->{description} = <<EOF;
Counts query by Collection, Site
EOF
$Queries{DuplicateFilesBySop}->{tags} = {
  duplicates => 1,
};
$Queries{DuplicateFilesBySop}->{args} = [
  "sop_instance_uid"
];
$Queries{DuplicateFilesBySop}->{schema} = "posda_files";
$Queries{DuplicateFilesBySop}->{columns} = [
  "collection", "site", "patient_id", "sop_instance_uid",
  "modality", "file_id", "file_path", "num_uploads",
  "first_upload", "last_upload"
];
$Queries{DuplicateFilesBySop}->{query} = <<EOF;
select
  distinct
    project_name as collection, site_name as site,
    patient_id, sop_instance_uid, modality, file_id,
    root_path || '/' || rel_path as file_path,
    count(*) as num_uploads,
    min(import_time) as first_upload, 
    max(import_time) as last_upload
from
  ctp_file natural join file_patient natural join file_sop_common
  natural join file_series natural join file_location natural join
  file_storage_root natural join file_import natural join
  import_event
where
  sop_instance_uid = ?
group by
  project_name, site_name, patient_id, sop_instance_uid, modality, 
  file_id, file_path
order by
  collection, site, patient_id, sop_instance_uid, modality
EOF
##########################################################
$Queries{FirstFilesInSeries}->{description} = <<EOF;
First files uploaded by series
EOF
$Queries{FirstFilesInSeries}->{tags} = {
  by_series => 1,
};
$Queries{FirstFilesInSeries}->{args} = [
  "series_instance_uid"
];
$Queries{FirstFilesInSeries}->{schema} = "posda_files";
$Queries{FirstFilesInSeries}->{columns} = [
  "path"
];
$Queries{FirstFilesInSeries}->{query} = <<EOF;
select root_path || '/' || rel_path as path
from file_location natural join file_storage_root
where file_id in (
select file_id from 
  (
  select 
    distinct sop_instance_uid, min(file_id) as file_id
  from 
    file_series natural join ctp_file 
    natural join file_sop_common
  where 
    series_instance_uid = ?
    and visibility is null
  group by sop_instance_uid
) as foo);
EOF
##########################################################
$Queries{FirstFileInSeriesPosda}->{description} = <<EOF;
First files in series in Posda
EOF
$Queries{FirstFileInSeriesPosda}->{tags} = {
  by_series => 1,
};
$Queries{FirstFileInSeriesPosda}->{args} = [
  "series_instance_uid"
];
$Queries{FirstFileInSeriesPosda}->{schema} = "posda_files";
$Queries{FirstFileInSeriesPosda}->{columns} = [
  "path"
];
$Queries{FirstFileInSeriesPosda}->{query} = <<EOF;
select root_path || '/' || rel_path as path
from file_location natural join file_storage_root
where file_id in (
select file_id from 
  (
  select 
    distinct sop_instance_uid, min(file_id) as file_id
  from 
    file_series natural join ctp_file 
    natural join file_sop_common
  where 
    series_instance_uid = ?
    and visibility is null
  group by sop_instance_uid
) as foo)
limit 1
EOF
##########################################################
$Queries{FirstFileInSeriesIntake}->{description} = <<EOF;
First files in series in Intake
EOF
$Queries{FirstFileInSeriesIntake}->{tags} = {
  by_series => 1,
  intake => 1,
};
$Queries{FirstFileInSeriesIntake}->{args} = [
  "series_instance_uid"
];
$Queries{FirstFileInSeriesIntake}->{schema} = "intake";
$Queries{FirstFileInSeriesIntake}->{columns} = [
  "path"
];
$Queries{FirstFileInSeriesIntake}->{query} = <<EOF;
select
  dicom_file_uri as path
from
  general_image
where
  series_instance_uid =  ?
limit 1
EOF
##########################################################
$Queries{LastFilesInSeries}->{description} = <<EOF;
Last files uploaded by series
EOF
$Queries{LastFilesInSeries}->{tags} = {
  by_series => 1,
};
$Queries{LastFilesInSeries}->{args} = [
  "series_instance_uid"
];
$Queries{LastFilesInSeries}->{schema} = "posda_files";
$Queries{LastFilesInSeries}->{columns} = [
  "path"
];
$Queries{LastFilesInSeries}->{query} = <<EOF;
select root_path || '/' || rel_path as path
from file_location natural join file_storage_root
where file_id in (
select file_id from 
  (
  select 
    distinct sop_instance_uid, max(file_id) as file_id
  from 
    file_series natural join ctp_file 
    natural join file_sop_common
  where 
    series_instance_uid = ?
    and visibility is null
  group by sop_instance_uid
) as foo);
EOF
##########################################################
$Queries{FilesAndLoadTimesInSeries}->{description} = <<EOF;
List of SOPs, files, and import times in a series
EOF
$Queries{FilesAndLoadTimesInSeries}->{tags} = {
  by_series => 1,
};
$Queries{FilesAndLoadTimesInSeries}->{args} = [
  "series_instance_uid"
];
$Queries{FilesAndLoadTimesInSeries}->{schema} = "posda_files";
$Queries{FilesAndLoadTimesInSeries}->{columns} = [
  "sop_instance_uid", "import_time", "file_id"
];
$Queries{FilesAndLoadTimesInSeries}->{query} = <<EOF;
select
  distinct sop_instance_uid, file_id, import_time
from
  file_sop_common natural join file_series
  natural join file_import natural join import_event
where
  series_instance_uid = ?
order by 
  sop_instance_uid, import_time, file_id
EOF
##########################################################
$Queries{DuplicateSopsInSeries}->{description} = <<EOF;
List of Actual duplicate SOPs (i.e. different files, same SOP)
in a series
EOF
$Queries{DuplicateSopsInSeries}->{tags} = {
  by_series => 1,
};
$Queries{DuplicateSopsInSeries}->{args} = [
  "series_instance_uid"
];
$Queries{DuplicateSopsInSeries}->{schema} = "posda_files";
$Queries{DuplicateSopsInSeries}->{columns} = [
  "sop_instance_uid", "import_time", "file_id"
];
$Queries{DuplicateSopsInSeries}->{query} = <<EOF;
select
  sop_instance_uid, import_time, file_id
from 
  file_sop_common
  natural join file_import natural join import_event
where sop_instance_uid in (
select sop_instance_uid from (
select
  distinct sop_instance_uid, count(distinct file_id) 
from
  file_sop_common natural join file_series
where
  series_instance_uid = ?
group by sop_instance_uid
) as foo
where count > 1
)
order by sop_instance_uid, import_time
EOF
##########################################################
$Queries{GetSeriesSignature}->{description} = <<EOF;
Get a list of Series Signatures by Collection
EOF
$Queries{GetSeriesSignature}->{tags} = {
  signature => 1,
};
$Queries{GetSeriesSignature}->{args} = [
  "collection"
];
$Queries{GetSeriesSignature}->{schema} = "posda_files";
$Queries{GetSeriesSignature}->{columns} = [
  "dicom_file_type", "signature", "num_series", "num_files"
];
$Queries{GetSeriesSignature}->{query} = <<EOF;
select distinct
  dicom_file_type, modality|| ':' || coalesce(manufacturer, '<undef>') || ':' 
  || coalesce(manuf_model_name, '<undef>') ||
  ':' || coalesce(software_versions, '<undef>') as signature,
  count(distinct series_instance_uid) as num_series,
  count(distinct file_id) as num_files
from
  file_series natural join file_equipment natural join ctp_file
  natural join dicom_file
where project_name = ?
group by dicom_file_type, signature
EOF
##########################################################
$Queries{GetSeriesWithSignature}->{description} = <<EOF;
Get a list of Series with Signatures by Collection
EOF
$Queries{GetSeriesWithSignature}->{tags} = {
  signature => 1,
};
$Queries{GetSeriesWithSignature}->{args} = [
  "collection"
];
$Queries{GetSeriesWithSignature}->{schema} = "posda_files";
$Queries{GetSeriesWithSignature}->{columns} = [
  "series_instance_uid", "dicom_file_type", "signature",
  "num_series", "num_files"
];
$Queries{GetSeriesWithSignature}->{query} = <<EOF;
select distinct
  series_instance_uid, dicom_file_type, 
  modality|| ':' || coalesce(manufacturer, '<undef>') || ':' 
  || coalesce(manuf_model_name, '<undef>') ||
  ':' || coalesce(software_versions, '<undef>') as signature,
  count(distinct series_instance_uid) as num_series,
  count(distinct file_id) as num_files
from
  file_series natural join file_equipment natural join ctp_file
  natural join dicom_file
where project_name = ? and visibility is null
group by series_instance_uid, dicom_file_type, signature
EOF
##########################################################
$Queries{SeriesByLikeDescriptionAndCollection}->{description} = <<EOF;
Get a list of Series by Collection matching Series Description
EOF
$Queries{SeriesByLikeDescriptionAndCollection}->{tags} = {
  find_series => 1,
};
$Queries{SeriesByLikeDescriptionAndCollection}->{args} = [
  "collection", "pattern"
];
$Queries{SeriesByLikeDescriptionAndCollection}->{schema} = "posda_files";
$Queries{SeriesByLikeDescriptionAndCollection}->{columns} = [
  "series_instance_uid", "series_description"
];
$Queries{SeriesByLikeDescriptionAndCollection}->{query} = <<EOF;
select distinct
  series_instance_uid, series_description
from
  file_series natural join ctp_file
where project_name = ? and series_description like ?
EOF
##########################################################
$Queries{SeriesCollectionSite}->{description} = <<EOF;
Get a list of Series by Collection, Site
EOF
$Queries{SeriesCollectionSite}->{tags} = {
  find_series => 1,
};
$Queries{SeriesCollectionSite}->{args} = [
  "collection", "site"
];
$Queries{SeriesCollectionSite}->{schema} = "posda_files";
$Queries{SeriesCollectionSite}->{columns} = [
  "series_instance_uid",
];
$Queries{SeriesCollectionSite}->{query} = <<EOF;
select distinct
  series_instance_uid
from
  file_series natural join ctp_file
where project_name = ? and site_name = ? and visibility is null
EOF
##########################################################
$Queries{SeriesConsistency}->{description} = <<EOF;
Check a Series for Consistency
EOF
$Queries{SeriesConsistency}->{tags} = {
  by_series => 1,
  consistency => 1,
};
$Queries{SeriesConsistency}->{args} = [
  "series_instance_uid"
];
$Queries{SeriesConsistency}->{schema} = "posda_files";
$Queries{SeriesConsistency}->{columns} = [
  "series_instance_uid", "count", "modality", "series_number", 
  "laterality", "series_date",
  "series_time", "performing_phys", "protocol_name", "series_description",
  "operators_name", "body_part_examined", "patient_position",
  "smallest_pixel_value", "largest_pixel_value", "performed_procedure_step_id",
  "performed_procedure_step_start_date", "performed_procedure_step_start_time",
  "performed_procedure_step_desc", "performed_procedure_step_comments", 
];
$Queries{SeriesConsistency}->{query} = <<EOF;
select distinct
  series_instance_uid, modality, series_number, laterality, series_date,
  series_time, performing_phys, protocol_name, series_description,
  operators_name, body_part_examined, patient_position,
  smallest_pixel_value, largest_pixel_value, performed_procedure_step_id,
  performed_procedure_step_start_date, performed_procedure_step_start_time,
  performed_procedure_step_desc, performed_procedure_step_comments,
  count(*)
from
  file_series natural join ctp_file
where series_instance_uid = ? and visibility is null
group by
  series_instance_uid, modality, series_number, laterality, series_date,
  series_time, performing_phys, protocol_name, series_description,
  operators_name, body_part_examined, patient_position,
  smallest_pixel_value, largest_pixel_value, performed_procedure_step_id,
  performed_procedure_step_start_date, performed_procedure_step_start_time,
  performed_procedure_step_desc, performed_procedure_step_comments
EOF
##########################################################
$Queries{SeriesConsistencyExtended}->{description} = <<EOF;
Check a Series for Consistency (including Image Type)
EOF
$Queries{SeriesConsistencyExtended}->{tags} = {
  by_series => 1,
  consistency => 1,
};
$Queries{SeriesConsistencyExtended}->{args} = [
  "series_instance_uid"
];
$Queries{SeriesConsistencyExtended}->{schema} = "posda_files";
$Queries{SeriesConsistencyExtended}->{columns} = [
  "series_instance_uid", "count", "modality", "series_number", 
  "laterality", "series_date", "image_type",
  "series_time", "performing_phys", "protocol_name", "series_description",
  "operators_name", "body_part_examined", "patient_position",
  "smallest_pixel_value", "largest_pixel_value", "performed_procedure_step_id",
  "performed_procedure_step_start_date", "performed_procedure_step_start_time",
  "performed_procedure_step_desc", "performed_procedure_step_comments", 
];
$Queries{SeriesConsistencyExtended}->{query} = <<EOF;
select distinct
  series_instance_uid, modality, series_number, laterality, series_date,
  series_time, performing_phys, protocol_name, series_description,
  operators_name, body_part_examined, patient_position,
  smallest_pixel_value, largest_pixel_value, performed_procedure_step_id,
  performed_procedure_step_start_date, performed_procedure_step_start_time,
  performed_procedure_step_desc, performed_procedure_step_comments, image_type,
  count(*)
from
  file_series natural join ctp_file
  left join file_image using(file_id)
  left join image using (image_id)
where series_instance_uid = ? and visibility is null
group by
  series_instance_uid, modality, series_number, laterality,
  series_date, image_type,
  series_time, performing_phys, protocol_name, series_description,
  operators_name, body_part_examined, patient_position,
  smallest_pixel_value, largest_pixel_value, performed_procedure_step_id,
  performed_procedure_step_start_date, performed_procedure_step_start_time,
  performed_procedure_step_desc, performed_procedure_step_comments
EOF
##########################################################
$Queries{FindInconsistentSeries}->{description} = <<EOF;
Find Inconsistent Series
EOF
$Queries{FindInconsistentSeries}->{tags} = {
  find_series => 1,
  consistency => 1,
};
$Queries{FindInconsistentSeries}->{args} = [
  "collection"
];
$Queries{FindInconsistentSeries}->{schema} = "posda_files";
$Queries{FindInconsistentSeries}->{columns} = [
  "series_instance_uid",
];
$Queries{FindInconsistentSeries}->{query} = <<EOF;
select series_instance_uid from (
select distinct series_instance_uid, count(*) from (
  select distinct
    series_instance_uid, modality, series_number, laterality, series_date,
    series_time, performing_phys, protocol_name, series_description,
    operators_name, body_part_examined, patient_position,
    smallest_pixel_value, largest_pixel_value, performed_procedure_step_id,
    performed_procedure_step_start_date, performed_procedure_step_start_time,
    performed_procedure_step_desc, performed_procedure_step_comments,
    count(*)
  from
    file_series natural join ctp_file
  where
    project_name = ? and visibility is null
  group by
    series_instance_uid, modality, series_number, laterality, series_date,
    series_time, performing_phys, protocol_name, series_description,
    operators_name, body_part_examined, patient_position,
    smallest_pixel_value, largest_pixel_value, performed_procedure_step_id,
    performed_procedure_step_start_date, performed_procedure_step_start_time,
    performed_procedure_step_desc, performed_procedure_step_comments
) as foo
group by series_instance_uid
) as foo
where count > 1
EOF
##########################################################
$Queries{FindInconsistentSeriesExtended}->{description} = <<EOF;
Find Inconsistent Series Extended to include image type
EOF
$Queries{FindInconsistentSeriesExtended}->{tags} = {
  find_series => 1,
  consistency => 1,
};
$Queries{FindInconsistentSeriesExtended}->{args} = [
  "collection"
];
$Queries{FindInconsistentSeriesExtended}->{schema} = "posda_files";
$Queries{FindInconsistentSeriesExtended}->{columns} = [
  "series_instance_uid",
];
$Queries{FindInconsistentSeriesExtended}->{query} = <<EOF;
select series_instance_uid from (
select distinct series_instance_uid, count(*) from (
  select distinct
    series_instance_uid, modality, series_number, laterality, series_date,
    series_time, performing_phys, protocol_name, series_description,
    operators_name, body_part_examined, patient_position,
    smallest_pixel_value, largest_pixel_value, performed_procedure_step_id,
    performed_procedure_step_start_date, performed_procedure_step_start_time,
    performed_procedure_step_desc, performed_procedure_step_comments,
    image_type, count(*)
  from
    file_series natural join ctp_file
    left join file_image using(file_id)
    left join image using(image_id)
  where
    project_name = ? and visibility is null
  group by
    series_instance_uid, image_type,
    modality, series_number, laterality, series_date,
    series_time, performing_phys, protocol_name, series_description,
    operators_name, body_part_examined, patient_position,
    smallest_pixel_value, largest_pixel_value, performed_procedure_step_id,
    performed_procedure_step_start_date, performed_procedure_step_start_time,
    performed_procedure_step_desc, performed_procedure_step_comments
) as foo
group by series_instance_uid
) as foo
where count > 1
EOF
##########################################################
$Queries{StudyConsistency}->{description} = <<EOF;
Check a Study for Consistency
EOF
$Queries{StudyConsistency}->{tags} = {
  by_study => 1,
  consistency => 1,
};
$Queries{StudyConsistency}->{args} = [
  "study_instance_uid"
];
$Queries{StudyConsistency}->{schema} = "posda_files";
$Queries{StudyConsistency}->{columns} = [
  "study_instance_uid", "count", "study_description",
  "study_date", "study_time", "referring_phy_name",
  "study_id", "accession_number", "phys_of_record",
  "phys_reading", "admitting_diag"
];
$Queries{StudyConsistency}->{query} = <<EOF;
select distinct
  study_instance_uid, study_date, study_time,
  referring_phy_name, study_id, accession_number,
  study_description, phys_of_record, phys_reading,
  admitting_diag, count(*)
from
  file_study natural join ctp_file
where study_instance_uid = ? and visibility is null
group by
  study_instance_uid, study_date, study_time,
  referring_phy_name, study_id, accession_number,
  study_description, phys_of_record, phys_reading,
  admitting_diag
EOF
##########################################################
$Queries{FindInconsistentStudy}->{description} = <<EOF;
Find Inconsistent Studies
EOF
$Queries{FindInconsistentStudy}->{tags} = {
  by_study => 1,
  consistency => 1,
};
$Queries{FindInconsistentStudy}->{args} = [
  "collection"
];
$Queries{FindInconsistentStudy}->{schema} = "posda_files";
$Queries{FindInconsistentStudy}->{columns} = [
  "study_instance_uid"
];
$Queries{FindInconsistentStudy}->{query} = <<EOF;
select distinct study_instance_uid from (
  select distinct study_instance_uid, count(*) from (
    select distinct
      study_instance_uid, study_date, study_time,
      referring_phy_name, study_id, accession_number,
      study_description, phys_of_record, phys_reading,
      admitting_diag
    from
      file_study natural join ctp_file
    where
      project_name = ? and visibility is null
    group by
      study_instance_uid, study_date, study_time,
      referring_phy_name, study_id, accession_number,
      study_description, phys_of_record, phys_reading,
      admitting_diag
  ) as foo
  group by study_instance_uid
) as foo
where count > 1
EOF
##########################################################
$Queries{PhiScanStatus}->{description} = <<EOF;
Status of PHI scans
EOF
$Queries{PhiScanStatus}->{tags} = {
  tag_usage => 1,
};
$Queries{PhiScanStatus}->{args} = [
];
$Queries{PhiScanStatus}->{schema} = "posda_phi";
$Queries{PhiScanStatus}->{columns} = [
  "id", "description", "start_time", "end_time",
  "duration", "status", "to_scan", "scanned"
];
$Queries{PhiScanStatus}->{query} = <<EOF;
select
  scan_event_id as id,
  scan_started as start_time,
  scan_ended as end_time,
  scan_ended - scan_started as duration,
  scan_status as status,
  scan_description as description,
  num_series_to_scan as to_scan,
  num_series_scanned as scanned
from 
  scan_event
order by id
EOF
##########################################################
$Queries{PhiScanStatusInProcess}->{description} = <<EOF;
Status of PHI scans
EOF
$Queries{PhiScanStatusInProcess}->{tags} = {
  tag_usage => 1,
};
$Queries{PhiScanStatusInProcess}->{args} = [
];
$Queries{PhiScanStatusInProcess}->{schema} = "posda_phi";
$Queries{PhiScanStatusInProcess}->{columns} = [
  "id", "description", "start_time", "end_time",
  "duration", "status", "to_scan", "scanned", "percentage",
  "projected_completion"
];
$Queries{PhiScanStatusInProcess}->{query} = <<EOF;
select
  scan_event_id as id,
  scan_started as start_time,
  scan_ended as end_time,
  scan_ended - scan_started as duration,
  scan_status as status,
  scan_description as description,
  num_series_to_scan as to_scan,
  num_series_scanned as scanned,
  (((now() - scan_started) / num_series_scanned) * (num_series_to_scan -
  num_series_scanned)) + now() as projected_completion,
  (cast(num_series_scanned as float) / 
    cast(num_series_to_scan as float)) * 100.0 as percentage
from
  scan_event
where
   num_series_to_scan > num_series_scanned
   and num_series_scanned > 0
order by id
EOF
##########################################################
$Queries{TagUsage}->{description} = <<EOF;
Which equipment signatures for which tags
EOF
$Queries{TagUsage}->{tags} = {
  tag_usage => 1,
};
$Queries{TagUsage}->{args} = [
  "scan_id"
];
$Queries{TagUsage}->{schema} = "posda_phi";
$Queries{TagUsage}->{columns} = [
  "element_signature", "equipment_signature"
];
$Queries{TagUsage}->{query} = <<EOF;
select
  distinct element_signature, equipment_signature
from 
  equipment_signature natural join series_scan
  natural join scan_element natural join element_signature
  natural join scan_event
where scan_event_id = ?
order by element_signature;
EOF
##########################################################
$Queries{PrivateTagUsage}->{description} = <<EOF;
Which equipment signatures for which private tags
EOF
$Queries{PrivateTagUsage}->{tags} = {
  tag_usage => 1,
};
$Queries{PrivateTagUsage}->{args} = [
  "scan_id"
];
$Queries{PrivateTagUsage}->{schema} = "posda_phi";
$Queries{PrivateTagUsage}->{columns} = [
  "element_signature", "equipment_signature"
];
$Queries{PrivateTagUsage}->{query} = <<EOF;
select
  distinct element_signature, equipment_signature
from 
  equipment_signature natural join series_scan
  natural join scan_element natural join element_signature
  natural join scan_event
where scan_event_id = ? and is_private
order by element_signature;
EOF
##########################################################
$Queries{PrivateTagsByEquipment}->{description} = <<EOF;
Which equipment signatures for which private tags
EOF
$Queries{PrivateTagsByEquipment}->{tags} = {
  tag_usage => 1,
};
$Queries{PrivateTagsByEquipment}->{args} = [
  "scan_id", "equipment_signature"
];
$Queries{PrivateTagsByEquipment}->{schema} = "posda_phi";
$Queries{PrivateTagsByEquipment}->{columns} = [
  "element_signature"
];
$Queries{PrivateTagsByEquipment}->{query} = <<EOF;
select distinct element_signature from (
select
  distinct element_signature, equipment_signature
from 
  equipment_signature natural join series_scan
  natural join scan_element natural join element_signature
  natural join scan_event
where scan_event_id = ? and is_private ) as foo
where equipment_signature = ?
order by element_signature;
EOF
##########################################################
$Queries{EquipmentByPrivateTag}->{description} = <<EOF;
Which equipment signatures for which private tags
EOF
$Queries{EquipmentByPrivateTag}->{tags} = {
  tag_usage => 1,
};
$Queries{EquipmentByPrivateTag}->{args} = [
  "scan_id", "element_signature"
];
$Queries{EquipmentByPrivateTag}->{schema} = "posda_phi";
$Queries{EquipmentByPrivateTag}->{columns} = [
  "equipment_signature"
];
$Queries{EquipmentByPrivateTag}->{query} = <<EOF;
select distinct equipment_signature from (
select
  distinct element_signature, equipment_signature
from 
  equipment_signature natural join series_scan
  natural join scan_element natural join element_signature
  natural join scan_event
where scan_event_id = ? and is_private ) as foo
where element_signature = ?
order by equipment_signature;
EOF
##########################################################
$Queries{NumEquipSigsForTagSigs}->{description} = <<EOF;
Number of Equipment signatures in which tags are featured
EOF
$Queries{NumEquipSigsForTagSigs}->{tags} = {
  tag_usage => 1,
};
$Queries{NumEquipSigsForTagSigs}->{args} = [
  "scan_id"
];
$Queries{NumEquipSigsForTagSigs}->{schema} = "posda_phi";
$Queries{NumEquipSigsForTagSigs}->{columns} = [
  "element_signature", "count"
];
$Queries{NumEquipSigsForTagSigs}->{query} = <<EOF;
select distinct element_signature, count(*) from (
select
  distinct element_signature, equipment_signature
from 
  equipment_signature natural join series_scan
  natural join scan_element natural join element_signature
  natural join scan_event
where scan_event_id = ?) as foo
group by element_signature
order by element_signature
EOF
##########################################################
$Queries{NumEquipSigsForPrivateTagSigs}->{description} = <<EOF;
Number of Equipment signatures in which tags are featured
EOF
$Queries{NumEquipSigsForPrivateTagSigs}->{tags} = {
  tag_usage => 1,
};
$Queries{NumEquipSigsForPrivateTagSigs}->{args} = [
  "scan_id"
];
$Queries{NumEquipSigsForPrivateTagSigs}->{schema} = "posda_phi";
$Queries{NumEquipSigsForPrivateTagSigs}->{columns} = [
  "element_signature", "count"
];
$Queries{NumEquipSigsForPrivateTagSigs}->{query} = <<EOF;
select distinct element_signature, count(*) from (
select
  distinct element_signature, equipment_signature
from 
  equipment_signature natural join series_scan
  natural join scan_element natural join element_signature
  natural join scan_event
where scan_event_id = ? and is_private) as foo
group by element_signature
order by element_signature
EOF
##########################################################
$Queries{VrsSeen}->{description} = <<EOF;
List of VR's seen in scan (with count)
EOF
$Queries{VrsSeen}->{tags} = {
  tag_usage => 1,
};
$Queries{VrsSeen}->{args} = [
  "scan_id"
];
$Queries{VrsSeen}->{schema} = "posda_phi";
$Queries{VrsSeen}->{columns} = [
  "vr", "count"
];
$Queries{VrsSeen}->{query} = <<EOF;
select distinct vr, count(*) from (
  select
    distinct value, element_signature, vr
  from
    scan_event natural join series_scan natural join seen_value
    natural join element_signature natural join scan_element
  where
    scan_event_id = ?
) as foo
group by vr
order by vr
EOF
##########################################################
$Queries{ValuesByVr}->{description} = <<EOF;
List of values seen in scan by VR (with count of elements)
EOF
$Queries{ValuesByVr}->{tags} = {
  tag_usage => 1,
};
$Queries{ValuesByVr}->{args} = [
  "scan_id", "vr"
];
$Queries{ValuesByVr}->{schema} = "posda_phi";
$Queries{ValuesByVr}->{columns} = [
  "value", "count"
];
$Queries{ValuesByVr}->{query} = <<EOF;
select distinct value, count(*) from (
  select
    distinct value, element_signature, vr
  from
    scan_event natural join series_scan natural join seen_value
    natural join element_signature natural join scan_element
  where
    scan_event_id = ? and vr = ?
) as foo
group by value
order by value
EOF
##########################################################
$Queries{FilesWithIndicesByScanValueTag}->{description} = <<EOF;
Find out where specific value, tag combinations occur in a scan
EOF
$Queries{FilesByScanValueTag}->{tags} = {
  tag_usage => 1,
};
$Queries{FilesByScanValueTag}->{args} = [
  "scan_id", "value", "tag"
];
$Queries{FilesByScanValueTag}->{schema} = "posda_phi";
$Queries{FilesByScanValueTag}->{columns} = [
  "series_instance_uid", "file", "element_signature",
  "sequence_level", "item_number"
];
$Queries{FilesByScanValueTag}->{query} = <<EOF;
select
  distinct series_instance_uid,
  series_scanned_file as file, 
  element_signature, sequence_level,
  item_number
from
  scan_event natural join series_scan natural join seen_value
  natural join element_signature natural join 
  scan_element natural left join sequence_index
where
  scan_event_id = ? and value = ? and element_signature = ?
order by series_instance_uid, file
EOF
##########################################################
$Queries{FilesWithIndicesByElementScanId}->{description} = <<EOF;
Find out where specific value, tag combinations occur in a scan
EOF
$Queries{FilesWithIndicesByElementScanId}->{tags} = {
  tag_usage => 1,
};
$Queries{FilesWithIndicesByElementScanId}->{args} = [
  "scan_element_id",
];
$Queries{FilesWithIndicesByElementScanId}->{schema} = "posda_phi";
$Queries{FilesWithIndicesByElementScanId}->{columns} = [
  "series_instance_uid", "file", "element_signature",
  "sequence_level", "item_number"
];
$Queries{FilesWithIndicesByElementScanId}->{query} = <<EOF;
select
  distinct series_instance_uid,
  series_scanned_file as file, 
  element_signature, sequence_level,
  item_number
from
  series_scan natural join element_signature natural join 
  scan_element natural left join sequence_index
where
  scan_element_id = ?
EOF
##########################################################
$Queries{ElementScanIdByScanValueTag}->{description} = <<EOF;
Find out where specific value, tag combinations occur in a scan
EOF
$Queries{ElementScanIdByScanValueTag}->{tags} = {
  tag_usage => 1,
};
$Queries{ElementScanIdByScanValueTag}->{args} = [
  "scan_id", "value", "tag"
];
$Queries{ElementScanIdByScanValueTag}->{schema} = "posda_phi";
$Queries{ElementScanIdByScanValueTag}->{columns} = [
  "scan_element_id",
];
$Queries{ElementScanIdByScanValueTag}->{query} = <<EOF;
select 
  distinct scan_element_id
from
  scan_element natural join element_signature
  natural join series_scan natural join seen_value
  natural join scan_event
where
  scan_event_id = ? and
  value = ? and
  element_signature = ?
EOF
##########################################################
$Queries{ValuesByVrWithTagAndCount}->{description} = <<EOF;
List of values seen in scan by VR (with count of elements)
EOF
$Queries{ValuesByVrWithTagAndCount}->{tags} = {
  tag_usage => 1,
};
$Queries{ValuesByVrWithTagAndCount}->{args} = [
  "scan_id", "vr"
];
$Queries{ValuesByVrWithTagAndCount}->{schema} = "posda_phi";
$Queries{ValuesByVrWithTagAndCount}->{columns} = [
  "value", "element_signature", "num_files"
];
$Queries{ValuesByVrWithTagAndCount}->{query} = <<EOF;
select distinct value, element_signature, num_files from (
  select
    distinct value, element_signature, vr, count(*)  as num_files
  from
    scan_event natural join series_scan natural join seen_value
    natural join element_signature natural join scan_element
  where
    scan_event_id = ? and vr = ?
  group by value, element_signature, vr
) as foo
order by value
EOF
##########################################################
$Queries{ValuesWithVrTagAndCount}->{description} = <<EOF;
List of values seen in scan by VR (with count of elements)
EOF
$Queries{ValuesWithVrTagAndCount}->{tags} = {
  tag_usage => 1,
};
$Queries{ValuesWithVrTagAndCount}->{args} = [
  "scan_id"
];
$Queries{ValuesWithVrTagAndCount}->{schema} = "posda_phi";
$Queries{ValuesWithVrTagAndCount}->{columns} = [
  "vr", "value", "element_signature", "num_files"
];
$Queries{ValuesWithVrTagAndCount}->{query} = <<EOF;
select distinct vr, value, element_signature, num_files from (
  select
    distinct vr, value, element_signature, count(*)  as num_files
  from
    scan_event natural join series_scan natural join seen_value
    natural join element_signature natural join scan_element
  where
    scan_event_id = ?
  group by value, element_signature, vr
) as foo
order by vr, value
EOF
##########################################################
$Queries{SeriesEquipmentByValueSignature}->{description} = <<EOF;
List of series, values, vr seen in scan with equipment signature
EOF
$Queries{SeriesEquipmentByValueSignature}->{tags} = {
  tag_usage => 1,
};
$Queries{SeriesEquipmentByValueSignature}->{args} = [
  "scan_id", "value", "tag_signature",
];
$Queries{SeriesEquipmentByValueSignature}->{schema} = "posda_phi";
$Queries{SeriesEquipmentByValueSignature}->{columns} = [
  "series_instance_uid", "value", "vr", "element_signature", 
  "equipment_signature"
];
$Queries{SeriesEquipmentByValueSignature}->{query} = <<EOF;
select
  distinct series_instance_uid, element_signature, value, vr,
  equipment_signature
from
  scan_event natural join series_scan
  natural join scan_element natural join element_signature
  natural join equipment_signature
  natural join seen_value
where
  scan_event_id = ? and
  value = ? and
  element_signature = ?
order by value, element_signature, vr
EOF
##########################################################
$Queries{EquipmentByValueSignature}->{description} = <<EOF;
List of equipment, values seen in scan by VR with count
EOF
$Queries{EquipmentByValueSignature}->{tags} = {
  tag_usage => 1,
};
$Queries{EquipmentByValueSignature}->{args} = [
  "scan_id", "value", "tag_signature",
];
$Queries{EquipmentByValueSignature}->{schema} = "posda_phi";
$Queries{EquipmentByValueSignature}->{columns} = [
  "value", "vr", "element_signature", 
  "equipment_signature", "count"
];
$Queries{EquipmentByValueSignature}->{query} = <<EOF;
select distinct value, vr, element_signature, equipment_signature, count(*)
from (
select
  distinct series_instance_uid, element_signature, value, vr,
  equipment_signature
from
  scan_event natural join series_scan
  natural join scan_element natural join element_signature
  natural join equipment_signature
  natural join seen_value
where
  scan_event_id = ? and
  value = ? and
  element_signature = ?
) as foo
group by value, element_signature, vr, equipment_signature
order by value, element_signature, vr, equipment_signature
EOF
##########################################################
$Queries{AllValuesByElementSig}->{description} = <<EOF;
List of values seen in scan by ElementSignature with VR and count
EOF
$Queries{AllValuesByElementSig}->{tags} = {
  tag_usage => 1,
};
$Queries{AllValuesByElementSig}->{args} = [
  "scan_id", "tag_signature",
];
$Queries{AllValuesByElementSig}->{schema} = "posda_phi";
$Queries{AllValuesByElementSig}->{columns} = [
  "value", "vr", "element_signature", 
  "equipment_signature", "count"
];
$Queries{AllValuesByElementSig}->{query} = <<EOF;
select distinct value, vr, element_signature, equipment_signature, count(*)
from (
select
  distinct series_instance_uid, element_signature, value, vr,
  equipment_signature
from
  scan_event natural join series_scan
  natural join scan_element natural join element_signature
  natural join equipment_signature
  natural join seen_value
where
  scan_event_id = ? and
  element_signature = ?
) as foo
group by value, element_signature, vr, equipment_signature
order by value, element_signature, vr, equipment_signature
EOF
##########################################################
$Queries{AllVrsByElementSig}->{description} = <<EOF;
List of values seen in scan by ElementSignature with VR and count
EOF
$Queries{AllVrsByElementSig}->{tags} = {
  tag_usage => 1,
};
$Queries{AllVrsByElementSig}->{args} = [
  "scan_id", "tag_signature",
];
$Queries{AllVrsByElementSig}->{schema} = "posda_phi";
$Queries{AllVrsByElementSig}->{columns} = [
  "vr", "element_signature", 
  "equipment_signature", "count"
];
$Queries{AllVrsByElementSig}->{query} = <<EOF;
select distinct vr, element_signature, equipment_signature, count(*)
from (
select
  distinct series_instance_uid, element_signature, vr,
  equipment_signature
from
  scan_event natural join series_scan
  natural join scan_element natural join element_signature
  natural join equipment_signature
where
  scan_event_id = ? and
  element_signature = ?
) as foo
group by element_signature, vr, equipment_signature
order by element_signature, vr, equipment_signature
EOF
##########################################################
$Queries{ElementsWithMultipleVRs}->{description} = <<EOF;
List of Elements with multiple VRs seen
EOF
$Queries{ElementsWithMultipleVRs}->{tags} = {
  tag_usage => 1,
};
$Queries{ElementsWithMultipleVRs}->{args} = [
  "scan_id", 
];
$Queries{ElementsWithMultipleVRs}->{schema} = "posda_phi";
$Queries{ElementsWithMultipleVRs}->{columns} = [
  "element_signature", "count"
];
$Queries{ElementsWithMultipleVRs}->{query} = <<EOF;
select element_signature, count from (
  select element_signature, count(*)
  from (
    select
      distinct element_signature, vr
    from
      scan_event natural join series_scan
      natural join scan_element natural join element_signature
      natural join equipment_signature
    where
      scan_event_id = ?
  ) as foo
  group by element_signature
) as foo
where count > 1
EOF
##########################################################
$Queries{PosdaImagesByCollectionSite}->{description} = <<EOF;
List of all Files Images By Collection, Site
EOF
$Queries{PosdaImagesByCollectionSite}->{tags} = {
  posda_files => 1,
};
$Queries{PosdaImagesByCollectionSite}->{args} = [
  "collection", "site"
];
$Queries{PosdaImagesByCollectionSite}->{schema} = "posda_files";
$Queries{PosdaImagesByCollectionSite}->{columns} = [
  "PID", "Modality", "SopInstance",
  "StudyDate", "StudyDescription", "SeriesDescription",
  "StudyInstanceUID", "SeriesInstanceUID", "Mfr",
  "Model", "software_versions"
];
$Queries{PosdaImagesByCollectionSite}->{query} = <<EOF;
select distinct
  patient_id as "PID",
  modality as "Modality",
  sop_instance_uid as "SopInstance",
  study_date as "StudyDate",
  study_description as "StudyDescription",
  series_description as "SeriesDescription",
  study_instance_uid as "StudyInstanceUID",
  series_instance_uid as "SeriesInstanceUID",
  manufacturer as "Mfr",
  manuf_model_name as "Model",
  software_versions
from
  file_patient natural join file_series natural join
  file_sop_common natural join file_study natural join
  file_equipment natural join ctp_file
where
  file_id in (
  select distinct file_id from ctp_file
  where project_name = ? and site_name = ? and visibility is null)
EOF
##########################################################
$Queries{IntakeImagesByCollectionSite}->{description} = <<EOF;
List of all Files Images By Collection, Site
EOF
$Queries{IntakeImagesByCollectionSite}->{tags} = {
  intake => 1,
};
$Queries{IntakeImagesByCollectionSite}->{args} = [
  "collection", "site"
];
$Queries{IntakeImagesByCollectionSite}->{schema} = "intake";
$Queries{IntakeImagesByCollectionSite}->{columns} = [
  "PID", "Modality", "SopInstance", "ImageType",
  "StudyDate", "StudyDescription", "SeriesDescription", "SeriesNumber",
  "StudyInstanceUID", "SeriesInstanceUID", "Mfr",
  "Model", "software_versions"
];
$Queries{IntakeImagesByCollectionSite}->{query} = <<EOF;
select
  p.patient_id as PID,
  s.modality as Modality,
  i.sop_instance_uid as SopInstance,
  t.study_date as StudyDate,
  t.study_desc as StudyDescription,
  s.series_desc as SeriesDescription,
  s.series_number as SeriesNumber,
  t.study_instance_uid as StudyInstanceUID,
  s.series_instance_uid as SeriesInstanceUID,
  q.manufacturer as Mfr,
  q.manufacturer_model_name as Model,
  q.software_versions
from
  general_image i,
  general_series s,
  study t,
  patient p,
  trial_data_provenance tdp,
  general_equipment q
where
  i.general_series_pk_id = s.general_series_pk_id and
  s.study_pk_id = t.study_pk_id and
  s.general_equipment_pk_id = q.general_equipment_pk_id and
  t.patient_pk_id = p.patient_pk_id and
  p.trial_dp_pk_id = tdp.trial_dp_pk_id and
  tdp.project = ? and
  tdp.dp_site_name = ?
EOF
##########################################################
$Queries{IntakeSeriesByCollectionSite}->{description} = <<EOF;
List of all Series By Collection, Site on Intake
EOF
$Queries{IntakeSeriesByCollectionSite}->{tags} = {
  intake => 1,
};
$Queries{IntakeSeriesByCollectionSite}->{args} = [
  "collection", "site"
];
$Queries{IntakeSeriesByCollectionSite}->{schema} = "intake";
$Queries{IntakeSeriesByCollectionSite}->{columns} = [
  "PID", "Modality",
  "StudyDate", "StudyDescription", "SeriesDescription", "SeriesNumber",
  "StudyInstanceUID", "SeriesInstanceUID", "Mfr",
  "Model", "software_versions"
];
$Queries{IntakeSeriesByCollectionSite}->{query} = <<EOF;
select
  p.patient_id as PID,
  s.modality as Modality,
  t.study_date as StudyDate,
  t.study_desc as StudyDescription,
  s.series_desc as SeriesDescription,
  s.series_number as SeriesNumber,
  t.study_instance_uid as StudyInstanceUID,
  s.series_instance_uid as SeriesInstanceUID,
  q.manufacturer as Mfr,
  q.manufacturer_model_name as Model,
  q.software_versions
from
  general_series s,
  study t,
  patient p,
  trial_data_provenance tdp,
  general_equipment q
where
  s.study_pk_id = t.study_pk_id and
  s.general_equipment_pk_id = q.general_equipment_pk_id and
  t.patient_pk_id = p.patient_pk_id and
  p.trial_dp_pk_id = tdp.trial_dp_pk_id and
  tdp.project = ? and
  tdp.dp_site_name = ?
EOF
##########################################################
$Queries{IntakeSeriesWithSignatureByCollectionSite}->{description} = <<EOF;
List of all Series By Collection, Site on Intake
EOF
$Queries{IntakeSeriesWithSignatureByCollectionSite}->{tags} = {
  intake => 1,
};
$Queries{IntakeSeriesWithSignatureByCollectionSite}->{args} = [
  "collection", "site"
];
$Queries{IntakeSeriesWithSignatureByCollectionSite}->{schema} = "intake";
$Queries{IntakeSeriesWithSignatureByCollectionSite}->{columns} = [
  "series_instance_uid", "Modality", "signature",
];
$Queries{IntakeSeriesWithSignatureByCollectionSite}->{query} = <<EOF;
select
  p.patient_id as PID,
  s.modality as Modality,
  t.study_date as StudyDate,
  t.study_desc as StudyDescription,
  s.series_desc as SeriesDescription,
  s.series_number as SeriesNumber,
  t.study_instance_uid as StudyInstanceUID,
  s.series_instance_uid as series_instance_uid,
  concat(q.manufacturer, ":", q.manufacturer_model_name, ":",
  q.software_versions) as signature
from
  general_series s,
  study t,
  patient p,
  trial_data_provenance tdp,
  general_equipment q
where
  s.study_pk_id = t.study_pk_id and
  s.general_equipment_pk_id = q.general_equipment_pk_id and
  t.patient_pk_id = p.patient_pk_id and
  p.trial_dp_pk_id = tdp.trial_dp_pk_id and
  tdp.project = ? and
  tdp.dp_site_name = ?
EOF
##########################################################
$Queries{IntakeFilesInSeries}->{description} = <<EOF;
List of all Series By Collection, Site on Intake
EOF
$Queries{IntakeFilesInSeries}->{tags} = {
  intake => 1,
};
$Queries{IntakeFilesInSeries}->{args} = [
  "series_instance_uid"
];
$Queries{IntakeFilesInSeries}->{schema} = "intake";
$Queries{IntakeFilesInSeries}->{columns} = [
  "file_path",
];
$Queries{IntakeFilesInSeries}->{query} = <<EOF;
select
  dicom_file_uri as file_path
from
  general_image
where
  series_instance_uid = ?
EOF
##########################################################
$Queries{SentToIntakeByDate}->{description} = <<EOF;
List of Files Sent To Intake By Date
EOF
$Queries{SentToIntakeByDate}->{tags} = {
  send_to_intake => 1,
};
$Queries{SentToIntakeByDate}->{args} = [
  "from_date", "to_date"
];
$Queries{SentToIntakeByDate}->{schema} = "posda_files";
$Queries{SentToIntakeByDate}->{columns} = [
  "send_started", "duration",
  "destination_host", "destination_port", "to_send",
  "files_sent", "invoking_user", "reason_for_send"
];
$Queries{SentToIntakeByDate}->{query} = <<EOF;
select
  send_started, send_ended - send_started as duration,
  destination_host, destination_port,
  number_of_files as to_send, files_sent,
  invoking_user, reason_for_send
from (
  select
    distinct dicom_send_event_id,
    count(distinct file_path) as files_sent
  from
    dicom_send_event natural join dicom_file_send
  where
    send_started > ? and send_started < ?
  group by dicom_send_event_id
) as foo
natural join dicom_send_event
order by send_started
EOF
##########################################################
$Queries{SentToIntakeByDateExtended}->{description} = <<EOF;
List of Files Sent To Intake By Date
EOF
$Queries{SentToIntakeByDateExtended}->{tags} = {
  send_to_intake => 1,
};
$Queries{SentToIntakeByDateExtended}->{args} = [
  "from_date", "to_date"
];
$Queries{SentToIntakeByDateExtended}->{schema} = "posda_files";
$Queries{SentToIntakeByDateExtended}->{columns} = [
  "send_started", "duration", "series_instance_uid",
  "destination_host", "destination_port", "to_send",
  "files_sent", "invoking_user", "reason_for_send"
];
$Queries{SentToIntakeByDateExtended}->{query} = <<EOF;
select
  series_instance_uid, send_started, send_ended - send_started as duration,
  destination_host, destination_port,
  number_of_files as to_send, files_sent,
  invoking_user, reason_for_send
from (
  select
    distinct dicom_send_event_id,
    count(distinct file_path) as files_sent
  from
    dicom_send_event natural join dicom_file_send
  where
    send_started > ? and send_started < ?
  group by dicom_send_event_id
) as foo
natural join dicom_send_event
order by send_started
EOF
##########################################################
$Queries{AverageSecondsPerFile}->{description} = <<EOF;
Average Time to send a file between times
EOF
$Queries{AverageSecondsPerFile}->{tags} = {
  send_to_intake => 1,
};
$Queries{AverageSecondsPerFile}->{args} = [
  "from_date", "to_date"
];
$Queries{AverageSecondsPerFile}->{schema} = "posda_files";
$Queries{AverageSecondsPerFile}->{columns} = [
  "avg",
];
$Queries{AverageSecondsPerFile}->{query} = <<EOF;
select avg(seconds_per_file) from (
  select (send_ended - send_started)/number_of_files as seconds_per_file 
  from dicom_send_event where send_ended is not null and number_of_files > 0
  and send_started > ? and send_ended < ?
) as foo
EOF
##########################################################
$Queries{SendEventsByReason}->{description} = <<EOF;
List of Send Events By Reason
EOF
$Queries{SendEventsByReason}->{tags} = {
  send_to_intake => 1,
};
$Queries{SendEventsByReason}->{args} = [
  "reason",
];
$Queries{SendEventsByReason}->{schema} = "posda_files";
$Queries{SendEventsByReason}->{columns} = [
  "send_started", "duration",
  "destination_host", "destination_port", "to_send",
  "files_sent", "invoking_user", "reason_for_send"
];
$Queries{SendEventsByReason}->{query} = <<EOF;
select
  send_started, send_ended - send_started as duration,
  destination_host, destination_port,
  number_of_files as to_send, files_sent,
  invoking_user, reason_for_send
from (
  select
    distinct dicom_send_event_id,
    count(distinct file_path) as files_sent
  from
    dicom_send_event natural join dicom_file_send
  where
    reason_for_send = ?
  group by dicom_send_event_id
) as foo
natural join dicom_send_event
order by send_started
EOF
##########################################################
$Queries{SendEventSummary}->{description} = <<EOF;
Summary of SendEvents by Reason
EOF
$Queries{SendEventSummary}->{tags} = {
  send_to_intake => 1,
};
$Queries{SendEventSummary}->{args} = [
];
$Queries{SendEventSummary}->{schema} = "posda_files";
$Queries{SendEventSummary}->{columns} = [
  "reason_for_send", "num_events",
  "files_sent", "earliest_send", "finished",
  "duration"
];
$Queries{SendEventSummary}->{query} = <<EOF;
select
  reason_for_send, num_events, files_sent, earliest_send,
  finished, finished - earliest_send as duration
from (
  select
    distinct reason_for_send, count(*) as num_events, sum(number_of_files) as files_sent,
    min(send_started) as earliest_send, max(send_ended) as finished
  from dicom_send_event
  group by reason_for_send
  order by earliest_send
) as foo
EOF
##########################################################
$Queries{GetValueForTag}->{description} = <<EOF;
Find Values for a given tag for all scanned series in a phi scan instance
EOF
$Queries{GetValueForTag}->{tags} = {
  tag_values => 1,
};
$Queries{GetValueForTag}->{args} = [
  "tag", "scan_id"
];
$Queries{GetValueForTag}->{schema} = "posda_phi";
$Queries{GetValueForTag}->{columns} = [
  "series_instance_uid", "tag", "value"
];
$Queries{GetValueForTag}->{query} = <<EOF;
select
  series_instance_uid, element_signature as tag, value
from
  scan_element natural join series_scan natural join
  seen_value natural join element_signature
where element_signature = ? and scan_event_id = ?
EOF
##########################################################
1;
