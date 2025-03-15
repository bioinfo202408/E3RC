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

# 查找所有 BAM 文件
my @samples = `find $inputdir -name "*.bam"`;
chomp @samples;

# 合并 BAM 文件
my $bamfiles = join(" ", @samples);
system("samtools merge $outputfile $bamfiles") == 0 or die "Failed to merge BAM files: $!";

# 构建索引
system("samtools index $outputfile") == 0 or die "Failed to index merged BAM file: $!";

print "BAM files merged and indexed successfully.\n";
