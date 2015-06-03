package COGDB_Load::Category;

# $Id: Category.pm,v 1.3 2011/07/27 21:29:43 givans Exp $

use warnings;
use strict;
use Carp;
use lib '/home/sgivan/projects/COGDB';
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
  my (@super,@category);
  open(IN,$file) or die "can't open $file: $!";
  my ($super,$category) = ();
  while (<IN>) {
    my $line = $_;
    next unless ($line =~ /\w/);
    chomp($line);

    if ($line =~ /^\w/) {
#      print "Super: '$line'\n";
      ++$super;
      push(@super,[$super, $line]);
    } else {
#      print "Category: '$line'\n";
      ++$category;
      my @data = split /\s/;
      my $code = $data[1];
      $code =~ s/[\[\]]//g;
      my $name = join ' ', @data[2..$#data];
#      print "$category\tcode = $code, name = $name, super = $super\n";
      push(@category,[$category, $code, $name, $super]);
    }
  }
  $self->load_super_category(\@super);
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
    my $sth = $dbh->prepare("insert into Category (ID,Code,Name,ID_Super) values ($row->[0],'$row->[1]','$row->[2]',$row->[3])");
    my $rtn = $cgrbdb->dbAction($dbh,$sth,1);
#    print "rtn: ", $rtn->[0]->[0], "\n" if ($rtn);
  }
}
