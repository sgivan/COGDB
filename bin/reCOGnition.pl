#!/bin/env perl
# $Id: reCOGnition.pl,v 3.22 2010/03/22 23:39:49 givans Exp $

use 5.010;
use warnings;
use strict;
use autodie;
use Carp;
use Getopt::Std;
use vars qw/ $opt_d $opt_D $opt_v $opt_h $opt_F $opt_f $opt_b $opt_o $opt_S $opt_l $opt_r $opt_M $opt_w $opt_p $opt_U $opt_L $opt_i $opt_X $opt_e
$opt_g $opt_G $opt_P /;
use Bio::SearchIO;
use lib '/home/sgivan/projects/COGDB/lib';
use COGDB;
use Statistics::Descriptive;
use Data::Dumper;
use IO::File;# I use this in the data_in() and data_out() methods

getopts('dDvhF:f:b:o:Slr:M:w:pU:L:i:Xe:gG:P:');

if ($opt_X) {
  
}

my($debug,$ddebug,$verbose,$help,$folder,$file,$blast,$outfile,@files,$cogsummary,$coglist,$crossref,$minimum_membership,$local_whog,$nonpathogen,$input_file,$exclude_list);
my ($upper,$lower,$genelist,$coglowcountlimit,$minimum_proportion);

$help = $opt_h;
if ($help) {
    _help();
}

$| = 1;
$debug = $opt_d;
$ddebug = $opt_D;
$debug = 1 if ($ddebug);
$verbose = $opt_v;
$verbose = 1 if ($debug);
$file = $opt_f;
$folder = $opt_F || 'blast';
$blast = $opt_b || 'blastp';
#$outfile = $opt_o || 'reCOGnition.out';
#$outfile = $opt_o || 'reCOGnition';
$outfile = $opt_o || "reCOGnition.$$";
$cogsummary = $opt_S;
$coglist = $opt_l;
$crossref = $opt_r;
$nonpathogen = $opt_p if ($crossref);
#$minimum_membership = $opt_M || 2;
$local_whog = $opt_w;
$upper = $opt_U || 0.90;
$lower = $opt_L || 0.10;
$input_file = $opt_i;
$exclude_list = $opt_e;
$genelist = $opt_g;
$coglowcountlimit = $opt_g || 1000;

if ($opt_M) {
    $minimum_membership = $opt_M;
} elsif ($opt_P) {
    $minimum_proportion = $opt_P;
} else {
    _help();
}

my $cogdb = COGDB->new();
my $whog = $cogdb->whog();

if ($verbose) {
  print "Options:\n";

  print "-f\t", $file || '', "\n";
  print "-F\t", $folder || '', "\n";
  print "-b\t", $blast || '', "\n";
  print "-o\t", $outfile || '', "\n";
  print "-S\t", $cogsummary || '', "\n";
  print "-l\t", $coglist || '', "\n";
  print "-r\t", $crossref || '', "\n";
  print "-e\t", $exclude_list || '', "\n";
  print "-p\t", $nonpathogen || '', "\n";
  print "-M\t", $minimum_membership || '', "\n";
  print "-w\t", $local_whog || '', "\n";
  print "-U\t", $upper || '', "\n";
  print "-L\t", $lower || '', "\n";
  print "-d\t", $debug || '', "\n";
  print "-D\t", $ddebug || '', "\n";
  print "-v\t", $verbose || '', "\n";
  print "-h\t", $help || '', "\n";
}

if (!$input_file && (!$file && !-e $folder)) {
#if (!$file && !-e $folder) {
  print STDERR "you must provide either a file name or a folder name\n";
  exit(0);
}

my (%CATEGORIES,%ec,%COGS) = ();

open(OUT,">$outfile" . ".reCOG.out") or die  "can't open $outfile" . ".out: $!";
#$outfile =~ s/out/tab/;
open(TAB,">$outfile" . ".reCOG.tab") or die "can't open $outfile" . ".tab: $!";

