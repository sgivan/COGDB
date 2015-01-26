package COGDB::COG;

# $Id: COG.pm,v 1.6 2010/06/03 22:15:10 givans Exp $

use warnings;
use strict;
use Carp;
use lib '/home/sgivan/projects/COGDB';
use COGDB;
use vars qw/ @ISA /;
@ISA = qw/ COGDB /;

my $debug = 0;

if ($debug) {
  open(LOG,">>/home/sgivan/log/COGDB.COG.log") or die "can't open COGDB.COG.log: $!";
  print LOG "\n\n\n", "+" x 50, "\n", scalar(localtime()), "\n\n";
}

return 1;


sub new {
  my ($pkg,$params,$cgrbdb) = @_;
  print LOG $pkg->stack() if ($debug);

  my $self = $pkg->SUPER::new($params,$cgrbdb);

  if ($params->{ID}) {
    $self->_init($params->{ID});
  } elsif ($params->{Name}) {
    my $id = $self->name_to_id($params->{Name});
    $self->_init($id) if ($id);
  }

  return $self;
}

sub _init {
  my ($self,$id) = @_;
  print LOG $self->stack() if ($debug);
  print LOG "initializing COG with id = '$id'\n" if ($debug);

  my $fetch = $self->SUPER::_init({ID => $id, Table => 'COGDB.COG'});

  if ($id) {
    $self->id($id);
    $self->name($fetch->[0]->[1]);
    $self->description($fetch->[0]->[2]);
    $self->categories();
  }


}

sub name_to_id {
  my ($self,$name) = @_;
  print LOG $self->stack() if ($debug);

  my $query = "select `ID` from `COG` where `Name` = '$name'";
  my $fetch = $self->fetch($query);

  if ($fetch) {
    return $fetch->[0]->[0];
  } else {
    return undef;
  }
}

sub fetch_all {
  my $self = shift;
  print LOG $self->stack() if ($debug);

  my $query = "select `ID` from `COG`";
  my $fetch = $self->fetch($query);
  my @rtn;

  foreach my $row (@$fetch) {
    push(@rtn,$self->cog({ID => $row->[0]}));
  }
  return \@rtn;
}

sub fetch_by_category {
  my ($self,$category) = @_;
  print LOG $self->stack() if ($debug);
  my @rtn;

  my $query = "select `ID_COG` from `COG__Category` where `ID_Category` = $category";
  my $fetch = $self->fetch($query);

  foreach my $row (@$fetch) {
    push(@rtn, $self->cog({ID => $row->[0]}));
  }
  return \@rtn;
}

sub categories {
  my ($self,$cogID) = @_;
  print LOG $self->stack() if ($debug);
  $cogID = $self->id() unless ($cogID);
  my @categories = ();
  return $self->{_categories} if (defined($self->{_categories}));

  my $query = "select `ID_Category` from `COG__Category` where `ID_COG` = $cogID";
  my $fetch = $self->fetch($query);

  foreach my $catID (@$fetch) {

    push(@categories, $self->category({ID => $catID->[0]},$self->cgrbdb()));
#    push(@categories, $self->category({ID => $catID->[0]}));
  }
  $self->{_categories} = \@categories;
  return \@categories;
}

sub fetch_by_organism {

}
