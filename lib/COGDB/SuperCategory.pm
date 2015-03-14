package COGDB::SuperCategory;

# $Id: SuperCategory.pm,v 1.2 2011/07/27 21:23:45 givans Exp $

use warnings;
use strict;
use Carp;
use lib '/home/sgivan/projects/COGDB';
use COGDB;
use vars qw/ @ISA /;
@ISA = qw/ COGDB /;

my $debug = 0;

if ($debug) {
  open(LOG,">>/home/sgivan/log/COGDB.SuperCategory.log") or die "can't open COGDB.SuperCategory.log: $!";
  print LOG "\n\n\n", "+" x 50, "\n", scalar(localtime()), "\n\n";
}

return 1;


sub new {
  my ($pkg,$params) = @_;
  print LOG $pkg->stack() if ($debug);

  my $self = $pkg->SUPER::new($params);

  if ($params->{ID}) {
    $self->_init($params->{ID});
  }

  return $self;
}

sub _init {
  my ($self,$id) = @_;
  print LOG $self->stack() if ($debug);

  my $fetch = $self->SUPER::_init({ID => $id, Table => 'SuperCategory'});

  if ($id) {
    $self->id($id);
    $self->name($fetch->[0]->[1]);
    $self->description($fetch->[0]->[1]);
  }


}

sub fetch_all {
  my $self = shift;
  print LOG $self->stack() if ($debug);

  my $query = "select ID from SuperCategory";
  my $fetch = $self->fetch($query);
  my @rtn;

  foreach my $row (@$fetch) {
    push(@rtn,$self->super_category($row->[0]));
  }
  return \@rtn;
}

