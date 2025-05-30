#!/usr/bin/perl -w
use strict;
use Getopt::Long;
use File::Path;

my ($inputdir,$outputfile,$help,$bwfile,$threads,$out);

GetOptions(
	"inputdir=s" => \$inputdir,
	"outputfile=s" => \$outputfile,
	"bwfile=s" => \$bwfile,
	"threads=i"   => \$threads,
	"help!" => \$help,
);

my @samples = `find $inputdir -name "*.bam"`;
my $bamfiles = "";
foreach my $sample (@samples){
	chomp $sample;
	$bamfiles .= "$sample ";
}

open(SH,">$inputdir/merge.sh") or die "$!\n";
print SH "samtools merge $outputfile $bamfiles\n";
print SH "samtools index $outputfile\n";
print SH "bamCoverage -b $outputfile -of bigwig --binSize 10 --ignoreDuplicates --normalizeUsing BPM --numberOfProcessors $threads -o $bwfile";
close(SH);

$out = system("sh $inputdir/merge.sh 1>>$inputdir/std.log 2>>$inputdir/error.log");
if($out==0){
	print "The task was successfully submitted\n";
}
