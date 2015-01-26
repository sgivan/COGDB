package COGDB::Local::Whog;

# $Id: Whog.pm,v 1.5 2006/11/16 16:53:43 givans Exp $

use warnings;
use strict;
use Carp;
use lib '/home/sgivan/projects/COGDB';
use COGDB::Local::COGDB_Local;
use COGDB::Whog;
#use COGDB;
use vars qw/ @ISA /;
#@ISA = qw/ COGDB::COGDB_Local COGDB::Whog /;
@ISA = qw/ COGDB::Local::COGDB_Local COGDB::Whog /;

my $debug = 0;
my $connection_req = 0;

if ($debug) {
  open(LOG,">>/home/sgivan/log/COGDB.Local.Whog.log") or die "can't open COGDB.Whog.log: $!";
  print LOG "\n\n\n", "+" x 50, "\n", scalar(localtime()), "\n\n";
}

return 1;


sub new {
  my ($pkg,$params,$cgrbdb) = @_;
  print LOG $pkg->stack() if ($debug);

  my $self = $pkg->SUPER::new($params,$cgrbdb);

  if ($params->{ID}) {
#    $self->_init($params->{ID},$params->{Table});
    $self->_init($params->{ID});
  }

  $self->table('COGDB_Local.Whog');

  return $self;
}

sub _init {
  my ($self,$id,$table) = @_;
  print LOG $self->stack() if ($debug);
#  $table = 'COGDB_Local.Whog' unless ($table);
  $self->table('COGDB_Local.Whog');
#  print "\$self is a '", ref($self), "'\n";
#  print "XX table = ", $self->table(), "\n";
  if (!$self->master()) {
    $self->master($self->create_master());
  } else {
    ++$connection_req;
  }
  
#  my $fetch = $self->SUPER::_init({ID => $id, Table => $table});
#  my $fetch = $self->SUPER::_init({ID => $id, Table => 'COGDB_Local.Whog'});
  my $fetch = $self->SUPER::_init({ID => $id, Table => $self->table()});

  if ($id) {
    $self->id($fetch->[0]->[0]);
    $self->name($fetch->[0]->[1]);
#    $self->organism($self->SUPER::organism({ID => $fetch->[0]->[2]}));
    $self->source($self->organism({ID => $fetch->[0]->[2]}));
    $self->novel($fetch->[0]->[5]);

    my $cogdb = $self->master();
    $self->cog($cogdb->cog({ ID => $fetch->[0]->[3], _cgrbdb => $cogdb->cgrbdb() }));

  }
}

 sub source {
   my ($self,$organism) = @_;
   print LOG $self->stack() if ($debug);
 
   $organism ? $self->_set_organism($organism) : $self->_get_organism();
 }
 
 sub _get_organism {
   my ($self) = @_;
   print LOG $self->stack() if ($debug);
   return $self->_get('_Organism');
 }
 
 sub _set_organism {
   my ($self,$organism) = @_;
   print LOG $self->stack() if ($debug);
 
   return $self->_set('_Organism',$organism);
 }



#  sub organism {
#    my ($self,$organism) = @_;
#    print LOG $self->stack() if ($debug);
 
#    $organism ? $self->_set_organism($organism) : $self->_get_organism();
#  }
 
#  sub _get_organism {
#    my ($self) = @_;
#    print LOG $self->stack() if ($debug);
#    return $self->{_Organism};
#  }
 
#  sub _set_organism {
#    my ($self,$organism) = @_;
#    print LOG $self->stack() if ($debug);
 
#    $self->{_Organism} = $organism;
#    return $self->{_Organism};
#  }
 
 sub cog {
   my ($self,$cog) = @_;
   print LOG $self->stack() if ($debug);
# 
   $cog ? $self->_set_cog($cog) : $self->_get_cog();
 }
# 
 sub _get_cog {
   my $self = shift;
   print LOG $self->stack() if ($debug);
   return $self->{_Cog};
 }
