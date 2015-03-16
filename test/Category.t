#
#===============================================================================
#
#         FILE:  Category.t
#
#  DESCRIPTION:  Test COGDB::Category
#
#        FILES:  ---
#         BUGS:  ---
#        NOTES:  ---
#       AUTHOR:  Dr. Scott A. Givan (sag), givans@missouri.edu
#      COMPANY:  University of Missouri, USA
#      VERSION:  1.0
#      CREATED:  03/13/15 18:44:47
#     REVISION:  ---
#===============================================================================

use 5.010;      # Require at least Perl version 5.10
use autodie;
use strict;
use warnings;
use FindBin qw/$Bin/;
use lib "$Bin/../lib";

# declare number of tests to run
use Test::More tests => 6;

use_ok('COGDB::Category');

my $cat = COGDB::Category->new({Code => 'S'});

isa_ok($cat,'COGDB::Category');

is($cat->description(),'Function unknown','Description OK');

is($cat->code(),'S','Code OK');

my $allcats = $cat->fetch_all();

isa_ok($allcats,'ARRAY', 'fetch_all');

is($cat->code_to_id($allcats->[0]->code()),$allcats->[0]->id(),'code_to_id');

