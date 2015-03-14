package COGDB::Category;

# $Id: Category.pm,v 1.3 2006/09/28 18:53:57 givans Exp $

use warnings;
use strict;
use Carp;
use lib '/home/sgivan/projects/COGDB/lib';
use COGDB;
use vars qw/ @ISA /;
@ISA = qw/ COGDB /;

my $debug = 0;

if ($debug) {
  open(LOG,">>/home/sgivan/log/COGDB.Category.log") or die "can't open COGDB.Category.log: $!";
  print LOG "\n\n\n", "+" x 50, "\n", scalar(localtime()), "\n\n";
}

return 1;


sub new {
  my ($pkg,$params,$cgrbdb) = @_;
  print LOG $pkg->stack() if ($debug);

  my $self = $pkg->SUPER::new($params,$cgrbdb);

  if ($params->{ID}) {
    $self->_init($params->{ID});
  } elsif ($params->{Code}) {
    my $id = $self->code_to_id($params->{Code});
    $self->_init($id) if ($id);
  }

  return $self;
}

sub _init {
  my ($self,$id) = @_;
  print LOG $self->stack() if ($debug);

  my $fetch = $self->SUPER::_init({ID => $id, Table => 'Category'});
  my $data = $fetch->[0];

  if ($data) {
    $self->id($data->[0]);
    $self->code($data->[1]);
    $self->name($data->[2]);
    $self->description($data->[3]);
    $self->id_super($data->[4]);
  }

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

sub _get_description {
  my $self = shift;
  return $self->name();
}
sub id_super {
  my ($self,$id_super) = @_;
  print LOG $self->stack() if ($debug);

  $id_super ? $self->_set_id_super($id_super) : $self->_get_id_super();
}

sub _get_id_super {
  my $self = shift;
  print LOG $self->stack() if ($debug);
  return $self->{_ID_Super};
}

sub _set_id_super {
  my ($self,$id_super) = @_;
  print LOG $self->stack() if ($debug);

  $self->{_ID_Super} = $id_super;
  return $self->{_ID_Super};
}

sub fetch_all {
  my $self = shift;
  print LOG $self->stack() if ($debug);

  my $query = "select ID from Category";
  my $fetch = $self->fetch($query);
  my @rtn;

  foreach my $row (@$fetch) {
    push(@rtn,$self->category({ID => $row->[0]}));
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
    my $query = "select `ID` from Category where `Code` = '$code'";
    my $fetch = $self->fetch($query);
    $id = $fetch->[0]->[0];
  }
  return $id;
}

