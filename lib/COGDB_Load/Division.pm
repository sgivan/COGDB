package COGDB_Load::Division;

# $Id: Division.pm,v 1.3 2011/07/27 21:30:19 givans Exp $

use warnings;
use strict;
use Carp;
use lib '/home/sgivan/projects/COGDB';
use COGDB;
use vars qw/ @ISA /;
@ISA = qw/ COGDB /;

my $debug = 0;

if ($debug) {
  open(LOG,">>/home/sgivan/log/COGDB_Load.Division.log") or die "can't open COGDB_Load.Category.log: $!";
  print LOG "\n\n\n", "+" x 50, "\n", scalar(localtime()), "\n\n";
}


return 1;


sub new {
  my ($pkg,$params) = @_;

  my $self = {};

  bless $self, $pkg;

  return $self;
}

sub load_division {
  my ($self,$division) = @_;
  print LOG $self->stack() if ($debug);
  print "load_division\n";
  my $cgrbdb = $self->cgrbdb();
  my $dbh = $cgrbdb->dbh();

  foreach my $row (@$division) {
#    my $line = join ',', @$row;
#    print "line: '$line'\n";
    my $sth = $dbh->prepare("insert into Division (Name) values ('$row->[0]')");
    my $rtn = $cgrbdb->dbAction($dbh,$sth,1);
    if ($rtn) {
      print STDERR $rtn->[0]->[0] . "\n";
    }
  }

}

sub division_exists {
    my ($self,$org_string) = @_;
    print LOG $self->stack() if ($debug);

    my $fetch = $self->fetch("select `ID` from COGDB.Division where `Name` = '$org_string'");

    for my $row (@$fetch) {
        return $row->[0];
        last;
    }
}

sub list_divisions {
    my ($self) = shift;
    my @divisions = ();
    print LOG $self->stack() if ($debug);

    my $fetch = $self->fetch("select `Name` from COGDB.Division");

    for my $divrow (@$fetch) {
        push(@divisions,$divrow->[0]);
    }
    return \@divisions;
}

sub division_id {
    my ($self,$divname) = @_;
    my $div_id = 0;
    print LOG $self->stack() if ($debug);

    my $fetch = $self->fetch("select `ID` from COGDB.Division where `Name` = '$divname'");

    for my $row (@$fetch) {
        $div_id = $row->[0];
        last;
    }
    return $div_id;
}

sub division_like {
    my ($self,$div_term) = @_;
    my $div_id = 0;
    print LOG $self->stack() if ($debug);

    my $fetch = $self->fetch("select `ID` from COGDB.Division where `Name` like '%$div_term%'");

    for my $row (@$fetch) {
        my $div_id = $row->[0];
        last;
    }
    return $div_id;
}

