#!/usr/bin/perl -w
use strict;
use Getopt::Long;
use File::Path;

my ($motifdir,$outfile,$help);

GetOptions(
	"motifdir=s" => \$motifdir,
	"outfile=s" => \$outfile,
	"help!" => \$help,
);

my @motifseqfiles = `find $motifdir -name "sequences.tsv"`;

open(OUT,">$outfile") or die "$!\n";
foreach my $motifseqfile (@motifseqfiles){
	chomp $motifseqfile;
	my $enfile = $motifseqfile;
	$enfile =~ s/sequences/ame/;
	my $stat ="No";
	open(EN,"<$enfile") or die "$!\n";
	my $adj_pvalue = "";
	my $motif_Name = "";
	while(<EN>){
		my $line = $_;
		chomp $line;
		next if($line =~ /^rank/);
		my @fieldValues = split /\t/,$line;
		if(defined $fieldValues[6] && $fieldValues[6] < 0.01){
			$stat="Yes";
		}
		$adj_pvalue = $fieldValues[6] if defined $fieldValues[6];
		$motif_Name = $fieldValues[3] if defined $fieldValues[3];
		last;
	}
	close EN;
	$motifseqfile=~/motif_enrich_results\/(.*?)\/.*/;
	my $stageName = $1;
	open(MS,"<$motifseqfile") or die "$!\n";
	while(<MS>){
		my $line = $_;
		chomp $line;
		my @fieldValues = split /\s+/,$line;
		if(defined $fieldValues[6] && $fieldValues[6] eq "tp"){
			if($fieldValues[3] !~ /shuf/){
				print OUT "$fieldValues[1]\t$motif_Name\t$fieldValues[3]\t$fieldValues[5]\t$stageName\t$stat\t$adj_pvalue\n";
			}
		}
	}
	close MS;
}
close OUT;

