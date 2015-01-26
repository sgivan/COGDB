#
#===============================================================================
#
#         FILE:  Whog.t
#
#  DESCRIPTION:  Script to test the COGDB::Whog class
#
#        FILES:  ---
#         BUGS:  ---
#        NOTES:  ---
#       AUTHOR:  Dr. Scott Givan (sag), givans@missouri.edu
#      COMPANY:  University of Missouri, USA
#      VERSION:  1.0
#      CREATED:  10/02/14 11:01:44
#     REVISION:  ---
#===============================================================================

use 5.010;       # use at least perl version 5.10
use strict;
use warnings;
use autodie;
#use lib '../lib/COGDB';
use lib '../lib/';

use Test::More tests => 6;

use_ok('COGDB');

my $cogdb = COGDB->new();
isa_ok($cogdb,"COGDB");

my $cog = $cogdb->cog({ID => 5});
isa_ok($cog,"COGDB::COG");

is($cog->id(),5,'COG ID OK');

my $whog = $cogdb->whog();
isa_ok($whog,'COGDB::Whog');

my $cog_count = $whog->cog_count({cog => $cog});
like($cog_count, qr/\d+/, "cog_count = $cog_count");

done_testing();
