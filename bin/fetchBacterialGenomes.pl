#!/bin/env perl
# $Id: fetchBacterialGenomes.pl,v 3.2 2007/04/17 22:52:22 givans Exp $

use warnings;
use strict;
use Carp;
use Net::FTP;

$| = 1;
my $debug = 0;

my $ftp = Net::FTP->new('ftp.ncbi.nih.gov');
$ftp->login('anonymous','anonymous@yahoo.com') or die "can't login to NCBI: $!";
$ftp->binary();
$ftp->cwd('genomes/Bacteria') or die "can't change to Bacteria directory: $!";
my @dirs = $ftp->ls();

my ($download,$fail,@failed) = (0,0);
DIRS:  foreach my $dir (@dirs) {
	print "\ndir: '$dir'\n";

	$ftp->cwd("/genomes/Bacteria/$dir");
	
	foreach my $file ($ftp->ls()) {
		if ($file =~ /\w+\.gbk/) {
			print "file: '$file'\n";
		  my ($remote_size,$local_size);
			$remote_size = $ftp->size($file);
#            $remote_size =1;
            if (!$remote_size) {
                print "can't determine remote size\n";
                if ($ftp->supported('size')) {
                    croak("size is supported by FTP server");
                } else {
                    croak("size is not supported by FTP server");
                }
            }
			$local_size = (-s "../bacterial/$file");
			if (!$local_size || $remote_size != $local_size) {
			  print "remote size = $remote_size, local size = " . eval { $local_size ? return $local_size : return '0'; } . "\n";
			  print "\tdownloading '$file'\n";
			  #print "\tfile size:  '", $ftp->size($file), "'\n";
			  if ($ftp->get($file)) {
					print "\tdownloaded '$file' successfully\n";
					++$download;
			  } else {
					print "\tfailed to download '$file'\n";
					push(@failed,$file);
					++$fail;
			  }
			} else {
			  print "remote file and local file are the same size\n";
			  print "\tnot downloading '$file'\n";
			}
		}
		last DIRS if ($debug && ($download == 10 || $fail == 10));
	}
	#last;
}

$ftp->quit();

print scalar(@dirs), " directories\n";
print "downloaded $download files\n";
if ($fail) {
	print "$fail failed downloads:\n";
	foreach my $failure (@failed) {
		print "\t$failure\n";
	}
}
