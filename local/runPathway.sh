#! /bin/bash
set -x
set -e

WORK_DIR="/home/zhaoc1/test_data/qc"
DECONTAM_HOST_OUTPUT_DIR="${WORK_DIR}/decontam"
R1="Phi6Spikec_R1.fastq"
R2="Phi6Spikec_R2.fastq"
PATHWAY_OUTPUT_DIR="${WORK_DIR}/pathfinder_results"
PATHWAY_SUMMARY="${WORK_DIR}/summary-pathway.json"

pathfinder.py \
    --forward-reads "${DECONTAM_HOST_OUTPUT_DIR}/${R1}" \
    --reverse-reads "${DECONTAM_HOST_OUTPUT_DIR}/${R2}" \
    --output-dir $PATHWAY_OUTPUT_DIR \
    --summary-file $PATHWAY_SUMMARY \
    --kegg_fp "/mnt/isilon/microbiome/biodata/kegg" \
    --kegg_idx_fp "/mnt/isilon/microbiome/biodata/keggRAP" \
    --kegg_to_ko_fp "/mnt/isilon/microbiome/biodata/kegg2ko" \
    --rap_search_fp "/home/zhaoc1/sunbeam/local/RAPSearch2/bin/rapsearch" \
    --threads 4

