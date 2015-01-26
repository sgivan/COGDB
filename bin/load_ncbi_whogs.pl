#!/usr/bin/env perl 
#===============================================================================
#
#         FILE:  load_ncbi_whogs.pl
#
#        USAGE:  ./load_ncbi_whogs.pl  
#
#  DESCRIPTION:  Script to use NCBI *.ptt files to load whogs into COGDB
#                   Goals of this script are to:
#                       1) Identify ptt file from cl args
#                       2) Validate that the organism exists in COGDB
#                       3) Parse ptt file
#                       4) Construct data structure to load into COGDB
#                       5) Load data into COGDB
#
#      OPTIONS:  ---
# REQUIREMENTS:  ---
#         BUGS:  ---
#        NOTES:  ---
#       AUTHOR:  Dr. Scott Givan (sag), givans@missouri.edu
#      COMPANY:  University of Missouri, USA
#      VERSION:  1.0
#      CREATED:  08/28/14 10:05:32
#     REVISION:  ---
#===============================================================================

use 5.010;       # use at least perl version 5.10
use strict;
use warnings;
use autodie;
use Getopt::Long; # use GetOptions function to for CL args
use lib '/home/sgivan/projects/COGDB/lib';
use COGDB;
use COGDB_Load;

my ($debug,$verbose,$help,$orgcode,$pttfile);

my $result = GetOptions(
    "org:s"     =>  \$orgcode,
    "ptt:s"     =>  \$pttfile,
    "debug"     =>  \$debug,
    "verbose"   =>  \$verbose,
    "help"      =>  \$help,
);
$pttfile ||= 'pttfile';
$verbose = 1 if ($debug);

my $cogdb = COGDB->new();
my $cogobj = $cogdb->cog();
my $cogdbload = COGDB_Load->new();
my $orgload = $cogdbload->organism();
my $whogload = $cogdbload->whog();

if ($help) {
    help();
    exit(0);
}

if (!-e $pttfile) {
    # most ptt files are in /ircf/dbase/genomes/bacterial/ptt
    say "'$pttfile' doesn't exist";
    exit();
}

if (!$orgload->code_exists($orgcode)) {
    say "organism code '$orgcode' doesn't exist";
    exit();
}
my $org_id = $orgload->code_exists($orgcode);
say "ID for '$orgcode' = $org_id" if ($verbose);

=cut
ptt files look like this:

Staphylococcus aureus RF122, complete genome - 1..2742531
2509 proteins
Location	Strand	Length	PID	Gene	Synonym	Code	COG	Product
517..1878	+	453	82749778	dnaA	SAB0001	-	COG0593L	chromosomal replication initiation protein
2156..3289	+	377	82749779	dnaN	SAB0002	-	COG0592L	DNA polymerase III subunit beta
3670..3915	+	81	82749780	-	SAB0003	-	COG2501S	hypothetical protein
3912..5024	+	370	82749781	recF	SAB0004	-	COG1195L	recombination protein F
5034..6968	+	644	82749782	gyrB	SAB0005	-	COG0187L	DNA gyrase subunit B
7005..9665	+	886	82749783	gyrA	SAB0006	-	COG0188L	DNA gyrase subunit A
9753..10583	-	276	82749784	-	SAB0007c	-	COG0063G	hypothetical protein
10890..12404	+	504	82749785	hutH	SAB0008	-	COG2986E	histidine ammonia-lyase
12781..14067	+	428	82749786	serS	SAB0009	-	COG0172J	seryl-tRNA synthetase

We want the "Synonym" and the "Code."

=cut

say "opening '$pttfile'" if ($debug);
open(PTT,"<",$pttfile);

my $pttcnt = 0;
my @whogs = ();
for my $line (<PTT>) {
    chomp($line);
    say "line: '$line'" if ($debug);
    my @linevals = split /\t/, $line;

    next unless (scalar(@linevals)) == 9;
    next if ($linevals[7] eq 'COG');# b/c header has 9 fields
    my $synonym = $linevals[5];
    my $cog = $linevals[7];
    next if ($cog eq '-');# some genes are not associated with a COG

    if ($cog =~ /(COG\d{4})[A-Z]/) {
        $cog = $1;
    }
    my $cog_id = $cogobj->name_to_id($cog);

    say "synonym: '$synonym'\tcog: '$cog'\t cog id: '$cog_id'" if ($debug);

    push(@whogs,[$synonym, $org_id, $cog_id]);

    last if (++$pttcnt == 10 && $debug);
}

say "loading $pttcnt whogs into COGDB" if ($verbose);

$whogload->load_whog(\@whogs);


close(PTT);


sub help {

    say <<HELP;

    Script to load NCBI ptt file into COGDB
    Command line options:

    --org   organism code
    --ptt   ptt file to use
    --debug
    --verbose
    --help


HELP

}


