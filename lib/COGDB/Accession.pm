package COGDB::Accession;
#
#===============================================================================
#
#         FILE:  Accession.pm
#
#  DESCRIPTION:  Module to represent the Accession table in COGDB
#                   Each organism in COGDB has a corresponding genome sequence
#                   that is identified by at least one NCBI accession number.
#                   This module represents that relationship.
#
#        FILES:  ---
#         BUGS:  ---
#        NOTES:  ---
#       AUTHOR:  Dr. Scott Givan (sag), givans@missouri.edu
#      COMPANY:  University of Missouri, USA
#      VERSION:  1.0
#      CREATED:  07/11/14 13:51:14
#     REVISION:  ---
#===============================================================================

use 5.010;       # use at least perl version 5.10
use strict;
use warnings;
use autodie;
use Carp;
use lib '/home/sgivan/projects/COGDB/lib';
use COGDB;
use vars qw/ @ISA /;
@ISA = qw/ COGDB /;

my $debug = 0;

if ($debug) {
  open(LOG,">>/home/sgivan/log/COGDB.Accessionlog") or die "can't open COGDB.Accession.log: $!";
  print LOG "\n\n\n", "+" x 50, "\n", scalar(localtime()), "\n\n";
}

1;

sub new {
  my ($pkg,$params,$cgrbdb) = @_;
  print LOG $pkg->stack() if ($debug);
  my $self = $pkg->SUPER::new($params,$cgrbdb);

  if ($params->{orgID}) {
    if ($params->{orgID} =~ /[0-9]/) {
        $self->_set('orgID',$params->{orgID});
        $self->_init($params->{orgID});
    }
#  } elsif ($params->{OrgID}) {
#    my $id = $self->OrgID_to_id($params->{Code});
#    $self->_init($id) if ($id);
  }

  return $self;
}

sub _init {
    my ($self,$id) = @_;
    print LOG $self->stack() if ($debug);

    my $accessions = $self->accessions_by_OrgID($id);
    $self->_set('accessions',$accessions);
}

sub accessions {
    my $self = shift;

    return $self->_get('accessions');
}

sub exists {
    my ($self,$acc_query) = @_;
    return undef unless ($acc_query);

    my $fetch = $self->fetch("select `ID` from Accessions where `Accession` = '$acc_query'");

    for my $row (@$fetch) {
        return $row->[0];
        last;
    }
}

sub OrgID_by_accession {
    my ($self,$acc_query) = @_;

    my $fetch = $self->fetch("select `OrgID` from Accessions where `Accession` = '$acc_query'");

    for my $row (@$fetch) {
        return $row->[0];
        last;
    }
}

sub accessions_by_OrgID {
    my ($self,$OrgID_query) = @_;
    my @accessions = ();

    my $fetch = $self->fetch("select `Accession` from Accessions where `OrgID` = '$OrgID_query'");

    for my $row (@$fetch) {
        push(@accessions,$row->[0]);
    }
    return \@accessions;
}
