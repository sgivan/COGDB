package COGDB::Local::COGDB_Local;
# $Id: COGDB_Local.pm,v 1.6 2011/07/27 21:25:19 givans Exp $

use warnings;
use strict;
use Carp;
use lib '/home/sgivan/projects/COGDB';
use COGDB;
use vars qw/ @ISA /;

@ISA = qw/ COGDB /;

my $debug = 0;
my $cnt = 0;

if ($debug) {
  open(LOG,">>/home/sgivan/log/COGDB_Local.log") or die "can't open COGDB_Local.log: $!";
  print LOG "\n\n\n", "+" x 50, "\n", scalar(localtime()), "\n\n";
}

return 1;

sub new {
  my ($pkg,$params) = @_;

  my $self = $pkg->SUPER::new($params);
  print LOG $self->stack() if ($debug);
  if (ref($params) !~ /HASH/) {
    print LOG "\$params is not a hash: '", ref($params), "'; '$params'\n" if ($debug);
    croak("ERROR:  \$params is not a hash");
  } else {
    print LOG "\$params is a hash\n" if ($debug);
  }

  $self->master($params->{_master}) if ($params->{_master});
  $self->cgrbdb($params->{_cgrbdb}) if ($params->{_cgrbdb});
#  $self->masterdb($params->{_masterdb} || $self->create_masterdb());

  return $self;
}

sub _init {
  my $self = shift;
  my $params = shift;
  print LOG $self->stack() if ($debug);


  my $id = $params->{ID};
  my $table = $params->{Table};
  if ($table) {
    $self->table($table);
#    print "setting table to '$table'\n";
  }

  my $query = "select * from $table";
  $query .= " where ID = $id" if ($id);
  my $fetch = $self->fetch($query);

  return $fetch;
}



sub cgrbdb {
  my ($self,$cgrbdb) = @_;
  print LOG $self->stack() if ($debug);


  if ($cgrbdb) {
    print LOG "storing a pre-existing \$cgrbdb\n" if ($debug);
    $self->{_cgrbdb} = $cgrbdb;
  } else {
#    print LOG "creating a new \$cgrbdb\n";
    if (!$self->{_cgrbdb}) {
#      $cgrbdb = CGRBDB->generate('COGDB_Local','givans','bioinfo');
      print LOG "creating a new \$cgrbdb\n" if ($debug);

#       if ($debug) {
# 	if (++$cnt >= 10) {
# #	  print LOG "exiting, \$cnt = $cnt\n";
# #	  return undef;
# 	  print LOG "\n\$cnt = $cnt\n\n";
# 	} else {
# 	  print LOG "\n\$cnt = $cnt\n\n";
# 	}
#       }


      $cgrbdb = CGRBDB->generate('COGDB_Local','cogtool','cogs');
      $self->{_cgrbdb} = $cgrbdb;
    } else {
      print LOG "returning a pre-existing \$cgrbdb\n" if ($debug);
      $cgrbdb = $self->{_cgrbdb};
    }
  }
  return $cgrbdb;
}

# sub organism {
#   my ($self,$params) = @_;
#   print LOG $self->stack() if ($debug);

#   eval {
#     require COGDB::Local::Organism;
#   };
#   if ($@) {
#     print LOG "can't load COGDB::Local::Organism: $@";
#     return undef;
#   }
#   my $obj = COGDB::Local::Organism->new($params,$self->cgrbdb());
#   return $obj;


# }

sub organism {
  my ($self,$params) = @_;
  print LOG $self->stack() if ($debug);

  eval {
    require COGDB::Local::Organism;
  };
  if ($@) {
    print LOG "can't load COGDB::Local::Organism:  $@";
    return undef;
  }
  $params->{_master} = $self->master();
  $params->{_cgrbdb} = $self->cgrbdb();
#  $params->{Table} = "COGDB_Local.Organism";

  my $organism = COGDB::Local::Organism->new($params);
  return $organism;
#  $self->SUPER::organism(@_);
}

sub division {
  my ($self,$params) = @_;
  print LOG $self->stack() if ($debug);

  eval {
    require COGDB::Local::Division;
  };
  if ($@) {
    print LOG "can't load COGDB::Local::Division:  $@";
    return undef;
  }

  $params->{_master} = $self->master();
  $params->{_cgrbdb} = $self->cgrbdb();

  my $obj = COGDB::Local::Division->new($params);
  return $obj;
}


sub whog {
  my ($self,$params) = @_;
  print LOG $self->stack() if ($debug);
  
  eval {
    require COGDB::Local::Whog;
  };
  if ($@) {
    print LOG "can't load COGDB::Local::Whog: $@";
    exit(1);
  }

  $params->{_master} = $self->master();
  $params->{_cgrbdb} = $self->cgrbdb();
#  $params->{_cgrbdb} = $self->master()->cgrbdb();

  my $whog = COGDB::Local::Whog->new($params);
  return $whog;
}

sub create_master {
  my $self = shift;
  print LOG $self->stack() if ($debug);
  
  eval {
    require COGDB;
  };
  if ($@) {
    print LOG "can't load COGDB: $@";
    exit(1);
  }
  return COGDB->new();
}

sub master {
  my ($self,$master) = @_;
  print LOG $self->stack() if ($debug);
  
  $master ? $self->_set_master($master) : $self->_get_master();
}

sub _get_master {
  my $self = shift;
  print LOG $self->stack() if ($debug);

  my $masterdb = $self->_get('_master');

  return $self->_get('_master');
}

sub _set_master {
  my ($self,$master) = @_;
  print LOG $self->stack() if ($debug);

  
  $self->_set('_master',$master);

  return $self->_get('_master');
}

sub fetch {
  my ($self,$query) = @_;
  print LOG $self->stack() if ($debug);
#   if ($debug) {
#     ++$cnt;
#     print $self->stack();
#     print "fetching # $cnt\n";
#   }
   my $cgrbdb = $self->cgrbdb();
   my $dbh = $cgrbdb->dbh();
   my ($sth,$rtn);

   $sth = $dbh->prepare($query);
   $rtn = $self->dbAction($dbh,$sth,2);
  $sth->finish();
   if ($rtn) {
     return $rtn;
   } else {
     return undef;
   }
}

