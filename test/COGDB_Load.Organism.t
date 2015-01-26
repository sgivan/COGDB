#
#===============================================================================
#
#         FILE:  COGDB_Load.Organism.t
#
#  DESCRIPTION:  Test script for COGDB_Load::Organism module.
#
#        FILES:  ---
#         BUGS:  ---
#        NOTES:  ---
#       AUTHOR:  Dr. Scott Givan (sag), givans@missouri.edu
#      COMPANY:  University of Missouri, USA
#      VERSION:  1.0
#      CREATED:  07/16/14 16:31:22
#     REVISION:  ---
#===============================================================================

use 5.010;       # use at least perl version 5.10
use strict;
use warnings;
use autodie;
use lib '/home/sgivan/projects/COGDB/lib';

use Test::More tests => 11;

use_ok("COGDB_Load");

my $load = COGDB_Load->new();


my $orgload = $load->organism();
isa_ok($orgload,'COGDB_Load::Organism');

cmp_ok($orgload->code_exists('Afu'),">=",1,"code Afu exists");

is($orgload->load_accession('999','NC_999999'),1,'load_accession');

is($orgload->delete_accession('NC_999999'),1,'delete_accession');

#cmp_ok($orgload->organism_exists('Archaeoglobus fulgidus'),">=",1,'Archaeoglobus fulgidus exists');
cmp_ok($orgload->organism_exists('Archaeoglobus fulgidus'),"eq",'Afu','Archaeoglobus fulgidus exists');

is($orgload->organism_exists('Nothing'),undef,"Correctly didn't identify a missing organism");

# code, other, division, name
my @load_item =  ('Xxx', 'test', 18, 'Xbug buggy');
#my @load_item =  qw/Xxx test 18 'Xbug buggy'/;
my @load = ();
push(@load,\@load_item);
ok($orgload->load_organism(\@load),'load organism');

ok($orgload->set_extend('Xxx'),'set extend');
ok($orgload->set_pathogen('Xxx'),'set pathogen');
ok($orgload->delete_organism($load_item[0]),'delete organism');

done_testing();
