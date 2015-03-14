package COGDB::Whog;

# $Id: Whog.pm,v 1.5 2006/09/29 21:07:52 givans Exp $

use warnings;
use strict;
use Carp;
use lib '/home/sgivan/projects/COGDB/lib';
use COGDB;
use vars qw/ @ISA /;
@ISA = qw/ COGDB /;

my $debug = 0;

# create cached data structures
my %cog_count = ();

if ($debug) {
  open(LOG,">>/home/sgivan/log/COGDB.Whog.log") or die "can't open COGDB.Whog.log: $!";
  print LOG "\n\n\n", "+" x 50, "\n", scalar(localtime()), "\n\n";
}

return 1;


sub new {
  my ($pkg,$params,$cgrbdb) = @_;
  print LOG $pkg->stack() if ($debug);

  my $self = $pkg->SUPER::new($params,$cgrbdb);

  if ($params->{ID}) {
    $self->_init($params->{ID});
  }
  $self->table('Whog');
  return $self;
}

sub _init {
  my ($self,$id) = @_;
  print LOG $self->stack() if ($debug);

  my $fetch = $self->SUPER::_init({ID => $id, Table => 'Whog'});

  if ($id) {
    $self->id($fetch->[0]->[0]);
    $self->name($fetch->[0]->[1]);
#    $self->source($self->SUPER::organism({ID => $fetch->[0]->[2]}));
    $self->source($self->organism({ID => $fetch->[0]->[2]}));
    $self->cog($self->SUPER::cog({ID => $fetch->[0]->[3]}));
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

# sub organism {
#   my ($self,$organism) = @_;
#   print LOG $self->stack() if ($debug);

#   $organism ? $self->_set_organism($organism) : $self->_get_organism();
# }

# sub _get_organism {
#   my ($self) = @_;
#   print LOG $self->stack() if ($debug);
#   return $self->{_Organism};
# }

# sub _set_organism {
#   my ($self,$organism) = @_;
#   print LOG $self->stack() if ($debug);

#   $self->{_Organism} = $organism;
#   return $self->{_Organism};
# }

sub cog {
  my ($self,$cog) = @_;
  print LOG $self->stack() if ($debug);

  $cog ? $self->_set_cog($cog) : $self->_get_cog();
}

sub _get_cog {
  my $self = shift;
  print LOG $self->stack() if ($debug);
  return $self->{_Cog};
}

sub _set_cog {
  my ($self,$cog) = @_;
  print LOG $self->stack() if ($debug);

  $self->{_Cog} = $cog;
  return $self->{_Cog};
}

sub fetch_by_organism {
  my ($self,$organism) = @_;
  print LOG $self->stack() if ($debug);
  return undef unless (ref($organism) eq 'COGDB::Organism');
  my $cgrbdb = $self->cgrbdb();
  my $dbh = $cgrbdb->dbh();

  my @whogs;

  my $sth = $dbh->prepare("select ID from Whog where ID_Organism = ?");
  $sth->bind_param(1,$organism->id());
  my $rtn = $cgrbdb->dbAction($dbh,$sth,2);

  foreach my $row (@$rtn) {
    push(@whogs,$self->whog({ID => $row->[0]}));
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

sub fetch_by_name {
  my ($self,$name) = @_;
  print LOG $self->stack() if ($debug);
  my $cgrbdb = $self->cgrbdb();
  my $dbh = $cgrbdb->dbh();

  my @whogs;

  my $sth = $dbh->prepare("select ID from Whog where Name = ?");
  $sth->bind_param(1,$name);
  my $rtn = $cgrbdb->dbAction($dbh,$sth,2);

  foreach my $row (@$rtn) {
    push(@whogs, $self->whog({ID => $row->[0]}));
  }
  return \@whogs;
}

sub fetch_by_division {
  my ($self,$division) = @_;
  print LOG $self->stack() if ($debug);
  my $cgrbdb = $self->cgrbdb();
  my $dbh = $cgrbdb->dbh();

}

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

#
# coverage_by_division() returns an array of COGDB::Organism or COGDB::Local::Organism objects
#
sub coverage_by_division {
  my $self = shift;
  my $params = shift;
  print LOG $self->stack() if ($debug);
  my $table = $self->table() || $params->{Table} || 'Whog';
  my $query;

  return undef unless ($params && ref($params) eq 'HASH');
  my ($cog,$division,$pathogen) = ($params->{cog},$params->{division},$params->{pathogen});
  return undef unless ($cog->isa('COGDB::COG') && $division->isa('COGDB::Division'));

#
#
#	old way
#
#

#    my @organisms = ();
#    my $all_organisms = $params->{organisms} || $self->SUPER::organism()->fetch_by_division($division,$pathogen);
#    if (!$pathogen) {
#      foreach my $org (@$all_organisms) {
#        push(@organisms,$org) if (!$org->pathogen());
#      }
#    } else {
#      @organisms = (@$all_organisms);
#    }

#    my $len = scalar(@organisms);
#    if ($len) {

#      $query = "select distinct `ID_Organism` from $table where (";
#      for (my $i = 0; $i < $len; ++$i) {
#        $query .= " `ID_ORGANISM` = " . $organisms[$i]->id();
#        $query .= " OR" unless ($i == ($len - 1));
#      }
#      $query .= ") AND `ID_COG` = " . $cog->id();
#    }


#
#
#	new way
#
#

   $query = "select distinct ID_Organism from Whog w, Organism o where w.ID_COG = " . $cog->id() . " AND w.ID_Organism = o.ID AND o.Division = " . $division->id();
   if (!$pathogen) {
     $query .= " AND o.pathogen = 0";
   }


  my ($rtn,@rtn) = ($self->fetch($query));
  if ($rtn) {
    foreach my $row (@$rtn) {
      push(@rtn,$self->organism({ ID => $row->[0] }));
    }
  }
  return \@rtn;
}

sub cog_count {
    my $self = shift;
    my $params = shift;
    print LOG $self->stack() if ($debug);
    my $table = $self->table() || $params->{Table} || 'Whog';

    return undef unless ($params && ref($params) eq 'HASH');
    my $cog = $params->{cog};
    return undef unless ($cog->isa('COGDB::COG'));

    if (defined($cog_count{$cog->id()})) {
        return $cog_count{$cog->id()};
    } else {
        my $query = "SELECT `ID_COG`, count(`ID_COG`) FROM `Whog` where `ID_COG` = " . $cog->id();
        print "$query\n" if ($debug);

        my ($rtn,@rtn) = ($self->fetch($query));
        if ($rtn) {
            $cog_count{$cog->id()} = $rtn->[0]->[1];
            return $rtn->[0]->[1];
        }
    }
   return -1;
}
