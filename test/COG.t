#
#===============================================================================
#
#         FILE:  COG.t
#
#  DESCRIPTION:  
#
#        FILES:  ---
#         BUGS:  ---
#        NOTES:  ---
#       AUTHOR:  Dr. Scott A. Givan (sag), givans@missouri.edu
#      COMPANY:  University of Missouri, USA
#      VERSION:  1.0
#      CREATED:  03/16/15 13:32:12
#     REVISION:  ---
#===============================================================================

use 5.010;      # Require at least Perl version 5.10
use autodie;
use strict;
use warnings;
use FindBin qw/ $Bin /;
use lib "$Bin/../lib";

# declare number of tests to run
use Test::More tests => 10;

use_ok('COGDB::COG');#1

my $cog = COGDB::COG->new({ID => 1});

isa_ok($cog,'COGDB::COG');#2

my $cog2 = COGDB::COG->new({Name => $cog->name()});

is($cog->id(),$cog2->id(), 'Both initialization methods work');#3

is($cog->name_to_id($cog->name()),$cog->id(),'name_to_id()');#4

my $allcogs = $cog->fetch_all();
isa_ok($allcogs,'ARRAY');#5
isa_ok($allcogs->[0],'COGDB::COG');#6

my $fetch_by_category = $cog->fetch_by_category(1);
isa_ok($fetch_by_category,'ARRAY');#7
isa_ok($fetch_by_category->[0],'COGDB::COG');#8

my $categories = $cog->categories($cog->id());
isa_ok($categories,'ARRAY');#9
isa_ok($categories->[0],'COGDB::Category');#10