# 
 sub _set_cog {
   my ($self,$cog) = @_;
   print LOG $self->stack() if ($debug);
# 
   $self->{_Cog} = $cog;
   return $self->{_Cog};
 }

sub novel {
  my ($self,$novel) = @_;
  print LOG $self->stack() if ($debug);

  $novel ? $self->_set_novel($novel) : $self->_get_novel();
}

sub _get_novel {
  my $self = shift;
  print LOG $self->stack() if ($debug);

    return $self->{_novel};
}

sub _set_novel {
  my ($self,$novel) = @_;
  print LOG $self->stack() if ($debug);

  $self->{_novel} = $novel;
  return $self->{_novel};
}

sub fetch_by_organism {
  my ($self,$organism) = @_;
  print LOG $self->stack() if ($debug);
#  return undef unless (ref($organism) eq 'COGDB::Organism' || ref($organism) eq 'COGDB::Local::Organism');
  return undef unless ($organism->isa('COGDB::Organism'));
  my $cgrbdb = $self->cgrbdb();
  my $dbh = $cgrbdb->dbh();

  my @whogs;

  my $sth = $dbh->prepare("select ID from Whog where ID_Organism = ?");
  $sth->bind_param(1,$organism->id());
  my $rtn = $cgrbdb->dbAction($dbh,$sth,2);

#  print "\n\n\$self isa ", ref($self), "\n\$sth isa ", ref($sth), "\n\$dbh isa ", ref($dbh), "\n\n";
#  return undef;

  my $cnt = 0;
  foreach my $row (@$rtn) {
    ++$cnt;
#    print "creating whog # $cnt\n";
    push(@whogs,$self->whog({ID => $row->[0]}));
#    last;
  }
  return \@whogs;
}

sub fetch_by_cog {
  my ($self,$cog) = @_;
  print LOG $self->stack() if ($debug);
  return undef unless (ref($cog) eq 'COGDB::COG');
  my $cgrbdb = $self->cgrbdb();
  my $dbh = $cgrbdb->dbh();

  my @whogs;

  my $sth = $dbh->prepare("select ID from Whog where ID_COG = ?");
  $sth->bind_param(1,$cog->id());
  my $rtn = $cgrbdb->dbAction($dbh,$sth,2);

  foreach my $row (@$rtn) {
    push(@whogs, $self->whog({ID => $row->[0]}));
  }
  return \@whogs;
}

# sub fetch_by_name {
  # my ($self,$name) = @_;
  # print LOG $self->stack() if ($debug);
  # my $cgrbdb = $self->cgrbdb();
  # my $dbh = $cgrbdb->dbh();
# 
  # my @whogs;
# 
  # my $sth = $dbh->prepare("select ID from Whog where Name = ?");
  # $sth->bind_param(1,$name);
  # my $rtn = $cgrbdb->dbAction($dbh,$sth,2);
  # my $loop = 0;
  # foreach my $row (@$rtn) {
# #    print ++$loop, "\n";
    # push(@whogs, $self->whog({ID => $row->[0]}));
  # }
  # return \@whogs;
# }

sub fetch_by_name {
  my ($self,$params) = @_;
  print LOG $self->stack() if ($debug);
  my $cgrbdb = $self->cgrbdb();
  my $dbh = $cgrbdb->dbh();
  return undef unless ($params && ref($params) eq 'HASH');
  my ($name,$organism) = ($params->{name},$params->{organism});
  return undef unless ($organism->isa('COGDB::Organism'));

  my @whogs;

  my $sth = $dbh->prepare("select ID from Whog where Name = ? and ID_Organism = ?");
  $sth->bind_param(1,$name);
  $sth->bind_param(2,$organism->id());
  my $rtn = $cgrbdb->dbAction($dbh,$sth,2);
  my $loop = 0;
  foreach my $row (@$rtn) {
#    print ++$loop, "\n";
    push(@whogs, $self->whog({ID => $row->[0]}));
  }
  return \@whogs;
}


