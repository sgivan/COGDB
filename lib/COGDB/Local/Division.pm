package COGDB::Local::Division;

# $Id: Division.pm,v 1.3 2011/07/27 21:28:03 givans Exp $


use warnings;
use strict;
use Carp;
#use COGDB;
use lib '/home/sgivan/projects/COGDB';
use COGDB::Local::COGDB_Local;
use COGDB::Division;
use vars qw/ @ISA /;
@ISA = qw/ COGDB::Local::COGDB_Local COGDB::Division /; ## added COGDB::Division when things were working perfectly

my $debug = 1;

if ($debug) {
  open(LOG,">>/home/sgivan/log/COGDB.Local.Division.log") or die "can't open COGDB.Local.Organism.log: $!";
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
  } else {
    print LOG "\$params wasn't passed\n" if ($debug);
  }

  return $self;
}

sub _init {
  my ($self,$id) = @_;
  print LOG $self->stack() if ($debug);

  #my $fetch = $self->SUPER::_init({ID => $id, Table => 'COGDB.Division'});
  my $fetch = $self->SUPER::_init({
          ID => $id,
          #Table => $self->cgrbdb->{_dbase} . ".Division",
          Table => 'COGDB2014.Division',
      });
  my $data = $fetch->[0];

  if ($id) {
    $self->id($data->[0]);
    $self->name($data->[1]);
    print LOG "id:  ", $data->[0], ", name: ", $data->[1], "\n" if ($debug);
#    print "COGDB::Local::Division:  id:  ", $self->id(), ", name: ", $self->name(), "\n";
  }


}

sub name_to_id {
  my ($self,$name) = @_;
  my $id = '';
  print LOG $self->stack() if ($debug);
  print $self->stack() if ($debug);

  my $cgrbdb = $self->cgrbdb();
  my $dbh = $cgrbdb->dbh();
  my $table = $self->cgrbdb->{_dbase} . ".Division";

  my $newname = $self->_convert_name_to_COGDB2014($name);

  if ($newname) {
    my $query = "select ID from COGDB2014.Division where Name = '$newname'";
    #my $query = "select ID from $table where Name = '$name'";
    #print "query: '$query'\n" if ($debug);
    my $fetch = $self->fetch($query);
    $id = $fetch->[0]->[0];
  }
  print LOG "returning ID = '$id' for '$name'\n" if ($debug);
  return $id;
}

sub _convert_name_to_COGDB2014 {
    my ($self,$name) = @_;
    my $name2014 = '';
    print LOG $self->stack() if ($debug);
    print $self->stack() if ($debug);
    #print "converting old division name '$name' to 2014 division name\n" if ($debug);

    my $cgrbdb = $self->cgrbdb();
    my $dbh = $cgrbdb->dbh();
    my $table = "COGDB_Local.Division2003_To_2014";

    if ($name) {
        my $query = "Select `Name2014` from $table where `Name2003` = '$name'";
        #print "query: '$query'\n" if ($debug);
        my $fetch = $self->fetch($query);
        $name2014 = $fetch->[0]->[0];
    }
    print LOG "returning name = '$name2014'\n" if ($debug);
    #print "returning name = '$name2014'\n" if ($debug);
    return $name2014;
}

