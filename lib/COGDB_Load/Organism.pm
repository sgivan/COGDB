package COGDB_Load::Organism;

# $Id: Organism.pm,v 1.3 2011/07/27 21:30:19 givans Exp $

use warnings;
use strict;
use Carp;
use lib '/home/sgivan/projects/COGDB';
use COGDB;
use vars qw/ @ISA /;
@ISA = qw/ COGDB /;

my $debug = 0;

if ($debug) {
  open(LOG,">>/home/sgivan/log/COGDB_Load.Organism.log") or die "can't open COGDB_Load.Category.log: $!";
  print LOG "\n\n\n", "+" x 50, "\n", scalar(localtime()), "\n\n";
}


return 1;


sub new {
  my ($pkg,$params) = @_;

  my $self = {};

  bless $self, $pkg;

  return $self;
}

sub parse_file {
  my ($self,$file) = @_;
  print LOG $self->stack() if ($debug);
  my @organism;
  open(IN,$file) or die "can't open $file: $!";

  while (<IN>) {
    my $line = $_;
    next unless ($line =~ /\w/);
    chomp($line);
    my @values = split /\s+/, $line;
#    print "@values\n";
    my $code = shift(@values);
    my $int = shift(@values);
    my $division = shift(@values);
    my $name = join ' ', @values;
#    print "code = '$code', int = '$int', division = '$division', name = '$name'\n";
    push(@organism,[$code, $int, $division, $name]);

  }
  $self->load_organism(\@organism);
}

sub load_organism {
  my ($self,$organism) = @_;
  print LOG $self->stack() if ($debug);
#  print "load_organism\n";
  my $cgrbdb = $self->cgrbdb();
  my $dbh = $cgrbdb->dbh();

  foreach my $row (@$organism) {
    my $line = join ',', @$row;
    #my $string = "insert into COGDB.Organism (`Code`, `Name`, `Division`, `Other`) values ('$row->[0]', '$row->[3]', $row->[2], '$row->[1]')";
    my $string = "insert into COGDB.Organism (`Code`, `Name`, `Division`, `Other`) values (?, ?, ?, ?)";
    my $sth = $dbh->prepare($string);
    $sth->bind_param(1,$row->[0]);
    $sth->bind_param(2,$row->[3]);
    $sth->bind_param(3,$row->[2]);
    $sth->bind_param(4,$row->[1]);
    my $rtn = $cgrbdb->dbAction($dbh,$sth,1);
    if ($rtn) {
      print STDERR $rtn->[0]->[0] . "\n";
    }
  }
    return 1;
}

sub load_accession {
    my ($self,$orgID,$accession) = @_;
    print LOG $self->stack() if ($debug);

    my $insert = $self->store("insert into COGDB.Accessions (OrgID, Accession) values ($orgID,'$accession')");

    for my $row (@$insert) {
        return $row->[0];
        last;
    }
    return 1;
}

sub delete_accession {
    my ($self,$accession) = @_;
    print LOG $self->stack() if ($debug);

    my $delete = $self->delete("delete from COGDB.Accessions where `Accession` = '$accession'");

    for my $row (@$delete) {
        return $row->[0];
        last;
    }
    return 1;

}

sub code_exists {
    my ($self,$code_query) = @_;
    print LOG $self->stack() if ($debug);

    my $fetch = $self->fetch("select `ID` from COGDB.Organism where `Code` = '$code_query'");

    for my $row (@$fetch) {
        return $row->[0];
        last;
    }
}

sub organism_exists {
    my ($self,$org_string) = @_;
    print LOG $self->stack() if ($debug);

    #my $fetch = $self->fetch("select `ID` from COGDB.Organism where `Name` = '$org_string'");
    #my $fetch = $self->fetch("select `code` from COGDB.Organism where `Name` = '$org_string'");
    my $fetch = $self->fetch("select `code` from COGDB.Organism where `Name` = \"$org_string\"");

    for my $row (@$fetch) {
        return $row->[0];
        last;
    }
}

sub delete_organism {
    my ($self,$code) = @_;
    print LOG $self->stack() if ($debug);

    my $delete = $self->delete("delete from COGDB.Organism where `Code` = '$code'");


    for my $row (@$delete) {
        return $row->[0];
        last;
    }
    return 1;
}

sub set_extend {
    my ($self,$code) = @_;
    print LOG $self->stack() if ($debug);

    my $update = $self->update("update COGDB.Organism set `extend` = 1 where `Code` = '$code'");

    for my $row (@$update) {
        return $row->[0];
        last;
    }
    return 1;
}

sub set_pathogen {
    my ($self,$code) = @_;
    print LOG $self->stack() if ($debug);

    my $update = $self->update("update COGDB.Organism set `pathogen` = 1 where `Code` = '$code'");

    for my $row (@$update) {
        return $row->[0];
        last;
    }
    return 1;
}

