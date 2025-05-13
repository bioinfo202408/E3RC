#!/usr/bin/perl -w
use strict;
use Getopt::Long;
use File::Path;

my ($infile,$outfile,$help);

GetOptions(
    "infile|i=s"  => \$infile,
    "outfile|o=s" => \$outfile,
    "help!"       => \$help,
);

open(IN, "<$infile") or die "$!\n";
open(OUT, ">$outfile") or die "$!\n";

my @data;

while (<IN>) {
    chomp;
    next if /^chr,start,end/i;
    my @fields = split /,/;
    push @data, \@fields;
}
close IN;

sub chr_rank {
    my $chr = shift;
    if ($chr =~ /^chr(\d+)$/i) {
        return $1;
    } elsif ($chr =~ /^chrX$/i) {
        return 1000;
    } elsif ($chr =~ /^chrY$/i) {
        return 1001;
    } else {
        return 2000;
    }
}

@data = sort {
    chr_rank($a->[0]) <=> chr_rank($b->[0]) ||
    $a->[1] <=> $b->[1]
} @data;

my $number = 1;
foreach my $entry (@data) {
    print OUT "$entry->[0]\t$entry->[1]\t$entry->[2]\tENH" . sprintf("%06d", $number) . "\n";
    $number++;
}

close OUT;
