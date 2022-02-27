#!/usr/bin/perl -w

###################################################################################################
#
# decidata.pl
#
# pick genes having sequence from decisive group, which could be clades of taxa, or particular taxa
# 
#
# Input: the directory storing the fasta files of the genes. taxa must have
#
# Output: gene files meet the requirement in a new folder called originalfolder.decisive
#
# Written by 
#                 Chenhong Li
#                 Shanghai Ocean University, China
#                 Created on Feb 2015
#                 Last modified on
#
###################################################################################################

use warnings;
use experimental 'smartmatch';

use Getopt::Long;   # include the module for input


my $dir = "test"; #variable for store the directory
my $taxagroup = "46QUNI,01RHAS,02ODPO 03MISW,04TYPA 05MIVE";

my $opt = GetOptions( 'dir:s', \$dir,
                      'taxagroup:s', \$taxagroup,
                      'help!', \$help); #set command line options
                      

if (!($opt && $dir && $taxagroup) || $help) {#check for the required inputs
   print STDERR "\nExample usage:\n";
   print STDERR "\n$0 -dir=\"test\" -taxagroup=\"a b,c,d e f\"\n";
   print STDERR "Options:\n";
   print STDERR "        -dir = name of the directory holding all gene files\n";
   print STDERR "        -taxagroup = name group of taxa that must be included\n";
   print STDERR "                     at least one of the taxon from each group\n";
   print STDERR "                     has to exist for the gene to be selected.\n";
   print STDERR "                     The groups are separated by comma, the taxa\n";
   print STDERR "                     are separated by space. \n\n";
   exit;
}
                      
                      
my $outdir = $dir . "_decisive"; #variable for store the directory
system ("mkdir $outdir");

my @group = split /\,/, $taxagroup;

opendir (DIR, $dir) or die $!; #open folder containing all fasta data file
my $genecount = 0;

while (my $file = readdir(DIR)) { #read all fasta files under the folder
    
    next if ($file =~ /^\./); #skip files beginning with .
    
    my $infile = $dir . "/$file";
    open (my $IN_FILE, "<$infile") or die "Can't open the  file!!!";
    my @taxainfile;
    while (my $line = readline ($IN_FILE)) {
        chop $line; #use chop bc there are maybe hidden characters in dos format files
        if (my ($speciesname) = $line =~ /^>(\S+)/) { # if we find >
            push @taxainfile, $speciesname; #push the taxon name into the array
        }
    }
    
    #print "$file\n";
    
    my $goodgene = 1; #set the switch for good gene
    foreach my $group (@group) {#loop through each group
        my @taxaingroup = split/\s+/, $group;
        my $good4group = 0;
        foreach my $taxon (@taxaingroup) {#loop through each taxon
            if ($taxon ~~ @taxainfile) {#check if the taxon is in the gene file
                #print "$taxon\n";
                $good4group = 1;
            }
        }
        $goodgene = "0" if ($good4group == 0);
    }
    
    if ($goodgene) {#if the gene has all taxa required copy it to anther directory
        $outfile = $outdir . "/$file";
        system ("cp $infile $outfile");
        $genecount ++;
    }
    
    close ($IN_FILE) or die "Can't close the input file!!!";
    
}

closedir (DIR);

print "A total of $genecount decisive genes were found!\n";

