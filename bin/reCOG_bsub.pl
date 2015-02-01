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
my ($indir,$crossref,$local_org_name,$min_proportion);
my $bsub = '/opt/openlava-2.2/bin/bsub';
my $reCOGnition = '/home/sgivan/projects/COGDB/bin/reCOGnition.pl';

my $result = GetOptions(
    "indir:s"   =>  \$indir,
    "crossref:s"    =>  \$crossref,
    "localorg:s"    =>  \$local_org_name,
    "proportion:f"  =>  \$min_proportion,
    "debug"     =>  \$debug,
    "verbose"   =>  \$verbose,
    "help"      =>  \$help,
);

$crossref ||= 'alpha';
$local_org_name ||= 'Phirschii';
$min_proportion ||= 0.025;

if ($debug) {
    say "
    indir: '$indir'\n
    crossref: '$crossref'\n
    localorg: '$local_org_name'\n
    proportion: '$min_proportion"
}

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

    if (-f $stub) {
        # use as input to reCOGnition.pl with --infile_list flag
        # -I $stub -S -l -r alpha -w Phirschii -v -P 0.025 
        open(my $bsubfh,">",$stub . ".bsub");

        bsub_content($bsubfh,$stub);

        close($bsubfh);
    }

    open(BSUB,"|-", "$bsub < $stub.bsub");
    
    my @bsub_output = <BSUB>;

    close(BSUB);

    say @bsub_output;

    close(STUB);
    rewinddir($dh);
}
#readdir();

closedir($dh);
close(FILES);

sub help {

say <<HELP;

--indir <directory name>     directory with blast output files
--crossref
--localorg
--proportion
--debug
--verbose
--help


HELP

}


sub bsub_content {
    my $fh = shift;
    my $infile = shift || 'infile';


say $fh <<END;
#BSUB -J reCOG-$infile
#BSUB -o $infile.o%J
#BSUB -e $infile.e%J
#BSUB -q normal
#BSUB -n 1
#BSUB -R "rusage[mem=940]"

$reCOGnition -I $infile -w $local_org_name -r $crossref -l -S -P $min_proportion -d

END

}

