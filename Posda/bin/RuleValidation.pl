#!/usr/bin/perl -w
#$Source: /home/bbennett/pass/archive/Posda/bin/RuleValidation.pl,v $
#$Date: 2013/05/17 15:11:04 $
#$Revision: 1.1 $
#
#Copyright 2013, Bill Bennett
# Part of the Posda package
# Posda may be copied only under the terms of either the Artistic License or the
# GNU General Public License, which may be found in the Posda Distribution,
# or at http://posda.com/License.html
#
use strict;
use Posda::Try;
use Cwd;
use Debug;
use Posda::ValidationRules;
use Posda::ValidationRuleEngine;
my $dbg = sub { print STDERR @_ };
my $file = $ARGV[0];
unless($file =~ /^\//) { $file = getcwd ."/$file" }
my $try = Posda::Try->new($file);
unless(exists $try->{dataset}) { die "$file is not a dataset" }
my $ds = $try->{dataset};
Posda::ValidationRuleEngine::invoke(\@Posda::ValidationRules::rules, $ds);
