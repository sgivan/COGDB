package COGDB::Local::Organism;
# $Id: Organism.pm,v 1.3 2011/07/27 21:28:33 givans Exp $

use warnings;
use strict;
use Carp;
use lib '/home/sgivan/projects/COGDB';
use COGDB::Local::COGDB_Local;
use COGDB::Organism;
#use COGDB::Division;
use vars qw/ @ISA /;

@ISA = qw/ COGDB::Local::COGDB_Local COGDB::Organism /;

my $debug = 0;
my $connection_req = 0;

if ($debug) {
  open(LOG,">>/home/sgivan/log/COGDB.Local.Organism.log") or die "can't open COGDB.Local.Organism.log";
  print LOG "\n\n\n", "+" x 50, "\n", scalar(localtime()), "\n\n";
}

return 1;


sub new {
  my ($pkg,$params,$cgrbdb) = @_;
  print LOG $pkg->stack() if ($debug);

  my $self = $pkg->SUPER::new($params,$cgrbdb);

  if ($params->{ID}) {
    if ($params->{ID} =~ /[0-9]/) {
 #    print "\ninitializing COGDB::Organism with ID = '", $params->{ID}, "'\n";
     $self->_init($params->{ID});
    }
  } elsif ($params->{Code}) {
 #   print "\ninitializing COGDB::Organism with Code\n";
    my $id = $self->code_to_id($params->{Code});
    $self->_init($id) if ($id);
  }


#   if ($params->{ID}) {
#     $self->_init($params->{ID});
#   } elsif ($params->{Code}) {
#     my $id = $self->code_to_id($params->{Code});
#     $self->_init($id) if ($id);
#   }

  return $self;
}

 sub _init {
   my ($self,$id) = @_;
   print LOG $self->stack() if ($debug);

  if (!$self->master()) {
#    print "it's necessary to create a new master\n";
    $self->master($self->create_master());
  } else {
    ++$connection_req;
#    print "retrieving pre-existing master ($connection_req)\n";
  }
  


   my $fetch = $self->SUPER::_init({ID => $id, Table => 'COGDB_Local.Organism'});
   my $data = $fetch->[0];

   if ($id) {
     $self->id($data->[0]);
     $self->code($data->[1]);
     $self->name($data->[2]);
     $self->description($data->[3]);
#     $self->division({Name => $data->[4]});
     $self->division($self->SUPER::division({Name => $data->[4]}));
     $self->other($data->[5]);
     $self->id_local($data->[6]);

#     my $cogdb = $self->master();
#     $self->cog($cogdb->cog({ ID => $fetch->[0]->[3], _cgrbdb => $cogdb->cgrbdb() }));


   }


 }

sub id_local {
  my ($self,$id) = @_;
  print LOG $self->stack() if ($debug);

  $id ? $self->_set_id_local($id) : $self->_get_id_local();
}

sub _set_id_local {
  my ($self,$id) = @_;
  print LOG $self->stack() if ($debug);

  $self->_set('_id_local',$id);
  return $self->_get('_id_local');
}

sub _get_id_local {
  my $self = shift;
  print LOG $self->stack() if ($debug);

  return $self->_get('_id_local');
}

# sub division {
#   my ($self,$param) = @_;
#   print LOG $self->stack() if ($debug);

#   if ($param) {

#     eval {
#       require COGDB::Local::Division;
#     };
#     if ($@) {
#       print LOG "can't load COGDB::Local::Division:  $@" if ($debug);
#       return undef;
#     }

#     my $division = COGDB::Local::Division->new({Name => $param},$self->cgrbdb());
#     $self->_set('_Division',$division);
#   } else {
#     return $self->_get('_Division');
#   }
# }

# sub code {
#   my ($self,$code) = @_;
#   print LOG $self->stack() if ($debug);

#   $code ? $self->_set_code($code) : $self->_get_code();

# }

# sub _get_code {
#   my $self = shift;
#   print LOG $self->stack() if ($debug);
#   return $self->{_Code};
# }

# sub _set_code {
#   my ($self,$code) = @_;
#   print LOG $self->stack() if ($debug);

#   $self->{_Code} = $code;
#   return $self->{_Code};
# }

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

 sub other {
   my ($self,$other) = @_;
   print LOG $self->stack() if ($debug);
#
   $other ? $self->_set_other($other) : $self->_get_other();
 }
#
 sub _get_other {
   my $self = shift;
   print LOG $self->stack() if ($debug);
   return $self->{_Other};
 }
#
 sub _set_other {
   my ($self,$other) = @_;
   print LOG $self->stack() if ($debug);
#
   $self->{_Other} = $other;
   return $self->{_Other};
 }
#
# sub fetch_all {
#   my $self = shift;
#   print LOG $self->stack() if ($debug);

#   my $query = "select ID from Organism";
#   my $fetch = $self->fetch($query);
#   my @rtn;

#   foreach my $row (@$fetch) {
#     push(@rtn,$self->organism({ID => $row->[0]},$self->cgrbdb()));
#   }
#   return \@rtn;
# }

# sub code_to_id {
#   my ($self,$code) = @_;
#   print LOG $self->stack() if ($debug);
#   my $cgrbdb = $self->cgrbdb();
#   my $dbh = $cgrbdb->dbh();
#   my $id = '';

#   if ($code) {
#     my $query = "select ID from Organism where Code = '$code'";
#     my $fetch = $self->fetch($query);
#     $id = $fetch->[0]->[0];
#   }
#   return $id;
# }

# sub fetch_by_division {
#   my ($self,$division) = @_;
#   print LOG $self->stack() if ($debug);
#   return undef unless ($division);
#   my @rtn;

#   my $orgs = $self->fetch_all();
#   foreach my $organism (@$orgs) {
#     push(@rtn,$organism) if ($organism->division() eq $division);
#   }
#   return \@rtn;
# }
