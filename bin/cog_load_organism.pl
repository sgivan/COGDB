#!/bin/env perl

# $Id$

use warnings;
use strict;
use Carp;
use lib '/home/sgivan/projects/COGDB/lib';
use COGDB_Load;


my $dbload = COGDB_Load->new();
my $cat_load = $dbload->organism();

#print "\$dbload is a ", ref($dbload), "\n";
#print "\$cat_load is a ", ref($cat_load), "\n";

#$cat_load->parse_file('/dbase/scratch/COG/org.txt');
$cat_load->parse_file('/ircf/dbase/COGdb/2014_update/static/outfile');

print "OK\n";
