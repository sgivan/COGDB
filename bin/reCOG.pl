#$ -o /home/cgrb/givans/cluster
#$ -e /home/cgrb/givans/cluster
#$ -cwd
#$ -N reCOG
#$ -S /bin/env perl
#
use lib '/local/cluster/lib/perl5/site_perl';
use Cwd;
$ENV{PERL5LIB} = '/mnt/local/cluster/lib/perl5/site_perl:/mnt/home/cgrb/cgrblib/perl5/COGDB';

my $dir = cwd();
$dir =~ s/.+\///;
#print "\$dir = '$dir'\n";

open(reCOG,"/home/cgrb/givans/bin/reCOGnition.pl -F blast -l -w $dir -v |") or die "can't open reCOGnition.pl: $!";
#open(reCOG,"/home/cgrb/givans/bin/reCOGnition.pl -F blast -l -w $dir -v -U 0.95 -L 0.05 |") or die "can't open reCOGnition.pl: $!";
my @output = <reCOG>;
close(reCOG) or die "can't close reCOGnition.pl: $!";
open(OUT,">reCOG.log") or die "can't open reCOG.log: $!";
print OUT @output;
close(OUT);
