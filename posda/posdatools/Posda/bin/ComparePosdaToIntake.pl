#!/usr/bin/perl
use Posda::DB::PosdaFilesQueries;
use Dispatch::Select;
use Dispatch::EventHandler;
use Debug;
my $dbg = sub {print @_};
my $DbSpec =  {
  "posda_files" => {
    "db_name" => "posda_files",
    "db_type" => "postgres"
  },
  "posda_nicknames" => {
    "db_name" => "posda_nicknames",
    "db_type" => "postgres"
  },
  "posda_counts" => {
    "db_name" => "posda_counts",
    "db_type" => "postgres"
  },
  "posda_phi" => {
    "db_name" => "posda_phi",
    "db_type" => "postgres"
  },
  "public" => {
    "db_name" => "ncia",
    "db_type" => "mysql",
    "db_host" => "144.30.1.74",
    "db_user" => "nciauser",
    "db_pass" => "nciA#112"
  },
  "intake" => {
    "db_name" => "ncia",
    "db_type" => "mysql",
    "db_host" => "144.30.1.71",
    "db_user" => "nciauser",
    "db_pass" => "nciA#112"
  },
};
{
  package Program;
  use vars qw( @ISA );
  @ISA = ( "Dispatch::EventHandler" );
  sub new{
    my($class, $collection, $site) = @_;
    my $self = {
      collection => $collection,
      site => $site,
      IntakeQuery => PosdaDB::Queries->GetQueryInstance(
        "IntakeImagesByCollectionSite"),
      PosdaQuery => PosdaDB::Queries->GetQueryInstance(
        "PosdaImagesByCollectionSite"),
    };
    unless(ref($self)){ die "self has no ref" }
    bless $self, $class;
    $self->InvokeAfterDelay("Start", 0);
    return $self;
  }
  sub Start{
    my($self) = @_;
    my $query;
    for my $i (keys %{$self->{IntakeQuery}}){
      $query->{$i} = $self->{IntakeQuery}->{$i};
    }
    for my $i (keys %{$DbSpec->{$query->{schema}}}){
      $query->{$i} = $DbSpec->{$query->{schema}}->{$i};
    }
    my @bindings;
    push(@bindings, $self->{collection});
    push(@bindings, $self->{site});
    $query->{bindings} = \@bindings;
print STDERR "Making Intake Query\n";
    $self->SerializedSubProcess($query, "SubProcessQuery.pl",
    $self->IntakeQueryEnd($query));
  }
  sub IntakeQueryEnd{
    my($self) = @_;
    my $sub = sub {
      my($status, $struct) = @_;
print STDERR "Intake query returned\n";
      if($status = "Succeeded" && $struct->{Status} eq "OK"){
        if(exists $struct->{Rows}){
my $count = @{$struct->{Rows}};
print STDERR "$count Rows Returned\n";
          $self->ProcessRows("Intake", $struct->{Rows});
          $self->PosdaQuery;
        } else{
          print STDERR "struct: ";
          Debug::GenPrint($dbg, $struct, 1, 2);
          print "\n";
          die "No rows from Intake query";
        }
      } else {
        die "Intake Query failed: $struct->{message}";
      }
    };
    return $sub;
  }
  sub PosdaQuery{
    my($self) = @_;
    my $query;
    for my $i (keys %{$self->{PosdaQuery}}){
      $query->{$i} = $self->{PosdaQuery}->{$i};
    }
    for my $i (keys %{$DbSpec->{$query->{schema}}}){
      $query->{$i} = $DbSpec->{$query->{schema}}->{$i};
    }
    my @bindings;
    push(@bindings, $self->{collection});
    push(@bindings, $self->{site});
    $query->{bindings} = \@bindings;
    $self->SerializedSubProcess($query, "SubProcessQuery.pl",
    $self->PosdaQueryEnd($query));
  }
  sub PosdaQueryEnd{
    my($self) = @_;
    my $sub = sub {
      my($status, $struct) = @_;
print STDERR "Posda query returned\n";
      if($status = "Succeeded" && $struct->{Status} eq "OK"){
        if(exists $struct->{Rows}){
my $count = @{$struct->{Rows}};
print STDERR "$count Rows Returned\n";
          $self->ProcessRows("Posda", $struct->{Rows});
          $self->AnalyzeResults;
        } else{
          die "No rows from Posda query";
        }
      } else {
        die "Posda Query failed";
      }
    };
    return $sub;
  }
  sub ProcessRows{
    my($self, $name, $rows) = @_;
    for my $r (@$rows){
      my $sop = $r->[2];
      if(exists $self->{$name}->{$sop}){
        print STDERR "sop $sop appears multiple times in $name\n";
        next;
      }
      $self->{$name}->{$sop} = $r;
    }
    my $count = keys %{$self->{$name}};
    print STDERR "$count sops in $name\n";
  }
  sub AnalyzeResults{
    my($self) = @_;
    print STDERR "In AnalyzeResults\n";
    my %OnlyInPosda;
    my %OnlyInIntake;
    my %SeriesOnlyInPosda;
    my %SeriesDescOnlyInPosda;
    my %DoseReportSeries;
    for my $i (keys %{$self->{Posda}}){
      unless(exists $self->{Intake}->{$i}){
        $OnlyInPosda{$i} = 1;
        my $series = $self->{Posda}->{$i}->[7];
        my $series_desc = $self->{Posda}->{$i}->[5];
        if($series_desc ne "Dose Report"){
          $SeriesOnlyInPosda{$series} = 1;
          $SeriesDescOnlyInPosda{$series_desc} = 1;
        } else {
          $DoseReportSeries{$series} = 1;
        }
      }
    }
    for my $i (keys %{$self->{Intake}}){
      unless(exists $self->{Posda}->{$i}){
        $OnlyInPosda{$i} = 1;
      }
    }
    print STDERR "OnlyInPosda:\n";
    for my $i (keys %OnlyInPosda){
       print STDERR "\t$i\n";
    }
    print STDERR "SeriesOnlyInPosda:\n";
    for my $i (keys %SeriesOnlyInPosda){
       print STDERR "\t$i\n";
    }
    print STDERR "SeriesDescOnlyInPosda:\n";
    for my $i (keys %SeriesDescOnlyInPosda){
       print STDERR "\t$i\n";
    }
    print STDERR "DoseReportSeries\n";
    for my $i (keys %DoseReportSeries){
       print STDERR "\t$i\n";
    }
    print "OnlyInIntake:\n";
    for my $i (keys %OnlyInIntake){
       print STDERR "\t$i\n";
    }
  };
}
sub Maker{
  my($collection, $site) = @_;
  my $sub = sub {
    Program->new($collection, $site);
  };
  return $sub;
}
Dispatch::Select::Background->new(Maker($ARGV[0], $ARGV[1]))->queue;
Dispatch::Select::Dispatch();
