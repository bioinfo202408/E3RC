#!/usr/bin/perl -w
use strict;
use Getopt::Long;
use File::Path;

my ($gtffile,$outfile,$help);
GetOptions(
	"gtffile=s" => \$gtffile,
	"outfile=s" => \$outfile,
	"help!" => \$help,
);

open(GFF,"<$gtffile") or die "$!\n";
open(OUT,">$outfile") or die "$!\n";
while(<GFF>){
    my $line = $_;
    chomp $line;
    next if($line =~ /^#/);
    my @fieldValues = split /\t/,$line;
    if($fieldValues[2] eq "gene"){
        my @geneinfo = $fieldValues[8] =~ /gene_id\s+"([^"]+)".*?gene_type\s+"([^"]+)".*?gene_name\s+"([^"]+)"/;
        print OUT join("\t",@geneinfo)."\n";
    }
}
close GFF;
close OUT;