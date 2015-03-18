#
#===============================================================================
#
#         FILE:  Accession.t
#
#  DESCRIPTION:  Test script for COGDB::Accession.
#
#        FILES:  ---
#         BUGS:  ---
#        NOTES:  ---
#       AUTHOR:  Dr. Scott Givan (sag), givans@missouri.edu
#      COMPANY:  University of Missouri, USA
#      VERSION:  1.0
#      CREATED:  07/11/14 14:42:43
#     REVISION:  ---
#===============================================================================

use 5.010;       # use at least perl version 5.10
use strict;
use warnings;
use autodie;
use lib '/home/sgivan/projects/COGDB/lib';

use Test::More tests => 6;

use_ok('COGDB::Accession');

my $accession = COGDB::Accession->new({orgID => 14});

isa_ok($accession,'COGDB::Accession');

my $listref = $accession->accessions();

isa_ok($listref,'ARRAY');

#ok($listref->[0],'Accession number retrieved from database');

SKIP: {

    skip "-- test will fail if accession number doesn't exist", 3 unless (exists($listref->[0]));

    ok($listref->[0],'Accession number retrieved from database');
    cmp_ok($accession->exists($listref->[0]),">=",1,"Accession number exists");
    like($listref->[0],qr/\S/,"Accession number looks OK");
}

done_testing();

