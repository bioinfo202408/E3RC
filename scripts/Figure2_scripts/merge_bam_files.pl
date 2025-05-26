#!/usr/bin/perl -w
use strict;
use Getopt::Long;
use File::Path;

my ($inputdir, $outputfile, $help);

GetOptions(
    "inputdir=s"   => \$inputdir,
    "outputfile=s" => \$outputfile,
    "help!"        => \$help,
);

my @samples = `find $inputdir -name "*.bam"`;
chomp @samples;

my $bamfiles = join(" ", @samples);
system("samtools merge $outputfile $bamfiles") == 0 or die "Failed to merge BAM files: $!";

(my $sortedfile = $outputfile) =~ s/\.bam$/.sorted.bam/;
system("samtools sort -o $sortedfile $outputfile") == 0 or die "Sort failed\n";

system("samtools index $sortedfile") == 0 or die "Index failed\n";

unlink $outputfile or warn "Failed to delete $outputfile\n";

print "Done: $sortedfile and index created\n";