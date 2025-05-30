#!/usr/bin/perl -w
use Getopt::Long;
use File::Path;

my ($motiffile,$outputdir,$mapfile,$help);

GetOptions(
	"motiffile=s" => \$motiffile,
	"outputdir=s" => \$outputdir,
	"mapfile=s" => \$mapfile,
	"help!" => \$help,
);

open(MOT,"<$motiffile") or die "$!\n";
my $header="MEME version 4

ALPHABET= ACGT

strands: + -

Background letter frequencies
A 0.25 C 0.25 G 0.25 T 0.25

";

open(MAP,">$mapfile") or die "$!\n";
my @array = <MOT>;
foreach my $element (@array){
	next if($element =~ /^MEME|^ALPH|^strand|^Background|^A\s0.25|^\s+$/);
	chomp $element;
	if($element =~ /^MOTIF/){
		my @fieldValues = split /\s+/,$element;
		print MAP "$fieldValues[1]\t$fieldValues[2]\n";
		open(OUT,">$outputdir/$fieldValues[1].meme") or die "$!\n";
		print OUT "$header\n";
		print OUT "$element\n";
	}else{
		print OUT "$element\n";
	}
}
close OUT;
close MOT;
close MAP;


