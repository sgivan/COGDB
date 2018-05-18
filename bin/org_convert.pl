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

#    Use lynx to print static/lists/homeCOGs.html to homeCOGs.html.txt.
#    Delete first three lines. Save as homeCOGs.txt.
#    grep -P "^\s{10,}[A-Z]+$" homeCOGs.txt | sed 's/ //g' | sort | uniq > supers.txt
#    grep -v -P "^\s{10,}[A-Z]+$" homeCOGs.txt | sed -E 's/^\s{1,5}(\w+\s+.+)/\1/' > temp0.txt
#    cat temp0.txt | sed -r 's/(\w+)\s\s/\1\t/' > temp2.txt
#    cat temp2.txt | sed -r 's/\s{2,}//' > temp3.txt
#    cat temp3.txt | sed 's/\t/\t00\t/' > temp4.txt
#    create symlink to COG2014/genomes2003-2014.tab
#    ~/projects/COGDB/bin/org_convert.pl --file temp4.txt  --debug
#    ~/projects/COGDB/bin/cog_load_organism.pl 

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



