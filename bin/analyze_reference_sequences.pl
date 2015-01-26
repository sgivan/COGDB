#!/usr/bin/env perl 
#===============================================================================
#
#         FILE:  analyze_reference_sequences.pl
#
#        USAGE:  ./analyze_reference_sequences.pl  
#
#  DESCRIPTION:  Script to analyze proteins sequences in a reference genome.
#                   Goals of the script are to:
#                   1) Identify if accession number is new
#                   2) If new accession number, analyze sequences
#                   3) Identify species associated with accession number
#                   4) If species is new, create "code."
#                   5) Identify and store whogs in MySQL DB
#
#      OPTIONS:  ---
# REQUIREMENTS:  ---
#         BUGS:  ---
#        NOTES:  ---
#       AUTHOR:  Dr. Scott Givan (sag), givans@missouri.edu
#      COMPANY:  University of Missouri, USA
#      VERSION:  1.0
#      CREATED:  07/17/14 10:57:04
#     REVISION:  ---
#===============================================================================

use 5.010;       # use at least perl version 5.10
use strict;
use warnings;
use autodie;
use Getopt::Long; # use GetOptions function to for CL args
use Bio::SeqIO;
use lib '/home/sgivan/projects/COGDB/lib';
use COGDB_Load;
use COGDB::Accession;
use File::Copy;

my ($debug,$verbose,$help,$infile,$noblast,$clusterblast,$useptt,$cb_dir,$ptt_dir,$extend);

my $result = GetOptions(
    "infile:s"  =>  \$infile,
    "cbdir:s"   =>  \$cb_dir,
    "noblast"   =>  \$noblast,
    "useptt"    =>  \$useptt,
    "pttdir:s"  =>  \$ptt_dir,
    "extend"    =>  \$extend,
    "debug"     =>  \$debug,
    "verbose"   =>  \$verbose,
    "help"      =>  \$help,
);
$verbose = 1 if ($debug);
$infile = 'infile' unless ($infile);
$clusterblast = 1 unless ($noblast);
$ptt_dir = '/ircf/dbase/genomes/bacterial/ptt' unless ($ptt_dir);

if ($help) {
    help();
    exit(0);
}

if (!-e $infile) {
    say "'$infile' doesn't exist";
    exit(1);
}

##
# determine if this is a new accession number
##

my $accession_number = "";

if ($infile =~ /(\S+?)\./) {
    $accession_number = $1;
} else {
    say "invalid file name: '$infile'.";
    exit(2);
}
say "\n#########\n# accession number: '$accession_number'\n#########" if ($verbose);

my $accession_obj = COGDB::Accession->new();
if ($accession_obj->exists($accession_number)) {
    say "$accession_number alread exists.\nNot proceeding with analysis.";
    exit();
}

##
# identify organism
##

say "Identifying organism" if ($verbose);

my $cogdbload = COGDB_Load->new();
my $org_obj = $cogdbload->organism();

#my $organism = "";
#my $division = "";
my ($organism,$division,$organism_division,$division_id,$code) = ();
open(INFILE,"<",$infile);
for my $line ( grep /ORGANISM\s(.+)$/,<INFILE>) {
    chomp($line);
    if ($line =~ /ORGANISM\s+(\S.+)$/) {
        $organism = $1;
    }
    say "organism: '$organism'" if ($verbose);
    last;
}

