#!/bin/env perl

use warnings;
use strict;
use Carp;

# must have following statement to use COGDB modules
use lib '/ibfs3/data/sgivan/projects/COGDB';
use COGDB;

my $orgcode = $ARGV[0] || 'AB2255';
my $orfname = $ARGV[1] || 'C10_0004';

my $cogdb = COGDB->new();
print "\$cogdb isa '", ref($cogdb), "'\n";

# localcogs returns a COGDB::Local object -- this provides access to MMG genome data (versus non-MMG genomes)
my $local = $cogdb->localcogs();
print "\$local isa '", ref($local), "'\n";
my $organism = $local->organism({Code => $orgcode});

# whog() returns a COGDB::Local::Whog object
# I've taken the nomenclature from the COG project.
# The term 'whog' seems to represent the relationship ORF <-> COG
my $whogdb = $local->whog();

# fetch_by_name() returns a reference to an array of COGDB::Local::Whog objects or undef
# Here I'm fetching all the whogs associated with a specific ORF in a MMG genome -- see $orgcode and $orfname assignments above
my $whogs = $whogdb->fetch_by_name({ name => $orfname, organism => $organism });

print "organism:  ", $organism->name(), "\n";

if ($whogs) {
  #
  # an ORF may contain multiple COGs
  # ie, C134_0050 of SAR11
  #
  foreach my $whog (@$whogs) {
    my $cog = $whog->cog();# cog() returns a COGDB::COG object
    ## COGs are defined and static, they have a name and a description and are associated with funtional categories
    my $cog_categories = $cog->categories();# categories() returns a reference to an array of COGDB::Category objects

    print "orf '$orfname' is a '", $cog->name(), ":  ", $cog->description(), "'\n";
    foreach my $category (@$cog_categories) {
      print "\t'", $category->name(), "'\n";
    }
  }
}

