package COGDB_Load::Category;

# $Id: Category.pm,v 1.3 2011/07/27 21:29:43 givans Exp $

use warnings;
use strict;
use Carp;
use lib '/home/sgivan/projects/COGDB/lib';
use COGDB;
use vars qw/ @ISA /;
@ISA = qw/ COGDB /;

my $debug = 0;

if ($debug) {
  open(LOG,">>/home/sgivan/log/COGDB_Load.Category.log") or die "can't open COGDB_Load.Category.log: $!";
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
  my (@category);
  open(IN,$file) or die "can't open $file: $!";
  my ($category) = ();
  while (<IN>) {
    my $line = $_;
    next if ($line =~ /^#/);
    chomp($line);
    ++$category;
    my @data = split /\s/;
    my $code = $data[0];
    my $name = join ' ', @data[1..$#data];
    push(@category,[$code, $name]);
  }
  $self->load_category(\@category);
}

sub load_super_category {
  my ($self,$list) = @_;
  print LOG $self->stack() if ($debug);
  my $cgrbdb = $self->cgrbdb();
  my $dbh = $cgrbdb->dbh();
  print "Remember to truncate table first\n";

  foreach my $row (@$list) {
#    print "ID: ", $row->[0], ", name: ", $row->[1], "\n";
    my $sth = $dbh->prepare("insert into SuperCategory (ID,Name) values (" . $row->[0] . ", '" . $row->[1] . "')");
    my $rtn = $cgrbdb->dbAction($dbh,$sth,1);
#    print "rtn: ", $rtn->[0]->[0], "\n" if ($rtn);
  }
}

sub load_category {
  my ($self,$list) = @_;
  print LOG $self->stack() if ($debug);
  my $cgrbdb = $self->cgrbdb();
  my $dbh = $cgrbdb->dbh();
#  print "Remember to truncate table first\n";

  foreach my $row (@$list) {
#    print "ID: $row->[0], code = $row->[1], name = $row->[2], super = $row->[3]\n";
    my $sth = $dbh->prepare("insert into Category (Code,Name) values ('$row->[0]','$row->[1]')");
    my $rtn = $cgrbdb->dbAction($dbh,$sth,1);
#    print "rtn: ", $rtn->[0]->[0], "\n" if ($rtn);
  }
}
