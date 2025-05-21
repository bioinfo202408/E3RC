#!/bin/bash

INPUT_DIR=$1
OUTPUT_DIR=$2

if [[ ! -d "$INPUT_DIR" ]]; then
    echo "Error: input directory not exist: $INPUT_DIR"
    exit 1
fi

mkdir -p "$OUTPUT_DIR"

for FILE1 in "${INPUT_DIR}"/*_1.fastq; do
    if [[ ! -f "$FILE1" ]]; then
        echo "Warning: no matches were found *_1.fastq file"
        continue
    fi

    BASENAME=$(basename "$FILE1" "_1.fastq")
    FILE2="${INPUT_DIR}/${BASENAME}_2.fastq"

    if [[ -f "$FILE2" ]]; then
        echo "file in process: $BASENAME"
        
        trim_galore --paired --quality 20 --illumina -o "$OUTPUT_DIR" "$FILE1" "$FILE2"
    else
        echo "Warning: not found $FILE1 R2 file: $FILE2"
    fi
done
