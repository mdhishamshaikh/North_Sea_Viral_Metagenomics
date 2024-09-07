#!/bin/bash
# AIM: To classify viral contigs

. ~/vo_vliz.sh
. .bashrc

# Defining directories
HOME_DIR="/data/gent/vo/001/gvo00125/vsc44392/Projects/North_Sea_Viral_Metagenomics"
OUTPUT_DIR="$HOME_DIR/working/3_genomad/2_genomad_cross_assemblies"
ASSEMBLY_DIR="$HOME_DIR/working/2_assembly/1_cross_assemblies"
SAMPLE_LIST_NJ_PE_GF="$HOME_DIR/data/sample_overview/NJ_PE_GF_sample_list.csv"
GENOMAD_DB="$HOME/viral_tools/genomad/genomad_db"


mkdir -p $OUTPUT_DIR
cd $OUTPUT_DIR


mamba activate genomad


while IFS= read -r sample; do
  
    echo "Running Genomad end-to-end for sample: $sample"

    # Running genomad
    genomad end-to-end --cleanup --splits 16 "$ASSEMBLY_DIR/${sample}_cross_assembly/${sample}_final_contigs.fa" "$OUTPUT_DIR/${sample}_genomad_output" "$GENOMAD_DB"
 
done < "$SAMPLE_LIST_NJ_PE_GF"


mamba deactivate