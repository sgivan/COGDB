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

use Test::More tests => 5;

use_ok('COGDB::Accession');

my $accession = COGDB::Accession->new({orgID => 14});

isa_ok($accession,'COGDB::Accession');

my $listref = $accession->accessions();

isa_ok($listref,'ARRAY');

for my $acc (@$listref) {
    #say $acc;
    like($acc,qr/\S/,"$acc looks OK");
    cmp_ok($accession->exists($acc),">=",1,"$acc exists");
    last;
}

done_testing();

