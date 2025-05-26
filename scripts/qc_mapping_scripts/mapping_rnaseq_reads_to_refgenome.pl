#!/usr/bin/perl -w
use strict;
use Getopt::Long;
use warnings;
use File::Path qw(mkpath);
use File::Find;

my ($inputdir,$outputdir,$indexdir,$hisat2dir,$picarddir,$threads,$help);

GetOptions(
	"inputdir|i=s" => \$inputdir,
	"outputdir|o=s" => \$outputdir,
	"indexdir=s" => \$indexdir,
	"hisat2dir=s" => \$hisat2dir,
	"picarddir=s" => \$picarddir,
	"threads=s" => \$threads,
	"help!" => \$help,
);

my @samples = `find $inputdir -name "SRR*.fq"`;
print join("\n",@samples)."\n";
foreach my $sample_p1 (@samples){
	chomp $sample_p1;
	$sample_p1 =~ /([^\/]+)_1_val_1\.fq$/;
my $sample_id = $1;

	if(!-e "$outputdir/$hisat2dir/$sample_id"){
		mkpath("$outputdir/$hisat2dir/$sample_id",0644);
		if($@){
			print "Make path $outputdir/$hisat2dir/$sample_id failed:$@\n";
			exit(1);
		}
	}
	open(SH,">$outputdir/$hisat2dir/$sample_id/${sample_id}_expcal.sh") or die "$!\n";
			 	         if(!-e "$outputdir/$hisat2dir/$sample_id/accepted_hits_NHi1.sorted.unique.bam" || -z "$outputdir/$hisat2dir/$sample_id/accepted_hits_NHi1.sorted.unique.bam"){
			 	           		 print SH "hisat2 -x $indexdir -p $threads --dta --rg-id $sample_id --rg SM:$sample_id -1 $inputdir/$sample_id\_1_val_1.fq -2 $inputdir/$sample_id\_2_val_2.fq --summary-file $outputdir/$hisat2dir/$sample_id/mapping_summary.txt -S $outputdir/$hisat2dir/$sample_id/accepted_hits.sam\n";
			 	           	 }
			 	           	 if(!-e "$outputdir/$hisat2dir/$sample_id/accepted_hits_NHi1.sorted.unique.bam" || -z "$outputdir/$hisat2dir/$sample_id/accepted_hits_NHi1.sam"){
			 	           		 print SH "grep -v -E -w 'NH:i:2|NH:i:3|NH:i:4|NH:i:5|NH:i:6|NH:i:7|NH:i:8|NH:i:9|NH:i:10|NH:i:11|NH:i:12|NH:i:13|NH:i:14|NH:i:15|NH:i:16|NH:i:17|NH:i:18|NH:i:19|NH:i:20' $outputdir/$hisat2dir/$sample_id/accepted_hits.sam > $outputdir/$hisat2dir/$sample_id/accepted_hits_NHi1.sam\n";
			 	           	 }
			 	           	 if(!-e "$outputdir/$hisat2dir/$sample_id/accepted_hits_NHi1.sorted.unique.bam" || -z "$outputdir/$hisat2dir/$sample_id/accepted_hits_NHi1.sorted.unique.bam"){
			 	           	        print SH "samtools view -bS $outputdir/$hisat2dir/$sample_id/accepted_hits_NHi1.sam -o $outputdir/$hisat2dir/$sample_id/accepted_hits_NHi1.bam\n";
			 	           	        print SH "samtools sort -@ $threads -o $outputdir/$hisat2dir/$sample_id/accepted_hits_NHi1.sorted.bam $outputdir/$hisat2dir/$sample_id/accepted_hits_NHi1.bam\n";
			 	           	 }
			 	           	 if(!-e "$outputdir/$hisat2dir/$sample_id/accepted_hits_NHi1.sorted.unique.bam" || -z "$outputdir/$hisat2dir/$sample_id/accepted_hits_NHi1.sorted.unique.bam"){
			 	           	        print SH "java -Xmx15g -jar $picarddir MarkDuplicates I=$outputdir/$hisat2dir/$sample_id/accepted_hits_NHi1.sorted.bam O=$outputdir/$hisat2dir/$sample_id/accepted_hits_NHi1.sorted.unique.bam METRICS_FILE=$outputdir/$hisat2dir/$sample_id/${sample_id}.metricsFile VALIDATION_STRINGENCY=LENIENT REMOVE_DUPLICATES=true ASSUME_SORT_ORDER=coordinate\n";
			 	           	 }
			 	           	 if(!-e "$outputdir/$hisat2dir/$sample_id/accepted_hits_NHi1.sorted.unique.bam" || -z "$outputdir/$hisat2dir/$sample_id/accepted_hits_NHi1.sorted.unique.bam"){
			 	           		 print SH "samtools index $outputdir/$hisat2dir/$sample_id/accepted_hits_NHi1.sorted.unique.bam\n";
							  	 print SH "rm $outputdir/$hisat2dir/$sample_id/accepted_hits_NHi1.bam\n";
							 	 print SH "rm $outputdir/$hisat2dir/$sample_id/accepted_hits_NHi1.sorted.bam\n";
							         print SH "rm $outputdir/$hisat2dir/$sample_id/accepted_hits_NHi1.sam\n";
							         print SH "rm $outputdir/$hisat2dir/$sample_id/accepted_hits.sam\n";
					  }
           	close SH;

		  	 my $taskNum =`ps -aux | grep perl | grep hisat | wc -l`; 
		        while($taskNum > 5){
		            print "The num of task remaining $taskNum\n";
		            sleep 30;
		            print `date`;
		            $taskNum = `ps -aux | grep perl | grep hisat | wc -l`;
		        }
	
	my $out = system("sh $outputdir/$hisat2dir/$sample_id/${sample_id}_expcal.sh 1>>$outputdir/$hisat2dir/$sample_id/std.log 2>>$outputdir/$hisat2dir/$sample_id/error.log &");
	if($out==0){
		print "The task of $sample_id is successfully submitted\n";
	}
}						