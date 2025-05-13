#!/usr/bin/perl -w
use strict;
use Getopt::Long;
use File::Path;

my ($genomefile,$jsfile,$posfile,$outputdir,$help);
GetOptions(
    "genomefile=s" => \$genomefile,
    "outputdir=s" => \$outputdir,
	"posfile=s" => \$posfile,
	"help!" => \$help,
	"jsfile=s" => \$jsfile
);

open(GENOME,"<$genomefile") or die "Could not open the file $genomefile:$!\n";
my (%chromosome,$chromname);
while(<GENOME>){
	my $line = $_;
	chomp $line;
	if($line =~ />(chr.*)/){
		my @lineContent = split /\s+/,$1;
		$chromname = $lineContent[0];
		print "$chromname\n";
		$chromosome{$chromname} = "";
	}else{
        $chromosome{$chromname} .= $line;
    }
}
close GENOME;

my (%stageHash,%jsHash);
open(JS,"<$jsfile") or die "$!\n";
while(<JS>){
	my $line = $_;
	chomp $line;
	my @fieldValues = split /\s+/,$line;
	push @{$stageHash{$fieldValues[2]}}, $fieldValues[0];
	$jsHash{$fieldValues[0]} = $fieldValues[1];
}
close JS;

my %posHash;
open(ERNA,"<$posfile") or die "Could not open the file $posfile:$!\n";
while(<ERNA>){
	my $line = $_;
	chomp $line;
	my @fieldValues = split /\s+/,$line;
	$posHash{$fieldValues[3]} = "$fieldValues[0]\t$fieldValues[1]\t$fieldValues[2]";
}
close ERNA;

foreach my $stagename (keys %stageHash){
	if(!-e "$outputdir/$stagename"){
		mkpath("$outputdir/$stagename",0644);
		if($@){
			print "Make path $outputdir/$stagename failed:$@\n";
			exit(1);
		}
	}
	
	open(FA,">$outputdir/$stagename/$stagename\_eRNAs.fasta") or die "Could not open the file $outputdir/$stagename/$stagename\_eRNAs.fasta:$!\n";
	foreach my $eRNAid (@{$stageHash{$stagename}}){
		my @fieldValues = split /\t/,$posHash{$eRNAid};
		if(exists $jsHash{$eRNAid}){
			my $geneseq = substr($chromosome{$fieldValues[0]},$fieldValues[1],($fieldValues[2]-$fieldValues[1]+1));
			print FA ">$eRNAid\t$jsHash{$eRNAid}\n";
			my $strnum = length($geneseq);
			my $iternum = int($strnum/50);
			for(my $iter=1;$iter<=$iternum;$iter++){
				print FA substr($geneseq,50*($iter-1),50)."\n";
			}
			print FA substr($geneseq,50*$iternum,($strnum-50*$iternum)-1)."\n";
		}
	}
	close FA;
}

