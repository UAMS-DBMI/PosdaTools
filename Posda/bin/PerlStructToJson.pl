#!/usr/bin/perl -w
#$Source: /home/bbennett/pass/archive/Posda/bin/PerlStructToJson.pl,v $
#$Date: 2014/08/27 12:26:29 $
#$Revision: 1.1 $
#
use Storable qw( fd_retrieve );
use JSON;
#use Debug;
#my $dbg = sub {print @_};
my $file = $ARGV[0];
open FILE, "<$file" or die "can't open $file";
my $struct = fd_retrieve(\*FILE);
my $json = encode_json $struct;
print $json;
