#!/usr/bin/perl -w
use Time::Local;
my $usage = "DateIncSubtract <yr> <mo> <da> <num_days>";
unless($#ARGV == 3) { die $usage };
my $yr = $ARGV[0];
my $mo = $ARGV[1];
my $da = $ARGV[2];
my $num_days = $ARGV[3];
my $time = timelocal(0,0,0,$da,$mo - 1,$yr);
my $shifted_time = $time +  ($num_days * 60 * 60 * 24);
print "Before shift: ";
print scalar localtime($time);
print "\nAfter shift: ";
print scalar localtime($shifted_time);
print "\n";
