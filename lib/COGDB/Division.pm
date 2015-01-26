package COGDB::Division;

# $Id: Division.pm,v 1.2 2011/07/27 21:21:43 givans Exp $


use warnings;
use strict;
use Carp;
use lib '/home/sgivan/projects/COGDB';
use COGDB;
use vars qw/ @ISA /;
@ISA = qw/ COGDB /;

my $debug = 0;

if ($debug) {
  open(LOG,">>/home/sgivan/log/COGDB.Division.log") or die "can't open COGDB.Organism.log: $!";
  print LOG "\n\n\n", "+" x 50, "\n", scalar(localtime()), "\n\n";
}

return 1;

sub new {
  my ($pkg,$params,$cgrbdb) = @_;
  print LOG $pkg->stack() if ($debug);
#  print "creating new COGDB::Division object\n";

  my $self = $pkg->SUPER::new($params,$cgrbdb);

  if ($params && ref($params) eq 'HASH') {
  
    if ($params->{ID}) {
      $self->_init($params->{ID});
    } elsif ($params->{Name}) {
      my $id = $self->name_to_id($params->{Name});
      $self->_init($id) if ($id);
    }
  } elsif ($params) {
    my $id = name_to_id($self,$params);
    $self->_init($id) if ($id);
  }

  return $self;
}

sub _init {
  my ($self,$id) = @_;
  print LOG $self->stack() if ($debug);

  my $fetch = $self->SUPER::_init({ID => $id, Table => 'COGDB.Division'});
  my $data = $fetch->[0];

  if ($id) {
    $self->id($data->[0]);
    $self->name($data->[1]);
    print LOG "id:  ", $data->[0], ", name: ", $data->[1], "\n" if ($debug);
#    print "id:  ", $self->id(), ", name: ", $self->name(), "\n";
  }


}

sub name_to_id {
  my ($self,$name) = @_;
  my $id = '';
  print LOG $self->stack() if ($debug);

  my $cgrbdb = $self->cgrbdb();
  my $dbh = $cgrbdb->dbh();

  if ($name) {
    my $query = "select ID from COGDB.Division where Name = '$name'";
    my $fetch = $self->fetch($query);
    $id = $fetch->[0]->[0];
  }
  print LOG "returning ID = '$id' for '$name'\n" if ($debug);
  return $id;
}

sub fetch_all {
  my $self = shift;
  print LOG $self->stack() if ($debug);
  my @divisions = ();

  my $query = "select `ID` from COGDB.Division";
  my $rtn = $self->fetch($query);

  if ($rtn) {
    foreach my $row (@$rtn) {
      push(@divisions,$self->division({ID => $row->[0]}));
    }
  }
  return \@divisions;
}
