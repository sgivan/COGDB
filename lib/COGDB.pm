package COGDB;

# $Id: COGDB.pm,v 1.6 2006/09/28 18:54:44 givans Exp $

use warnings;
use strict;
use Carp;
#use lib '/home/cgrb/givans/dev/lib/perl5';
#use CGRB::CGRBDB;
use CGRBDB;
use vars qw/ @ISA /;

@ISA = qw/ CGRBDB /;

my $debug = 0;
my $cnt;

if ($debug) {
  open(LOG,">>/home/sgivan/log/COGDB.log") or die "can't open COGDB.log: $!";
  print LOG "\n\n\n", "+" x 50, "\n", scalar(localtime()), "\n\n";
}

return 1;

sub new {
  my ($pkg,$params,$cgrbdb) = @_;
  print LOG stack() if ($debug);

  my $self = {};

  bless $self, $pkg;

  $self->cgrbdb($cgrbdb) if ($cgrbdb);

  return $self;

}

sub _init {
  my $self = shift;
  my $params = shift;

  my $id = $params->{ID};
  my $table = $params->{Table};
  $self->table($table);
  print LOG $self->stack() if ($debug);

  my $query = "select * from $table";
  $query .= " where ID = $id" if ($id);
  my $fetch = $self->fetch($query);

#   if ($id) {
#     $self->id($id);
#     $self->name($fetch->[0]->[1]);
#     $self->description($fetch->[0]->[1]);
#   }
  return $fetch;
}

#################################################################
#								#
# If possible, I want to reuse an existing DB connection	#
#								#
# cgrbdb() either creates a new connection			#
# or reuses an existing connection.				#
#								#
#################################################################

sub cgrbdb {
  my ($self,$cgrbdb) = @_;

  if ($cgrbdb) {
    $self->{_cgrbdb} = $cgrbdb;
  } else {
    if (!$self->{_cgrbdb}) {
#      print "\n\nWHOA! -- ", ++$cnt, "\n", $self->stack(), "\n\n";
       $cgrbdb = CGRBDB->generate('COGDB2014','cogtool','cogs');
#      $cgrbdb = CGRBDB->generate('COGDB','cogtool','cogs');
      $self->{_cgrbdb} = $cgrbdb;
    } else {
      $cgrbdb = $self->{_cgrbdb};
    }
  }
  return $cgrbdb;
}

sub id {
  my ($self,$id) = @_;
  print LOG $self->stack() if ($debug);

  $id ? $self->_set_id($id) : $self->_get_id();
}

sub _get_id {
  my ($self) = @_;
  print LOG $self->stack() if ($debug);

  return $self->_get('ID');
}

sub _set_id {
  my ($self,$id) = @_;
  print LOG $self->stack() if ($debug);

  return $self->_set('ID',$id);
}

sub name {
  my ($self,$name) = @_;
  print LOG $self->stack() if ($debug);

  $name ? $self->_set_name($name) : $self->_get_name();
}

sub _get_name {
  my $self = shift;
  print LOG $self->stack() if ($debug);

  return $self->_get('Name');
}

sub _set_name {
  my ($self,$name) = @_;
  print LOG $self->stack() if ($debug);

  return $self->_set('Name',$name);
}

sub description {
  my ($self,$description) = @_;
  print LOG $self->stack() if ($debug);

  $description ? $self->_set_description($description) : $self->_get_description();
}

sub _get_description {
  my $self = shift;
  print LOG $self->stack() if ($debug);

  return $self->_get('Description');
}

sub _set_description {
  my ($self,$description) = @_;
  print LOG $self->stack() if ($debug);

  return $self->_set('Description',$description);
}

sub table {
  my ($self,$table) = @_;
  print LOG $self->stack() if ($debug);

  $table ? $self->_set_table($table) : $self->_get_table();
}

sub _set_table {
  my ($self,$table) = @_;
  print LOG $self->stack() if ($debug);

  return $self->_set('Table',$table);
}

sub _get_table {
  my $self = shift;
  print LOG $self->stack() if ($debug);

  return $self->_get('Table');
}


sub super_category {
  my ($self,$params) = @_;
  print LOG $self->stack() if ($debug);

  eval {
    require COGDB::SuperCategory;
  };
  if ($@) {
    print LOG "can't load COGDB::SuperCategory: $@";
    return undef;
  }
  
  my $obj = COGDB::SuperCategory->new({ID => $params});
  return $obj;
}

sub category {
  my ($self,$params,$cgrbdb) = @_;
  print LOG $self->stack() if ($debug);

  eval {
    require COGDB::Category;
  };
  if ($@) {
    print LOG "can't load COGDB::Category: $@";
    return undef;
  }
  my $obj = COGDB::Category->new($params,$cgrbdb);
  return $obj;

}

