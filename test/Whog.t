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
#use lib '../lib/';
use FindBin qw/ $Bin /;
use lib "$Bin/../lib";

use Test::More tests => 21;

use_ok('COGDB');#1

my $cogdb = COGDB->new();
isa_ok($cogdb,"COGDB");#2

my $cog = $cogdb->cog({ID => 5});
isa_ok($cog,"COGDB::COG");#3

is($cog->id(),5,'COG ID OK');#4

my $whog = $cogdb->whog({ID => 1});
isa_ok($whog,'COGDB::Whog');#5
isa_ok($whog->source(),'COGDB::Organism');#6
my $cog_count = $whog->cog_count({cog => $cog});
like($cog_count, qr/\d+/, "cog_count = $cog_count");#7

my $cog2 = $whog->cog();
isa_ok($cog2,'COGDB::COG');#8

my $organism = $whog->source();
isa_ok($organism,'COGDB::Organism');#9
print "fetching all wogs for " . $organism->name() . "\n";
my $orgs = $whog->fetch_by_organism($organism);
isa_ok($orgs,'ARRAY');#10
isa_ok($orgs->[0],'COGDB::Whog');#11
is($organism->id(),$orgs->[0]->source->id(),'id == id');#12

my $whogs_by_name = $whog->fetch_by_name($orgs->[0]->name());
isa_ok($whogs_by_name,'ARRAY');#13
isa_ok($whogs_by_name->[0],'COGDB::Whog');#14
is($orgs->[0]->name(),$whogs_by_name->[0]->name(), 'name eq name');#15

my $fetch_by_whog = $whog->fetch_by_whog({organism => $organism, cog => $cog});
isa_ok($fetch_by_whog,'ARRAY');#16
isa_ok($fetch_by_whog->[0],'COGDB::Whog');#17
is($fetch_by_whog->[0]->cog()->id(),$cog->id(), 'cogID == cogID');#18
print "cog name: '", $cog->name(), "'\n";

my $coverage = $whog->coverage_by_division({cog => $cog, division => $organism->division() });
isa_ok($coverage,'ARRAY');#19
isa_ok($coverage->[0],'COGDB::Organism');#20
is($coverage->[0]->division()->id(),$organism->division()->id(), 'divID == divID');#21

done_testing();
