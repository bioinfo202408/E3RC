#!/bin/bash

outputdir=$1
hisat2dir=$2

samples=$(find "$outputdir/$hisat2dir" -type d -name "SRR*")

for sample_path in $samples; do
    sample_id=$(basename "$sample_path")

    samtools view -bS "$outputdir/$hisat2dir/$sample_id/accepted_hits_NHi1.sam" \
        -o "$outputdir/$hisat2dir/$sample_id/accepted_hits_NHi1.bam"

    echo "SAM to BAM conversion completed for sample $sample_id."
done

echo "All samples processed."
