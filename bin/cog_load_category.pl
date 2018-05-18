#!/bin/env perl

# $Id$

use warnings;
use strict;
use Carp;
use FindBin qw/ $Bin /;
use lib "$Bin/../lib";
#use lib '/home/sgivan/projects/COGDB/lib';
use COGDB_Load;


my $dbload = COGDB_Load->new();
my $cat_load = $dbload->category();

#print "\$dbload is a ", ref($dbload), "\n";
#print "\$cat_load is a ", ref($cat_load), "\n";

#$cat_load->parse_file('/ircf/dbase/COGdb/2014_update/fun2003-2014.tab');
$cat_load->parse_file('/share/ircf/dbase/COGdb/2014_update/COG2014/fun2003-2014.tab');

print "OK\n";