sub organism {
  my ($self,$params) = @_;
  print LOG $self->stack() if ($debug);

  eval {
    require COGDB::Organism;
  };
  if ($@) {
    print LOG "can't load COGDB::Organism: $@";
    return undef;
  }

  my $obj = COGDB::Organism->new($params,$self->cgrbdb());
  return $obj;

}

sub division {
  my ($self,$params) = @_;
  print LOG $self->stack() if ($debug);

  eval {
    require COGDB::Division;
  };
  if ($@) {
    print LOG "can't load COGDB::Division:  $@";
    return undef;
  }
  my $obj = COGDB::Division->new($params,$self->cgrbdb());
  return $obj;
}

sub cog {
  my ($self,$params) = @_;
  print LOG $self->stack() if ($debug);

  eval {
    require COGDB::COG;
  };
  if ($@) {
    print LOG "can't load COGDB::COG: $@";
    return undef;
  }
  my $obj = COGDB::COG->new($params, $params->{_cgrbdb} || $self->cgrbdb());
  return $obj;

}

sub whog {
  my ($self,$params) = @_;
  print LOG $self->stack() if ($debug);
  #print "this is a local whog call\n" if ($self->local());
  eval {
    require COGDB::Whog;
  };
  if ($@) {
    print LOG "can't load COGDB::Whog: $@";
    return undef;
  }
  my $obj = COGDB::Whog->new($params,$self->cgrbdb());
  return $obj;

}

sub localcogs {
  my ($self,$params) = @_;
  print LOG $self->stack() if ($debug);

  eval {
    require COGDB::Local::COGDB_Local;
    };
  if ($@) {
    print LOG "can't load COGDB::Local::COGDB_Local: $@";
    return undef;
  }

  $params->{_master} = $self;
  my $obj = COGDB::Local::COGDB_Local->new($params);
  $self->local($obj);
  return $obj;
}

sub local {
  my ($self,$value) = @_;
  print LOG $self->stack() if ($debug);

  $value ? $self->_set_local($value) : $self->_get_local();

}

sub _get_local {
  my $self = shift;
  print LOG $self->stack() if ($debug);

  return $self->_get('_local');
}

sub _set_local {
  my ($self,$value) = @_;
  print LOG $self->stack() if ($debug);
#  print "\$value is a ", ref($value), "\n";
#  $self->cgrbdb($value);
  return $self->_set('_local',$value);
}

sub _get {
  my ($self,$param) = @_;
  print LOG $self->stack() if ($debug);
  return $self->{$param};
}

sub _set {
  my ($self,$param,$value) = @_;
  print LOG $self->stack() if ($debug);

  $self->{$param} = $value;
  return $self->{$param};
}

sub fetch {
  my ($self,$query) = @_;
  print LOG  $self->stack() if ($debug);
  my $cgrbdb = $self->cgrbdb();
  my $dbh = $cgrbdb->dbh();
  my ($sth,$rtn);

  $sth = $dbh->prepare($query);

  $rtn = $self->dbAction($dbh,$sth,2);
  
#  print $self->stack();
#  print "query:  '$query'\n";
#  print "\$rtn is a '", $rtn->[0]->[0], "'\n";

  if ($rtn) {
    return $rtn;
  } else {
    return undef;
  }
}

sub store {
    my ($self,$query) = @_;
    print LOG  $self->stack() if ($debug);
    my $cgrbdb = $self->cgrbdb();
    my $dbh = $cgrbdb->dbh();
    my ($sth,$rtn);

    $sth = $dbh->prepare($query);

    $rtn = $self->dbAction($dbh,$sth,1);

    if ($rtn) {
        return $rtn;
    } else {
        return undef;
    }

}

sub delete {
    my ($self,$query) = @_;
    print LOG  $self->stack() if ($debug);
    my $cgrbdb = $self->cgrbdb();
    my $dbh = $cgrbdb->dbh();
    my ($sth,$rtn);

    $sth = $dbh->prepare($query);

    $rtn = $self->dbAction($dbh,$sth,4);

    if ($rtn) {
        return $rtn;
    } else {
        return undef;
    }

}

sub update {
    my ($self,$query) = @_;
    print LOG $self->stack() if ($debug);
    my $cgrbdb = $self->cgrbdb();
    my $dbh = $cgrbdb->dbh();
    my ($sth,$rtn);

    $sth = $dbh->prepare($query);

    $rtn = $self->dbAction($dbh,$sth,3);

    if ($rtn) {
        return $rtn;
    } else {
        return undef;
    }
}

#sub fetch_all {
#  my $self = shift;
#  print LOG $self->stack() if ($debug);
#  warn("not yet implemented for this class");
#}

sub stack {
  my ($p,$f,$l,$sub) = caller(1);
  return sprintf "%s\: %s, %s, %s\n", $sub, $p, $f, $l;
}

sub DESTROY {
  my $self = shift;
  print LOG $self->stack() if ($debug);
}
