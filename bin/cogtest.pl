#!/usr/bin/env perl

# $Id$

use warnings;
use strict;
use Carp;
use FindBin qw/ $Bin /;
use lib "$Bin/../lib";
#use lib '/home/sgivan/projects/COGDB';
use COGDB;

my $cogdb;

#my $localcogdb = COGDB->new()->localcogs();
#$cogdb = COGDB->new();
$cogdb = COGDB->new()->localcogs();
my $division = $cogdb->division({ID => 11});

print "\$cogdb is a '", ref($cogdb), "'\n";

#my $whogdb = $localcogdb->whog();
my $whogdb = $cogdb->whog();
print "\$whogdb is a '", ref($whogdb), "'\n";
print "table = '", $whogdb->table(), "'\n";

#my $org_obj = $localcogdb->organism();
my $org_obj = $cogdb->organism();
print "\$org_obj is a '", ref($org_obj), "'\n";

#my $orgs = $org_obj->fetch_all();
my $orgs = $org_obj->fetch_by_division($division);
print "\$orgs is a '", ref($orgs), "'\n";
if (ref($orgs) eq 'ARRAY') {
    print "array length: '" . scalar(@$orgs) . "'\n";
}

my $cnt = 0;
foreach my $org (@$orgs) {
    print "\$org isa '" . ref($org) . "'\n";
  print "organism name: ", $org->name(), " [id=", $org->id(), "]\n";
  print "\tdivision: ", $org->division()->name(), " [id=", $org->division->id(), "]\n";
}

my $organism = $orgs->[0];
print "\$organism is a '", ref($organism), "'\n";
print "organism name: '", $organism->name(), "'\n";

#  my $whogs = $whogdb->fetch_by_organism($organism);
#  print "\$whogs is a '", ref($whogs), "'\n";

#  for (my $i = 0; $i < 50; ++$i) {
#    my $whog = $whogs->[$i];
#    print "whog id: '", $whog->id(), "', name: '", $whog->name(), "', COG: '",$whog->cog()->description(), "'\n";
#  }

#my $cog = $cogdb->cog({ID => 2429});
my $cog = $cogdb->cog({ID => 3149});
print "\$cog is a '", ref($cog), "'\n";

my $whog = $whogdb->fetch_by_whog({cog => $cog, organism => $organism});

print "\$whog is a '", ref($whog), "'\n";
print "whog ID = " . $whog->[0]->id() . "; whog name = '", $whog->[0]->name(), "'\n";

print "table = '", $whogdb->table(), "'\n\n\n";

print "Coverage by Division:\n";
  my $coverage = $whogdb->coverage_by_division({ cog => $cog, division => $division });
   print "coverage = '", scalar(@$coverage), "'\n" if ($coverage);
   foreach my $org (sort { $a->id() <=> $b->id() } @$coverage) {
     print "\t'" . $org->name() . "'\n";
#     print "\t'" . ref($org) . "'\n";
   }

 my $absent = $whogdb->fetch_absent_cogs($organism);

 my $abs_len = scalar(@$absent);

 if ($abs_len) {
   print "# absent COGs: $abs_len\n";
   foreach my $cog (@$absent) {
     print "\t", ref($cog), ", name: ", $cog->name(), " ", $cog->description(), "\n";
   }
 }

my $divisions = $cogdb->division()->fetch_all();
foreach my $div (@$divisions) {
  print "division: ", $div->name(), "\n";
}
