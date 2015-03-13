#!/usr/bin/env perl 
#===============================================================================
#
#         FILE:  org_convert.pl
#
#        USAGE:  ./org_convert.pl  
#
#  DESCRIPTION:  Script to convert new COG organisms file.
#
#      OPTIONS:  ---
# REQUIREMENTS:  ---
#         BUGS:  ---
#        NOTES:  ---
#       AUTHOR:  Dr. Scott A. Givan (sag), givans@missouri.edu
#      COMPANY:  University of Missouri, USA
#      VERSION:  1.0
#      CREATED:  02/27/15 15:43:22
#     REVISION:  ---
#===============================================================================

use 5.010;      # Require at least Perl version 5.10
use autodie;
use Getopt::Long; # use GetOptions function to for CL args
use warnings;
use strict;

my ($debug,$verbose,$help,$infile);

my $result = GetOptions(
    "debug"     =>  \$debug,
    "verbose"   =>  \$verbose,
    "help"      =>  \$help,
    "file:s"    =>  \$infile,
);

if ($help) {
    help();
    exit(0);
}

# Opened lists/listCOGs.html with lynx and saved as text file via Print menu
# Deleted first few lines of resulting file
# ran these commands
# cat org2014.txt | sed -r 's/(\w+)\s\s/\1\t/' > temp1.txt
# cat temp1.txt | sed -r 's/\s{2,}//' > temp2.txt
# cat temp2.txt | sed 's/\t/\t00\t/' > temp3.txt
# run this script on temp3.txt

if (!$infile) {
    help();
}

open(my $fh, "<", $infile);
open(my $taxidsfh,"<",'genomes2003-2014.tab');
open(my $outfh, ">", "outfile");

my (%taxid,%bioproject,$bpid) = ();
for my $line (<$taxidsfh>) {
    chomp($line);
    my @vals = split /\s+/, $line;
    $taxid{$vals[0]} = $vals[1];

    if ($vals[2] =~ /uid(\d+)/) {
        $bpid = $1;
    } else {
        $bpid = '00';
    }
    $bioproject{$vals[0]} = $bpid;
}

say "taxids: '" . scalar(keys %taxid) if ($debug);

my $group = "";
while (<$fh>) {
    chomp(my $line = $_);
#    say "line: '$line'";
    if ($line =~ /^(.+)\s\[\d+\]/) {
        say "group $1" if ($debug);
        $group = $1;
    } else {
        my @vals = split/\t/, $line;
        #say $outfh "$vals[0]\t$taxid{$vals[0]}\t" . ucfirst(lc($group)) . "\t$vals[2]";
        say $outfh "$vals[0]\t$taxid{$vals[0]}\t$bioproject{$vals[0]}\t" . ucfirst(lc($group)) . "\t$vals[2]";
    }
}

sub help {

say <<HELP;

run script with --file argument

HELP
exit();
}



