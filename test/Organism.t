#
#===============================================================================
#
#         FILE:  Organism.t
#
#  DESCRIPTION:  Test script to test COGDB::Organism class.
#
#        FILES:  ---
#         BUGS:  ---
#        NOTES:  ---
#       AUTHOR:  Dr. Scott Givan (sag), givans@missouri.edu
#      COMPANY:  University of Missouri, USA
#      VERSION:  1.0
#      CREATED:  07/02/14 13:25:43
#     REVISION:  ---
#===============================================================================

use 5.010;       # use at least perl version 5.10
use strict;
use warnings;
use autodie;

use Test::More tests => 13;
use lib '/home/sgivan/projects/COGDB/lib';
use_ok('COGDB');

my $cogdb = COGDB->new();

isa_ok($cogdb,"COGDB");

my $organism = $cogdb->organism();
isa_ok($organism,'COGDB::Organism');

my $all_organisms = $organism->fetch_all();
isa_ok($all_organisms,'ARRAY','fetch_all returned an array reference');

for my $looporg (@$all_organisms) {
    isa_ok($looporg,'COGDB::Organism','first object in array reference');
    like($looporg->id(), qr/^\d+$/, 'ID looks OK');
    like($looporg->code(), qr/^\w{3}$/, "Code looks OK '" . $looporg->code() . "'");
    like($looporg->name(), qr/[\w\s.]+/, "Name looks OK '" . $looporg->name() . "'");
    isa_ok($looporg->division(), 'COGDB::Division', "Division");
    like($looporg->other(), qr/^\d+$/, 'Other looks OK');
    is($looporg->extend(), undef, 'Extend looks OK');
    is($looporg->pathogen(), undef, 'Pathogen looks OK');
    like($looporg->accession(), qr/[A-Z]{2}_\d+/, "Accession looks OK '" . $looporg->accession() . "'");
    last;
}

done_testing();

