#!/bin/env perl
# $Id: get_seqfeature.pl,v 1.4 2005/11/18 01:10:14 givans Exp $
# $Log: get_seqfeature.pl,v $
# Revision 1.4  2005/11/18 01:10:14  givans
# Wrapped $feature->get_tag_values() in an eval{} block to catch exceptions.
#
# Revision 1.3  2004/01/09 19:18:51  givans
# Added a line to not output deprecated ORFs (genDB will export them)
#
# Revision 1.2  2004/01/09 01:57:21  givans
# Perl script to extract protein translations
# from either a genbank or embl file into
# a fasta file
#
#
use strict;
use Carp;
use warnings;
use Bio::SeqIO;
use Bio::Seq::SeqFactory;
use Getopt::Std;
use  vars qw/$opt_f $opt_F $opt_d $opt_D $opt_l $opt_p/;

getopts('f:F:dD:pl');

my $debug = $opt_d;
my $outputdir = $opt_D;
my $usage = "usage: get_seqfeature.pl -f <filename> -F <file format>";
$opt_p = 1 unless ($opt_l);

if (!$opt_f) {
  print <<HELP;
# Perl script to extract protein translations
# from either a genbank or embl file into
# a fasta file named after the input file

Comand line options

    -f  input file name
    -F  input file format
    -p  use protein_id as fasta id
    -l  use locus_tag as fasta id
    -D  output directory [default=same as input file]
HELP
  print "$usage\n";
  exit(1);
}

my $file_in = $opt_f;

my $outfile;
if ($outputdir) {
    if ($file_in =~ /^(\S+\/)+(\S+?)(\.\w+)*$/) {
        $outfile = $2 . ".fasta";
    } else {
        $outfile = $file_in . ".fasta";
    }
}

print "outfile = '$outfile'\n" if ($debug);
#exit;

if (!$opt_F) {
  print "$usage\n";
  exit(1);
}

my $format = $opt_F;

my $seqin = Bio::SeqIO->new(
    -file	=>	$file_in,
    -format	=>	$format,
);
my $seqout = Bio::SeqIO->new(
    -file	=>	$outputdir ? ">" . $outputdir . "/$outfile" : ">$file_in.fasta",
    -format	=>	'fasta',
);
my $seqcnt = 0;
while (my $seq = $seqin->next_seq()) {
  print "sequence ID: ", $seq->id(), "\n";
#  my @topFeatures = $seq->top_SeqFeatures();
  my @topFeatures = $seq->get_SeqFeatures();
  foreach my $feature (@topFeatures) {
    next unless ($feature->primary_tag eq 'CDS');
    my $seqFactory = Bio::Seq::SeqFactory->new();

    my @pid;
    if ($opt_p) {
        eval {
            @pid = $feature->get_tag_values('protein_id');
        };
#        if ($@) {
#            print "get_tag_values threw an exception:\n>>>>\n $@ \n<<<<<\n";
#            print "This usually happens with things like pseudogenes.  Ignoring...\n\n";
#            next;
#        }
    } elsif ($opt_l) {
        eval {
            @pid = $feature->get_tag_values('locus_tag');
        };
    }
    if ($@) {
        print "get_tag_values threw an exception:\n>>>>\n $@ \n<<<<<\n";
        print "This usually happens with things like pseudogenes.  Ignoring...\n\n";
        next;
    }


    next if ($pid[0] =~ /deprecated/);
    my (@products,$product);

    my @tags = $feature->get_all_tags();
    my $tags = join '_', @tags;

    if ($tags =~ /product/) {
      @products = $feature->get_tag_values('product');
      $product = $products[0];
    } else {
      $product = "unknown function";
    }


    my $id = $pid[0];
    my $newSeq;
    eval {
    $newSeq = $seqFactory->create(
				     -id	=>	$id,
				     -seq	=>	$feature->get_tag_values('translation'),
				     -desc	=>	"(" . $feature->start() . ".." . $feature->end() . ") $product",
				    );
    };
    if ($@) {
      warn "problem retrieving translation for '$id'\n";
      next;
    }
    $seqout->write_seq($newSeq);
    ++$seqcnt;
  }
}

print "$seqcnt proteins\n" if ($seqcnt);
print "finished\n";
