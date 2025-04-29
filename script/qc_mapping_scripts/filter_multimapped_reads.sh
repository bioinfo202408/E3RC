#!/bin/bash

# 参数
outputdir=$1
hisat2dir=$2

# 查找所有样本
samples=$(find "$outputdir/$hisat2dir" -type d -name "SRR*")

# 遍历每个样本
for sample_path in $samples; do
    sample_id=$(basename "$sample_path")

    # 过滤多比对 reads
    grep -v -E -w 'NH:i:2|NH:i:3|NH:i:4|NH:i:5|NH:i:6|NH:i:7|NH:i:8|NH:i:9|NH:i:10|NH:i:11|NH:i:12|NH:i:13|NH:i:14|NH:i:15|NH:i:16|NH:i:17|NH:i:18|NH:i:19|NH:i:20' \
        "$outputdir/$hisat2dir/$sample_id/accepted_hits.sam" > \
        "$outputdir/$hisat2dir/$sample_id/accepted_hits_NHi1.sam"

    echo "Multi-mapped reads filtered for sample $sample_id."
done

echo "All samples processed."
