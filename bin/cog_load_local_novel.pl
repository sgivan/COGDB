#!/bin/env perl

# $Id: cog_load_local_novel.pl,v 3.1 2005/12/08 17:48:50 givans Exp $

use warnings;
use strict;
use Carp;
use lib '/home/sgivan/projects/COGDB/lib';
use COGDB_Load;
use COGDB;

my $file = $ARGV[0];
if (! $file) {
  my $script = $0;
  $script =~ s/.+\///;
  print "usage:  $script <file name>\n";
  exit(0);
}

my $organism_id = 0;
#$organism_id =~ s/whogs_unique_\d+_//;
if ($file =~ /whogs_unique_\d+_(\d+)/) {
        $organism_id = $1;
}
print "organism ID = '$organism_id'\n";

my $dbload = COGDB_Load->new();
$dbload->localcog_load();

my $cogdb = COGDB->new();
my $local_cogdb = $cogdb->localcogs();
my $organism = $local_cogdb->organism({ ID => $organism_id});
if ($organism->name() =~ /\w+/) {
    print "organism name: ", $organism->name(), "\n";
} else {
    print "invalid organism id: '$organism_id'\n";
}

my $cat_load = $dbload->whog();

open(IN,$file) or die "can't open '$file': $!";

foreach my $line (<IN>) {
  my ($cogname,$cogid) = split /\t/, $line;
  chomp($cogid);

  my $cog = $cogdb->cog({ ID => $cogid });

  print "setting '$cogname' ('$cogid') ", $cog->description(), " to novel\n";
  $cat_load->novel(
		   {
		    organism	=>	$organism,
		    cog		=>	$cog,
		    }
		   );

}

close(IN);
