#!/usr/bin/env perl 
#===============================================================================
#
#         FILE:  populate_accessions_table.pl
#
#        USAGE:  ./populate_accessions_table.pl  
#
#  DESCRIPTION:  Script to populate the Accessions table in COGDB.
#                   This script will probably only be used once.
#
#      OPTIONS:  ---
# REQUIREMENTS:  ---
#         BUGS:  ---
#        NOTES:  ---
#       AUTHOR:  Dr. Scott Givan (sag), givans@missouri.edu
#      COMPANY:  University of Missouri, USA
#      VERSION:  1.0
#      CREATED:  07/02/14 12:05:18
#     REVISION:  ---
#===============================================================================

use 5.010;       # use at least perl version 5.10
use strict;
use warnings;
use autodie;
use Getopt::Long; # use GetOptions function to for CL args
use lib '/home/sgivan/projects/COGDB/lib';
use COGDB;
use COGDB::Accession;

my ($debug,$verbose,$help);

my $result = GetOptions(
    "debug"     =>  \$debug,
    "verbose"   =>  \$verbose,
    "help"      =>  \$help,
);

if ($help) {
    help();
    exit(0);
}

#$debug = 1;

my $cogdb = COGDB->new();
my $orgobj = $cogdb->organism();
my $all_organisms = $orgobj->fetch_all();
my $db = $cogdb->cgrbdb();

my ($loop,$acc) = (0,0);
for my $organism (@$all_organisms) {
    ++$loop;
    if ($debug) {
        say "\$organism isa '" . ref($organism) . "'";
        say $organism->name() . "\t" . $organism->id() . "\t" . $organism->accession();
    }
    my $acc_string = $organism->accession();
    my $orgID = $organism->id();
    if (!$acc_string) {
        say "warning: " . $organism->name() . " has no accession numbers in database";
        next;
    }
    my @accession = split /\s/,$acc_string;
    for my $accession (@accession) {
        say $organism->id() . " accession: '$accession'" if ($debug);
        my $statement = "insert into COGDB.Accessions (`OrgID`,`Accession`) values ($orgID,'$accession')";
        say $statement if ($debug);
        my $sth = $db->dbh()->prepare($statement);
        $db->dbAction($db->dbh(),$sth,1);
        ++$acc;
    }
    last if ($debug && $loop >= 3);
}

say "$loop organisms and $acc accessions entered into COGDB.Accessions table";

sub help {

    say <<HELP;


HELP

}


