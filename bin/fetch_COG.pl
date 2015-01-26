#!/bin/env perl
# $Id: fetch_COG.pl,v 3.2 2008/02/07 01:34:55 givans Exp $

use warnings;
use Getopt::Std;
use Bio::DB::Flat;
use Bio::SeqIO;
use vars qw/ $opt_i $opt_n $opt_D $opt_d $opt_h $opt_v /;
use COGDB;

getopts('i:n:D:dhv');

my $cogid = $opt_i;
my $cogname = $opt_n;
my $cogdescr = $opt_D;
my $debug = $opt_d;
my $help = $opt_h;
my $verbose = $opt_v;

if ((!$cogid && !$cogname && !$cogdescr) || $help) {
  help();
  exit();
}


my $cogdb = COGDB->new();
#my $cogs = $cogdb->cog();

# print "\$cogs isa '", ref($cogs), "'\n";

# my $allcogs = $cogs->fetch_all();

# foreach my $cogobj (@$allcogs) {
#   print "id: '", $cogobj->id(), "'\n";
# }

if ($cogid) {
  my $cog = $cogdb->cog({ID => $cogid});
  my $whog = $cogdb->whog();
  my $seqdb = Bio::DB::Flat->new(
				 -directory	=>	"$ENV{HOME}/lib/seqdb",
				 -write_flag	=>	0,
				 -dbname	=>	'cogs',
				 -index		=>	'bdb',
				 );
  my $seqout = Bio::SeqIO->newFh(
				 -format	=>	'fasta',
				 );

  my $whogobjs = $whog->fetch_by_cog($cog);

  foreach my $whogobj (@$whogobjs) {
    my $extend = $whogobj->source()->extend();
    if (!$extend) {
      #print "whog name = ", $whogobj->name(), "\n";
      my $seq = $seqdb->get_Seq_by_id($whogobj->name());
      print $seqout $seq;
      #last;
    }
  }
  #print "number of whogs: ", scalar(@$whogobjs), "\n";

  #print "COG ID: ", $cog->id(), "\n";
  #print "COG Name: ", $cog->name(), "\n";
  #print "COG Description: ", $cog->description(), "\n";
}




sub help {

print <<HELP;

options

  -i	COG ID
  -n	COG Name
  -D	Search for term in COG descriptions
  -d	debug mode
  -h	print help menu
  -v	verbose output to terminal




HELP
}
