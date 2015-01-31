#!/usr/bin/env perl 
#===============================================================================
#
#         FILE:  reCOG_sub.pl
#
#        USAGE:  ./reCOG_sub.pl  
#
#  DESCRIPTION:  Run reCOGnition.pl on a cluster using bsub.
#
#      OPTIONS:  ---
# REQUIREMENTS:  ---
#         BUGS:  ---
#        NOTES:  ---
#       AUTHOR:  Dr. Scott A. Givan (sag), givans@missouri.edu
#      COMPANY:  University of Missouri, USA
#      VERSION:  1.0
#      CREATED:  01/31/15 07:54:25
#     REVISION:  ---
#===============================================================================

use 5.010;      # Require at least Perl version 5.10
use autodie;
use Getopt::Long; # use GetOptions function to for CL args
use warnings;
use strict;

my ($debug,$verbose,$help);
my ($indir);

my $result = GetOptions(
    "indir:s"   =>  \$indir,
    "debug"     =>  \$debug,
    "verbose"   =>  \$verbose,
    "help"      =>  \$help,
);

if ($help) {
    help();
    exit(0);
}

my $files_cmd = "ls -1 $indir | cut -f 1 -d _ | sort | uniq";

open(FILES,"-|",$files_cmd);

opendir(my $dh,$indir);
for my $stub (<FILES>) {
    chomp($stub);
    say "'$stub'" if ($stub =~ /\w/);
    open(STUB,">",$stub);

    for my $file (grep { /^$stub.+\.blast\w/ && -f "$indir/$_" } readdir($dh)) {
        chomp($file);
        say STUB "$indir/$file";
    }

    close(STUB);
    rewinddir($dh);
}
#readdir();

closedir($dh);
close(FILES);

sub help {

say <<HELP;

--indir <directory name>     directory with blast output files
--debug
--verbose
--help


HELP

}



