#!/usr/bin/perl -w
#$Source: /home/bbennett/pass/archive/Posda/bin/test/DeletePlanRef.pl,v $
#$Date: 2013/03/14 15:30:08 $
#$Revision: 1.1 $
#
#Copyright 2013, Bill Bennett
# Part of the Posda package
# Posda may be copied only under the terms of either the Artistic License or the
# GNU General Public License, which may be found in the Posda Distribution,
# or at http://posda.com/License.html
#
use Posda::Try;
use Cwd;
my $cur_dir = getcwd;
my $file_name = $ARGV[0];
my $new_file_name = $ARGV[1];
unless($#ARGV == 1) { die "usage: $0 <from> <to>" }
unless($file_name =~ /^\//) { $file_name = "$cur_dir/$file_name" }
unless($new_file_name =~ /^\//) { $new_file_name = "$cur_dir/$new_file_name" }
unless(-r $file_name) {die "can't access $file_name" }
my $try = Posda::Try->new($file_name);
unless($try->{dataset}) { die "$file_name didn't parse" }
$try->{dataset}->Delete("(300c,0002)");
$try->{dataset}->WritePart10($new_file_name, $try->{xfr_stx}, "Posda");
