package COGDB_Load::COG;

# $Id: COG.pm,v 1.3 2011/07/27 21:29:20 givans Exp $
use warnings;
use strict;
use Carp;
use lib '/home/sgivan/projects/COGDB/lib';
use COGDB;
use vars qw/ @ISA /;
@ISA = qw/ COGDB /;

my $debug = 0;
my $db = 1;## whether the database should actually be modified

if ($debug) {
  open(LOG,">>/home/sgivan/log/COGDB_Load.COG.log") or die "can't open COGDB_Load.COG.log: $!";
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
  my (%cog,@cog_assoc,$cognum);
  open(IN,$file) or die "can't open $file: $!";

  while (<IN>) {
    my $line = $_;
    next unless ($line =~ /\w/);
    next if ($line =~ /^#/);
    chomp($line);
    my @values = split /\t/, $line;

    my $cogname = shift(@values);
    my $category = shift(@values);
    my $description = shift(@values);

    foreach my $category_char (split //, $category) {
      my $category_id = $self->category({Code => $category_char})->id();
      if (!$cog{$cogname}) {
        ++$cognum;
        $cog{$cogname} = [$cogname, $description, $cognum];
      }
      push(@cog_assoc,[$cognum, $category_id]);
    }

  }
  $self->load_cog(\%cog);
  $self->load_associate(\@cog_assoc);
}

sub load_cog {
  my ($self,$cog) = @_;
  print LOG $self->stack() if ($debug);
  my $cgrbdb = $self->cgrbdb();
  my $dbh = $cgrbdb->dbh();

  foreach my $data (values %$cog) {
    print "Name: $data->[0], Description: $data->[1], ID: $data->[2]\n" if ($debug);
    if ($db) {
      my $sth = $dbh->prepare("insert into COG (Name, Description, ID) values (?,?, ?)");
      $sth->bind_param(1,$data->[0]);
      $sth->bind_param(2,$data->[1]);
      $sth->bind_param(3,$data->[2]);
      my $rtn = $cgrbdb->dbAction($dbh,$sth,1);
      if ($rtn) {
    	print "rtn:  ", $rtn->[0]->[0], "\n";
      } else {
    	print "loaded $data->[0]\n" if ($debug);
      }
    }
  }
}

sub load_associate {
  my ($self,$assoc) = @_;
  print LOG $self->stack() if ($debug);
  my $cgrbdb = $self->cgrbdb();
  my $dbh = $cgrbdb->dbh();

  foreach my $data (@$assoc) {
    print "assoc: $data->[0] -> $data->[1]\n";
    if ($db) {
      my $sth = $dbh->prepare("insert into COG__Category (ID_COG, ID_Category) values (?,?)");
      $sth->bind_param(1,$data->[0]);
      $sth->bind_param(2,$data->[1]);
      my $rtn = $cgrbdb->dbAction($dbh,$sth,1);
      if ($rtn) {
	print "rtn:  ", $rtn->[0]->[0], "\n";
      }
    }
  }
}
