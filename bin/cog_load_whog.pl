#!/bin/env perl

# $Id: cog_load_whog.pl,v 3.2 2005/12/08 17:50:33 givans Exp $

use warnings;
use strict;
use Carp;
use FindBin qw/ $Bin /;
#use lib '/home/sgivan/projects/COGDB/lib';
use lib "$Bin/../lib";
use COGDB_Load;

my $whog_file = shift;
if (! $whog_file) {
  my $script = $0;
  $script =~ s/.+\///;
  print "usage:  $script <file name>\n";
  exit(0);
}

#$whog_file = '/dbase/scratch/COG/whog' unless ($whog_file);
# in the 2014 update, I load the  cog2003-2014.csv file.
print "loading whog file: $whog_file\n";

my $dbload = COGDB_Load->new();
my $cat_load = $dbload->whog();

#$cat_load->parse_file('/dbase/scratch/COG/whog');
$cat_load->parse_file($whog_file);

print "OK\n";
