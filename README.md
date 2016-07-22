# PosdaTools
Posda (Perl Open Source DICOM Archive) is an application for archival and
curation of DICOM datasets.


# Installation

## Pre-install steps
* install all deps
* create posda system user
* create postgres user, make them admin
* clone the repository
* edit main.env to your liking (rename this to something like config.env???)

### Dependencies
* git
* postgresql database server, client, and development headers >= 9.0
* perl >= 5.10
* perl modules (all installable from CPAN):
  * Modern::Perl
  * Method::Signatures::Simple
  * DBD::Pg
  * Switch
  * JSON
  * Data::UUID
  * Text::Diff
  * Term::ReadKey


For Ubuntu 16.04, run this:
```
sudo apt-get update
sudo apt-get install -y postgresql-9.5 postgresql-server-dev-9.5 postgresql-client-9.5
sudo apt-get install -y libmodern-perl-perl libmethod-signatures-simple-perl libdbd-pg-perl libjson-perl libswitch-perl libdata-uuid-perl libtext-diff-perl libterm-readkey-perl
```

### Create postgres user
sudo -u postgres createuser -s posda


## Install Steps
* create databases
* populate databases
* add file\_storage\_root entry to posda\_files db (taken from environment)
* prompt user for default admin password?