if (!$org_obj->organism_exists($organism)) {

    my $seek_rtn = seek(INFILE,0,0);
    if (!$seek_rtn) {
        say "FATAL: can't rewind input file. Not going further.";
        exit(1);
    }

    my $append = 0;
    for my $line (<INFILE>) {
        chomp($line);
        if ($line =~ /ORGANISM/) {
            $append = 1;
            next;
        } elsif ($line =~ /REFERENCE/) {
            $append = 2;
            last;
        }
        if ($append == 1) {
            $division .= $line;
        }
    }

    $division =~ s/\s//g;
    $division =~ s/\.//;

    $organism_division = "";
    my $div_obj = $cogdbload->division();
    my @taxa = split /;/, $division;
    for my $taxa (@taxa) {
        if ($div_obj->division_exists($taxa)) {
            $organism_division = $taxa;
            last;
        }
    }

    if (!$organism_division) {
        say "re-searching division names" if ($debug);

        my $divisions = $div_obj->list_divisions();
        for my $division (@$divisions) {
            #say $division;
            for my $taxa (@taxa) {
                if ($taxa =~ /$division/i) {
                    $organism_division = $division;
                    last;
                }
            }
            last if ($organism_division);
        }
    }
    $division_id = $div_obj->division_id($organism_division);
    if ($division_id) {
        say "division = '$division'" if ($verbose);
        say "organism division = '$organism_division' ($division_id)" if ($verbose);
    } else {
        say "WARNING: division for '$organism' [$accession_number] not found in COGDB";
    }
}

close(INFILE);
#say "division = '$division'" if ($verbose);
#say "organism division = '$organism_division' ($division_id)" if ($verbose);


$code = $accession_number;
if ($org_obj->organism_exists($organism)) {
    say "'$organism' already present in db" if ($verbose);
    # get code from database entry
    $code = $org_obj->organism_exists($organism);
} else {
    say "'$organism' is not present in db" if ($verbose);

    ##
    # try to create a code for this organism
    ##

    my $extension = 0;
    my ($original_species,$original_genus) = ();
    if ($organism =~ /(\w+)\s(.+)/) {
            my $genus = $original_genus = $1;
            my $species = $original_species = $2;
            chomp($species);
            say "genus = '$genus', species = '$species'";

            my ($i,$j) = (0,1);
            my $genus_length = length($genus);
            while ($j < $genus_length) {
                my $tcode = substr($genus,0,1);
                my $tchar = substr($genus,$j,1);
                next if ($tchar =~ /\W/);
                $tcode .= $tchar;

                my $maxtry = length($species);
                for (my $i = 0; $i < $maxtry; ++$i) {

                    my $char = lc(substr($species,$i,1));
                    next if ($char =~ /\W/);
                    say "trying '$char'";
                    $tcode .= $char;

                    say "try code '$tcode'" if ($verbose);
                    if ($org_obj->code_exists($tcode)) {
                        say "'$tcode' exists" if ($verbose);
                        chop($tcode);
#                        if ($i >= $maxtry) {
#                            say "FATAL: can't generate a code for $genus $species" if ($verbose);
#                            exit();
#                        }
                    } else {
                        say "'$tcode' doesn't exist" if ($verbose);
                        $code = $tcode;
                        last;
                    }
                }
            } continue {
                # end of loop
                ++$j;
                if (($j == $genus_length) && ($code eq $accession_number)) {
                    ++$extension;
                    if ($extension == 1) {
                        #$original_species = $species unless ($orginal_species);
                        $species = join '', ("a" .. "z");
                    } elsif ($extension == 2) {
                        $species = join '', (0 .. 9);
                    } else {
                        say "FATAL: can't generate a code for $genus $species [code == accession number]";
                        exit();
                    }
                    say "creating artificial species = '$species'" if ($verbose);
                    $i = 0;
                    $j = 1;
                    #$maxtry = length($species);
                    redo;
                } elsif ($code ne $accession_number) {
                    # we've got a good code, so move on
                    last;
                }
            }
    }

    say "Finished identifying organism. Code = '$code'." if ($verbose);

##
# store organism in database
# need: Code, Name, Division ID
# need: accession number
##
    my @load_line = ($code,'',$division_id,$organism);
    $org_obj->load_organism([\@load_line]);
}

my $orgID = $org_obj->code_exists($code);
$org_obj->load_accession($orgID,$accession_number);
$org_obj->set_extend($code) if ($extend);

##
# extract protein sequences from source file
##

say "extracting sequences from input file to: $infile" . ".fasta" if ($verbose);
# usage: get_seqfeature.pl -f <filename> -F <file format>
open(XTRACT,"-|","bsub -J xtract -Ip 'get_seqfeature.pl -f $infile -F genbank -l'");
if ($verbose) {
    while (<XTRACT>) {
        say $_;
    }
}
close(XTRACT);
say "finished extracting sequences" if ($verbose);

