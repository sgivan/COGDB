package COGDB_Load;

# $Id

use warnings;
use strict;
use Carp;
use COGDB;
use vars qw/ @ISA /;
@ISA = qw/ COGDB /;

my $debug = 0;

if ($debug) {
  open(LOG,">>/home/sgivan/log/CODB_Load.log") or die "can't open COGDB_Load.log: $!";
  print LOG "\n\n\n", "+" x 50, "\n", scalar(localtime()), "\n\n";
}

return 1;

sub new {
  my ($pkg) = shift;

  my $self = $pkg->SUPER::new();

  return $self;
}

sub category {
  my $self = shift;
  print LOG $self->stack() if ($debug);

  eval {
    require COGDB_Load::Category;
  };
  if ($@) {
    die "can't find COGDB_Load::Category: $@";
  }

  my $cat = COGDB_Load::Category->new();
  return $cat;
}

sub organism {
  my $self = shift;
  print LOG $self->stack() if ($debug);

  eval {
    require COGDB_Load::Organism;
  };
  if ($@) {
    die "can't find COGDB_Load::Organism: $@";
  }

  my $org = COGDB_Load::Organism->new();
  return $org;
}

sub division {
  my $self = shift;
  print LOG $self->stack() if ($debug);

  eval {
    require COGDB_Load::Division;
  };
  if ($@) {
    die "can't find COGDB_Load::Division $@";
  }

  my $org = COGDB_Load::Division->new();
  return $org;
}

sub cog {
  my $self = shift;
  print LOG $self->stack() if ($debug);

  eval {
    require COGDB_Load::COG;
  };
  if ($@) {
    print "can't load COGDB_Load::COG.pm: $@\n";
  }

  my $cog = COGDB_Load::COG->new();
  return $cog;
}

sub whog {
  my ($self,$cgrbdb) = @_;
  print LOG $self->stack() if ($debug);

  eval {
    require COGDB_Load::Whog;
  };
  if ($@) {
    print "can't load COGDB_Load::Whog.pm: $@\n";
  }

#  my $whog = COGDB_Load::Whog->new({ _local => $self->{_local} });
  my $whog = COGDB_Load::Whog->new({ _local => $self->local() });
  return $whog;
}

sub localcog_load {
  my $self = shift;
  print LOG $self->stack() if ($debug);

#  $self->local($self->localcogs());
  $self->localcogs();

#   my $localcogs = $self->localcogs();
#   $self->{_local} = $localcogs;
#   return $localcogs;
}
