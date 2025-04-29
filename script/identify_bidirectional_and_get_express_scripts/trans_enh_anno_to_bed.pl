#!/usr/bin/perl -w
use strict;
use Getopt::Long;
use File::Path;

my ($infile,$outfile,$help);

GetOptions(
	"infile|i=s" => \$infile,
	"outfile|o=s" => \$outfile,
	"help!" => \$help,
);

open(IN,"<$infile") or die "$!\n";
open(OUT,">$outfile") or die "$!\n";
my $number = 1;
while(<IN>){
	my $line = $_;
	chomp $line;
	next if($line =~ /^chr/);
	my @fieldValues = split /,/,$line;
	print OUT "$fieldValues[0]\t$fieldValues[1]\t$fieldValues[2]\tENH".sprintf("%06d",$number)."\n";
	$number = $number + 1;
}
close IN;
close OUT;
