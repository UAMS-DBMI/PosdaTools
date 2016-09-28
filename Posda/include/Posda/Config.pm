package Posda::Config;

require Exporter;
@ISA = 'Exporter';
@EXPORT_OK = ('Config', 'Database');

use Modern::Perl '2010';
use Method::Signatures::Simple;

use Env;
use JSON;

use Posda::DicomSendLocations;
use Posda::DatabaseConfig;

our $vars = {};

# special complex rules for certain config variables
my $loading_rules = {
  dicom_send_locations => sub {
    return Posda::DicomSendLocations::get();
  },
  databases => sub {
    return Posda::DatabaseConfig::get();
  },
  extraction_mgr_port => sub {
    return Config("port") + 2;
  },
  port_pool => sub {
    my $main_port = Config("port");
    return [($main_port+3)..($main_port+20)];
  },
};

func _get($var) {
  my $var_name = "POSDA_$var";

  if (defined $ENV{$var_name}) {
    return $ENV{$var_name};
  } else {
    say STDERR "Attempted to load environment variable $var_name but it was " .
               "not found! Is the Posda environment configured?";
    return undef;
  }
}

func _load($var) {
  if (defined $loading_rules->{$var}) {
    return $loading_rules->{$var}();
  }

  # default rule
  return _get(uc($var));
}

func Config($var) {
  if (not defined $vars->{$var}) {
    $vars->{$var} = _load($var);
  }
  return $vars->{$var};
}

my $driver_map = { postgres => 'Pg',
                   mysql => 'mysql', };

func Database($name) {
  my $db_info = Config('databases')->{$name};

  if (not defined $db_info) {
    say STDERR "Invalid database name requested: $name";
    return 'invalid database name';
  }

  my $driver = $driver_map->{$db_info->{driver}};

  if (not defined $driver) {
    say STDERR "Invalid driver specified in database config: $db_info->{driver}";
    return 'invalid database driver';
  }

  my $prefix = "dbi:$driver:";

  my @params;
  for my $k (keys %$db_info) {
    if ($k ne 'driver') {
      push @params, "$k=$db_info->{$k}";
    }
  }

  return $prefix . join(';', @params);
}

1;
