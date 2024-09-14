#!/usr/bin/env bash

#PBS -N mapping_genomad_virus_NJ_PE_GF
#PBS -l nodes=1:ppn=40 #1 of node requested; 20 processors in total
#PBS -l walltime=48:00:00 # 48 hours walltime
#PBS -l mem=150gb #150 Gb memory in total
#PBS -m abe
#PBS -M MohammedHisham.Shaikh@ugent.be
#PBS -o /data/gent/vo/001/gvo00125/vsc44392/Projects/North_Sea_Viral_Metagenomics/logs/${PBS_JOBNAME}_output.log  
#PBS -e /data/gent/vo/001/gvo00125/vsc44392/Projects/North_Sea_Viral_Metagenomics/logs/${PBS_JOBNAME}_error.log   



#Making sure I am on the rigth cluster
module swap cluster/doduo

# Unset OMP_PROC_BIND
unset OMP_PROC_BIND



# AIM: Getting RPKM on NJ_PE_GF_cross_assembly

. ~/vo_vliz.sh
. .bashrc

# Defining directories
HOME_DIR="/data/gent/vo/001/gvo00125/vsc44392/Projects/North_Sea_Viral_Metagenomics"
GENOMAD_VIRUS_SUMMARY="$HOME_DIR/working/4_genomad/2_genomad_cross_assemblies/NJ_PE_GF_genomad_output/NJ_PE_GF_clustered_contigs_summary/NJ_PE_GF_clustered_contigs_virus_summary.tsv"
BOWTIE2_QUANT="$HOME_DIR/working/5_read_mapping/2_NJ_PE_GF/combined_quant/combined_read_counts_NJ_PE_GF.txt"
OUTPUT_DIR="$HOME_DIR/working/7_bacteriophages/10_mapping_viruses/genomad_viruses"
OUTPUT_FILE="$OUTPUT_DIR/genomad_viral_contig_read_counts.txt"
RPK_OUTPUT="$OUTPUT_DIR/genomad_viral_contig_RPK.txt"
RPKM_OUTPUT="$OUTPUT_DIR/genomad_viral_contig_RPKM.txt"
PHABOX_SUMMARY="$HOME_DIR/working/7_bacteriophages/1_phabox/NJ_PE_GF_phabox/NJ_PE_GF_phabox_output/prediction_summary.csv"
PHABOX_RPKM_OUTPUT="$OUTPUT_DIR/phabox_summary_with_rpkm.csv"


mkdir -p $OUTPUT_DIR
cd $OUTPUT_DIR


# Step 1: Extracting viral contigs from GeNomad output
awk 'NR>1 {print $1, $2}' $GENOMAD_VIRUS_SUMMARY > genomad_viral_contigs.txt

# Step 2: Filtering Bowtie2 quant file for viral contigs
echo -e "Sample\tContig\tContig_Length\tMapped_Reads\tUnmapped_Reads" > $OUTPUT_FILE
awk 'NR==FNR {viral[$1]; next} $2 in viral' genomad_viral_contigs.txt $BOWTIE2_QUANT >> $OUTPUT_FILE

# Step 3: Calculating RPK for each viral contig and save to RPK output file
echo -e "Sample\tContig\tContig_Length\tMapped_Reads\tUnmapped_Reads\tRPK" > $RPK_OUTPUT
awk 'NR>1 {RPK = $4 / ($3 / 1000); print $0, RPK}' $OUTPUT_FILE >> $RPK_OUTPUT

# Step 4: Calculating the total mapped reads from Bowtie2 quant file
TOTAL_MAPPED_READS=$(awk 'NR>1 {sum+=$4} END {print sum}' $OUTPUT_FILE)

# Step 5: Calculating RPKM for each viral contig and save to RPKM output file
echo -e "Sample\tContig\tContig_Length\tMapped_Reads\tUnmapped_Reads\tRPK\tRPKM" > $RPKM_OUTPUT
awk -v total_reads=$TOTAL_MAPPED_READS 'NR>1 {RPKM = ($4 / ($3 / 1000)) * (1000000 / total_reads); print $0, RPKM}' $RPK_OUTPUT >> $RPKM_OUTPUT

echo "RPKM values saved to $RPKM_OUTPUT"

# Step 6: Attaching RPKM to phaBOX output
module load R/4.3.2-gfbf-2023a


