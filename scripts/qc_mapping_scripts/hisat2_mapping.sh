#!/bin/bash
inputdir=$1
outputdir=$2
indexdir=$3
hisat2dir=$4
threads=$5
samples=$(find "$inputdir" -name "*_1_val_1.fq" | sed 's/_1_val_1\.fq$//')
for sample_path in $samples; do
    sample_id=$(basename "$sample_path")
    mkdir -p "$outputdir/$hisat2dir/$sample_id"
    hisat2 -x "$indexdir" -p "$threads" --dta --rg-id "$sample_id" --rg SM:"$sample_id" \
        -1 "$inputdir/${sample_id}_1_val_1.fq" \
        -2 "$inputdir/${sample_id}_2_val_2.fq" \
        --summary-file "$outputdir/$hisat2dir/$sample_id/mapping_summary.txt" \
        -S "$outputdir/$hisat2dir/$sample_id/accepted_hits.sam"

    echo "HISAT2 mapping completed for sample $sample_id."
done
echo "All samples processed."
