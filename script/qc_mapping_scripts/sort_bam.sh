#!/bin/bash

# 参数
outputdir=$1
hisat2dir=$2
threads=$3

# 查找所有样本
samples=$(find "$outputdir/$hisat2dir" -type d -name "SRR*")

# 遍历每个样本
for sample_path in $samples; do
    sample_id=$(basename "$sample_path")

    # 排序 BAM 文件
    samtools sort -@ "$threads" \
        -o "$outputdir/$hisat2dir/$sample_id/accepted_hits_NHi1.sorted.bam" \
        "$outputdir/$hisat2dir/$sample_id/accepted_hits_NHi1.bam"

    echo "SORT BAM conversion completed for sample $sample_id."
done

echo "All samples processed."
