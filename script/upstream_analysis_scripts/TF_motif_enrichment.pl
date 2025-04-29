#!/usr/bin/perl -w
use strict;
use Getopt::Long;
use File::Path;

my ($inputdir,$outputdir,$motifdir,$help);
GetOptions(
	"inputdir=s" => \$inputdir,
    "outputdir=s" => \$outputdir,
	"motifdir=s" => \$motifdir,
	"help!" => \$help,
);

my @fastafiles = `find $inputdir -name "*.fasta"`;
foreach my $fastafile (@fastafiles){
    chomp $fastafile;
    $fastafile =~ /.*\/(.*)\_eRNAs.fasta/;
    my $stagename = $1;
    my @motiffiles = `find $motifdir -name "*meme"`;
    foreach my $motiffile (@motiffiles){
		$motiffile =~ /.*\/(.*)\.meme/;
		my $motifname = $1;
		mkpath("$outputdir/$stagename/$motifname",0644);
		if($@){
			print "Make path $outputdir/$stagename/$motifname failed:$@\n";
			exit(1);
		}

		my $out = system("ame --control --shuffle-- --oc $outputdir/$stagename/$motifname $fastafile $motiffile");
		if($out == 0){
			print "The task of $stagename/$motifname is successfully submitted\n";
		}
	}
}





