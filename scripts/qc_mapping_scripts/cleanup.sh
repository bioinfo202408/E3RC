#!/bin/bash

outputdir=$1
hisat2dir=$2

samples=$(find "$outputdir/$hisat2dir" -type d -name "SRR*")

for sample_path in $samples; do
    sample_id=$(basename "$sample_path")

    rm "$outputdir/$hisat2dir/$sample_id/accepted_hits_NHi1.bam"
    rm "$outputdir/$hisat2dir/$sample_id/accepted_hits_NHi1.sorted.bam"
    rm "$outputdir/$hisat2dir/$sample_id/accepted_hits_NHi1.sam"
    rm "$outputdir/$hisat2dir/$sample_id/accepted_hits.sam"

    echo "Intermediate files cleaned up for sample $sample_id."
done

echo "All samples processed."
