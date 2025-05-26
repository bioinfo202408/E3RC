#!/usr/bin/perl -w
use strict;
use Getopt::Long;

my ($inputbam, $bwfile, $threads, $help);

GetOptions(
    "inputbam=s" => \$inputbam,
    "bwfile=s"   => \$bwfile,
    "threads=i"  => \$threads,
    "help!"      => \$help,
);

# change BAM file to BigWig file
system("bamCoverage -b $inputbam -of bigwig --binSize 10 --ignoreDuplicates --normalizeUsing BPM --numberOfProcessors $threads -o $bwfile") == 0
    or die "Failed to convert BAM to BigWig: $!";

print "BAM file converted to BigWig successfully.\n";
