package COGDB_Load::Whog;

# $Id: Whog.pm,v 1.3 2008/08/15 16:10:35 givans Exp $

use warnings;
use strict;
use Carp;
use lib '/home/sgivan/projects/COGDB';
use COGDB;
use vars qw/ @ISA /;
@ISA = qw/ COGDB /;

my $debug = 0;
my $db = 1;## whether the database should actually be modified
$| = 1;
if ($debug) {
  open(LOG,">>/home/sgivan/log/COGDB_Load.Whog.log") or die "can't open COGDB_Load.COG.log: $!";
  print LOG "\n\n\n", "+" x 50, "\n", scalar(localtime()), "\n\n";
}


return 1;


sub new {
  my ($pkg,$params) = @_;

  my $self = {};

  bless $self, $pkg;

  if ($params->{_local}) {
#    print "this is a local db load\n";
    $self->local($params->{_local});
  }

  return $self;
}

sub parse_file {
  my ($self,$file) = @_;
  print LOG $self->stack() if ($debug);
  my ($cog,$organism,@whog);
#  print "parsing for a local db:  ", ref($self->local()), "\n" if ($self->local());
  open(IN,$file) or die "can't open $file: $!";
  my $cnt = 0;
  while (<IN>) {
    my $line = $_;
    next unless ($line =~ /\w/);

    chomp($line);
    if ($line =~ /^\[\w+\]\s(COG\d+)\s/) {
      $cog = $self->cog({Name => $1});
      #} elsif ( $line =~ /\s+([\w-]{3,11})\:(\s+.+)/ ) {
    } elsif ( $line =~ /\s+([\w-]{3,255})\:(\s+.+)/ ) {

      if ($self->local()) {
        $organism = $self->local()->organism({Code => $1});
      } else {
        $organism = $self->organism({Code => $1});
      }

      my $ids = $self->get_identifiers($2);

      foreach my $id (@$ids) {
	push(@whog,[$id, $organism->id(), $cog->id()]);
      }

    } elsif ($line =~ /\s+\S+/) {

      my $ids = $self->get_identifiers($line);

      foreach my $id (@$ids) {
	push(@whog,[$id, $organism->id(), $cog->id()]);
      }

    } elsif ($line =~ /^_/) {
#      print "loading\n";
    } else {
      print "weird line: '$line'\n";
    }
#    last;
  }
  $self->load_whog(\@whog);
  return scalar(@whog);
}

#  sub load_whog {
#    my ($self,$whogs) = @_;


#    $self->local() ? $self->_load_whog_local($whogs) : $self->_load_whog($whogs);
#  }

sub load_whog {
  my ($self,$whogs) = @_;
  print LOG $self->stack() if ($debug);
  my $cgrbdb = $self->local() ? $self->local()->cgrbdb() : $self->cgrbdb();
  my $dbh = $cgrbdb->dbh();

  foreach my $data (@$whogs) {
      #print "Name:  '$data->[0]', OrgID:  '$data->[1]', COGID:  '$data->[2]'\n";
    if ($db) {
      my $sth = $dbh->prepare("insert into Whog (Name, ID_Organism, ID_COG) values (?, ?, ?)");
      $sth->bind_param(1,$data->[0]);
      $sth->bind_param(2,$data->[1]);
      $sth->bind_param(3,$data->[2]);
       my $rtn = $cgrbdb->dbAction($dbh,$sth,1);
#       if ($rtn) {
#           print "rtn:  ", $rtn->[0]->[0], "\n";
#       }
    }
  }
}

# sub _load_whog_local {
#   my ($self,$whogs) = @_;
#   print LOG $self->stack() if ($debug);
#   my $cgrbdb = $self->cgrbdb();
#   my $dbh = $cgrbdb->dbh();

#   foreach my $data (@$whogs) {
#     print "Name:  '$data->[0]', OrgID:  '$data->[1]', COGID:  '$data->[2]'\n";
#     if ($db) {
#       my $sth = $dbh->prepare("insert into Whog (Name, ID_Organism, ID_COG) values (?, ?, ?)");
#       $sth->bind_param(1,$data->[0]);
#       $sth->bind_param(2,$data->[1]);
#       $sth->bind_param(3,$data->[2]);
#       my $rtn = $cgrbdb->dbAction($dbh,$sth,1);
#       if ($rtn) {
# 	print "rtn:  ", $rtn->[0]->[0], "\n";
#       }
#     }
#   }
# }


sub get_identifiers {
  my ($self,$string) = @_;
  print LOG $self->stack() if ($debug);
  my @ids = ();

  @ids = $string =~ /(\S+)/g;
  return \@ids;
}

sub novel {
  my ($self,$params) = @_;
  my $organism = $params->{organism};
  my $cog = $params->{cog};

  if ($organism && $cog) {
    $self->_set_novel($organism,$cog);
  }

}

sub _set_novel {
  my ($self,$organism,$cog) = @_;
#  my $dbh = $self->cgrbdb()->dbh();
#  print "\$dbh is a ", ref($dbh), "\n";
  my $org_id = $organism->id();
  my $cog_id = $cog->id();
  my $cgrbdb = $self->local() ? $self->local()->cgrbdb() : $self->cgrbdb();
  my $dbh = $cgrbdb->dbh();

#  print "update Whog set Novel = 1 where ID_Organism = $org_id AND ID_COG = $cog_id\n";

  my $sth = $dbh->prepare("update Whog set Novel = 1 where ID_Organism = $org_id AND ID_COG = $cog_id");
  my $rslt = $cgrbdb->dbAction($dbh,$sth,3);
  return $rslt;

}

sub parse_missing {
   my ($self,$file,$organism) = @_;
   my @cogs = ();

   open(IN,$file) or die "can't open '$file': $!";
   foreach my $line (<IN>) {
     my ($cogname,$cogid) = split /\t/, $line;
     chomp($cogid);

     my $cog = $self->cog({ ID => $cogid });
     push(@cogs,$cog);
     print "setting '$cogname' ('$cogid') ", $cog->description(), " to missing\n";
   }
   close(IN);

   $self->load_missing(\@cogs,$organism);
}

sub load_missing {
  my ($self,$cogs,$organism) = @_;
  my $cgrbdb = $self->local() ? $self->local()->cgrbdb() : $self->cgrbdb();
  my $dbh = $cgrbdb->dbh();

  foreach my $cog (@$cogs) {
#    my $cog_id = $cog->id();
    my $sth = $dbh->prepare("insert into Whog_absent (ID_Organism, ID_COG) values (?, ?)");
    $sth->bind_param(1,$organism);
    $sth->bind_param(2,$cog->id());

    my $rslt = $cgrbdb->dbAction($dbh,$sth,1);
    return $rslt if ($rslt);
  }
}