if (!$input_file) {

  @files = <$folder/*.$blast> if ($folder && !$file);
  push(@files,$file) if ($file);

  my $cnt = 0;
  #my (%CATEGORIES,%ec,%COGS) = ();
  foreach my $file (@files) {
    ++$cnt;
    print "\nfile:  '$file'  -  $cnt\n" if ($verbose);

    last if ($ddebug && $cnt > 2);

    my (%cogs,@cognames)= ();

    my $searchIO = Bio::SearchIO->new(
              -format =>  'blast',
              -file =>  $file,
             );
    $searchIO->max_significance(1e-6);
    $searchIO->check_all_hits(0);
    print "checking all hits\n" if ($searchIO->check_all_hits() && $debug);

    my $hit_cnt = 0;
    my ($query_name,$pos_min,$pos_max);
    foreach my $result ($searchIO->next_result()) {
      my @hits = $result->hits();
      my (%categories);
      $query_name = $result->query_name();
      print "\thits:  ", scalar(@hits), "\n" if ($debug);


      #######################

      # Loop through hits and collect COGs

      #######################

    foreach my $hit (@hits) {
        next unless ($hit->start());
        ++$hit_cnt;

        my $t_hitname = $hit->name();
        $t_hitname =~ s/lcl\|//;
        $hit->name($t_hitname);

        print "hit name: ", $hit->name(), ", E = ", $hit->significance(), " [", $hit->start(), "-", $hit->end(), "]\n" if ($debug);
        
        ########################

        # set some hit quality thresholds

        ########################

        #      next unless (eval { if ($hit->frac_aligned_hit() >= 0.75) { return 1; } else { return 0; } });


        ##################

        # collect COG memberships for each DB hit

        ##################

        my $whogs = $whog->fetch_by_name($hit->name());
        my $COGS_cnt = 0;
        COGS: foreach my $cog (map { $_->cog() } @$whogs) { # this may be unneccessary since there seems to be 1 COG per hit
            ++$COGS_cnt;
            print "\t\t" . $hit->name() . "has more than one COG\n" if (($COGS_cnt > 1) && $debug);
            print "\tCOG:  ", $cog->name(), "\n" if ($debug); #, " - ", $cog->description(), "\n" if ($debug);


            #######################

            # only keep first (best) COG for each fcnl category

            #######################


            #   foreach my $category (@{$cog->categories()}) {
            #     last COGS if ($categories{$category->name()} && $categories{$category->name()} >= $minimum_membership);
            #     ++$categories{$category->name()};
            #   }

            #   if ($cogs{$cog->name()}->{pos_min} && $cogs{$cog->name()}->{pos_max}) {
            #     next COGS if ($hit->start() < $cogs{$cog->name()}->{pos_max} && $hit->end() > $cogs{$cog->name()}->{pos_min});
            #   }


                

            ++$cogs{$cog->name()}->{count};
            $cogs{$cog->name()}->{cog} = $cog;
            $cogs{$cog->name()}->{pos_min} = $hit->start() if (!$cogs{$cog->name()}->{pos_min} || ($hit->start() < $cogs{$cog->name()}->{pos_min}));
            $cogs{$cog->name()}->{pos_max} = $hit->end() if (!$cogs{$cog->name()}->{pos_max} || ($hit->end() < $cogs{$cog->name()}->{pos_max}));
            $cogs{$cog->name()}->{E} = $hit->significance() if (!$cogs{$cog->name()}->{E} || ($hit->significance() < $cogs{$cog->name()}->{E}));
        }     ## end of COGS routine
        #       last;
      }       ## end of foreach $hit

    }       ## end of foreach $result
 

    #  print "hit count = $hit_cnt\n" if ($debug);
    my (%tmp_categories,@tmp_regions,$chk_loop) = ();

    #  foreach my $cogname (sort { $cogs{$b}->{count} <=> $cogs{$a}->{count} } keys %cogs) {


    # The following loop first sorts COG alignments by E-value, then
    # queries each for start and stop locations of the
    # similarity alignment.  The COG with the lowest
    # E-value initializes an array of arrays that contain
    # start and stop locations.  If another COG alignment
    # DOES NOT overlap first alignment, then it is added
    # to an array of cognames, which is used later.


    foreach my $cogname (sort { $cogs{$a}->{E} <=> $cogs{$b}->{E} } keys %cogs) {
        ++$chk_loop;

        if ($debug) {
            print "\n\t$cogname ($cogs{$cogname}->{count}): ", $cogs{$cogname}->{cog}->description(), "\n";
            print "\t\tregion: ", $cogs{$cogname}->{pos_min}, " - ", $cogs{$cogname}->{pos_max}, "\n";
            print "\t\tE:  ", $cogs{$cogname}->{E}, "\n";
        }

        if ($opt_M) {
            next unless ($cogs{$cogname}->{count} && $cogs{$cogname}->{count} >= $minimum_membership);
        } elsif ($opt_P) {
            my $all_count = $whog->cog_count($cogs{$cogname});
            #my $threshold = int($all_count * $minimum_proportion) * 100;
            my $threshold = int($all_count * $minimum_proportion);
            $threshold = 1 unless ($threshold);
            say "threshold for $cogname: $threshold" if ($debug);
            next unless ($cogs{$cogname}->{count} && $cogs{$cogname}->{count} >= $threshold);
        }

        my $overlap = 0;
        if ($chk_loop == 1) {
            push(@tmp_regions,[$cogs{$cogname}->{pos_min}, $cogs{$cogname}->{pos_max}]);
        } else {
            foreach my $region (@tmp_regions) {
                if ($cogs{$cogname}->{pos_min} < $region->[1] && $cogs{$cogname}->{pos_max} > $region->[0]) {
                    $overlap = 1;
                    print "\t\t[$cogs{$cogname}->{pos_min} - $cogs{$cogname}->{pos_max}] overlaps [$region->[0] - $region->[1]]\n" if ($debug);
                } else {
                    print "\t\t[$cogs{$cogname}->{pos_min} - $cogs{$cogname}->{pos_max}] doesn't overlap [$region->[0] - $region->[1]]\n" if ($debug);
                }
            }
        
            if (!$overlap) {
                push(@tmp_regions, [$cogs{$cogname}->{pos_min}, $cogs{$cogname}->{pos_max}]);
            }
        }       ## end of if ($chk_loop) else

        if ($overlap) {
            print "\t\tcog $cogname overlaps another COG\n" if ($debug);
            next;
        }

        push(@cognames,$cogname); ## pushes cogname onto array if no overlap with other COG alignments was detected
        my $categories = $cogs{$cogname}->{cog}->categories();
        foreach my $category (@$categories) {
            print "\t\tcategory:  ", $category->name(), "\n" if ($debug);
            ++$tmp_categories{$category->name()}; # incrementing this populates the hash
        }
    }       # end of foreach $cogname

    #
    # Now @cognames contains the names of distinct non-overlapping COGs
    # that aligned to the query sequence.
    #

    #####################################

    # Assemble/Add to global lists

    #####################################



    foreach my $category_name (keys %tmp_categories) {
      ++$CATEGORIES{$category_name};
    }


    #
    # The following loop populates the %COGS hash.
    #
    #
# $COGS{"cog name"} = {
#       cog =>  COGDB::COG object,
#       count =>  occurrences in this genome,
#       list  =>  (array of ORF names),
#     };
#
#
    foreach my $cog (map { $cogs{$_}->{cog} } @cognames) {

#      next unless ($cogs{$cog->name()}->{count} >= $minimum_membership); ## this is the second check for min membership -- is it necessary?

      $COGS{$cog->name()}->{cog} = $cog unless ($COGS{$cog->name()}->{count});
      ++$COGS{$cog->name()}->{count};
      push(@{$COGS{$cog->name()}->{list}}, $query_name); ## $query_name is name of BLAST query - the ORF that was the BLAST query
    }

  }       ## end of foreach $file
#
#
# Generate data output file that can be reloaded 
#
  data_out(\%COGS);
#
#
} else {      ## end of if ($file || $folder)
  print "loading input file '$input_file'\n" if ($debug);
  my $rtn = data_in($input_file);
  %COGS = %$rtn;
  print "finished loading file\n" if ($debug);
}


#foreach my $orfname (@{$COGS{COG0583}->{list}}) {
#  print "orf:  $orfname\n";
#}


#exit();




##################################

# User-requested output

##################################


#######################

# List of COG categories
# and number of COGs identified from the category

#######################

if ($cogsummary) {

  print "\n\nCategory Summary:\n\n" if ($verbose);
  print OUT "\n\nCategory Summary:\n\n";
  printf "%60s\t%25s\n", "Category Name", "Occurrences" if ($verbose);
  printf OUT "%60s\t%25s\n", "Category Name", "Occurrences";
  foreach my $category_name (keys %CATEGORIES) {
    printf  "%70s\t%10d\n", $category_name, $CATEGORIES{$category_name} if ($verbose);
    printf  OUT "%70s\t%10d\n", $category_name, $CATEGORIES{$category_name};
  }

}


######################

# List of COGs identified
# and the ORFs used to ID
# the COG

######################

if ($coglist) {
  print "\n\nCOG List\n\n" if ($verbose);
  print OUT "\n\nCOG List\n\n";

  foreach my $cog (map { $_->{cog}} values %COGS) {
    print $cog->name(), "\t", $COGS{$cog->name()}->{count}, " - [ ", join ' ', @{$COGS{$cog->name()}->{list}}, "]\n" if ($verbose);
    print OUT $cog->name(), "\t", $COGS{$cog->name()}->{count}, "\t[ ", join ' ', @{$COGS{$cog->name()}->{list}}, "]\n";
    print TAB $cog->name(), "\t", $COGS{$cog->name()}->{count}, "\t", join ' ', @{$COGS{$cog->name()}->{list}}, "\n";
  }

}

if ($genelist) {
    my %GENES = ();
    open(GENES,">",$outfile . ".genes.tab");
    say "\n\nGene List\n\n" if ($verbose);

    for my $cog (map { $_->{cog}} values %COGS) {
        for my $genename (@{$COGS{$cog->name()}->{list}}) {
            push(@{$GENES{$genename}},$cog->name())
        }
    }

    for my $genename (sort keys %GENES) {
        say GENES $genename . "\t" . join ' ', @{$GENES{$genename}};
    }
    close(GENES);
}



#########################

# create a whog file for local organism

#########################

if ($local_whog) {

  print "\n\nmaking whog file\n" if ($verbose);
  my $local_cogdb = $cogdb->localcogs();
  my $organism = $local_cogdb->organism({ Code => $local_whog });
  my $org_code = $organism->code();
#  print "\$organism is a '", ref($organism), "'\n" if ($debug);

  if (! $org_code) {
    $org_code = $local_whog;
  }

  print "local organism code: '$org_code'\n" if ($debug);

  open(WHOG,">$outfile" . "_whogs") or die "can't open whogs: $!";

  foreach my $cogname (map { $_->{cog}->name() } values %COGS) {
    my $cog = $cogdb->cog({ Name => $cogname });
    my $categories = $cog->categories();
    my $category_codes = join '', map { $_->code() } @$categories;
    print WHOG "[$category_codes] ", $cog->name(), " ", $cog->description(), "\n";
#    print WHOG "  ", $organism->code(), ":  ", join ' ', @{$COGS{$cogname}->{list}}, "\n";
    print WHOG "  ", $org_code, ":  ", join ' ', @{$COGS{$cogname}->{list}}, "\n";
  }

  close(WHOG);

#
# if local whogs are requested, I should also cross-reference
#
  $crossref = $organism->division()->name() if ($crossref);

}


###########################

# Cross-reference COGs identified in this
# orginism to those in a user-specified
# group of other organisms

###########################

if ($crossref) {
    print "\n\nCOG cross-reference report - vs '$crossref'\n" if ($verbose);
    print OUT "\n\nCOG cross-reference report - vs $crossref\n";
    print "excluding pathgenic strains\n" if ($nonpathogen && $verbose);
    print OUT "excluding pathogenic strains\n" if ($nonpathogen);

    #my $stats = Statistics::Descriptive::Full->new();
    my (@all_whogs,%cogref,@common_cogs,%cog_count,$whog_cnt,%orglist);
    my $orgdb = $cogdb->organism();

    my @organisms = ();# this will contain all the organisms to analyze
    foreach my $crossref (split /\s/, $crossref) {
        push(@organisms,@{$orgdb->fetch_by_division($crossref,$nonpathogen ? 0 : 1)}); ## decide whether to get pathogens by value of $nonpathogen
    }


    my $orgcnt = 0;
    foreach my $organism (@organisms) {
        ++$orgcnt;
        #last if ($debug && scalar(@all_whogs) >= 5);
        last if ($debug && $orgcnt > 10);

        print $organism->division()->name(), ":  ", $organism->name(), " (" , $organism->code(), ")\n" if ($verbose);
        print OUT $organism->division()->name(), ":  ", $organism->name(), " (" , $organism->code(), ")\n";

        if ($nonpathogen) {
            if ($organism->pathogen()) {
                print "\texcluding pathogen:  ", $organism->name(), "\n" if ($verbose);
                print OUT "\texcluding pathogen:  ", $organism->name(), "\n";
                next;
            }
        }
        
        
        if ($exclude_list) {
            my $exclude = 0;
            foreach my $excluded (split /,/, $exclude_list) {
                if ($organism->code() eq $excluded) {
                    print "excluded by user: ", $organism->code(), " - ", $organism->name(), "\n" if ($verbose);
                    print OUT "excluded by user: ", $organism->code(), " - ", $organism->name(), "\n";
                    $exclude = 1;
                    last;
                }
            }
            if ($exclude) {
#                 exit();
                next();
            }
        }
        
        $orglist{$organism->id()} = $organism;
        my $whogs = $whog->fetch_by_organism($organism);

        # put in a minumum # of COGs threshold
        if (scalar(@$whogs) < $coglowcountlimit) {
            say "skipping '" . $organism->name() . "' b/c # COGs < $coglowcountlimit" if ($verbose);
            next;
        }

        push(@all_whogs,$whogs);
    }
#
#
    $whog_cnt = scalar(@all_whogs);
    print "number of organisms in '$crossref' = $whog_cnt\n" if ($verbose);

    foreach my $whogs (@all_whogs) {
        # there will be an array reference for each organism
        # referenced array will contain all Whog objects from that organism
        my %orgcogs = ();
        my $org_whogs = 0;
        
        # tally the occurrence of each COG for this organism
        # keys in hash ensure each COG is unique
        foreach my $whog (@$whogs) {
            $orgcogs{organism} = $whog->source() unless ($orgcogs{organism});
            ++$org_whogs;
            ++$orgcogs{cogs}{$whog->cog()->name()}->{count};
            $orgcogs{cogs}{$whog->cog()->name()}->{cog} = $whog->cog();# unless ($orgcogs{$whog->cog()->name()} > 1);
        }

        # add the occurrence of each COG in this organism to master tally
        foreach my $cogname (keys %{$orgcogs{cogs}}) {
            #
            # Initialize a hash structure that keeps track of the representation of
            # the COGs in the different organisms.  The final structure should look
            # like:
            #           {
            #              '35' => 2,
            #              '67' => 3,
            #              '39' => 2,
            #              '36' => 2,
            #              '46' => 2,
            #              '44' => 2,
            #            };
            #
            # where the key is the organism ID and the value is the tally for that COG in the organism
            #
      
            # initialize %cogref the first time through
            if (!$cogref{$cogname}->{count}) {
                foreach my $organism (values %orglist) {
                    $cogref{$cogname}->{orgrep}->{$organism->id()} = undef;## orgrep == organism representation
                }
            }
        
        
            ++$cogref{$cogname}->{count};
            $cogref{$cogname}->{cog} = $orgcogs{cogs}{$cogname}->{cog};# COG object
            #  store number of occurences of this COG in this organism
            $cogref{$cogname}->{orgrep}->{$orgcogs{organism}->id()} = $orgcogs{cogs}{$cogname}->{count};
        }
    }

    my (@missing,@present,@unique);

    foreach my $cogname (keys %cogref) {
        # coverage = number of species that contain this COG
        $cogref{$cogname}->{coverage} = $cogref{$cogname}->{count} . "/" . $whog_cnt;# $whog_cnt is the number of organisms
#        $stats->add_data($cogref{$cogname}->{count});
#        $stats->add_data($cog_count{$cogname});
#        if ($cogref{$cogname}->{count} >= scalar(@all_whogs)) {
        if ($cogref{$cogname}->{count} >= int($upper * $whog_cnt)) {
#            push(@common_cogs,$cogref{$cogname}->{cog});
             push(@common_cogs,[$cogref{$cogname}->{cog},$cogref{$cogname}->{orgrep}]);
        }
    }
    print "total common:  ", scalar(@common_cogs), " COGs\n" if ($verbose);
    print OUT "total common:  ", scalar(@common_cogs), " COGs\n";

    #
    # Structure of %cogref
    #
    # $cogref{"cog name"} = {
    #         count   =>  integer,
    #         cog   =>  COGDB::COG object,
    #         coverage  =>  text string,
    #         orgrep    =>  {
    #                          organism ID =>  integer,
    #                          organism ID =>  integer,
    #                          < ... repeated for each organism ID >
    #                       },
    #       }
    #
    #
    #
    #   print "mean COG membership:  ", $stats->mean(), " (+/- " . $stats->standard_deviation() . ") [N=" . $stats->count() . "]\n" if ($verbose);
    #   print "median COG membership:  ", $stats->median(), "\n" if ($verbose);
    
    
    #   my @bins = ($stats->min()..$stats->max());
    #   my %f = $stats->frequency_distribution(\@bins);
    #   foreach my $freq (sort {$a <=> $b} keys %f) {
    #     print "$freq:\t$f{$freq}\n";
    #   }
    
    #  exit(0);


    foreach my $cogdata (@common_cogs) {
        my ($cog,$orgrep) = @$cogdata;

        if ($COGS{$cog->name()}) {## %COGS contains COGs found in current organism
            push(@present,[$cog,$orgrep]);
        } else {
            push(@missing,[$cog,$orgrep]);
        }
    }

    print "\n\nCOGs in common (threshold = " . int($upper * $whog_cnt) . "/$whog_cnt):\n" if ($verbose);
    print OUT "\n\nCOGs in common (threshold = " . int($upper * $whog_cnt) . "/$whog_cnt):\n";



#
# Generate output for COGs passing minimum membership test
#
# uses @present
#

    foreach my $cogdata (sort { $cogref{$b->[0]->name()}->{count} <=> $cogref{$a->[0]->name()}->{count} } @present) {
        my $cog = $cogdata->[0];

        print $cog->name(), " (", $COGS{$cog->name()}->{count}, ": ", join ' ', @{$COGS{$cog->name()}->{list}}, ") ", $cog->description(), " - [" . $cogref{$cog->name()}->{coverage} . "]", "\t", included(\%orglist,$cogdata->[1]), "\t", excluded(\%orglist,$cogdata->[1]), "\n" if ($verbose);
        print OUT $cog->name(), "\t", $cog->description(), "\t[" . $cogref{$cog->name()}->{coverage} . "]", "\n";

    }
    print "total:  ", scalar(@present), " / ", scalar(@common_cogs), "\n" if ($verbose);
    print OUT "total:  ", scalar(@present), " / ", scalar(@common_cogs), "\n";

#  exit();

    print "\n\nCOGs missing (threshold = " . int($upper * $whog_cnt) . "/$whog_cnt):\n" if ($verbose);
    print OUT "\n\nCOGs missing (threshold = " . int($upper * $whog_cnt) . "/$whog_cnt):\n";

    if ($local_whog) {
        my $local_cogdb = $cogdb->localcogs();
        my $organism = $local_cogdb->organism({ Code => $local_whog });
        my $org_id = $organism->id();

        open(MISS,">whogs_missing_" . "$org_id") or die "can't open 'whog_missing': $!";
    }


#
# Generate output for COGs failing minimum membership test
#
# uses @missing
#

    foreach my $cogdata (sort { $cogref{$b->[0]->name()}->{count} <=> $cogref{$a->[0]->name()}->{count} } @missing) {
        my $cog = $cogdata->[0];

        print "COG:  ", $cog->name(), "  -  ", $cog->description(), " - [" . $cogref{$cog->name()}->{coverage} . "]", "\t", included(\%orglist,$cogdata->[1]), "\t", excluded(\%orglist,$cogdata->[1]), "\n" if ($verbose);
        print OUT $cog->name(), "\t", $cog->description(), "\t[" . $cogref{$cog->name()}->{coverage} . "]", "\t", included(\%orglist,$cogdata->[1]),"\t", excluded(\%orglist,$cogdata->[1]),"\n";
        print MISS $cog->name(), "\t", $cog->id(), "\n" if ($local_whog);
    }
    print "total:  ", scalar(@missing), " / ", scalar(@common_cogs), "\n" if ($verbose);
    print OUT "total:  ", scalar(@missing), " / ", scalar(@common_cogs), "\n";

    close(MISS) if ($local_whog);


#  exit();

#
# Generate data for COGs unique to this genome
#
# populates @unique
#

    foreach my $cog (map { $_->{cog} } values %COGS) {
#       push(@unique,$cog) unless ($cogref{$cog->name()}->{count} && $cogref{$cog->name()}->{count} > 0);
        push(@unique,$cog) unless ($cogref{$cog->name()}->{count} && $cogref{$cog->name()}->{count} > (int($lower * $whog_cnt)));
    }

    print "\n\nunique COGs (threshold = " . int($lower * $whog_cnt) . "/$whog_cnt):\n" if ($verbose);
    print OUT "\n\nunique COGs (threshold = " . int($lower * $whog_cnt) . "/$whog_cnt):\n";

    if ($local_whog) {
        my $local_cogdb = $cogdb->localcogs();
        my $organism = $local_cogdb->organism({ Code => $local_whog });
        my $org_id = $organism->id();

        open(UNIQUE,">whogs_unique_" . "$org_id") or die "can't open 'whog_unique': $!";
    }

#
# Output data for unique COGs
#
# uses @unique
#
    foreach my $cog (sort { eval {$cogref{$a->name()}->{count} || 0} <=> eval {$cogref{$b->name()}->{count} || 0} } @unique) {
        print "COG:  ", $cog->name(), "  -  ", $COGS{$cog->name()}->{count}, " - ", $cog->description, " - ", eval { $cogref{$cog->name()}->{count} ? return included(\%orglist,$cogref{$cog->name()}->{orgrep}) : return "[0/$whog_cnt]"; }, "\n" if ($verbose);
        print OUT $cog->name(), "\t", $COGS{$cog->name()}->{count}, "\t", $cog->description, "\t", eval { $cogref{$cog->name()}->{count} ? return included(\%orglist,$cogref{$cog->name()}->{orgrep}) : return "[]"; }, "\n" if ($verbose);
#       print OUT $cog->name(), "\t", $cog->description, "\t", eval { $cogref{$cog->name()}->{coverage} ? return "[" . $cogref{$cog->name()}->{coverage} . "]" : return "[0/$whog_cnt]"; }, "\n";
        print UNIQUE $cog->name(), "\t", $cog->id(), "\n" if ($local_whog);
    }
    print "total:  ", scalar(@unique), "\n" if ($verbose);
    print OUT "total:  ", scalar(@unique), "\n";

    close(UNIQUE) if ($local_whog);
    
    # Signficantly high (SHO)/low (SLO) occurrences:
    # use $cogref{"cog name"}{orgrep} hash reference
    # compare to $COGS{$cog->name()}->{count}
    my (@sho,@slo) = ();

    open(SHO,">","whogs_sho.txt");
    open(SLO,">","whogs_slo.txt");

    # if I use %coref here, I'll not see COGs present in query organism, but absent from others
    # So, this is only good for SHO'so
    #
    #for my $cogname (keys %cogref) {
    for my $cogname (keys %COGS) {
        my $orgrep = $cogref{$cogname}->{orgrep};
        my $stats = Statistics::Descriptive::Full->new();
        my @tallies = values %$orgrep;

        for my $tally (@tallies) {
#            $tally = 0 unless ($tally);
#            next if ($tally == 0);
            next unless ($tally);
            $stats->add_data($tally);
        }

        my ($mean,$sd) = ($stats->trimmed_mean(0.05),$stats->standard_deviation());
        $stats->sort_data();
        my @data = $stats->get_data();
        my ($skew,$kurtosis) = ($stats->skewness(),$stats->kurtosis());
        $skew = 1 unless ($skew);
        $kurtosis = 0 unless ($kurtosis);
        my (@greater,@lesser) = ();

        for my $val (@data) {
            if ($val > $COGS{$cogname}->{count}) {
                push(@greater,$val);
            } else{
                push(@lesser,$val);
            }
        }

        if (scalar(@tallies)) {

            if ($COGS{$cogname}->{count} && $COGS{$cogname}->{count} > ($mean + (  2 * $sd))) {
               unless ($stats->count() > (0.95 * $whog_cnt)) { 
                    say "skipping statisitical analysis of '$cogname' b/c n < " . 0.95 * $whog_cnt if ($verbose);
                    next;
                }
#                if ($COGS{$cogname}->{count} < 3) {
#                    say "skipping statistical analysis of '$cogname' b/c count = " . $COGS{$cogname}->{count} if ($verbose);
#                    next;
#                }
           
                if ($skew && $skew > 2) {
                    say "skipping '$cogname' b/c skewness = $skew" if ($verbose);
                    next;
                }

                push(@sho,[$cogname,$COGS{$cogname}->{count},$mean,$sd,$stats->count(),$skew,$kurtosis,$stats->min(),$stats->max(),scalar(@lesser),scalar(@greater),\@greater]);
            }
        } else {
            # these are COGs that are in query genome, but <5% of the related genomes
            #push(@sho,[$cogname,$COGS{$cogname}->{count},0,0,0,0,0,0,0]);
            push(@sho,[$cogname,$COGS{$cogname}->{count},$mean,$sd,$stats->count(),$skew,$kurtosis,$stats->min(),$stats->max(),scalar(@lesser),scalar(@greater),\@greater]);
        }

    }

    # Use %cogref to analyze SLO's
    for my $cogname (keys %cogref) {
        my $orgrep = $cogref{$cogname}->{orgrep};
        my $stats = Statistics::Descriptive::Full->new();


        my @tallies = values %$orgrep;

        if (scalar(@tallies)) {

            for my $tally (@tallies) {
                $tally = 0 unless ($tally);
                $stats->add_data($tally);
            }

            my ($mean,$sd) = ($stats->trimmed_mean(0.05),$stats->standard_deviation());
            if ($COGS{$cogname}->{count} && $COGS{$cogname}->{count} < ($mean - (2 * $sd))) {
                if ($stats->skewness() < 0.5) {
                    say "skipping '$cogname' b/c skewness = " . $stats->skewness() if ($verbose);
                    next;
                }
                push(@slo,[$cogname,$COGS{$cogname}->{count},$mean,$sd,$stats->count(),$stats->skewness(),$stats->kurtosis(),$stats->min(),[$stats->max()]]);
            } elsif (!$COGS{$cogname}) {
                push(@slo,[$cogname,0,$mean,$sd,$stats->count(),$stats->skewness(),$stats->kurtosis(),$stats->min(),$stats->max()]);
            }

        }# else { # no other organisms in this group have this COG
#
#            push(@slo,[$cogname,$COGS{$cogname}->{count},0,0,0,0,0]);
#
#        }
    }

    say "\nSignificantly High Occurrences:";
    for my $high (@sho) {
        my $highstring = sprintf("%s\t%u\t%.2f\t%.2f\t%u\t%.2f\t%.2f\t%u\t%u\t%u\t%u",@$high);
        $highstring .= "\t" . join ",", @{$high->[11]} if ($high->[11]);
        say $highstring if ($verbose);
        say SHO $highstring;
    }

    say "\nSignificantly Low Occurrences:";
    for my $low (@slo) {
        #my $lowstring = join "\t", @$low;
        my $lowstring = sprintf("%s\t%u\t%.2f\t%.2f\t%u\t%.2f\t%.2f\t%u\t%u",@$low);
        #say "$low->[0]\t$low->[1]\t$low->[2]\t$low->[3]\t$low->[4]\t$low->[5]\t$low->[6]" if ($verbose);
        say $lowstring if ($verbose);
        #say SLO "$low->[0]\t$low->[1]\t$low->[2]\t$low->[3]\t$low->[4]\t$low->[5]\t$low->[6]";
        say SLO $lowstring;
    }

    close(SHO);
    close(SLO);

} # end of if ($crossref) { }

close(OUT);
close(TAB);


######### End of cross-reference section  #################


######### Subroutines ##############

#
# included() returns a string of organism names that all pass the minimum membership test
#
sub included {
  my $orglist = shift;
  my $orgrep = shift;
  my $string = "[";

#   foreach my $org_id (sort { $orglist->{$a}->name() cmp $orglist->{$b}->name() } keys %$orgrep) {
#     if ($orgrep->{$org_id}) {
#       $string .= $orglist->{$org_id}->name() . "(" . $orgrep->{$org_id} . "), ";
#     }
#   }

# convert above routine to use organism codes instead of organism names
#
  foreach my $org_id (sort { $orglist->{$a}->code() cmp $orglist->{$b}->code() } keys %$orgrep) {
    if ($orgrep->{$org_id}) {
      $string .= $orglist->{$org_id}->code() . "(" . $orgrep->{$org_id} . "), ";
    }
  }

  $string =~ s/\,\s$//;
  $string .= "]";
#  print Dumper($orgrep);

  return $string;
}

#
# excluded() returns a string of organism names that fail to pass
# the minimum membership test
#
sub excluded {
  my $orglist = shift;
  my $orgrep = shift;
  my $string = "[";

#   foreach my $org_id (sort { $orglist->{$a}->name() cmp $orglist->{$b}->name() } keys %$orglist) {
#     if (!$orgrep->{$org_id}) {
#       $string .= $orglist->{$org_id}->name() . ", ";
#     }
#   }

# convert above routine to use organism codes instead of organism names
#
  foreach my $org_id (sort { $orglist->{$a}->code() cmp $orglist->{$b}->code() } keys %$orglist) {
    if (!$orgrep->{$org_id}) {
      $string .= $orglist->{$org_id}->code() . ", ";
    }
  }

  $string =~ s/\,\s$//;
  $string .= "]";

  return $string;
}

sub data_out {
  my $data = shift;

  eval {
    require XML::Writer;
    require File::Copy;
    import File::Copy;
  };
  if ($@) {
    die "can't load XML::Writer: $@";
  }

  my $xmloutfile = "$outfile" . ".xml";# $outfile is from MAIN namespace

  #if (-e 'reCOGnition.xml') {
  if (-e $xmloutfile) {
    if (!copy($xmloutfile, $$ . ".$xmloutfile")) {
        die "can't copy $xmloutfile: $!";
    }
    if (!unlink($xmloutfile)) {
        die "can't delete $xmloutfile: $!";
    }
#    if (!copy('reCOGnition.xml',"reCOGnition." . $$ . ".xml")) {
#        die "can't copy old reCOGnition.xml: $!";
#    }
#    if (!unlink('reCOGnition.xml')) {
#        die "can't delete old reCOGnition.xml: $!";
#    }
  }

  #my $file = IO::File->new(">reCOGnition.xml");
  my $file = IO::File->new(">$xmloutfile");
  my $xml = XML::Writer->new(
           OUTPUT   =>  $file,
           DATA_MODE    =>  1,
           DATA_INDENT  =>  5,
           );

  $xml->xmlDecl();
  $xml->doctype("reCOGnition");
  $xml->startTag('reCOGnition');
  $xml->startTag('author');
  $xml->startTag('name');
  $xml->characters('Scott Givan');
  $xml->endTag('name');
  $xml->startTag('email');
  $xml->characters('givans@missour.edu');
  $xml->endTag('email');
  $xml->endTag('author');

  $xml->startTag('data');

  foreach my $cogdata (values %$data) {
    $xml->startTag('cog');

    $xml->dataElement('id',$cogdata->{cog}->id());
    $xml->dataElement('name',$cogdata->{cog}->name());
    $xml->dataElement('description',$cogdata->{cog}->description());
    $xml->dataElement('occurrence',$cogdata->{count});

    $xml->startTag('orflist');
    foreach my $orf (@{$cogdata->{list}}) {
      $xml->dataElement('orf',$orf);
    }
    $xml->endTag('orflist');
    $xml->endTag('cog');
  }

  $xml->endTag('data');

  $xml->endTag("reCOGnition");
  $xml->end();

}

sub data_in {
  my $filename = shift;

  my %data = ();

  eval {
    require XML::Simple;
    import XML::Simple;
  };
  if ($@) {
    die "can't load XML::Simple:  $@";
  }

  my $file = IO::File->new($filename);

  my $indata = XMLin($file);

#  print Dumper($indata);
#  exit();

  my $cogdata = $indata->{data}->{cog};

  foreach my $cogname (keys %$cogdata) {

    my $cog = $cogdb->cog({ID => $cogdata->{$cogname}->{id} });
    print "COG:  ", $cog->name(), "\n" if ($debug);
    print "\tcount: ", $cogdata->{$cogname}->{occurrence}, "\n" if ($debug);

    my $orflist = $cogdata->{$cogname}->{orflist}->{orf};
    my $string = "\tORF:  ";
    my @orflist = ();
    if ($cogdata->{$cogname}->{occurrence} == 1) {
      $string .= "$orflist";
      push(@orflist,$orflist);
    } else {
      foreach my $orfname (@$orflist) {
  $string .= "$orfname ";
  push(@orflist,$orfname);
      }
    }

    $data{$cog->name()} = {
         cog  =>  $cog,
         count  =>  $cogdata->{$cogname}->{occurrence},
         list =>  [@orflist],
        };
    print "$string\n" if ($debug);
  }
  return \%data;
}

sub _help {

print <<HELP;

This script takes the output of BLAST against the COG database
and collects the COGs from the search.  Information about each
COG is generated from the CGRB COGDB.

usage:  reCOGnition.pl <options>

Options:
-f <text> input file name
-F <text> input folder name (default= blast)
-i <text> input data file -- use results from previous run (usually reCOGnition.xml)
-b <text> type of blast search (default = blastp)

-M <integer>  minimum COG membership level
-P <decimal>  minimum proportional representation of COGs to accept
You must use either -M or -P. These levels set the minumum by which a query set is
declared to contain a COG relationship. Setting -M 2 means that there must be at
least two examples of hits to a COG before including it in the list of COGs 
represented in this query set. Setting -P 0.025 means that there must be more
than 2.5% of the total number of occurrences of a specific COG in the database before
including it in the list of COGs represented in the query set. The recommended 
value for either -M or -P is: -M 2 or -P 0.025.

-o <text> output file name (default = reCOGnition.out)
-S    generate a COG Category Summary
-l    generate a COG List
-g    generate a gene list with corresponding COGs
-r <text> cross-reference to related bugs --
                (can enclose multiple divisions separated by spaces; enclose in quotes)
-p    when cross-referencing, exclude pathogenic strains
-e <text> when cross-referencing, exclude this list of org ID's (comma-separated list)
-U    when cross-referencing, fractional upper threshold to define common COGs (default = 0.90)
      This will define the threshold to consider missing COGs and common COGs.
      i.e. if a given COG is missing in this genome, but present in 90% of the genomes
      of related bacteria, flag this COG as missing.  Conversely, if a given COG
      is present in this genome and also present in 90% of related genomes, it is common.
-L    when cross-referencing, fractional lower threshold to define missing COGs (default = 0.10)
      This will define which COGs are novel.
      i.e. if the COG is present in this genome and present in only 10% of the other genomes
      of related bacteria, flag this COG as novel.
-G  when cross-referencing, exclude genomes with less than this number of COGs (default = 1000)
-w <text>       create output file to load local COGDB data (text = local organism code)
-v    verbose output to terminal
-d    debug mode
-D    debug mode -- abbridged analysis
-h    print this help menu


HELP
exit(0);
}
