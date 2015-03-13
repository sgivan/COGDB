package COGDB::Organism;

# $Id: Organism.pm,v 1.4 2011/07/27 21:23:10 givans Exp $

use warnings;
use strict;
use Carp;
use lib '/home/sgivan/projects/COGDB/lib';
use COGDB;
use vars qw/ @ISA /;
@ISA = qw/ COGDB /;

my $debug = 0;

if ($debug) {
  open(LOG,">>/home/sgivan/log/COGDB.Organism.log") or die "can't open COGDB.Organism.log: $!";
  print LOG "\n\n\n", "+" x 50, "\n", scalar(localtime()), "\n\n";
}

return 1;


sub new {
  my ($pkg,$params,$cgrbdb) = @_;
  print LOG $pkg->stack() if ($debug);
  my $self = $pkg->SUPER::new($params,$cgrbdb);

  if ($params->{ID}) {
    if ($params->{ID} =~ /[0-9]/) {
     $self->_init($params->{ID});
    }
  } elsif ($params->{Code}) {
    my $id = $self->code_to_id($params->{Code});
    $self->_init($id) if ($id);
  }

  return $self;
}

sub _init {
  my ($self,$id) = @_;
  print LOG $self->stack() if ($debug);

  my $fetch = $self->SUPER::_init({ID => $id, Table => 'COGDB.Organism'});
  my $data = $fetch->[0];

  if ($id) {
    $self->id($data->[0]);
    $self->code($data->[1]);
    $self->name($data->[2]);
    $self->description($data->[3]);

#    division($self,$self->SUPER::division($data->[4]));
    $self->division($self->SUPER::division({ID => $data->[4]}));
#    $self->division($data->[4]);

    $self->taxid($data->[5]);
    $self->extend($data->[6]);
    $self->pathogen($data->[7]);
    $self->accession($data->[8]);
    $self->bioproject($data->[10]);
#    print "COGDB::Organism id = '", $self->id(), "'; name = '", $self->name(), "'\n";
  }
  return;

}

sub code {
  my ($self,$code) = @_;
  print LOG $self->stack() if ($debug);

  $code ? $self->_set_code($code) : $self->_get_code();

}

sub _get_code {
  my $self = shift;
  print LOG $self->stack() if ($debug);
  return $self->{_Code};
}

sub _set_code {
  my ($self,$code) = @_;
  print LOG $self->stack() if ($debug);

  $self->{_Code} = $code;
  return $self->{_Code};
}

sub division {
  my ($self,$division) = @_;
  print LOG $self->stack() if ($debug);

  $division ? $self->_set_division($division) : $self->_get_division();
}

sub _get_division {
  my $self = shift;
  print LOG $self->stack() if ($debug);

  return $self->{_Division};
}

sub _set_division {
  my ($self,$division) = @_;
  print LOG $self->stack() if ($debug);

  $self->{_Division} = $division;
  return $self->{_Division};
}

sub taxid {
  my ($self,$taxid) = @_;
  print LOG $self->stack() if ($debug);

  $taxid ? $self->_set_taxid($taxid) : $self->_get_taxid();
}

sub _get_taxid {
  my $self = shift;
  print LOG $self->stack() if ($debug);
  return $self->{_Taxid};
}

sub _set_taxid {
  my ($self,$taxid) = @_;
  print LOG $self->stack() if ($debug);

  $self->{_Taxid} = $taxid;
  return $self->{_Taxid};
}

sub extend {
  my ($self,$extend) = @_;
  print LOG $self->stack() if ($debug);

  $extend ? $self->_set_extend($extend) : $self->_get_extend();
}

sub _get_extend {
  my $self = shift;
  print LOG $self->stack() if ($debug);
  return $self->{_extend};
}

sub _set_extend {
  my ($self,$extend) = @_;
  print LOG $self->stack() if ($debug);

  $self->{_extend} = $extend;
  return $self->{_extend};
}

sub pathogen {
  my ($self,$pathogen) = @_;
  print LOG $self->stack() if ($debug);

  $pathogen ? $self->_set_pathogen($pathogen) : $self->_get_pathogen();
}

sub _get_pathogen {
  my $self = shift;
  print LOG $self->stack() if ($debug);
  return $self->{_pathogen};
}

sub _set_pathogen {
  my ($self,$pathogen) = @_;
  print LOG $self->stack() if ($debug);

  $self->{_pathogen} = $pathogen;
  return $self->{_pathogen};
}

sub accession {
  my ($self,$accession) = @_;
  print LOG $self->stack() if ($debug);

  $accession ? $self->_set_accession($accession) : $self->_get_accession();
}

sub _get_accession {
  my $self = shift;
  print LOG $self->stack() if ($debug);
  return $self->{_accession};
}

sub _set_accession {
  my ($self,$accession) = @_;
  print LOG $self->stack() if ($debug);

  $self->{_accession} = $accession;
  return $self->{_accession};
}

sub bioproject {
  my ($self,$bioproject) = @_;
  print LOG $self->stack() if ($debug);

  $bioproject ? $self->_set_bioproject($bioproject) : $self->_get_bioproject();
}

sub _get_bioproject {
  my $self = shift;
  print LOG $self->stack() if ($debug);
  return $self->{_BioProject};
}

sub _set_bioproject {
  my ($self,$bioproject) = @_;
  print LOG $self->stack() if ($debug);

  $self->{_BioProject} = $bioproject;
  return $self->{_BioProject};
}

sub fetch_all {
  my $self = shift;
  print LOG $self->stack() if ($debug);

  my $query = "select ID from Organism";
  my $fetch = $self->fetch($query);
  my @rtn;

  foreach my $row (@$fetch) {
    push(@rtn,$self->organism({ID => $row->[0]},$self->cgrbdb()));
  }
  return \@rtn;
}

sub code_to_id {
  my ($self,$code) = @_;
  print LOG $self->stack() if ($debug);
  my $cgrbdb = $self->cgrbdb();
  my $dbh = $cgrbdb->dbh();
  my $id = '';

  if ($code) {
    my $query = "select ID from Organism where Code = '$code'";
    my $fetch = $self->fetch($query);
    $id = $fetch->[0]->[0];
  }
  return $id;
}

sub fetch_by_division {
  my ($self,$division,$pathogen) = @_;
  print LOG $self->stack() if ($debug);
  return undef unless ($division);
  if (ref($division) && $division->isa('COGDB::Division')) {
    $division = $division->name();
  }
  my @rtn;

  my $orgs = $self->fetch_all();
  foreach my $organism (@$orgs) {
    next if ($organism->pathogen() && !$pathogen);
    push(@rtn,$organism) if ($organism->division()->name() eq $division);
  }

  return \@rtn;
}

