#!/bin/bash
outputdir=$1
hisat2dir=$2
picarddir=$3
samples=$(find "$outputdir/$hisat2dir" -type d -name "SRR*")

for sample_path in $samples; do
    sample_id=$(basename "$sample_path")

    java -Xmx15g -jar "$picarddir" MarkDuplicates \
        I="$outputdir/$hisat2dir/$sample_id/accepted_hits_NHi1.sorted.bam" \
        O="$outputdir/$hisat2dir/$sample_id/accepted_hits_NHi1.sorted.unique.bam" \
        METRICS_FILE="$outputdir/$hisat2dir/$sample_id/${sample_id}.metricsFile" \
        VALIDATION_STRINGENCY=LENIENT REMOVE_DUPLICATES=true ASSUME_SORT_ORDER=coordinate

    echo "Duplicates marked and removed for sample $sample_id."
done

echo "All samples processed."
