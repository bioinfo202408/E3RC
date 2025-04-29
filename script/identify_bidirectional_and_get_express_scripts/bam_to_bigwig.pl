#!/usr/bin/perl -w
use strict;
use Getopt::Long;
use File::Path;

my ($inputdir, $help, $bwfile, $threads);

GetOptions(
    "inputdir=s" => \$inputdir,
    "bwfile=s"   => \$bwfile,
    "threads=i"  => \$threads,
    "help!"      => \$help,
);

die "Usage: $0 --inputdir DIR --bwfile OUTPUT_DIR --threads N\n" if $help || !$inputdir || !$bwfile || !$threads;


$inputdir =~ s/\/$//;
$bwfile =~ s/\/$//;  


my @samples = glob("$inputdir/*.bam");
die "No BAM files found in $inputdir\n" unless @samples;


mkpath($bwfile) unless -d $bwfile;


my $sh_file = "$inputdir/bam_to_bw.sh";
open(SH, ">$sh_file") or die "Cannot open $sh_file: $!\n";

foreach my $sample (@samples) {
    chomp $sample;
    my ($basename) = $sample =~ /([^\/]+)\.bam$/;  
    my $out_bw = "$bwfile/${basename}.bw";  
    print SH "bamCoverage -b $sample -of bigwig --binSize 10 --ignoreDuplicates --normalizeUsing BPM --numberOfProcessors $threads -o $out_bw\n";
}

close(SH);

# 运行 shell 脚本
my $out = system("sh $sh_file 1>>$inputdir/std.log 2>>$inputdir/error.log");
if ($out == 0) {
    print "The task was successfully submitted\n";
} else {
    print "Error in execution. Check error logs.\n";
}
