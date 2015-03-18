#!/usr/bin/env perl 
#===============================================================================
#
#         FILE:  run_tests.pl
#
#        USAGE:  ./run_tests.pl  
#
#  DESCRIPTION:  Run tests 
#
#      OPTIONS:  ---
# REQUIREMENTS:  ---
#         BUGS:  ---
#        NOTES:  ---
#       AUTHOR:  Dr. Scott A. Givan (sag), givans@missouri.edu
#      COMPANY:  University of Missouri, USA
#      VERSION:  1.0
#      CREATED:  03/18/15 09:27:22
#     REVISION:  ---
#===============================================================================

use 5.010;      # Require at least Perl version 5.10
use autodie;
use Getopt::Long; # use GetOptions function to for CL args
use warnings;
use strict;
use Test::Harness;
use FindBin qw/ $Bin /;
use File::chdir;

my ($debug,$verbose,$help);
my $testdir = "$Bin/../test";
$CWD = $testdir;

opendir(my $dirh,$testdir);

my @testfiles = grep(/^\w+\.t$/, readdir($dirh));

runtests(@testfiles);

my $result = GetOptions(
    "debug"     =>  \$debug,
    "verbose"   =>  \$verbose,
    "help"      =>  \$help,
);

if ($help) {
    help();
    exit(0);
}

sub help {

    say <<HELP;


HELP

}