if ($noblast) {
    say "skipping clusterblast" if ($verbose);
#    say "exiting now" if ($verbose);
#    exit();
} else {

#if ($clusterblast) {
##
# submit protein sequences to clusterblast
##

    say "Submitting protein sequences to clusterblast" if ($verbose);
    $cb_dir = "clusterblast.$code" unless ($cb_dir);
    if (!-e $cb_dir) {
        say "creating $cb_dir directory, which will contain clusterblast output" if ($verbose);
        if (!mkdir($cb_dir)) {
            say "FATAL: can't create $cb_dir directory";
            exit(3);
        }
    } else {
        say "$cb_dir directory already present" if ($verbose);
    }

##
# copy file to clusterblast directory
##
    if (!move("$infile" . ".fasta","$cb_dir/$infile" . ".pfa")) {
        say "FATAL: can't move file into $cb_dir directory";
        exit(4);
    } else {
        say "$infile" . ".fasta moved into $cb_dir directory and renamed to $infile" . ".pfa" if ($verbose);
    }

    if (!chdir($cb_dir)) {
        say "FATAL: can't change directory to '$cb_dir'";
        exit(5);
    }

    open(CLUSTERBLAST,"-|","clusterblast -f $infile" . ".pfa -d cogs -B -b blastp -a '-seg no -num_descriptions 250 -num_alignments 250'");

    if ($verbose) {
        while (<CLUSTERBLAST>) {
            print $_;
        }
    }
    close(CLUSTERBLAST);
    chdir('..');
    say "Finished submitting sequences to clusterblast" if ($verbose);

}

##
# Identify COGs
##

if ($useptt) {

    if (!-e $ptt_dir . "/" . $accession_number . ".ptt") {
        say "'$ptt_dir' doesn't exist";
        exit();
    }
}

say "Identifying COGs" if ($verbose);

if ($clusterblast) {
    say "running clusterblast on BioCluster" if ($verbose);
    #open(COGS, "-|", "bsub -J reCOG.$code -Ip '~/projects/COGDB/bin/reCOGnition.pl -o $code -F $cb_dir -b blastp -w $code'");
    open(COGS, "-|", "bsub -J reCOG.$code -Ip '~/projects/COGDB/bin/reCOGnition.pl -o $code -F $cb_dir -b blastp -w $code -G 500 -s'");
} elsif ($useptt) {
    say "running load_ncbi_whogs.pl on BioCluster" if ($verbose);
    say "bsub -J COG.$code -Ip '~/projects/COGDB/bin/load_ncbi_whogs.pl --verbose --org $code --ptt $ptt_dir" . "/" . $accession_number . ".ptt'" if ($verbose);
    open(COGS, "-|", "bsub -J COG.$code -Ip '~/projects/COGDB/bin/load_ncbi_whogs.pl --verbose --org $code --ptt $ptt_dir" . "/" . $accession_number . ".ptt'");
}
if ($verbose) {
    while (<COGS>) {
        say $_;
    }
}
close(COGS);
if ($verbose) {
    say "Finished identifying COGs.";
    say "Use whogs file to load into database." unless ($useptt);
}

sub help {

say <<HELP;

Input files must conform to a naming standard related to their accession numbers.
It is assumed that all characters in file name up to the first period is the
accession number. For example, a valid file name is NC_004567.gbk.fasta. An invalid
file name is NC_004567.1.gbk.fasta.
Note: clusterblast must be in your path before running this script. This can
be as simple as running the command "module load clusterblast".

--infile        input file name
--cbdir         file to contain clusterblast output [otherwise a default name will be created]
--noblast       do not search COG DB with BLAST
--useptt        use NCBI ptt file for COG data instead of reCOGnition.pl
--pttdir        the directory containing the ptt files [default=/ircf/dbase/genomes/bacterial/ptt]
--extend        label organism as a member of extend (may be irrelevant)
--debug         debugging output to terminal
--verbose       verbose output to terminal
--help          this help message

HELP

}