# sub fetch_by_division {
#   my ($self,$division) = @_;
#   print LOG $self->stack() if ($debug);
#   my $cgrbdb = $self->cgrbdb();
#   my $dbh = $cgrbdb->dbh();


# }

# I think I should change the name of this to fetch_absent_cogs() and return COGDB::COG objects
#sub fetch_absent {
sub fetch_absent_cogs {
  my ($self,$organism) = @_;
  print LOG $self->stack() if ($debug);
  my $cgrbdb = $self->cgrbdb();
  my $dbh = $cgrbdb->dbh();

  my @cogs;
#  my $sth = $dbh->prepare("select ID from Whog_absent where ID_Organism = ?");
  my $sth = $dbh->prepare("select * from Whog_absent where ID_Organism = ?");
  $sth->bind_param(1,$organism->id());
  my $rtn = $cgrbdb->dbAction($dbh,$sth,2);

  foreach my $row (@$rtn) {
#    push(@whogs,$self->whog({ID => $row->[0], Table => 'Whog_absent'}));
    push(@cogs,$self->master()->cog({ID => $row->[3]}));#, Table => 'Whog_absent'}));
  }
  return \@cogs;

}

# sub fetch_by_division {
#   my ($self,$division) = @_;
#   print LOG $self->stack() if ($debug);<
#   my $cgrbdb = $self->cgrbdb();
#   my $dbh = $cgrbdb->dbh();

# #  print "\n\nfetch_by_division()\n\n";
# }


sub fetch_by_whog {
  my $self = shift;
  my $params = shift;
  print LOG $self->stack() if ($debug);

  return undef unless ($params && ref($params) eq 'HASH');
  my ($cog,$organism) = ($params->{cog},$params->{organism});
  return undef unless ($cog->isa('COGDB::COG') && $organism->isa('COGDB::Organism'));

  my $query = "select ID from `Whog` where ID_Organism = " . $organism->id() . " and ID_COG = " . $cog->id();
  print LOG "\$query = '$query'\n" if ($debug);
  my $rtn = $self->fetch($query);
  my @rtn = ();

  if ($rtn) {
    foreach my $row (@$rtn) {
      push(@rtn,$self->whog({ID => $row->[0]}));
    }
  }
  return \@rtn;
}

sub coverage_by_division {
  my $self = shift;
  my $params = shift;
  print LOG $self->stack() if ($debug);
  my $table = $self->table() || $params->{Table} || 'COGDB_Local.Whog';
  my $query;

#  return $self->SUPER::coverage_by_division($params);

  return undef unless ($params && ref($params) eq 'HASH');
  my ($cog,$division) = ($params->{cog},$params->{division});
  return undef unless ($cog->isa('COGDB::COG') && $division->isa('COGDB::Division'));

  # my $organisms =
  $self->SUPER::organism()->fetch_by_division($division); my
  $organisms = $self->organism()->fetch_by_division($division);
  $params->{organisms} = $organisms;

  return $self->SUPER::coverage_by_division($params);

#   my $len = scalar(@$organisms);
#   if ($len) {
# #    $query = "select distinct `ID_Organism` from `Whog` where (";
#     $query = "select distinct `ID_Organism` from $table where (";
#     for (my $i = 0; $i < $len; ++$i) {
#       $query .= " `ID_ORGANISM` = " . $organisms->[$i]->id();
#       $query .= " OR" unless ($i == ($len - 1));
#     }
#     $query .= ") AND `ID_COG` = " . $cog->id();
#   }
# #  print "\n\nquery: '$query'\n\n";
#   my ($rtn,@rtn) = ($self->fetch($query));
#   if ($rtn) {
#     foreach my $row (@$rtn) {
# #      push(@rtn,$self->SUPER::organism({ ID => $row->[0] }));
#       push(@rtn,$self->organism({ ID => $row->[0] }));
#     }
#   }
#   return \@rtn;
}

